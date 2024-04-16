-- CL DAM MAPS
local nh = 24
local sw = 128
local sh = 128 + nh
local br = 4
local function DAMCreateMapButton(tab, parent, dock)
	local name = string.Replace(tab, ".bsp", "")
	local imgfile1 = file.Find("maps/" .. name .. ".png", "GAME")
	local imgfile2 = file.Find("maps/thumb/" .. name .. ".png", "GAME")
	local pmap = DAMAddElement("DPanel", parent, sw, sh, dock)
	function pmap:Paint(pw, ph)
	end

	-- draw.RoundedBox(0,0,0,pw,ph,Color( 255, 0, 0, 100 ))
	pmap.btn = DAMAddElement("DImageButton", pmap, sw, sw, TOP)
	pmap.btn:DockMargin(0, 0, br, br)
	if imgfile1 and #imgfile1 > 0 then
		pmap.btn:SetImage("maps/" .. imgfile1[1])
	elseif imgfile2 and #imgfile2 > 0 then
		pmap.btn:SetImage("maps/thumb/" .. imgfile2[1])
	else
		pmap.btn:SetImage("img/empty.png")
	end

	function pmap.btn:DoClick()
		local gm = engine.ActiveGamemode()
		if IsValid(DAM_GM_CB) then
			_, gm = DAM_GM_CB:GetSelected()
		end

		net.Start("dam_changelevel")
		net.WriteString(gm)
		net.WriteString(name)
		net.SendToServer()
	end

	pmap.name = DAMAddElement("DPanel", pmap, sw, nh, BOTTOM)
	pmap.name:DockMargin(0, 0, br, br)
	pmap.name:SetMouseInputEnabled(false)
	function pmap.name:Paint(pw, ph)
		draw.SimpleText(name, "DAM_16", pw / 2, ph * 0.5, DAMGetColor("text"), 1, 1)
	end

	return pmap
end

function DAMOpenMaps(content)
	-- GAMEMODE
	local gmh = DAMAddElement("DPanel", content, 200, 32, TOP)
	function gmh:Paint(pw, ph)
		draw.SimpleText(DAMGT("servergamemodes"), "DAM_30", pw / 2, ph / 2, DAMGetColor("text"), 1, 1)
	end

	DAM_GM_CB = DAMAddElement("DComboBox", content, 200, 32, TOP)
	net.Receive(
		"dam_getgms",
		function(len)
			local gms = net.ReadTable()
			if gms and IsValid(DAM_GM_CB) then
				DAM_GM_CB:Clear()
				for i, v in pairs(gms) do
					DAM_GM_CB:AddChoice(v, v, v == engine.ActiveGamemode())
				end
			end
		end
	)

	net.Start("dam_getgms")
	net.SendToServer()
	-- MAP
	local maph = DAMAddElement("DButton", content, 200, 32, TOP)
	maph:SetText("")
	maph:DockMargin(0, 8, 0, 0)
	function maph:Paint(pw, ph)
		draw.RoundedBox(0, 0, 0, pw, ph, DAMGetColor("navi"))
		if self:IsHovered() then
			draw.RoundedBox(0, 0, 0, pw, ph, Color(255, 255, 255, 100))
		end

		draw.SimpleText(DAMGT("reloadcurrentmap"), "DAM_24", pw / 2, ph / 2, DAMGetColor("text"), 1, 1)
	end

	function maph:DoClick()
		local gm = engine.ActiveGamemode()
		if IsValid(DAM_GM_CB) then
			_, gm = DAM_GM_CB:GetSelected()
		end

		net.Start("dam_changelevel")
		net.WriteString(gm)
		net.WriteString(game.GetMap())
		net.SendToServer()
	end

	-- MAPS
	local mapsh = DAMAddElement("DPanel", content, 200, 32, TOP)
	mapsh:DockMargin(0, 8, 0, 0)
	function mapsh:Paint(pw, ph)
		draw.SimpleText(DAMGT("servermaps"), "DAM_30", pw / 2, ph / 2, DAMGetColor("text"), 1, 1)
	end

	local mapsscroll = DAMAddElement("DScrollPanel", content, 200, 200, FILL)
	function mapsscroll:Paint(pw, ph)
	end

	--draw.RoundedBox( 0, 0, 0, pw, ph, Color( 255, 255, 0, 100 ) )
	local mapsgrid = DAMAddElement("DGrid", mapsscroll, 200, 200, NODOCK)
	mapsgrid:SetCols(5)
	mapsgrid:SetColWide(sw)
	mapsgrid:SetRowHeight(sh)
	function mapsgrid:Paint(pw, ph)
	end

	--draw.RoundedBox( 0, 0, 0, pw, ph, Color( 255, 0, 0, 100 ) )
	function mapsgrid:Think()
		mapsgrid.count = mapsgrid.count or 0
		local cw, _ = mapsscroll:GetSize()
		local colsize = math.ceil(cw / 5)
		if colsize ~= mapsgrid:GetColWide() or mapsgrid.count ~= #mapsgrid:GetItems() then
			mapsgrid.count = #mapsgrid:GetItems()
			mapsgrid:SetColWide(colsize)
			mapsgrid:SetRowHeight(colsize + nh + 4)
			for i, v in pairs(mapsgrid:GetItems()) do
				v:SetSize(colsize, colsize + nh)
				v.btn:SetSize(colsize, colsize)
			end

			mapsscroll:Rebuild()
		end
	end

	net.Receive(
		"dam_getmaps",
		function(len)
			local mapfiles = net.ReadTable()
			if mapfiles and IsValid(mapsgrid) then
				mapsgrid:Clear()
				for i, v in pairs(mapfiles) do
					local pmap = DAMCreateMapButton(v, mapsgrid)
					mapsgrid:AddItem(pmap)
				end
			end
		end
	)

	net.Start("dam_getmaps")
	net.SendToServer()
end