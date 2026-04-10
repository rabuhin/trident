local Repo = 'https://raw.githubusercontent.com/rabuhin/Trident/main/'
-- Используем библиотеку в стиле AmongUs Hook / Venyx
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/zxciaz/VenyxUI/main/Reallib.lua"))()
local Venyx = Library.new("Trident Project | rabuhin")

local function GetModule(path)
    local url = Repo .. path .. "?t=" .. os.time() -- Обход кеша
    local success, result = pcall(function() return game:HttpGet(url) end)
    if success then return loadstring(result)() end
end

local ESP = GetModule("Modules/ESP.lua")
_G.TridentConfig = GetModule("Config.lua")

-- Темы (AmongUs Hook Style)
local MainTab = Venyx:addPage("Main", 5012544693)
local Visuals = MainTab:addSection("Visuals")
local Settings = MainTab:addPage("Settings", 5012544693)
local MenuControl = Settings:addSection("Menu Control")

Visuals:addToggle("Enable ESP", true, function(val) 
    _G.TridentConfig.ESP_Enabled = val 
end)

Visuals:addToggle("Show Resources", true, function(val) 
    _G.TridentConfig.Ores_Enabled = val 
end)

Visuals:addSlider("Max Distance", 2000, 100, 5000, function(val) 
    _G.TridentConfig.ESP_Distance = val 
end)

-- Настройка цвета в стиле AmongUs Hook
Visuals:addColorPicker("ESP Color", Color3.fromRGB(0, 255, 123), function(color)
    Venyx:setTheme("Accent", color)
end)

-- Тот самый Unload Cheat
MenuControl:addButton("Unload Cheat", function()
    if ESP then ESP:Unload() end
    game:GetService("CoreGui")["Trident Project | rabuhin"]:Destroy()
    print("--- SCRIPT UNLOADED ---")
end)

-- Клавиша закрытия меню
MenuControl:addKeybind("Toggle Menu", Enum.KeyCode.RightControl, function()
    Venyx:toggle()
end)

if ESP then
    ESP:Start(_G.TridentConfig)
end
