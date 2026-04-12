-- [[ 1. ПОДГОТОВКА ]]
pcall(function() setfflag('DebugRunParallelLuaOnMainThread', 'True') end)

local Library = loadstring(game:HttpGet('https://raw.githubusercontent.com/wally-rbIx/LinoriaLib/main/Library.lua'))()
local Window = Library:CreateWindow({ Title = 'Trident | Stable Build', Center = true, AutoShow = true })
local Tabs = { Main = Window:AddTab('Visuals'), Settings = Window:AddTab('Settings') }

_G.TridentConfig = { ESP = false }
local ESP_Table = {}
local MainLoop = nil -- Переменная для цикла

-- [[ 2. ФУНКЦИЯ ОЧИСТКИ (UNLOAD) ]]
local function UnloadCheat()
    _G.TridentConfig.ESP = false
    if MainLoop then MainLoop:Disconnect() end
    task.wait(0.1)
    for _, obj in pairs(ESP_Table) do
        pcall(function() obj.Box:Remove(); obj.Name:Remove() end)
    end
    table.clear(ESP_Table)
    Library:Unload()
end

-- [[ 3. ГЛАВНЫЙ ЦИКЛ (ЗАПУСКАЕТСЯ ТОЛЬКО ПО КНОПКЕ) ]]
local function StartESP()
    if MainLoop then return end -- Чтобы не запускать дважды
    
    MainLoop = game:GetService("RunService").RenderStepped:Connect(function()
        if not _G.TridentConfig.ESP then return end
        
        for _, player in pairs(game.Players:GetPlayers()) do
            if player ~= game.Players.LocalPlayer then
                local container = ESP_Table[player]
                if not container then
                    ESP_Table[player] = {
                        Box = Drawing.new("Square"),
                        Name = Drawing.new("Text")
                    }
                    container = ESP_Table[player]
                end

                pcall(function()
                    local char = player.Character or workspace:FindFirstChild(player.Name)
                    -- ПРОВЕРКА: Если мы не в игре или персонаж далеко - скрываем
                    if char and char:FindFirstChild("HumanoidRootPart") then
                        local root = char.HumanoidRootPart
                        local pos, onScreen = workspace.CurrentCamera:WorldToViewportPoint(root.Position)
                        
                        if onScreen then
                            local dist = (root.Position - workspace.CurrentCamera.CFrame.Position).Magnitude
                            if dist < 1000 then
                                local size = 2000 / dist
                                container.Box.Size = Vector2.new(size, size * 1.5)
                                container.Box.Position = Vector2.new(pos.X - size/2, pos.Y - size/2)
                                container.Box.Visible = true
                                
                                container.Name.Text = player.Name
                                container.Name.Position = Vector2.new(pos.X, pos.Y - size/2 - 15)
                                container.Name.Visible = true
                                return
                            end
                        end
                    end
                    container.Box.Visible = false
                    container.Name.Visible = false
                end)
            end
        end
    end)
end

-- [[ 4. ИНТЕРФЕЙС ]]
local VisualsGroup = Tabs.Main:AddLeftGroupbox('Players')

VisualsGroup:AddToggle('EspToggle', {
    Text = 'Enable ESP',
    Default = false,
    Callback = function(Value)
        _G.TridentConfig.ESP = Value
        if Value then 
            StartESP() -- Запускаем цикл только когда включили галку
        end
    end
})

local SettingsGroup = Tabs.Settings:AddLeftGroupbox('Menu')
SettingsGroup:AddButton('UNLOAD CHEAT', UnloadCheat)

Library:Notify("Script Loaded. Use toggle to start ESP.")
