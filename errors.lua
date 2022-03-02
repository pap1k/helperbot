local u8 = require("helperbot.u8")

M = {
    FILEOPEN = {
        message = "Ошибка открытия файла",
        exit = true
    },
    JSON_DECODE = {
        message = "Ошибка расшифровки файла",
        exit = true
    }
}

function M.alert(err)
    if M[err] then
        print(M[err].message)
    else
        print(u8:decode("Неопознанная ошибка."))
    end
end

return M