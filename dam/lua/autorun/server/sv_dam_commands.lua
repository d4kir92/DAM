DAM_SQL_CREATE_TABLE("DAM_CMDS")
DAM_SQL_ADD_COLUMN("DAM_CMDS", "name", "TEXT DEFAULT ''")
DAM_SQL_ADD_COLUMN("DAM_CMDS", "content", "TEXT DEFAULT ''")
util.AddNetworkString("dam_cmds_clear")
util.AddNetworkString("dam_cmds_getall")
local damcmds = {}
local blacklist = {}
local TAB_CMDS = {}
local function DAM_CMDS_UPDATE_TABLE()
	local tab = DAM_SQL_SELECT("DAM_CMDS")
	if tab then
		for i, v in pairs(tab) do
			TAB_CMDS[v.name] = v.content
		end
	end
end

DAM_CMDS_UPDATE_TABLE()
local function DAM_CMDS_SEND_ALL(ply)
	local tab = DAM_SQL_SELECT("DAM_CMDS")
	if tab == nil or tab == false then
		tab = {}
	end

	net.Start("dam_cmds_clear")
	net.Send(ply)
	for i, v in pairs(tab) do
		net.Start("dam_cmds_getall")
		net.WriteString(v.name)
		net.WriteString(v.content)
		net.Send(ply)
	end
end

net.Receive(
	"dam_cmds_getall",
	function(len, ply)
		if not DAMPlyHasPermission(ply, "dam_commands") then return end
		DAM_CMDS_SEND_ALL(ply)
	end
)

util.AddNetworkString("dam_cmds_add")
net.Receive(
	"dam_cmds_add",
	function(len, ply)
		if not DAMPlyHasPermission(ply, "dam_commands") then return end
		local name = net.ReadString()
		local content = net.ReadString()
		if name then
			name = string.lower(name)
			if blacklist[name] then
				DAM_MSG("BLACKLISTED COMMAND NAME")
				DAM_CMDS_SEND_ALL(ply)

				return
			end

			if content then
				local tab = DAM_SQL_SELECT("DAM_CMDS", nil, "name = '" .. name .. "'")
				if tab then
					DAM_MSG("Command with name already exists!")
				else
					local added = DAM_SQL_INSERT_INTO(
						"DAM_CMDS",
						{
							["name"] = name,
							["content"] = content,
						}
					)

					if added ~= nil then
						DAM_MSG("Added command: " .. name)
						DAM_CMDS_UPDATE_TABLE()
					else
						DAM_MSG("Failed to add command! name: " .. tostring(name))
					end
				end
			else
				DAM_MSG("Wrong Content for Adding Command")
			end
		else
			DAM_MSG("Wrong NAME for Adding Command")
		end

		DAM_CMDS_SEND_ALL(ply)
	end
)

util.AddNetworkString("dam_cmds_rem")
net.Receive(
	"dam_cmds_rem",
	function(len, ply)
		if not DAMPlyHasPermission(ply, "dam_commands") then return end
		local name = net.ReadString()
		DAM_SQL_DELETE_FROM("DAM_CMDS", "name = '" .. name .. "'")
		DAM_CMDS_UPDATE_TABLE()
		DAM_CMDS_SEND_ALL(ply)
	end
)

util.AddNetworkString("dam_model_open")
net.Receive(
	"dam_model_open",
	function(len, ply)
		if not DAMPlyHasPermission(ply, "dam_commands") then return end
		local target = net.ReadEntity()
		local pm = net.ReadString()
		if IsValid(target) then
			target:SetModel(pm)
			DAM_MSG(string.format("[MODEL] Set Model to %s for %s", pm, target:DAMName()), Color(255, 0, 0), ply)
		end
	end
)

local function DAMFindPlayerByName(name)
	local strname = string.lower(name)
	for i, ply in pairs(player.GetAll()) do
		if string.find(string.lower(ply:Nick()), strname, 1, true) then
			return ply
		elseif ply.SteamName and string.find(string.lower(ply:SteamName()), strname, 1, true) then
			return ply
		end
	end

	return NULL
end

function DAMTeleportTo(ply, target)
	local dir = Angle(0, 0, 0)
	for ran = 1, 3 do
		for ang = 0, 360, 45 do
			local pos = target:GetPos() + Vector(0, 0, 2)
			dir:RotateAroundAxis(target:GetUp(), 45)
			local newpos = pos + dir:Forward() * 44 * ran
			local tr = util.TraceHull(
				{
					start = newpos,
					endpos = newpos,
					filter = ply,
					mins = Vector(-18, -18, 0),
					maxs = Vector(18, 18, 75)
				}
			)

			if not tr.Hit then
				ply:SetPos(tr.HitPos)

				return true
			end
		end
	end

	return false
end

local function DAMTryTP(ply, args)
	if not DAMPlyHasPermission(ply, "perm_tp") then return end
	if args[2] then
		local pl = DAMFindPlayerByName(args[2])
		if IsValid(pl) then
			if pl ~= ply then
				DAMTeleportTo(ply, pl)
				DAM_MSG(string.format("[TP] Teleported to %s", pl:DAMName()), Color(255, 0, 0), ply)
			else
				DAM_MSG("[TP] You cant tp to yourself", Color(255, 0, 0), ply)
			end
		else
			DAM_MSG("[TP] Target Not Found", Color(255, 0, 0), ply)

			return
		end
	else
		DAM_MSG("[TP] Missing Target Name", Color(255, 0, 0), ply)
	end
end

local function DAMTryBring(ply, args)
	if not DAMPlyHasPermission(ply, "perm_bring") then return end
	if args[2] then
		local pl = DAMFindPlayerByName(args[2])
		if IsValid(pl) then
			if pl ~= ply then
				DAMTeleportTo(pl, ply)
				DAM_MSG(string.format("[BRING] Brought %s to %s", pl:DAMName(), ply:DAMName()), Color(255, 0, 0), ply)
			else
				DAM_MSG("[BRING] You cant bring yourself", Color(255, 0, 0), ply)
			end
		else
			DAM_MSG("[BRING] Target Not Found", Color(255, 0, 0), ply)

			return
		end
	else
		DAM_MSG("[BRING] Missing Target Name", Color(255, 0, 0), ply)
	end
end

local function DAMTryGod(ply, args)
	if not DAMPlyHasPermission(ply, "perm_god") then return end
	local pl = NULL
	if args[2] then
		pl = DAMFindPlayerByName(args[2])
		if not IsValid(pl) then
			DAM_MSG("[GOD] Target Not Found #1", Color(255, 0, 0), ply)

			return
		end
	else
		pl = ply
	end

	if IsValid(pl) then
		if pl:HasGodMode() then
			pl:GodDisable()
			if ply == pl then
				DAM_MSG("[GOD] Disabled", Color(0, 255, 0), pl)
			else
				DAM_MSG("[GOD] Disabled for " .. pl:DAMName(), Color(0, 255, 0), pl)
			end
		else
			pl:GodEnable()
			if ply == pl then
				DAM_MSG("[GOD] Enabled", Color(0, 255, 0), pl)
			else
				DAM_MSG("[GOD] Enabled for " .. pl:DAMName(), Color(0, 255, 0), pl)
			end
		end
	else
		DAM_MSG("[GOD] Target Not Found #2", Color(255, 0, 0), ply)

		return
	end
end

local function DAMTryRespawn(ply, args)
	if not DAMPlyHasPermission(ply, "perm_respawn") then return end
	local pl = NULL
	if args[2] then
		pl = DAMFindPlayerByName(args[2])
		if not IsValid(pl) then
			DAM_MSG("[RESPAWN] Target Not Found #1", Color(255, 0, 0), ply)

			return
		end
	else
		pl = ply
	end

	if IsValid(pl) then
		if pl:Alive() then
			DAM_MSG("[RESPAWN] Target is Alive", Color(255, 0, 0), ply)
		else
			DAM_MSG("[RESPAWN] Respawned " .. pl:DAMName(), Color(255, 0, 0), ply)
			pl:Spawn()
		end
	else
		DAM_MSG("[RESPAWN] Target Not Found #2", Color(255, 0, 0), ply)

		return
	end
end

local function DAMTryHP(ply, args)
	if not DAMPlyHasPermission(ply, "perm_hp") then return end
	local hp = 0
	if args[2] then
		args[2] = tonumber(args[2])
		if type(args[2]) == "number" then
			hp = args[2]
		else
			DAM_MSG("[HP] Wrong ARGUMENTS!", Color(255, 0, 0), ply)

			return
		end
	else
		DAM_MSG("[HP] Missing Amount", Color(255, 0, 0), ply)

		return
	end

	local pl = NULL
	if args[3] then
		pl = DAMFindPlayerByName(args[3])
		if not IsValid(pl) then
			DAM_MSG("[HP] Target Not Found #1", Color(255, 0, 0), ply)

			return
		end
	else
		pl = ply
	end

	if IsValid(pl) then
		if pl:GetMaxHealth() < hp then
			pl:SetMaxHealth(hp)
			pl:SetHealth(hp)
		else
			pl:SetHealth(hp)
		end

		DAM_MSG(string.format("[HP] Set HP to %s for %s", hp, pl:DAMName()), Color(255, 0, 0), ply)
	else
		DAM_MSG("[HP] Target Not Found #2", Color(255, 0, 0), ply)

		return
	end
end

local function DAMTryArmor(ply, args)
	if not DAMPlyHasPermission(ply, "perm_armor") then return end
	local armor = 0
	if args[2] then
		args[2] = tonumber(args[2])
		if type(args[2]) == "number" then
			armor = args[2]
		else
			DAM_MSG("[ARMOR] Wrong ARGUMENTS!", Color(255, 0, 0), ply)

			return
		end
	else
		DAM_MSG("[ARMOR] Missing Amount", Color(255, 0, 0), ply)

		return
	end

	local pl = NULL
	if args[3] then
		pl = DAMFindPlayerByName(args[3])
		if not IsValid(pl) then
			DAM_MSG("[ARMOR] Target Not Found #1", Color(255, 0, 0), ply)

			return
		end
	else
		pl = ply
	end

	if IsValid(pl) then
		if pl:GetMaxArmor() < armor then
			pl:SetDAMInt("MaxArmor", armor)
			pl:SetArmor(armor)
		else
			pl:SetArmor(armor)
		end

		DAM_MSG(string.format("[ARMOR] Set Armor to %s for %s", armor, pl:DAMName()), Color(255, 0, 0), ply)
	else
		DAM_MSG("[ARMOR] Target Not Found #2", Color(255, 0, 0), ply)

		return
	end
end

local function DAMTryModel(ply, args)
	if not DAMPlyHasPermission(ply, "perm_model") then return end
	local pl = ply
	if args[2] then
		pl = DAMFindPlayerByName(args[2])
	end

	if IsValid(pl) then
		net.Start("dam_model_open")
		net.WriteEntity(pl)
		net.Send(ply)
	else
		DAM_MSG("[MODEL] Target Not Found", Color(255, 0, 0), ply)
	end
end

local function DAMTryCleanup(ply, args)
	if not DAMPlyHasPermission(ply, "perm_cleanup") then return end
	game.CleanUpMap()
	DAM_MSG("[CLEANUP] Cleaned Whole Map", Color(255, 255, 0), ply)
end

local function DAMTryCSAY(ply, args)
	if not DAMPlyHasPermission(ply, "perm_csay") then return end
	if args[2] then
		args[1] = ""
		ply:PrintMessage(HUD_PRINTCENTER, table.concat(args, " "))
	else
		DAM_MSG("[CSAY] Missing Text", Color(255, 0, 0), ply)
	end
end

local function DAMTryESP(ply, args)
	ply:SetDAMBool("dam_esp_hide", not ply:GetDAMBool("dam_esp_hide", false))
end

local function DAMTryCustomCommand(ply, args)
	local name = string.Replace(args[1], "!", "")
	name = string.Replace(name, "/", "")
	name = string.lower(name)
	if TAB_CMDS[name] then
		if IsValid(ply) and name then
			DAM_MSG("Player: " .. ply:DAMName() .. " used command: " .. name)
		end

		PrintMessage(HUD_PRINTTALK, TAB_CMDS[name])
	end
end

util.AddNetworkString("dam_vote_start")
util.AddNetworkString("dam_vote_select")
util.AddNetworkString("dam_vote_add")
util.AddNetworkString("dam_vote_ended")
net.Receive(
	"dam_vote_select",
	function(len, ply)
		local ans = net.ReadInt(6)
		ply:SetDAMInt("dam_vote_answer", ans)
	end
)

function DAMSyncTime()
	SetGlobalInt("dam_ts", SysTime())
	timer.Simple(0.5, DAMSyncTime)
end

DAMSyncTime()
net.Receive(
	"dam_vote_add",
	function(len, ply)
		local question = net.ReadString()
		local duration = net.ReadString()
		local answers = net.ReadTable()
		if isEmpty(question) then
			DAM_MSG("Question is Empty", Color(255, 0, 0), ply)

			return
		end

		local ans = {}
		for i, v in pairs(answers) do
			if not isEmpty(v) then
				table.insert(ans, v)
			end
		end

		SetGlobalInt("dam_vote_ts_start", SysTime())
		SetGlobalInt("dam_vote_ts_end", SysTime() + tonumber(duration))
		timer.Simple(
			duration,
			function()
				local res = {}
				for i, pl in pairs(player.GetAll()) do
					res[pl:GetDAMInt("dam_vote_answer", -1)] = res[pl:GetDAMInt("dam_vote_answer", -1)] or 0
					res[pl:GetDAMInt("dam_vote_answer", -1)] = res[pl:GetDAMInt("dam_vote_answer", -1)] + 1
				end

				local resid = 1
				for i, v in pairs(res) do
					res[resid] = res[resid] or 0
					if v > res[resid] then
						resid = i
					end
				end

				local result = answers[resid] or "NO ONE VOTED"
				net.Start("dam_vote_ended")
				net.WriteString(question)
				net.WriteString(result)
				net.Broadcast()
			end
		)

		for i, pl in pairs(player.GetAll()) do
			pl:SetDAMInt("dam_vote_answer", -1)
		end

		timer.Simple(
			0.5,
			function()
				net.Start("dam_vote_start")
				net.WriteString(question)
				net.WriteTable(ans)
				net.Broadcast()
			end
		)
	end
)

local function DAMTryVote(ply, args)
	if not DAMPlyHasPermission(ply, "perm_vote") then return end
	net.Start("dam_vote_add")
	net.Send(ply)
end

local function DAMTrySlay(ply, args)
	if not DAMPlyHasPermission(ply, "perm_slay") then return end
	local pl = NULL
	if args[2] then
		pl = DAMFindPlayerByName(args[2])
		if not IsValid(pl) then
			DAM_MSG("[SLAY] Target Not Found #1", Color(255, 0, 0), ply)

			return
		end
	else
		pl = ply
	end

	if IsValid(pl) then
		pl:Kill()
	else
		DAM_MSG("[SLAY] Target Not Found #2", Color(255, 0, 0), ply)

		return
	end
end

local function DAMTrySlap(ply, args)
	if not DAMPlyHasPermission(ply, "perm_slap") then return end
	local pl = NULL
	if args[2] then
		pl = DAMFindPlayerByName(args[2])
		if not IsValid(pl) then
			DAM_MSG("[SLAP] Target Not Found #1", Color(255, 0, 0), ply)

			return
		end
	else
		pl = ply
	end

	if IsValid(pl) then
		pl:SetVelocity(Vector(0, 0, 1) * 600)
	else
		DAM_MSG("[SLAP] Target Not Found #2", Color(255, 0, 0), ply)

		return
	end
end

local function DAMTryBurn(ply, args)
	if not DAMPlyHasPermission(ply, "perm_burn") then return end
	local pl = NULL
	if args[2] then
		pl = DAMFindPlayerByName(args[2])
		if not IsValid(pl) then
			DAM_MSG("[BURN] Target Not Found #1", Color(255, 0, 0), ply)

			return
		end
	else
		pl = ply
	end

	if IsValid(pl) then
		pl:Ignite(3, 0)
	else
		DAM_MSG("[BURN] Target Not Found #2", Color(255, 0, 0), ply)

		return
	end
end

local function DAMTryScale(ply, args)
	if not DAMPlyHasPermission(ply, "perm_scale") then return end
	local pl = NULL
	local scale = 1
	if args[2] then
		scale = args[2]
	end

	if args[3] then
		pl = DAMFindPlayerByName(args[3])
		if not IsValid(pl) then
			DAM_MSG("[SCALE] Target Not Found #1", Color(255, 0, 0), ply)

			return
		end
	else
		pl = ply
	end

	if IsValid(pl) then
		pl:SetModelScale(scale)
	else
		DAM_MSG("[SCALE] Target Not Found #2", Color(255, 0, 0), ply)

		return
	end
end

local function DAMTryCloak(ply, args)
	if not DAMPlyHasPermission(ply, "perm_cloak") then return end
	local pl = NULL
	if args[2] then
		pl = DAMFindPlayerByName(args[2])
		if not IsValid(pl) then
			DAM_MSG("[CLOAK] Target Not Found #1", Color(255, 0, 0), ply)

			return
		end
	else
		pl = ply
	end

	if IsValid(pl) then
		DAMToggleCloak(pl)
	else
		DAM_MSG("[CLOAK] Target Not Found #2", Color(255, 0, 0), ply)

		return
	end
end

local function DAMTryNoclip(ply, args)
	if not DAMPlyHasPermission(ply, "perm_noclip") then return end
	local pl = NULL
	if args[2] then
		pl = DAMFindPlayerByName(args[2])
		if not IsValid(pl) then
			DAM_MSG("[NOCLIP] Target Not Found #1", Color(255, 0, 0), ply)

			return
		end
	else
		pl = ply
	end

	if IsValid(pl) then
		DAMToggleNoclip(pl)
	else
		DAM_MSG("[NOCLIP] Target Not Found #2", Color(255, 0, 0), ply)

		return
	end
end

local function DAMTrySpectate(ply, args)
	if not DAMPlyHasPermission(ply, "perm_spectate") then return end
	local pl = NULL
	if args[2] then
		pl = DAMFindPlayerByName(args[2])
		if not IsValid(pl) then
			DAM_MSG("[SPECTATE] Target Not Found #1", Color(255, 0, 0), ply)

			return
		end
	end

	if IsValid(pl) then
		DAMToggleSpectate(ply, pl)
	else
		DAM_MSG("[SPECTATE] Target Not Found #2", Color(255, 0, 0), ply)

		return
	end
end

local function DAMAddCommand(tab)
	if tab then
		if tab.name == nil then
			DAM_MSG("Failed to add Command, missing name", Color(255, 0, 0))

			return false
		end

		if tab.func == nil then
			DAM_MSG("Failed to add Command missing function", Color(255, 0, 0))

			return false
		end

		if tab.syntax == nil then
			DAM_MSG("Failed to add Command missing syntax", Color(255, 0, 0))

			return false
		end

		if tab.help == nil then
			DAM_MSG("Failed to add Command missing help", Color(255, 0, 0))

			return false
		end

		local entry = {}
		entry.name = tab.name
		entry.func = tab.func
		entry.syntax = tab.syntax
		entry.help = tab.help
		damcmds["!" .. tab.name] = entry
		damcmds["/" .. tab.name] = entry
		blacklist[tab.name] = true
		--DAM_MSG( "Added Command: " .. tab.name .. " (" .. tab.syntax .. ") (" .. tab.help .. ")", Color( 0, 255, 0 ) )

		return true
	end

	return false
end

DAMAddCommand(
	{
		["name"] = "tp",
		["func"] = DAMTryTP,
		["syntax"] = "tp NAME",
		["help"] = "Teleport YOU to NAME",
	}
)

DAMAddCommand(
	{
		["name"] = "bring",
		["func"] = DAMTryBring,
		["syntax"] = "bring NAME",
		["help"] = "Brings NAME to YOU",
	}
)

DAMAddCommand(
	{
		["name"] = "god",
		["func"] = DAMTryGod,
		["syntax"] = "god [NAME]",
		["help"] = "Toggle GODMODE for YOU/NAME",
	}
)

DAMAddCommand(
	{
		["name"] = "respawn",
		["func"] = DAMTryRespawn,
		["syntax"] = "respawn [NAME]",
		["help"] = "Respawns YOU/NAME",
	}
)

DAMAddCommand(
	{
		["name"] = "hp",
		["func"] = DAMTryHP,
		["syntax"] = "hp AMOUNT [NAME]",
		["help"] = "Set hp for YOU/NAME",
	}
)

DAMAddCommand(
	{
		["name"] = "armor",
		["func"] = DAMTryArmor,
		["syntax"] = "armor AMOUNT [NAME]",
		["help"] = "Set armor for YOU/NAME",
	}
)

DAMAddCommand(
	{
		["name"] = "model",
		["func"] = DAMTryModel,
		["syntax"] = "model [NAME]",
		["help"] = "Set model for NAME",
	}
)

DAMAddCommand(
	{
		["name"] = "cleanup",
		["func"] = DAMTryCleanup,
		["syntax"] = "cleanup",
		["help"] = "Cleanup the map",
	}
)

DAMAddCommand(
	{
		["name"] = "csay",
		["func"] = DAMTryCSAY,
		["syntax"] = "csay TEXT",
		["help"] = "shows message on all players on the hud",
	}
)

DAMAddCommand(
	{
		["name"] = "esp",
		["func"] = DAMTryESP,
		["syntax"] = "esp",
		["help"] = "Toggles ESP",
	}
)

DAMAddCommand(
	{
		["name"] = "vote",
		["func"] = DAMTryVote,
		["syntax"] = "vote",
		["help"] = "Starts a Vote",
	}
)

DAMAddCommand(
	{
		["name"] = "slay",
		["func"] = DAMTrySlay,
		["syntax"] = "slay [NAME]",
		["help"] = "Slays Target/You",
	}
)

DAMAddCommand(
	{
		["name"] = "slap",
		["func"] = DAMTrySlap,
		["syntax"] = "slap [NAME]",
		["help"] = "Slaps Target/You",
	}
)

DAMAddCommand(
	{
		["name"] = "burn",
		["func"] = DAMTryBurn,
		["syntax"] = "burn [NAME]",
		["help"] = "Burns Target/You",
	}
)

DAMAddCommand(
	{
		["name"] = "scale",
		["func"] = DAMTryScale,
		["syntax"] = "scale [SCALE] [NAME]",
		["help"] = "Scales Target/You",
	}
)

DAMAddCommand(
	{
		["name"] = "cloak",
		["func"] = DAMTryCloak,
		["syntax"] = "cloak [NAME]",
		["help"] = "Cloaks Target/You",
	}
)

DAMAddCommand(
	{
		["name"] = "noclip",
		["func"] = DAMTryNoclip,
		["syntax"] = "noclip [NAME]",
		["help"] = "Noclips Target/You",
	}
)

DAMAddCommand(
	{
		["name"] = "spectate",
		["func"] = DAMTrySpectate,
		["syntax"] = "spectate NAME",
		["help"] = "Spectates Target",
	}
)

util.AddNetworkString("dam_chat_help")
local function DAMChatHelp(ply)
	local cmds = {}
	for name, tab in pairs(damcmds) do
		cmds[tab.name] = {
			["syntax"] = tab.syntax,
			["help"] = tab.help,
			["name"] = tab.name,
		}
	end

	net.Start("dam_chat_help")
	net.WriteTable(cmds)
	net.Send(ply)
end

util.AddNetworkString("dam_togglemenu")
hook.Remove("PlayerSay", "DAM_PlayerSay")
hook.Add(
	"PlayerSay",
	"DAM_PlayerSay",
	function(ply, text, teamChat, isDead)
		local args = string.Explode(" ", text)
		if args[1] then
			local cmd = string.lower(args[1])
			if args[2] == nil and (cmd == "!dam" or cmd == "/dam") then
				net.Start("dam_togglemenu")
				net.Send(ply)
			elseif damcmds[cmd] then
				damcmds[cmd].func(ply, args)
			elseif args[2] then
				if args[2] == "help" then
					DAMChatHelp(ply)
				else
					DAMTryCustomCommand(ply, args)
				end
			else
				DAMTryCustomCommand(ply, args)
			end
		end
	end
)