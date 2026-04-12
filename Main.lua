-- [[ 1. ПОДГОТОВКА ]]
pcall(function() setfflag('DebugRunParallelLuaOnMainThread', 'True') end)

local Library = loadstring(game:HttpGet('https://raw.githubusercontent.com/wally-rbIx/LinoriaLib/main/Library.lua'))()
local Window = Library:CreateWindow({ Title = 'Trident | Final Stability', Center = true, AutoShow = true })
local Tabs = { Main = Window:AddTab('Visuals'), Settings = Window:AddTab('Settings') }

_G.TridentConfig = { ESP = false, MaxDist = 500 }
local ESP_Table = {}

-- [[ 2. ФУНКЦИЯ ОЧИСТКИ (UNLOAD) ]]
local function UnloadCheat()
    _G.TridentConfig.ESP = false
    task.wait(0.1)
    for player, objects in pairs(ESP_Table) do
        if objects.Box then objects.Box:Remove() end
        if objects.Name then objects.Name:Remove() end
        if objects.Conn then objects.Conn:Disconnect() end
    end
    table.clear(ESP_Table)
    Library:Unload()
    print("[Trident] Script Unloaded")
end

-- [[ 3. ЛОГИКА ESP С ЗАЩИТОЙ ОТ ДИСТАНЦИИ ]]
local function ApplyESP(player)
    if player == game.Players.LocalPlayer then return end

    local box = Drawing.new("Square")
    box.Visible = false
    local name = Drawing.new("Text")
    name.Visible = false
    name.Size = 14
    name.Center = true
    name.Outline = true

    local connection = game:GetService("RunService").RenderStepped:Connect(function()
        if not _G.TridentConfig.ESP then 
            box.Visible = false; name.Visible = false
            return 
        end

        local char = player.Character or workspace:FindFirstChild(player.Name)
        if char and char:FindFirstChild("HumanoidRootPart") then
            local root = char.HumanoidRootPart
            local cam = workspace.CurrentCamera
            local pos, onScreen = cam:WorldToViewportPoint(root.Position)
            
            if onScreen then
                local dist = (root.Position - cam.CFrame.Position).Magnitude
                
                -- ПРОВЕРКА ДИСТАНЦИИ (Твой вопрос про Render Distance)
                if dist <= _G.TridentConfig.MaxDist then
                    local size = 2000 / dist
                    box.Size = Vector2.new(size, size * 1.5)
                    box.Position = Vector2.new(pos.X - size/2, pos.Y - size/2)
                    box.Color = Color3.new(1, 1, 1)
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
        else
            box.Visible = false; name.Visible = false
        end
    end)

    ESP_Table[player] = {Box = box, Name = name, Conn = connection}
end

-- [[ 4. ИНТЕРФЕЙС ]]
local VisualsGroup = Tabs.Main:AddLeftGroupbox('Player Visuals')

VisualsGroup:AddToggle('EspToggle', {
    Text = 'Enable ESP',
    Default = false,
    Callback = function(Value) _G.TridentConfig.ESP = Value end
})

VisualsGroup:AddSlider('MaxDist', {
    Text = 'Max Render Distance',
    Default = 500, Min = 100, Max = 2000, Rounding = 0,
    Callback = function(Value) _G.TridentConfig.MaxDist = Value end
})

local SettingsGroup = Tabs.Settings:AddLeftGroupbox('Menu Management')
SettingsGroup:AddButton('UNLOAD CHEAT', UnloadCheat)

-- [[ 5. ЗАПУСК ]]
for _, p in pairs(game.Players:GetPlayers()) do ApplyESP(p) end
game.Players.PlayerAdded:Connect(ApplyESP)

game.Players.PlayerRemoving:Connect(function(p)
    if ESP_Table[p] then
        ESP_Table[p].Box:Remove()
        ESP_Table[p].Name:Remove()
        ESP_Table[p].
