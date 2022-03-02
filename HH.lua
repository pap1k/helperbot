script_name('HH')
script_author('papercut')
script_version(2.2)

local sampev = require 'lib.samp.events'
local imgui = require 'imgui'
local imadd = require 'imgui_addons'
encoding = require 'encoding'
encoding.default = 'CP1251' 
u8 = encoding.UTF8

mojno = false
faid = -1
fa = false
local counter = {}
local playerid = -1
local abase = {}
local loaded = true
local isact = false
local settings = {}
local fansw = ""
local VERSION = "Версия 2.2 - (stable)"
local prefix = "{e9ab4f}[HH]{5fdbea} "

local rx, ry = getScreenResolution()
local wx, wy = 500, 500
local hhmenu = imgui.ImBool(false)
local mine = imgui.ImBuffer(500)
mine.v = u8'Функцию быстрого ответа буду разблокировать только тем,\nв ком уверен, что не будут нбивать.\n\nА так пользуйтесь как подсказной. Ну или можете вскрыть код\nи в нем найти адрес переменной, ограничивающей\nдоступ к быстрому ответу и править ее.'
local BtnAnswId = imgui.ImBool(false)
local BtnFast = imgui.ImBool(false)
local BtnColor = imgui.ImBool(false)
local BtnFastCmd = imgui.ImBool(false)
local BtnFastInfo = imgui.ImBool(false)

function apply_custom_style()
	imgui.SwitchContext()
	local style = imgui.GetStyle()
	local colors = style.Colors
	local clr = imgui.Col
	local ImVec4 = imgui.ImVec4
	local ImVec2 = imgui.ImVec2

	style.WindowPadding = ImVec2(15, 15)
	style.WindowRounding = 6.0
	style.FramePadding = ImVec2(5, 5)
	style.FrameRounding = 4.0
	style.ItemSpacing = ImVec2(12, 8)
	style.ItemInnerSpacing = ImVec2(8, 6)
	style.IndentSpacing = 25.0
	style.ScrollbarSize = 15.0
	style.ScrollbarRounding = 9.0
	style.GrabMinSize = 5.0
	style.GrabRounding = 3.0

	colors[clr.Text] = ImVec4(0.80, 0.80, 0.83, 1.00)
	colors[clr.TextDisabled] = ImVec4(0.24, 0.23, 0.29, 1.00)
	colors[clr.WindowBg] = ImVec4(0.06, 0.05, 0.07, 1.00)
	colors[clr.ChildWindowBg] = ImVec4(0.07, 0.07, 0.09, 1.00)
	colors[clr.PopupBg] = ImVec4(0.07, 0.07, 0.09, 1.00)
	colors[clr.Border] = ImVec4(0.80, 0.80, 0.83, 0.88)
	colors[clr.BorderShadow] = ImVec4(0.92, 0.91, 0.88, 0.00)
	colors[clr.FrameBg] = ImVec4(0.10, 0.09, 0.12, 1.00)
	colors[clr.FrameBgHovered] = ImVec4(0.24, 0.23, 0.29, 1.00)
	colors[clr.FrameBgActive] = ImVec4(0.56, 0.56, 0.58, 1.00)
	colors[clr.TitleBg] = ImVec4(0.76, 0.31, 0.00, 1.00)
	colors[clr.TitleBgCollapsed] = ImVec4(1.00, 0.98, 0.95, 0.75)
	colors[clr.TitleBgActive] = ImVec4(0.80, 0.33, 0.00, 1.00)
	colors[clr.MenuBarBg] = ImVec4(0.10, 0.09, 0.12, 1.00)
	colors[clr.ScrollbarBg] = ImVec4(0.10, 0.09, 0.12, 1.00)
	colors[clr.ScrollbarGrab] = ImVec4(0.80, 0.80, 0.83, 0.31)
	colors[clr.ScrollbarGrabHovered] = ImVec4(0.56, 0.56, 0.58, 1.00)
	colors[clr.ScrollbarGrabActive] = ImVec4(0.06, 0.05, 0.07, 1.00)
	colors[clr.ComboBg] = ImVec4(0.19, 0.18, 0.21, 1.00)
	colors[clr.CheckMark] = ImVec4(1.00, 0.42, 0.00, 0.53)
	colors[clr.SliderGrab] = ImVec4(1.00, 0.42, 0.00, 0.53)
	colors[clr.SliderGrabActive] = ImVec4(1.00, 0.42, 0.00, 1.00)
	colors[clr.Button] = ImVec4(0.10, 0.09, 0.12, 1.00)
	colors[clr.ButtonHovered] = ImVec4(0.24, 0.23, 0.29, 1.00)
	colors[clr.ButtonActive] = ImVec4(0.56, 0.56, 0.58, 1.00)
	colors[clr.Header] = ImVec4(0.10, 0.09, 0.12, 1.00)
	colors[clr.HeaderHovered] = ImVec4(0.56, 0.56, 0.58, 1.00)
	colors[clr.HeaderActive] = ImVec4(0.06, 0.05, 0.07, 1.00)
	colors[clr.ResizeGrip] = ImVec4(0.00, 0.00, 0.00, 0.00)
	colors[clr.ResizeGripHovered] = ImVec4(0.56, 0.56, 0.58, 1.00)
	colors[clr.ResizeGripActive] = ImVec4(0.06, 0.05, 0.07, 1.00)
	colors[clr.CloseButton] = ImVec4(0.40, 0.39, 0.38, 0.16)
	colors[clr.CloseButtonHovered] = ImVec4(0.40, 0.39, 0.38, 0.39)
	colors[clr.CloseButtonActive] = ImVec4(0.40, 0.39, 0.38, 1.00)
	colors[clr.PlotLines] = ImVec4(0.40, 0.39, 0.38, 0.63)
	colors[clr.PlotLinesHovered] = ImVec4(0.25, 1.00, 0.00, 1.00)
	colors[clr.PlotHistogram] = ImVec4(0.40, 0.39, 0.38, 0.63)
	colors[clr.PlotHistogramHovered] = ImVec4(0.25, 1.00, 0.00, 1.00)
	colors[clr.TextSelectedBg] = ImVec4(0.25, 1.00, 0.00, 0.43)
	colors[clr.ModalWindowDarkening] = ImVec4(1.00, 0.98, 0.95, 0.73)
end
apply_custom_style()

function imgui.OnDrawFrame()
	if hhmenu.v then
		imgui.SetNextWindowSize(imgui.ImVec2(wx, wy), imgui.Cond.FirstUseEver)
		imgui.SetNextWindowPos(imgui.ImVec2(rx/2-wx/2, ry/2-wy/2))
		
		imgui.Begin(u8'Helper`s Helper. | '..u8(VERSION), hhmenu, imgui.WindowFlags.NoResize)
			imgui.Text(u8'Да-да, тот самый, БОТ(нет) ПАПАНИСТЕРА!!!!!!!!!')
			imgui.Spacing()
			if imgui.CollapsingHeader(u8'Настройки:')then
				imgui.Text(u8'Использовать функцию ответа одной клавишей(бот).')
				imgui.SameLine()
				ShowHelpMarker(u8'Если в базе нашелся ответ, то при нажатии на определенную клавишу, скрипт сам ответит игроку ответом из базы.')
				if imadd.ToggleButton("UseFast", BtnFast) then
					settings.fastansw = BtnFast.v
					settingsreload(settings)
				end
				
				imgui.Text(u8'Использовать встроенную функцию /answ [id]')
				imgui.SameLine()
				ShowHelpMarker(u8'При нажатии на определенную клавишу откроется чат, где будет /answ [ID], где ID - ид последнего спросившего чего-либо игрока.')
				if imadd.ToggleButton("UseAnswId", BtnAnswId) then
					settings.answid = BtnAnswId.v
					settingsreload(settings)
				end
				
				imgui.Text(u8'Использовать перекраску чата')
				imgui.SameLine() 
				ShowHelpMarker(u8'Скрипт будет перекрашивать попросы и ответы, как многие уже видели. Не видели - попробуйте!')
				if imadd.ToggleButton("UseColor", BtnColor) then
					settings.color = BtnColor.v
					settingsreload(settings)
				end
				
				imgui.Text(u8'Использовать быстрые макросы')
				imgui.SameLine()
				ShowHelpMarker(u8'Если ввести просто /bps(без ID) или любой другой максорс, то скрипт автоматически направит этот ответ последнему спросившему что-либо.')
				if imadd.ToggleButton("UseFastCmd", BtnFastCmd) then
					settings.fastcmd = BtnFastCmd.v
					settingsreload(settings)
				end
				
				imgui.Text(u8'Получать быструю информацию о спросившем')
				imgui.SameLine()
				ShowHelpMarker(u8'Добавит в чат после вопроса строку с уровнем, цветом и страной проживания спросившего.')
				if imadd.ToggleButton("UseFastInfo", BtnFastInfo) then
					settings.fastinfo = BtnFastInfo.v
					settingsreload(settings)
				end
			end
			
			imgui.Separator()
			imgui.Spacing()
			if imgui.Button(u8'  Обновить') then update(true) end
			if imgui.Button(u8'  Поверить доступ к быстрому ответу') then
				lua_thread.create(allow)
			end
			imgui.Text(u8("Сейчас: ")) imgui.SameLine()
			if mojno then
				imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(19/255, 232/255, 63/255, 1.0))
					imgui.Text(u8("Есть доступ!"))
				imgui.PopStyleColor()
			else
				imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(232/255, 19/255, 19/255, 1.0))
					imgui.Text(u8("Нет доступа"))
				imgui.PopStyleColor()
			end
			imgui.Spacing() imgui.Spacing() imgui.Spacing()
			if imgui.CollapsingHeader(u8'Откровение:')then
				imgui.InputTextMultiline('##mine', mine, imgui.ImVec2(400, 110), imgui.InputTextFlags.ReadOnly)
			end
		imgui.End()
	end
end

function main()
    repeat wait(0) until isSampAvailable()
	if not doesDirectoryExist(getWorkingDirectory().."/answ_c") then
		createDirectory(getWorkingDirectory().."/answ_c")
	end
	if not doesFileExist(getWorkingDirectory().."\\answ_c\\base.json") then
		createFile()
	end
	sampAddChatMessage("{a02525}[A_C] {44eecc}Очистка базы - {41ff60}/ac.c{44eecc}, Сформировать отчет - {41ff60}/ac.r", 0x44eecc)
	sampRegisterChatCommand("ac.c", function()
		createFile()
		sampAddChatMessage("База очищена.", 0x44eecc)
	end)
	sampRegisterChatCommand("ac.r", function()
		local fopen = io.open(getWorkingDirectory().."\\answ_c\\base.json", "r")
		local data = decodeJson(fopen:read('*a'))
		local str = ""
		if data.helpers then
			for i = 1, #data.helpers do
				str = str..data.helpers[i].nick.." : "..data.helpers[i].count.."\n"
			end
		end
		io.close(fopen)
		
		local fname = os.date('[AC_report_for]_%Y-%m-%d_%H-%M-%S.txt', os.time())
		local fopen = io.open(getWorkingDirectory().."\\"..fname, "w")
		fopen:write(str)
		io.close(fopen)
		sampAddChatMessage("Отчет сформирован в {41ff60}"..fname, 0x44eecc)
	end)
	sampRegisterChatCommand('hh', function()
		hhmenu.v = not hhmenu.v
		imgui.Process = hhmenu.v
	end)
	sampAddChatMessage(prefix..' by {ee3142}papercut. {2dd282}'..VERSION..'. Меню - {2dd282}/hh', 0x5fdbea)
	isfirst()
	if not try() then
		sampAddChatMessage(prefix..' {ee3142}Обнаружена несовместимая с работой ошибка файла базы ответов.', 0x5fdbea)
		loaded = false
	end
	if not getsettings() then
		sampAddChatMessage(prefix..' {ee3142}Обнаружена несовместимая с работой ошибка файла настроек.', 0x5fdbea)
		loaded = false
	end
	lua_thread.create(update, false)
	lua_thread.create(allow)
	if loaded then
		while true do
			wait(0)
			if not hhmenu.v then imgui.Process = false end
		
			if wasKeyPressed(settings.answidbtn) and settings.answid then
				sampSetChatInputText("/answ "..playerid.." ")
				sampSetChatInputEnabled(true)
			end
			if wasKeyPressed(settings.fastanswbtn) and fa and settings.fastansw then
				if mojno then
					sampSendChat("/answ "..faid.." "..fansw)
					fa = false
					faid = -1
				else
					sampAddChatMessage(prefix..'Для тебя заблокирована функция быстрого ответа.', 0x5fdbea)
				end
			end
		end
	end
end

function sampev.onServerMessage(color, text)

	if isact and text:find('{F5DEB3}Имя: .* Телефон: .* Проживает в: .*') then
		local country = ''
			if text:find('{F5DEB3}Имя: .* Телефон: .* Проживает в: .*') then
				country = string.match(text, '{F5DEB3}Имя: {ffffff}.*{F5DEB3} Телефон: {ffffff}.*{F5DEB3} Проживает в: {ffffff}(%a+){F5DEB3}%.')
			end
		sampAddChatMessage("[INFO]: {"..dectohex(sampGetPlayerColor(id))..'}'..pname..', {e64c5a}'..sampGetPlayerScore(id)..'{5fdbea} LVL, {e64c5a}'..country, 0x5fdbea)
		isact = false
		return false
	end
	if isact and text:find('Телефонный справочник') then
		return false
	end
	if isact and text:find('не найден в телефонном справочнике') then
		sampAddChatMessage("[INFO]: {"..dectohex(sampGetPlayerColor(id))..'}'..pname..', {e64c5a}'..sampGetPlayerScore(id)..'{5fdbea} LVL, {e64c5a}Нет данных по стране проживания', 0x5fdbea)
		isact = false
		return false
	end

	if color == -5631489 then
		if text:find('%[H%].*: .*') then return end
		if text:find('Вопрос от .* ID .*:') then		
			if settings.color then sampAddChatMessage('[Q]{ffff52} '..text, 0xc10013)
			else sampAddChatMessage(text, 0xffaa11) end
			pname, id, q = string.match(text, 'Вопрос от (.*) ID (%d+): (.*)')
			if settings.fastinfo then
				isact = true
				sampSendChat("/num "..id)
			end
			playerid = id
			temp = fastansw(id, q)
			if temp ~= 'none' then
				fansw = temp
			end
			return false
		end
		if text:find('От .* для .*') then
			local from = text:match("От (.*) для .*: ")
			lua_thread.create(plus,try_remove_chatid(from))
			if settings.color then sampAddChatMessage('[A]{c78108} '..text, 0xc10013)
			else sampAddChatMessage(text, 0xffaa11) end
			return false
		end
	end
end

function createFile()
	local f = io.open(getWorkingDirectory().."\\answ_c\\base.json", "w")
	f:write('{"helpers" : [{"nick": "papercut", "count": 0}]}')
	io.close(f)
end


function count(nick, question)
	
end

function sampev.onSendCommand(cmd)
	if settings.fastcmd then
		if cmd == '/tf' then 
			sampSendChat('/tf '..playerid)
			return false
		end
		if cmd == '/geo' then 
			sampSendChat('/geo '..playerid)
			return false
		end
		if cmd == '/grup' then 
			sampSendChat('/grup '..playerid)
			return false
		end
		if cmd == '/fmgrup' then 
			sampSendChat('/fmgrup '..playerid)
			return false
		end
		if cmd == '/art' then 
			sampSendChat('/art '..playerid)
			return false
		end
		if cmd == '/rpg' then 
			sampSendChat('/rpg '..playerid)
			return false
		end
		if cmd == '/don' then 
			sampSendChat('/don '..playerid)
			return false
		end
		if cmd == '/fad' then 
			sampSendChat('/fad '..playerid)
			return false
		end
		if cmd == '/bsp' then 
			sampSendChat('/bsp '..playerid)
			return false
		end
		if cmd == '/qp' then 
			sampSendChat('/qp '..playerid)
			return false
		end
		if cmd == '/rec' then 
			sampSendChat('/rec '..playerid)
			return false
		end
		if cmd == '/tb' then 
			sampSendChat('/tb '..playerid)
			return false
		end
	end
end

function ShowHelpMarker(desc)
    if imgui.IsItemHovered() then
        imgui.BeginTooltip()
        imgui.PushTextWrapPos(imgui.GetFontSize() * 35.0)
        imgui.TextUnformatted(desc)
        imgui.PopTextWrapPos()
        imgui.EndTooltip()
    end
end 

function NEWcheckansw(str)
	local data = abase.base
	for i = 1,table.maxn(data) do
		for j = 1, table.maxn(data[i].q) do
		local s = u8:decode(data[i].q[j])
			if str:find(s) then
				if settings.info == '1' then  print('[HH::debug] i = '..i..', j = '..j..', trigger: '..s) end
				return data[i].a
			end
		end
	end	
	return 'none'
end

function isfirst()
	local f1 = getWorkingDirectory().."\\helper/settings.json"
	if not doesFileExist(f1) then
		createDirectory(getWorkingDirectory().."/helper/")
		local cs = {}
		cs.info = true
		cs.answidbtn = "104"
		cs.color = false
		cs.fastansw	= true
		cs.answid = true
		cs.fastanswbtn = "113"
		cs.fastcmd = true
		cs.fastinfo = true
		settingsreload(cs)
	end
	local f2 = getWorkingDirectory().."\\helper/base.json"
	if not doesFileExist(f2) then
		local str = "{\"ex\" : \"1\", \"base\":[{\"q\": [\"-keyword1-\", \"-keyword2-\"], \"a\":\"-answer-\"}]}"
		sampAddChatMessage(prefix..' {ee3142}Необходимо настроить базу. Поcле настройки поставить \"ex\" на \"0\".', 0x5fdbea)
		local fopen = io.open(f2, 'w')
		fopen:write(str)
		io.close(fopen)
	end
end

function getsettings()
	local fpath = getWorkingDirectory().."\\helper/settings.json"
	local s = io.open(fpath, 'r')
	if s then
		local set = decodeJson(s:read('*a'))
		if set then
			settings = set
			
			BtnAnswId.v = settings.answid
			BtnFast.v = settings.fastansw
			BtnColor.v = settings.color
			BtnFastCmd.v = settings.fastcmd
			return true
		else
			sampAddChatMessage("{e9ab4f}[HH] {ee3142}Ошибка{eb5244}: Не удается преобразовать файл настроек. Подробнее в консоли.", 0xeb5244)
			print(s)
			return false
		end
	else
		sampAddChatMessage('{e9ab4f}[HH] {ee3142}Ошибка{eb5244}: Не найден файл настроек.', 0x5fdbea)
		return false
	end
	io.close(s)
end

function plus(nick)
	local fpath = getWorkingDirectory().."\\answ_c\\base.json"
	local fopen = io.open(fpath, "r")
	local data = decodeJson(fopen:read('*a'))
	if data.helpers then
		local flag = true
		for i = 1, #data.helpers do
			if nick == data.helpers[i].nick then
				data.helpers[i].count = tonumber(data.helpers[i].count) + 1
				flag = false
			end
		end
		if flag then
			table.insert(data.helpers, {nick = nick, count = 1})
		end
	end
	io.close(fopen)
	fopen = io.open(fpath, "w")
	fopen:write(encodeJson(data))
	io.close(fopen)
end
function try_remove_chatid(str)
	if str:find("%[%d+%]") then
		local r, garbage = str:match("(.*)%[(.*)")
		return r
	end
	return str
end

function try()
	local fpath = getWorkingDirectory().."\\helper/base.json"
	local base = io.open(fpath, 'r')
	if base then
		local b = decodeJson(base:read('*a'))
		if b then
			if b.ex == "1" then
				sampAddChatMessage(prefix..' База ответов пустая. Необходимо ее заполнить.', 0x5fdbea)
			else
				abase = b
				local a = table.maxn(b.base)
				sampAddChatMessage(prefix..' База успешно загружена. Вопросов в базе: {e6dc22}'..a..'{5fdbea}. Скрипт готов к работе.', 0x5fdbea)
			end
		return true			
		else
			sampAddChatMessage("{e9ab4f}[HH]{ee3142}Ошибка{eb5244}: Не удается преобразовать файл базы. Подробнее в консоли.", 0xeb5244)
			print(b)
			return false
		end
	else
		sampAddChatMessage('{e9ab4f}[HH] {ee3142}Ошибка{eb5244}: Не найден файл базы ответов.', 0x5fdbea)
		return false
	end
	io.close(base)
end

function urlencode(str)
if (str) then      str = string.gsub (str, "\n", "\r\n")      str = string.gsub (str, "([^%w ])",         function (c) return string.format ("%%%02X", string.byte(c)) end)      str = string.gsub (str, " ", "+")   end   return str
end

function dectohex(num)
	local result = ""
	local hex = {}
	hex[10] = 'a' hex[11] = 'b' hex[12] = 'c' hex[13] = 'd' hex[14] = 'e' hex[15] = 'f'
	while math.floor(num / 16) > 0 do
		local tmp = num % 16
		if tmp > 9 then result = result..hex[tmp]
		else result = result..tostring(tmp) end
		num = math.floor(num / 16)
	end
	return result:sub(0, 6)
end

function fastansw(id, q)
local answ = u8:decode(NEWcheckansw(q))
	if answ ~= 'none' then
		sampAddChatMessage('Возможно, подойдет ответ {c10013}'..answ, 0x35b74a)
		lua_thread.create(function()
			wait(500)
			faid = id
			fa = true
		end)
	end
	return answ
end

function settingsreload(confing)
	local fpath = getWorkingDirectory().."\\helper/settings.json"
	local s = io.open(fpath, 'w')
	s:write(encodeJson(confing))
	io.close(s)
	getsettings()
	print(prefix..' Настройки обновлены.')
end

function getMyName()
	local result, myid = sampGetPlayerIdByCharHandle(PLAYER_PED)
	if result then 
		return sampGetPlayerNickname(myid)
	end
end

function update(wtd)
  	local fpath = os.getenv('TEMP') .. '\\HHUupd.txt'
	local params = 'action=update'
	local q = server..'scripts/hh/upd/index.php?'..params
	downloadUrlToFile(q, fpath, function(id, status, p1, p2)
		if status == dlstatus.STATUS_ENDDOWNLOADDATA then
			local f = io.open(fpath, 'r')
			if f then
				local response = decodeJson(f:read('*a'))
				if response and response.v and response.url then
					if response.v > tonumber(thisScript().version) then
						if wtd then
							lua_thread.create(goupdate, presponse.url, presponse.v)
						else
							if not response.s then sampAddChatMessage(prefix..'Доступно обновление.', 0x5fdbea) end
						end
					else
						sampAddChatMessage(prefix..'У Вас последняя версия скрипта.', 0x5fdbea)
					end
				end
			io.close(f)
			end
		end
	end)
	os.remove(fpath)
end

function goupdate(url, newv, f)
	if not f then sampAddChatMessage((prefix..'Текущая версия: '..thisScript().version..". Новая версия: "..newv), 0x5fdbea) end
	wait(300)
	downloadUrlToFile(url, thisScript().path, function(id3, status1, p13, p23)
		if status1 == dlstatus.STATUS_ENDDOWNLOADDATA then
			if not f then 
				sampAddChatMessage(prefix..'Обновление завершено! Перезагружаюсь.', 0x5fdbea)
				thisScript():reload()
			end
		end
	end)
end