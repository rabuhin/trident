-- [ POTASSIUM / WAVE HOTFIX ]
-- Создаем заглушку для функции setfflag, если экзекутор её не поддерживает.
-- Это предотвращает вылеты интерфейса Kavo.
if (type(getgenv) == 'function' and getgenv().setfflag == nil) then
    getgenv().setfflag = function() end;
end;

-- [[ TRIDENT PROJECT: ADVANCED LOADER ]]
local executor = identifyexecutor and identifyexecutor() or "Unknown"
local request = request or http_request

-- Защищенная функция загрузки с проверкой статус-кода (как в amongus.hook)
local function SafeLoad(file)
    local url = "https://raw.githubusercontent.com/rabuhin/Trident/main/" .. file .. "?t=" .. os.time()
    local success, response = pcall(request, {Url = url, Method = "GET"})
    
    if success and response.StatusCode == 200 then
        local func, err = loadstring(response.Body)
        if func then 
            return func() 
        else
            warn("[Trident] Syntax Error in " .. file .. ": " .. err)
        end
    else
        warn("[Trident] Failed to load " .. file .. " | Status: " .. (response and response.StatusCode or "No Response"))
    end
end

-- 1. Исправляем Drawing API (если его нет в Potassium)
if not getgenv().Drawing then
    SafeLoad("Modules/DrawingFix.lua")
end

-- 2. Загружаем библиотеку интерфейса
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()

-- 3. Создаем окно (Без функций типа SetWatermarkColor, которые вызывают ошибки)
local Window = Library.CreateLib("Trident Project | " .. executor, "DarkTheme")

-- 4. Загружаем компоненты через защищенный загрузчик
_G.TridentConfig = SafeLoad("Config.lua")
local ESP = SafeLoad("Modules/ESP.lua")

-- [[ ИНТЕРФЕЙС ]]
local MainTab = Window:NewTab("Visuals")
local VisSection = MainTab:NewSection("Player ESP")

VisSection:NewToggle("Enable ESP", "Отрисовка через Drawing API", function(state)
    if _G.TridentConfig then 
        _G.TridentConfig.ESP_Enabled = state 
    end
end)

local SetTab = Window:NewTab("Settings")
local SetSection = SetTab:NewSection("Config Control")

SetSection:NewButton("Unload & Clean", "Полная очистка скрипта", function()
    if ESP and ESP.Unload then ESP:Unload() end
    Library:Unload()
end)

-- [[ ЗАПУСК ЛОГИКИ ]]
if ESP and _G.TridentConfig then
    local startSuccess, err = pcall(function()
        ESP:Start(_G.TridentConfig)
    end)
    
    if startSuccess then
        print("[Trident] ESP Module Started Successfully on " .. executor)
    else
        warn("[Trident] Failed to start ESP logic: " .. tostring(err))
    end
end
