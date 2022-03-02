local imgui = require("imgui")
local imadd = require("imgui_addons")
local utils = require("helperbot.utils")
local defs = require("helperbot.defines")
local base = require("helperbot.base")
local settings = require("helperbot.settings")
local fa = require("fAwesome5")
local vkeys = require "vkeys"

local rx, ry = getScreenResolution()
local wx, wy = 500, 500

local activeTab = 0
local searchMode = false

local searchInpBuf = imgui.ImBuffer(128)

local imBoolSettings = {
    ["useAnswId"] = imgui.ImBool(settings.get("useAnswId")),
    ["useFastAnsw"] = imgui.ImBool(settings.get("useFastAnsw")),
    ["useColor"] = imgui.ImBool(settings.get("useColor")),
    ["useFastCmd"] = imgui.ImBool(settings.get("useFastCmd")),
    ["useFastInfo"] = imgui.ImBool(settings.get("useFastInfo"))
}

local hotkeys = {
    btnAnswId = {v = {settings.get("btnAnswId")}},
    btnFastAnsw = {v = {settings.get("btnFastAnsw")}}
}

M = {
    ["imgui"] = imgui
}


local fa_font = nil
local fa_glyph_ranges = imgui.ImGlyphRanges({ fa.min_range, fa.max_range })
function imgui.BeforeDrawFrame()
    if fa_font == nil then
        local font_config = imgui.ImFontConfig()
        font_config.MergeMode = true
        font_config.SizePixels = 15.0;
        font_config.GlyphExtraSpacing.x = 0.1
        font_config.GlyphOffset.y = 1.5
        fa_font = imgui.GetIO().Fonts:AddFontFromFileTTF(getWorkingDirectory().."/helperbot/fAwesome5.ttf", font_config.SizePixels, font_config, fa_glyph_ranges)
    end
end

function M.MainWindow(boolref)
    imgui.SetNextWindowSize(imgui.ImVec2(wx, wy), imgui.Cond.FirstUseEver)
    imgui.SetNextWindowPos(imgui.ImVec2(rx/2-wx/2, ry/2-wy/2))

    imgui.Begin("HelperBot | Mister_Papanister",  boolref, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoCollapse)
        imgui.SetCursorPosX(100)
        if imgui.Button(fa.ICON_FA_WRENCH.."   Настройки", imgui.ImVec2(130, 30)) then
            activeTab = 0
        end
        imgui.SameLine(nil, 40)
        if imgui.Button(fa.ICON_FA_LIST.."   База", imgui.ImVec2(130, 30)) then
            activeTab = 1
        end
        imgui.LineSize(400, wx, 5, 0xFFAA11)

        if activeTab == 0 then -- настройки
            imgui.CenterTextColoredRGB("Настройки")
            imgui.LineSize(400, wx, 5, 0xFFAA11)
            if imgui.ToggleButton("Активировать /answ id", imBoolSettings.useAnswId) then
                settings.set("useAnswId", not settings.get("useAnswId"))
            end
            imgui.Spacing()
            if imadd.HotKey("##btnAnswId", hotkeys.btnAnswId, nil, 120) then
                if hotkeys.btnAnswId.v[1] ~= settings.get("btnAnswId") then
                    settings.set("btnAnswId", hotkeys.btnAnswId.v[1])
                end
            end
            imgui.SameLine()
            imgui.Text(" - Кнопка активации")
            imgui.Spacing()
            imgui.Separator()

            if imgui.ToggleButton("Использовать быстрый ответ", imBoolSettings.useFastAnsw) then
                settings.set("useFastAnsw", not settings.get("useFastAnsw"))
            end
            imgui.Spacing()
            if imadd.HotKey("##btnFastAnsw", hotkeys.btnFastAnsw, nil, 120) then
                if hotkeys.btnFastAnsw.v[1] ~= settings.get("btnFastAnsw") then
                    settings.set("btnFastAnsw", hotkeys.btnFastAnsw.v[1])
                end
            end
            imgui.SameLine()
            imgui.Text(" - Кнопка активации")
            imgui.Spacing()
            imgui.Separator()

            if imgui.ToggleButton("Использовать перекраску чата", imBoolSettings.useColor) then
                settings.set("useColor", not settings.get("useColor"))
            end
            imgui.Spacing()
            imgui.Separator()

            if imgui.ToggleButton("Использовать быстрый ответ макросами", imBoolSettings.useFastCmd) then
                settings.set("useFastCmd", not settings.get("useFastCmd"))
            end
            imgui.Spacing()
            imgui.Separator()

            if imgui.ToggleButton("Получать быструю инфу о спросившем (beta)", imBoolSettings.useFastInfo) then
                settings.set("useFastInfo", not settings.get("useFastInfo"))
            end
            imgui.Spacing()
            imgui.Separator()

        elseif activeTab == 1 then -- база
            imgui.CenterTextColoredRGB("База ответов")
            imgui.LineSize(400, wx, 5, 0xFFAA11)
            
            if imgui.InputText(fa.ICON_FA_SEARCH, searchInpBuf) then
                if searchInpBuf.v ~= "" then
                    searchMode = true
                else
                    searchMode = false
                end
            end

            imgui.BeginChild("##LIST")
                local lbase = base.getBase()
                for k,v in ipairs(lbase) do
                    if searchMode then
                        local huy = false
                        for kx, vx in ipairs(v.trig) do if vx:find(searchInpBuf.v) then huy = true break end end
                        if v.answ:find(searchInpBuf.v) or huy then
                            answerElem(v, k)
                        end
                    else
                       answerElem(v, k) 
                    end
                end
            imgui.EndChild()
        end

    imgui.End()
end

function popupEdit()
    
end

function answerElem(v, id)
    if imgui.Button(fa.ICON_FA_TRASH, imgui.ImVec2(20, 20)) then
        -- popup delete
    end
    imgui.SameLine()
    if imgui.Button(v.answ) then
        --popup edit answer
    end
    imgui.SetCursorPosX(200)
    for i = 1, #v.trig do
        imgui.SameLine()
        imgui.Button(v.trig[i])
    end
    imgui.Spacing() imgui.Separator()
end

-- // Кастомный переключатель (Author: DonHomka)
function imgui.ToggleButton(str_id, bool)

    local rBool = false

    if LastActiveTime == nil then
        LastActiveTime = {}
    end
    if LastActive == nil then
        LastActive = {}
    end

    local function ImSaturate(f)
        return f < 0.0 and 0.0 or (f > 1.0 and 1.0 or f)
    end
    
    local p = imgui.GetCursorScreenPos()
    local draw_list = imgui.GetWindowDrawList()

    local height = imgui.GetTextLineHeightWithSpacing()
    local width = height * 1.55
    local radius = height * 0.50
    local ANIM_SPEED = 0.15
	local butPos = imgui.GetCursorPos()
	
    if imgui.InvisibleButton(str_id, imgui.ImVec2(width, height)) then
        bool.v = not bool.v
        rBool = true
        LastActiveTime[tostring(str_id)] = os.clock()
        LastActive[tostring(str_id)] = true
    end
	
	imgui.SetCursorPos(imgui.ImVec2(butPos.x + width + 8, butPos.y + 2.5))
    imgui.Text( str_id:gsub("##.+", "") )
	
    local t = bool.v and 1.0 or 0.0

    if LastActive[tostring(str_id)] then
        local time = os.clock() - LastActiveTime[tostring(str_id)]
        if time <= ANIM_SPEED then
            local t_anim = ImSaturate(time / ANIM_SPEED)
            t = bool.v and t_anim or 1.0 - t_anim
        else
            LastActive[tostring(str_id)] = false
        end
    end

    local col_bg
    if bool.v then
        col_bg = imgui.GetColorU32(imgui.GetStyle().Colors[imgui.Col.FrameBgHovered]) -- фон кнопки вкл
    else
        col_bg = imgui.ImColor(100, 100, 100, 255):GetU32() -- фон кнопки выкл
    end

    draw_list:AddRectFilled(imgui.ImVec2(p.x, p.y + (height / 6)), imgui.ImVec2(p.x + width - 1.0, p.y + (height - (height / 6))), col_bg, 5.0)
    draw_list:AddCircleFilled(imgui.ImVec2(p.x + radius + t * (width - radius * 2.0), p.y + radius), radius - 0.75, imgui.GetColorU32(bool.v and imgui.GetStyle().Colors[imgui.Col.ButtonActive] or imgui.ImColor(150, 150, 150, 255):GetVec4()))

    return rBool
end

function imgui.LineSize(sizeLine, widthWindow, bordLine, rgb) -- Взял у берри бредли
	local cursP = imgui.GetCursorScreenPos()
	local r = bit.band(bit.rshift(rgb, 16), 0xFF) / 255
    local g = bit.band(bit.rshift(rgb, 8), 0xFF) / 255
    local b = bit.band(rgb, 0xFF) / 255
	
	imgui.GetWindowDrawList():AddLine(imgui.ImVec2(cursP.x + (widthWindow / 2) - (sizeLine / 2), cursP.y + bordLine), imgui.ImVec2(cursP.x + (widthWindow / 2) + (sizeLine / 2), cursP.y + bordLine), imgui.GetColorU32(imgui.ImVec4(r, g, b, 1.0)))
	imgui.SetCursorPosY(imgui.GetCursorPosY() + bordLine + 10)
end

function imgui.CenterTextColoredRGB(text) -- Взял у берри бредли
    local width = imgui.GetWindowWidth() 
    local style = imgui.GetStyle() 
    local colors = style.Colors 
    local ImVec4 = imgui.ImVec4 
 
    local explode_argb = function(argb) 
        local a = bit.band(bit.rshift(argb, 24), 0xFF) 
        local r = bit.band(bit.rshift(argb, 16), 0xFF) 
        local g = bit.band(bit.rshift(argb, 8), 0xFF) 
        local b = bit.band(argb, 0xFF) 
        return a, r, g, b 
    end 
 
    local getcolor = function(color) 
        if color:sub(1, 6):upper() == "SSSSSS" then 
            local r, g, b = colors[1].x, colors[1].y, colors[1].z 
            local a = tonumber(color:sub(7, 8), 16) or colors[1].w * 255 
            return ImVec4(r, g, b, a / 255) 
        end 
        local color = type(color) == "string" and tonumber(color, 16) or color 
        if type(color) ~= "number" then return end 
        local r, g, b, a = explode_argb(color) 
        return imgui.ImColor(r, g, b, a):GetVec4() 
    end 
 
    local render_text = function(text_) 
        for w in text_:gmatch("[^\r\n]+") do 
            local textsize = w:gsub("{.-}", "") 
            local text_width = imgui.CalcTextSize(textsize) 
            imgui.SetCursorPosX( width / 2 - text_width .x / 2 ) 
            local text, colors_, m = {}, {}, 1 
            w = w:gsub("{(......)}", "{%1FF}") 
            while w:find("{........}") do 
                local n, k = w:find("{........}") 
                local color = getcolor(w:sub(n + 1, k - 1)) 
                if color then 
                    text[#text], text[#text + 1] = w:sub(m, n - 1), w:sub(k + 1, #w) 
                    colors_[#colors_ + 1] = color 
                    m = n 
                end 
                w = w:sub(1, n - 1) .. w:sub(k + 1, #w) 
            end 
            if text[0] then 
                for i = 0, #text do 
                    imgui.TextColored(colors_[i] or colors[1], text[i]) 
                    imgui.SameLine(nil, 0) 
                end 
                imgui.NewLine() 
            else 
                imgui.Text(w) 
            end 
        end 
    end 
    render_text(text) 
end
function theme()
    imgui.SwitchContext()
    local style = imgui.GetStyle()
    local colors = style.Colors
    local clr = imgui.Col
    local ImVec4 = imgui.ImVec4
    local ImVec2 = imgui.ImVec2

    style.WindowPadding = imgui.ImVec2(8, 8)
    style.WindowRounding = 6
    style.ChildWindowRounding = 5
    style.FramePadding = imgui.ImVec2(5, 3)
    style.FrameRounding = 3.0
    style.ItemSpacing = imgui.ImVec2(5, 4)
    style.ItemInnerSpacing = imgui.ImVec2(4, 4)
    style.IndentSpacing = 21
    style.ScrollbarSize = 10.0
    style.ScrollbarRounding = 13
    style.GrabMinSize = 8
    style.GrabRounding = 1
    style.WindowTitleAlign = imgui.ImVec2(0.5, 0.5)
    style.ButtonTextAlign = imgui.ImVec2(0.5, 0.5)

    colors[clr.Text]                   = ImVec4(0.95, 0.96, 0.98, 1.00);
    colors[clr.TextDisabled]           = ImVec4(0.29, 0.29, 0.29, 1.00);
    colors[clr.WindowBg]               = ImVec4(0.14, 0.14, 0.14, 1.00);
    colors[clr.ChildWindowBg]          = ImVec4(0.12, 0.12, 0.12, 1.00);
    colors[clr.PopupBg]                = ImVec4(0.08, 0.08, 0.08, 0.94);
    colors[clr.Border]                 = ImVec4(0.14, 0.14, 0.14, 1.00);
    colors[clr.BorderShadow]           = ImVec4(1.00, 1.00, 1.00, 0.10);
    colors[clr.FrameBg]                = ImVec4(0.22, 0.22, 0.22, 1.00);
    colors[clr.FrameBgHovered]         = ImVec4(0.18, 0.18, 0.18, 1.00);
    colors[clr.FrameBgActive]          = ImVec4(0.09, 0.12, 0.14, 1.00);
    colors[clr.TitleBg]                = ImVec4(0.14, 0.14, 0.14, 0.81);
    colors[clr.TitleBgActive]          = ImVec4(0.14, 0.14, 0.14, 1.00);
    colors[clr.TitleBgCollapsed]       = ImVec4(0.00, 0.00, 0.00, 0.51);
    colors[clr.MenuBarBg]              = ImVec4(0.20, 0.20, 0.20, 1.00);
    colors[clr.ScrollbarBg]            = ImVec4(0.02, 0.02, 0.02, 0.39);
    colors[clr.ScrollbarGrab]          = ImVec4(0.36, 0.36, 0.36, 1.00);
    colors[clr.ScrollbarGrabHovered]   = ImVec4(0.18, 0.22, 0.25, 1.00);
    colors[clr.ScrollbarGrabActive]    = ImVec4(0.24, 0.24, 0.24, 1.00);
    colors[clr.ComboBg]                = ImVec4(0.24, 0.24, 0.24, 1.00);
    colors[clr.CheckMark]              = ImVec4(1.00, 0.28, 0.28, 1.00);
    colors[clr.SliderGrab]             = ImVec4(1.00, 0.28, 0.28, 1.00);
    colors[clr.SliderGrabActive]       = ImVec4(1.00, 0.28, 0.28, 1.00);
    colors[clr.Button]                 = ImVec4(1.00, 0.28, 0.28, 1.00);
    colors[clr.ButtonHovered]          = ImVec4(1.00, 0.39, 0.39, 1.00);
    colors[clr.ButtonActive]           = ImVec4(1.00, 0.21, 0.21, 1.00);
    colors[clr.Header]                 = ImVec4(1.00, 0.28, 0.28, 1.00);
    colors[clr.HeaderHovered]          = ImVec4(1.00, 0.39, 0.39, 1.00);
    colors[clr.HeaderActive]           = ImVec4(1.00, 0.21, 0.21, 1.00);
    colors[clr.ResizeGrip]             = ImVec4(1.00, 0.28, 0.28, 1.00);
    colors[clr.ResizeGripHovered]      = ImVec4(1.00, 0.39, 0.39, 1.00);
    colors[clr.ResizeGripActive]       = ImVec4(1.00, 0.19, 0.19, 1.00);
    colors[clr.CloseButton]            = ImVec4(0.40, 0.39, 0.38, 0.16);
    colors[clr.CloseButtonHovered]     = ImVec4(0.40, 0.39, 0.38, 0.39);
    colors[clr.CloseButtonActive]      = ImVec4(0.40, 0.39, 0.38, 1.00);
    colors[clr.PlotLines]              = ImVec4(0.61, 0.61, 0.61, 1.00);
    colors[clr.PlotLinesHovered]       = ImVec4(1.00, 0.43, 0.35, 1.00);
    colors[clr.PlotHistogram]          = ImVec4(1.00, 0.21, 0.21, 1.00);
    colors[clr.PlotHistogramHovered]   = ImVec4(1.00, 0.18, 0.18, 1.00);
    colors[clr.TextSelectedBg]         = ImVec4(1.00, 0.32, 0.32, 1.00);
    colors[clr.ModalWindowDarkening]   = ImVec4(0.26, 0.26, 0.26, 0.60);
end
theme()
return M