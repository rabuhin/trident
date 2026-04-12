-- [[ 1. ПРЕДОХРАНИТЕЛИ ]]
setfflag('DebugRunParallelLuaOnMainThread', 'True')

local Library = loadstring(game:HttpGet('https://raw.githubusercontent.com/wally-rbIx/LinoriaLib/main/Library.lua'))()
local Window = Library:CreateWindow({ Title = 'Trident | STABLE', Center = true, AutoShow = true })
local Tabs = { Main = Window:AddTab('Visuals') }

_G.TridentConfig = { ESP = false }
local ESP_Objects = {}

-- [[ 2. БЕЗОПАСНАЯ ОТРИСОВКА ]]
local function CreateESP(player)
    if player == game.Players.LocalPlayer then return end
    
    -- Создаем объекты один раз, а не в цикле
    local box = Drawing.new("Square")
    box.Visible = false
    local name = Drawing.new("Text")
    name.Visible = false

    local conn
    conn = game:GetService("RunService").RenderStepped:Connect(function()
        -- ГЛАВНАЯ ПРОВЕРКА: Если выключено — вообще ничего не считаем
        if not _G.TridentConfig.ESP then 
            box.Visible = false
            name.Visible = false
            return 
        end

        -- Защита от nil (чтобы не было 3000 ошибок)
        local success, err = pcall(function()
            local char = player.Character or workspace:FindFirstChild(player.Name)
            if char and char:FindFirstChild("HumanoidRootPart") then
                local root = char.HumanoidRootPart
                local pos, onScreen = workspace.CurrentCamera:WorldToViewportPoint(root.Position)
                
                if onScreen then
                    local dist = (root.Position - workspace.CurrentCamera.CFrame.Position).Magnitude
                    local size = 2000 / dist
                    
                    box.Size = Vector2.new(size, size * 1.5)
                    box.Position = Vector2.new(pos.X - size/2, pos.Y - size/2)
                    box.Visible = true

                    name.Text = player.Name
                    name.Position = Vector2.new(pos.X, pos.Y - size/2 - 15)
                    name.Visible = true
                else
                    box.Visible = false; name.Visible = false
                end
            else
                box.Visible = false; name.Visible = false
            end
        end)
        
        -- Если случилась ошибка — отключаем этот поток, чтобы не спамить
        if not success then 
            box.Visible = false
            name.Visible = false
            -- warn("ESP Error: " .. tostring(err)) -- Раскомментируй если хочешь видеть 1 ошибку вместо 3000
        end
    end)
    
    table.insert(ESP_Objects, {box, name, conn})
end

-- [[ 3. ИНТЕРФЕЙС ]]
local Group = Tabs.Main:AddLeftGroupbox('Players')
Group:AddToggle('EspToggle', {
    Text = 'Enable ESP',
    Default = false,
    Callback = function(Value)
        _G.TridentConfig.ESP = Value
        print("ESP Status:", Value)
    end
})

-- Запуск
for _, p in pairs(game.Players:GetPlayers()) do CreateESP(p) end
game.Players.PlayerAdded:Connect(CreateESP)
