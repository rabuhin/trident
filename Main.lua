-- [[ TRIDENT PROJECT: STABLE REBUILT ]]
pcall(function() setfflag('DebugRunParallelLuaOnMainThread', 'True') end)

local Library = loadstring(game:HttpGet('https://raw.githubusercontent.com/wally-rbIx/LinoriaLib/main/Library.lua'))()
local Window = Library:CreateWindow({ Title = 'Trident | STABLE BUILD', Center = true, AutoShow = true })

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
    MaxDist = 600
}

local ESP_Table = {}

-- [[ 1. COMBAT: SILENT AIM & NO RECOIL ]]
local function GetClosestToMouse()
    local target = nil
    local maxDist = _G.Config.FOV
    local mousePos = game:GetService("UserInputService"):GetMouseLocation()

    for _, p in pairs(game.Players:GetPlayers()) do
        if p ~= game.Players.LocalPlayer and p.Character and p.Character:FindFirstChild("Head") then
            local head = p.Character.Head
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
    return target
end

local OldNamecall
OldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
    local method = getnamecallmethod()
    local args = {...}

    if _G.Config.SilentAim and method == "FireServer" and self.Name == "Network" and args[1] == "ProjectileFire" then
        local target = GetClosestToMouse()
        if target then
            args[3] = target.Position
            return OldNamecall(self, unpack(args))
        end
    end
    
    if _G.Config.NoRecoil and method == "Recoil" then return end
    return OldNamecall(self, ...)
end))

-- [[ 2. VISUALS: ESP ]]
local function ApplyESP(player)
    if player == game.Players.LocalPlayer then return end
    
    local box = Drawing.new("Square")
    box.Visible = false
    box.Thickness = 1
    box.Color = Color3.fromRGB(255, 255, 255)

    local name = Drawing.new("Text")
    name.Visible = false
    name.Size = 14
    name.Center = true
    name.Outline = true
    name.Color = Color3.fromRGB(255, 255, 255)

    local connection = game:GetService("RunService").RenderStepped:Connect(function()
        if not _G.Config.ESP then 
            box.Visible = false; name.Visible = false
            return 
        end

        local char = player.Character or workspace:FindFirstChild(player.Name)
        if char and char:FindFirstChild("HumanoidRootPart") then
            local root = char.HumanoidRootPart
            local pos, onScreen = workspace.CurrentCamera:WorldToViewportPoint(root.Position)
            
            if onScreen then
                local dist = (root.Position - workspace.CurrentCamera.CFrame.Position).Magnitude
                if dist <= _G.Config.MaxDist then
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
        else
            box.Visible = false; name.Visible = false
        end
    end)
    ESP_Table[player] = {box, name, connection}
end

-- [[ 3. ИНТЕРФЕЙС ]]
local CombatGroup = Tabs.Combat:AddLeftGroupbox('Combat')
CombatGroup:AddToggle('SAim', { Text = 'Silent Aim', Default = false, Callback = function(v) _G.Config.SilentAim = v end })
CombatGroup:AddToggle('NRec', { Text = 'No Recoil', Default = false, Callback = function(v) _G.Config.NoRecoil = v end })

local VisualGroup = Tabs.Visuals:AddLeftGroupbox('Visuals')
VisualGroup:AddToggle('EspT', { Text = 'Enable ESP', Default = false, Callback = function(v) _G.Config.ESP = v end })

-- КНОПКА UNLOAD (ВОЗВРАЩЕНА)
local SettingsGroup = Tabs.Settings:AddLeftGroupbox('Menu Settings')
SettingsGroup:AddButton('UNLOAD CHEAT', function()
    _G.Config.ESP = false
    _G.Config.SilentAim = false
    _G.Config.NoRecoil = false
    task.wait(0.1)
    for _, obj in pairs(ESP_Table) do
        pcall(function()
            obj[1]:Remove()
            obj[2]:Remove()
            obj[3]:Disconnect()
        end)
    end
    Library:Unload()
end)

-- Запуск
for _, p in pairs(game.Players:GetPlayers()) do ApplyESP(p) end
game.Players.PlayerAdded:Connect(ApplyESP)

Library:Notify("Trident Rebuilt: Ready")
