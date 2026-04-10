local function Get(path)
    -- Используем твой ник rabuhin
    local url = "https://raw.githubusercontent.com/rabuhin/Trident/main/" .. path
    local success, result = pcall(function()
        return game:HttpGet(url)
    end)
    if success then
        local f, err = loadstring(result)
        if f then 
            return f() 
        else 
            warn("Ошибка парсинга " .. path .. ": " .. err) 
        end
    else
        warn("Ошибка загрузки файла из GitHub: " .. path)
    end
end

-- Инициализация конфига и модуля ESP
getgenv().TridentConfig = Get("Config.lua")
local ESP = Get("Modules/ESP.lua")

if ESP then
    ESP:Start(getgenv().TridentConfig)
    print("--- TRIDENT SCRIPT BY RABUHIN LOADED ---")
else
    warn("--- КРИТИЧЕСКАЯ ОШИБКА: МОДУЛЬ ESP НЕ НАЙДЕН ---")
end
