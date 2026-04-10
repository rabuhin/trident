local Repo = 'https://raw.githubusercontent.com/rabuhin/Trident/main/'
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = Library.CreateLib("Trident Project | rabuhin", "DarkTheme")

-- Загрузка модулей
local function Get(file)
    return loadstring(game:HttpGet(Repo .. file .. "?t=" .. os.time()))()
end

local ESP = Get("Modules/ESP.lua")
_G.TridentConfig = Get("Config.lua")

-- Интерфейс
local MainTab = Window:NewTab("Visuals")
local Section = MainTab:NewSection("ESP Settings")

Section:NewToggle("Enable ESP", "Включить/Выключить ESP", function(state)
    _G.TridentConfig.ESP_Enabled = state
end)

Section:NewToggle("Show Ores", "Показывать руду", function(state)
    _G.TridentConfig.Ores_Enabled = state
end)

local SettingsTab = Window:NewTab("Settings")
local SetSection = SettingsTab:NewSection("Menu")

SetSection:NewKeybind("Toggle Menu", "Скрыть меню", Enum.KeyCode.RightControl, function()
	Library:ToggleUI()
end)

SetSection:NewButton("Unload Cheat", "Полная выгрузка", function()
    ESP:Unload()
    for _, v in pairs(game:GetService("CoreGui"):GetChildren()) do
        if v.Name == "Trident Project | rabuhin" or v:FindFirstChild("Main") then v:Destroy() end
    end
end)

-- Старт
if ESP then
    ESP:Start(_G.TridentConfig)
end
