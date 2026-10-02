local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera

local LocalPlayer = Players.LocalPlayer

-- Gunakan Rayfield official source
local Rayfield = loadstring(game:HttpGet("https://raw.githubusercontent.com/shlexware/Rayfield/main/source.lua"))()

local Window = Rayfield:CreateWindow({
    Name = "SC Aimbot Mobile",
    LoadingTitle = "SC Aimbot",
    LoadingSubtitle = "Mobile Edition",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "SC_Aimbot",
        FileName = "Config"
    },
    KeySystem = false
})

local MainTab = Window:CreateTab("Main", 13047715)
local SettingsTab = Window:CreateTab("Settings", 3926305)
local InfoTab = Window:CreateTab("Info", 5028892)

local CONFIG = {
    ENABLED = true,
    ESP_ENABLED = true,
    AIMBOT_ENABLED = true,
    TEAM_CHECK = true,
    DRAW_LINES = true,

    AIM_DISTANCE = 120,
    AIM_SENSITIVITY = 0.12,
    SMOOTH_AIM = true,

    ESP_DISTANCE = 250,
    ESP_COLOR_ENEMY = Color3.fromRGB(255, 0, 0),
    ESP_COLOR_FRIEND = Color3.fromRGB(0, 255, 0),
}

local ESPLabels = {}
local AimbotActive = false

local function IsEnemy(targetPlayer)
    if not CONFIG.TEAM_CHECK then
        return targetPlayer ~= LocalPlayer
    end

    if targetPlayer == LocalPlayer then
        return false
    end

    local localTeam = LocalPlayer.Team
    local targetTeam = targetPlayer.Team

    if not localTeam or not targetTeam then
        return true
    end

    return localTeam ~= targetTeam
end

local function GetPlayerDistance(player)
    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        return math.huge
    end

    if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
        return math.huge
    end

    return (LocalPlayer.Character.HumanoidRootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude
end

local function GetHead(player)
    if not player.Character then return nil end
    return player.Character:FindFirstChild("Head")
end

local function FindClosestEnemy()
    local closestPlayer = nil
    local closestDistance = CONFIG.AIM_DISTANCE

    for _, player in ipairs(Players:GetPlayers()) do
        if IsEnemy(player) then
            local distance = GetPlayerDistance(player)
            if distance < closestDistance then
                closestDistance = distance
                closestPlayer = player
            end
        end
    end

    return closestPlayer, closestDistance
end

local function ScreenPos(worldPos)
    local pos, onScreen = Camera:WorldToViewportPoint(worldPos)
    return Vector2.new(pos.X, pos.Y), onScreen
end

local function RotateCameraTowards(targetPosition)
    if not targetPosition then return end
    local cameraPos = Camera.CFrame.Position
    local direction = (targetPosition - cameraPos).Unit

    if CONFIG.SMOOTH_AIM then
        local currentDirection = Camera.CFrame.LookVector
        local blended = currentDirection:Lerp(direction, CONFIG.AIM_SENSITIVITY)
        Camera.CFrame = CFrame.new(cameraPos, cameraPos + blended)
    else
        Camera.CFrame = CFrame.new(cameraPos, targetPosition)
    end
end

local function CreateESPLabel(player)
    local gui = LocalPlayer.PlayerGui:FindFirstChild("ESPGui")
    if not gui then
        gui = Instance.new("ScreenGui")
        gui.Name = "ESPGui"
        gui.ResetOnSpawn = false
        gui.IgnoreGuiInset = true
        gui.Parent = LocalPlayer.PlayerGui
    end

    local label = Instance.new("TextLabel")
    label.Name = "ESP_" .. player.Name
    label.Size = UDim2.new(0, 120, 0, 18)
    label.BackgroundTransparency = 0.3
    label.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextSize = 12
    label.Font = Enum.Font.GothamBold
    label.BorderSizePixel = 1
    label.BorderColor3 = Color3.fromRGB(255, 255, 255)
    label.Parent = gui

    return label
end

local function UpdateESP()
    if not CONFIG.ESP_ENABLED then
        for _, label in pairs(ESPLabels) do
            label:Destroy()
        end
        ESPLabels = {}
        return
    end

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local distance = GetPlayerDistance(player)

            if distance <= CONFIG.ESP_DISTANCE then
                local label = ESPLabels[player]
                if not label then
                    label = CreateESPLabel(player)
                    ESPLabels[player] = label
                end

                local head = GetHead(player)
                if head then
                    local screenPos, onScreen = ScreenPos(head.Position)

                    if onScreen then
                        label.Visible = true
                        label.Position = UDim2.new(screenPos.X / Camera.ViewportSize.X, 0, screenPos.Y / Camera.ViewportSize.Y, 0)

                        if IsEnemy(player) then
                            label.BackgroundColor3 = CONFIG.ESP_COLOR_ENEMY
                            label.TextColor3 = Color3.fromRGB(255, 150, 150)
                        else
                            label.BackgroundColor3 = CONFIG.ESP_COLOR_FRIEND
                            label.TextColor3 = Color3.fromRGB(150, 255, 150)
                        end

                        label.Text = player.Name .. " (" .. tostring(math.floor(distance)) .. ")"
                    else
                        label.Visible = false
                    end
                end
            else
                local label = ESPLabels[player]
                if label then
                    label:Destroy()
                    ESPLabels[player] = nil
                end
            end
        end
    end
end

local function DrawLineToTarget(targetPosition)
    if not CONFIG.DRAW_LINES or not targetPosition then return end

    local gui = LocalPlayer.PlayerGui:FindFirstChild("LineGui")
    if not gui then
        gui = Instance.new("ScreenGui")
        gui.Name = "LineGui"
        gui.ResetOnSpawn = false
        gui.IgnoreGuiInset = true
        gui.Parent = LocalPlayer.PlayerGui
    end

    gui:ClearAllChildren()

    local screenPos, onScreen = ScreenPos(targetPosition)
    if not onScreen then return end

    local centerX = Camera.ViewportSize.X / 2
    local centerY = Camera.ViewportSize.Y / 2

    local dx = screenPos.X - centerX
    local dy = screenPos.Y - centerY
    local distance = math.sqrt(dx * dx + dy * dy)
    local angle = math.atan2(dy, dx)

    local line = Instance.new("Frame")
    line.Name = "TraceLine"
    line.AnchorPoint = Vector2.new(0.5, 0.5)
    line.Position = UDim2.new(centerX / Camera.ViewportSize.X, 0, centerY / Camera.ViewportSize.Y, 0)
    line.Size = UDim2.new(0, distance, 0, 2)
    line.Rotation = math.deg(angle)
    line.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    line.BorderSizePixel = 0
    line.Parent = gui
end

local function UpdateAimbot()
    if not CONFIG.AIMBOT_ENABLED or not AimbotActive then
        return
    end

    local target, distance = FindClosestEnemy()
    if target and distance <= CONFIG.AIM_DISTANCE then
        local head = GetHead(target)
        if head then
            local cameraPos = Camera.CFrame.Position
            local direction = (head.Position - cameraPos).Unit

            if CONFIG.SMOOTH_AIM then
                local currentDir = Camera.CFrame.LookVector
                local blended = currentDir:Lerp(direction, CONFIG.AIM_SENSITIVITY)
                Camera.CFrame = CFrame.new(cameraPos, cameraPos + blended)
            else
                Camera.CFrame = CFrame.new(cameraPos, head.Position)
            end

            DrawLineToTarget(head.Position)
        end
    end
end

UserInputService.TouchBegan:Connect(function(_, processed)
    if processed then return end
    AimbotActive = true
end)

UserInputService.TouchEnded:Connect(function(_, processed)
    if processed then return end
    AimbotActive = false
end)

MainTab:CreateLabel("SC Aimbot Mobile")
MainTab:CreateToggle({
    Name = "Enable Aimbot",
    CurrentValue = true,
    Callback = function(value)
        CONFIG.AIMBOT_ENABLED = value
    end
})

MainTab:CreateToggle({
    Name = "Enable ESP",
    CurrentValue = true,
    Callback = function(value)
        CONFIG.ESP_ENABLED = value
    end
})

MainTab:CreateToggle({
    Name = "Team Check",
    CurrentValue = true,
    Callback = function(value)
        CONFIG.TEAM_CHECK = value
    end
})

MainTab:CreateToggle({
    Name = "Draw Line",
    CurrentValue = true,
    Callback = function(value)
        CONFIG.DRAW_LINES = value
    end
})

MainTab:CreateLabel("Touch and hold to aim")
MainTab:CreateLabel("Release to stop aiming")

SettingsTab:CreateSlider({
    Name = "Aim Distance",
    Range = {10, 300},
    Increment = 5,
    Suffix = "studs",
    CurrentValue = CONFIG.AIM_DISTANCE,
    Callback = function(value)
        CONFIG.AIM_DISTANCE = value
    end
})

SettingsTab:CreateSlider({
    Name = "Aim Sensitivity",
    Range = {0.01, 1},
    Increment = 0.01,
    Suffix = "x",
    CurrentValue = CONFIG.AIM_SENSITIVITY,
    Callback = function(value)
        CONFIG.AIM_SENSITIVITY = value
    end
})

SettingsTab:CreateSlider({
    Name = "ESP Distance",
    Range = {50, 500},
    Increment = 10,
    Suffix = "studs",
    CurrentValue = CONFIG.ESP_DISTANCE,
    Callback = function(value)
        CONFIG.ESP_DISTANCE = value
    end
})

SettingsTab:CreateToggle({
    Name = "Smooth Aiming",
    CurrentValue = true,
    Callback = function(value)
        CONFIG.SMOOTH_AIM = value
    end
})

InfoTab:CreateParagraph({
    Title = "Features",
    Content = "ESP Player\nAimbot\nTeam Check\nLine Tracer\nMobile Only"
})

InfoTab:CreateParagraph({
    Title = "Controls",
    Content = "Touch and hold on screen to activate the aimbot. Release to stop."
})

RunService.RenderStepped:Connect(function()
    if not CONFIG.ENABLED then return end
    UpdateESP()
    UpdateAimbot()
end)

print("[SC Aimbot Mobile] Loaded")
print("[SC Aimbot Mobile] Touch and hold to aim")
