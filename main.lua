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

    sampAddChatMessage("{e9ab4f}[HH]{5fdbea} HelperBot Loaded. ����.", -1)

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
        local result = search(u8(lower(inputstr:gsub("[��]", "e"))))
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
        [168] = '�', [184] = '�', [192] = '�', [193] = '�', [194] = '�', [195] = '�', [196] = '�', [197] = '�', [198] = '�', [199] = '�', [200] = '�', [201] = '�', [202] = '�', [203] = '�', [204] = '�', [205] = '�', [206] = '�', [207] = '�', [208] = '�', [209] = '�', [210] = '�', [211] = '�', [212] = '�', [213] = '�', [214] = '�', [215] = '�', [216] = '�', [217] = '�', [218] = '�', [219] = '�', [220] = '�', [221] = '�', [222] = '�', [223] = '�', [224] = '�', [225] = '�', [226] = '�', [227] = '�', [228] = '�', [229] = '�', [230] = '�', [231] = '�', [232] = '�', [233] = '�', [234] = '�', [235] = '�', [236] = '�', [237] = '�', [238] = '�', [239] = '�', [240] = '�', [241] = '�', [242] = '�', [243] = '�', [244] = '�', [245] = '�', [246] = '�', [247] = '�', [248] = '�', [249] = '�', [250] = '�', [251] = '�', [252] = '�', [253] = '�', [254] = '�', [255] = '�',
      }
    local strlen = s:len()
    if strlen == 0 then return s end
    s = s:lower()
    local output = ''
    for i = 1, strlen do
        local ch = s:byte(i)
        if ch >= 192 and ch <= 223 then -- upper russian characters
            output = output .. russian_characters[ch+32]
        elseif ch == 168 then -- �
            output = output .. russian_characters[184]
        else
            output = output .. string.char(ch)
        end
    end
    return output
end