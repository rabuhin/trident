local Repo = 'https://raw.githubusercontent.com/rabuhin/Trident/main/'
local Library = loadstring(game:HttpGet('https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/Library.lua'))()

local function GetModule(path)
    return loadstring(game:HttpGet(Repo .. path))()
end

local ESP = GetModule("Modules/ESP.lua")
_G.TridentConfig = GetModule("Config.lua")

-- Создание окна
local Window = Library:CreateWindow({
    Title = 'Trident Project | by rabuhin',
    Center = true,
    AutoShow = true,
    TabGuiNavigation = true
})

local Tabs = {
    Main = Window:AddTab('Visuals'),
    Settings = Window:AddTab('Settings'),
}

-- Настройки ESP
local VisualsSection = Tabs.Main:AddLeftGroupbox('ESP Settings')

VisualsSection:AddToggle('ESPEnabled', {
    Text = 'Enable ESP',
    Default = true,
    Callback = function(Value) _G.TridentConfig.ESP_Enabled = Value end
})

VisualsSection:AddToggle('OreESP', {
    Text = 'Show Resources (Ores)',
    Default = true,
    Callback = function(Value) _G.TridentConfig.Ores_Enabled = Value end
})

VisualsSection:AddSlider('ESPDistance', {
    Text = 'Max Distance',
    Default = 2000, Min = 100, Max = 5000, Rounding = 0,
    Callback = function(Value) _G.TridentConfig.ESP_Distance = Value end
})

-- Настройка цветов
VisualsSection:AddLabel('Menu Accent Color'):AddColorPicker('ColorPicker', {
    Default = Color3.fromRGB(0, 255, 123),
    Callback = function(Value) Library:SetWatermarkColor(Value) end
})

-- Кнопка выгрузки
local SettingsSection = Tabs.Settings:AddLeftGroupbox('Menu Control')
SettingsSection:AddButton('Unload Cheat', function() Library:Unload() end)

-- Запуск логики
ESP:Start(_G.TridentConfig)
Library:Notify("Script Loaded! Use RightControl to hide menu.")
