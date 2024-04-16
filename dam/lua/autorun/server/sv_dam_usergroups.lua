-- SV DAM Usergroups
local function botono(bo)
	if bo then return 1 end

	return 0
end

--sql.Query("DROP TABLE DAM_UGS;")
DAM_SQL_CREATE_TABLE("DAM_UGS")
local function DAMAddPerm(key)
	DAM_SQL_ADD_COLUMN("DAM_UGS", key, "INT DEFAULT 0")
	util.AddNetworkString("dam_ug_update_" .. key)
	net.Receive(
		"dam_ug_update_" .. key,
		function(len, ply)
			if not DAMPlyHasPermission(ply, "dam_usergroups") then return end
			local uid = net.ReadString()
			local bo = botono(net.ReadBool())
			DAM_SQL_UPDATE(
				"DAM_UGS",
				{
					[key] = bo
				}, "uid = '" .. uid .. "'"
			)
		end
	)
end

DAM_SQL_ADD_COLUMN("DAM_UGS", "name", "TEXT DEFAULT 'unnamed'")
DAM_SQL_ADD_COLUMN("DAM_UGS", "position", "INT DEFAULT 1")
DAMAddPerm("dam_dashboard")
DAMAddPerm("dam_maps")
DAMAddPerm("dam_players")
DAMAddPerm("dam_usergroups")
DAMAddPerm("dam_permaprops")
DAMAddPerm("dam_bans")
DAMAddPerm("dam_commands")
DAMAddPerm("dam_server")
DAMAddPerm("dam_console")
-- powers
DAMAddPerm("hassuperadminpowers")
DAMAddPerm("hasadminpowers")
-- password
DAMAddPerm("perm_skippw")
-- chat
DAMAddPerm("perm_csay")
-- teleport
DAMAddPerm("perm_tp")
DAMAddPerm("perm_bring")
-- hax
DAMAddPerm("perm_noclip")
DAMAddPerm("perm_god")
-- player
DAMAddPerm("perm_respawn")
DAMAddPerm("perm_hp")
DAMAddPerm("perm_armor")
DAMAddPerm("perm_model")
DAMAddPerm("perm_scale")
DAMAddPerm("perm_cloak")
DAMAddPerm("perm_spectate")
-- punishment
DAMAddPerm("perm_slay")
DAMAddPerm("perm_slap")
DAMAddPerm("perm_burn")
DAMAddPerm("perm_kick")
DAMAddPerm("perm_ban")
DAMAddPerm("perm_usergroup")
-- map
DAMAddPerm("perm_cleanup")
DAMAddPerm("perm_permaprops")
-- votes
DAMAddPerm("perm_vote")
DAMAddPerm("perm_votemap")
local function DAMUpdateCAMIPrivs()
	if CAMI then
		for i, v in pairs(CAMI.GetPrivileges()) do
			DAM_SQL_ADD_COLUMN("DAM_UGS", "'" .. v.Name .. "'", "INT DEFAULT 0")
			util.AddNetworkString("dam_ug_update_perm_" .. v.Name)
			net.Receive(
				"dam_ug_update_perm_" .. v.Name,
				function(len, ply)
					if not DAMPlyHasPermission(ply, "dam_usergroups") then return end
					local uid = net.ReadString()
					local bo = botono(net.ReadBool())
					DAM_SQL_UPDATE(
						"DAM_UGS",
						{
							[v.Name] = bo
						}, "uid = '" .. uid .. "'"
					)
				end
			)
		end
	end
end

timer.Simple(1, DAMUpdateCAMIPrivs)
local function DAMUpdateMainUGS()
	if DAM_SQL_SELECT("DAM_UGS", nil, "uid = '1'") == nil then
		DAM_SQL_INSERT_INTO(
			"DAM_UGS",
			{
				["name"] = "superadmin",
				["dam_dashboard"] = 1,
			}
		)
	else
		DAM_SQL_UPDATE(
			"DAM_UGS",
			{
				["name"] = "superadmin",
			}, "uid = '1'"
		)
	end

	if DAM_SQL_SELECT("DAM_UGS", nil, "uid = '2'") == nil then
		DAM_SQL_INSERT_INTO(
			"DAM_UGS",
			{
				["name"] = "user",
				["dam_dashboard"] = 1,
			}
		)
	else
		DAM_SQL_UPDATE(
			"DAM_UGS",
			{
				["name"] = "user",
			}, "uid = '2'"
		)
	end

	local columns = DAM_SQL_SELECT("DAM_UGS", nil, "uid = '1'")
	if columns and columns[1] then
		columns = columns[1]
		for i, v in pairs(columns) do
			if i ~= "uid" and i ~= "name" then
				DAM_SQL_UPDATE(
					"DAM_UGS",
					{
						[i] = 1,
					}, "uid = '1'"
				)
			end
		end
	end
end

timer.Simple(1.1, DAMUpdateMainUGS)
local DAMUGS = {}
local function DAMUpdateUserGroupTable()
	-- remove old entries
	for i, usergroup in pairs(DAMUGS) do
		if CAMI then
			CAMI.UnregisterUsergroup(usergroup.Name, "DAM")
		end
	end

	-- add current entries
	local tab = DAM_SQL_SELECT("DAM_UGS")
	DAMUGS = {}
	if tab then
		for i, usergroup in pairs(tab) do
			local entry = {}
			entry.Name = usergroup.name
			entry.Inherits = "superadmin"
			if CAMI then
				CAMI.RegisterUsergroup(entry, "DAM")
			end

			table.insert(DAMUGS, entry)
		end
	end
end

timer.Simple(1, DAMUpdateUserGroupTable)
local function DAMUpdateUGNames()
	local tab = DAM_SQL_SELECT("DAM_UGS")
	if tab then
		for i, v in pairs(tab) do
			DAM_SQL_UPDATE(
				"DAM_UGS",
				{
					["name"] = string.lower(v.name)
				}, "uid = '" .. v.uid .. "'"
			)
		end
	end
end

DAMUpdateUGNames()
local function DAMUpdatePosition()
	local tab = DAM_SQL_SELECT("DAM_UGS")
	if tab == nil or tab == false then
		tab = {}
	end

	local pos = 1
	for i, v in pairs(tab) do
		DAM_SQL_UPDATE(
			"DAM_UGS",
			{
				["position"] = pos
			}, "uid = '" .. v.uid .. "'"
		)

		pos = pos + 1
	end
end

DAMUpdatePosition()
util.AddNetworkString("dam_get_sites_data")
util.AddNetworkString("dam_get_sites_done")
net.Receive(
	"dam_get_sites_data",
	function(len, ply)
		DAM_MSG("[GetTabs] " .. ply:DAMName() .. " ask for tabs.")
		local tab = DAM_SQL_SELECT("DAM_UGS", nil, "name = '" .. string.lower(ply:DAMGetUserGroup()) .. "'")
		if tab and tab[1] then
			tab = tab[1]
			DAM_MSG("[GetTabs] send tabs to " .. ply:DAMName() .. "")
			for i, v in pairs(tab) do
				net.Start("dam_get_sites_data")
				if i ~= "name" and i ~= "uid" then
					net.WriteString(i)
					net.WriteBool(tobool(v))
				end

				net.Send(ply)
			end

			net.Start("dam_get_sites_done")
			net.WriteString(tab.name)
			net.Send(ply)
		else
			DAM_MSG("[GetTabs] UserGroup not in database: " .. tostring(ply:DAMGetUserGroup()), ply)
		end
	end
)

util.AddNetworkString("dam_open_site")
net.Receive(
	"dam_open_site",
	function(len, ply)
		local site = net.ReadString()
		if site == "dam_dashboard" or site == "dam_settings" then
			net.Start("dam_open_site")
			net.WriteString(site)
			net.Send(ply)

			return
		end

		local tab = DAM_SQL_SELECT("DAM_UGS", nil, "name = '" .. string.lower(ply:DAMGetUserGroup()) .. "'")
		if tab and tab[1] then
			tab = tab[1]
			if tab[site] then
				net.Start("dam_open_site")
				net.WriteString(site)
				net.Send(ply)

				return
			else
				DAM_MSG("[OpenSite] not allowed to open site: " .. site)
			end
		else
			DAM_MSG("[OpenSite] UserGroup not in database: " .. tostring(ply:DAMGetUserGroup()), ply)
		end
	end
)

local function DAMGetUGS(ply)
	local tab = DAM_SQL_SELECT("DAM_UGS")
	if tab == nil or tab == false then
		tab = {}
	end

	net.Start("dam_getugs")
	net.WriteTable(tab)
	net.Send(ply)
end

util.AddNetworkString("dam_getugs")
net.Receive(
	"dam_getugs",
	function(len, ply)
		if not DAMPlyHasPermission(ply, "dam_usergroups") then return end
		DAMGetUGS(ply)
	end
)

util.AddNetworkString("dam_getug")
net.Receive(
	"dam_getug",
	function(len, ply)
		if not DAMPlyHasPermission(ply, "dam_usergroups") then return end
		local uid = net.ReadString()
		local tab = DAM_SQL_SELECT("DAM_UGS", nil, "uid = '" .. uid .. "'")
		if tab == nil or tab == false then
			tab = {}
		end

		if tab[1] then
			tab = tab[1]
		end

		net.Start("dam_getug")
		net.WriteTable(tab)
		net.Send(ply)
	end
)

util.AddNetworkString("dam_addug")
net.Receive(
	"dam_addug",
	function(len, ply)
		if not DAMPlyHasPermission(ply, "dam_usergroups") then return end
		DAM_SQL_INSERT_INTO(
			"DAM_UGS",
			{
				["name"] = "unnamed"
			}
		)

		DAM_MSG("Added New UserGroup")
		DAMUpdateUserGroupTable()
		DAMUpdatePosition()
		DAMGetUGS(ply)
	end
)

util.AddNetworkString("dam_remug")
net.Receive(
	"dam_remug",
	function(len, ply)
		if not DAMPlyHasPermission(ply, "dam_usergroups") then return end
		local uid = tonumber(net.ReadString())
		if uid ~= 1 and uid ~= 2 then
			DAM_SQL_DELETE_FROM("DAM_UGS", "uid = '" .. uid .. "'")
			DAM_MSG("Removed UserGroup", Color(255, 0, 0))
			DAMUpdateUserGroupTable()
			DAMUpdatePosition()
			DAMGetUGS(ply)
		end
	end
)

util.AddNetworkString("dam_ug_update_name")
net.Receive(
	"dam_ug_update_name",
	function(len, ply)
		if not DAMPlyHasPermission(ply, "dam_usergroups") then return end
		local uid = net.ReadString()
		local name = net.ReadString()
		name = string.lower(name)
		DAM_SQL_UPDATE(
			"DAM_UGS",
			{
				["name"] = name
			}, "uid = '" .. uid .. "'"
		)

		timer.Simple(0.1, DAMUpdateUserGroupTable)
	end
)

util.AddNetworkString("dam_ug_update_dashboard")
net.Receive(
	"dam_ug_update_dashboard",
	function(len, ply)
		if not DAMPlyHasPermission(ply, "dam_usergroups") then return end
		local uid = net.ReadString()
		local bo = botono(net.ReadBool())
		DAM_SQL_UPDATE(
			"DAM_UGS",
			{
				["dam_dashboard"] = bo
			}, "uid = '" .. uid .. "'"
		)

		DAMUpdatePermissionsAll()
	end
)

util.AddNetworkString("dam_ug_update_maps")
net.Receive(
	"dam_ug_update_maps",
	function(len, ply)
		if not DAMPlyHasPermission(ply, "dam_usergroups") then return end
		local uid = net.ReadString()
		local bo = botono(net.ReadBool())
		DAM_SQL_UPDATE(
			"DAM_UGS",
			{
				["dam_maps"] = bo
			}, "uid = '" .. uid .. "'"
		)

		DAMUpdatePermissionsAll()
	end
)

util.AddNetworkString("dam_ug_update_players")
net.Receive(
	"dam_ug_update_players",
	function(len, ply)
		if not DAMPlyHasPermission(ply, "dam_usergroups") then return end
		local uid = net.ReadString()
		local bo = botono(net.ReadBool())
		DAM_SQL_UPDATE(
			"DAM_UGS",
			{
				["dam_players"] = bo
			}, "uid = '" .. uid .. "'"
		)

		DAMUpdatePermissionsAll()
	end
)

util.AddNetworkString("dam_ug_update_usergroups")
net.Receive(
	"dam_ug_update_usergroups",
	function(len, ply)
		if not DAMPlyHasPermission(ply, "dam_usergroups") then return end
		local uid = net.ReadString()
		local bo = botono(net.ReadBool())
		DAM_SQL_UPDATE(
			"DAM_UGS",
			{
				["dam_usergroups"] = bo
			}, "uid = '" .. uid .. "'"
		)

		DAMUpdatePermissionsAll()
	end
)

util.AddNetworkString("dam_ug_update_permaprops")
net.Receive(
	"dam_ug_update_permaprops",
	function(len, ply)
		if not DAMPlyHasPermission(ply, "dam_usergroups") then return end
		local uid = net.ReadString()
		local bo = botono(net.ReadBool())
		DAM_SQL_UPDATE(
			"DAM_UGS",
			{
				["dam_permaprops"] = bo
			}, "uid = '" .. uid .. "'"
		)

		DAMUpdatePermissionsAll()
	end
)

util.AddNetworkString("dam_ug_update_bans")
net.Receive(
	"dam_ug_update_bans",
	function(len, ply)
		if not DAMPlyHasPermission(ply, "dam_usergroups") then return end
		local uid = net.ReadString()
		local bo = botono(net.ReadBool())
		DAM_SQL_UPDATE(
			"DAM_UGS",
			{
				["dam_bans"] = bo
			}, "uid = '" .. uid .. "'"
		)

		DAMUpdatePermissionsAll()
	end
)

util.AddNetworkString("dam_ug_update_commands")
net.Receive(
	"dam_ug_update_commands",
	function(len, ply)
		if not DAMPlyHasPermission(ply, "dam_usergroups") then return end
		local uid = net.ReadString()
		local bo = botono(net.ReadBool())
		DAM_SQL_UPDATE(
			"DAM_UGS",
			{
				["dam_commands"] = bo
			}, "uid = '" .. uid .. "'"
		)

		DAMUpdatePermissionsAll()
	end
)

util.AddNetworkString("dam_ug_update_server")
net.Receive(
	"dam_ug_update_server",
	function(len, ply)
		if not DAMPlyHasPermission(ply, "dam_usergroups") then return end
		local uid = net.ReadString()
		local bo = botono(net.ReadBool())
		DAM_SQL_UPDATE(
			"DAM_UGS",
			{
				["dam_server"] = bo
			}, "uid = '" .. uid .. "'"
		)

		DAMUpdatePermissionsAll()
	end
)

util.AddNetworkString("dam_ug_update_console")
net.Receive(
	"dam_ug_update_console",
	function(len, ply)
		if not DAMPlyHasPermission(ply, "dam_usergroups") then return end
		local uid = net.ReadString()
		local bo = botono(net.ReadBool())
		DAM_SQL_UPDATE(
			"DAM_UGS",
			{
				["dam_console"] = bo
			}, "uid = '" .. uid .. "'"
		)

		DAMUpdatePermissionsAll()
	end
)

function DAMCheckPlayer(ply, steamid)
	DAMCheckBanBySteamID(steamid)
	local banned = DAMIsPlayerBanned(steamid)
	if banned and IsValid(ply) then
		DAM_MSG("Player is banned: " .. ply:SteamName())
		if DAMGetBanDuration(steamid) > 0 then
			local dur = string.FormattedTime(DAMGetBanDuration(steamid))
			ply:Kick("[BANNED] " .. DAMGetBanReason(steamid) .. " [" .. string.format("%.2d:%.2d:%.2d", dur.h, dur.m, dur.s) .. "]")

			return false
		else
			ply:Kick("[BANNED] " .. DAMGetBanReason(steamid) .. " [" .. "PERMANENT" .. "]")

			return false
		end
	elseif banned then
		DAM_MSG("Player is banned: " .. steamid)

		return false
	end

	if DAM_SQL_SELECT("DAM_PLYS", nil, "steamid = '" .. steamid .. "'") == nil then
		DAM_MSG("Found New Player, adding to Database")
		DAM_SQL_INSERT_INTO(
			"DAM_PLYS",
			{
				["steamid"] = steamid
			}
		)
	end

	return true
end

hook.Add(
	"CheckPassword",
	"DAM_CHECKPASSWORD",
	function(steamID64, ipAddress, svPassword, clPassword, name)
		local steamid = util.SteamIDFrom64(steamID64)
		if steamid == nil or steamID64 == nil then
			DAM_MSG("Player with no SteamID", Color(255, 0, 0))

			return false, "BROKEN GAME"
		end

		local ok = DAMCheckPlayer(nil, steamid)
		if not ok then
			if DAMGetBanDuration(steamid) > 0 then
				local dur = string.FormattedTime(DAMGetBanDuration(steamid))

				return false, "[BANNED] " .. DAMGetBanReason(steamid) .. " [" .. string.format("%.2d:%.2d:%.2d", dur.h, dur.m, dur.s) .. "]"
			else
				return false, "[BANNED] " .. DAMGetBanReason(steamid) .. " [" .. "PERMANENT" .. "]"
			end
		end

		local tab = DAM_SQL_SELECT("DAM_PLYS", nil, "steamid = '" .. steamid .. "'")
		if tab and tab[1] then
			tab = tab[1]
			local ug = DAM_SQL_SELECT("DAM_UGS", nil, "name = '" .. tab.ug .. "'")
			if ug and ug[1] then
				ug = ug[1]
				if tobool(ug.perm_skippw) then
					DAM_MSG("[" .. steamid .. "] can skip Password (" .. ug.name .. ": Skip Password = ON)", Color(0, 255, 0))

					return true
				end
			end
		else
			DAM_MSG("Player not in Database", Color(255, 0, 0))

			return false, "NOT IN DATABASE"
		end
	end
)

util.AddNetworkString("dam_ug_update_hassuperadminpowers")
net.Receive(
	"dam_ug_update_hassuperadminpowers",
	function(len, ply)
		if not DAMPlyHasPermission(ply, "dam_usergroups") then return end
		local uid = net.ReadString()
		local bo = botono(net.ReadBool())
		DAM_SQL_UPDATE(
			"DAM_UGS",
			{
				["hassuperadminpowers"] = bo
			}, "uid = '" .. uid .. "'"
		)
	end
)

util.AddNetworkString("dam_ug_update_hasadminpowers")
net.Receive(
	"dam_ug_update_hasadminpowers",
	function(len, ply)
		if not DAMPlyHasPermission(ply, "dam_usergroups") then return end
		local uid = net.ReadString()
		local bo = botono(net.ReadBool())
		DAM_SQL_UPDATE(
			"DAM_UGS",
			{
				["hasadminpowers"] = bo
			}, "uid = '" .. uid .. "'"
		)
	end
)