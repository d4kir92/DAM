-- SV DAM MAPS
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
		if mapname then
			if gm and gm ~= engine.ActiveGamemode() then
				DAM_MSG("Change Gamemode to " .. gm .. " by " .. ply:DAMName())
				RunConsoleCommand("gamemode", gm)
			end

			DAM_MSG("Changelevel to " .. mapname .. " by " .. ply:DAMName())
			RunConsoleCommand("changelevel", mapname)
		else
			DAM_MSG("dam_changelevel failed", Color(255, 0, 0))
		end
	end
)