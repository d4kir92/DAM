-- CL DAM Settings
local palette = {}
function DAMCP()
	if DAMClientData and DAMClientData.curpalette then return DAMClientData.curpalette end

	return "dark"
end

function DAMGetColor(key)
	if palette and DAMCP() and palette[DAMCP()] and palette[DAMCP()][key] then
		local color = palette[DAMCP()][key]

		return Color(color.r, color.g, color.b)
	end

	return Color(255, 0, 0)
end

function DAMAColor()
	if DAMClientData and DAMClientData.acolor then
		local color = DAMClientData.acolor

		return Color(color.r, color.g, color.b)
	end

	return Color(255, 0, 0)
end

local function DAMAddPalette(name, ligh, navi, nav2, back, text, tex2)
	palette[name] = {}
	palette[name]["ligh"] = ligh
	palette[name]["navi"] = navi
	palette[name]["nav2"] = nav2
	palette[name]["back"] = back
	palette[name]["text"] = text -- text background
	palette[name]["tex2"] = tex2 -- text navi
end

DAMAddPalette("dark", Color(96, 116, 139), Color(52, 73, 94), Color(9, 34, 52), Color(9, 34, 52), Color(255, 255, 255), Color(255, 255, 255))
DAMAddPalette("evendarker", Color(48, 48, 48), Color(30, 30, 30), Color(0, 0, 0), Color(0, 0, 0), Color(255, 255, 255), Color(255, 255, 255))
DAMAddPalette("light", Color(255, 255, 255), Color(236, 240, 241), Color(186, 190, 190), Color(186, 190, 190), Color(0, 0, 0), Color(0, 0, 0))
DAMAddPalette("lightgray", Color(174, 188, 189), Color(127, 140, 141), Color(83, 95, 96), Color(83, 95, 96), Color(255, 255, 255), Color(255, 255, 255))
DAMAddPalette("lightblue", Color(204, 204, 204), Color(75, 123, 236), Color(0, 80, 185), Color(255, 255, 255), Color(0, 0, 0), Color(255, 255, 255))
DAMAddPalette("darkblue", Color(96, 116, 139), Color(75, 123, 236), Color(0, 80, 185), Color(9, 34, 52), Color(255, 255, 255), Color(255, 255, 255))
DAMAddPalette("lightred", Color(204, 204, 204), Color(231, 76, 60), Color(174, 12, 19), Color(255, 255, 255), Color(0, 0, 0), Color(255, 255, 255))
DAMAddPalette("darkred", Color(96, 116, 139), Color(231, 76, 60), Color(174, 12, 19), Color(9, 34, 52), Color(255, 255, 255), Color(255, 255, 255))
DAMAddPalette("lightgreen", Color(204, 204, 204), Color(38, 222, 129), Color(0, 171, 83), Color(255, 255, 255), Color(0, 0, 0), Color(0, 0, 0))
DAMAddPalette("darkgreen", Color(96, 116, 139), Color(38, 222, 129), Color(0, 171, 83), Color(9, 34, 52), Color(255, 255, 255), Color(255, 255, 255))
function DAMUpdatePalette()
	if DAMClientData and DAMClientData.curpalette then
		if palette[DAMClientData.curpalette] then
		else -- all good
			DAMClientData.curpalette = DAMDefaultData.curpalette
			DAMSaveClientSettings()
		end
	end
end

function DAMOpenSettings(content)
	local lang = DAMAddElement("DPanel", content, 200, 32, TOP)
	function lang:Paint(pw, ph)
		draw.SimpleText("Language", "DAM_30", pw / 2, ph / 2, DAMGetColor("text"), 1, 1)
	end

	local l_tab = {
		["de"] = "German",
		["en"] = "English",
		["ru"] = "Russian",
	}

	local gamelang = string.lower(GetConVar("gmod_language"):GetString())
	local langs = DAMAddElement("DComboBox", content, 200, 32, TOP)
	for key, value in SortedPairs(l_tab) do
		langs:AddChoice(value, key, key == gamelang, "materials/dam/" .. key .. ".png")
	end

	if not langs:GetSelected() then
		langs:ChooseOption("English", "en")
	end

	function langs:OnSelect()
		local _, data = langs:GetSelected()
		DAM_ChangeLanguage(data)
	end

	local uicolor = DAMAddElement("DPanel", content, 200, 32, TOP)
	function uicolor:Paint(pw, ph)
		draw.SimpleText(DAMGT("palette"), "DAM_30", pw / 2, ph / 2, DAMGetColor("text"), 1, 1)
	end

	local uicolors = DAMAddElement("DComboBox", content, 200, 32, TOP)
	for key, value in SortedPairs(palette) do
		uicolors:AddChoice(DAMGT(key), key, key == DAMClientData.curpalette) --, "icon16/bug.png" )
	end

	if not uicolors:GetSelected() then
		uicolors:ChooseOption("Dark", "dark")
	end

	function uicolors:OnSelect()
		local _, data = uicolors:GetSelected()
		DAMClientData.curpalette = data
		DAMSaveClientSettings()
		DAMUpdatePalette()
	end

	local acolor = DAMAddElement("DPanel", content, 200, 32, TOP)
	function acolor:Paint(pw, ph)
		draw.SimpleText(DAMGT("acolor"), "DAM_30", pw / 2, ph / 2, DAMGetColor("text"), 1, 1)
	end

	local acolorpicker = DAMAddElement("DColorMixer", content, 200, 200, FILL)
	acolorpicker:SetColor(DAMClientData.acolor)
	acolorpicker:DockMargin(10, 10, 10, 10)
	function acolorpicker:ValueChanged(col)
		DAMClientData.acolor = col
		DAMSaveClientSettings()
	end
end