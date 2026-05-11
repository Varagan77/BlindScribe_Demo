# Config Integration Guide

## 1. Load first in main.lua

```lua
-- top of main.lua, before any other require
Config = require("config")   -- or wherever you put config.lua
```

---

## 2. Key swaps per file

### grid.lua  — map size & tile sheet path
```lua
-- BEFORE
map, spawnX, spawnY, carveLog = mapModule.generate(15, 15)
tileset = love.graphics.newImage("assets/media/images/sheets/tiles.png")
debugSpeed = 0.04

-- AFTER
local C = Config.map
map, spawnX, spawnY, carveLog = mapModule.generate(C.cols, C.rows)
tileset = love.graphics.newImage(Config.assets.tileSheet)
debugSpeed = C.debugSpeed
```

### player.lua  — starting stats & dice timing
```lua
-- BEFORE
hp = 10, gold = 0, speed = 10 ...

-- AFTER
local PC = Config.player
hp = PC.hp, gold = PC.gold, speed = PC.speed ...
-- dice cutscene
if e >= PC.dice.spinStart and e < PC.dice.spinEnd then ...
```

### dm.lua  — essence, ability costs, block duration
```lua
-- BEFORE
local ABILITIES = { { name="Spawn", cost=12, cooldownMax=0 ... } ... }
DM = { essence=100, essenceMax=100, essenceDrain=1.5 ... }

-- AFTER
local DC = Config.dm
-- Build abilities from Config (preserves action functions):
local abs = {}
for i, def in ipairs(DC.abilities) do
    abs[i] = {
        name        = def.name,
        cost        = def.cost,
        cooldownMax = def.cooldownMax,
        cooldown    = 0,
        desc        = def.desc,
        action      = ABILITY_ACTIONS[i],  -- keep actions table separate in dm.lua
    }
end
DM = { essence = DC.essence, essenceMax = DC.essenceMax,
       essenceDrain = DC.essenceDrain, ... }

-- Block duration
table.insert(dm.blocks, { ..., timer = Config.dm.blockDuration, ... })
```

### player_hud.lua & dm_hud.lua  — layout constants & colours
```lua
-- BEFORE (player_hud.lua)
HUD.TOP_BAR_H   = 36
HUD.RIGHT_COL_W = 180
local C = { bg = {0.05,0.05,0.06} ... }

-- AFTER
local L = Config.hud.player
local C = Config.colours.playerHud
HUD.TOP_BAR_H   = L.topBarH
HUD.RIGHT_COL_W = L.rightColW
-- then use C.bg, C.accent etc. as before

-- Same pattern for dm_hud.lua using Config.hud.dm + Config.colours.dmHud
```

### fog.lua & camera (wherever camera_load lives)
```lua
fog.enabled    = Config.fog.enabled
camera.enabled = Config.camera.enabled
```

---

## 3. Keybinds (main.lua / player.lua / dm.lua)
```lua
local K = Config.keys

-- player_keypressed
if key == K.move.up    and testMap(0,-1) then ...
if key == K.move.down  and testMap(0, 1) then ...
if key == K.fogToggle  then fog.enabled = not fog.enabled end

-- dm_keypressed ability loop
local abKeys = {}
for i, k in ipairs(K.dmAbilities) do abKeys[k] = i end
```

---

## 4. Things intentionally NOT in config
- Draw logic, animation math, UI layout calculations — those stay in their files.
- Action functions for abilities (closures referencing dm_* helpers) — keep them
  in dm.lua; config only holds the numeric parameters.

---

## 5. Hot-reloading trick (optional, dev only)
```lua
-- In love.keypressed, add:
if key == "f9" then
    package.loaded["config"] = nil
    Config = require("config")
    print("Config reloaded.")
end
```
This lets you tweak costs/colours/sizes and see them next frame without
restarting the game.
