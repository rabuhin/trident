local ESP = { Objects = {}, Connections = {} }
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera

function ESP:CreateESP(player)
    local box = Drawing.new("Square")
    box.Thickness = 1
    box.Filled = false
    box.Visible = false
    
    local name = Drawing.new("Text")
    name.Size = 14
    name.Center = true
    name.Outline = true
    name.Visible = false

    local conn = RunService.RenderStepped:Connect(function()
        local char = player.Character or workspace:FindFirstChild(player.Name)
        if char and char:FindFirstChild("HumanoidRootPart") and self.Config.ESP_Enabled then
            local root = char.HumanoidRootPart
            local pos, onScreen = Camera:WorldToViewportPoint(root.Position)
            
            if onScreen then
                -- Логика Radium: расчет размера бокса от дистанции
                local diff = (root.Position - Camera.CFrame.Position).Magnitude
                local size = math.clamp(2000 / diff, 10, 500)
                
                box.Size = Vector2.new(size, size * 1.5)
                box.Position = Vector2.new(pos.X - size/2, pos.Y - size/2)
                box.Color = self.Config.Colors.Player
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
    table.insert(self.Connections, conn)
    table.insert(self.Objects, box)
    table.insert(self.Objects, name)
end

function ESP:Start(Config)
    self.Config = Config
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= Players.LocalPlayer then self:CreateESP(p) end
    end
end

function ESP:Unload()
    for _, c in pairs(self.Connections) do c:Disconnect() end
    for _, o in pairs(self.Objects) do o:Remove() end
end

return ESP
