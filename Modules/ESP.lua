local ESP = { Objects = {}, Connections = {} }
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera

function ESP:CreateESP(player)
    local line = Drawing.new("Line")
    line.Thickness = 1
    line.Transparency = 1
    line.Visible = false
    
    local text = Drawing.new("Text")
    text.Size = 16
    text.Center = true
    text.Outline = true
    text.Visible = false

    local conn = RunService.RenderStepped:Connect(function()
        -- Пытаемся найти персонажа разными способами
        local char = player.Character or workspace:FindFirstChild(player.Name)
        if char and char:FindFirstChild("Head") and self.Config.ESP_Enabled then
            local head = char.Head
            local pos, onScreen = Camera:WorldToViewportPoint(head.Position)
            
            if onScreen then
                -- Линия (Tracer)
                line.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                line.To = Vector2.new(pos.X, pos.Y)
                line.Color = self.Config.Colors.Player
                line.Visible = true
                
                -- Текст
                text.Text = player.Name .. " [" .. math.floor((Camera.CFrame.Position - head.Position).Magnitude) .. "m]"
                text.Position = Vector2.new(pos.X, pos.Y - 20)
                text.Color = Color3.new(1, 1, 1)
                text.Visible = true
            else
                line.Visible = false; text.Visible = false
            end
        else
            line.Visible = false; text.Visible = false
        end
    end)
    table.insert(self.Connections, conn)
    table.insert(self.Objects, line)
    table.insert(self.Objects, text)
end

function ESP:Start(Config)
    self.Config = Config
    self:Unload()
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= Players.LocalPlayer then self:CreateESP(p) end
    end
    Players.PlayerAdded:Connect(function(p) self:CreateESP(p) end)
end

function ESP:Unload()
    for _, c in pairs(self.Connections) do c:Disconnect() end
    for _, o in pairs(self.Objects) do o:Remove() end
    table.clear(self.Connections)
    table.clear(self.Objects)
end

return ESP
