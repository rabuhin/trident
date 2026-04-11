-- [[ TRIDENT PROJECT: ULTIMATE RECONSTRUCTION ]]

-- 1. Исправление окружения для Potassium
if (type(getgenv) == 'function' and getgenv().setfflag == nil) then
    getgenv().setfflag = function() end;
end;

local request = request or http_request
local Repo = "https://raw.githubusercontent.com/rabuhin/Trident/main/Modules/"

-- Функция загрузки через Request (как в амонгус-хуке)
local function GetModule(name)
    local success, response = pcall(request, {
        Url = Repo .. name .. "?t=" .. os.time(), 
        Method = "GET"
    })
    if success and response.StatusCode == 200 then
        return loadstring(response.Body)()
    end
    warn("[Trident] Missing module: " .. name)
end

-- 2. Инициализация критических систем
-- Сначала запускаем мост для отрисовки в акторах
local actorFixSource = GetModule("actorDrawingFix.lua")
if actorFixSource then
    -- Этот модуль возвращает строку-скрипт для актора, запускаем её
    loadstring(actorFixSource)()
end

-- Настраиваем шрифты под экзекутор
GetModule("drawingSetup.lua")

-- 3. Загрузка библиотек
local uiLibrary = GetModule("uiLibrary.lua")
local espLibrary = GetModule("espLibrary.lua")

-- 4. Инициализация (Пример на Kavo, пока ты не решишь перейти на UI амонгуса)
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = Library.CreateLib("Trident Project | Actors Fixed", "DarkTheme")

local MainTab = Window:NewTab("Visuals")
local Section = MainTab:NewSection("ESP Logic")

Section:NewToggle("Enable ESP", "Запуск через Parallel Drawing", function(state)
    _G.TridentConfig.ESP_Enabled = state
end)

print("[Trident] Parallel Drawing Bridge: ACTIVE")
print("[Trident] ESP Logic: LOADED")
