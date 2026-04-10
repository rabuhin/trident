local ESP = { Objects = {}, Connections = {} }
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local function Create(class, props)
    local d = Drawing.new(class)
    for i, v in pairs(props) do d[i] = v end
    return d
end

function ESP:CreateESP(player)
    local box = Create("Square", {Thickness = 1, Filled = false, Transparency = 1, Visible = false})
    local tracer = Create("Line", {Thickness = 1, Transparency = 1, Visible = false})
    local name = Create("Text", {Size = 14, Center = true, Outline = true, Visible = false})

    local conn = RunService.RenderStepped:Connect(function()
        local char = player.Character
        if char and char:FindFirstChild("HumanoidRootPart") and self.Config.ESP_Enabled then
            local root = char.HumanoidRootPart
            local pos, onScreen = Camera:WorldToViewportPoint(root.Position)
            
            if onScreen then
                local size = (Camera:WorldToViewportPoint(root.Position + Vector3.new(0, 3, 0)).Y - Camera:WorldToViewportPoint(root.Position + Vector3.new(0, -3, 0)).Y)
                local boxSize = Vector2.new(size / 1.5, size)
                local boxPos = Vector2.new(pos.X - boxSize.X / 2, pos.Y - boxSize.Y / 2)

                -- Box
                box.Size = boxSize
                box.Position = boxPos
                box.Color = self.Config.Colors.Player
                box.Visible = true

                -- Tracer
                tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                tracer.To = Vector2.new(pos.X, pos.Y + (boxSize.Y / 2))
                tracer.Color = self.Config.Colors.Player
                tracer.Visible = true

                -- Name
                name.Text = player.Name
                name.Position = Vector2.new(pos.X, boxPos.Y - 15)
                name.Color = Color3.new(1, 1, 1)
                name.Visible = true
            else
                box.Visible = false; tracer.Visible = false; name.Visible = false
            end
        else
            box.Visible = false; tracer.Visible = false; name.Visible = false
        end
    end)
    table.insert(self.Connections, conn)
    table.insert(self.Objects, {box, tracer, name})
end

function ESP:Start(Config)
    self.Config = Config
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then self:CreateESP(p) end
    end
    Players.PlayerAdded:Connect(function(p) self:CreateESP(p) end)
end

function ESP:Unload()
    for _, c in pairs(self.Connections) do c:Disconnect() end
    for _, group in pairs(self.Objects) do
        for _, obj in pairs(group) do obj:Remove() end
    end
    table.clear(self.Connections)
    table.clear(self.Objects)
end

return ESP
