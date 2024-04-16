-- CL Commands
function DAMOpenCommands(content)
	local cmdsh = DAMAddElement("DPanel", content, 200, 32, TOP)
	function cmdsh:Paint(pw, ph)
		draw.SimpleText("Commands", "DAM_30", pw / 2, ph / 2, DAMGetColor("text"), 1, 1)
	end

	local cmdsline = DAMAddElement("DPanel", content, 200, 32, TOP)
	cmdsline:DockMargin(0, 0, 0, 4)
	function cmdsline:Paint(pw, ph)
	end

	--
	local cmdsadd = DAMAddElement("DButton", cmdsline, 240, 32, LEFT)
	cmdsadd:DockMargin(0, 0, 4, 0)
	cmdsadd:SetText(DAMGT("addcommand"))
	function cmdsadd:DoClick()
		local cmdaddwin = DAMAddElement("DFrame", nil, 200, 32, NODOCK)
		cmdaddwin:SetSize(400, 400)
		function cmdaddwin:Paint(pw, ph)
			Derma_DrawBackgroundBlur(self, self.startTime)
			draw.RoundedBox(0, 0, 0, pw, ph, DAMGetColor("navi"))
			draw.SimpleText(DAMGT("addcommand"), "DAM_24", 48 / 4, 48 / 2, DAMGetColor("text"), 0, 1)
		end

		local cmdaddnameh = DAMAddElement("DLabel", cmdaddwin, 200, 32, TOP)
		cmdaddnameh:SetText(DAMGT("name"))
		local cmdaddname = DAMAddElement("DTextEntry", cmdaddwin, 200, 32, TOP)
		local cmdaddcontenth = DAMAddElement("DLabel", cmdaddwin, 200, 32, TOP)
		cmdaddcontenth:SetText(DAMGT("content"))
		local cmdaddcontent = DAMAddElement("DTextEntry", cmdaddwin, 200, 32, TOP)
		local cmdadd = DAMAddElement("DButton", cmdaddwin, 200, 32, TOP)
		cmdadd:DockMargin(0, 4, 0, 0)
		cmdadd:SetText(DAMGT("addcommand"))
		function cmdadd:DoClick()
			local name = cmdaddname:GetText()
			local contentAdd = cmdaddcontent:GetText()
			if name and contentAdd then
				net.Start("dam_cmds_add")
				net.WriteString(name)
				net.WriteString(contentAdd)
				net.SendToServer()
				if IsValid(cmdaddwin) then
					cmdaddwin:Remove()
				end
			end
		end
	end

	function cmdsadd:Paint(pw, ph)
		draw.RoundedBox(0, 0, 0, pw, ph, Color(0, 200, 0))
		if self:IsHovered() then
			draw.RoundedBox(0, 0, 0, pw, ph, Color(255, 255, 255, 100))
		end

		draw.SimpleText(self:GetText(), "DAM_24", pw / 2, ph / 2, DAMGetColor("text"), 1, 1)
	end

	local cmdsl = DAMAddElement("DListView", content, 32, 32, FILL)
	cmdsl:SetMultiSelect(false)
	cmdsl:AddColumn(DAMGT("name"))
	cmdsl:AddColumn(DAMGT("content"))
	local cmdsrem = DAMAddElement("DButton", cmdsline, 240, 32, LEFT)
	cmdsrem:SetText(DAMGT("removecommand"))
	function cmdsrem:DoClick()
		local _, line = cmdsl:GetSelectedLine()
		if line then
			local name = line:GetColumnText(1)
			if name then
				net.Start("dam_cmds_rem")
				net.WriteString(name)
				net.SendToServer()
			end
		end
	end

	function cmdsrem:Paint(pw, ph)
		local line = cmdsl:GetSelectedLine()
		if line then
			draw.RoundedBox(0, 0, 0, pw, ph, Color(200, 0, 0))
			if self:IsHovered() then
				draw.RoundedBox(0, 0, 0, pw, ph, Color(255, 255, 255, 100))
			end

			draw.SimpleText(self:GetText(), "DAM_24", pw / 2, ph / 2, DAMGetColor("text"), 1, 1)
		end
	end

	net.Receive(
		"dam_cmds_clear",
		function()
			if IsValid(cmdsl) then
				cmdsl:Clear()
			end
		end
	)

	net.Receive(
		"dam_cmds_getall",
		function()
			local name = net.ReadString()
			local cont = net.ReadString()
			if IsValid(cmdsl) then
				cmdsl:AddLine(name, cont)
			end
		end
	)

	net.Start("dam_cmds_getall")
	net.SendToServer()
end

net.Receive(
	"dam_model_open",
	function()
		local pl = net.ReadEntity()
		if IsValid(pl) then
			local win = DAMAddElement("DFrame", nil, ScrH(), ScrH(), NODOCK)
			win:SetTitle("Set Model for: " .. pl:DAMName())
			win.Search = DAMAddElement("DTextEntry", win, ScrH(), 30, TOP)
			win.Search:SetPlaceholderText("Search for a model")
			local function DAMModelUpdateList()
				if IsValid(win.List) then
					win.List:Clear()
					local x = 0
					local y = 0
					local count = 0
					local id = 0
					local size = (ScrH() - 24) / 3
					local searchtext = string.lower(win.Search:GetText())
					for i, model in pairs(player_manager.AllValidModels()) do
						if string.find(string.lower(model), searchtext, 1, true) or string.find(string.lower(i), searchtext, 1, true) then
							count = count + 1
							timer.Simple(
								count * 0.11,
								function()
									if IsValid(win) and IsValid(win.List) and searchtext == string.lower(win.Search:GetText()) then
										if x == 0 then
											win.List[y] = DAMAddElement("DPanel", win.List, size, size, TOP)
											win.List[y].Paint = function(self, pw, ph) end --
										end

										if IsValid(win.List[y]) then
											win.List[y].mdl = DAMAddElement("DModelPanel", win.List[y], size, size, LEFT)
											win.List[y].mdl:SetModel(model)
											win.List[y].btn = DAMAddElement("DModelPanel", win.List[y].mdl, size, size, FILL)
											win.List[y].btn.id = id
											win.List[y].btn.Paint = function(self, pw, ph)
												draw.SimpleText("[" .. self.id .. "] " .. i, "DAM_24", pw / 2, ph * 0.1, DAMGetColor("text"), 1, 1)
												draw.SimpleText(model, "DAM_24", pw / 2, ph * 0.9, DAMGetColor("text"), 1, 1)
											end

											win.List[y].btn.DoClick = function(self, pw, ph)
												net.Start("dam_model_open")
												net.WriteEntity(pl)
												net.WriteString(model)
												net.SendToServer()
												win:Remove()
											end

											x = x + 1
											if x * size + 100 >= win:GetWide() then
												y = y + 1
												x = 0
											end

											id = id + 1
										end
									end
								end
							)
						end
					end
				end
			end

			function win.Maxim.PostDoClick()
				DAMModelUpdateList()
			end

			function win.Search:OnChange()
				DAMModelUpdateList()
			end

			win.List = DAMAddElement("DScrollPanel", win, ScrH(), 200, FILL)
			DAMModelUpdateList()
		end
	end
)

net.Receive(
	"dam_vote_ended",
	function()
		local question = net.ReadString()
		local answer = net.ReadString()
		chat.AddText(Color(0, 255, 0), question)
		chat.AddText(Color(0, 255, 0), answer)
	end
)

net.Receive(
	"dam_vote_start",
	function()
		local question = net.ReadString()
		local answers = net.ReadTable()
		local win = DAMAddElement("DFrame", nil, 700, 140, NODOCK, true)
		win:SetTitle("")
		win:SetPos(ScrW() / 2 - 700 / 2, 0)
		win.big = false
		win.more = DAMAddElement("DButton", win, 700, 40, BOTTOM)
		win.more:SetText(DAMGT("showmore"))
		function win.more:DoClick()
			if not win.big then
				win:SetTall(400)
				win.more:SetText(DAMGT("showless"))
			else
				win:SetTall(140)
				win.more:SetText(DAMGT("showmore"))
			end

			win.big = not win.big
		end

		local duration = DAMAddElement("DButton", win, 200, 40, TOP)
		duration.cur = 0
		function duration:Paint(pw, ph)
			local plc = 0
			local plm = 0
			for i, pl in pairs(player.GetAll()) do
				plm = plm + 1
				if pl:GetDAMInt("dam_vote_answer", -1) ~= -1 then
					plc = plc + 1
				end
			end

			win:SetTitle(DAMGT("vote") .. ": " .. question .. " (" .. plc .. "/" .. plm .. " " .. DAMGT("players") .. ")")
			local tssta = GetGlobalInt("dam_vote_ts_start", 1)
			local tscur = GetGlobalInt("dam_ts", 1)
			local tsend = GetGlobalInt("dam_vote_ts_end", 1)
			local cur = math.Round(tsend - tscur, 1)
			local max = math.Round(tsend - tssta, 1)
			if cur <= 0 then
				win:Remove()
			end

			self.cur = Lerp(FrameTime() * 8, self.cur, cur)
			self.tcur = math.Round(self.cur, 0)
			draw.RoundedBox(0, 0, 0, pw, ph, DAMGetColor("ligh"))
			draw.RoundedBox(0, 0, 0, pw * self.cur / max, ph, DAMAColor())
			draw.SimpleText(DAMGT("time"), "DAM_24", ph / 2, ph / 2, DAMGetColor("text"), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
			draw.SimpleText(self.tcur, "DAM_24", pw - ph / 2, ph / 2, DAMGetColor("text"), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
		end

		win.answers = DAMAddElement("DScrollPanel", win, 200, 200, FILL)
		win.answers:DockMargin(0, 4, 0, 4)
		function win.answers:Paint(pw, ph)
			draw.RoundedBox(0, 0, 0, pw, ph, DAMGetColor("back"))
		end

		function win.answers:UpdateList()
			win.answers:Clear()
			local id = 0
			for i, v in pairs(answers) do
				id = id + 1
				local answer = DAMAddElement("DButton", win.answers, 200, 40, TOP)
				answer.id = id
				function answer:Paint(pw, ph)
					local cur = 0
					local max = 0
					for x, pl in pairs(player.GetAll()) do
						if pl:GetDAMInt("dam_vote_answer", -1) == self.id then
							cur = cur + 1
						end

						if pl:GetDAMInt("dam_vote_answer", -1) ~= -1 then
							max = max + 1
						end
					end

					max = math.Clamp(max, 1, 128)
					draw.RoundedBox(0, 0, 0, pw, ph, DAMGetColor("ligh"))
					draw.RoundedBox(0, 0, 0, pw * cur / max, ph, DAMAColor())
					draw.SimpleText(self.text, "DAM_24", ph / 2, ph / 2, DAMGetColor("text"), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
					draw.SimpleText(cur .. "/" .. max .. " (" .. math.Round(cur / max * 100, 0) .. "%)", "DAM_24", pw - ph / 2, ph / 2, DAMGetColor("text"), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
				end

				function answer:DoClick()
					net.Start("dam_vote_select")
					net.WriteInt(self.id, 6)
					net.SendToServer()
				end

				answer:DockMargin(4, 4, 4, 0)
				answer:SetText(v)
			end
		end

		win.answers:UpdateList()
	end
)

net.Receive(
	"dam_vote_add",
	function()
		local answers = {"", "",}
		local win = DAMAddElement("DFrame", nil, 700, 700, NODOCK)
		win:SetTitle(DAMGT("vote"))
		win.questionh = DAMAddElement("DLabel", win, 200, 40, TOP)
		win.questionh:SetText(DAMGT("question"))
		win.question = DAMAddElement("DTextEntry", win, 200, 40, TOP)
		win.vote = DAMAddElement("DButton", win, 200, 40, BOTTOM)
		win.vote:SetText(DAMGT("startvote"))
		function win.vote:DoClick()
			win:Remove()
			net.Start("dam_vote_add")
			net.WriteString(win.question:GetText())
			net.WriteString(win.duration:GetValue())
			net.WriteTable(answers)
			net.SendToServer()
		end

		win.duration = DAMAddElement("DNumberWang", win, 200, 40, BOTTOM)
		win.duration:DockMargin(0, 0, 0, 4)
		win.duration:SetValue(60)
		win.duration:SetMin(10)
		win.duration:SetMax(60 * 60)
		win.durationh = DAMAddElement("DLabel", win, 200, 40, BOTTOM)
		win.durationh:SetText(DAMGT("duration"))
		win.durationh:DockMargin(0, 4, 0, 0)
		win.answers = DAMAddElement("DScrollPanel", win, 200, 200, FILL)
		win.answers:DockMargin(0, 4, 0, 4)
		function win.answers:Paint(pw, ph)
			draw.RoundedBox(0, 0, 0, pw, ph, DAMGetColor("back"))
		end

		function win.answers:UpdateList()
			win.answers:Clear()
			local id = 0
			for i, v in pairs(answers) do
				id = id + 1
				local answerh = DAMAddElement("DLabel", win.answers, 200, 40, TOP)
				answerh:SetText(DAMGT("answer") .. " " .. id)
				local answer = DAMAddElement("DTextEntry", win.answers, 200, 40, TOP)
				function answer:OnChange()
					answers[i] = self:GetText()
				end

				answer:SetText(v)
			end

			if id < 10 then
				local addanswer = DAMAddElement("DButton", win.answers, 200, 40, TOP)
				addanswer:DockMargin(0, 4, 0, 0)
				addanswer:SetText(DAMGT("add"))
				function addanswer:DoClick()
					table.insert(answers, "")
					win.answers:UpdateList()
				end
			end
		end

		win.answers:UpdateList()
	end
)