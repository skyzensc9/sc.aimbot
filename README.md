# SC Aimbot - Roblox Universal Aimbot

Universal Aimbot untuk Roblox dengan fitur ESP, Team Check, dan Line Tracer.

## ✨ Fitur Utama

- **ESP Player** - Lihat posisi semua pemain dengan jarak
- **Aimbot** - Auto aim dengan configureable range dan sensitivity
- **Team Check** - Hindari aimlock ke teammate
- **Line Tracer** - Garis visual ke musuh
- **Smooth Aiming** - Aiming yang smooth, bukan instant lock

## 🚀 Cara Pakai

1. Buka Roblox game
2. Buka DevConsole (F9)
3. Copy-paste script dari `src/main.lua`
4. Sesuaikan settings di bagian konfigurasi

## ⚙️ Konfigurasi

```lua
local CONFIG = {
    ENABLED = true,
    ESP_ENABLED = true,
    AIMBOT_ENABLED = true,
    TEAM_CHECK = true,
    
    AIM_DISTANCE = 100,      -- Jarak maksimal aimbot (studs)
    AIM_SENSITIVITY = 0.3,   -- Kecepatan aiming (0-1)
    SMOOTH_AIM = true,       -- Aiming smooth atau instant
}
```

## 📋 Keybinds

- **Mouse2 (Klik Kanan)** - Aktivasi aimbot
- **Insert** - Toggle ESP on/off

## ⚠️ Disclaimer

Script ini untuk educational purposes. Gunakan dengan bijak dan sesuai dengan ToS game.