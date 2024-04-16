-- DAM SH Player
local Player = FindMetaTable("Player")
function Player:DAMName()
	if self.SteamName then
		return self:Name() .. "/" .. self:SteamName()
	else
		return self:Name()
	end
end

if Player.DAMGetUserGroup == nil then
	function Player:DAMGetUserGroup()
		return self:GetDAMString("DAMUserGroup", "NOT SET")
	end

	function Player:GetUserGroup()
		if self:DAMGetUserGroup() ~= "NOT SET" then
			return self:DAMGetUserGroup()
		else
			return self:GetDAMString("UserGroup", "NOT SET")
		end
	end
end

function Player:IsUserGroup(groupname)
	return self:GetDAMString("DAMUserGroup", "NOT SET") == string.lower(groupname)
end

function Player:IsSuperAdmin()
	return self:GetDAMBool("hassuperadminpowers", false)
end

function Player:IsAdmin()
	return self:GetDAMBool("hasadminpowers", false)
end

local function DAMSearchInFiles(fi)
	if string.EndsWith(fi, ".lua") and not string.find(fi, "_dam_", 1, true) and not string.find(fi, "lua/includes/extensions/player_auth.lua", 1, true) then
		local data = file.Read(fi, "GAME")
		local s1, e1 = string.find(data, ":SetDAMString(\"UserGroup\"", 1, true)
		local s2, e2 = string.find(data, ":SetDAMString( \"UserGroup\"", 1, true)
		local s3, e3 = string.find(data, ":SetUserGroup(", 1, true)
		if s1 then
			DAM_HR()
			DAM_MSG("Found NETWORK USERGROUP in:", Color(255, 0, 0))
			DAM_MSG(fi, Color(255, 0, 0))
			s1 = math.Clamp(s1 - 100, 0, string.len(data))
			e1 = math.Clamp(e1 + 100, 0, string.len(data))
			local res = string.sub(data, s1, e1)
			MsgC("[CODE START]" .. "\n" .. res .. "\n" .. "[CODE END]" .. "\n")
			DAM_HR()
		end

		if s2 then
			DAM_HR()
			DAM_MSG("Found NETWORK USERGROUP in:", Color(255, 0, 0))
			DAM_MSG(fi, Color(255, 0, 0))
			s2 = math.Clamp(s2 - 100, 0, string.len(data))
			e2 = math.Clamp(e2 + 100, 0, string.len(data))
			local res = string.sub(data, s2, e2)
			MsgC("[CODE START]" .. "\n" .. res .. "\n" .. "[CODE END]" .. "\n")
			DAM_HR()
		end

		if s3 then
			DAM_HR()
			DAM_MSG("Found SETUSERGROUP in:", Color(255, 0, 0))
			DAM_MSG(fi, Color(255, 0, 0))
			s3 = math.Clamp(s3 - 100, 0, string.len(data))
			e3 = math.Clamp(e3 + 100, 0, string.len(data))
			local res = string.sub(data, s3, e3)
			MsgC("[CODE START]" .. "\n" .. res .. "\n" .. "[CODE END]" .. "\n")
			DAM_HR()
		end
	end
end

local function DAMSearchInFolders(path)
	local files, directories = file.Find(path .. "/" .. "*", "GAME", false)
	for i, v in pairs(directories) do
		if file.IsDir(path .. "/" .. v, "GAME") then
			DAMSearchInFolders(path .. "/" .. v)
		end
	end

	for i, v in pairs(files) do
		DAMSearchInFiles(path .. "/" .. v)
	end
end

local searched = false
local function DAMSearchForBackdoor()
	if not searched then
		searched = true
		DAM_HR()
		DAM_MSG("Search For UserGroup Backdoors", Color(0, 255, 0))
		DAMSearchInFolders("lua")
		DAM_HR()
	end
end

local damfoundproblem1 = false
local damfoundproblem2 = false
local damgetug = Player.DAMGetUserGroup
local function DAMCheckGetUserGroup()
	if damgetug ~= Player.DAMGetUserGroup then
		DAM_ERR("DAMGetUserGroup was overwritten, by another addon!", Color(255, 0, 0))
	end

	for i, ply in pairs(player.GetAll()) do
		if not ply:IsBot() and ply:DAMGetUserGroup() ~= "NOTSET" then
			if ply:GetUserGroup() ~= ply:DAMGetUserGroup() and not damfoundproblem1 then
				damfoundproblem1 = true
				timer.Simple(
					6,
					function()
						if ply:GetUserGroup() ~= ply:DAMGetUserGroup() then
							DAM_HR()
							DAM_ERR("Player UserGroup was overwritten, by another addon! #1", Color(255, 0, 0))
							DAM_ERR("ply:GetUserGroup(): " .. ply:GetUserGroup(), Color(255, 0, 0))
							DAM_ERR("ply:DAMGetUserGroup(): " .. ply:DAMGetUserGroup(), Color(255, 0, 0))
							DAM_HR()
							DAMSearchForBackdoor()
							timer.Simple(
								4,
								function()
									damfoundproblem1 = false
								end
							)
						end
					end
				)
			elseif ply:GetUserGroup() ~= ply:GetDAMString("UserGroup") and not damfoundproblem2 then
				damfoundproblem2 = true
				timer.Simple(
					6,
					function()
						if ply:GetUserGroup() ~= ply:GetDAMString("UserGroup") then
							DAM_HR()
							DAM_ERR("Player UserGroup was overwritten, by another addon! #2", Color(255, 0, 0))
							DAM_ERR("ply:GetUserGroup(): " .. ply:GetUserGroup(), Color(255, 0, 0))
							DAM_ERR("ply:GetDAMString(\"UserGroup\"): " .. ply:GetDAMString("UserGroup"), Color(255, 0, 0))
							DAM_HR()
							DAMSearchForBackdoor()
							timer.Simple(
								4,
								function()
									damfoundproblem2 = false
								end
							)
						end
					end
				)
			end
		end
	end

	timer.Simple(1, DAMCheckGetUserGroup)
end

DAMCheckGetUserGroup()
-- CAMI
if CAMI then
	hook.Remove("CAMI.PlayerHasAccess", "DAM.CAMI.PlayerHasAccess")
	hook.Add(
		"CAMI.PlayerHasAccess",
		"DAM.CAMI.PlayerHasAccess",
		function(ply, privilege, callback, target)
			callback(ply:GetDAMBool(privilege, false))

			return ply:GetDAMBool(privilege, false)
		end
	)
end