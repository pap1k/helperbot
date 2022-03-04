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

local query = {}
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
    -- �� ���
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
	if fastinfo and text:find('{F5DEB3}���: .* �������: .* ��������� �: .*') then
		local country = string.match(text, '{F5DEB3}���: {ffffff}.*{F5DEB3} �������: {ffffff}.*{F5DEB3} ��������� �: {ffffff}(%a+){F5DEB3}%.')
		sampAddChatMessage("[INFO]: {"..dectohex(sampGetPlayerColor(id))..'}'..sampGetPlayerNickname(id)..', {e64c5a}'..sampGetPlayerScore(id)..'{5fdbea} LVL, {e64c5a}'..country, 0x5fdbea)
		fastinfo = false
		return false
	end
	if fastinfo and text:find('���������� ����������') then
		return false
	end
	if fastinfo and text:find('�� ������ � ���������� �����������') then
		sampAddChatMessage("[INFO]: {"..dectohex(sampGetPlayerColor(id))..'}'..sampGetPlayerNickname(id)..', {e64c5a}'..sampGetPlayerScore(id)..'{5fdbea} LVL, {e64c5a}��� ������ �� ������ ����������', 0x5fdbea)
		fastinfo = false
		return false
	end

	if color == -5631489 and settings.get("useFastAnsw") then
		if text:find('%[H%].*: .*') then return end
		if text:find('������ �� .* ID %d*:.*') then
			if settings.get("useColor") then sampAddChatMessage('[Q]{ffff52} '..text, 0xc10013)
			else sampAddChatMessage(text, 0xffaa11) end

			local id, q = string.match(text, '������ �� .* ID (%d+): (.*)')
            playerid = id
			if settings.get("useFastInfo") then
				fastinfo = true
				sampSendChat("/num "..id)
			end
			lua_thread.create(findAnswer, q, id)
			return false
		end
		if text:find('�� .* ��� .*') then
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
        local result = search(u8(inputstr:lower()))
        print("RESULT", result, "SUB", result.sub(1, 2))
        if result == "!!" then
            work = false
        elseif result == "!!wait" then
            wait(100)
        else
            work = false
            if answer.status then
                answer.ts = os.clock()
            end
            while answer.ts + 0.5 >= os.clock() do
                sampAddChatMessage(tostring(answer.ts + 0.5).." > ="..tostring(os.clock()), -1)
                wait(100)
            end
            announceAndSave(result, id)
        end
    end
end

function announceAndSave(result, id)
    sampAddChatMessage('��������, �������� ����� {c10013}'..result, 0x35b74a)
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
            for i = 1, #variant.trig do
                if  inputstr:match("%s"..variant.trig[i].."%s") or 
                    inputstr:match("%s"..variant.trig[i].."$") or 
                    inputstr:match("^"..variant.trig[i].."%s") or 
                    inputstr:match("^"..variant.trig[i].."$") then
                        print(variant.trig[i])
                        count = count +1
                end
            end
            if count > max then
                max = count
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