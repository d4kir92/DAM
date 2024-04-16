-- SV DAM Server
local oldhostname = GetHostName()
local oldplycount = -1
local oldpassword = ""
local curpassword = ""
local oldloadingurl = ""
local curloadingurl = ""
RunConsoleCommand("sv_hibernate_think", 1)
--sql.Query("DROP TABLE DAM_UGS;")
DAM_SQL_CREATE_TABLE("DAM_SERVER")
DAM_SQL_ADD_COLUMN("DAM_SERVER", "hostname_toggle", "INT DEFAULT 0")
DAM_SQL_ADD_COLUMN("DAM_SERVER", "hostname", "TEXT DEFAULT 'unnamed'")
DAM_SQL_ADD_COLUMN("DAM_SERVER", "password_toggle", "INT DEFAULT 0")
DAM_SQL_ADD_COLUMN("DAM_SERVER", "password", "TEXT DEFAULT ''")
DAM_SQL_ADD_COLUMN("DAM_SERVER", "loadingurl_toggle", "INT DEFAULT 0")
DAM_SQL_ADD_COLUMN("DAM_SERVER", "loadingurl", "TEXT DEFAULT ''")
if DAM_SQL_SELECT("DAM_SERVER", nil, "uid = '1'") == nil then
	DAM_SQL_INSERT_INTO(
		"DAM_SERVER",
		{
			["hostname"] = GetHostName()
		}
	)

	local pw = GetConVar("sv_password")
	local loadingurl = GetConVar("sv_loadingurl")
	if pw and loadingurl then
		pw = pw:GetString()
		loadingurl = loadingurl:GetString()
		DAM_SQL_INSERT_INTO(
			"DAM_SERVER",
			{
				["hostname"] = GetHostName(),
				["password"] = pw,
				["loadingurl"] = loadingurl
			}
		)
	else
		DAM_SQL_INSERT_INTO(
			"DAM_SERVER",
			{
				["hostname"] = GetHostName()
			}
		)
	end
end

local tab = DAM_SQL_SELECT("DAM_SERVER")
if tab and tab[1] then
	tab = tab[1]
	SetGlobalBool("dam_hostname_toggle", tobool(tab.hostname_toggle))
	SetGlobalString("dam_hostname", tab.hostname)
	SetGlobalBool("dam_password_toggle", tobool(tab.password_toggle))
	SetGlobalBool("dam_loadingurl_toggle", tobool(tab.loadingurl_toggle))
	curpassword = tab.password
	curloadingurl = tab.loadingurl
end

-- HOSTNAME
hook.Add(
	"Think",
	"DAM_HOSTNAME_CHANGER",
	function()
		if GetGlobalBool("dam_hostname_toggle", false) and (oldhostname ~= GetGlobalString("dam_hostname", "") or player.GetCount() ~= oldplycount) then
			oldhostname = GetGlobalString("dam_hostname", "")
			oldplycount = player.GetCount()
			local hname = GetGlobalString("dam_hostname", "")
			hname = DAMConvertHostname(hname)
			if not isEmpty(hname) then
				DAM_MSG("New Hostname: " .. hname, Color(0, 255, 0))
				RunConsoleCommand("hostname", hname)
			else
				DAM_MSG("Hostname is empty, change it!", Color(255, 0, 0))
				RunConsoleCommand("hostname", "Garry's Mod")
			end
		end
	end
)

util.AddNetworkString("dam_hostname_toggle")
net.Receive(
	"dam_hostname_toggle",
	function(len, ply)
		if not DAMPlyHasPermission(ply, "dam_server") then return end
		local hb = net.ReadBool()
		if hb ~= nil then
			local text = "ON"
			local val = 1
			if not hb then
				text = "OFF"
				val = 0
			end

			DAM_SQL_UPDATE(
				"DAM_SERVER",
				{
					["hostname_toggle"] = val
				}, "uid = '1'"
			)

			DAM_MSG("Hostname Changer: " .. text)
			SetGlobalBool("dam_hostname_toggle", hb)
		end
	end
)

util.AddNetworkString("dam_update_hostname")
net.Receive(
	"dam_update_hostname",
	function(len, ply)
		if not DAMPlyHasPermission(ply, "dam_server") then return end
		local hname = net.ReadString()
		hname = string.Replace(hname, "'", "´")
		if hname then
			DAM_SQL_UPDATE(
				"DAM_SERVER",
				{
					["hostname"] = hname
				}, "uid = '1'"
			)

			DAM_MSG("Hostname changed to: " .. hname)
			SetGlobalString("dam_hostname", hname)
		end
	end
)

-- PASSWORD
local wason = false
hook.Add(
	"Think",
	"DAM_PASSWORD_CHANGER",
	function()
		if GetGlobalBool("dam_password_toggle", false) then
			if oldpassword ~= curpassword then
				oldpassword = curpassword
				wason = true
				RunConsoleCommand("sv_password", curpassword)
			end
		elseif wason then
			wason = false
			RunConsoleCommand("sv_password", "")
		end
	end
)

util.AddNetworkString("dam_password_toggle")
net.Receive(
	"dam_password_toggle",
	function(len, ply)
		if not DAMPlyHasPermission(ply, "dam_server") then return end
		local hb = net.ReadBool()
		if hb ~= nil then
			local text = "ON"
			local val = 1
			if not hb then
				text = "OFF"
				val = 0
			end

			DAM_SQL_UPDATE(
				"DAM_SERVER",
				{
					["password_toggle"] = val
				}, "uid = '1'"
			)

			DAM_MSG("Password Changer: " .. text)
			SetGlobalBool("dam_password_toggle", hb)
		end
	end
)

util.AddNetworkString("dam_update_password")
net.Receive(
	"dam_update_password",
	function(len, ply)
		if not DAMPlyHasPermission(ply, "dam_server") then return end
		local pw = net.ReadString()
		pw = string.Replace(pw, "'", "´")
		if pw then
			DAM_SQL_UPDATE(
				"DAM_SERVER",
				{
					["password"] = pw
				}, "uid = '1'"
			)

			DAM_MSG("password changed to: " .. pw)
			curpassword = pw
		end
	end
)

util.AddNetworkString("dam_getpassword")
net.Receive(
	"dam_getpassword",
	function(len, ply)
		if not DAMPlyHasPermission(ply, "dam_server") then return end
		net.Start("dam_getpassword")
		net.WriteString(curpassword)
		net.Send(ply)
	end
)

hook.Add(
	"Think",
	"DAM_LOADINGURL_CHANGER",
	function()
		if GetGlobalBool("dam_loadingurl_toggle", false) and oldloadingurl ~= curloadingurl then
			oldloadingurl = curloadingurl
			RunConsoleCommand("sv_loadingurl", curloadingurl)
		end
	end
)

util.AddNetworkString("dam_loadingurl_toggle")
net.Receive(
	"dam_loadingurl_toggle",
	function(len, ply)
		if not DAMPlyHasPermission(ply, "dam_server") then return end
		local hb = net.ReadBool()
		if hb ~= nil then
			local text = "ON"
			local val = 1
			if not hb then
				text = "OFF"
				val = 0
			end

			DAM_SQL_UPDATE(
				"DAM_SERVER",
				{
					["loadingurl_toggle"] = val
				}, "uid = '1'"
			)

			DAM_MSG("LoadingURL Changer: " .. text)
			SetGlobalBool("dam_loadingurl_toggle", hb)
		end
	end
)

util.AddNetworkString("dam_update_loadingurl")
net.Receive(
	"dam_update_loadingurl",
	function(len, ply)
		if not DAMPlyHasPermission(ply, "dam_server") then return end
		local lu = net.ReadString()
		lu = string.Replace(lu, "'", "´")
		if lu then
			DAM_SQL_UPDATE(
				"DAM_SERVER",
				{
					["loadingurl"] = lu
				}, "uid = '1'"
			)

			DAM_MSG("loadingurl changed to: " .. lu)
			curloadingurl = lu
		end
	end
)

util.AddNetworkString("dam_getloadingurl")
net.Receive(
	"dam_getloadingurl",
	function(len, ply)
		if not DAMPlyHasPermission(ply, "dam_server") then return end
		net.Start("dam_getloadingurl")
		net.WriteString(curloadingurl)
		net.Send(ply)
	end
)

util.AddNetworkString("dam_import_ulx")
net.Receive(
	"dam_import_ulx",
	function(len, ply)
		if not DAMPlyHasPermission(ply, "dam_server") then return end
		if file.Exists("ulib/groups.txt", "DATA") then
			local ulx = file.Read("ulib/groups.txt", "DATA")
			ulx = string.Explode("\n", ulx)
			local ranks = {}
			for i, v in pairs(ulx) do
				if v ~= "" and not string.StartWith(v, "\t") and not string.StartWith(v, "{") and not string.StartWith(v, "}") then
					v = string.Replace(v, "\"", "")
					v = string.Replace(v, "\t", "")
					table.insert(ranks, v)
				end
			end

			local foundnew = false
			for i, rank in pairs(ranks) do
				rank = string.lower(rank)
				local ug = DAM_SQL_SELECT("DAM_UGS", nil, "name = '" .. rank .. "'")
				if ug == nil then
					local res = DAM_SQL_INSERT_INTO(
						"DAM_UGS",
						{
							["name"] = rank
						}
					)

					if res == nil then
						DAM_MSG("Added usergroup " .. tostring(rank) .. "!")
						foundnew = true
					end
				end
			end

			if not foundnew then
				DAM_MSG("Already all ULX Ranks imported.")
			end

			net.Start("dam_import_ulx")
			net.Send(ply)
		else
			DAM_MSG("No ULX database found.", Color(255, 255, 0, 255))
		end
	end
)

util.AddNetworkString("dam_import_sam")
net.Receive(
	"dam_import_sam",
	function(len, ply)
		if not DAMPlyHasPermission(ply, "dam_server") then return end
		local sam = DAM_SQL_SELECT("sam_ranks", nil, nil)
		if sam ~= nil and sam ~= false then
			local ranks = {}
			for i, v in pairs(sam) do
				table.insert(ranks, string.lower(v.name))
			end

			local foundnew = false
			for i, rank in pairs(ranks) do
				rank = string.lower(rank)
				local ug = DAM_SQL_SELECT("DAM_UGS", nil, "name = '" .. rank .. "'")
				if ug == nil then
					local res = DAM_SQL_INSERT_INTO(
						"DAM_UGS",
						{
							["name"] = rank
						}
					)

					if res == nil then
						DAM_MSG("Added usergroup " .. tostring(rank) .. "!")
						foundnew = true
					end
				end
			end

			if not foundnew then
				DAM_MSG("Already all SAM Ranks imported.")
			end

			net.Start("dam_import_sam")
			net.Send(ply)
		else
			DAM_MSG("No SAM database found.", Color(255, 255, 0, 255))
		end
	end
)

local delay = 0
hook.Add(
	"Think",
	"DAM_UPTIME",
	function()
		if delay > SysTime() then return end
		delay = SysTime() + 1
		SetGlobalString("DAM_SERVER_UPTIME", SysTime())
		SetGlobalString("DAM_SERVER_TICKRATE", 1 / FrameTime())
	end
)