function DAMOpenServer(content)
	-- SET HOSTNAME
	local hnameh = DAMAddElement("DPanel", content, 200, 32, TOP)
	function hnameh:Paint(pw, ph)
		draw.SimpleText(DAMGT("sethostname"), "DAM_30", pw / 2, ph / 2, DAMGetColor("text"), 1, 1)
	end

	local hnameprev = DAMAddElement("DPanel", content, 200, 32, TOP)
	hnameprev.text = GetGlobalString("dam_hostname", GetHostName())
	function hnameprev:Paint(pw, ph)
		local hname = self.text
		hname = DAMConvertHostname(hname)
		draw.SimpleText(DAMGT("preview") .. ": " .. hname, "DAM_30", pw / 2, ph / 2, DAMGetColor("text"), 1, 1)
	end

	local hname = DAMAddElement("DPanel", content, 200, 32, TOP)
	function hname:Paint(pw, ph)
	end

	--
	local hnamecb = DAMAddElement("DCheckBox", hname, 32, 32, LEFT)
	hnamecb:SetChecked(GetGlobalBool("dam_hostname_toggle", false))
	function hnamecb:OnChange()
		net.Start("dam_hostname_toggle")
		net.WriteBool(self:GetChecked())
		net.SendToServer()
	end

	local hnametext = DAMAddElement("DTextEntry", hname, 32, 32, FILL)
	hnametext:DockMargin(4, 0, 0, 0)
	hnametext:SetText(GetGlobalString("dam_hostname", GetHostName()))
	function hnametext:OnChange()
		hnameprev.text = self:GetText()
		net.Start("dam_update_hostname")
		net.WriteString(self:GetText())
		net.SendToServer()
	end

	function hnametext:OnValueChange()
		hnameprev.text = self:GetText()
		net.Start("dam_update_hostname")
		net.WriteString(self:GetText())
		net.SendToServer()
	end

	local specials = DAMAddElement("DPanel", content, 32, 32, TOP)
	specials:DockMargin(32 + 4, 4, 0, 0)
	function specials:Paint(pw, ph)
	end

	--
	local plys = DAMAddElement("DButton", specials, 200, 32, LEFT)
	plys:SetText("")
	function plys:Paint(pw, ph)
		draw.RoundedBox(0, 0, 0, pw, ph, DAMGetColor("navi"))
		if self:IsHovered() then
			draw.RoundedBox(0, 0, 0, pw, ph, Color(255, 255, 255, 100))
		end

		draw.SimpleText(DAMGT("playercount"), "DAM_24", pw / 2, ph / 2, DAMGetColor("text"), 1, 1)
	end

	function plys:DoClick()
		hnametext:SetValue(hnametext:GetText() .. "%PLYS%")
	end

	-- SET PASSWORD
	local pwh = DAMAddElement("DPanel", content, 200, 32, TOP)
	pwh:DockMargin(0, 10, 0, 0)
	function pwh:Paint(pw, ph)
		draw.SimpleText(DAMGT("setpassword"), "DAM_30", pw / 2, ph / 2, DAMGetColor("text"), 1, 1)
	end

	local pwt = DAMAddElement("DPanel", content, 200, 32, TOP)
	function pwt:Paint(pw, ph)
	end

	--
	local pwcb = DAMAddElement("DCheckBox", pwt, 32, 32, LEFT)
	pwcb:SetChecked(GetGlobalBool("dam_password_toggle", false))
	function pwcb:OnChange()
		net.Start("dam_password_toggle")
		net.WriteBool(self:GetChecked())
		net.SendToServer()
	end

	local pwtext = DAMAddElement("DTextEntry", pwt, 32, 32, FILL)
	pwtext:DockMargin(4, 0, 0, 0)
	function pwtext:OnChange()
		net.Start("dam_update_password")
		net.WriteString(self:GetText())
		net.SendToServer()
	end

	net.Receive(
		"dam_getpassword",
		function(len)
			if IsValid(pwtext) then
				local dampw = net.ReadString()
				pwtext:SetText(dampw)
			end
		end
	)

	net.Start("dam_getpassword")
	net.SendToServer()
	-- SET LOADINGURL
	local luh = DAMAddElement("DPanel", content, 200, 32, TOP)
	luh:DockMargin(0, 10, 0, 0)
	function luh:Paint(pw, ph)
		draw.SimpleText(DAMGT("setloadingurl"), "DAM_30", pw / 2, ph / 2, DAMGetColor("text"), 1, 1)
	end

	local lu = DAMAddElement("DPanel", content, 200, 32, TOP)
	function lu:Paint(pw, ph)
	end

	--
	local lucb = DAMAddElement("DCheckBox", lu, 32, 32, LEFT)
	lucb:SetChecked(GetGlobalBool("dam_loadingurl_toggle", false))
	function lucb:OnChange()
		net.Start("dam_loadingurl_toggle")
		net.WriteBool(self:GetChecked())
		net.SendToServer()
	end

	local lutext = DAMAddElement("DTextEntry", lu, 32, 32, FILL)
	lutext:DockMargin(4, 0, 0, 0)
	function lutext:OnChange()
		net.Start("dam_update_loadingurl")
		net.WriteString(self:GetText())
		net.SendToServer()
	end

	net.Receive(
		"dam_getloadingurl",
		function(len)
			if IsValid(lutext) then
				local damlu = net.ReadString()
				lutext:SetText(damlu)
			end
		end
	)

	net.Start("dam_getloadingurl")
	net.SendToServer()
	local importranks = DAMAddElement("DPanel", content, 32, 32, TOP)
	importranks:DockMargin(0, 32, 0, 0)
	function importranks:Paint(pw, ph)
	end

	--
	local ulx = DAMAddElement("DButton", importranks, 280, 32, LEFT)
	ulx:SetText("")
	function ulx:Paint(pw, ph)
		draw.RoundedBox(0, 0, 0, pw, ph, DAMGetColor("navi"))
		if self:IsHovered() then
			draw.RoundedBox(0, 0, 0, pw, ph, Color(255, 255, 255, 100))
		end

		draw.SimpleText(DAMGT("importulxranks"), "DAM_24", pw / 2, ph / 2, DAMGetColor("text"), 1, 1)
	end

	function ulx:DoClick()
		net.Start("dam_import_ulx")
		net.SendToServer()
	end

	local sam = DAMAddElement("DButton", importranks, 280, 32, LEFT)
	sam:SetText("")
	sam:DockMargin(4, 0, 0, 0)
	function sam:Paint(pw, ph)
		draw.RoundedBox(0, 0, 0, pw, ph, DAMGetColor("navi"))
		if self:IsHovered() then
			draw.RoundedBox(0, 0, 0, pw, ph, Color(255, 255, 255, 100))
		end

		draw.SimpleText(DAMGT("importsamranks"), "DAM_24", pw / 2, ph / 2, DAMGetColor("text"), 1, 1)
	end

	function sam:DoClick()
		net.Start("dam_import_sam")
		net.SendToServer()
	end
end