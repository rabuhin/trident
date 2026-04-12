-- [[ 1. ПРЕДОХРАНИТЕЛИ ]]
if not game:IsLoaded() then game.Loaded:Wait() end
pcall(function() setfflag('DebugRunParallelLuaOnMainThread', 'True') end)

local Library = loadstring(game:HttpGet('https://raw.githubusercontent.com/wally-rbIx/LinoriaLib/main/Library.lua'))()
local Window = Library:CreateWindow({ Title = 'Trident | Silent Build', Center = true, AutoShow = true })
local Tabs = { Main = Window:AddTab('Visuals') }

_G.TridentConfig = { ESP = false }
local ESP_Table = {}

-- [[ 2. БЕЗОПАСНАЯ ФУНКЦИЯ ESP ]]
local function ApplyESP(player)
    if player == game.Players.LocalPlayer then return end

    local box = Drawing.new("Square")
    box.Visible = false
    box.Thickness = 1
    box.Color = Color3.new(1, 1, 1)

    local name = Drawing.new("Text")
    name.Visible = false
    name.Size = 14
    name.Center = true
    name.Outline = true

    local connection
    connection = game:GetService("RunService").RenderStepped:Connect(function()
        -- ГЛАВНЫЙ СТОП-КРАН: Если галка выключена - ВООБЩЕ ничего не делаем
        if not _G.TridentConfig.ESP then 
            box.Visible = false
            name.Visible = false
            return 
        end

        -- БЕЗОПАСНЫЙ ПОИСК (pcall глушит все ошибки в консоли)
        local ok, err = pcall(function()
            local char = player.Character or workspace:FindFirstChild(player.Name)
            -- Проверка: есть ли персонаж и не в лобби ли мы?
            if char and char:FindFirstChild("HumanoidRootPart") then
                local root = char.HumanoidRootPart
                local cam = workspace.CurrentCamera
                local pos, onScreen = cam:WorldToViewportPoint(root.Position)
                
                if onScreen then
                    local dist = (root.Position - cam.CFrame.Position).Magnitude
                    local size = math.clamp(2000 / dist, 5, 300) -- Ограничение размера
                    
                    box.Size = Vector2.new(size, size * 1.5)
                    box.Position = Vector2.new(pos.X - size/2, pos.Y - size/2)
                    box.Visible = true

                    name.Text = player.Name .. " [" .. math.floor(dist) .. "]"
                    name.Position = Vector2.new(pos.X, pos.Y - size/2 - 15)
                    name.Visible = true
                else
                    box.Visible = false
                    name.Visible = false
                end
            else
                box.Visible = false
                name.Visible = false
            end
        end)
        
        -- Если всё-таки лезет ошибка - вырубаем поток для этого игрока
        if not ok then 
            box.Visible = false
            name.Visible = false
        end
    end)

    ESP_Table[player] = {box, name, connection}
end

-- [[ 3. ИНТЕРФЕЙС ]]
local Group = Tabs.Main:AddLeftGroupbox('Players')
Group:AddToggle('EspToggle', {
    Text = 'Enable ESP',
    Default = false,
    Callback = function(Value)
        _G.TridentConfig.ESP = Value
    end
})

-- [[ 4. СТАРТ ]]
for _, p in pairs(game.Players:GetPlayers()) do ApplyESP(p) end
game.Players.PlayerAdded:Connect(ApplyESP)

-- Очистка при выходе игрока
game.Players.PlayerRemoving:Connect(function(p)
    if ESP_Table[p] then
        ESP_Table[p][1]:Remove()
        ESP_Table[p][2]:Remove()
        ESP_Table[p][3]:Disconnect()
        ESP_Table[p] = nil
    end
end)
