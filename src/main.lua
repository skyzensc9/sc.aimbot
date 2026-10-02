-- SC Aimbot Script for Roblox
-- ESP + Team Check + Aimbot

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- ============================================
-- CONFIGURATION
-- ============================================

local CONFIG = {
    ENABLED = true,
    ESP_ENABLED = true,
    AIMBOT_ENABLED = true,
    TEAM_CHECK = true,
    DRAW_LINES = true,
    
    AIM_DISTANCE = 100,      -- Jarak maksimal aimbot (studs)
    AIM_SENSITIVITY = 0.15,  -- Kecepatan aiming (0-1, kecil = lambat)
    SMOOTH_AIM = true,       -- Smooth aiming
    
    ESP_DISTANCE = 250,       -- Jarak maximal ESP
    ESP_COLOR_ENEMY = Color3.fromRGB(255, 0, 0),
    ESP_COLOR_FRIEND = Color3.fromRGB(0, 255, 0),
    ESP_COLOR_NEUTRAL = Color3.fromRGB(255, 255, 0),
}

-- ============================================
-- STATE MANAGEMENT
-- ============================================

local AimbotState = {
    Active = false,
    TargetPlayer = nil,
    TargetPosition = nil,
}

local ESPLabels = {}

-- ============================================
-- HELPER FUNCTIONS
-- ============================================

local function IsEnemy(targetPlayer)
    if not CONFIG.TEAM_CHECK then
        return targetPlayer ~= LocalPlayer
    end
    
    if targetPlayer == LocalPlayer then
        return false
    end
    
    local localTeam = LocalPlayer.Team
    local targetTeam = targetPlayer.Team
    
    -- Jika salah satu tidak punya team, anggap enemy
    if not localTeam or not targetTeam then
        return true
    end
    
    -- Jika team sama, bukan enemy
    return localTeam ~= targetTeam
end

local function GetPlayerDistance(player)
    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        return math.huge
    end
    
    if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
        return math.huge
    end
    
    local distance = (LocalPlayer.Character.HumanoidRootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude
    return distance
end

local function GetPlayerHead(player)
    if not player.Character then
        return nil
    end
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

local function GetScreenPosition(worldPosition)
    local screenPosition, onScreen = Camera:WorldToViewportPoint(worldPosition)
    return Vector2.new(screenPosition.X, screenPosition.Y), onScreen
end

local function RotateCameraTowards(targetPosition)
    if not targetPosition then return end
    
    local cameraPosition = Camera.CFrame.Position
    local direction = (targetPosition - cameraPosition).Unit
    
    if CONFIG.SMOOTH_AIM then
        -- Smooth aiming
        local currentDirection = Camera.CFrame.LookVector
        local blendedDirection = currentDirection:Lerp(direction, CONFIG.AIM_SENSITIVITY)
        Camera.CFrame = CFrame.new(cameraPosition, cameraPosition + blendedDirection)
    else
        -- Instant aim
        Camera.CFrame = CFrame.new(cameraPosition, targetPosition)
    end
end

-- ============================================
-- ESP SYSTEM
-- ============================================

local function CreateESPLabel(player)
    local screenGui = LocalPlayer.PlayerGui:FindFirstChild("ESPGui")
    if not screenGui then
        screenGui = Instance.new("ScreenGui")
        screenGui.Name = "ESPGui"
        screenGui.ResetOnSpawn = false
        screenGui.IgnoreGuiInset = true
        screenGui.Parent = LocalPlayer.PlayerGui
    end
    
    local label = Instance.new("TextLabel")
    label.Name = "ESP_" .. player.Name
    label.Size = UDim2.new(0, 100, 0, 20)
    label.BackgroundTransparency = 0.3
    label.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextSize = 12
    label.Font = Enum.Font.GothamBold
    label.BorderSizePixel = 1
    label.BorderColor3 = Color3.fromRGB(255, 255, 255)
    label.Parent = screenGui
    
    return label
end

local function UpdateESP()
    if not CONFIG.ESP_ENABLED then
        for player, label in pairs(ESPLabels) do
            label:Destroy()
            ESPLabels[player] = nil
        end
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
                
                local head = GetPlayerHead(player)
                if head then
                    local screenPos, onScreen = GetScreenPosition(head.Position)
                    
                    if onScreen then
                        label.Visible = true
                        label.Position = UDim2.new(screenPos.X / Camera.ViewportSize.X, 0, screenPos.Y / Camera.ViewportSize.Y, 0)
                        
                        -- Color based on team
                        if IsEnemy(player) then
                            label.BackgroundColor3 = CONFIG.ESP_COLOR_ENEMY
                            label.TextColor3 = Color3.fromRGB(255, 100, 100)
                        else
                            label.BackgroundColor3 = CONFIG.ESP_COLOR_FRIEND
                            label.TextColor3 = Color3.fromRGB(100, 255, 100)
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
    
    -- Clean up removed players
    for player, label in pairs(ESPLabels) do
        if not player.Parent then
            label:Destroy()
            ESPLabels[player] = nil
        end
    end
end

-- ============================================
-- LINE TRACER SYSTEM
-- ============================================

local function DrawLineToTarget(targetPosition)
    if not CONFIG.DRAW_LINES or not targetPosition then
        return
    end
    
    local screenGui = LocalPlayer.PlayerGui:FindFirstChild("LineGui")
    if not screenGui then
        screenGui = Instance.new("ScreenGui")
        screenGui.Name = "LineGui"
        screenGui.ResetOnSpawn = false
        screenGui.IgnoreGuiInset = true
        screenGui.Parent = LocalPlayer.PlayerGui
    end
    
    -- Clear old lines
    screenGui:ClearAllChildren()
    
    local screenPos, onScreen = GetScreenPosition(targetPosition)
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
    line.Parent = screenGui
end

-- ============================================
-- AIMBOT SYSTEM
-- ============================================

local function UpdateAimbot()
    if not CONFIG.AIMBOT_ENABLED or not AimbotState.Active then
        return
    end
    
    local target, distance = FindClosestEnemy()
    
    if target and distance <= CONFIG.AIM_DISTANCE then
        AimbotState.TargetPlayer = target
        local head = GetPlayerHead(target)
        if head then
            AimbotState.TargetPosition = head.Position
            RotateCameraTowards(head.Position)
            DrawLineToTarget(head.Position)
        end
    else
        AimbotState.TargetPlayer = nil
        AimbotState.TargetPosition = nil
    end
end

-- ============================================
-- INPUT HANDLING
-- ============================================

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        -- Right click to activate aimbot
        AimbotState.Active = true
    end
    
    if input.KeyCode == Enum.KeyCode.Insert then
        -- Insert key to toggle ESP
        CONFIG.ESP_ENABLED = not CONFIG.ESP_ENABLED
        print("[Aimbot] ESP " .. (CONFIG.ESP_ENABLED and "Enabled" or "Disabled"))
    end
end)

UserInputService.InputEnded:Connect(function(input, gameProcessed)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        -- Release right click to deactivate aimbot
        AimbotState.Active = false
    end
end)

-- ============================================
-- MAIN LOOP
-- ============================================

RunService.RenderStepped:Connect(function()
    if not CONFIG.ENABLED then return end
    
    UpdateESP()
    UpdateAimbot()
end)

-- ============================================
-- CLEANUP ON DISCONNECT
-- ============================================

LocalPlayer.Destroying:Connect(function()
    for _, label in pairs(ESPLabels) do
        label:Destroy()
    end
    
    local espGui = LocalPlayer.PlayerGui:FindFirstChild("ESPGui")
    if espGui then
        espGui:Destroy()
    end
    
    local lineGui = LocalPlayer.PlayerGui:FindFirstChild("LineGui")
    if lineGui then
        lineGui:Destroy()
    end
end)

print("[SC Aimbot] Script Loaded!")
print("[SC Aimbot] Controls:")
print("  - Right Click (Mouse2) = Aimbot")
print("  - Insert Key = Toggle ESP")
