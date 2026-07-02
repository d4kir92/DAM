-- SV DAM MAPS
local function DAMFindCaseInsensitive(list, value)
	if not list or not value then return nil end
	local lowerValue = string.lower(value)
	for i, entry in ipairs(list) do
		if string.lower(entry) == lowerValue then return entry end
	end

	return nil
end

util.AddNetworkString("dam_getgms")
net.Receive(
	"dam_getgms",
	function(len, ply)
		if not DAMPlyHasPermission(ply, "dam_maps") then return end
		local _, gms = file.Find("gamemodes/*", "GAME")
		if gms then
			net.Start("dam_getgms")
			net.WriteTable(gms)
			net.Send(ply)
		else
			DAM_MSG("Get Gamemodes failed", Color(255, 0, 0))
		end
	end
)

util.AddNetworkString("dam_getmaps")
net.Receive(
	"dam_getmaps",
	function(len, ply)
		if not DAMPlyHasPermission(ply, "dam_maps") then return end
		local maps = file.Find("maps/*.bsp", "GAME")
		if maps then
			net.Start("dam_getmaps")
			net.WriteTable(maps)
			net.Send(ply)
		else
			DAM_MSG("Get Maps failed", Color(255, 0, 0))
		end
	end
)

util.AddNetworkString("dam_changelevel")
net.Receive(
	"dam_changelevel",
	function(len, ply)
		if not DAMPlyHasPermission(ply, "dam_maps") then return end
		local gm = net.ReadString()
		local mapname = net.ReadString()
		local matchedMap = mapname and DAMFindCaseInsensitive(file.Find("maps/*.bsp", "GAME"), mapname .. ".bsp")
		if matchedMap then
			local realMapName = string.Replace(matchedMap, ".bsp", "")
			if gm and gm ~= "" and string.lower(gm) ~= string.lower(engine.ActiveGamemode()) then
				local _, gms = file.Find("gamemodes/*", "GAME")
				local matchedGm = DAMFindCaseInsensitive(gms, gm)
				if matchedGm then
					DAM_MSG("Change Gamemode to " .. matchedGm .. " by " .. ply:DAMName())
					RunConsoleCommand("gamemode", matchedGm)
				else
					DAM_MSG("dam_changelevel failed, invalid gamemode: " .. gm, Color(255, 0, 0))

					return
				end
			end

			DAM_MSG("Changelevel to " .. realMapName .. " by " .. ply:DAMName())
			RunConsoleCommand("changelevel", realMapName)
		else
			DAM_MSG("dam_changelevel failed, invalid map: " .. tostring(mapname), Color(255, 0, 0))
		end
	end
)