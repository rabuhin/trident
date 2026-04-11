-- [[ TRIDENT PROJECT: ULTIMATE PARALLEL LOADER ]]

-- 1. ВКЛЮЧАЕМ ПАРАЛЛЕЛЬНЫЙ ЛУА (Тот самый важный флаг)
local success_flag, err_flag = pcall(function()
    setfflag('DebugRunParallelLuaOnMainThread', 'True')
end)

if not success_flag then
    warn("[Trident] Не удалось установить FFlag. Попробуй инжектнуть его вручную перед скриптом.")
end

-- 2. ГОРЯЧИЕ ИСПРАВЛЕНИЯ ДЛЯ POTASSIUM
if (type(getgenv) == 'function' and getgenv().setfflag == nil) then
    getgenv().setfflag = function() end;
end;

local request = request or http_request
local Repo = "https://raw.githubusercontent.com/rabuhin/Trident/main/Modules/"

-- Функция безопасной загрузки модулей
local function GetModule(name)
    local success, response = pcall(request, {
        Url = Repo .. name .. "?t=" .. os.time(), 
        Method = "GET"
    })
    if success and response.StatusCode == 200 then
        return loadstring(response.Body)()
    end
    warn("[Trident] Ошибка загрузки модуля: " .. name)
end

-- 3. ЗАПУСК МОСТА ДЛЯ ОТРИСОВКИ (ACTOR FIX)
-- Это то, что позволяет рисовать ESP, когда игра работает в параллельных потоках
local actorFixSource = GetModule("actorDrawingFix.lua")
if actorFixSource then
    loadstring(actorFixSource)()
    print("[Trident] Actor Drawing Bridge: INITIALIZED")
end

-- Настройка шрифтов
GetModule("drawingSetup.lua")

-- 4. ЗАГРУЗКА БИБЛИОТЕК ИЗ ТВОИХ ФАЙЛОВ
local uiLibrary = GetModule("uiLibrary.lua")
local espLibrary = GetModule("espLibrary.lua")

-- 5. СОЗДАНИЕ МЕНЮ (Используем Kavo или твой новый uiLibrary)
-- Чтобы не усложнять, пока оставим запуск интерфейса Kavo, 
-- но теперь он будет работать поверх исправленного Drawing API.

local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = Library.CreateLib("Trident | Parallel Mode", "DarkTheme")

local MainTab = Window:NewTab("Visuals")
local Section = MainTab:NewSection("Parallel ESP")

Section:NewToggle("Enable ESP", "Отрисовка в реальном времени", function(state)
    if _G.TridentConfig then
        _G.TridentConfig.ESP_Enabled = state
    end
end)

-- Подгружаем конфиг
_G.TridentConfig = GetModule("Config.lua") or { ESP_Enabled = false }

print("[Trident] Script Fully Loaded with Parallel Support!")
