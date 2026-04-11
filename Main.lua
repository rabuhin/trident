-- [ FIX: MISSING FUNCTIONS ]
if (type(getgenv) == 'function' and getgenv().setfflag == nil) then
      getgenv().setfflag = function() end;
end;

local request = request or http_request
local executor = identifyexecutor and identifyexecutor() or "Unknown"

-- Функция загрузки через request (как в README амонгус-хука)
local function RequestLoad(file)
    local url = "https://raw.githubusercontent.com/rabuhin/Trident/main/" .. file .. "?t=" .. os.time()
    local success, response = pcall(request, {Url = url, Method = "GET"})
    if success and response.StatusCode == 200 then
        local func = loadstring(response.Body)
        if func then return func() end
    end
    warn("[Trident] Critical fail on: " .. file)
end

-- 1. Исправляем Drawing API
if not getgenv().Drawing then
    RequestLoad("Modules/DrawingFix.lua")
end

-- 2. Загружаем UI библиотеку через request (обход блокировок)
local libContent = request({Url='https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua', Method='GET'}).Body
local Library = loadstring(libContent)()

-- 3. Создаем меню
local Window = Library.CreateLib("Trident Project | " .. executor, "DarkTheme")

-- 4. Загружаем конфиг и ESP
_G.TridentConfig = RequestLoad("Config.lua")
local ESP = RequestLoad("Modules/ESP.lua")

-- [ ИНТЕРФЕЙС ]
local MainTab = Window:NewTab("Visuals")
local Section = MainTab:NewSection("ESP Settings")

Section:NewToggle("Enable ESP", "Запуск отрисовки", function(state)
    if _G.TridentConfig then _G.TridentConfig.ESP_Enabled = state end
end)

-- [ СТАРТ ]
if ESP and _G.TridentConfig then
    pcall(function() ESP:Start(_G.TridentConfig) end)
    print("[Trident] All systems online")
end
