local Repo = 'https://raw.githubusercontent.com/rabuhin/Trident/main/'
local Library = loadstring(game:HttpGet('https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/Library.lua'))()

local function GetModule(path)
    local success, result = pcall(function()
        return game:HttpGet(Repo .. path)
    end)
    if success then return loadstring(result)() end
end

local ESP = GetModule("Modules/ESP.lua")
_G.TridentConfig = GetModule("Config.lua")

local Window = Library:CreateWindow({
    Title = 'Trident Project | rabuhin',
    Center = true,
    AutoShow = true,
})

local Tabs = {
    Main = Window:AddTab('Visuals'),
    Settings = Window:AddTab('Settings'),
}

local VisualsSection = Tabs.Main:AddLeftGroupbox('ESP Settings')

VisualsSection:AddToggle('ESPEnabled', {
    Text = 'Enable ESP',
    Default = true,
    Callback = function(Value) _G.TridentConfig.ESP_Enabled = Value end
})

VisualsSection:AddToggle('OreESP', {
    Text = 'Show Resources',
    Default = true,
    Callback = function(Value) _G.TridentConfig.Ores_Enabled = Value end
})

VisualsSection:AddSlider('ESPDistance', {
    Text = 'Max Distance',
    Default = 2000, Min = 100, Max = 5000, Rounding = 0,
    Callback = function(Value) _G.TridentConfig.ESP_Distance = Value end
})

-- Исправленная настройка цвета (меняет акцент меню)
VisualsSection:AddLabel('Menu Color'):AddColorPicker('ColorPicker', {
    Default = Color3.fromRGB(0, 255, 123),
    Callback = function(Value) 
        Library.AccentColor = Value
        Library:UpdateColors()
    end
})

local SettingsSection = Tabs.Settings:AddLeftGroupbox('Menu Control')

SettingsSection:AddButton('Unload Cheat', function() 
    Library:Unload() 
end)

SettingsSection:AddLabel('Menu Keybind'):AddKeyPicker('MenuKeybind', {
    Default = 'RightControl',
    NoUI = true,
    Text = 'Menu Keybind',
    Callback = function() Library:Toggle() end
})

if ESP then
    ESP:Start(_G.TridentConfig)
    Library:Notify("Success! Press RightControl to toggle menu.")
end
