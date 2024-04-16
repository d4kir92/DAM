-- Networking
local ENTITY = FindMetaTable("Entity")
DAMDEBUGENTITY = false
-- STATS
DAM_NW = DAM_NW or {}
DAM_NW2 = DAM_NW2 or {}
DAM_G = DAM_G or {}
if ENTITY.OldSetNWAngle == nil then
	DAM_NW["angle"] = DAM_NW["angle"] or {}
	DAM_NW["bool"] = DAM_NW["bool"] or {}
	DAM_NW["entity"] = DAM_NW["entity"] or {}
	DAM_NW["float"] = DAM_NW["float"] or {}
	DAM_NW["int"] = DAM_NW["int"] or {}
	DAM_NW["string"] = DAM_NW["string"] or {}
	DAM_NW["vector"] = DAM_NW["vector"] or {}
	ENTITY.OldSetNWAngle = ENTITY.SetNWAngle
	function ENTITY:SetNWAngle(key, value)
		DAM_NW["angle"][key] = DAM_NW["angle"][key] or 0
		DAM_NW["angle"][key] = DAM_NW["angle"][key] + 1
		self:OldSetNWAngle(key, value)
	end

	ENTITY.OldSetNWBool = ENTITY.SetNWBool
	function ENTITY:SetNWBool(key, value)
		DAM_NW["bool"][key] = DAM_NW["bool"][key] or 0
		DAM_NW["bool"][key] = DAM_NW["bool"][key] + 1
		self:OldSetNWBool(key, value)
	end

	ENTITY.OldSetNWEntity = ENTITY.SetNWEntity
	function ENTITY:SetNWEntity(key, value)
		DAM_NW["entity"][key] = DAM_NW["entity"][key] or 0
		DAM_NW["entity"][key] = DAM_NW["entity"][key] + 1
		self:OldSetNWEntity(key, value)
	end

	ENTITY.OldSetNWFloat = ENTITY.SetNWFloat
	function ENTITY:SetNWFloat(key, value)
		DAM_NW["float"][key] = DAM_NW["float"][key] or 0
		DAM_NW["float"][key] = DAM_NW["float"][key] + 1
		self:OldSetNWFloat(key, value)
	end

	ENTITY.OldSetNWInt = ENTITY.SetNWInt
	function ENTITY:SetNWInt(key, value)
		DAM_NW["int"][key] = DAM_NW["int"][key] or 0
		DAM_NW["int"][key] = DAM_NW["int"][key] + 1
		self:OldSetNWInt(key, value)
	end

	ENTITY.OldSetNWString = ENTITY.SetNWString
	function ENTITY:SetNWString(key, value)
		DAM_NW["string"][key] = DAM_NW["string"][key] or 0
		DAM_NW["string"][key] = DAM_NW["string"][key] + 1
		self:OldSetNWString(key, value)
	end

	ENTITY.OldSetNWVector = ENTITY.SetNWVector
	function ENTITY:SetNWVector(key, value)
		DAM_NW["vector"][key] = DAM_NW["vector"][key] or 0
		DAM_NW["vector"][key] = DAM_NW["vector"][key] + 1
		self:OldSetNWVector(key, value)
	end

	DAM_NW2["angle"] = DAM_NW2["angle"] or {}
	DAM_NW2["bool"] = DAM_NW2["bool"] or {}
	DAM_NW2["entity"] = DAM_NW2["entity"] or {}
	DAM_NW2["float"] = DAM_NW2["float"] or {}
	DAM_NW2["int"] = DAM_NW2["int"] or {}
	DAM_NW2["string"] = DAM_NW2["string"] or {}
	DAM_NW2["vector"] = DAM_NW2["vector"] or {}
	ENTITY.OldSetNW2Angle = ENTITY.SetNW2Angle
	function ENTITY:SetNW2Angle(key, value)
		DAM_NW2["angle"][key] = DAM_NW2["angle"][key] or 0
		DAM_NW2["angle"][key] = DAM_NW2["angle"][key] + 1
		self:OldSetNW2Angle(key, value)
	end

	ENTITY.OldSetNW2Bool = ENTITY.SetNW2Bool
	function ENTITY:SetNW2Bool(key, value)
		DAM_NW2["bool"][key] = DAM_NW2["bool"][key] or 0
		DAM_NW2["bool"][key] = DAM_NW2["bool"][key] + 1
		self:OldSetNW2Bool(key, value)
	end

	ENTITY.OldSetNW2Entity = ENTITY.SetNW2Entity
	function ENTITY:SetNW2Entity(key, value)
		DAM_NW2["entity"][key] = DAM_NW2["entity"][key] or 0
		DAM_NW2["entity"][key] = DAM_NW2["entity"][key] + 1
		self:OldSetNW2Entity(key, value)
	end

	ENTITY.OldSetNW2Float = ENTITY.SetNW2Float
	function ENTITY:SetNW2Float(key, value)
		DAM_NW2["float"][key] = DAM_NW2["float"][key] or 0
		DAM_NW2["float"][key] = DAM_NW2["float"][key] + 1
		self:OldSetNW2Float(key, value)
	end

	ENTITY.OldSetNW2Int = ENTITY.SetNW2Int
	function ENTITY:SetNW2Int(key, value)
		DAM_NW2["int"][key] = DAM_NW2["int"][key] or 0
		DAM_NW2["int"][key] = DAM_NW2["int"][key] + 1
		self:OldSetNW2Int(key, value)
	end

	ENTITY.OldSetNW2String = ENTITY.SetNW2String
	function ENTITY:SetNW2String(key, value)
		DAM_NW2["string"][key] = DAM_NW2["string"][key] or 0
		DAM_NW2["string"][key] = DAM_NW2["string"][key] + 1
		self:OldSetNW2String(key, value)
	end

	ENTITY.OldSetNW2Vector = ENTITY.SetNW2Vector
	function ENTITY:SetNW2Vector(key, value)
		DAM_NW2["vector"][key] = DAM_NW2["vector"][key] or 0
		DAM_NW2["vector"][key] = DAM_NW2["vector"][key] + 1
		self:OldSetNW2Vector(key, value)
	end

	DAM_G["angle"] = DAM_G["angle"] or {}
	DAM_G["bool"] = DAM_G["bool"] or {}
	DAM_G["entity"] = DAM_G["entity"] or {}
	DAM_G["float"] = DAM_G["float"] or {}
	DAM_G["int"] = DAM_G["int"] or {}
	DAM_G["string"] = DAM_G["string"] or {}
	DAM_G["vector"] = DAM_G["vector"] or {}
	OldSetGlobalAngle = SetGlobalAngle
	function OldSetGlobalAngle(key, value)
		DAM_G["angle"][key] = DAM_G["angle"][key] or 0
		DAM_G["angle"][key] = DAM_G["angle"][key] + 1
		OldSetGlobalAngle(key, value)
	end

	OldSetGlobalBool = SetGlobalBool
	function OldSetGlobalBool(key, value)
		DAM_G["bool"][key] = DAM_G["bool"][key] or 0
		DAM_G["bool"][key] = DAM_G["bool"][key] + 1
		OldSetGlobalBool(key, value)
	end

	OldSetGlobalEntity = SetGlobalEntity
	function OldSetGlobalEntity(key, value)
		DAM_G["entity"][key] = DAM_G["entity"][key] or 0
		DAM_G["entity"][key] = DAM_G["entity"][key] + 1
		OldSetGlobalEntity(key, value)
	end

	OldSetGlobalFloat = SetGlobalFloat
	function OldSetGlobalFloat(key, value)
		DAM_G["float"][key] = DAM_G["float"][key] or 0
		DAM_G["float"][key] = DAM_G["float"][key] + 1
		OldSetGlobalFloat(key, value)
	end

	OldSetGlobalInt = SetGlobalInt
	function OldSetGlobalInt(key, value)
		DAM_G["int"][key] = DAM_G["int"][key] or 0
		DAM_G["int"][key] = DAM_G["int"][key] + 1
		OldSetGlobalInt(key, value)
	end

	OldSetGlobalString = SetGlobalString
	function OldSetGlobalString(key, value)
		DAM_G["string"][key] = DAM_G["string"][key] or 0
		DAM_G["string"][key] = DAM_G["string"][key] + 1
		OldSetGlobalString(key, value)
	end

	OldSetGlobalVector = SetGlobalVector
	function OldSetGlobalVector(key, value)
		DAM_G["vector"][key] = DAM_G["vector"][key] or 0
		DAM_G["vector"][key] = DAM_G["vector"][key] + 1
		OldSetGlobalVector(key, value)
	end
end

-- STATS
local c = {}
-- ANGLE
function ENTITY:GetDAMAngle(key, value)
	if not IsValid(self) then return value or "" end

	return self:GetNW2Angle(key, value)
end

function ENTITY:SetDAMAngle(key, value)
	if not IsValid(self) then return end
	if self:GetDAMAngle(key) ~= value or value == Angle(0, 0, 0) then
		self:SetNW2Angle(key, value)
	elseif DAMDEBUGENTITY then
		c["angle"] = c["angle"] or 0
		c["angle"] = c["angle"] + 1
	end
end

-- BOOL
function ENTITY:GetDAMBool(key, value)
	if not IsValid(self) then return value or false end

	return tobool(self:GetNW2Bool(key, value))
end

function ENTITY:SetDAMBool(key, value)
	if not IsValid(self) then return end
	if self:GetDAMAngle(key) ~= value or value == false then
		self:SetNW2Bool(key, value)
	elseif DAMDEBUGENTITY then
		c["bool"] = c["bool"] or 0
		c["bool"] = c["bool"] + 1
	end
end

-- ENTITY
function ENTITY:GetDAMEntity(key, value)
	if not IsValid(self) then return value or NULL end

	return self:GetNW2Entity(key, value)
end

function ENTITY:SetDAMEntity(key, value)
	if not IsValid(self) then return end
	if self:GetDAMEntity(key) ~= value or value == NULL then
		self:SetNW2Entity(key, value)
	elseif DAMDEBUGENTITY then
		c["entity"] = c["entity"] or 0
		c["entity"] = c["entity"] + 1
	end
end

-- FLOAT
function ENTITY:GetDAMFloat(key, value)
	if not IsValid(self) then return value or 0 end

	return tonumber(self:GetNW2Float(key, value))
end

function ENTITY:SetDAMFloat(key, value)
	if not IsValid(self) then return end
	if self:GetDAMFloat(key) ~= value or value == 0 then
		self:SetNW2Float(key, tonumber(value))
	elseif DAMDEBUGENTITY then
		c["float"] = c["float"] or 0
		c["float"] = c["float"] + 1
	end
end

-- INT
function ENTITY:GetDAMInt(key, value)
	if not IsValid(self) then return value or 0 end

	return tonumber(self:GetNW2Int(key, value))
end

function ENTITY:SetDAMInt(key, value)
	if not IsValid(self) then return end
	if self:GetDAMInt(key) ~= value or value == 0 then
		self:SetNW2Int(key, tonumber(value))
	elseif DAMDEBUGENTITY then
		c["int"] = c["int"] or 0
		c["int"] = c["int"] + 1
	end
end

-- STRING
function ENTITY:GetDAMString(key, value)
	if not IsValid(self) then return value or "" end

	return tostring(self:GetNW2String(key, value))
end

function ENTITY:SetDAMString(key, value)
	if not IsValid(self) then return end
	if self:GetDAMString(key) ~= value or value == "" then
		self:SetNW2String(key, tostring(value))
	elseif DAMDEBUGENTITY then
		c["string"] = c["string"] or 0
		c["string"] = c["string"] + 1
	end
end

-- Vector
function ENTITY:GetDAMVector(key, value)
	if not IsValid(self) then return value or Vector(0, 0, 0) end

	return self:GetNW2Vector(key, value)
end

function ENTITY:SetDAMVector(key, value)
	if not IsValid(self) then return end
	if self:GetDAMVector(key) ~= value or value == Vector(0, 0, 0) then
		self:SetNW2Vector(key, value)
	elseif DAMDEBUGENTITY then
		c["vector"] = c["vector"] or 0
		c["vector"] = c["vector"] + 1
	end
end

if DAMDEBUGENTITY then
	DAMDEBUGENTITY_V = DAMDEBUGENTITY_V or 0
	DAMDEBUGENTITY_V = DAMDEBUGENTITY_V + 1
	local v = DAMDEBUGENTITY_V
	local function ShowStatsLoop()
		if pTab then
			MsgC(Color(0, 255, 0), "######################################################################\n")
			MsgC(Color(0, 255, 0), "DAM - ENTITY:\n")
			PrintTable(c)
			MsgC(Color(0, 255, 0), "DAM - NW ENTITY:\n")
			PrintTable(DAM_NW)
			MsgC(Color(0, 255, 0), "DAM - NW2 ENTITY:\n")
			PrintTable(DAM_NW2)
		end

		if DAMDEBUGENTITY and v == DAMDEBUGENTITY_V then
			timer.Simple(2, ShowStatsLoop)
		end
	end

	ShowStatsLoop()
end

function DAMGetNWTable(intab, tabname, maxvalue, maxshow)
	local tab = {}
	for ityp, typ in pairs(intab) do
		local co = 0
		for name, value in SortedPairsByValue(typ, true) do
			if value > maxvalue then
				co = co + 1
				if co == 1 then
					tab[ityp] = {}
					--MsgC( Color( 255, 255, 0 ), ">>> [" .. tabname .. "-".. ityp .. "]\n")
				end

				tab[ityp][name] = value
				--MsgC( Color( 255, 255, 255 ), string.format( "%6d - %s\n", value, name ) )
				if co == maxshow then break end
			end
		end
	end

	return tab
end

if SERVER then
	util.AddNetworkString("dam_get_nwstats")
	net.Receive(
		"dam_get_nwstats",
		function(len, ply)
			if not DAMPlyHasPermission(ply, "dam_console") then return end
			local tabnw = DAMGetNWTable(DAM_NW, "NW", 10, 2)
			local tabnw2 = DAMGetNWTable(DAM_NW2, "NW2", 10, 2)
			local tabg = DAMGetNWTable(DAM_G, "G", 10, 2)
			net.Start("dam_get_nwstats")
			net.WriteTable(tabnw)
			net.WriteTable(tabnw2)
			net.WriteTable(tabg)
			net.Send(ply)
		end
	)
end