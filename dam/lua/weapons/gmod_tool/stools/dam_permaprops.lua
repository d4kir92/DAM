-- DAM Perma Props
TOOL.Category = "DAM"
TOOL.Name = "Perma Props"
TOOL.Command = nil
TOOL.ConfigName = ""
if CLIENT then
	language.Add("Tool.permaprops.name", "DAM Perma Props")
	language.Add("Tool.permaprops.desc", "Perma Props/Entities")
	language.Add("Tool.permaprops.0", "LeftClick: Add Perma    RightClick: Remove Perma    Reload: Update Perma")
end

function DAMPPGetContent(ent)
	if not ent or not ent:IsValid() then return false end
	local content = {}
	content.Class = ent:GetClass()
	content.Pos = ent:GetPos()
	content.Angle = ent:GetAngles()
	content.Model = ent:GetModel()
	content.Skin = ent:GetSkin()
	content.ColGroup = ent:GetCollisionGroup()
	content.Name = ent:GetName()
	content.ModelScale = ent:GetModelScale()
	content.Color = ent:GetColor()
	content.Material = ent:GetMaterial()
	content.Solid = ent:GetSolid()
	content.RenderMode = ent:GetRenderMode()
	if ent.GetNetworkVars then
		content.NWVars = ent:GetNetworkVars()
	end

	local sm = ent:GetMaterials()
	if sm and istable(sm) then
		for k, v in pairs(sm) do
			if ent:GetSubMaterial(k) then
				content.SubMat = content.SubMat or {}
				content.SubMat[k] = ent:GetSubMaterial(k - 1)
			end
		end
	end

	local bg = ent:GetBodyGroups()
	if bg then
		for k, v in pairs(bg) do
			if ent:GetBodygroup(v.id) > 0 then
				content.BodyG = content.BodyG or {}
				content.BodyG[v.id] = ent:GetBodygroup(v.id)
			end
		end
	end

	if ent:GetPhysicsObject() and ent:GetPhysicsObject():IsValid() then
		content.Frozen = not ent:GetPhysicsObject():IsMoveable()
	end

	if content.Class == "prop_dynamic" then
		content.Class = "prop_physics"
	end

	return content
end

if SERVER then
	util.AddNetworkString("DAM_PP_NOTI")
end

local function DAM_PP_NOTI(ply, msg)
	net.Start("DAM_PP_NOTI")
	net.WriteString(msg)
	net.Send(ply)
end

if CLIENT then
	net.Receive(
		"DAM_PP_NOTI",
		function(len)
			local msg = net.ReadString()
			notification.AddLegacy(msg, NOTIFY_HINT, 4)
		end
	)
end

function TOOL:LeftClick(trace)
	if CLIENT then return true end
	local ent = trace.Entity
	local ply = self:GetOwner()
	if not IsValid(ent) then
		DAM_PP_NOTI(ply, "Invalid!")

		return false
	end

	if ent:IsPlayer() then
		DAM_PP_NOTI(ply, "That is a Player!")

		return false
	end

	if not DAMPlyHasPermission(ply, "perm_permaprops") then return end
	if ent.PermaProps then
		DAM_PP_NOTI(ply, "Prop/Entity already added!")
	else
		DAM_PP_NOTI(ply, "Prop/Entity added!")
		local content = DAMPPGetContent(ent)
		local id = DAM_SQL_INSERT_INTO(
			"DAM_PP",
			{
				["map"] = game.GetMap(),
				["classname"] = ent:GetClass(),
				["content"] = util.TableToJSON(content),
			}
		)

		ent.PermaProps_ID = tonumber(id)
		ent.PermaProps = true
		DAMPPUpdateCount()
	end

	return true
end

function TOOL:RightClick(trace)
	if CLIENT then return true end
	local ent = trace.Entity
	local ply = self:GetOwner()
	if not IsValid(ent) then
		DAM_PP_NOTI(ply, "Invalid!")

		return false
	end

	if ent:IsPlayer() then
		DAM_PP_NOTI(ply, "That is a Player!")

		return false
	end

	if not DAMPlyHasPermission(ply, "perm_permaprops") then return end
	if ent.PermaProps then
		if ent.PermaProps_ID == nil then
			DAM_PP_NOTI(ply, "PermaProps_ID invalid!")
		else
			DAM_PP_NOTI(ply, "Prop/Entity removed!")
			DAM_SQL_DELETE_FROM("DAM_PP", "uid = '" .. ent.PermaProps_ID .. "'")
			ent.PermaProps = false
			ent.PermaProps_ID = nil
			DAMPPUpdateCount()
		end
	else
		DAM_PP_NOTI(ply, "Prop/Entity is not a permaprop!")
	end

	return true
end

function TOOL:Reload(trace)
	if CLIENT then return true end
	local ent = trace.Entity
	local ply = self:GetOwner()
	if not IsValid(ent) then
		DAM_PP_NOTI(ply, "Invalid!")

		return false
	end

	if ent:IsPlayer() then
		DAM_PP_NOTI(ply, "That is a Player!")

		return false
	end

	if not DAMPlyHasPermission(ply, "perm_permaprops") then return end
	if ent.PermaProps then
		if ent.PermaProps_ID == nil then
			DAM_PP_NOTI(ply, "PermaProps_ID invalid!")
		else
			DAM_PP_NOTI(ply, "Prop/Entity updated!")
			local content = DAMPPGetContent(ent)
			DAM_SQL_UPDATE(
				"DAM_PP",
				{
					["map"] = game.GetMap(),
					["classname"] = ent:GetClass(),
					["content"] = util.TableToJSON(content),
				}, "uid = '" .. ent.PermaProps_ID .. "'"
			)

			DAMPPUpdateCount()
		end
	else
		DAM_PP_NOTI(ply, "Prop/Entity is not a permaprop!")
	end

	return true
end

function TOOL.BuildCPanel(panel)
	panel:AddControl(
		"Header",
		{
			Text = "Perma Props",
			Description = "Perma Props\n\nSaves Props/Entities\n"
		}
	)
end

function TOOL:DrawToolScreen(width, height)
	if SERVER then return end
	surface.SetDrawColor(DAMAColor())
	surface.DrawRect(0, 0, width, height)
	local font = "DAM_50"
	local text = "Perma Props"
	surface.SetFont(font)
	local _, h = surface.GetTextSize(text)
	draw.SimpleText(text, font, 128, 100, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	local font2 = "DAM_30"
	local text2 = "By DAM"
	surface.SetFont(font2)
	local _, h2 = surface.GetTextSize(text2)
	draw.SimpleText(text2, font2, 128, 128 + (h + h2) / 2 - 4, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end