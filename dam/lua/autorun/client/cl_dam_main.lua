-- CL DAM Main
local damfont = "Open Sans"
surface.CreateFont(
	"DAM_14",
	{
		font = damfont,
		extended = true,
		size = 14,
		weight = 700,
		blursize = 0,
		scanlines = 0,
		antialias = true,
		underline = false,
		italic = false,
		strikeout = false,
		symbol = false,
		rotary = false,
		shadow = false,
		additive = false,
		outline = false
	}
)

surface.CreateFont(
	"DAM_16",
	{
		font = damfont,
		extended = true,
		size = 16,
		weight = 700,
		blursize = 0,
		scanlines = 0,
		antialias = true,
		underline = false,
		italic = false,
		strikeout = false,
		symbol = false,
		rotary = false,
		shadow = false,
		additive = false,
		outline = false
	}
)

surface.CreateFont(
	"DAM_20",
	{
		font = damfont,
		extended = true,
		size = 20,
		weight = 700,
		blursize = 0,
		scanlines = 0,
		antialias = true,
		underline = false,
		italic = false,
		strikeout = false,
		symbol = false,
		rotary = false,
		shadow = false,
		additive = false,
		outline = false
	}
)

surface.CreateFont(
	"DAM_24",
	{
		font = damfont,
		extended = true,
		size = 24,
		weight = 700,
		blursize = 0,
		scanlines = 0,
		antialias = true,
		underline = false,
		italic = false,
		strikeout = false,
		symbol = false,
		rotary = false,
		shadow = false,
		additive = false,
		outline = false
	}
)

surface.CreateFont(
	"DAM_30",
	{
		font = damfont,
		extended = true,
		size = 30,
		weight = 700,
		blursize = 0,
		scanlines = 0,
		antialias = true,
		underline = false,
		italic = false,
		strikeout = false,
		symbol = false,
		rotary = false,
		shadow = false,
		additive = false,
		outline = false
	}
)

surface.CreateFont(
	"DAM_50",
	{
		font = damfont,
		extended = true,
		size = 50,
		weight = 700,
		blursize = 0,
		scanlines = 0,
		antialias = true,
		underline = false,
		italic = false,
		strikeout = false,
		symbol = false,
		rotary = false,
		shadow = false,
		additive = false,
		outline = false
	}
)

include("denhancedavatarimage.lua")
include("modules/cl_dam_dashboard.lua")
include("modules/cl_dam_maps.lua")
include("modules/cl_dam_players.lua")
include("modules/cl_dam_usergroups.lua")
include("modules/cl_dam_permaprops.lua")
include("modules/cl_dam_commands.lua")
include("modules/cl_dam_bans.lua")
include("modules/cl_dam_server.lua")
include("modules/cl_dam_console.lua")
include("modules/cl_dam_settings.lua")
DAMMenu = DAMMenu
local open = false
local dam_logo = Material("dam/dam_blue.png")
local dam_menu = Material("dam/dam_menu.png")
local cb_checked = Material("dam/cb_checked.png")
local cb_unchecked = Material("dam/cb_unchecked.png")
local DAM = {}
local clientfile = "dam/client.json"
DAMDefaultData = {}
DAMDefaultData.small = false
DAMDefaultData.maxim = false
DAMDefaultData.px = 50
DAMDefaultData.py = 50
DAMDefaultData.sw = 600
DAMDefaultData.sh = 412
DAMDefaultData.currenttab = "dam_dashboard"
DAMDefaultData.curpalette = "dark"
DAMDefaultData.acolor = Color(38, 222, 129)
DAMClientData = DAMDefaultData
function DAMCheckClientSettings()
	if not file.Exists("dam", "DATA") then
		file.CreateDir("dam")
	end

	if not file.Exists(clientfile, "DATA") then
		DAM_MSG("Client File Not Found, Create Client File.", Color(255, 255, 0))
		file.Write(clientfile, util.TableToJSON(DAMDefaultData, true))
	end
end

function DAMSaveClientSettings()
	DAMCheckClientSettings()
	if file.Exists(clientfile, "DATA") then
		file.Write(clientfile, util.TableToJSON(DAMClientData, true))
		DAM_MSG("Saved Client File")
	end
end

function DAMLoadClientSettings()
	DAMCheckClientSettings()
	if file.Exists(clientfile, "DATA") then
		local data = file.Read(clientfile, "DATA")
		if data then
			DAMClientData = util.JSONToTable(file.Read(clientfile, "DATA"))
			if DAMClientData then
				local changed = false
				for i, v in pairs(DAMDefaultData) do
					if DAMClientData[i] == nil then
						DAMClientData[i] = v
						changed = true
					end
				end

				if changed then
					DAMSaveClientSettings()
				end

				--DAMClientData = DAMDefaultData -- SET TO DEFAULT
				DAMUpdatePalette()
				DAM_MSG("LOADED CLIENT DATA", Color(0, 255, 0))
			else
				DAMClientData = DAMDefaultData
				DAM_MSG("FAILED CLIENT DATA", Color(255, 0, 0))
			end
		else
			DAMClientData = DAMDefaultData
			DAM_MSG("CLIENT FILE BROKEN?", Color(255, 0, 0))
		end
	else
		DAMClientData = DAMDefaultData
		DAM_MSG("CLIENT FILE NOT EXISTS!", Color(255, 0, 0))
	end
end

DAMLoadClientSettings()
function DAMAddElement(cname, parent, w, h, dock, nofocus)
	local ele = vgui.Create(cname, parent)
	ele.sw = w
	ele.sh = h
	ele:SetSize(w, h)
	if dock then
		ele:Dock(dock)
	end

	if cname == "DCheckBox" then
		function ele:Paint(pw, ph)
			surface.SetDrawColor(DAMGetColor("text"))
			if self:GetChecked() then
				surface.SetMaterial(cb_checked)
			else
				surface.SetMaterial(cb_unchecked)
			end

			surface.DrawTexturedRect(0, 0, pw, ph)
		end
	elseif cname == "DTextEntry" then
		ele:SetPaintBackground(false)
		function ele:Paint(pw, ph)
			local br = 1
			surface.SetDrawColor(DAMGetColor("text"))
			surface.DrawRect(0, 0, self:GetWide(), self:GetTall())
			surface.SetDrawColor(DAMGetColor("back"))
			surface.DrawRect(br, br, self:GetWide() - 2 * br, self:GetTall() - 2 * br)
			derma.SkinHook("Paint", "TextEntry", self, pw, ph)
			if self:GetDisabled() then
				ele:SetTextColor(Color(140, 140, 140))
				ele:SetCursorColor(Color(0, 0, 0, 0))
				ele:SetHighlightColor(Color(0, 0, 0, 0))
				surface.SetDrawColor(Color(80, 80, 80, 200))
				surface.DrawRect(br, br, self:GetWide() - 2 * br, self:GetTall() - 2 * br)
			else
				ele:SetTextColor(DAMGetColor("text"))
				ele:SetCursorColor(DAMGetColor("text"))
				local test = DAMGetColor("text")
				test.a = 120
				ele:SetHighlightColor(test)
			end
		end

		ele:SetFont("DAM_24")
	elseif cname == "DButton" then
		ele.text = ""
		ele.color = DAMGetColor("navi")
		ele:SetText("")
		function ele:SetText(txt)
			self.text = txt
		end

		function ele:GetText()
			return self.text
		end

		function ele:SetColor(col)
			self.color = col
		end

		function ele:GetColor()
			return self.color
		end

		function ele:Paint(pw, ph)
			draw.RoundedBox(0, 0, 0, pw, ph, self:GetColor())
			if self:IsHovered() then
				draw.RoundedBox(0, 0, 0, pw, ph, Color(255, 255, 255, 100))
			end

			draw.SimpleText(DAMGT(self:GetText()), "DAM_24", pw / 2, ph / 2, DAMGetColor("text"), 1, 1)
		end
	elseif cname == "DLabel" then
		ele.text = ""
		ele:SetText("")
		function ele:SetText(txt)
			self.text = txt
		end

		function ele:GetText()
			return self.text
		end

		ele.ax = TEXT_ALIGN_CENTER
		ele.ay = TEXT_ALIGN_CENTER
		function ele:SetTextAnchor(ax, ay)
			self.ax = ax
			self.ay = ay
		end

		function ele:Paint(pw, ph)
			--draw.RoundedBox( 0, 0, 0, pw, ph, DAMAColor() )
			self.px = pw / 2
			self.py = ph / 2
			if self.ax == TEXT_ALIGN_LEFT then
				self.px = ph / 4
			end

			if self.ax == TEXT_ALIGN_RIGHT then
				self.px = pw - ph / 4
			end

			draw.SimpleText(DAMGT(self:GetText()), "DAM_24", self.px, self.py, DAMGetColor("text"), self.ax, self.ay)
		end
	elseif cname == "DFrame" then
		if nofocus == nil then
			ele:MakePopup()
		end

		ele:Center()
		ele:SetDraggable(true)
		ele:SetSizable(true)
		ele:SetScreenLock(true)
		ele:ShowCloseButton(false)
		ele:SetTitle("")
		function ele:SetTitle(txt)
			self.title = txt
		end

		function ele:GetTitle()
			return self.title
		end

		ele.Close = DAMAddElement("DButton", ele, 20, 20, NODOCK)
		ele.Close:SetText("")
		function ele.Close:Paint(pw, ph)
			draw.RoundedBox(ph / 2, 0, 0, pw, ph, Color(255, 100, 100))
			if self:IsHovered() then
				draw.SimpleText("X", "DAM_20", pw / 2, ph / 2, Color(0, 0, 0), 1, 1)
			end
		end

		ele.Maxim = DAMAddElement("DButton", ele, 20, 20, NODOCK)
		ele.Maxim:SetText("")
		function ele.Maxim:Paint(pw, ph)
			draw.RoundedBox(ph / 2, 0, 0, pw, ph, Color(100, 255, 100))
			if self:IsHovered() then
				draw.SimpleText("_", "DAM_20", pw / 2, ph / 2, Color(0, 0, 0), 1, 1)
			end
		end

		function ele.Maxim:DoClick()
			if not ele.maxim then
				ele:SetSize(ScrW(), ScrH())
				ele:Center()
			else
				ele:SetSize(ele.sw, ele.sh)
				ele:Center()
			end

			ele.maxim = not ele.maxim
			if self.PostDoClick then
				self.PostDoClick()
			end
		end

		function ele:LayoutThink()
			local pw, _ = self:GetSize()
			local py = (48 - 20) / 2
			local px = pw - 20 - py
			self.Close:SetPos(px, py)
			self.Maxim:SetPos(px - 32, py)
			if self.dc then
				self.dc:SetPos(px - 32 - 32, py + 1)
			end

			if self.re then
				self.re:SetPos(px - 32 - 32 - 32, py + 1)
			end

			timer.Simple(
				0.01,
				function()
					if IsValid(ele) then
						ele:LayoutThink()
					end
				end
			)
		end

		ele:LayoutThink()
		function ele:Paint(pw, ph)
			--Derma_DrawBackgroundBlur( self, self.startTime )
			draw.RoundedBox(0, 0, 0, pw, ph, DAMGetColor("navi"))
			-- HEADER
			local x = 0
			if self.burger then
				x = x + 40
			end

			if self.logo then
				surface.SetDrawColor(DAMAColor())
				surface.SetMaterial(self.logo)
				surface.DrawTexturedRect(x + 8, 8, 32, 32)
				x = x + 40
			end

			if self:GetTitle() then
				if x == 0 then
					x = 48 / 2
				elseif x == 80 then
					x = x + 8
				end

				draw.SimpleText(self:GetTitle(), "DAM_30", x, 48 / 2, DAMGetColor("tex2"), 0, 1)
			end
		end

		--ele.OldThink = ele.OldThink or ele.Think
		function ele:Think()
			local mousex = math.Clamp(gui.MouseX(), 1, ScrW() - 1)
			local mousey = math.Clamp(gui.MouseY(), 1, ScrH() - 1)
			if self.Dragging then
				local x = mousex - self.Dragging[1]
				local y = mousey - self.Dragging[2]
				-- Lock to screen bounds if screenlock is enabled
				if self:GetScreenLock() then
					x = math.Clamp(x, 0, ScrW() - self:GetWide())
					y = math.Clamp(y, 0, ScrH() - self:GetTall())
				end

				self:SetPos(x, y)
			end

			if self.Sizing then
				local x = mousex - self.Sizing[1]
				local y = mousey - self.Sizing[2]
				local px, py = self:GetPos()
				if x < self.m_iMinWidth then
					x = self.m_iMinWidth
				elseif x > ScrW() - px and self:GetScreenLock() then
					x = ScrW() - px
				end

				if y < self.m_iMinHeight then
					y = self.m_iMinHeight
				elseif y > ScrH() - py and self:GetScreenLock() then
					y = ScrH() - py
				end

				if self.SizingMode == "sizenwse" then
					self:SetSize(x, y)
					self:SetCursor("sizenwse")

					return
				elseif self.SizingMode == "sizewe" then
					self:SetWide(x)
					self:SetCursor("sizewe")

					return
				elseif self.SizingMode == "sizens" then
					self:SetTall(y)
					self:SetCursor("sizens")

					return
				end
			end

			local screenX, screenY = self:LocalToScreen(0, 0)
			if self.Hovered and self.m_bSizable then
				if mousex > (screenX + self:GetWide() - 20) and mousey > (screenY + self:GetTall() - 20) then
					self:SetCursor("sizenwse")

					return
				elseif mousex > (screenX + self:GetWide() - 20) then
					self:SetCursor("sizewe")

					return
				elseif mousey > (screenY + self:GetTall() - 20) then
					self:SetCursor("sizens")

					return
				end
			end

			if self.Hovered and self:GetDraggable() and mousey < (screenY + 48) then
				self:SetCursor("sizeall")

				return
			end

			self:SetCursor("arrow")
			-- Don't allow the frame to go higher than 0
			if self.y < 0 then
				self:SetPos(self.x, 0)
			end
		end

		local br = 4
		ele:DockPadding(br, 48, br, br)
		function ele.Close:DoClick()
			ele:Remove()
		end
	elseif cname == "DPanel" then
		function ele:Paint(pw, ph)
		end
	end
	--

	return ele
end

local modules = {}
local modid = 0
function AddDAMModule(name, tab)
	if modules[name] then
		DAM_MSG("[AddDAMModule] Module was already added!", Color(255, 0, 0))

		return
	end

	modid = modid + 1
	tab.id = modid
	modules[name] = tab
end

function DAMReloadDAMMenu()
	if IsValid(DAMMenu) then
		DAMMenu:Remove()
		open = false
		DAM.ToggleDAMMenu()
	end
end

function DAM.CloseDAMMenu()
	if IsValid(DAMMenu) then
		DAMMenu:Hide()
	end

	open = false
end

local tabh = 40 -- 48
net.Receive(
	"dam_open_site",
	function(len)
		local site = net.ReadString()
		DAMClientData.currenttab = site
		DAMSaveClientSettings()
		if modules[site] and IsValid(DAMMenu.Content) then
			modules[site].func(DAMMenu.Content)
		end
	end
)

local UG = {}
net.Receive(
	"dam_get_sites_data",
	function(len)
		local id = net.ReadString()
		local bo = net.ReadBool()
		UG[id] = bo
	end
)

net.Receive(
	"dam_get_sites_done",
	function(len)
		UG["name"] = net.ReadString()
		if IsValid(DAMMenu) and IsValid(DAMMenu.SideBarScroll) then
			DAMMenu.SideBarScroll:Clear()
			for name, tab in SortedPairsByMemberValue(modules, "id") do
				if tobool(UG[name]) or name == "dam_settings" then
					local btn = DAMAddElement("DButton", DAMMenu, 180, tabh, TOP)
					btn:DockMargin(0, 0, 0, 2)
					btn:SetText("")
					btn.delay = 0
					btn.per = 0
					btn.enabled = false
					function btn:Paint(pw, ph)
						if LocalPlayer():GetDAMBool(name, false) then
							self.enabled = true
						end

						if self.enabled and LocalPlayer():GetDAMBool(name, false) == false then
							if DAMClientData.currenttab == name then
								DAMClientData.currenttab = "dam_dashboard"
								net.Start("dam_get_sites_data")
								net.SendToServer()
							end

							self:Remove()
						end

						if DAMClientData.currenttab == name then
							draw.RoundedBox(0, 0, 0, pw, ph, DAMGetColor("nav2"))
							draw.RoundedBox(0, 0, 0, 4, ph, DAMAColor())
						end

						if self.delay < CurTime() then
							self.delay = CurTime() + 0.02
							if self:IsHovered() then
								self.per = math.Clamp(self.per + 0.15, 0, 1)
							else
								self.per = math.Clamp(self.per - 0.20, 0, 1)
							end
						end

						local val = ph * self.per
						draw.RoundedBox(0, 0, (ph - val) / 2, pw, val, DAMGetColor("nav2"))
						draw.RoundedBox(0, 0, (ph - val) / 2, 4, val, Color(255, 255, 255))
						-- ICON
						local size = 26
						local br = (ph - size) / 2
						surface.SetMaterial(tab.icon)
						surface.SetDrawColor(DAMGetColor("tex2"))
						surface.DrawTexturedRect(br, br, size, size)
						-- Text
						draw.SimpleText(DAMGT(tab.name), "DAM_30", ph, ph / 2, DAMGetColor("tex2"), 0, 1)
					end

					function btn:DoClick()
						DAMMenu.Content:Clear()
						net.Start("dam_open_site")
						net.WriteString(name)
						net.SendToServer()
					end

					if DAMClientData.currenttab == name then
						btn:DoClick()
					end

					DAMMenu.tabs[name] = DAMMenu.SideBarScroll:AddItem(btn)
				end
			end
		end
	end
)

function DAM.OpenDAMMenu(site)
	if not IsValid(DAMMenu) then
		DAMMenu = DAMAddElement("DFrame", nil, 800, 600, NODOCK)
		DAMMenu:SetMinHeight(412)
		DAMMenu:SetMinWidth(600)
		DAMMenu.logo = dam_logo
		DAMMenu:SetTitle("D4KiRs Admin Mod")
		DAMMenu.curtabs = {}
		DAMMenu.chatabs = false
		function DAMMenuThink()
			if IsValid(DAMMenu) then
				for name, tab in SortedPairsByMemberValue(modules, "id") do
					local enabled = LocalPlayer():GetDAMBool(name, false)
					if DAMMenu.curtabs[name] == nil then
						DAMMenu.curtabs[name] = enabled
					end

					if DAMMenu.curtabs[name] ~= enabled then
						DAMMenu.curtabs[name] = enabled
						if enabled then
							DAMMenu.chatabs = true
						end
					end
				end

				if DAMMenu.chatabs then
					DAMMenu.chatabs = false
					net.Start("dam_get_sites_data")
					net.SendToServer()
				end

				if IsValid(LocalPlayer()) then
					DAMMenu.ug = DAMMenu.ug or LocalPlayer():GetUserGroup()
					if DAMMenu.ug ~= LocalPlayer():GetUserGroup() then
						DAMMenu:Remove()
						open = false
						timer.Simple(0.5, DAM.OpenDAMMenu)
					end
				end

				timer.Simple(0.1, DAMMenuThink)
			end
		end

		DAMMenuThink()
		function DAMMenu.Close:DoClick()
			DAM.CloseDAMMenu()
		end

		function DAMMenu.Maxim:DoClick()
			if not DAMClientData.maxim then
				local x, y = DAMMenu:GetPos()
				local w, h = DAMMenu:GetSize()
				DAMClientData.px = x
				DAMClientData.py = y
				DAMClientData.sw = w
				DAMClientData.sh = h
				DAMMenu:SetSize(ScrW(), ScrH())
				DAMMenu:Center()
			else
				DAMMenu:SetSize(DAMClientData.sw, DAMClientData.sh)
				DAMMenu:SetPos(DAMClientData.px, DAMClientData.py)
			end

			DAMClientData.maxim = not DAMClientData.maxim
			DAMSaveClientSettings()
		end

		DAMMenu.burger = DAMAddElement("DButton", DAMMenu, 48, 48, NODOCK)
		DAMMenu.burger:SetText("")
		function DAMMenu.burger:Paint(pw, ph)
			local color = DAMAColor()
			if self:IsHovered() then
				color = Color(255, 255, 255)
			end

			surface.SetDrawColor(color)
			surface.SetMaterial(dam_menu)
			surface.DrawTexturedRect(8 + 2, 8 + 2, 28, 28)
		end

		function DAMMenu.burger:DoClick()
			if DAMClientData.small then
				DAMClientData.small = true
			else
				DAMClientData.small = false
			end

			DAMSaveClientSettings()
			DAMClientData.small = not DAMClientData.small
		end

		DAMMenu.dc = DAMAddElement("DImageButton", DAMMenu, 20, 20, NODOCK)
		DAMMenu.dc:SetImage("dam/dc_color.png")
		function DAMMenu.dc:DoClick()
			gui.OpenURL("https://discord.gg/HBA3QA4BJq")
		end

		DAMMenu.re = DAMAddElement("DButton", DAMMenu, 20, 20, NODOCK)
		function DAMMenu.re:Paint(pw, ph)
			draw.RoundedBox(ph / 2, 0, 0, pw, ph, Color(100, 255, 255))
			if self:IsHovered() then
				draw.SimpleText("↻", "DAM_20", pw / 2, ph / 2, Color(0, 0, 0), 1, 1)
			end
		end

		function DAMMenu.re:DoClick()
			DAMReloadDAMMenu()
		end

		function DAMMenu:Init()
			self.startTime = SysTime()
		end

		function DAMMenu:OnMousePressed()
			local screenX, screenY = self:LocalToScreen(0, 0)
			if self.m_bSizable then
				if gui.MouseX() > (screenX + self:GetWide() - 20) and gui.MouseY() > (screenY + self:GetTall() - 20) then
					self.SizingMode = "sizenwse"
					self.Sizing = {gui.MouseX() - self:GetWide(), gui.MouseY() - self:GetTall()}
					self:MouseCapture(true)

					return
				elseif gui.MouseX() > (screenX + self:GetWide() - 20) then
					self.SizingMode = "sizewe"
					self.Sizing = {gui.MouseX() - self:GetWide(), 0}
					self:MouseCapture(true)

					return
				elseif gui.MouseY() > (screenY + self:GetTall() - 20) then
					self.SizingMode = "sizens"
					self.Sizing = {0, gui.MouseY() - self:GetTall()}
					self:MouseCapture(true)

					return
				end
			end

			if self:GetDraggable() and gui.MouseY() < (screenY + 48) then
				self.Dragging = {gui.MouseX() - self.x, gui.MouseY() - self.y}
				self:MouseCapture(true)

				return
			end
		end

		DAMMenu.OldOnMouseReleased = DAMMenu.OnMouseReleased
		function DAMMenu:OnMouseReleased()
			DAMMenu.OldOnMouseReleased(self)
			local w, h = DAMMenu:GetSize()
			DAMClientData.sw = w
			DAMClientData.sh = h
			local x, y = DAMMenu:GetPos()
			DAMClientData.px = x
			DAMClientData.py = y
			DAMSaveClientSettings()
		end

		DAMMenu.tabs = {}
		-- CONTENT
		DAMMenu.Content = DAMAddElement("DPanel", DAMMenu, 200, 600, FILL)
		DAMMenu.Content:DockPadding(4, 4, 4, 4)
		function DAMMenu.Content:Paint(pw, ph)
			draw.RoundedBox(0, 0, 0, pw, ph, DAMGetColor("back"))
			for x = 3, 1, -1 do
				draw.RoundedBox(0, 0, 0, x, ph, Color(0, 0, 0, 40))
			end

			for y = 3, 1, -1 do
				draw.RoundedBox(0, 0, 0, pw, y, Color(0, 0, 0, 40))
			end
		end

		-- SIDEBAR
		DAMMenu.SideBar = DAMAddElement("DPanel", DAMMenu, 240, 600, LEFT)
		DAMMenu.SideBar.sw = 240
		DAMMenu.SideBar.delay = 0
		function DAMMenu.SideBar:Paint(pw, ph)
			--BSHADOWS.BeginShadow()
			draw.RoundedBox(0, 0, 0, pw, ph, DAMGetColor("navi"))
			if self.delay < CurTime() then
				self.delay = CurTime() + 0.005
				if DAMClientData.small then
					if DAMMenu.SideBarScroll:GetVBar():IsVisible() then
						if self.sw > 54 then
							self.sw = math.Clamp(self.sw - 5, 54, 254)
						elseif self.sw < 54 then
							self.sw = math.Clamp(self.sw + 1, 40, 54)
						end
					else
						self.sw = math.Clamp(self.sw - 5, 40, 240)
					end
				else
					if DAMMenu.SideBarScroll:GetVBar():IsVisible() then
						if self.sw > 54 then
							self.sw = math.Clamp(self.sw + 5, 40, 254)
						else
							self.sw = math.Clamp(self.sw + 1, 40, 254)
						end
					else
						if self.sw >= 240 then
							self.sw = math.Clamp(self.sw - 1, 240, 254)
						elseif self.sw >= 226 then
							self.sw = math.Clamp(self.sw + 1, 40, 240)
						else
							self.sw = math.Clamp(self.sw + 5, 40, 240)
						end
					end
				end

				self:SetWide(self.sw)
			end
			--intensity, spread, blur, opacity, direction, distance, _shadowOnly
			--BSHADOWS.EndShadow(1, 1, 2)
		end

		DAMMenu.SideBarScroll = DAMAddElement("DScrollPanel", DAMMenu.SideBar, 220, 600, FILL)
		local sbar = DAMMenu.SideBarScroll.VBar
		function sbar:Paint(w, h)
			draw.RoundedBox(0, 0, 0, w, h, DAMGetColor("navi"))
		end

		function sbar.btnUp:Paint(w, h)
			draw.RoundedBox(0, 0, 0, w, h, DAMGetColor("ligh"))
		end

		function sbar.btnDown:Paint(w, h)
			draw.RoundedBox(0, 0, 0, w, h, DAMGetColor("ligh"))
		end

		function sbar.btnGrip:Paint(w, h)
			draw.RoundedBox(w / 2, 0, 0, w, h, DAMGetColor("ligh"))
		end

		-- BOTTOM BAR
		DAMMenu.version = DAMAddElement("DButton", DAMMenu.SideBar, 50, 12, BOTTOM)
		DAMMenu.version:SetText("")
		function DAMMenu.version:Paint(pw, ph)
			local color = Color(255, 0, 0)
			if DAMVERSION == DAMVERSIONONLINE then
				color = Color(0, 255, 0)
			end

			local version = string.format("%.2f", DAMVERSION)
			if not DAMClientData.small then
				draw.SimpleText(DAMGT("version") .. ": " .. version, "DAM_14", ph / 4 - 2, ph / 2 + 1, color, 0, 1)
			else
				draw.SimpleText(version, "DAM_14", pw * 0.45, ph / 2 + 1, color, 1, 1)
			end
		end

		function DAMMenu.version:DoClick()
			gui.OpenURL("https://steamcommunity.com/sharedfiles/filedetails/changelog/2647674457")
		end

		DAMMenu:SetSize(DAMClientData.sw, DAMClientData.sh)
		DAMMenu:SetPos(DAMClientData.px, DAMClientData.py)
		if DAMClientData.maxim then
			DAMMenu.Maxim:DoClick()
		end

		DAM_MSG("Ask Server for tabs")
		net.Start("dam_get_sites_data")
		net.SendToServer()
	end

	if IsValid(DAMMenu) then
		DAMMenu:Show()
	end

	open = true
end

function DAM.ToggleDAMMenu(site)
	if not open then
		DAM.OpenDAMMenu(site)
	else
		DAM.CloseDAMMenu()
	end
end

local delay = 0
local switch = false
hook.Add(
	"Think",
	"DAM_Think_Keybind",
	function()
		if switch and not input.IsKeyDown(KEY_END) then
			switch = false
		end

		if input.IsKeyDown(KEY_END) and not switch and delay < CurTime() then
			delay = CurTime() + 0.2
			switch = true
			DAM.ToggleDAMMenu()
		end
	end
)

-- MAIN MODULES --
-- Dashboard: Statistics, Info
AddDAMModule(
	"dam_dashboard",
	{
		["name"] = "dashboard",
		["icon"] = Material("dam/dam_dashboard.png"),
		["func"] = DAMOpenDashboard
	}
)

-- Server: SetPassword, SetHostname
AddDAMModule(
	"dam_maps",
	{
		["name"] = "maps",
		["icon"] = Material("dam/dam_maps.png"),
		["func"] = DAMOpenMaps
	}
)

-- Players: GiveUG
AddDAMModule(
	"dam_players",
	{
		["name"] = "players",
		["icon"] = Material("dam/dam_player.png"),
		["func"] = DAMOpenPlayers
	}
)

-- Usergroup: AddUG, RemoveUG, SettingsOfUG
AddDAMModule(
	"dam_usergroups",
	{
		["name"] = "usergroups",
		["icon"] = Material("dam/dam_ugs.png"),
		["func"] = DAMOpenUsergroups
	}
)

-- Players: GiveUG
AddDAMModule(
	"dam_bans",
	{
		["name"] = "bans",
		["icon"] = Material("dam/dam_bans.png"),
		["func"] = DAMOpenBans
	}
)

AddDAMModule(
	"dam_commands",
	{
		["name"] = "commands",
		["icon"] = Material("dam/dam_commands.png"),
		["func"] = DAMOpenCommands
	}
)

-- Server: SetPassword, SetHostname
AddDAMModule(
	"dam_server",
	{
		["name"] = "server",
		["icon"] = Material("dam/dam_server.png"),
		["func"] = DAMOpenServer
	}
)

-- PermaProps
AddDAMModule(
	"dam_permaprops",
	{
		["name"] = "permaprops",
		["icon"] = Material("dam/dam_permaprops.png"),
		["func"] = DAMOpenPermaProps
	}
)

-- Console: RCON
AddDAMModule(
	"dam_console",
	{
		["name"] = "console",
		["icon"] = Material("dam/dam_terminal.png"),
		["func"] = DAMOpenConsole
	}
)

-- Settings: Colors?
AddDAMModule(
	"dam_settings",
	{
		["name"] = "settings",
		["icon"] = Material("dam/dam_settings.png"),
		["func"] = DAMOpenSettings
	}
)

-- MAIN MODULES --
-- CMDS
concommand.Add(
	"dam",
	function(ply, cmd, args, options)
		if cmd == "dam" and (options == "" or options == "help") then
			DAM_MSG("HELP")
			DAM_MSG("• Help, shows all commands")
		end
	end, function() end, "DAM"
)

net.Receive(
	"dam_chat_help",
	function(len)
		local cmds = net.ReadTable()
		chat.AddText(Color(0, 255, 0), "DAM HELP:")
		for i, v in pairs(cmds) do
			chat.AddText(Color(0, 255, 0), string.format("%-24s", v.syntax), Color(200, 200, 255), v.help)
		end
	end
)

net.Receive(
	"dam_togglemenu",
	function(len)
		DAM.ToggleDAMMenu()
	end
)

if IsValid(DAMMenu) then
	DAMMenu:Remove()
	open = false
end

-- DEBUG
if DAMDEBUG then
	timer.Simple(
		0.5,
		function()
			--DAM.ToggleDAMMenu( "dam_dashboard" )
			DAM.ToggleDAMMenu("dam_server")
			--DAMMenu:SetSize( 600, 412 )
			DAMMenu:SetPos(50, 50)
		end
	)
end

hook.Remove("PlayerNoClip", "DAM_PlayerNoClip_CL")
hook.Add(
	"PlayerNoClip",
	"DAM_PlayerNoClip_CL",
	function(ply, desiredNoClipState)
		if desiredNoClipState then
			if ply:GetDAMBool("perm_noclip", false) then
				return true
			else
				return false
			end
		else
			return true
		end
	end
)

surface.CreateFont(
	"DAM_ESP",
	{
		font = damfont,
		extended = true,
		size = 24,
		weight = 700,
		blursize = 0,
		scanlines = 0,
		antialias = true,
		underline = false,
		italic = false,
		strikeout = false,
		symbol = false,
		rotary = false,
		shadow = true,
		additive = false,
		outline = false
	}
)

local br_x = 4
local br_y = 0
local function DAMDrawESPText(name, font, x, y, tcolor, tax, tay, bcolor)
	surface.SetFont(font)
	local tw, th = surface.GetTextSize(name)
	draw.RoundedBox(0, x - tw / 2 - br_x, y - th / 2 - br_y, tw + 2 * br_x, th + 2 * br_y, bcolor or Color(0, 0, 0, 160))
	draw.SimpleText(name, font, x, y, tcolor, tax, tay)
end

local size = 16
function DAMRenderESP(ent)
	local OBBCen = ent:LocalToWorld(ent:OBBCenter())
	local ScrCen = OBBCen:ToScreen()
	if ScrCen.x < 0 then
		ScrCen.x = 0
	elseif ScrCen.x > ScrW() - size / 2 then
		ScrCen.x = ScrW() - size / 2
	end

	if ScrCen.y < 0 then
		ScrCen.y = 0
	elseif ScrCen.y > ScrH() - size / 2 then
		ScrCen.y = ScrH() - size / 2
	end

	local color = Color(100, 100, 255, 200)
	if ent.GetUserGroupColor then
		color = ent:GetUserGroupColor()
	end

	if ent:GetClass() == "yrp_dealer" then
		color = Color(255, 255, 100, 200)
	end

	if ent:GetClass() == "yrp_teleporter" then
		color = Color(100, 100, 255, 200)
	end

	local cor_y = -12.5 * 2
	if ScrCen.y < ScrH() / 10 then
		cor_y = 12.5 * 2
	end

	local cor_x = true
	if ScrCen.x < ScrW() * 0.02 then
		cor_x = false
	elseif ScrCen.x > ScrW() - ScrW() * 0.02 then
		cor_x = false
	end

	if ent ~= LocalPlayer() then
		surface.SetDrawColor(color)
		surface.DrawLine(ScrW() / 2, ScrH() * 0.95, ScrCen.x, ScrCen.y)
		local r = size
		if ent:GetClass() == "yrp_dealer" then
			r = 0
		end

		if LocalPlayer():GetPos().z - 80 > ent:GetPos().z then
			local tri = {
				{
					x = ScrCen.x - size / 2,
					y = ScrCen.y - size / 2
				},
				{
					x = ScrCen.x + size / 2,
					y = ScrCen.y - size / 2
				},
				{
					x = ScrCen.x,
					y = ScrCen.y + size / 2
				},
			}

			surface.SetDrawColor(color)
			draw.NoTexture()
			surface.DrawPoly(tri)
		elseif LocalPlayer():GetPos().z + 80 < ent:GetPos().z then
			local tri = {
				{
					x = ScrCen.x,
					y = ScrCen.y - size / 2
				},
				{
					x = ScrCen.x + size / 2,
					y = ScrCen.y + size / 2
				},
				{
					x = ScrCen.x - size / 2,
					y = ScrCen.y + size / 2
				},
			}

			surface.SetDrawColor(color)
			draw.NoTexture()
			surface.DrawPoly(tri)
		else
			draw.RoundedBox(r, ScrCen.x - size / 2, ScrCen.y - size / 2, size, size, color)
		end

		local y = 1
		DAMDrawESPText(math.Round(ent:GetPos():Distance(LocalPlayer():GetPos()) / 52.49, 0) .. "m", "DAM_ESP", ScrCen.x, ScrCen.y + cor_y * y, Color(255, 255, 255, 200), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		y = y + 1
		if ent:IsPlayer() and cor_x then
			if ent:GetActiveWeapon() and ent:GetActiveWeapon().GetPrintName and ent:GetActiveWeapon():GetPrintName() then end --DAMDrawESPText( DAMGT( "weapon" ) .. ": " .. ent:GetActiveWeapon():GetPrintName(), "DAM_ESP", ScrCen.x, ScrCen.y + cor_y * y, Color( 255, 255, 255, 200 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER ) --y = y + 1
			if ent.GetRoleName then end --DAMDrawESPText( ent:GetRoleName(), "DAM_ESP", ScrCen.x, ScrCen.y + cor_y * y, Color( 255, 255, 255, 200 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER ) --y = y + 1
			if ent.GetGroupName then end --DAMDrawESPText( ent:GetGroupName(), "DAM_ESP", ScrCen.x, ScrCen.y + cor_y * y, Color( 255, 255, 255, 200 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER ) --y = y + 1
			DAMDrawESPText(DAMGT("rank") .. ": " .. string.upper(ent:GetUserGroup()), "DAM_ESP", ScrCen.x, ScrCen.y + cor_y * y, Color(255, 255, 255, 200), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			y = y + 1
			DAMDrawESPText(ent:Health() .. "/" .. ent:GetMaxHealth() .. " HP", "DAM_ESP", ScrCen.x, ScrCen.y + cor_y * y, Color(255, 255, 255, 200), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			y = y + 1
			local name = ent:Nick()
			if ent:IsBot() then
				name = "[BOT] " .. name
			end

			DAMDrawESPText(name, "DAM_ESP", ScrCen.x, ScrCen.y + cor_y * y, Color(255, 255, 255, 200), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			y = y + 1
		elseif ent:GetClass() == "yrp_dealer" then
			local name = ent:GetDAMString("name", "")
			DAMDrawESPText(name, "DAM_ESP", ScrCen.x, ScrCen.y + cor_y * y, Color(255, 255, 255, 200), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			y = y + 1
			DAMDrawESPText(DAMGT("dealer"), "DAM_ESP", ScrCen.x, ScrCen.y + cor_y * y, Color(255, 255, 255, 200), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			y = y + 1
		elseif ent:GetClass() == "yrp_teleporter" then
			local target = ent:GetDAMString("string_target", "")
			DAMDrawESPText(DAMGT("target") .. ": " .. target, "DAM_ESP", ScrCen.x, ScrCen.y + cor_y * y, Color(255, 255, 255, 200), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			y = y + 1
			local name = ent:GetDAMString("string_name", "")
			DAMDrawESPText(DAMGT("name") .. ": " .. name, "DAM_ESP", ScrCen.x, ScrCen.y + cor_y * y, Color(255, 255, 255, 200), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			y = y + 1
			DAMDrawESPText(DAMGT("teleporter"), "DAM_ESP", ScrCen.x, ScrCen.y + cor_y * y, Color(255, 255, 255, 200), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			y = y + 1
		end
	end
end

hook.Remove("HUDDrawScoreBoard", "dam_HUDDrawScoreBoard_esp")
hook.Add(
	"HUDDrawScoreBoard",
	"dam_HUDDrawScoreBoard_esp",
	function()
		if LocalPlayer():GetDAMBool("dam_in_noclip", false) then
			local alpha = 25
			if not LocalPlayer():GetDAMBool("dam_esp_hide", false) then
				alpha = 150
				for i, ply in pairs(player.GetAll()) do
					DAMRenderESP(ply)
				end

				for i, dealer in pairs(ents.FindByClass("yrp_dealer")) do
					DAMRenderESP(dealer)
				end

				for i, teleporter in pairs(ents.FindByClass("yrp_teleporter")) do
					DAMRenderESP(teleporter)
				end

				draw.RoundedBox(size, ScrW() / 2 - size / 2, ScrH() * 0.95 - size / 2, size, size, Color(255, 255, 255, 255))
			end

			draw.SimpleText("!ESP in chat to toggle ESP", "DAM_24", ScrW() / 2, ScrH() * 0.975, Color(255, 255, 255, alpha), 1, 1)
		end
	end
)
