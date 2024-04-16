-- DAM SV Main
-- SHARED --
AddCSLuaFile("autorun/sh_dam_network.lua")
include("autorun/sh_dam_network.lua")
AddCSLuaFile("autorun/sh_dam_translations.lua")
include("autorun/sh_dam_translations.lua")
AddCSLuaFile("autorun/sh_dam_main.lua")
include("autorun/sh_dam_main.lua")
AddCSLuaFile("autorun/sh_dam_player.lua")
include("autorun/sh_dam_player.lua")
-- CLIENT --
AddCSLuaFile("autorun/client/denhancedavatarimage.lua")
AddCSLuaFile("autorun/client/cl_dam_main.lua")
-- modules
AddCSLuaFile("autorun/client/modules/cl_dam_dashboard.lua")
AddCSLuaFile("autorun/client/modules/cl_dam_maps.lua")
AddCSLuaFile("autorun/client/modules/cl_dam_players.lua")
AddCSLuaFile("autorun/client/modules/cl_dam_usergroups.lua")
AddCSLuaFile("autorun/client/modules/cl_dam_permaprops.lua")
AddCSLuaFile("autorun/client/modules/cl_dam_commands.lua")
AddCSLuaFile("autorun/client/modules/cl_dam_bans.lua")
AddCSLuaFile("autorun/client/modules/cl_dam_server.lua")
AddCSLuaFile("autorun/client/modules/cl_dam_console.lua")
AddCSLuaFile("autorun/client/modules/cl_dam_settings.lua")
-- RESOURCES
local mats = {"materials/dam/dam_blue.png", "materials/dam/dam_logo.png", "materials/dam/dam_white.png", "materials/dam/dc_color.png", "materials/dam/dc_white.png", "materials/dam/dam_menu.png", "materials/dam/cb_checked.png", "materials/dam/cb_unchecked.png", "materials/dam/dam_chart.png", "materials/dam/dam_dashboard.png", "materials/dam/dam_maps.png", "materials/dam/dam_player.png", "materials/dam/dam_settings.png", "materials/dam/dam_server.png", "materials/dam/dam_commands.png", "materials/dam/dam_terminal.png", "materials/dam/dam_ugs.png", "materials/dam/dam_ugadd.png", "materials/dam/dam_ugrem.png", "materials/dam/dam_bans.png", "materials/dam/dam_permaprops.png", "materials/dam/en.png", "materials/dam/de.png", "materials/dam/ru.png",}
for i, v in pairs(mats) do
	resource.AddSingleFile(v)
end

function DAMPlyHasPermission(ply, perm)
	local tab = DAM_SQL_SELECT("DAM_UGS", {perm}, "name = '" .. ply:DAMGetUserGroup() .. "'")
	if tab and tab[1] then
		tab = tab[1]
		if tab[perm] then
			if tonumber(tab[perm]) == 1 then
				return true
			elseif tonumber(tab[perm]) == 0 then
				DAM_MSG(string.format("NOT ALLOWED TO DO THIS: %s", perm), Color(255, 0, 0), ply)
			else
				DAM_MSG(string.format("ERROR in Permission: %s", perm), Color(255, 0, 0), ply)
			end
		end
	elseif tab == false then
		DAM_MSG("Permission not found: " .. tostring(perm), Color(255, 0, 0), ply)
	else
		DAM_MSG("Usergroup not found", Color(255, 0, 0), ply)
	end

	return false
end

-- STATS
DAM_SQL_CREATE_TABLE("DAM_PLYGRAPH")
DAM_SQL_ADD_COLUMN("DAM_PLYGRAPH", "plcount", "INT DEFAULT 0")
DAM_SQL_ADD_COLUMN("DAM_PLYGRAPH", "bocount", "INT DEFAULT 0")
DAM_SQL_ADD_COLUMN("DAM_PLYGRAPH", "sec", "INT DEFAULT 0")
DAM_SQL_ADD_COLUMN("DAM_PLYGRAPH", "min", "INT DEFAULT 0")
DAM_SQL_ADD_COLUMN("DAM_PLYGRAPH", "hou", "INT DEFAULT 0")
DAM_SQL_ADD_COLUMN("DAM_PLYGRAPH", "day", "INT DEFAULT 0")
DAM_SQL_ADD_COLUMN("DAM_PLYGRAPH", "mon", "INT DEFAULT 0")
DAM_SQL_ADD_COLUMN("DAM_PLYGRAPH", "yea", "INT DEFAULT 0")
DAM_SQL_ADD_COLUMN("DAM_PLYGRAPH", "ts", "INT DEFAULT 0")
if DAMTrackPlayers == nil then
	function DAMTrackPlayers()
		if os.date("%M") % 1 == 0 and os.date("%S") % 60 == 0 then
			local bocount = 0
			local plcount = 0
			for i, ply in pairs(player.GetAll()) do
				if ply:IsBot() then
					bocount = bocount + 1
				else
					plcount = plcount + 1
				end
			end

			local newentry = {
				["sec"] = tonumber(os.date("%S")),
				["min"] = tonumber(os.date("%M")),
				["hou"] = tonumber(os.date("%H")),
				["day"] = tonumber(os.date("%d")),
				["mon"] = tonumber(os.date("%m")),
				["yea"] = tonumber(os.date("%Y")),
				["ts"] = os.time(),
				["plcount"] = plcount,
				["bocount"] = bocount,
			}

			DAM_SQL_INSERT_INTO("DAM_PLYGRAPH", newentry)
			local tab = DAM_SQL_SELECT("DAM_PLYGRAPH", nil, "ts > 0")
			if tab then
				for i, v in pairs(tab) do
					if tonumber(v.ts) < (os.time() - (60 * 60 * 24 * 30)) then
						DAM_SQL_DELETE_FROM("DAM_PLYGRAPH", "uid = '" .. v.uid .. "'")
					end
				end
			end
		end

		timer.Simple(1, DAMTrackPlayers)
	end

	DAMTrackPlayers()
end

util.AddNetworkString("dam_getplygraph")
util.AddNetworkString("dam_getplygraph_data")
net.Receive(
	"dam_getplygraph",
	function(len, ply)
		if not DAMPlyHasPermission(ply, "dam_dashboard") then return end
		local mode = net.ReadString()
		local vmod = 1
		local vmax = 1
		local max = 1
		local now = os.time()
		local enddate = os.time()
		local tab = DAM_SQL_SELECT("DAM_PLYGRAPH", nil, nil)
		local nettab = {}
		if mode == "1hour" then
			vmod = 1
			vmax = 60 + 1
			max = 60
			enddate = now - 60 * vmax
		elseif mode == "1day" then
			vmod = 60
			vmax = 60 * 24
			max = 24
			enddate = now - 60 * vmax
		elseif mode == "1week" then
			vmod = 60 * 60
			vmax = 60 * 24 * 7
			max = 7
			enddate = now - 60 * vmax
		elseif mode == "1month" then
			vmod = 60 * 60
			vmax = 60 * 24 * 30
			max = 30
			enddate = now - 60 * vmax
		end

		local c = 0
		if tab then
			local bocount = 0
			local plcount = 0
			for i, pl in pairs(player.GetAll()) do
				if pl:IsBot() then
					bocount = bocount + 1
				else
					plcount = plcount + 1
				end
			end

			table.insert(
				nettab,
				{
					["uid"] = 0,
					["sec"] = tonumber(os.date("%S")),
					["min"] = tonumber(os.date("%M")),
					["hou"] = tonumber(os.date("%H")),
					["day"] = tonumber(os.date("%d")),
					["mon"] = tonumber(os.date("%m")),
					["yea"] = tonumber(os.date("%Y")),
					["ts"] = os.time(),
					["plcount"] = plcount,
					["bocount"] = bocount
				}
			)

			for i, v in SortedPairs(tab, true) do
				local ta = {
					["sec"] = tonumber(v.sec),
					["min"] = tonumber(v.min),
					["hour"] = tonumber(v.hou),
					["day"] = tonumber(v.day),
					["month"] = tonumber(v.mon),
					["year"] = tonumber(v.yea)
				}

				local ts = os.time(ta)
				if ts > enddate then
					if c % vmod == 0 and c <= vmax then
						table.insert(nettab, v)
					elseif c > vmax then
						break
					end
				end

				c = c + 1
			end
		end

		net.Start("dam_getplygraph")
		net.WriteString(mode)
		net.WriteString(max)
		net.Send(ply)
		for i, v in pairs(nettab) do
			if i > 1 then
				net.Start("dam_getplygraph_data")
				net.WriteUInt(v.uid, 18)
				net.WriteUInt(v.ts or 0, 32)
				net.WriteUInt(v.plcount or 0, 8)
				net.WriteUInt(v.bocount or 0, 8)
				net.WriteUInt(v.sec, 6)
				net.WriteUInt(v.min, 6)
				net.WriteUInt(v.hou, 5)
				net.WriteUInt(v.day, 5)
				net.WriteUInt(v.mon, 4)
				net.WriteUInt(v.yea, 12)
				net.Send(ply)
			end
		end
	end
)

hook.Add(
	"PostGamemodeLoaded",
	"DAM_PostGamemodeLoaded_MapFileSize",
	function()
		timer.Simple(
			0,
			function()
				RunConsoleCommand("net_maxfilesize", 64)
			end
		)
	end
)

local function DAMRenderNormal(ply)
	ply:SetRenderMode(RENDERMODE_NORMAL)
	ply:SetColor(Color(255, 255, 255, 255))
	for i, wp in pairs(ply:GetWeapons()) do
		wp:SetRenderMode(RENDERMODE_NORMAL)
		wp:SetColor(Color(255, 255, 255, 255))
	end
end

local function DAMRenderCloaked(ply)
	ply:SetRenderMode(RENDERMODE_TRANSCOLOR)
	ply:SetColor(Color(255, 255, 255, 0))
	for i, wp in pairs(ply:GetWeapons()) do
		wp:SetRenderMode(RENDERMODE_TRANSCOLOR)
		wp:SetColor(Color(255, 255, 255, 0))
	end
end

function DAMToggleCloak(ply)
	if ply:GetRenderMode() == RENDERMODE_NORMAL then
		DAMRenderCloaked(ply)
	else
		DAMRenderNormal(ply)
	end
end

function DAMToggleNoclip(ply)
	if ply:GetMoveType() == MOVETYPE_WALK then
		ply:SetMoveType(MOVETYPE_NOCLIP)
	else
		ply:SetMoveType(MOVETYPE_WALK)
	end
end

function DAMToggleSpectate(ply, target)
	if ply:GetObserverTarget() == NULL then
		ply:Spectate(OBS_MODE_IN_EYE)
		ply:SpectateEntity(target)
	else
		ply:UnSpectate()
	end
end

local function DAMDisableNoclip(pl)
	if pl:GetMoveType() ~= MOVETYPE_NOCLIP then return false end
	local _pos = pl:GetPos()
	-- Stuck?
	local tr = {
		start = _pos,
		endpos = _pos,
		mins = pl:OBBMins(),
		maxs = pl:OBBMaxs(),
		filter = pl
	}

	local _t = util.TraceHull(tr)
	if _t.Hit then
		-- Up
		local trup = {
			start = _pos + Vector(0, 0, 100),
			endpos = _pos,
			mins = Vector(1, 1, 0),
			maxs = Vector(-1, -1, 0),
			filter = pl
		}

		local _tup = util.TraceHull(trup)
		-- Down
		local trdn = {
			start = _pos,
			endpos = _pos + Vector(0, 0, 100),
			mins = Vector(1, 1, 0),
			maxs = Vector(-1, -1, 0),
			filter = pl
		}

		local _tdn = util.TraceHull(trdn)
		timer.Simple(
			0.001,
			function()
				if not _tup.StartSolid and _tdn.StartSolid then
					pl:SetPos(_tup.HitPos + Vector(0, 0, 10))
				elseif _tup.StartSolid and not _tdn.StartSolid then
					pl:SetPos(_tdn.HitPos - Vector(0, 0, 72 + 10))
				elseif not _tup.StartSolid and not _tdn.StartSolid then
					_pos = _pos + Vector(0, 0, 36) -- Mid of Player
					if _pos:Distance(_tup.HitPos) < _pos:Distance(_tdn.HitPos) then
						pl:SetPos(_tup.HitPos + Vector(0, 0, 10))
					elseif _pos:Distance(_tup.HitPos) > _pos:Distance(_tdn.HitPos) then
						pl:SetPos(_tdn.HitPos - Vector(0, 0, 72 + 10))
					end
				end
			end
		)
	end

	return true
end

hook.Remove("PlayerNoClip", "DAM_PlayerNoClip_SV")
hook.Add(
	"PlayerNoClip",
	"DAM_PlayerNoClip_SV",
	function(ply, desiredNoClipState)
		if desiredNoClipState then
			if ply:GetDAMBool("perm_noclip", false) then
				DAMRenderCloaked(ply)
				ply:SetDAMBool("dam_in_noclip", true)

				return true
			else
				DAMDisableNoclip(ply)
				DAMRenderNormal(ply)
				ply:SetDAMBool("dam_in_noclip", false)

				return false
			end
		else
			DAMDisableNoclip(ply)
			DAMRenderNormal(ply)
			ply:SetDAMBool("dam_in_noclip", false)

			return true
		end
	end
)

-- PERMA PROPS
DAM_SQL_CREATE_TABLE("DAM_PP")
DAM_SQL_ADD_COLUMN("DAM_PP", "map", "TEXT DEFAULT ''")
DAM_SQL_ADD_COLUMN("DAM_PP", "classname", "TEXT DEFAULT ''")
DAM_SQL_ADD_COLUMN("DAM_PP", "content", "TEXT DEFAULT ''")
--DAM_SQL_DROP_TABLE( "DAM_PP" )
local curcleanupid = 0
function DAMPPUpdateCount()
	local ppl = DAM_SQL_SELECT("DAM_PP", {"uid",}, "map = '" .. game.GetMap() .. "'")
	local count = 0
	if ppl then
		for i, p in pairs(ppl) do
			count = count + 1
		end

		SetGlobalInt("dam_pps_count", count)
	end
end

local function DAMPPIsValid(pp)
	if pp.uid == nil then
		DAM_MSG("[PP] Invalid Perma prop: UID", Color(255, 0, 0))

		return false
	end

	if pp.classname == nil then
		DAM_MSG("[PP] Invalid Perma prop: Classname", Color(255, 0, 0))

		return false
	end

	if pp.map == nil then
		DAM_MSG("[PP] Invalid Perma prop: MAP", Color(255, 0, 0))

		return false
	end

	local content = util.JSONToTable(pp.content)
	if content.Pos == nil then
		DAM_MSG("[PP] Invalid Perma prop: Missing Pos", Color(255, 0, 0))

		return false
	end

	if content.Angle == nil then
		DAM_MSG("[PP] Invalid Perma prop: Missing Angle", Color(255, 0, 0))

		return false
	end

	if content.RenderMode == nil then
		DAM_MSG("[PP] Invalid Perma prop: Missing RenderMode", Color(255, 0, 0))

		return false
	end

	if content.ColGroup == nil then
		DAM_MSG("[PP] Invalid Perma prop: Missing ColGroup", Color(255, 0, 0))

		return false
	end

	if content.Solid == nil then
		DAM_MSG("[PP] Invalid Perma prop: Missing Solid", Color(255, 0, 0))

		return false
	end

	if content.Model == nil then
		DAM_MSG("[PP] Invalid Perma prop: Missing Model", Color(255, 0, 0))

		return false
	end

	if content.ModelScale == nil then
		DAM_MSG("[PP] Invalid Perma prop: Missing ModelScale", Color(255, 0, 0))

		return false
	end

	if content.Color == nil then
		DAM_MSG("[PP] Invalid Perma prop: Missing Color", Color(255, 0, 0))

		return false
	end

	if content.Skin == nil then
		DAM_MSG("[PP] Invalid Perma prop: Missing Skin", Color(255, 0, 0))

		return false
	end

	return true
end

local function DAMPPRepair(pp)
	DAM_MSG("[PP] Try to Repair Perma prop: " .. tostring(pp.classname) .. " [" .. tostring(pp.uid) .. "]", Color(0, 255, 0))
	if pp.uid == nil then
		DAM_MSG("[PP] Invalid Perma prop: UID", Color(255, 0, 0))

		return false
	end

	if pp.classname == nil then
		DAM_MSG("[PP] Invalid Perma prop: Classname", Color(255, 0, 0))

		return false
	end

	if pp.map == nil then
		DAM_MSG("[PP] Invalid Perma prop: MAP", Color(255, 0, 0))

		return false
	end

	local content = util.JSONToTable(pp.content)
	if content.Pos == nil then
		content.Pos = Vector(0, 0, 0)
		DAM_MSG("[PP] Invalid Perma prop: Missing Pos", Color(255, 0, 0))
		foundproblem = true
	end

	if content.Angle == nil then
		content.Angle = Angle(0, 0, 0)
		DAM_MSG("[PP] Invalid Perma prop: Missing Angle", Color(255, 0, 0))
		foundproblem = true
	end

	if content.RenderMode == nil then
		content.RenderMode = RENDERMODE_NORMAL
		DAM_MSG("[PP] Invalid Perma prop: Missing RenderMode", Color(255, 0, 0))
		foundproblem = true
	end

	if content.ColGroup == nil then
		content.ColGroup = 0
		DAM_MSG("[PP] Invalid Perma prop: Missing ColGroup", Color(255, 0, 0))
		foundproblem = true
	end

	if content.Solid == nil then
		content.Solid = SOLID_VPHYSICS
		DAM_MSG("[PP] Invalid Perma prop: Missing Solid", Color(255, 0, 0))
		foundproblem = true
	end

	if content.Model == nil then
		DAM_MSG("[PP] Invalid Perma prop: Missing Model", Color(255, 0, 0))
		foundproblem = true
	end

	if content.ModelScale == nil then
		content.ModelScale = 1
		DAM_MSG("[PP] Invalid Perma prop: Missing ModelScale", Color(255, 0, 0))
		foundproblem = true
	end

	if content.Color == nil then
		content.Color = Color(255, 255, 255, 255)
		DAM_MSG("[PP] Invalid Perma prop: Missing Color", Color(255, 0, 0))
		foundproblem = true
	end

	if content.Skin == nil then
		DAM_MSG("[PP] Invalid Perma prop: Missing Skin", Color(255, 0, 0))
		content.Skin = 0
		foundproblem = true
	end

	if pp.uid and pp.map and content and pp.classname then
		DAM_SQL_UPDATE(
			"DAM_PP",
			{
				["map"] = pp.map,
				["classname"] = pp.classname,
				["content"] = util.TableToJSON(content),
			}, "uid = '" .. pp.uid .. "'"
		)

		local reppp = DAM_SQL_SELECT("DAM_PP", nil, "uid = '" .. pp.uid .. "'")
		if reppp and reppp[1] then
			reppp = reppp[1]
			if DAMPPIsValid(reppp) then
				DAM_MSG("[PP] Repaired Perma prop: " .. tostring(pp.classname) .. " [" .. tostring(pp.uid) .. "]", Color(255, 0, 0))

				return true
			else
				return false
			end
		end
	else
		return false
	end

	return false
end

local function GetRealm()
	if SERVER then return "SERVER" end

	return "CLIENT"
end

local function DAMPPLoadProps(from)
	DAM_MSG(string.format("[PP] LOAD Perma Props: %s", from))
	DAMPPUpdateCount()
	curcleanupid = curcleanupid + 1
	local ppl = DAM_SQL_SELECT("DAM_PP", {"uid",}, "map = '" .. game.GetMap() .. "'")
	if ppl then
		for i, p in pairs(ppl) do
			p.curcleanupid = curcleanupid
			timer.Simple(
				i * 0.01,
				function()
					if curcleanupid ~= p.curcleanupid then return false end
					local pp = DAM_SQL_SELECT("DAM_PP", nil, "uid = '" .. p.uid .. "'")
					if pp and pp[1] then
						pp = pp[1]
						local valid = true
						local ent = ents.Create(pp.classname)
						if not DAMPPIsValid(pp) then
							valid = false
							DAM_MSG("[PP] Invalid Perma prop: " .. tostring(pp.classname) .. " [UID: " .. tostring(pp.uid) .. "]", Color(255, 255, 0))
							local repaired = DAMPPRepair(pp)
							if not repaired then
								DAM_MSG("[PP] Failed to Repair Perma prop: " .. tostring(pp.classname) .. " [" .. tostring(pp.uid) .. "]", Color(255, 0, 0))
								DAMAddError(table.ToString(util.JSONToTable(pp.content), "DB PP", false), "DAM PP", GetRealm())
							else
								local reppp = DAM_SQL_SELECT("DAM_PP", nil, "uid = '" .. pp.uid .. "'")
								if reppp and reppp[1] then
									pp = reppp[1]
									valid = true
								end
							end
						end

						if IsValid(ent) and valid then
							local data = util.JSONToTable(pp.content)
							ent:SetPos(data.Pos)
							ent:SetAngles(data.Angle)
							ent:SetModel(data.Model)
							ent:SetModelScale(data.ModelScale)
							ent:SetSkin(data.Skin)
							ent:SetRenderMode(data.RenderMode)
							ent:SetColor(data.Color)
							ent:SetCollisionGroup(data.ColGroup)
							ent:SetSolid(data.Solid)
							if data.Name and not isEmpty(data.Name) then
								ent:SetName(data.Name)
							end

							if data.Material and not isEmpty(data.Material) then
								ent:SetMaterial(data.Material)
							end

							if data.SubMat then
								for x, v in pairs(data.SubMat) do
									if not isEmpty(v.Material) then
										ent:SetSubMaterial(v.Material)
									end
								end
							end

							ent:Spawn()
							if data.DT then
								for k, v in pairs(data.DT) do
									if data.DT[k] == nil then continue end
									if not isfunction(ent["Set" .. k]) then continue end
									ent["Set" .. k](ent, data.DT[k])
								end
							end

							if data.BodyG then
								for k, v in pairs(data.BodyG) do
									ent:SetBodygroup(k, v)
								end
							end

							if data.SubMat then
								for k, v in pairs(data.SubMat) do
									if type(k) ~= "number" or type(v) ~= "string" then continue end
									ent:SetSubMaterial(k - 1, v)
								end
							end

							if data.Frozen then
								local phys = ent:GetPhysicsObject()
								if phys and phys:IsValid() then
									phys:EnableMotion(false)
								end
							else
								local phys = ent:GetPhysicsObject()
								if phys and phys:IsValid() then
									phys:EnableMotion(true)
								end
							end

							ent.PermaProps = true
							ent.PermaProps_ID = tonumber(p.uid)
						else
							if not IsValid(ent) then
								DAM_MSG("[PP] Can't Create Entity/Prop >> INVALID CLASS, Missing addon?", Color(255, 0, 0))
							end
						end
					else
						DAM_MSG("[PP] INVALID DATABASE ENTRY", Color(255, 0, 0))
					end
				end
			)
		end
	end
end

hook.Add(
	"InitPostEntity",
	"InitPostEntity_DAMPermaProps",
	function()
		DAM_MSG("InitPostEntity")
		timer.Simple(
			5.0,
			function()
				DAMPPLoadProps("InitPostEntity")
				pTab(hook.GetTable()["InitPostEntity"])
			end
		)
	end
)

hook.Add(
	"PostCleanupMap",
	"PostCleanupMap_DAMPermaProps",
	function()
		DAM_MSG("PostCleanupMap")
		timer.Simple(
			0.1,
			function()
				DAMPPLoadProps("PostCleanupMap")
			end
		)
	end
)

local function DAMPPSGet(ply)
	DAMPPUpdateCount()
	local pps = DAM_SQL_SELECT("DAM_PP", nil, "map = '" .. game.GetMap() .. "'")
	ply.getppsid = ply.getppsid or 0
	ply.getppsid = ply.getppsid + 1
	local count = 0
	if pps then
		for i, perma in pairs(pps) do
			count = count + 1
			perma.getppsid = ply.getppsid
			perma.count = count
			timer.Simple(
				i * 0.01,
				function()
					if IsValid(ply) and ply.getppsid == perma.getppsid then
						perma.content = util.JSONToTable(perma.content)
						net.Start("dam_pps_get")
						net.WriteUInt(perma.count, 24)
						net.WriteUInt(perma.uid, 24)
						net.WriteString(perma.classname)
						net.WriteString(perma.content.Model)
						net.Send(ply)
					end
				end
			)
		end
	end
end

util.AddNetworkString("dam_pps_get")
net.Receive(
	"dam_pps_get",
	function(len, ply)
		if not DAMPlyHasPermission(ply, "dam_permaprops") then return end
		DAMPPSGet(ply)
	end
)

util.AddNetworkString("dam_pps_rem")
net.Receive(
	"dam_pps_rem",
	function(len, ply)
		if not DAMPlyHasPermission(ply, "dam_permaprops") then return end
		local uid = net.ReadUInt(24)
		DAM_SQL_DELETE_FROM("DAM_PP", "uid = '" .. uid .. "'")
		DAMPPUpdateCount()
	end
)

util.AddNetworkString("dam_pps_tel")
net.Receive(
	"dam_pps_tel",
	function(len, ply)
		if not DAMPlyHasPermission(ply, "dam_permaprops") then return end
		local uid = net.ReadUInt(24)
		for i, ent in pairs(ents.GetAll()) do
			if ent.PermaProps_ID and ent.PermaProps_ID == uid then
				DAMTeleportTo(ply, ent)

				return
			end
		end
	end
)

util.AddNetworkString("dam_import_pps")
net.Receive(
	"dam_import_pps",
	function(len, ply)
		if not DAMPlyHasPermission(ply, "dam_permaprops") then return end
		local pps = DAM_SQL_SELECT("permaprops")
		if pps then
			for i, perma in pairs(pps) do
				local content = util.JSONToTable(perma.content)
				DAM_SQL_INSERT_INTO(
					"DAM_PP",
					{
						["map"] = perma.map,
						["classname"] = content.Class,
						["content"] = perma.content,
					}
				)

				DAM_SQL_DELETE_FROM("permaprops", "id = '" .. perma.id .. "'")
			end

			DAMPPUpdateCount()
			DAM_MSG("permaprops by malboro - imported", Color(255, 0, 0), ply)
			DAMPPSGet(ply)
		else
			DAM_MSG("permaprops by malboro - db is empty", Color(255, 0, 0), ply)
		end
	end
)

function DAMPPConvertContent(tab, class, pos, model)
	local content = {}
	content.Class = tab.Class or tab.class or class or ""
	content.Pos = tab.Pos or tab.pos or pos or Vector(0, 0, 0)
	content.Angle = tab.Angle or tab.Ang or tab.ang or Angle(0, 0, 0)
	content.Model = tab.Model or tab.model or model or ""
	content.Skin = tab.Skin or tab.skin or ""
	content.ColGroup = tab.ColGroup or tab.collision or 0
	content.Name = ""
	content.ModelScale = tab.ModelScale or tab.modelScale or 1
	content.Color = tab.Color or tab.color or Color(255, 255, 255)
	content.Material = tab.Material or tab.material or ""
	content.Solid = SOLID_VPHYSICS
	content.RenderMode = tab.RenderMode or tab.renderMode or 0
	content.NWVars = tab.NWVars or {}
	content.SubMat = tab.SubMat or {}
	content.BodyG = tab.BodyG or {}
	content.Frozen = tab.Frozen or false

	return content
end

util.AddNetworkString("dam_import_ppsce")
net.Receive(
	"dam_import_ppsce",
	function(len, ply)
		if not DAMPlyHasPermission(ply, "dam_permaprops") then return end
		local pps = DAM_SQL_SELECT("permaprops_system")
		if pps then
			for i, perma in pairs(pps) do
				local content = util.JSONToTable(perma.data)
				content = DAMPPConvertContent(content, perma.class, perma.pos, perma.model)
				content = util.TableToJSON(content)
				DAM_SQL_INSERT_INTO(
					"DAM_PP",
					{
						["map"] = perma.map,
						["classname"] = perma.class,
						["content"] = content,
					}
				)

				DAM_SQL_DELETE_FROM("permaprops_system", "id = '" .. perma.id .. "'")
			end

			DAMPPUpdateCount()
			DAM_MSG("permaprops clean and easy - imported", Color(255, 0, 0), ply)
			DAMPPSGet(ply)
		else
			DAM_MSG("permaprops clean and easy - db is empty", Color(255, 0, 0), ply)
		end
	end
)
