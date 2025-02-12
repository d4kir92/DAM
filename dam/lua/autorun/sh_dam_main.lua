-- SH DAM Main
DAMVERSION = 1.41
DAMVERSIONONLINE = 0.00
DAMDEBUG = false
function DAM_HR()
	MsgC(Color(0, 0, 255), "-------------------------------------------------------------------------------", "\n")
end

if SERVER then
	util.AddNetworkString("dam_msgtoply")
else
	net.Receive(
		"dam_msgtoply",
		function(len)
			local msg = net.ReadString()
			notification.AddLegacy(msg, NOTIFY_HINT, 6)
		end
	)
end

function DAM_MSG(msg, color, ply)
	color = color or Color(255, 255, 255)
	MsgC(Color(0, 0, 255), "[DAM]", color, " ", msg, "\n")
	if SERVER and ply then
		net.Start("dam_msgtoply")
		net.WriteString(msg)
		net.Send(ply)
	end
end

function DAM_ERR(msg, color, ply)
	color = color or Color(255, 255, 255)
	MsgC(Color(0, 0, 255), "[DAM][ERR][" .. DAMVERSION .. "]", color, " ", msg, "\n")
	if SERVER and ply then
		net.Start("dam_msgtoply")
		net.WriteString(msg)
		net.Send(ply)
	end
end

function isEmpty(str)
	return not not tostring(str):find("^%s*$")
end

function DAMConvertHostname(text)
	local res = text
	res = string.Replace(res, "%PLYS%", player.GetCount() .. "/" .. game.MaxPlayers())

	return res
end

-- VERSION TEST
function DAMCheckVersion()
	if DAMVERSIONONLINE <= 0.0 or DAMVERSIONONLINE ~= DAMVERSION then
		DAM_MSG("Check [DAM] Version")
		http.Fetch(
			"https://docs.google.com/spreadsheets/d/12Wx2CdNKqL54wBnu42nSSZYU5SQuhnJAkASBzBmyUpM/edit?usp=sharing",
			function(body, length, headers, code)
				if code == 200 then
					local s, e = string.find(body, "DAMVERSION*", 1, true)
					if s then
						local ov = string.sub(body, e + 1)
						s, e = string.find(ov, "*", 1, true)
						if s then
							ov = string.sub(ov, 1, s - 1)
							DAMVERSIONONLINE = tonumber(ov)
						end
					end
				else
					DAM_MSG("Failed to get Online Version: " .. tostring(code), Color(255, 0, 0))
				end
			end,
			function(msg)
				DAM_MSG("Failed to get Online Version: " .. tostring(msg), Color(255, 0, 0))
			end
		)
	end
end

hook.Add(
	"PostGamemodeLoaded",
	"DAM_PostGamemodeLoaded",
	function()
		timer.Simple(
			0,
			function()
				DAMCheckVersion()
			end
		)
	end
)

timer.Simple(
	4,
	function()
		DAMCheckVersion()
	end
)

-- SQL
function DAM_SQL_QUERY(query)
	return sql.Query(query)
end

function DAM_SQL_SELECT(dbname, cols, where)
	local c = "*"
	-- wip
	if cols then
		c = ""
		for i, v in pairs(cols) do
			if c == "" then
				c = c .. v
			else
				c = "," .. c .. v
			end
		end
	end

	local q = "SELECT " .. c .. " FROM " .. dbname
	if where then
		q = q .. " WHERE " .. where
	end

	q = q .. ";"

	return DAM_SQL_QUERY(q)
end

function DAM_SQL_CREATE_TABLE(dbname)
	if not sql.TableExists(dbname) then
		local result = DAM_SQL_QUERY("CREATE TABLE IF NOT EXISTS " .. dbname .. " ( uid INTEGER PRIMARY KEY autoincrement );")
		if result == nil then
			DAM_MSG("CREATED TABLE " .. dbname)
		end
	end
end

function DAM_SQL_ADD_COLUMN(dbname, colname, datatype)
	DAM_SQL_QUERY("ALTER TABLE " .. dbname .. " ADD " .. colname .. " " .. datatype .. ";")
end

function DAM_SQL_DROP_TABLE(dbname)
	DAM_SQL_QUERY("DROP TABLE " .. dbname .. ";")
end

function DAM_SQL_INSERT_INTO(dbname, values)
	local cols = ""
	local vals = ""
	for i, v in pairs(values) do
		if cols == "" then
			cols = i
			vals = "'" .. v .. "'"
		else
			cols = cols .. "," .. i
			vals = vals .. "," .. "'" .. v .. "'"
		end
	end

	local result = DAM_SQL_QUERY("INSERT INTO " .. dbname .. " (" .. cols .. ") VALUES (" .. vals .. ");")
	if result ~= nil then
		DAM_MSG("FAILED TO INSERT INTO DB: " .. dbname, Color(255, 0, 0))

		return -1
	end

	local last = DAM_SQL_SELECT(dbname)
	if last[#last] then return last[#last].uid end

	return -1
end

function DAM_SQL_UPDATE(dbname, values, where)
	local vals = ""
	for i, v in pairs(values) do
		if vals == "" then
			vals = "'" .. i .. "'" .. " = '" .. v .. "'"
		else
			vals = vals .. "," .. "'" .. i .. "'" .. " = '" .. v .. "'"
		end
	end

	local q = "UPDATE " .. dbname .. " SET " .. vals
	if where then
		q = q .. " WHERE " .. where
	end

	q = q .. ";"
	local result = DAM_SQL_QUERY(q)
	if result ~= nil then
		DAM_MSG("FAILED TO UPDATE DB: " .. dbname, Color(255, 0, 0))
	end
end

function DAM_SQL_DELETE_FROM(dbname, where)
	local q = "DELETE FROM " .. dbname .. " WHERE " .. where
	q = q .. ";"
	local result = DAM_SQL_QUERY(q)
	if result ~= nil then
		DAM_MSG("FAILED TO DELETE FROM DB: " .. dbname, Color(255, 0, 0))
	end
end

local samdelay = 0
hook.Add(
	"Think",
	"DAM_Check_SAM",
	function()
		if SAM_LOADED and samdelay < CurTime() then
			samdelay = CurTime() + 2
			DAM_MSG("SAM IS ALSO INSTALLED, please use only one Admin Mod!", Color(255, 0, 0))
		end
	end
)

local ulxdelay = 0
hook.Add(
	"Think",
	"DAM_Check_ULX",
	function()
		if ulx and ulxdelay < CurTime() then
			ulxdelay = CurTime() + 2
			DAM_MSG("ULX IS ALSO INSTALLED, please use only one Admin Mod!", Color(255, 0, 0))
		end
	end
)

function DAMFindPlayerBySteamID(steamid)
	for i, ply in pairs(player.GetAll()) do
		if ply:SteamID() == steamid then return ply end
	end

	return NULL
end
-- NET STATS
--[[local shownetstats = false

if true then
	DAM_NetTab_Data = DAM_NetTab_Data or {}
	DAM_NetTab_Calls = DAM_NetTab_Calls or {}

	if SERVER then
		util.AddNetworkString( "dam_get_netstats" )
		net.Receive( "dam_get_netstats", function( len, ply )
			if !DAMPlyHasPermission( ply, "dam_console" ) then
				return
			end

			local tab1 = {}
			local tab2 = {}

			local c = 0
			for i, v in SortedPairsByValue( DAM_NetTab_Data, true ) do
				c = c + 1
				if v > 0 then
					tab1[i] = v
				end
				if c >= 10 then
					break
				end
			end

			c = 0
			for i, v in SortedPairsByValue( DAM_NetTab_Calls, true ) do
				c = c + 1
				tab2[i] = v
				if c >= 10 then
					break
				end
			end

			net.Start( "dam_get_netstats" )
				net.WriteTable( tab1 )
				net.WriteTable( tab2 )
			net.Send( ply )
		end )
	end

	function DAMNetStats()
		if shownetstats then
			MsgC( Color( 0, 255, 0 ), "################################################################################\n" )
			MsgC( Color( 0, 255, 0 ), "-NETSTATS-" .. string.upper( GetRealm() ) .. "--------------------------------------------------------------------" .. "\n" )
			
			MsgC( Color( 0, 255, 0 ), "          DATA | NETNAME" .. "\n" )
			MsgC( Color( 0, 255, 0 ), "----------------------------------------------------------------------" .. "\n" )

			local count = 0
			local found = false
			for i, v in SortedPairsByValue( DAM_NetTab_Data, true ) do
				if v > 10 and count < 14 then
					count = count + 1
					found = true
					local color = Color( 255, 255, 255 )
					if v > 1000000 then
						color = Color( 255, 0, 0 )
					elseif v > 100000 then
						color = Color( 255, 255, 0 )
					end
					MsgC( color, string.format( "%9d Bytes", tostring( v / 8 ) ) .. "| " .. i .. "\n" )
				end
			end
			if !found then
				MsgC( Color( 0, 255, 0 ), " > EMPTY <" .. "\n" )
			end

			MsgC( Color( 0, 255, 0 ), "\n" )

			MsgC( Color( 0, 255, 0 ), "         CALLS | NETNAME" .. "\n" )
			MsgC( Color( 0, 255, 0 ), "----------------------------------------------------------------------" .. "\n" )

			count = 0
			found = false
			for i, v in SortedPairsByValue( DAM_NetTab_Calls, true ) do
				if v > 10 and count < 14 then
					count = count + 1
					found = true
					local color = Color( 255, 255, 255 )
					if v > 10000 then
						color = Color( 255, 0, 0 )
					elseif v > 1000 then
						color = Color( 255, 255, 0 )
					end
					MsgC( color, string.format( "%13dx ", tostring( v ) ) .. "| " .. i .. "\n" )
				end
			end
			if !found then
				MsgC( Color( 0, 255, 0 ), "> EMPTY <" .. "\n" )
			end

			if shownetstats then
				MsgC( Color( 0, 255, 0 ), "-NETSTATS-" .. string.upper( GetRealm() ) .. "--------------------------------------------------------------------" .. "\n" )
				MsgC( Color( 0, 255, 0 ), "################################################################################\n" )
			end
		end
	end

	function net.Incoming( len, client )
		local i = net.ReadHeader()
		local strName = util.NetworkIDToString( i )
		
		if ( !strName ) then return end

		local func = net.Receivers[ strName:lower() ]
		if ( !func ) then return end

		--
		-- len includes the 16 bit int which told us the message name
		--
		len = len - 16

		func( len, client )

		-- NEW
		DAM_NetTab_Data[strName] = DAM_NetTab_Data[strName] or 0
		DAM_NetTab_Data[strName] = DAM_NetTab_Data[strName] + len / 8

		DAM_NetTab_Calls[strName] = DAM_NetTab_Calls[strName] or 0
		DAM_NetTab_Calls[strName] = DAM_NetTab_Calls[strName] + 1

		DAMNetStats()
	end
end

concommand.Add( "dam_netstats", function( ply, cmd, args )
    shownetstats = !shownetstats
	if shownetstats then
		MsgC( Color( 0, 255, 0 ), "[dam_netstats] Enabled" .. "\n" )
		DAMNetStats()
	else
		MsgC( Color( 255, 0, 0 ), "[dam_netstats] Disabled" .. "\n" )
	end
end)
]]
