local defs = require("helperbot.defines")
local errors = require("helperbot.errors")
local imadd = require("imgui_addons")

M = {}

function M.createFile(filename)
    local f = io.open(getWorkingDirectory().."\\"..defs.DIRECTORY..filename, "w")
    if not f then
        errors.alert(errors.FILEOPEN)
        if errors.FILEOPEN.exit then
            thisScript():unload()
        end
    end
    io.close(f)
    return true
end

function M.writeFile(filename, text)
    local f =  io.open(getWorkingDirectory().."\\"..defs.DIRECTORY..filename, "w")
    if not f then
        errors.alert(errors.FILEOPEN)
        if errors.FILEOPEN.exit then
            thisScript():unload()
        end
    end
    f:write(text)
    io.close(f)
    return true
end

function M.readFile(filename)
    local f = io.open(getWorkingDirectory().."\\"..defs.DIRECTORY..filename, "r")
    if not f then
        errors.alert(errors.FILEOPEN)
        if errors.FILEOPEN.exit then
            thisScript():unload()
        end
    end
	local data = f:read('*a')
    io.close(f)
    return data
end

function M.doesFileExist(filename)
    if not doesDirectoryExist(getWorkingDirectory().."\\"..defs.DIRECTORY) then
        createDirectory(getWorkingDirectory().."\\"..defs.DIRECTORY)
    end
    return doesFileExist(getWorkingDirectory().."\\"..defs.DIRECTORY..filename)
end

function M.print_r ( t ) 
    local print_r_cache={}
    local function sub_print_r(t,indent)
        if (print_r_cache[tostring(t)]) then
            print(indent.."*"..tostring(t))
        else
            print_r_cache[tostring(t)]=true
            if (type(t)=="table") then
                for pos,val in pairs(t) do
                    if (type(val)=="table") then
                        print(indent.."["..pos.."] => "..tostring(t).." {")
                        sub_print_r(val,indent..string.rep(" ",string.len(pos)+8))
                        print(indent..string.rep(" ",string.len(pos)+6).."}")
                    else
                        print(indent.."["..pos.."] => "..tostring(val))
                    end
                end
            else
                print(indent..tostring(t))
            end
        end
    end
    sub_print_r(t,"  ")
end

function M.split(inputstr, sep)
	if sep == nil then
		sep = "%s"
	end
	local t={}
	for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
		table.insert(t, str)
	end
	return t
end

function M.inArray(array, needle)
    for k,v in ipairs(array) do
        if v == needle then
            return true
        end
    end
    return false
end

return M