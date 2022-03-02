utils = require("helperbot.utils")
defs = require("helperbot.defines")
settings = require("helperbot.settings")
settings.init(not utils.doesFileExist(defs.SETTINGS_FILENAME))
require("helperbot.base").init()
gui = require("helperbot.gui")
se = require("lib.samp.events")

local winActive = gui.imgui.ImBool(false)

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
    end
end

function gui.imgui.OnDrawFrame()
    if winActive.v then
        gui.MainWindow(winActive)
    end
end