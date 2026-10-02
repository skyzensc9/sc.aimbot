-- Configuration Settings untuk SC Aimbot

return {
    -- Master Control
    ENABLED = true,
    
    -- Feature Toggles
    ESP_ENABLED = true,
    AIMBOT_ENABLED = true,
    TEAM_CHECK = true,
    DRAW_LINES = true,
    
    -- Aimbot Settings
    AIM_DISTANCE = 100,        -- Jarak maksimal aimbot dalam studs
    AIM_SENSITIVITY = 0.15,    -- Kecepatan aiming (0-1)
    SMOOTH_AIM = true,         -- Gunakan smooth aiming (true) atau instant (false)
    
    -- ESP Settings
    ESP_DISTANCE = 250,        -- Jarak maksimal ESP dalam studs
    
    -- Colors
    ESP_COLOR_ENEMY = Color3.fromRGB(255, 0, 0),      -- Merah untuk musuh
    ESP_COLOR_FRIEND = Color3.fromRGB(0, 255, 0),    -- Hijau untuk teman
    ESP_COLOR_NEUTRAL = Color3.fromRGB(255, 255, 0), -- Kuning untuk netral
    
    -- Keybinds
    AIMBOT_KEY = Enum.UserInputType.MouseButton2,  -- Klik kanan
    ESP_TOGGLE_KEY = Enum.KeyCode.Insert,          -- Insert
}
