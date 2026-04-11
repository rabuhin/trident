local ESP = { Connections = {} }
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

function ESP:Start(Config)
    self.Config = Config
    
    -- Используем библиотеку амонгус-хука для создания объектов
    -- _G.ESP — это загруженный ранее espLibrary.lua
    local espLib = _G.ESP
    if not espLib then 
        warn("[Trident] espLibrary не найдена в глобальных переменных!")
        return 
    end

    local function ApplyESP(player)
        if player == Players.LocalPlayer then return end

        local connection = RunService.RenderStepped:Connect(function()
            if not self.Config.ESP_Enabled then 
                -- Если ESP выключен в меню, скрываем объекты через библиотеку
                return 
            end

            -- Твой метод поиска персонажа в Trident
            local char = player.Character or workspace:FindFirstChild(player.Name)
            
            if char and char:FindFirstChild("HumanoidRootPart") then
                -- Вызываем отрисовку из espLibrary
                -- Она сама обработает дистанцию, боксы и проверку на экран
                espLib.new(char, player.Name, self.Config.Colors.Player)
            end
        end)
        table.insert(self.Connections, connection)
    end

    -- Запуск для текущих и новых игроков
    for _, p in pairs(Players:GetPlayers()) do ApplyESP(p) end
    table.insert(self.Connections, Players.PlayerAdded:Connect(ApplyESP))
    
    print("[Trident] ESP Logic Connected to Drawing Bridge")
end

function ESP:Unload()
    for _, c in pairs(self.Connections) do c:Disconnect() end
    -- Очистка объектов отрисовки происходит внутри espLibrary
end

return ESP
