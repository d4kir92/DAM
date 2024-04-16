local ugslist = nil
local ugscontent = nil
local madd = Material("dam/dam_ugadd.png")
local mrem = Material("dam/dam_ugrem.png")
function DAMOpenUsergroups(content)
	local ugs = DAMAddElement("DPanel", content, 200, 50, LEFT)
	function ugs:Paint(pw, ph)
	end

	--draw.RoundedBox( 0, 0, 0, pw, ph, DAMGetColor( "ligh" ) )
	local modug = DAMAddElement("DPanel", ugs, 200, 32, TOP)
	modug:DockMargin(0, 0, 0, 4)
	function modug:Paint(pw, ph)
		draw.RoundedBox(0, 0, 0, pw, ph, DAMGetColor("back"))
	end

	local addug = DAMAddElement("DButton", modug, 50, 32, LEFT)
	addug:SetText("")
	function addug:Paint(pw, ph)
		draw.RoundedBox(0, 0, 0, pw, ph, Color(100, 255, 100))
		surface.SetDrawColor(255, 255, 255, 255)
		surface.SetMaterial(madd)
		surface.DrawTexturedRect((pw - ph) / 2, 0, ph, ph)
	end

	function addug:DoClick()
		net.Start("dam_addug")
		net.SendToServer()
	end

	local remug = DAMAddElement("DButton", modug, 50, 32, RIGHT)
	remug:SetText("")
	function remug:Paint(pw, ph)
		if ugslist.currenttab ~= 1 and ugslist.currenttab ~= 2 then
			draw.RoundedBox(0, 0, 0, pw, ph, Color(255, 100, 100))
			surface.SetDrawColor(255, 255, 255, 255)
			surface.SetMaterial(mrem)
			surface.DrawTexturedRect((pw - ph) / 2, 0, ph, ph)
		end
	end

	function remug:DoClick()
		if ugslist.currenttab ~= 1 and ugslist.currenttab ~= 2 and ugslist and ugslist.currenttab then
			net.Start("dam_remug")
			net.WriteString(ugslist.currenttab)
			net.SendToServer()
		end
	end

	ugslist = DAMAddElement("DScrollPanel", ugs, 50, 50, FILL)
	ugslist.tabs = {}
	ugslist.currenttab = 1
	function ugslist:Paint(pw, ph)
		draw.RoundedBox(0, 0, 0, pw, ph, DAMGetColor("ligh"))
	end

	local sbar = ugslist.VBar
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

	ugscontent = DAMAddElement("DScrollPanel", content, 200, 50, FILL)
	function ugscontent:Paint(pw, ph)
		draw.RoundedBox(0, 0, 0, pw, ph, DAMGetColor("navi"))
	end

	ugscontent:DockMargin(0, 0, 0, 0)
	local sbar2 = ugscontent.VBar
	function sbar2:Paint(w, h)
		draw.RoundedBox(0, 0, 0, w, h, DAMGetColor("navi"))
	end

	function sbar2.btnUp:Paint(w, h)
		draw.RoundedBox(0, 0, 0, w, h, DAMGetColor("ligh"))
	end

	function sbar2.btnDown:Paint(w, h)
		draw.RoundedBox(0, 0, 0, w, h, DAMGetColor("ligh"))
	end

	function sbar2.btnGrip:Paint(w, h)
		draw.RoundedBox(w / 2, 0, 0, w, h, DAMGetColor("ligh"))
	end

	net.Start("dam_getugs")
	net.SendToServer()
end

net.Receive(
	"dam_getugs",
	function()
		local UGS = net.ReadTable()
		if IsValid(ugslist) then
			ugslist:Clear()
			for i, tab in pairs(UGS) do
				tab.uid = tonumber(tab.uid)
				local btn = DAMAddElement("DButton", nil, 200, 50, TOP)
				btn:SetText("")
				btn.text = tab.name
				function btn:Paint(pw, ph)
					if ugslist.currenttab == tab.uid then
						draw.RoundedBox(0, 0, 0, pw, ph, DAMGetColor("navi"))
						draw.RoundedBox(0, 0, 0, 4, ph, DAMAColor())
					end

					if self:IsHovered() then
						draw.RoundedBox(0, 0, 0, 4, ph, Color(255, 255, 255))
					end

					-- Text
					draw.SimpleText(self.text, "DAM_30", pw / 2, ph / 2, DAMGetColor("text"), 1, 1)
				end

				function btn:DoClick()
					ugslist.currenttab = tab.uid
					net.Start("dam_getug")
					net.WriteString(tab.uid)
					net.SendToServer()
				end

				if ugslist.currenttab == tab.uid then
					btn:DoClick()
				end

				ugslist.tabs[tab.uid] = btn
				ugslist:AddItem(btn)
			end
		end
	end
)

local function DAMCB(val, name)
	local line = DAMAddElement("DPanel", ugscontent, 200, 24, TOP)
	function line:Paint(pw, ph)
	end

	--
	line.cb = DAMAddElement("DCheckBox", line, 24, 24, LEFT)
	line.cb:DockMargin(4, 0, 0, 0)
	line.cb:SetChecked(val or false)
	line.text = DAMAddElement("DPanel", line, 24, 24, FILL)
	function line.text:Paint(pw, ph)
		draw.SimpleText(name, "DAM_30", ph / 4, ph / 2, DAMGetColor("text"), 0, 1)
	end

	return line
end

net.Receive(
	"dam_getug",
	function()
		local UGS = net.ReadTable()
		UGS.uid = tonumber(UGS.uid)
		if IsValid(ugscontent) then
			ugscontent:Clear()
			local name = DAMAddElement("DPanel", ugscontent, 32, 32, TOP)
			function name:Paint(pw, ph)
				draw.SimpleText(DAMGT("name"), "DAM_30", pw / 2, ph / 2, DAMGetColor("text"), 1, 1)
			end

			local nametext = DAMAddElement("DTextEntry", ugscontent, 32, 32, TOP)
			nametext:DockMargin(4, 0, 0, 0)
			nametext:SetText(UGS.name)
			function nametext:OnChange()
				local text = self:GetText()
				net.Start("dam_ug_update_name")
				net.WriteString(UGS.uid)
				net.WriteString(text)
				net.SendToServer()
				if IsValid(ugslist.tabs[UGS.uid]) then
					ugslist.tabs[UGS.uid].text = text
				end
			end

			if UGS.uid == 1 or UGS.uid == 2 then
				nametext:SetDisabled(true)
			end

			local damperm = DAMAddElement("DPanel", ugscontent, 32, 32, TOP)
			function damperm:Paint(pw, ph)
				draw.SimpleText("DAM " .. DAMGT("permissions"), "DAM_30", pw / 2, ph / 2, DAMGetColor("text"), 1, 1)
			end

			local dashboard = DAMCB(UGS.dam_dashboard, DAMGT("dashboard"))
			function dashboard.cb:OnChange()
				net.Start("dam_ug_update_dashboard")
				net.WriteString(UGS.uid)
				net.WriteBool(self:GetChecked())
				net.SendToServer()
			end

			if UGS.uid == 1 then
				dashboard:SetDisabled(true)
			end

			local maps = DAMCB(UGS.dam_maps, DAMGT("maps"))
			function maps.cb:OnChange()
				net.Start("dam_ug_update_maps")
				net.WriteString(UGS.uid)
				net.WriteBool(self:GetChecked())
				net.SendToServer()
			end

			if UGS.uid == 1 then
				maps:SetDisabled(true)
			end

			local players = DAMCB(UGS.dam_players, DAMGT("players"))
			function players.cb:OnChange()
				net.Start("dam_ug_update_players")
				net.WriteString(UGS.uid)
				net.WriteBool(self:GetChecked())
				net.SendToServer()
			end

			if UGS.uid == 1 then
				players:SetDisabled(true)
			end

			local usergroups = DAMCB(UGS.dam_usergroups, DAMGT("usergroups"))
			function usergroups.cb:OnChange()
				net.Start("dam_ug_update_usergroups")
				net.WriteString(UGS.uid)
				net.WriteBool(self:GetChecked())
				net.SendToServer()
			end

			if UGS.uid == 1 then
				usergroups:SetDisabled(true)
			end

			local permaprops = DAMCB(UGS.dam_permaprops, DAMGT("permaprops"))
			function permaprops.cb:OnChange()
				net.Start("dam_ug_update_permaprops")
				net.WriteString(UGS.uid)
				net.WriteBool(self:GetChecked())
				net.SendToServer()
			end

			if UGS.uid == 1 then
				permaprops:SetDisabled(true)
			end

			local bans = DAMCB(UGS.dam_bans, DAMGT("bans"))
			function bans.cb:OnChange()
				net.Start("dam_ug_update_bans")
				net.WriteString(UGS.uid)
				net.WriteBool(self:GetChecked())
				net.SendToServer()
			end

			if UGS.uid == 1 then
				bans:SetDisabled(true)
			end

			local commands = DAMCB(UGS.dam_commands, DAMGT("commands"))
			function commands.cb:OnChange()
				net.Start("dam_ug_update_commands")
				net.WriteString(UGS.uid)
				net.WriteBool(self:GetChecked())
				net.SendToServer()
			end

			if UGS.uid == 1 then
				commands:SetDisabled(true)
			end

			local server = DAMCB(UGS.dam_server, DAMGT("server"))
			function server.cb:OnChange()
				net.Start("dam_ug_update_server")
				net.WriteString(UGS.uid)
				net.WriteBool(self:GetChecked())
				net.SendToServer()
			end

			if UGS.uid == 1 then
				server:SetDisabled(true)
			end

			local console = DAMCB(UGS.dam_console, DAMGT("console"))
			function console.cb:OnChange()
				net.Start("dam_ug_update_console")
				net.WriteString(UGS.uid)
				net.WriteBool(self:GetChecked())
				net.SendToServer()
			end

			if UGS.uid == 1 then
				console:SetDisabled(true)
			end

			local perm = DAMAddElement("DPanel", ugscontent, 32, 32, TOP)
			function perm:Paint(pw, ph)
				draw.SimpleText(DAMGT("permissions"), "DAM_30", pw / 2, ph / 2, DAMGetColor("text"), 1, 1)
			end

			local cmds = {}
			local function DAMPermAddOption(key, nam)
				table.insert(
					cmds,
					{
						["key"] = key,
						["name"] = nam
					}
				)
			end

			DAMPermAddOption("hassuperadminpowers")
			DAMPermAddOption("hasadminpowers")
			DAMPermAddOption("perm_skippw", "skippw")
			DAMPermAddOption("perm_csay", "csay")
			DAMPermAddOption("perm_tp", "tp")
			DAMPermAddOption("perm_bring", "bring")
			DAMPermAddOption("perm_noclip", "noclip")
			DAMPermAddOption("perm_god", "god")
			DAMPermAddOption("perm_respawn", "respawn")
			DAMPermAddOption("perm_hp", "hp")
			DAMPermAddOption("perm_armor", "armor")
			DAMPermAddOption("perm_model", "model")
			DAMPermAddOption("perm_scale", "scale")
			DAMPermAddOption("perm_cleanup", "cleanup")
			DAMPermAddOption("perm_vote", "vote")
			DAMPermAddOption("perm_slay", "slay")
			DAMPermAddOption("perm_slap", "slap")
			DAMPermAddOption("perm_burn", "burn")
			DAMPermAddOption("perm_kick", "kick")
			DAMPermAddOption("perm_ban", "ban")
			DAMPermAddOption("perm_usergroup", "usergroup")
			DAMPermAddOption("perm_permaprops", "permaprops")
			DAMPermAddOption("perm_cloak", "cloak")
			DAMPermAddOption("perm_spectate", "spectate")
			for i, perma in pairs(cmds) do
				local nam = DAMGT(perma.key)
				if perma.name then
					nam = "[" .. string.upper(perma.name) .. "] " .. DAMGT(perma.name)
				end

				local permp = DAMCB(UGS[perma.key], nam)
				function permp.cb:OnChange()
					net.Start("dam_ug_update_" .. perma.key)
					net.WriteString(UGS.uid)
					net.WriteBool(self:GetChecked())
					net.SendToServer()
				end

				if UGS.uid == 1 then
					permp:SetDisabled(true)
				end
			end

			-- CAMI
			if CAMI then
				local dampermcami = DAMAddElement("DPanel", ugscontent, 32, 32, TOP)
				function dampermcami:Paint(pw, ph)
					draw.SimpleText("CAMI " .. DAMGT("permissions"), "DAM_30", pw / 2, ph / 2, DAMGetColor("text"), 1, 1)
				end

				for i, v in pairs(CAMI.GetPrivileges()) do
					local option = DAMCB(UGS[v.Name], "" .. v.Name)
					function option.cb:OnChange()
						net.Start("dam_ug_update_perm_" .. v.Name)
						net.WriteString(UGS.uid)
						net.WriteBool(self:GetChecked())
						net.SendToServer()
					end

					if UGS.uid == 1 then
						option:SetDisabled(true)
					end
				end
			end
		end
	end
)