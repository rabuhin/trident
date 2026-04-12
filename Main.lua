-- [[ TRIDENT REBORN ]]
pcall(function() setfflag('DebugRunParallelLuaOnMainThread', 'True') end)

local Library = loadstring(game:HttpGet('https://raw.githubusercontent.com/wally-rbIx/LinoriaLib/main/Library.lua'))()
local Window = Library:CreateWindow({ Title = 'Trident | Final Fix', Center = true, AutoShow = true })

local Tabs = {
    Combat = Window:AddTab('Combat'),
    Visuals = Window:AddTab('Visuals'),
    Settings = Window:AddTab('Settings')
}

_G.Config = { ESP = false, SAim = false, Recoil = false, Dist = 600 }
local ESP_Table = {}

-- [[ 1. COMBAT (SILENT AIM) ]]
local function GetTarget()
    local target, nearest = nil, 150
    local mouse = game:GetService("UserInputService"):GetMouseLocation()
    for _, p in pairs(game.Players:GetPlayers()) do
        if p ~= game.Players.LocalPlayer and p.Character and p.Character:FindFirstChild("Head") then
            local pos, vis = workspace.CurrentCamera:WorldToViewportPoint(p.Character.Head.Position)
            if vis then
                local mDist = (Vector2.new(pos.X, pos.Y) - mouse).Magnitude
                if mDist < nearest then nearest = mDist; target = p.Character.Head end
            end
        end
    end
    return target
end

local OldNC; OldNC = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
    local method = getnamecallmethod()
    local args = {...}
    if _G.Config.SAim and method == "FireServer" and self.Name == "Network" and args[1] == "ProjectileFire" then
        local t = GetTarget()
        if t then args[3] = t.Position; return OldNC(self, unpack(args)) end
    end
    if _G.Config.Recoil and method == "Recoil" then return end
    return OldNC(self, ...)
end))

-- [[ 2. VISUALS (ULTRA-STABLE ESP) ]]
local function CreateESP(p)
    local box = Drawing.new("Square")
    local txt = Drawing.new("Text")
    txt.Size = 14; txt.Center = true; txt.Outline = true

    local c; c = game:GetService("RunService").RenderStepped:Connect(function()
        if not _G.Config.ESP then box.Visible = false; txt.Visible = false; return end
        local char = p.Character or workspace:FindFirstChild(p.Name)
        if char and char:FindFirstChild("HumanoidRootPart") then
            local root = char.HumanoidRootPart
            local pos, vis = workspace.CurrentCamera:WorldToViewportPoint(root.Position)
            local dist = (root.Position - workspace.CurrentCamera.CFrame.Position).Magnitude
            if vis and dist < _G.Config.Dist then
                local s = 2000 / dist
                box.Size = Vector2.new(s, s * 1.5)
                box.Position = Vector2.new(pos.X - s/2, pos.Y - s/2)
                box.Visible = true
                txt.Text = p.Name .. " [" .. math.floor(dist) .. "]"
                txt.Position = Vector2.new(pos.X, pos.Y - s/2 - 15)
                txt.Visible = true
            else box.Visible = false; txt.Visible = false end
        else box.Visible = false; txt.Visible = false end
    end)
    ESP_Table[p] = {box, txt, c}
end

-- [[ 3. INTERFACE (ИСПРАВЛЕННЫЕ МЕТОДЫ) ]]
local CombatBox = Tabs.Combat:AddLeftGroupbox('Combat')
CombatBox:AddToggle('SA', { Text = 'Silent Aim', Default = false }):OnChanged(function() _G.Config.SAim = Toggles.SA.Value end)
CombatBox:AddToggle('NR', { Text = 'No Recoil', Default = false }):OnChanged(function() _G.Config.Recoil = Toggles.NR.Value end)

local VisualBox = Tabs.Visuals:AddLeftGroupbox('Visuals')
VisualBox:AddToggle('E', { Text = 'Enable ESP', Default = false }):OnChanged(function() _G.Config.ESP = Toggles.E.Value end)

local SettingsBox = Tabs.Settings:AddLeftGroupbox('Menu')
-- Исправленный вызов кнопки:
SettingsBox:AddButton({
    Text = 'UNLOAD CHEAT',
    Func = function()
        _G.Config.ESP = false
        for _, o in pairs(ESP_Table) do o[1]:Remove(); o[2]:Remove(); o[3]:Disconnect() end
        Library:Unload()
    end,
    DoubleClick = false
})

for _, p in pairs(game.Players:GetPlayers()) do if p ~= game.Players.LocalPlayer then CreateESP(p) end end
game.Players.PlayerAdded:Connect(CreateESP)

Library:Notify("Fixed Build Loaded!")
