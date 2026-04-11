-- [[ TRIDENT PROJECT: ADVANCED LOADER ]]
local executor = identifyexecutor and identifyexecutor() or "Unknown"
local request = request or http_request

-- Защищенная функция загрузки (как в amongus.hook)
local function SafeLoad(file)
    local url = "https://raw.githubusercontent.com/rabuhin/Trident/main/" .. file .. "?t=" .. os.time()
    local success, response = pcall(request, {Url = url, Method = "GET"})
    
    if success and response.StatusCode == 200 then
        local func, err = loadstring(response.Body)
        if func then 
            return func() 
        else
            warn("Syntax Error in " .. file .. ": " .. err)
        end
    else
        warn("Failed to load " .. file .. " | Executor: " .. executor)
    end
end

-- 1. Исправляем Drawing API (если его нет)
if not getgenv().Drawing then
    SafeLoad("Modules/DrawingFix.lua")
end

-- 2. Загружаем бибилиотеку интерфейса (Используем более стабильную ссылку)
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()

-- 3. Создаем окно (Без лишних функций, которые ломали меню)
local Window = Library.CreateLib("Trident Project | " .. executor, "DarkTheme")

-- 4. Загружаем компоненты
_G.TridentConfig = SafeLoad("Config.lua")
local ESP = SafeLoad("Modules/ESP.lua")

-- [ ИНТЕРФЕЙС ]
local MainTab = Window:NewTab("Visuals")
local VisSection = MainTab:NewSection("Player ESP")

VisSection:NewToggle("Enable ESP", "Отрисовка через Drawing API", function(state)
    if _G.TridentConfig then _G.TridentConfig.ESP_Enabled = state end
end)

local SetTab = Window:NewTab("Settings")
local SetSection = SetTab:NewSection("Config")

SetSection:NewButton("Unload & Clean", "Полная очистка", function()
    if ESP then ESP:Unload() end
    Library:Unload()
end)

-- [ ЗАПУСК ЛОГИКИ ]
if ESP and _G.TridentConfig then
    ESP:Start(_G.TridentConfig)
    print("[Trident] ESP Module Started Successfully")
end
