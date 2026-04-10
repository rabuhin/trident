local function Get(path)
    local url = "https://raw.githubusercontent.com/Maksik-paksik/Trident/main/" .. path
    local success, result = pcall(function()
        return game:HttpGet(url)
    end)
    if success then
        local f, err = loadstring(result)
        if f then return f() else warn("Ошибка парсинга " .. path .. ": " .. err) end
    else
        warn("Ошибка загрузки: " .. path)
    end
end

-- Инициализация
getgenv().TridentConfig = Get("Config.lua")
local ESP = Get("Modules/ESP.lua")

if ESP then
    ESP:Start(getgenv().TridentConfig)
    print("--- TRIDENT SCRIPT LOADED ---")
else
    warn("--- ESP MODULE NOT FOUND ---")
end
