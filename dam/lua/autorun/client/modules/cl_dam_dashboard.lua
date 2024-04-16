local function drawCircle(x, y, radius, seg, ang, stang)
	ang = ang or 360
	stang = stang or 180
	local cir = {}
	--, u = 0.5, v = 0.5 } ) -- mid point
	table.insert(
		cir,
		{
			x = x,
			y = y
		}
	)

	for i = 0, seg do
		local a = math.rad(stang + (i / seg) * -ang)
		--, u = math.sin( a ) / 2 + 0.5, v = math.cos( a ) / 2 + 0.5 } )
		table.insert(
			cir,
			{
				x = x + math.sin(a) * radius,
				y = y + math.cos(a) * radius
			}
		)
	end

	--local a = math.rad( 0 ) + 180
	--table.insert( cir, { x = x + math.sin( a ) * radius, y = y + math.cos( a ) * radius, u = math.sin( a ) / 2 + 0.5, v = math.cos( a ) / 2 + 0.5 } )
	surface.DrawPoly(cir)
end

net.Receive(
	"dam_getplygraph",
	function(len)
		local mode = net.ReadString()
		local max = tonumber(net.ReadString())
		if IsValid(plysg) then
			plysg.mode = mode
			plysg.max = max
		end

		if plysgraph and IsValid(plysgraph) then
			plysgraph.tab = {}
		end
	end
)

net.Receive(
	"dam_getplygraph_data",
	function(len)
		local tab = {}
		tab.uid = net.ReadUInt(18)
		tab.ts = net.ReadUInt(32)
		tab.plcount = net.ReadUInt(8)
		tab.bocount = net.ReadUInt(8)
		tab.sec = net.ReadUInt(6)
		tab.min = net.ReadUInt(6)
		tab.hou = net.ReadUInt(5)
		tab.day = net.ReadUInt(5)
		tab.mon = net.ReadUInt(4)
		tab.yea = net.ReadUInt(12)
		if plysgraph and IsValid(plysgraph) then
			table.insert(plysgraph.tab, tab)
		end
	end
)

function DAMOpenDashboard(content)
	local hostname = DAMAddElement("DPanel", content, 200, 50, TOP)
	function hostname:Paint(pw, ph)
		--draw.RoundedBox(0, 0, 0, pw, ph, Color( 255, 0, 0 ))
		draw.SimpleText(DAMGT("hostname") .. ": " .. GetHostName(), "DAM_30", ph / 4, ph / 2, DAMGetColor("text"), 0, 1)
	end

	-- Server infos
	local serverinfo = DAMAddElement("DPanel", content, 200, 200, LEFT)
	serverinfo:DockMargin(0, 0, 0, 0)
	function serverinfo:Paint(pw, ph)
	end

	--draw.RoundedBox(0, 0, 0, pw, ph, DAMAColor())
	local uptimeh = DAMAddElement("DPanel", serverinfo, 200, 40, TOP)
	function uptimeh:Paint(pw, ph)
		draw.RoundedBox(0, 0, 0, pw, ph, DAMGetColor("navi"))
		draw.SimpleText(DAMGT("serveruptime"), "DAM_24", pw / 2, ph / 2, DAMGetColor("text"), 1, 1)
	end

	local uptime = DAMAddElement("DPanel", serverinfo, 200, 40, TOP)
	function uptime:Paint(pw, ph)
		draw.RoundedBox(0, 0, 0, pw, ph, DAMGetColor("ligh"))
		local ti = tonumber(GetGlobalString("DAM_SERVER_UPTIME", "0"))
		local ttab = string.FormattedTime(ti)
		draw.SimpleText(string.format("%02u:%02u:%02u", ttab.h, ttab.m, ttab.s), "DAM_30", pw / 2, ph / 2, DAMGetColor("text"), 1, 1)
	end

	local trh = DAMAddElement("DPanel", serverinfo, 200, 40, TOP)
	trh:DockMargin(0, 4, 0, 0)
	function trh:Paint(pw, ph)
		draw.RoundedBox(0, 0, 0, pw, ph, DAMGetColor("navi"))
		draw.SimpleText(DAMGT("servertickrate"), "DAM_24", pw / 2, ph / 2, DAMGetColor("text"), 1, 1)
	end

	local tr = DAMAddElement("DPanel", serverinfo, 200, 40, TOP)
	function tr:Paint(pw, ph)
		draw.RoundedBox(0, 0, 0, pw, ph, DAMGetColor("ligh"))
		local ti = tonumber(GetGlobalString("DAM_SERVER_TICKRATE", "0"))
		draw.SimpleText(string.format("%0.3f", ti), "DAM_30", pw / 2, ph / 2, DAMGetColor("text"), 1, 1)
	end

	local admins = DAMAddElement("DPanel", serverinfo, 180, 200, FILL)
	admins:DockMargin(0, 4, 0, 0)
	function admins:Paint(pw, ph)
		draw.RoundedBox(0, 0, 0, pw, ph, DAMGetColor("navi"))
	end

	local adminsh = DAMAddElement("DPanel", admins, 180, 40, TOP)
	function adminsh:Paint(pw, ph)
		draw.RoundedBox(0, 0, 0, pw, ph, DAMGetColor("navi"))
		draw.SimpleText(DAMGT("adminsonline"), "DAM_24", pw / 2, ph / 2, DAMGetColor("text"), 1, 1)
	end

	local adminsl = DAMAddElement("DScrollPanel", admins, 180, 40, FILL)
	function adminsl:Update()
		for i, ply in pairs(player.GetAll()) do
			if ply:GetUserGroup() == "superadmin" or ply:GetUserGroup() == "admin" then
				local admin = DAMAddElement("DPanel", nil, 180, 40, TOP)
				function admin:Paint(pw, ph)
					draw.RoundedBox(0, 0, 0, pw, ph, DAMGetColor("ligh"))
				end

				local adminavatar = DAMAddElement("DEnhancedAvatarImage", admin, 32, 32, LEFT)
				adminavatar:DockMargin(4, 4, 4, 4)
				adminavatar:SetPlayer(ply)
				local adminname = DAMAddElement("DPanel", admin, 180 - 40, 40, LEFT)
				function adminname:Paint(pw, ph)
					if IsValid(ply) then
						draw.SimpleText(ply:Nick(), "DAM_24", 0, ph * 0.3, DAMGetColor("text"), 0, 1)
						draw.SimpleText(ply:GetUserGroup(), "DAM_16", 0, ph * 0.7, DAMGetColor("text"), 0, 1)
					end
				end

				adminsl:AddItem(admin)
			end
		end
	end

	adminsl:Update()
	-- column2
	local serverinfo2 = DAMAddElement("DPanel", content, 180, 200, LEFT)
	serverinfo2:DockMargin(4, 0, 0, 0)
	function serverinfo2:Paint(pw, ph)
	end

	--draw.RoundedBox(0, 0, 0, pw, ph, DAMAColor())
	local curplys = DAMAddElement("DPanel", serverinfo2, 160, 200, TOP)
	function curplys:Paint(pw, ph)
		local rad = pw * 0.35
		local br = pw / 2
		--draw.RoundedBox(0, 0, 0, pw, ph, Color( 255, 0, 0 ))
		surface.SetDrawColor(DAMGetColor("ligh"))
		draw.NoTexture()
		drawCircle(br, br, rad, 64)
		local plcount = 0
		local bocount = 0
		for i, v in pairs(player.GetAll()) do
			if v:IsBot() then
				bocount = bocount + 1
			else
				plcount = plcount + 1
			end
		end

		-- players
		surface.SetDrawColor(DAMAColor())
		draw.NoTexture()
		drawCircle(br, br, rad, 64, 360 * plcount / game.MaxPlayers())
		-- bots
		surface.SetDrawColor(Color(255, 255, 0))
		draw.NoTexture()
		drawCircle(br, br, rad, 64, 360 * bocount / game.MaxPlayers(), 180 - plcount / game.MaxPlayers() * 360)
		draw.SimpleText(DAMGT("players") .. ": " .. plcount .. "/" .. game.MaxPlayers(), "DAM_30", pw / 2, ph - 34, DAMAColor(), 1, 1)
		if bocount > 0 then
			draw.SimpleText(DAMGT("bots") .. ": " .. bocount .. "/" .. game.MaxPlayers(), "DAM_30", pw / 2, ph - 12, Color(255, 255, 0), 1, 1)
		end
	end

	local mapname = game.GetMap()
	local currentmapp = DAMAddElement("DPanel", serverinfo2, 160, 160, TOP)
	currentmapp:DockMargin(0, 8, 0, 0)
	function currentmapp:Paint(pw, ph)
		draw.RoundedBox(0, 0, 0, pw, ph, DAMGetColor("navi"))
		draw.SimpleText(DAMGT("map") .. ": " .. mapname, "DAM_24", pw / 2, ph - 14, DAMGetColor("text"), 1, 1)
	end

	local currentmap = DAMAddElement("DImage", currentmapp, 128, 128, NODOCK)
	currentmap:SetPos((180 - 128) / 2, 4)
	local imgfile1 = file.Find("maps/" .. mapname .. ".png", "GAME")
	local imgfile2 = file.Find("maps/thumb/" .. mapname .. ".png", "GAME")
	if imgfile1 and #imgfile1 > 0 then
		currentmap:SetImage("maps/" .. imgfile1[1])
	elseif imgfile2 and #imgfile2 > 0 then
		currentmap:SetImage("maps/thumb/" .. imgfile2[1])
	else
		currentmap:SetImage("img/empty.png")
	end

	-- PLAYER LINE
	plysg = DAMAddElement("DPanel", content, 400, 300, FILL)
	plysg.mode = "1hour"
	plysg.max = 60
	function plysg:Paint(pw, ph)
	end

	--draw.RoundedBox(0, 0, 0, pw, ph, DAMGetColor( "ligh" ))
	local plysTop = DAMAddElement("DPanel", plysg, 32, 32, TOP)
	plysTop:DockMargin(32, 0, 0, 0)
	function plysTop:Paint(pw, ph)
	end

	--
	local tabs = {"1hour", "1day", "1week", "1month",}
	--"1year",
	for i, v in pairs(tabs) do
		local btn = DAMAddElement("DButton", plysTop, 80, 32, LEFT)
		btn:DockMargin(0, 0, 4, 0)
		btn:SetText("")
		btn.text = v
		function btn:Paint(pw, ph)
			if v == plysg.mode then
				draw.RoundedBox(0, 0, 0, pw, ph, DAMGetColor("navi"))
			else
				draw.RoundedBox(0, 0, 0, pw, ph, DAMGetColor("back"))
			end

			draw.SimpleText(DAMGT(btn.text), "DAM_16", pw / 2, ph / 2, DAMGetColor("text"), 1, 1)
		end

		function btn:DoClick()
			net.Start("dam_getplygraph")
			net.WriteString(v)
			net.SendToServer()
		end

		if v == plysg.mode then
			btn:DoClick()
		end
	end

	local plysY = DAMAddElement("DPanel", plysg, 32, 300, LEFT)
	plysY:DockMargin(0, 0, 0, 32)
	function plysY:Paint(pw, ph)
		--draw.RoundedBox( 0, 0, 0, pw, ph, DAMAColor() )
		draw.SimpleText(game.MaxPlayers(), "DAM_14", pw / 2, 7, DAMGetColor("text"), 1, 1)
		draw.SimpleText(game.MaxPlayers() * 0.75, "DAM_14", pw / 2, ph * 0.25, DAMGetColor("text"), 1, 1)
		draw.SimpleText(game.MaxPlayers() * 0.50, "DAM_14", pw / 2, ph * 0.50, DAMGetColor("text"), 1, 1)
		draw.SimpleText(game.MaxPlayers() * 0.25, "DAM_14", pw / 2, ph * 0.75, DAMGetColor("text"), 1, 1)
		draw.SimpleText("0", "DAM_14", pw / 2, ph - 7, DAMGetColor("text"), 1, 1)
	end

	local plysX = DAMAddElement("DPanel", plysg, 32, 32, BOTTOM)
	function plysX:Paint(pw, ph)
		local px = 24
		local pt = pw / plysg.max
		local ev = math.ceil(px / pt)
		for i = 1, plysg.max do
			local x = pw * i / plysg.max - 10
			if i % ev == 0 then
				draw.SimpleText("-" .. plysg.max * i / plysg.max, "DAM_14", x, ph / 2, DAMGetColor("text"), 1, 1)
			end
		end
	end

	plysgraph = DAMAddElement("DPanel", plysg, 400, 300, FILL)
	plysgraph.tab = {}
	function plysgraph:Paint(pw, ph)
		draw.RoundedBox(0, 0, 0, pw, ph, DAMGetColor("navi"))
		local px = 24
		local pt = pw / plysg.max
		local ev = math.ceil(px / pt)
		if #self.tab >= 2 then
			for i = 1, #self.tab do
				if i < #self.tab then
					self.tab[i].bocount = tonumber(self.tab[i].bocount)
					self.tab[i + 1].bocount = tonumber(self.tab[i + 1].bocount)
					self.tab[i].plcount = tonumber(self.tab[i].plcount)
					self.tab[i + 1].plcount = tonumber(self.tab[i + 1].plcount)
					local pos1 = self.tab[i]
					local pos2 = self.tab[i + 1]
					if pos1 and pos2 then
						local x1 = (i - 1) * pw / plysg.max - 10
						local y1 = ph - pos1.bocount * ph / game.MaxPlayers()
						local x2 = i * pw / plysg.max - 10
						local y2 = ph - pos2.bocount * ph / game.MaxPlayers()
						if self.tab[i].bocount > 0 or self.tab[i + 1].bocount > 0 then
							surface.SetDrawColor(255, 255, 0)
							surface.DrawLine(x1, y1, x2, y2)
							if i % ev == 0 and self.tab[i + 1].bocount > 0 then
								draw.SimpleText(self.tab[i + 1].bocount, "DAM_14", x2, y2, DAMGetColor("text"), 1, 1)
							end
						end

						x1 = (i - 1) * pw / plysg.max - 10
						y1 = ph - pos1.plcount * ph / game.MaxPlayers()
						x2 = i * pw / plysg.max - 10
						y2 = ph - pos2.plcount * ph / game.MaxPlayers()
						surface.SetDrawColor(DAMAColor())
						surface.DrawLine(x1, y1, x2, y2)
						if i % ev == 0 and self.tab[i + 1].plcount > 0 then
							draw.SimpleText(self.tab[i + 1].plcount, "DAM_14", x2, y2, DAMGetColor("text"), 1, 1)
						end
					end
				end
			end
		end
	end
end