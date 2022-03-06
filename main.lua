utils = require("helperbot.utils")
defs = require("helperbot.defines")
base = require("helperbot.base")
base.init()
settings = require("helperbot.settings")
settings.init(not utils.doesFileExist(defs.SETTINGS_FILENAME))
gui = require("helperbot.gui")
se = require("lib.samp.events")
u8 = require("helperbot.u8")

local winActive = gui.imgui.ImBool(false)

local fastinfo = false

answer = {
    status = false,
    answ = "",
    id = -1,
    ts = os.clock()
}

playerid = -1

function main()
    repeat wait(0) until isSampAvailable()

    sampAddChatMessage("{e9ab4f}[HH]{5fdbea} HelperBot Loaded. Ебаш.", -1)

    sampRegisterChatCommand("test", function(txt)
        sampAddChatMessage(lower(txt), -1)
    end)

    sampRegisterChatCommand('hh', function()
		winActive.v = not winActive.v
		gui.imgui.Process = winActive.v
	end)

    while true do 
        wait(0)
        gui.imgui.ShowCursor = winActive.v
        if settings.get("useAnswId") then
            if playerid ~= -1 then
                if wasKeyPressed(settings.get("btnAnswId")) then
                    sampSetChatInputText("/answ "..playerid.." ")
                    sampSetChatInputEnabled(true)
                end
            end
        end

        if settings.get("useFastAnsw") then
            if answer.status == true then
                if wasKeyPressed(settings.get("btnFastAnsw")) then
                    sampSendChat("/answ "..answer.id.." "..answer.answ)
                    answer.status = false
                end
            end
        end
    end
end

function se.onServerMessage(color, text)
	if fastinfo and text:find('{F5DEB3}Имя: .* Телефон: .* Проживает в: .*') then
		local country = string.match(text, '{F5DEB3}Имя: {ffffff}.*{F5DEB3} Телефон: {ffffff}.*{F5DEB3} Проживает в: {ffffff}(%a+){F5DEB3}%.')
		sampAddChatMessage("[INFO]: {"..dectohex(sampGetPlayerColor(id))..'}'..sampGetPlayerNickname(id)..', {e64c5a}'..sampGetPlayerScore(id)..'{5fdbea} LVL, {e64c5a}'..country, 0x5fdbea)
		fastinfo = false
		return false
	end
	if fastinfo and text:find('Телефонный справочник') then
		return false
	end
	if fastinfo and text:find('не найден в телефонном справочнике') then
		sampAddChatMessage("[INFO]: {"..dectohex(sampGetPlayerColor(id))..'}'..sampGetPlayerNickname(id)..', {e64c5a}'..sampGetPlayerScore(id)..'{5fdbea} LVL, {e64c5a}Нет данных по стране проживания', 0x5fdbea)
		fastinfo = false
		return false
	end

	if color == -5631489 and settings.get("useFastAnsw") then
		if text:find('%[H%].*: .*') then return end
		if text:find('Вопрос от .* ID %d*:.*') then
			if settings.get("useColor") then sampAddChatMessage('[Q]{ffff52} '..text, 0xc10013)
			else sampAddChatMessage(text, 0xffaa11) end

			local id, q = string.match(text, 'Вопрос от .* ID (%d+): (.*)')
            playerid = id
			if settings.get("useFastInfo") then
				fastinfo = true
				sampSendChat("/num "..id)
			end
			lua_thread.create(findAnswer, q, id)
			return false
		end
		if text:find('От .* для .*') then
			if settings.get("useColor") then sampAddChatMessage('[A]{c78108} '..text, 0xc10013)
			else sampAddChatMessage(text, 0xffaa11) end
			return false
		end
	end
end

function se.onSendCommand(cmd)
	if settings.get("useFastCmd") then
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

function gui.imgui.OnDrawFrame()
    if winActive.v then
        gui.MainWindow(winActive)
    end
end

function findAnswer(inputstr, id)
    local work = true
    while work do
        local result = search(u8(lower(inputstr:gsub("[ёЁ]", "e"))))
        if result == "!!" then
            work = false
        elseif result == "!!wait" then
            wait(100)
        else
            work = false
            if answer.status and answer.ts + 5 >= os.clock() then
                answer.ts = os.clock()
            end
            while answer.ts + 0.5 >= os.clock() and answer.status == false do
                wait(100)
            end
            announceAndSave(result, id)
        end
    end
end

function announceAndSave(result, id)
    sampAddChatMessage('Возможно, подойдет ответ {c10013}'..result, 0x35b74a)
    answer.status = true
    answer.answ = result
    answer.id = id
    answer.ts = os.clock()
end

function search(inputstr)
    if not base.isBusy() then
        local b = base.getBase()

        local maxindex = 0
        local max = 0

        for k, variant in ipairs(b) do
            local count = 0
            local percentage = 0
            for i = 1, #variant.trig do
                local test = u8(lower(u8:decode(variant.trig[i])))
                if  inputstr:match("%s"..test.."%s") or 
                    inputstr:match("%s"..test.."$") or 
                    inputstr:match("^"..test.."%s") or 
                    inputstr:match("^"..test.."$") then
                        count = count +1
                end
            end
            percentage = #variant.trig / count
            if percentage > max then
                max = percentage
                maxindex = k
            end
        end
        print(maxindex, max)
        if maxindex ~= 0 and max ~= 0 then
            return u8:decode(b[maxindex].answ)
        else
            return '!!'
        end
    else
        return '!!wait'
    end
end

function lower(s)
    local russian_characters = {
        [168] = 'Ё', [184] = 'ё', [192] = 'А', [193] = 'Б', [194] = 'В', [195] = 'Г', [196] = 'Д', [197] = 'Е', [198] = 'Ж', [199] = 'З', [200] = 'И', [201] = 'Й', [202] = 'К', [203] = 'Л', [204] = 'М', [205] = 'Н', [206] = 'О', [207] = 'П', [208] = 'Р', [209] = 'С', [210] = 'Т', [211] = 'У', [212] = 'Ф', [213] = 'Х', [214] = 'Ц', [215] = 'Ч', [216] = 'Ш', [217] = 'Щ', [218] = 'Ъ', [219] = 'Ы', [220] = 'Ь', [221] = 'Э', [222] = 'Ю', [223] = 'Я', [224] = 'а', [225] = 'б', [226] = 'в', [227] = 'г', [228] = 'д', [229] = 'е', [230] = 'ж', [231] = 'з', [232] = 'и', [233] = 'й', [234] = 'к', [235] = 'л', [236] = 'м', [237] = 'н', [238] = 'о', [239] = 'п', [240] = 'р', [241] = 'с', [242] = 'т', [243] = 'у', [244] = 'ф', [245] = 'х', [246] = 'ц', [247] = 'ч', [248] = 'ш', [249] = 'щ', [250] = 'ъ', [251] = 'ы', [252] = 'ь', [253] = 'э', [254] = 'ю', [255] = 'я',
      }
    local strlen = s:len()
    if strlen == 0 then return s end
    s = s:lower()
    local output = ''
    for i = 1, strlen do
        local ch = s:byte(i)
        if ch >= 192 and ch <= 223 then -- upper russian characters
            output = output .. russian_characters[ch+32]
        elseif ch == 168 then -- Ё
            output = output .. russian_characters[184]
        else
            output = output .. string.char(ch)
        end
    end
    return output
end