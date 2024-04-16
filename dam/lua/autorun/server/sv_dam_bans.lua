function DAMGetBanDuration(steamid)
	local tab = DAM_SQL_SELECT("DAM_PLYS", nil, "steamid = '" .. steamid .. "'")
	if tab and tab[1] then
		tab = tab[1]

		return tab.banned_ts - SysTime()
	end

	return 0
end

function DAMGetBanReason(steamid)
	local tab = DAM_SQL_SELECT("DAM_PLYS", nil, "steamid = '" .. steamid .. "'")
	if tab and tab[1] then
		tab = tab[1]

		return tab.banned_reason
	end

	return "NO REASON FOUND"
end

function DAMCheckBan(tab)
	tab.banned_ts = tonumber(tab.banned_ts)
	if tab.banned_ts > 0 and tab.banned_ts < SysTime() then
		DAMUnbanPlayer(tab.steamid)
		DAM_MSG("Unbanned " .. tab.steamid .. " (expired)")
	end
end

function DAMCheckBanBySteamID(steamid)
	local tab = DAM_SQL_SELECT("DAM_PLYS", nil, "steamid = '" .. steamid .. "'")
	if tab and tab[1] then
		tab = tab[1]
		DAMCheckBan(tab)
	end
end

function DAMCheckBans()
	local tab = DAM_SQL_SELECT("DAM_PLYS", nil, "banned = '1'")
	if tab ~= nil and tab ~= false then
		for i, plytab in pairs(tab) do
			DAMCheckBan(plytab)
		end
	end
end

function DAMGetPermaBans()
	local tab = DAM_SQL_SELECT("DAM_PLYS", nil, "banned = '1'")
	if tab ~= nil and tab ~= false then
		return tab
	else
		return {}
	end
end

function DAMIsPlayerBanned(steamid)
	local bans = DAMGetPermaBans()
	for i, v in pairs(bans) do
		if steamid == v.steamid then return true end
	end

	return false
end

function DAMUnbanPlayer(steamid)
	if steamid then
		local tab = DAM_SQL_SELECT("DAM_PLYS", nil, "steamid = '" .. steamid .. "'")
		if tab ~= nil and tab ~= false then
			tab = tab[1]
			tab.banned = tonumber(tab.banned)
			if tab.banned == 1 then
				DAM_SQL_UPDATE(
					"DAM_PLYS",
					{
						["banned"] = 0,
						["banned_ts"] = -1,
						["banned_reason"] = "",
						["banned_from"] = "",
					}, "steamid = '" .. steamid .. "'"
				)

				return true
			else
				DAM_MSG("[UnbanPlayer] Player is not banned!: " .. steamid)

				return false
			end
		else
			DAM_MSG("[UnbanPlayer] Player not found in database!: " .. steamid)

			return false
		end
	else
		DAM_ERR("[UnbanPlayer] steamid is missing")

		return false
	end
end

util.AddNetworkString("dam_get_bans")
net.Receive(
	"dam_get_bans",
	function(len, ply)
		if not DAMPlyHasPermission(ply, "dam_bans") then return end
		DAMCheckBans()
		local bans = DAMGetPermaBans()
		net.Start("dam_get_bans")
		net.WriteTable(bans)
		net.Send(ply)
	end
)