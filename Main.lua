-- [ ПРОВЕРКА И ФИКС DRAWING API ]
local function CheckDrawing()
    local success, drawing = pcall(function() return Drawing.new("Line") end)
    if not success or not drawing then
        return false
    end
    drawing:Remove()
    return true
end

if not CheckDrawing() then
    -- Загружаем фикс напрямую, если Drawing API не найден или не работает
    loadstring(game:HttpGet("https://raw.githubusercontent.com/rabuhin/Trident/main/Modules/DrawingFix.lua"))()
end

local Repo = 'https://raw.githubusercontent.com/rabuhin/Trident/main/'
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = Library.CreateLib("Trident Project | rabuhin", "DarkTheme")

-- Функция загрузки без getgenv
local function Get(file)
    return loadstring(game:HttpGet(Repo .. file .. "?t=" .. os.time()))()
end

local ESP = Get("Modules/ESP.lua")
_G.TridentConfig = Get("Config.lua")

-- [ ТУТ ДАЛЬШЕ ТВОЙ КОД МЕНЮ ]
-- Обязательно убедись, что нигде нет лишних символов *
