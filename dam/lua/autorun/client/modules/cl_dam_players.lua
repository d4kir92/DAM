local plyslist = plyslist or nil
local DAMShowOffline = false
function DAMOpenPlayers(content)
	local plys = DAMAddElement("DPanel", content, 32, 32, TOP)
	function plys:Paint(pw, ph)
		draw.SimpleText(DAMGT("players"), "DAM_30", pw / 2, ph / 2, DAMGetColor("text"), 1, 1)
	end

	local plysettings = DAMAddElement("DPanel", content, 24, 24, TOP)
	local showoffline = DAMAddElement("DCheckBox", plysettings, 24, 24, LEFT)
	showoffline:SetChecked(DAMShowOffline)
	function showoffline:OnChange()
		DAMShowOffline = not DAMShowOffline
		plyslist:Clear()
		net.Start("dam_getplys")
		net.WriteBool(DAMShowOffline)
		net.SendToServer()
	end

	local showofflineh = DAMAddElement("DLabel", plysettings, 200, 24, LEFT)
	showofflineh:SetTextAnchor(TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
	showofflineh:SetText("showoffline")
	plyslist = DAMAddElement("DListView", content, 32, 32, FILL)
	plyslist:SetMultiSelect(false)
	plyslist:AddColumn("SteamID")
	plyslist:AddColumn(DAMGT("name"))
	plyslist:AddColumn(DAMGT("usergroup"))
	function plyslist:OnRowRightClick(lineID, line)
		local Menu = DermaMenu()
		local lply = LocalPlayer()
		if lply:GetDAMBool("perm_usergroup", false) then
			local btnSetUG = Menu:AddOption(DAMGT("setusergroup"))
			btnSetUG:SetIcon("icon16/group.png")
			function btnSetUG:DoClick()
				local win = DAMAddElement("DFrame", nil, 400, 116, NODOCK)
				function win:Init()
					self.startTime = SysTime()
				end

				function win:Paint(pw, ph)
					Derma_DrawBackgroundBlur(self, self.startTime)
					draw.RoundedBox(0, 0, 0, pw, ph, DAMGetColor("navi"))
					draw.SimpleText(DAMGT("setusergroup"), "DAM_30", 48 / 4, 48 / 2, DAMGetColor("text"), 0, 1)
				end

				local ugcb = DAMAddElement("DComboBox", win, 200, 32, TOP)
				net.Receive(
					"dam_setug_getugs",
					function(len)
						local tab = net.ReadTable()
						local ugname = "user"
						if IsValid(line) and IsValid(ugcb) then
							for i, v in pairs(player.GetAll()) do
								if v:SteamID() == line:GetColumnText(1) then
									ugname = v:GetUserGroup()
								end
							end

							for i, v in pairs(tab) do
								local sel = false
								if v.name == ugname then
									sel = true
								end

								ugcb:AddChoice(v.name, v.name, sel)
							end
						end
					end
				)

				net.Start("dam_setug_getugs")
				net.SendToServer()
				local apply = DAMAddElement("DButton", win, 200, 32, TOP)
				apply:SetText("")
				function apply:Paint(pw, ph)
					if self:IsHovered() then
						draw.RoundedBox(0, 0, 0, pw, ph, Color(255, 255, 255, 100))
					end

					draw.SimpleText(DAMGT("apply"), "DAM_30", pw / 2, ph / 2, DAMGetColor("text"), 1, 1)
				end

				function apply:DoClick()
					net.Start("dam_ply_update_ug")
					net.WriteString(line:GetColumnText(1))
					net.WriteString(ugcb:GetSelected())
					net.WriteBool(DAMShowOffline)
					net.SendToServer()
					if IsValid(win) then
						win:Remove()
					end
				end
			end
		end

		if lply:GetDAMBool("perm_kick", false) then
			local btnKick = Menu:AddOption(DAMGT("kick"))
			btnKick:SetIcon("icon16/exclamation.png")
			function btnKick:DoClick()
				local win = DAMAddElement("DFrame", nil, 400, 148, NODOCK)
				function win:Init()
					self.startTime = SysTime()
				end

				function win:Paint(pw, ph)
					Derma_DrawBackgroundBlur(self, self.startTime)
					draw.RoundedBox(0, 0, 0, pw, ph, DAMGetColor("navi"))
					draw.SimpleText(DAMGT("kick"), "DAM_30", 48 / 4, 48 / 2, DAMGetColor("text"), 0, 1)
				end

				local dteh = DAMAddElement("DPanel", win, 200, 32, TOP)
				function dteh:Paint(pw, ph)
					draw.SimpleText(DAMGT("reason"), "DAM_30", pw / 2, ph / 2, DAMGetColor("text"), 1, 1)
				end

				local dte = DAMAddElement("DTextEntry", win, 200, 32, TOP)
				local kick = DAMAddElement("DButton", win, 200, 32, TOP)
				kick:SetText("")
				function kick:Paint(pw, ph)
					if self:IsHovered() then
						draw.RoundedBox(0, 0, 0, pw, ph, Color(255, 255, 255, 100))
					end

					draw.SimpleText(DAMGT("kick"), "DAM_30", pw / 2, ph / 2, DAMGetColor("text"), 1, 1)
				end

				function kick:DoClick()
					net.Start("dam_ply_kick")
					net.WriteString(line:GetColumnText(1))
					net.WriteString(dte:GetText())
					net.SendToServer()
					if IsValid(win) then
						win:Remove()
					end
				end
			end
		end

		if lply:GetDAMBool("perm_ban", false) then
			local btnBan = Menu:AddOption(DAMGT("ban"))
			btnBan:SetIcon("icon16/exclamation.png")
			function btnBan:DoClick()
				local win = DAMAddElement("DFrame", nil, 400, 212, NODOCK)
				function win:Init()
					self.startTime = SysTime()
				end

				function win:Paint(pw, ph)
					Derma_DrawBackgroundBlur(self, self.startTime)
					draw.RoundedBox(0, 0, 0, pw, ph, DAMGetColor("navi"))
					draw.SimpleText(DAMGT("ban"), "DAM_30", 48 / 4, 48 / 2, DAMGetColor("text"), 0, 1)
				end

				local dteh = DAMAddElement("DPanel", win, 200, 32, TOP)
				function dteh:Paint(pw, ph)
					draw.SimpleText(DAMGT("reason"), "DAM_30", pw / 2, ph / 2, DAMGetColor("text"), 1, 1)
				end

				local dte = DAMAddElement("DTextEntry", win, 200, 32, TOP)
				local dnwh = DAMAddElement("DPanel", win, 200, 32, TOP)
				function dnwh:Paint(pw, ph)
					draw.SimpleText(DAMGT("time") .. " (" .. DAMGT("inminutes") .. ")", "DAM_30", pw / 2, ph / 2, DAMGetColor("text"), 1, 1)
				end

				local dnw = DAMAddElement("DNumberWang", win, 200, 32, TOP)
				dnw:SetMin(0)
				dnw:SetMax(60 * 60 * 24 * 30)
				dnw:SetInterval(60)
				function dnw:OnValueChanged()
					if self:GetValue() < self:GetMin() then
						self:SetText(self:GetMin())
					end

					if self:GetValue() > self:GetMax() then
						self:SetText(self:GetMax())
					end
				end

				local ban = DAMAddElement("DButton", win, 200, 32, TOP)
				ban:SetText("")
				function ban:Paint(pw, ph)
					if self:IsHovered() then
						draw.RoundedBox(0, 0, 0, pw, ph, Color(255, 255, 255, 100))
					end

					draw.SimpleText(DAMGT("ban"), "DAM_30", pw / 2, ph / 2, DAMGetColor("text"), 1, 1)
				end

				function ban:DoClick()
					net.Start("dam_ply_ban")
					net.WriteString(line:GetColumnText(1))
					net.WriteString(dte:GetText())
					net.WriteString(dnw:GetValue())
					net.SendToServer()
					if IsValid(win) then
						win:Remove()
					end
				end
			end
		end

		Menu:Open()
	end

	plyslist:Clear()
	net.Receive(
		"dam_getplys",
		function(len)
			local v = net.ReadTable()
			if IsValid(plyslist) then
				local ply = DAMFindPlayerBySteamID(v.steamid)
				local name = "OFFLINE"
				local status = "Offline"
				if IsValid(ply) then
					name = ply:DAMName()
					status = "Online"
				end

				if status == "Offline" and not DAMShowOffline then return end
				plyslist:AddLine(v.steamid, name, v.ug)
			end
		end
	)

	net.Start("dam_getplys")
	net.WriteBool(DAMShowOffline)
	net.SendToServer()
end