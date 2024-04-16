-- CL DAM Console
function DAMConvertToStringTable(tab1, tab2)
	local ntab = {}
	ntab["data"] = {}
	table.insert(ntab["data"], Color(255, 255, 255))
	table.insert(ntab["data"], "- DATA ------------------------------------------------" .. "\n")
	local count = 0
	for i, v in SortedPairsByValue(tab1, true) do
		count = count + 1
		found = true
		local color = Color(255, 255, 255)
		if v > 1000000 then
			color = Color(255, 0, 0)
		elseif v > 100000 then
			color = Color(255, 255, 0)
		end

		table.insert(ntab["data"], color)
		table.insert(ntab["data"], math.ceil(v / 8) .. " Bytes - " .. i .. "\n")
		if count >= 10 then break end
	end

	table.insert(ntab["data"], "" .. "\n")
	ntab["calls"] = {}
	table.insert(ntab["data"], Color(255, 255, 255))
	table.insert(ntab["data"], "- CALLS -----------------------------------------------" .. "\n")
	count = 0
	found = false
	for i, v in SortedPairsByValue(tab2, true) do
		count = count + 1
		found = true
		local color = Color(255, 255, 255)
		if v > 10000 then
			color = Color(255, 0, 0)
		elseif v > 1000 then
			color = Color(255, 255, 0)
		end

		table.insert(ntab["calls"], color)
		table.insert(ntab["calls"], math.Round(v) .. "x - " .. i .. "\n")
		if count >= 10 then break end
	end

	return ntab
end

function DAMOpenConsole(content)
	local consoleentry = DAMAddElement("DTextEntry", content, 200, 32, TOP)
	consoleentry:DockMargin(0, 0, 0, 4)
	consoleentry:SetPlaceholderText("Enter a server command")
	function consoleentry:OnEnter(str)
		net.Start("dam_rcon_str")
		net.WriteString(str)
		net.SendToServer()
		self:SetText("")
	end

	local btns = DAMAddElement("DPanel", content, 200, 32, TOP)
	btns:DockMargin(0, 0, 0, 4)
	function btns:Paint(pw, ph)
	end

	--
	local btn_bot = DAMAddElement("DButton", btns, 200, 32, LEFT)
	btn_bot:SetText(DAMGT("bot"))
	function btn_bot:DoClick()
		net.Start("dam_rcon_str")
		net.WriteString("bot")
		net.SendToServer()
	end
	--[[local nettab_cl = DAMAddElement( "RichText", content, sw / 2, sh, NODOCK )
	function nettab_cl:PerformLayout()
		if self.SetUnderlineFont != nil then
			self:SetUnderlineFont( "DAM_20" )
		end
		self:SetFontInternal( "DAM_20" )
		self:SetBGColor(Color( 0, 0, 0, 100 ) )
	end
	nettab_cl:InsertColorChange( 255, 255, 255, 255 )
	nettab_cl:AppendText( "NET-STATS CLIENT\n\n" )
	for i, tab in pairs( DAMConvertToStringTable( DAM_NetTab_Data, DAM_NetTab_Calls ) ) do
		for x, entry in pairs( tab ) do
			if type( entry ) == "table" then
				local col = entry
				nettab_cl:InsertColorChange( col.r, col.g, col.b, col.a or 255 )
			else
				nettab_cl:AppendText( entry )
			end
		end
	end
	
	local nettab_sv = DAMAddElement( "RichText", content, sw / 2, sh, NODOCK )
	function nettab_sv:PerformLayout()
		if self.SetUnderlineFont != nil then
			self:SetUnderlineFont( "DAM_20" )
		end
		self:SetFontInternal( "DAM_20" )
		self:SetBGColor(Color( 0, 0, 0, 100 ) )
	end
	nettab_sv:InsertColorChange( 255, 255, 255, 255 )
	nettab_sv:AppendText( "NET-STATS SERVER\n\n" )
	net.Receive( "dam_get_netstats", function( len )
		local tab1 = net.ReadTable()
		local tab2 = net.ReadTable()
		if IsValid( nettab_sv ) then
			for i, tab in pairs( DAMConvertToStringTable( tab1, tab2 ) ) do
				for x, entry in pairs( tab ) do
					if type( entry ) == "table" then
						local col = entry
						nettab_sv:InsertColorChange( col.r, col.g, col.b, col.a or 255 )
					else
						nettab_sv:AppendText( entry )
					end
				end
			end
		end
	end )
	net.Start( "dam_get_netstats" )
	net.SendToServer()]]
	--[[local nwtab_sv = DAMAddElement( "RichText", content, sw / 2, sh, NODOCK )
	function nwtab_sv:PerformLayout()
		if self.SetUnderlineFont != nil then
			self:SetUnderlineFont( "DAM_20" )
		end
		self:SetFontInternal( "DAM_20" )
		self:SetBGColor(Color( 0, 0, 0, 100 ) )
	end
	nwtab_sv:InsertColorChange( 255, 255, 255, 255 )
	nwtab_sv:AppendText( "NW-STATS SERVER\n\n" )
	net.Receive( "dam_get_nwstats", function( len )
		local tabnw = net.ReadTable()
		local tabnw2 = net.ReadTable()
		local tabg = net.ReadTable()
		if IsValid( nwtab_sv ) then
			nwtab_sv:AppendText( "NW - CALLS:\n" )
			for tabname, tab in pairs( tabnw ) do
				nwtab_sv:AppendText( "> [" .. tabname .. "]" .. "\n" )
				for nwname, nwvalue in pairs( tab ) do
					nwtab_sv:AppendText( ">>  " .. nwvalue .. "x " .. nwname .. "\n" )
				end
			end
			nwtab_sv:AppendText( "\nNW2 - CALLS:\n" )
			for tabname, tab in pairs( tabnw2 ) do
				nwtab_sv:AppendText( "> [" .. tabname .. "]" .. "\n" )
				for nwname, nwvalue in pairs( tab ) do
					nwtab_sv:AppendText( ">>  " .. nwvalue .. "x " .. nwname .. "\n" )
				end
			end
			nwtab_sv:AppendText( "\nG - CALLS:\n" )
			for tabname, tab in pairs( tabg ) do
				nwtab_sv:AppendText( "> [" .. tabname .. "]" .. "\n" )
				for nwname, nwvalue in pairs( tab ) do
					nwtab_sv:AppendText( ">>  " .. nwvalue .. "x " .. nwname .. "\n" )
				end
			end
		end
	end )
	net.Start( "dam_get_nwstats" )
	net.SendToServer()

	local nettab_hdiv = DAMAddElement( "DHorizontalDivider", content, sw, 200, NODOCK )
	nettab_hdiv:SetText( DAMGT( "SV" ) )
	nettab_hdiv:SetLeft( nettab_cl )
	nettab_hdiv:SetRight( nettab_sv )
	nettab_hdiv:SetDividerWidth( 4 )
	nettab_hdiv:SetLeftWidth( sw / 2 )

	local nettab_vdiv = DAMAddElement( "DVerticalDivider", content, sw, 200, FILL )
	nettab_vdiv:SetText( DAMGT( "SV" ) )
	nettab_vdiv:SetTop( nettab_hdiv )
	nettab_vdiv:SetBottom( nwtab_sv )
	nettab_vdiv:SetDividerHeight( 4 )
	nettab_vdiv:SetTopHeight( (sh - 64) / 2 )]]
end