-- [[ TRIDENT PROJECT: MERGED EDITION ]]
pcall(function() setfflag('DebugRunParallelLuaOnMainThread', 'True') end)

local Library = loadstring(game:HttpGet('https://raw.githubusercontent.com/wally-rbIx/LinoriaLib/main/Library.lua'))()
local Window = Library:CreateWindow({ Title = 'Trident | Merged Build', Center = true, AutoShow = true })

local Tabs = {
    Combat = Window:AddTab('Combat'),
    Visuals = Window:AddTab('Visuals'),
    Settings = Window:AddTab('Settings')
}

_G.Config = {
    ESP = false,
    SilentAim = false,
    NoRecoil = false,
    FOV = 150,
    MaxDist = 500
}

local ESP_Table = {}

-- [[ 1. COMBAT LOGIC (DEOBFUSCATED FROM EXCLUDEX) ]]
local function GetClosestToMouse()
    local target = nil
    local maxDist = _G.Config.FOV
    local mousePos = game:GetService("UserInputService"):GetMouseLocation()

    for _, p in pairs(game.Players:GetPlayers()) do
        if p ~= game.Players.LocalPlayer and p.Character and p.Character:FindFirstChild("Head") then
            -- Проверка на спящих
            local head = p.Character.Head
            local isSleeping = head.Rotation.Z > 0.5 or head.Rotation.Z < -0.5
            
            if not isSleeping then
                local pos, onScreen = workspace.CurrentCamera:WorldToViewportPoint(head.Position)
                if onScreen then
                    local dist = (Vector2.new(pos.X, pos.Y) - mousePos).Magnitude
                    if dist < maxDist then
                        maxDist = dist
                        target = head
                    end
                end
            end
        end
    end
    return target
end

-- Хуки для Combat (Silent Aim & No Recoil)
local OldNamecall
OldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
    local method = getnamecallmethod()
    local args = {...}

    -- Silent Aim
    if _G.Config.SilentAim and method == "FireServer" and self.Name == "Network" and args[1] == "ProjectileFire" then
        local target = GetClosestToMouse()
        if target then
            args[3] = target.Position -- Подменяем точку попадания
            return OldNamecall(self, unpack(args))
        end
    end
    
    -- No Recoil (Хук на камеру)
    if _G.Config.NoRecoil and method == "Recoil" then
        return
    end

    return OldNamecall(self, ...)
end))

-- [[ 2. VISUALS LOGIC ]]
local function ApplyESP(player)
    local box = Drawing.new("Square")
    local name = Drawing.new("Text")
    name.Size = 14; name.Center = true; name.Outline = true

    local conn = game:GetService("RunService").RenderStepped:Connect(function()
        if not _G.Config.ESP then box.Visible = false; name.Visible = false; return end

        pcall(function()
            local char = player.Character or workspace:FindFirstChild(player.Name)
            if char and char:FindFirstChild("HumanoidRootPart") then
                local root = char.HumanoidRootPart
                local pos, onScreen = workspace.CurrentCamera:WorldToViewportPoint(root.Position)
                local dist = (root.Position - workspace.CurrentCamera.CFrame.Position).Magnitude

                if onScreen and dist <= _G.Config.MaxDist then
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
    end)
    ESP_Table[player] = {box, name, conn}
end

-- [[ 3. ИНТЕРФЕЙС ]]
local CombatGroup = Tabs.Combat:AddLeftGroupbox('Combat Functions')
CombatGroup:AddToggle('SilentAim', { Text = 'Silent Aim', Default = false, Callback = function(v) _G.Config.SilentAim = v end })
CombatGroup:AddToggle('NoRecoil', { Text = 'No Recoil', Default = false, Callback = function(v) _G.Config.NoRecoil = v end })
CombatGroup:AddSlider('FOV', { Text = 'Silent FOV', Default = 150, Min = 50, Max = 500, Rounding = 0, Callback = function(v) _G.Config.FOV = v end })

local VisualGroup = Tabs.Visuals:AddLeftGroupbox('ESP Settings')
VisualGroup:AddToggle('EspToggle', { Text = 'Enable ESP', Default = false, Callback = function(v) _G.Config.ESP = v end })
VisualGroup:AddSlider('MaxDist', { Text = 'Render Distance', Default = 500, Min = 100, Max = 2000, Rounding = 0, Callback = function(v) _G.Config.MaxDist = v end })

Tabs.Settings:AddButton('UNLOAD CHEAT', function()
    _G.Config.ESP = false
    for _, obj in pairs(ESP_Table) do
        obj[1]:Remove(); obj[2]:Remove(); obj[3]:Disconnect()
    end
    Library:Unload()
end)

-- Запуск
for _, p in pairs(game.Players:GetPlayers()) do if p ~= game.Players.LocalPlayer then ApplyESP(p) end end
game.Players.PlayerAdded:Connect(ApplyESP)

Library:Notify("Trident Merged Loaded!")
