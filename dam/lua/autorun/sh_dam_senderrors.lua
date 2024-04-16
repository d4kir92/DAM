-- ERROR COLLECT
-- CONFIG
local filename = "dam/dam_errors.json"
local deleteafter = 60 * 60 * 24
local url_cl = "https://docs.google.com/forms/u/0/d/e/1FAIpQLSdpDXnmrvp5iItVODt4EJu-kEm-w8WYULEa85-ZyW03MnCKTw/formResponse"
local url_sv = "https://docs.google.com/forms/u/0/d/e/1FAIpQLSeCBNEnzprx2UmJ3UIi2h_vj2ylNwzhkpl_i1xvK3KqWdiCPg/formResponse"
-- CONFIG
local function DAMErrorMSG(msg, color)
	color = color or Color(255, 0, 0)
	MsgC(color, "[COLLECT-ERRORS] " .. msg .. "\n")
end

local DAMErrors = {}
local function DAMCheckErrorFile()
	if not file.Exists("dam", "DATA") then
		file.CreateDir("dam")
	end

	if not file.Exists(filename, "DATA") then
		local tab = {}
		file.Write(filename, util.TableToJSON(tab, true))
	end

	DAMErrors = util.JSONToTable(file.Read(filename, "DATA"))
end

DAMCheckErrorFile()
function DAMNewError(error)
	DAMCheckErrorFile()
	for i, v in pairs(DAMErrors) do
		if v.error and v.error == err then return false end
	end

	return true
end

local function DAMSaveErrors()
	if DAMErrors ~= nil then
		DAMErrorMSG("Saved Errors", Color(0, 255, 0))
		file.Write(filename, util.TableToJSON(DAMErrors, true))
	else
		DAMErrorMSG("Failed to save Errors")
		DAMCheckErrorFile()
		timer.Simple(0.1, DAMSaveErrors)
	end
end

local function DAMSendError(tab, from)
	local entry = {}
	local posturl = ""
	if tab.version ~= DAMVERSION then
		MsgC(Color(255, 0, 0), ">>> [DAMSendError] FAIL, ERROR IS OUTDATED" .. "\n")
		DAMRemoveOutdatedErrors()

		return
	end

	if tab.realm == "SERVER" then
		-- err
		entry["entry.15092053"] = tostring(tab.error)
		-- trace
		entry["entry.1100087360"] = tostring(tab.trace)
		-- ts
		entry["entry.793417475"] = tostring(tab.ts)
		-- realm
		entry["entry.1691073207"] = tostring(tab.realm)
		-- version
		entry["entry.1170309832"] = tostring(DAMVERSION)
		posturl = url_sv
	elseif tab.realm == "CLIENT" then
		-- err
		entry["entry.1358830945"] = tostring(tab.error)
		-- trace
		entry["entry.77270352"] = tostring(tab.trace)
		-- ts
		entry["entry.1127154342"] = tostring(tab.ts)
		-- realm
		entry["entry.1795109154"] = tostring(tab.realm)
		-- version
		entry["entry.987438708"] = tostring(DAMVERSION)
		posturl = url_cl
	else
		MsgC(Color(255, 0, 0), ">>> [DAMSendError] FAIL! >> Realm: " .. tostring(tab.realm) .. "\n")

		return
	end

	if DAMVERSION == DAMVERSIONONLINE then
		--MsgC(  Color( 255, 0, 0 ), "[DAMSendError] [" .. tostring(from) .. "] >> " .. tostring(tab.error) .. "\n" )
		http.Post(
			posturl,
			entry,
			function(body, length, headers, code)
				if code == 200 then
					-- worked
					tab.sended = true
					DAMSaveErrors()
				else
					DAM.msg("error", "[DAMSendError] failed: " .. "HTTP " .. tostring(code))
				end
			end,
			function(failed)
				DAMErrorMSG("[DAMSendError] failed: " .. tostring(failed))
			end
		)
	else
		MsgC(Color(255, 0, 0), "[DAMSendError] >> DAM Is Outdated" .. "\n")
	end
end

function DAMRemoveOutdatedErrors()
	if DAMErrors then
		local TMPDAMErrors = {}
		local changed = false
		for i, v in pairs(DAMErrors) do
			if v.version == nil then
				v.version = 0
				changed = true
			end

			if v.ts and os.time() - v.ts < deleteafter and v.version == DAMVERSION then
				table.insert(TMPDAMErrors, v)
			else
				changed = true
			end

			if not v.sended then
				timer.Simple(
					10 * i,
					function()
						DAMSendError(v, "Was not sended")
					end
				)
			end
		end

		if changed then
			DAMErrorMSG("Found Outdated Errors", Color(0, 255, 0))
			DAMErrors = TMPDAMErrors
			DAMSaveErrors()
		end
	else
		DAMErrorMSG("Failed to remove outdated errors")
		timer.Simple(0.01, DAMRemoveOutdatedErrors)
	end
end

timer.Simple(0.1, DAMRemoveOutdatedErrors)
function DAMAddError(error, trace, realm)
	local newErr = {}
	newErr.error = err
	newErr.trace = trace
	newErr.trace = newErr.trace .. "\n" .. "err: /dam/ " .. tostring(string.find(error, "/dam/", 1, true)) .. "      trace: /dam/ " .. tostring(string.find(trace, "/dam/", 1, true)) .. "      trace: DAM " .. tostring(string.find(trace, "DAM - ", 1, true))
	newErr.trace = newErr.trace .. "\n" .. "IP: " .. GetGlobalString("serverip", "0.0.0.0:27015")
	newErr.ts = os.time()
	newErr.realm = realm
	newErr.sended = false
	newErr.version = DAMVERSION
	table.insert(DAMErrors, newErr)
	DAMSendError(newErr, "NEW ERROR")
	DAMSaveErrors()
end

function DAMAddLuaErrorHook()
	hook.Remove("OnLuaError", "yrp_OnLuaError")
	hook.Add(
		"OnLuaError",
		"DAM_OnLuaError",
		function(error, realm, stack, name, id)
			if game.SinglePlayer() then return end
			local newtrace = {}
			for i, w in pairs(stack) do
				local v = w.File .. ":" .. w.Line
				if not string.find(v, "stack traceback:", 1, true) and not string.find(v, "lua/autorun/sh_d4_senderrors.lua", 1, true) then
					table.insert(newtrace, v)
				end
			end

			trace = table.concat(newtrace, "\n")
			trace = string.Replace(trace, "\t", "")
			local isId = false
			if id ~= nil and id == 2647674457 then
				isId = true
			end

			if err and trace and realm and not string.find(trace, "addons/dam/lua/autorun/sh_dam_main.lua:528", 1, true) and ((string.find(error, "/dam/", 1, true) or string.find(trace, "DAM - ", 1, true)) or isId) and DAMNewError(error, id) then
				MsgC(Color(255, 0, 0), "[DAMAddError] >> Found a new ERROR" .. "\n")
				DAMAddError(error, trace, realm)
			end
		end
	)

	MsgC(Color(0, 255, 0), "[DAM][OnLuaError] LOADED" .. "\n")
end

DAMAddLuaErrorHook()