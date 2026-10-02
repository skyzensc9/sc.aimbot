-- GTA SA-MP Aimbot Script (Moonloader)
-- ESP + Aimbot + Team Check

script_name("GTA SA-MP Aimbot")
script_author("SC")
script_version("1.0")

local sampev = require "lib.samp.events"
local encoding = require "encoding"
encoding.default = 'UTF-8'
local u8 = encoding.UTF8

local players = {}
local aimbot_enabled = true
local esp_enabled = true
local team_check = true
local aim_distance = 150
local aim_smooth = 0.15
local current_target = nil

function updatePlayersData()
    for i = 0, sampGetMaxPlayerId() do
        if sampIsPlayerConnected(i) and i ~= select(2, sampGetPlayerIdByCharHandle(PLAYER_PED)) then
            local x, y, z = getCharCoordinates(PLAYER_PED)
            local px, py, pz = getCharCoordinates(sampGetCharHandleByPlayerId(i))
            
            if px and py and pz then
                local distance = math.sqrt((x - px) ^ 2 + (y - py) ^ 2 + (z - pz) ^ 2)
                
                players[i] = {
                    pos = {x = px, y = py, z = pz},
                    distance = distance,
                    connected = true
                }
            end
        end
    end
end

function isPlayerEnemy(playerId)
    if not team_check then return true end
    
    local myTeam = sampGetPlayerTeam(select(2, sampGetPlayerIdByCharHandle(PLAYER_PED)))
    local playerTeam = sampGetPlayerTeam(playerId)
    
    return myTeam ~= playerTeam
end

function findClosestEnemy()
    local closest = nil
    local closest_distance = aim_distance
    
    for i, player_data in pairs(players) do
        if isPlayerEnemy(i) and player_data.distance < closest_distance then
            closest = i
            closest_distance = player_data.distance
        end
    end
    
    return closest
end

function aimAtPlayer(playerId)
    if not players[playerId] then return end
    
    local targetPos = players[playerId].pos
    local x, y, z = getCharCoordinates(PLAYER_PED)
    
    -- Calculate direction
    local dx = targetPos.x - x
    local dy = targetPos.y - y
    local dz = targetPos.z - z
    
    -- Calculate angles
    local angle = math.atan2(dy, dx)
    local distance_xy = math.sqrt(dx * dx + dy * dy)
    local vertical_angle = math.atan2(dz, distance_xy)
    
    -- Aim smoothly
    local camera = getActiveCameraCoordinates()
    local cam_x, cam_y, cam_z = getActiveCameraCoordinates()
    
    -- Smooth aim (lerp)
    local smooth = aim_smooth
    
    setCameraPositionUnfixed(
        cam_x + (targetPos.x - cam_x) * smooth,
        cam_y + (targetPos.y - cam_y) * smooth,
        cam_z + (targetPos.z - cam_z) * smooth
    )
    
    setCameraLookAt(
        targetPos.x,
        targetPos.y,
        targetPos.z + 0.5
    )
end

function renderESP()
    if not esp_enabled then return end
    
    for i, player_data in pairs(players) do
        if player_data.connected and player_data.distance <= aim_distance * 1.5 then
            local screenX, screenY = convertGameScreenCoordsToWindowScreenCoords(
                player_data.pos.x,
                player_data.pos.y
            )
            
            if screenX and screenY then
                local color = 0xFFFF0000 -- Merah untuk enemy
                
                if not isPlayerEnemy(i) then
                    color = 0xFF00FF00 -- Hijau untuk teman
                end
                
                -- Draw distance label
                local nick = sampGetPlayerNickname(i)
                local distance_text = string.format("%s (%.1fm)", nick, player_data.distance)
                
                renderFontDrawText(font, distance_text, screenX, screenY, color)
            end
        end
    end
end

function main()
    while true do
        wait(0)
        
        updatePlayersData()
        renderESP()
        
        if aimbot_enabled then
            local target = findClosestEnemy()
            if target then
                current_target = target
                aimAtPlayer(target)
            else
                current_target = nil
            end
        end
    end
end

-- Command handlers
function sampev.onServerMessage(color, text)
    if text:find("Aimbot") then
        return false
    end
end

-- Keybind: F to toggle aimbot
function onWindowMessage(msg, wparam, lparam)
    if msg == wm.WM_KEYDOWN then
        if wparam == 70 then -- F key
            aimbot_enabled = not aimbot_enabled
            sampAddChatMessage("[Aimbot] " .. (aimbot_enabled and "Enabled" or "Disabled"), 0xFFFFFFFF)
            return false
        elseif wparam == 69 then -- E key
            esp_enabled = not esp_enabled
            sampAddChatMessage("[ESP] " .. (esp_enabled and "Enabled" or "Disabled"), 0xFFFFFFFF)
            return false
        elseif wparam == 84 then -- T key
            team_check = not team_check
            sampAddChatMessage("[Team Check] " .. (team_check and "Enabled" or "Disabled"), 0xFFFFFFFF)
            return false
        end
    end
end

main()
