utils = require("helperbot.utils")
defs = require("helperbot.defines")
base = require("helperbot.base")
base.init()
settings = require("helperbot.settings")
settings.init(not utils.doesFileExist(defs.SETTINGS_FILENAME))
gui = require("helperbot.gui")
se = require("lib.samp.events")

local winActive = gui.imgui.ImBool(false)

local query = {}
local fastinfo = false

answer = {
    status = false,
    answ = "",
    id,
    ts = os.clock()
}

playerid = -1

function main()
    repeat wait(0) until isSampAvailable()
    -- че это
    sampAddChatMessage("HelperBot Loaded", -1)

    sampRegisterChatCommand('hh', function()
		winActive.v = not winActive.v
		gui.imgui.Process = winActive.v
	end)

    while true do 
        wait(0)
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
                    sampSendChat(" /answ "..answer.id.." "..answer.answ)
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
		if text:find('Вопрос от .* ID .*:') then		
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
        local result = search(inputstr:lower())
        if result.sub(1, 2) == "!!" then
            if result == "!!wait" then
                wait(100)
            else
                work = false
            end
        else
            work = false
            while answer.ts + 500 >= os.clock() do
                wait(100)
            end
            announceAndSave(result, id)
        end
    end
end

function announceAndSave(result)
    sampAddChatMessage('Возможно, подойдет ответ {c10013}'..result, 0x35b74a)
    answer.status = true
    answer.answ = result
    answer.ts = os.clock()
end

function search(inputstr)
    if not base.isBusy() then
        local b = base.getBase()
        local words = utils.split(inputstr)

        local maxindex = 0
        local max = 0

        for k, variant in ipairs(b) do
            local count = 0
            for i = 0, #variant.trig do
                if utils.inArray(words, variant.trig[i]) then
                    count = count +1
                end
            end
            if count > max then
                max = count
                maxindex = k
            end
        end
        
        if maxindex ~= 0 and max ~= 0 then
            return b[maxindex].answ
        else
            return '!!'
        end
    else
        return '!!wait'
    end
end