-- SV DAM Console
util.AddNetworkString("dam_rcon_str")
net.Receive(
	"dam_rcon_str",
	function(len, ply)
		if not DAMPlyHasPermission(ply, "dam_console") then return end
		local str = net.ReadString()
		local tab = string.Explode(" ", str)
		if tab[1] == "sv_cheats" then
			DAM_MSG("Command is blocked by GMOD", Color(255, 0, 0), ply)
		else
			DAM_MSG("RCON [" .. str .. "]")
			RunConsoleCommand(tab[1], tab[2], tab[3])
		end
	end
)