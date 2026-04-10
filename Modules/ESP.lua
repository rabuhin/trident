local ESP = {}
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local function CreateDrawing(class, props)
    local d = Drawing.new(class)
    for i, v in pairs(props) do d[i] = v end
    return d
end

function ESP:AddESP(obj, name, color)
    local text = CreateDrawing("Text", {Text = name, Color = color, Size = 16, Outline = true, Center = true, Visible = false})
    
    local connection
    connection = RunService.RenderStepped:Connect(function()
        if not obj or not obj.Parent then
            text:Remove()
            connection:Disconnect()
            return
        end
        
        local pos, onScreen = Camera:WorldToViewportPoint(obj:IsA("Model") and obj:GetPivot().Position or obj.Position)
        if onScreen and self.Config.ESP_Enabled then
            text.Position = Vector2.new(pos.X, pos.Y)
            text.Visible = true
        else
            text.Visible = false
        end
    end)
end

function ESP:Start(Config)
    self.Config = Config
    
    -- ESP на игроков
    Players.PlayerAdded:Connect(function(p)
        p.CharacterAdded:Connect(function(char)
            self:AddESP(char:WaitForChild("HumanoidRootPart"), p.Name, Config.Colors.Player)
        end)
    end)
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            self:AddESP(p.Character:FindFirstChild("HumanoidRootPart"), p.Name, Config.Colors.Player)
        end
    end

    -- ESP на ресурсы Trident (Sulfur, Iron)
    if workspace:FindFirstChild("Resources") then
        for _, ore in pairs(workspace.Resources:GetChildren()) do
            local color = ore.Name:find("Sulfur") and Config.Colors.Sulfur or Config.Colors.Iron
            self:AddESP(ore, ore.Name, color)
        end
    end
end

return ESP
