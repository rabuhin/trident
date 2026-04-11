-- [ FIX: DRAWING API EMULATION ]
if not genv.Drawing then
    -- Тот самый код, который ты нашел (я сократил его для стабильности)
    -- Теперь Drawing.new будет создавать реальные объекты, которые ТЫ УВИДИШЬ
    loadstring(game:HttpGet("https://raw.githubusercontent.com/rabuhin/Trident/main/Modules/DrawingFix.lua"))()
end

local Repo = 'https://raw.githubusercontent.com/rabuhin/Trident/main/'
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = Library.CreateLib("Trident Project | rabuhin", "DarkTheme")

-- Загрузка модулей
local function Get(file)
    return loadstring(game:HttpGet(Repo .. file .. "?t=" .. os.time()))()
end

local ESP = Get("Modules/ESP.lua")
_G.TridentConfig = Get("Config.lua")

-- Интерфейс (Visuals)
local MainTab = Window:NewTab("Visuals")
local Section = MainTab:NewSection("ESP Settings")

Section:NewToggle("Enable ESP", "Показать игроков", function(state)
    _G.TridentConfig.ESP_Enabled = state
end)

-- Настройки (Settings)
local SettingsTab = Window:NewTab("Settings")
local SetSection = SettingsTab:NewSection("Menu")

SetSection:NewButton("Unload Cheat", "Полная выгрузка", function()
    if ESP then ESP:Unload() end
    Library:Unload()
end)

-- Старт
if ESP then
    ESP:Start(_G.TridentConfig)
end
