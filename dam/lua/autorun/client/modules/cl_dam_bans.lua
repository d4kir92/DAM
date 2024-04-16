function DAMOpenBans(content)
	local bansh = DAMAddElement("DPanel", content, 200, 32, TOP)
	function bansh:Paint(pw, ph)
		draw.SimpleText(DAMGT("bans"), "DAM_30", pw / 2, ph / 2, DAMGetColor("text"), 1, 1)
	end

	banlist = DAMAddElement("DListView", content, 32, 32, FILL)
	banlist:SetMultiSelect(false)
	banlist:AddColumn("SteamID")
	banlist:AddColumn(DAMGT("duration"))
	banlist:AddColumn(DAMGT("reason"))
	banlist:AddColumn(DAMGT("source"))
	function banlist:OnRowRightClick(lineID, line)
		local Menu = DermaMenu()
		local btnUnban = Menu:AddOption("Unban")
		btnUnban:SetIcon("icon16/exclamation.png")
		function btnUnban:DoClick()
			net.Start("dam_ply_unban")
			net.WriteString(line:GetColumnText(1))
			net.SendToServer()
		end

		Menu:Open()
	end

	net.Receive(
		"dam_get_bans",
		function(len)
			local bans = net.ReadTable()
			if IsValid(banlist) and banlist.AddLine then
				if table.Count(bans) > 0 then
					for i, v in pairs(bans) do
						v.banned_ts = tonumber(v.banned_ts)
						if v.banned_ts == 0 then
							banlist:AddLine(v.steamid, DAMGT("perma"), v.banned_reason, v.banned_from)
						else
							banlist:AddLine(v.steamid, SysTime() - v.banned_ts, v.banned_reason, v.banned_from)
						end
					end
				else
					banlist:AddLine(0, "NO BANS")
				end
			end
		end
	)

	net.Start("dam_get_bans")
	net.SendToServer()
end