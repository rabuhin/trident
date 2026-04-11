-- [ FIX: DRAWING API EMULATION ]
if not getgenv().Drawing then
    loadstring(game:HttpGet("https://raw.githubusercontent.com/rabuhin/Trident/main/Modules/DrawingFix.lua"))()
end

local Repo = 'https://raw.githubusercontent.com/rabuhin/Trident/main/'
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()

-- Создаем окно (БЕЗ Watermark, чтобы не было ошибок)
local Window = Library.CreateLib("Trident Project | rabuhin", "DarkTheme")

local function Get(file)
    return loadstring(game:HttpGet(Repo .. file .. "?t=" .. os.time()))()
end

-- Загрузка модулей
local ESP = Get("Modules/ESP.lua")
_G.TridentConfig = Get("Config.lua")

-- Вкладка Visuals
local MainTab = Window:NewTab("Visuals")
local VisSection = MainTab:NewSection("Player ESP")

VisSection:NewToggle("Enable ESP", "Подсветка игроков", function(state)
    _G.TridentConfig.ESP_Enabled = state
end)

-- Вкладка Settings
local SetTab = Window:NewTab("Settings")
local SetSection = SetTab:NewSection("Control")

SetSection:NewKeybind("Toggle Menu", "Скрыть/Показать", Enum.KeyCode.RightControl, function()
    Library:ToggleUI()
end)

SetSection:NewButton("Unload Cheat", "Удалить чит", function()
    if ESP then ESP:Unload() end
    Library:Unload()
end)

-- Старт логики
if ESP then
    ESP:Start(_G.TridentConfig)
    print("ESP Module: Logic Started")
end

print("--- TRIDENT SCRIPT BY RABUHIN LOADED ---")
