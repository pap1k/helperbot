local defs = require("helperbot.defines")
local utils = require("helperbot.utils")
local errors = require("helperbot.errors")


M = {}

base = {}

local defaults = {
    b = {
        {trig = {"срок", "сколько сидеть"}, answ = "/jailtime"},
        {trig = {"хокей", "хока", "хокка"}, answ = "от 500к"}
    }
}

function getFromFile()
    local data = utils.readFile(defs.BASE_FILENAME)
    local lbase = decodeJson(data)
    if lbase then
        return lbase.b
    else
        errors.alert(errors.JSON_DECODE)
        if errors.JSON_DECODE.exit then
            thisScript():unload()
        end
    end
end

function save()
    utils.writeFile(encodeJson({b = base}))
end

function M.init()
    if not utils.doesFileExist(defs.BASE_FILENAME) then
        utils.createFile(defs.BASE_FILENAME)
        utils.writeFile(defs.BASE_FILENAME, encodeJson(defaults))
    end
    base = getFromFile()
end

function M.getBase()
    return base
end

function M.add(triggers, answer)
    table.insert( base,{trig = triggers, answ = answer} )
    save()
end

function M.edit()

end

function M.delete(id)
    table.remove( base,id)
end

return M