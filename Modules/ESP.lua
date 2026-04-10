local ESP = { Connection = nil }
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera

function ESP:AddLabel(obj, text, color)
    local label = Drawing.new("Text")
    label.Visible = false
    label.Center = true
    label.Outline = true
    label.Font = 2
    label.Size = 13
    label.Color = color

    local conn
    conn = RunService.RenderStepped:Connect(function()
        if not obj or not obj.Parent or not self.Config.ESP_Enabled then
            label.Visible = false
            if not obj or not obj.Parent then label:Remove(); conn:Disconnect() end
            return
        end

        local pos, onScreen = Camera:WorldToViewportPoint(obj:IsA("Model") and obj:GetPivot().Position or obj.Position)
        local dist = (Camera.CFrame.Position - (obj:IsA("Model") and obj:GetPivot().Position or obj.Position)).Magnitude

        if onScreen and dist <= self.Config.ESP_Distance then
            label.Position = Vector2.new(pos.X, pos.Y)
            label.Text = text .. " [" .. math.floor(dist) .. "m]"
            label.Visible = true
        else
            label.Visible = false
        end
    end)
end

function ESP:Start(Config)
    self.Config = Config
    -- Сканируем игроков
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= Players.LocalPlayer and p.Character then 
            self:AddLabel(p.Character:WaitForChild("HumanoidRootPart", 5), p.Name, Config.Colors.Player) 
        end
    end
    
    -- Сканируем ресурсы (Trident-Specific)
    task.spawn(function()
        while task.wait(5) do -- Обновляем поиск каждые 5 сек, чтобы не лагало
            if self.Config.Ores_Enabled then
                for _, v in pairs(workspace:GetDescendants()) do
                    if v.Name == "SulfurNode" or v.Name == "IronNode" then
                        if not v:FindFirstChild("ESPTag") then
                            local tag = Instance.new("BoolValue", v); tag.Name = "ESPTag"
                            local col = v.Name:find("Sulfur") and Config.Colors.Sulfur or Config.Colors.Iron
                            self:AddLabel(v, v.Name:gsub("Node", ""), col)
                        end
                    end
                end
            end
        end
    end)
end

return ESP
