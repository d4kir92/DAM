-- SV DAM Player
local function DAMNumberToBool(num)
	num = tonumber(num)
	if num == 1 then
		return true
	elseif num == 0 then
		return false
	end

	return false
end

local function DAMUpdatePermissions(ply)
	local groupName = ply:DAMGetUserGroup()
	local dbtab = DAM_SQL_SELECT("DAM_UGS", nil, "name = '" .. groupName .. "'")
	if dbtab and dbtab[1] then
		dbtab = dbtab[1]
		for i, v in pairs(dbtab) do
			ply:SetDAMBool(i, DAMNumberToBool(v))
		end

		if CAMI then
			for i, v in pairs(CAMI.GetPrivileges()) do
				if dbtab[v.Name] then
					ply:SetDAMBool(v.Name, DAMNumberToBool(dbtab[v.Name]))
				end
			end
		end
	end
end

function DAMUpdatePermissionsAll()
	for i, v in pairs(player.GetAll()) do
		DAMUpdatePermissions(v)
	end
end

local Player = FindMetaTable("Player")
if Player.DAMSetUserGroup == nil then
	function Player:DAMSetUserGroup(groupName)
		DAM_HR()
		if groupName == nil then
			DAM_MSG("[SetUserGroup] INVALID PARAMETERS", Color(255, 0, 0))
		end

		-- if it has debug info
		if debug.getinfo(2) and debug.getinfo(2).short_src then
			-- if not from DAM
			if debug.getinfo(2).short_src ~= "addons/dam/lua/autorun/server/sv_dam_player.lua" then
				DAM_MSG("[SetUserGroup] From: [" .. tostring(debug.getinfo(2).short_src) .. "]")
			end
		else
			DAM_MSG("[SetUserGroup] From: Unknown Source", Color(255, 0, 0))
			if debug.getinfo(2) then
				PrintTable(debug.getinfo(2))
			end
		end

		self:SetDAMString("DAMUserGroup", groupName)
		self:SetDAMString("UserGroup", groupName)
		DAM_MSG("[SetUserGroup] Set the Usergroup for [" .. self:DAMName() .. "] to [" .. groupName .. "]")
		DAMUpdatePermissions(self)
		DAM_HR()
	end
end

hook.Add(
	"PlayerSpawn",
	"DAMPlayerSpawn",
	function(ply)
		DAMUpdatePermissions(ply)
	end
)

local damgetug = Player.DAMSetUserGroup
local function DAMCheckSetUserGroup()
	if damgetug ~= Player.DAMSetUserGroup then
		DAM_ERR("DAMSetUserGroup was overwritten, by another addon!", Color(255, 0, 0))
	end

	timer.Simple(1, DAMCheckSetUserGroup)
end

DAMCheckSetUserGroup()
-- DB
--sql.Query("DROP TABLE DAM_UGS;")
DAM_SQL_CREATE_TABLE("DAM_PLYS")
DAM_SQL_ADD_COLUMN("DAM_PLYS", "steamid", "TEXT DEFAULT ''")
DAM_SQL_ADD_COLUMN("DAM_PLYS", "ug", "TEXT DEFAULT 'user'")
DAM_SQL_ADD_COLUMN("DAM_PLYS", "warns", "INT DEFAULT 0")
DAM_SQL_ADD_COLUMN("DAM_PLYS", "banned", "INT DEFAULT 0")
DAM_SQL_ADD_COLUMN("DAM_PLYS", "banned_ts", "TEXT DEFAULT '-1'")
DAM_SQL_ADD_COLUMN("DAM_PLYS", "banned_reason", "TEXT DEFAULT '-'")
DAM_SQL_ADD_COLUMN("DAM_PLYS", "banned_from", "TEXT DEFAULT '-'")
hook.Add(
	"PlayerAuthed",
	"DAM_PlayerAuthed",
	function(ply, steamid, uniqueid)
		DAMCheckPlayer(ply, steamid)
		local tab = DAM_SQL_SELECT("DAM_PLYS", nil, "steamid = '" .. steamid .. "'")
		if tab and tab[1] then
			tab = tab[1]
			ply:SetUserGroup(tab.ug)
			ply:DAMSetUserGroup(tab.ug)
		end
	end
)

hook.Remove("PlayerSpawn", "DAM_PlayerSpawn")
hook.Add(
	"PlayerSpawn",
	"DAM_PlayerSpawn",
	function(ply)
		local steamid = ply:SteamID()
		if ply:GetUserGroup() == "NOTSET" then
			DAMCheckPlayer(ply, steamid)
			local tab = DAM_SQL_SELECT("DAM_PLYS", nil, "steamid = '" .. steamid .. "'")
			if tab and tab[1] then
				tab = tab[1]
				ply:SetUserGroup(tab.ug)
				ply:DAMSetUserGroup(tab.ug)
			end
		end
	end
)

local function DAMSendPLYS(ply, showOffline)
	if showOffline == nil then
		showOffline = false
	end

	local tab = DAM_SQL_SELECT("DAM_PLYS")
	if not tab then
		tab = {}
	end

	local nettab = {}
	if not showOffline then
		for i, v in pairs(tab) do
			local fPly = DAMFindPlayerBySteamID(v.steamid)
			if IsValid(fPly) then
				table.insert(nettab, v)
			end
		end
	else
		nettab = tab
	end

	for i, v in pairs(nettab) do
		timer.Simple(
			0.001 * i,
			function()
				net.Start("dam_getplys")
				net.WriteTable(v)
				net.Send(ply)
			end
		)
	end
end

util.AddNetworkString("dam_getplys")
net.Receive(
	"dam_getplys",
	function(len, ply)
		if not DAMPlyHasPermission(ply, "dam_players") then return end
		local showOffline = net.ReadBool()
		DAMSendPLYS(ply, showOffline)
	end
)

util.AddNetworkString("dam_ply_update_ug")
net.Receive(
	"dam_ply_update_ug",
	function(len, ply)
		if not DAMPlyHasPermission(ply, "dam_players") then return end
		local steamid = net.ReadString()
		local ug = net.ReadString()
		local showOffline = net.ReadBool()
		ug = string.lower(ug)
		if DAMPlyHasPermission(ply, "perm_usergroup") then
			if ug ~= "" then
				DAM_SQL_UPDATE(
					"DAM_PLYS",
					{
						["ug"] = ug
					}, "steamid = '" .. steamid .. "'"
				)

				local target = DAMFindPlayerBySteamID(steamid)
				if IsValid(target) then
					target:SetUserGroup(ug)
					target:DAMSetUserGroup(ug)
				end
			end

			DAMSendPLYS(ply, showOffline)
		end
	end
)

local function ConHelp()
	DAM_HR()
	local structure = "%-28s %s"
	DAM_MSG(string.format(structure, "dam help", "shows help info"))
	DAM_MSG(string.format(structure, "dam adduser NAME USERGROUP", "give the user with the usergroup"))
	DAM_MSG(string.format(structure, "dam addply NAME USERGROUP", "give the user with the usergroup"))
	DAM_MSG(string.format(structure, "dam maps", "Shows all maps on the server"))
	DAM_MSG(string.format(structure, "dam map ID", "Switch to the map that has the ID"))
	DAM_MSG(string.format(structure, "dam status", "Shows info"))
	DAM_MSG(string.format(structure, "dam unban \"Steamid\"", "Unbans a player with the steamid"))
	DAM_MSG(string.format(structure, "dam version", "Shows Version of DAM"))
	DAM_HR()
end

concommand.Add(
	"dam",
	function(ply, cmd, args, options)
		-- SERVER CONSOLE
		if not IsValid(ply) or (IsValid(ply) and ply:IPAddress() == "loopback") then
			if args[1] then
				if args[1] == "adduser" or args[1] == "addply" then
					if args[2] and args[3] then
						if args[4] then
							DAM_MSG("To much arguments: ", Color(255, 0, 0))
							DAM_MSG("dam adduser \"NAME\" \"USERGROUP\"", Color(255, 255, 0))

							return false
						end

						if args[3] == "" then
							DAM_MSG("USERGROUP IS WRONG", Color(255, 0, 0))

							return false
						end

						local hassteamname = false
						local name = string.lower(args[2])
						local ug = args[3]
						ug = string.lower(ug)
						for i, pl in pairs(player.GetAll()) do
							if string.find(string.lower(pl:Nick()), name, 1, true) then
								DAM_SQL_UPDATE(
									"DAM_PLYS",
									{
										["ug"] = ug
									}, "steamid = '" .. pl:SteamID() .. "'"
								)

								pl:SetUserGroup(ug)
								pl:DAMSetUserGroup(ug)

								return true
							elseif pl.SteamName and string.find(string.lower(pl:SteamName()), name, 1, true) then
								DAM_SQL_UPDATE(
									"DAM_PLYS",
									{
										["ug"] = ug
									}, "steamid = '" .. pl:SteamID() .. "'"
								)

								pl:SetUserGroup(ug)
								pl:DAMSetUserGroup(ug)

								return true
							end

							if pl.SteamName then
								hassteamname = true
							end
						end

						DAM_MSG(">> PLAYER NOT FOUND", Color(255, 0, 0))
						DAM_MSG("PLAYERS ON THE SERVER:", Color(255, 255, 0))
						local plFormat = "%4s: %30s"
						if hassteamname then
							plFormat = "%4s: %30s %30s"
							DAM_MSG(string.format(plFormat, "NR", "Nick", "SteamName"))
						else
							DAM_MSG(string.format(plFormat, "NR", "Nick"))
						end

						for i, pl in pairs(player.GetAll()) do
							if pl.SteamName then
								DAM_MSG(string.format(plFormat, i, pl:Nick(), pl:SteamName()))
							else
								DAM_MSG(string.format(plFormat, i, pl:Nick()))
							end
						end

						DAM_MSG(">> PLAYER NOT FOUND", Color(255, 0, 0))

						return false
					else
						DAM_MSG("dam adduser \"NAME\" \"USERGROUP\"", Color(255, 255, 0))
					end
				elseif args[1] == "maps" then
					DAM_HR()
					DAM_MSG("MAPS")
					local maps = file.Find("maps/*.bsp", "GAME")
					DAM_MSG(string.format("%-4s: %s", "ID", "MAPNAME"))
					DAM_MSG("-------------------------------------------------------------------------")
					for i, v in pairs(maps) do
						DAM_MSG(string.format("%-4s: %s", i, string.Replace(v, ".bsp", "")))
					end

					DAM_HR()
				elseif args[1] == "map" then
					local maps = file.Find("maps/*.bsp", "GAME")
					if args[2] and tonumber(args[2]) <= #maps then
						args[2] = tonumber(args[2])
						local map = string.Replace(maps[args[2]], ".bsp", "")
						DAM_MSG("changelevel to " .. map)
						RunConsoleCommand("changelevel", map)
					else
						DAM_MSG("MAP-ID NOT FOUND: " .. args[2], Color(255, 0, 0))
					end
				elseif args[1] == "status" then
					DAM_HR()
					local structure = "%-10s %s"
					local plcount = 0
					local bocount = 0
					local cototal = player.GetCount()
					for i, v in pairs(player.GetAll()) do
						if v:IsBot() then
							bocount = bocount + 1
						else
							plcount = plcount + 1
						end
					end

					DAM_MSG("--- [STATUS] ---")
					local col = Color(255, 0, 0)
					if DAMVERSION == DAMVERSIONONLINE then
						col = Color(0, 255, 0)
					end

					DAM_MSG(string.format(structure, "Version", DAMVERSION), col)
					DAM_MSG("")
					DAM_MSG(string.format(structure, "Hostname", GetHostName()))
					DAM_MSG(string.format(structure, "IP", game.GetIPAddress()))
					DAM_MSG(string.format(structure, "Map", game.GetMap()))
					DAM_MSG("")
					DAM_MSG(string.format(structure, DAMGT("players"), plcount .. "/" .. game.MaxPlayers()), Color(100, 100, 255))
					DAM_MSG(string.format(structure, DAMGT("bots"), bocount .. "/" .. game.MaxPlayers()), Color(255, 255, 0))
					DAM_MSG(string.format(structure, "Total", cototal .. "/" .. game.MaxPlayers()), Color(0, 255, 0))
					DAM_HR()
				elseif args[1] == "unban" then
					if args[2] then
						local unbanned = DAMUnbanPlayer(args[2])
						if unbanned then
							DAM_MSG(args[2] .. " was unbanned!")
						end
					else
						DAM_MSG("[UNBAN] Missing parameters", Color(255, 0, 0))
					end
				elseif args[1] == "ban" then
					if args[2] then
						local pl = DAMFindPlayerBySteamID(args[2])
						if IsValid(pl) then
							local duration = args[3] or 0
							local reason = args[4] or "NO REASON"
							local from = "console"
							if IsValid(ply) then
								from = ply:SteamID()
							end

							pl:Ban(duration, true, reason, from)
						else
							DAM_MSG("[BAN] Player not found: " .. args[2], Color(255, 0, 0))
						end
					else
						DAM_MSG("[BAN] Missing parameters", Color(255, 0, 0))
					end
				elseif args[1] == "version" then
					DAM_MSG("[DAM] Version: " .. DAMVERSION)
				else
					ConHelp()
				end
			else
				ConHelp()
			end
		end
	end, function() end, "HELP"
)

local function DAMGetUGS(ply)
	local tab = DAM_SQL_SELECT("DAM_UGS")
	if tab == nil or tab == false then
		tab = {}
	end

	net.Start("dam_setug_getugs")
	net.WriteTable(tab)
	net.Send(ply)
end

util.AddNetworkString("dam_setug_getugs")
net.Receive(
	"dam_setug_getugs",
	function(len, ply)
		if not DAMPlyHasPermission(ply, "dam_players") then return end
		DAMGetUGS(ply)
	end
)

util.AddNetworkString("dam_ply_kick")
net.Receive(
	"dam_ply_kick",
	function(len, ply)
		if not DAMPlyHasPermission(ply, "dam_players") then return end
		local steamid = net.ReadString()
		local kreason = net.ReadString()
		if DAMPlyHasPermission(ply, "perm_kick") then
			local pl = DAMFindPlayerBySteamID(steamid)
			if IsValid(pl) then
				pl:Kick(kreason)
				DAM_MSG("Player kicked: " .. pl:DAMName(), Color(0, 255, 0))
			else
				DAM_MSG("Player not found!", Color(255, 0, 0))
			end
		end
	end
)

Player.OldBan = Player.OldBan or Player.Ban
function Player:Ban(duration, kick, reason, from)
	local i_duration = duration or 0
	local s_reason = reason or ""
	local s_from = from or "console"
	if i_duration ~= 0 then
		i_duration = SysTime() + i_duration * 60
	end

	DAMCheckPlayer(self, self:SteamID())
	DAM_SQL_UPDATE(
		"DAM_PLYS",
		{
			["banned"] = 1,
			["banned_ts"] = i_duration,
			["banned_reason"] = s_reason,
			["banned_from"] = s_from,
		}, "steamid = '" .. self:SteamID() .. "'"
	)

	DAM_MSG("[BANNED] [Player: " .. self:DAMName() .. "] [Duration: " .. i_duration .. "] [From: " .. s_from .. "]", Color(0, 255, 0))
	if kick then
		self:Kick(s_reason)
	end
end

util.AddNetworkString("dam_ply_ban")
net.Receive(
	"dam_ply_ban",
	function(len, ply)
		if not DAMPlyHasPermission(ply, "dam_players") then return end
		local steamid = net.ReadString()
		local breason = net.ReadString()
		local duration = tonumber(net.ReadString())
		if DAMPlyHasPermission(ply, "perm_ban") then
			local pl = DAMFindPlayerBySteamID(steamid)
			if IsValid(pl) then
				pl:Ban(duration, true, breason, ply:SteamID())
			else
				DAM_MSG("Player not found!", Color(255, 0, 0))
			end
		end
	end
)

util.AddNetworkString("dam_ply_unban")
net.Receive(
	"dam_ply_unban",
	function(len, ply)
		if not DAMPlyHasPermission(ply, "dam_players") then return end
		local steamid = net.ReadString()
		local unbanned = DAMUnbanPlayer(steamid)
		if unbanned then
			DAM_MSG(steamid .. " was unbanned!")
		end
	end
)