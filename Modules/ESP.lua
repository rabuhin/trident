local ESP = { Labels = {}, Connections = {} }
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera

function ESP:AddLabel(obj, text, color)
    local label = Drawing.new("Text")
    label.Visible = false
    label.Center = true
    label.Outline = true
    label.Font = 2
    label.Size = 14
    label.Color = color
    table.insert(self.Labels, label)

    local conn = RunService.RenderStepped:Connect(function()
        if not obj or not obj.Parent or not self.Config.ESP_Enabled then
            label.Visible = false
            if not obj or not obj.Parent then label:Remove() end
            return
        end

        local pos, onScreen = Camera:WorldToViewportPoint(obj:IsA("Model") and obj:GetPivot().Position or obj.Position)
        if onScreen then
            label.Position = Vector2.new(pos.X, pos.Y)
            label.Text = text
            label.Visible = true
        else
            label.Visible = false
        end
    end)
    table.insert(self.Connections, conn)
end

function ESP:Start(Config)
    self.Config = Config
    -- Игроки
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= Players.LocalPlayer and p.Character then
            self:AddLabel(p.Character:WaitForChild("HumanoidRootPart", 5), p.Name, Config.Colors.Player)
        end
    end
    -- Руда (Trident)
    task.spawn(function()
        while task.wait(5) do
            if self.Config.Ores_Enabled then
                for _, v in pairs(workspace:GetDescendants()) do
                    if (v.Name == "SulfurNode" or v.Name == "IronNode") and not v:FindFirstChild("ESPTag") then
                        Instance.new("BoolValue", v).Name = "ESPTag"
                        local col = v.Name:find("Sulfur") and Config.Colors.Sulfur or Config.Colors.Iron
                        self:AddLabel(v, v.Name:gsub("Node", ""), col)
                    end
                end
            end
        end
    end)
end

function ESP:Unload()
    for _, c in pairs(self.Connections) do c:Disconnect() end
    for _, l in pairs(self.Labels) do l:Remove() end
    table.clear(self.Connections)
    table.clear(self.Labels)
end

return ESP
