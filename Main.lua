local Repo = 'https://raw.githubusercontent.com/rabuhin/Trident/main/'
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = Library.CreateLib("Trident Project | rabuhin", "DarkTheme")

local function Get(file)
    return loadstring(game:HttpGet(Repo .. file .. "?t=" .. os.time()))()
end

local ESP = Get("Modules/ESP.lua")
_G.TridentConfig = Get("Config.lua")

local MainTab = Window:NewTab("Visuals")
local VisSection = MainTab:NewSection("Player ESP (Radium Style)")

VisSection:NewToggle("Enable ESP", "Отрисовка боксов и линий", function(state)
    _G.TridentConfig.ESP_Enabled = state
end)

local SetTab = Window:NewTab("Settings")
local SetSection = SetTab:NewSection("Control")

SetSection:NewKeybind("Toggle Menu", "Скрыть меню", Enum.KeyCode.RightControl, function()
	Library:ToggleUI()
end)

SetSection:NewButton("Unload Cheat", "Полное удаление скрипта", function()
    if ESP then ESP:Unload() end
    for _, v in pairs(game:GetService("CoreGui"):GetChildren()) do
        if v.Name == "Trident Project | rabuhin" then v:Destroy() end
    end
end)

if ESP then
    ESP:Start(_G.TridentConfig)
end
