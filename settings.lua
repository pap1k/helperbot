local utils = require("helperbot.utils")
local defs = require("helperbot.defines")
local errors = require("helperbot.errors")
local vkeys = require "vkeys"

M = {
    inited = false
}

settings = {}



local defaults = {
    ["useAnswId"] = false,
    ["btnAnswId"] = vkeys.VK_NUMPAD8,

    ["useFastAnsw"] = false,
    ["btnFastAnsw"] = vkeys.VK_F2,

    ["useColor"] = false,
    ["useFastCmd"] = false,
    ["useFastInfo"] = false
}

function getFromFile()
    local filedata = utils.readFile(defs.SETTINGS_FILENAME)
    local json = decodeJson(filedata)
    if json then
        return json
    else
        errors.alert(errors.JSON_DECODE)
        if errors.JSON_DECODE.exit then
            thisScript():unload()
        end
        return nil
    end
end

function save()
    local v = utils.writeFile(defs.SETTINGS_FILENAME, encodeJson(settings))
    return v
end

function M.get(key)
    if settings[key] ~= nil then
        return settings[key]
    end
    return nil
end

function M.set(key, value)
    settings[key] = value
    return save()
end

function M.init(first)
    if first then
        utils.writeFile(defs.SETTINGS_FILENAME, encodeJson(defaults))
    end
    settings = getFromFile()
    M.inited = true
end

return M