-- [[ 1. ПОДГОТОВКА СРЕДЫ ]]
setfflag('DebugRunParallelLuaOnMainThread', 'True')

if (type(getgenv) == 'function' and getgenv().setfflag == nil) then
    getgenv().setfflag = function() end
end

local Repo = "https://raw.githubusercontent.com/rabuhin/Trident/main/Modules/"
local request = request or http_request

-- [[ 2. ЗАГРУЗКА ФИКСОВ (Без них Trident не даст рисовать) ]]
local function GetFile(name)
    local res = request({Url = Repo .. name .. "?t=" .. os.time(), Method = "GET"})
    return res.StatusCode == 200 and res.Body or nil
end

local actorFix = GetFile("actorDrawingFix.lua")
if actorFix then loadstring(loadstring(actorFix)())() end
loadstring(GetFile("drawingSetup.lua") or "")()

-- [[ 3. БИБЛИОТЕКА ИНТЕРФЕЙСА (Linoria - самая стабильная) ]]
local Library = loadstring(game:HttpGet('https://raw.githubusercontent.com/wally-rbIx/LinoriaLib/main/Library.lua'))()

local Window = Library:CreateWindow({
    Title = 'Trident Survival | Revived',
    Center = true,
    AutoShow = true,
})

local Tabs = {
    Main = Window:AddTab('Visuals'),
    Settings = Window:AddTab('Settings'),
}

-- [[ 4. ЛОГИКА ESP (Переписанная под Potassium) ]]
_G.TridentConfig = { ESP = false }
local ESP_Objects = {}

local function CreateESP(player)
    if player == game.Players.LocalPlayer then return end
    
    local box = Drawing.new("Square")
    box.Thickness = 1
    box.Filled = false
    box.Color = Color3.new(1, 1, 1)
    
    local name = Drawing.new("Text")
    name.Size = 14
    name.Center = true
    name.Outline = true
    name.Color = Color3.new(1, 1, 1)

    local connection
    connection = game:GetService("RunService").RenderStepped:Connect(function()
        local char = player.Character or workspace:FindFirstChild(player.Name)
        if char and char:FindFirstChild("HumanoidRootPart") and _G.TridentConfig.ESP then
            local root = char.HumanoidRootPart
            local pos, onScreen = workspace.CurrentCamera:WorldToViewportPoint(root.Position)
            
            if onScreen then
                local dist = (root.Position - workspace.CurrentCamera.CFrame.Position).Magnitude
                local size = 2000 / dist
                
                box.Size = Vector2.new(size, size * 1.5)
                box.Position = Vector2.new(pos.X - size/2, pos.Y - size/2)
                box.Visible = true

                name.Text = player.Name .. " [" .. math.floor(dist) .. "m]"
                name.Position = Vector2.new(pos.X, pos.Y - size/2 - 15)
                name.Visible = true
            else
                box.Visible = false; name.Visible = false
            end
        else
            box.Visible = false; name.Visible = false
        end
    end)
    
    table.insert(ESP_Objects, {box, name, connection})
end

-- [[ 5. НАПОЛНЕНИЕ МЕНЮ ]]
local VisualsGroup = Tabs.Main:AddLeftGroupbox('Player ESP')

VisualsGroup:AddToggle('EspToggle', {
    Text = 'Enable ESP',
    Default = false,
    Callback = function(Value)
        _G.TridentConfig.ESP = Value
    end
})

-- [[ 6. КНОПКА UNLOAD (Реально рабочая) ]]
local SettingsGroup = Tabs.Settings:AddLeftGroupbox('Menu')

SettingsGroup:AddButton('Unload Script', function()
    _G.TridentConfig.ESP = false
    for _, data in pairs(ESP_Objects) do
        data[1]:Remove() -- Box
        data[2]:Remove() -- Text
        data[3]:Disconnect() -- Connection
    end
    Library:Unload()
end)

-- Запуск для всех игроков
for _, p in pairs(game.Players:GetPlayers()) do CreateESP(p) end
game.Players.PlayerAdded:Connect(CreateESP)

Library:Notify("Script Loaded! Use it in-game.")
