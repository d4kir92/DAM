-- DAM Perma Props
net.Receive(
	"dam_pps_get",
	function(len)
		if IsValid(pplist) then
			local nr = net.ReadUInt(24)
			if nr == 1 then
				pplist:Clear()
			end

			local uid = net.ReadUInt(24)
			local classname = net.ReadString()
			local model = net.ReadString()
			local perma = DAMAddElement("DPanel", pplist, 128, 128, TOP)
			perma:DockMargin(4, 4, 4, 4)
			function perma:Paint(pw, ph)
				draw.RoundedBox(0, 0, 0, pw, ph, DAMGetColor("ligh"))
			end

			local permamdl = DAMAddElement("DModelPanel", perma, 128, 128, LEFT)
			permamdl:SetModel(model)
			local permrem = DAMAddElement("DButton", perma, 128, 128, RIGHT)
			permrem:DockMargin(4, 4, 4, 4)
			permrem:SetText("remove")
			permrem:SetColor(Color(140, 0, 0))
			function permrem:DoClick()
				net.Start("dam_pps_rem")
				net.WriteUInt(uid, 24)
				net.SendToServer()
				perma:Remove()
			end

			local permtel = DAMAddElement("DButton", perma, 128, 128, RIGHT)
			permtel:DockMargin(4, 4, 4, 4)
			permtel:SetText("teleport")
			function permtel:DoClick()
				net.Start("dam_pps_tel")
				net.WriteUInt(uid, 24)
				net.SendToServer()
			end

			local permacn = DAMAddElement("DPanel", perma, 128, 128, FILL)
			function permacn:Paint(pw, ph)
				draw.SimpleText("NR: " .. nr .. "/" .. GetGlobalInt("dam_pps_count", 1), "DAM_24", pw / 2, ph * 0.2, DAMGetColor("text"), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
				draw.SimpleText("ID: " .. uid, "DAM_24", pw / 2, ph * 0.4, DAMGetColor("text"), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
				draw.SimpleText("Class: " .. classname, "DAM_24", pw / 2, ph * 0.6, DAMGetColor("text"), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
				draw.SimpleText(model, "DAM_24", pw / 2, ph * 0.8, DAMGetColor("text"), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			end
		end
	end
)

function DAMOpenPermaProps(content)
	local importpps = DAMAddElement("DPanel", content, 32, 32, TOP)
	importpps:DockMargin(0, 0, 0, 0)
	function importpps:Paint(pw, ph)
	end

	--
	local pps = DAMAddElement("DButton", importpps, 320, 32, LEFT)
	pps:SetText("")
	function pps:Paint(pw, ph)
		draw.RoundedBox(0, 0, 0, pw, ph, DAMGetColor("navi"))
		if self:IsHovered() then
			draw.RoundedBox(0, 0, 0, pw, ph, Color(255, 255, 255, 100))
		end

		draw.SimpleText("Import PermaProps by Malboro", "DAM_24", pw / 2, ph / 2, DAMGetColor("text"), 1, 1)
	end

	function pps:DoClick()
		net.Start("dam_import_pps")
		net.SendToServer()
	end

	local ppsce = DAMAddElement("DButton", importpps, 320, 32, LEFT)
	ppsce:SetText("")
	ppsce:DockMargin(4, 0, 0, 0)
	function ppsce:Paint(pw, ph)
		draw.RoundedBox(0, 0, 0, pw, ph, DAMGetColor("navi"))
		if self:IsHovered() then
			draw.RoundedBox(0, 0, 0, pw, ph, Color(255, 255, 255, 100))
		end

		draw.SimpleText("Import PermaProps - Clean & Easy", "DAM_24", pw / 2, ph / 2, DAMGetColor("text"), 1, 1)
	end

	function ppsce:DoClick()
		net.Start("dam_import_ppsce")
		net.SendToServer()
	end

	local navi = DAMAddElement("DLabel", content, 32, 32, TOP)
	navi:DockMargin(0, 4, 0, 0)
	navi:SetText("permaprops")
	pplist = DAMAddElement("DScrollPanel", content, 320, 32, FILL)
	function pplist:Paint(pw, ph)
		draw.RoundedBox(0, 0, 0, pw, ph, DAMGetColor("navi"))
	end

	net.Start("dam_pps_get")
	net.SendToServer()
end