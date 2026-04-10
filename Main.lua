local Repo = 'https://raw.githubusercontent.com/rabuhin/Trident/main/'
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = Library.CreateLib("Trident Project | rabuhin", "DarkTheme")

local function Get(file)
    return loadstring(game:HttpGet(Repo .. file .. "?t=" .. os.time()))()
end

local ESP = Get("Modules/ESP.lua")
_G.TridentConfig = Get("Config.lua")

local MainTab = Window:NewTab("Visuals")
local VisSection = MainTab:NewSection("Player ESP")

VisSection:NewToggle("Enable ESP", "Показать игроков", function(state)
    _G.TridentConfig.ESP_Enabled = state
end)

local SetTab = Window:NewTab("Settings")
local SetSection = SetTab:NewSection("Control")

SetSection:NewButton("Unload Cheat", "Выход", function()
    if ESP then ESP:Unload() end
    for _, v in pairs(game:GetService("CoreGui"):GetChildren()) do
        if v.Name == "Trident Project | rabuhin" then v:Destroy() end
    end
end)

SetSection:NewKeybind("Toggle Menu", "Закрыть UI", Enum.KeyCode.RightControl, function()
	Library:ToggleUI()
end)

if ESP then
    ESP:Start(_G.TridentConfig)
end
