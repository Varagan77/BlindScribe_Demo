-- =============================================================================
--  config.lua  —  Central configuration for BlindScribe
--  DO NOT HARDCODE PLEASE I BEG YAH.
-- =============================================================================

Config = {}


-- ---------------------------------------------------------------------------
--  WORLD / MAP
-- ---------------------------------------------------------------------------
Config.map = {
    tileSize   = 32,        -- pixel size of one tile
    cols       = 15,        -- map width  in tiles (must be odd; forced odd in map.lua)
    rows       = 15,        -- map height in tiles (must be odd; forced odd in map.lua)
    seed       = nil,       -- nil → os.time() at startup

    -- Debug / generation animation
    debugSpeed = 0.04,      -- seconds per carve-step reveal

    -- Procedural generation ranges
    roomCountMin  = 3,      -- min extra carved rooms
    roomCountMax  = 6,      -- max extra carved rooms
    roomSizeMin   = 2,      -- min half-size of a carved room
    roomSizeMax   = 3,      -- max half-size of a carved room
    enemyCountMin = 3,      -- min enemies placed
    enemyCountMax = 8,      -- max enemies placed
    goldCountMin  = 3,      -- min gold tiles placed
    goldCountMax  = 8,      -- max gold tiles placed
    shopCount     = 2,      -- exact number of shops placed

    -- Tile IDs  (match quads[i] in grid.lua — index 0-based)
    tiles = {
        floor     = 0,
        wall      = 1,
        shop      = 2,
        enemy     = 3,
        portalIn  = 4,
        portalOut = 5,
        exit      = 6,
        gold      = 7,
    },
}


-- ---------------------------------------------------------------------------
--  PLAYER
-- ---------------------------------------------------------------------------
Config.player = {
    hp    = 10,
    maxHp = 10,
    gold  = 0,
    speed = 10,     -- lerp speed (higher = snappier movement)

    -- Dice roll cutscene timing (seconds)
    dice = {
        spinStart   = 0.8,   -- when the die starts spinning
        spinEnd     = 3.0,   -- when it locks on the result
        totalTime   = 4.0,   -- when diceRoll table is cleared
        minInterval = 0.06,  -- fastest face-change interval
        maxInterval = 0.31,  -- slowest  face-change interval  (0.06 + 0.25)
    },

    entryPopupDuration = 3.5,   -- seconds the "You entered…" message stays
}


-- ---------------------------------------------------------------------------
--  CAMERA
-- ---------------------------------------------------------------------------
Config.camera = {
    enabled = true,
    speed   = 6,    -- lerp multiplier used in camera_update  (camera.speed in camera.lua)
                    -- NOTE: camera.lua currently uses camera.speed, not camera.lerp.
                    --       Rename the field in camera.lua if you want "lerp" semantics (0-1).
}


-- ---------------------------------------------------------------------------
--  FOG OF WAR
-- ---------------------------------------------------------------------------
Config.fog = {
    enabled = true,
}


-- ---------------------------------------------------------------------------
--  DM (Dungeon Master)
-- ---------------------------------------------------------------------------
Config.dm = {
    essence      = 100,
    essenceMax   = 100,
    essenceDrain = 1.5,     -- essence lost per second (passive drain)
    lowEssPct    = 0.25,    -- fraction at which "LOW" warning appears

    -- Essence reward when a pawn takes damage
    damageEssenceMultiplier = 2,    -- gain = damage * this

    -- Block ability
    blockDuration = 8,      -- seconds a blocked tile stays sealed

    -- Pawn colours (up to 4; cycled with modulo for >4 pawns)
    pawnColours = {
        {0.30, 0.80, 1.00},   -- blue
        {1.00, 0.70, 0.20},   -- orange
        {0.30, 1.00, 0.55},   -- green
        {1.00, 0.35, 0.55},   -- pink
    },

    -- Ability definitions  (numeric params only — action functions live in dm.lua)
    -- Order must match ABILITY_ACTIONS table in dm.lua.
    abilities = {
        {
            name        = "Spawn",
            cost        = 12,
            cooldownMax = 0,
            desc        = "Place a new enemy on an empty floor tile [WORKS]",
        },
        {
            name        = "Mutate",
            cost        = 8,
            cooldownMax = 0,
            desc        = "Enemies grow stronger [WIP]",
        },
        {
            name        = "Block",
            cost        = 6,
            cooldownMax = 8,
            desc        = "Seal a passage temporarily [WIP]",
        },
        {
            name        = "Swap",
            cost        = 20,
            cooldownMax = 0,
            desc        = "Teleport two pawns to each other [WIP]",
        },
        {
            name        = "Inflate",
            cost        = 6,
            cooldownMax = 0,
            desc        = "Raise store prices [WIP]",
        },
        {
            name        = "Shift",
            cost        = 10,
            cooldownMax = 12,
            desc        = "Move a tile to a new position [WIP]",
        },
    },
}


-- ---------------------------------------------------------------------------
--  HUD — shared layout constants
-- ---------------------------------------------------------------------------
Config.hud = {
    pad         = 6,
    corner      = 8,
    logDuration = 4.0,   -- seconds a log message stays visible

    -- Player HUD
    player = {
        topBarH   = 36,
        rightColW = 180,
        hpBarW    = 160,
        hpBarH    = 12,
        maxHp     = 10,     -- used to compute HP bar fill fraction
        lowHpPct  = 0.4,    -- fraction below which bar turns red
    },

    -- DM HUD
    dm = {
        topBarH   = 40,
        botBarH   = 72,
        rightColW = 190,
        essBarW   = 200,
        essBarH   = 13,
        lowEssPct = 0.25,   -- fraction below which essence bar pulses red
    },
}


-- ---------------------------------------------------------------------------
--  COLOURS
-- ---------------------------------------------------------------------------
Config.colours = {}

-- Player HUD palette
Config.colours.playerHud = {
    bg        = {0.05, 0.05, 0.06},
    panel     = {0.08, 0.08, 0.10},
    border    = {0.25, 0.25, 0.30},
    text      = {0.85, 0.85, 0.85},
    label     = {0.45, 0.45, 0.55},
    accent    = {0.35, 0.85, 0.75},
    gold      = {1.00, 0.85, 0.25},
    danger    = {1.00, 0.30, 0.30},
    hpFill    = {0.20, 0.75, 0.35},
    hpBg      = {0.15, 0.15, 0.18},
    debugHdr  = {0.40, 1.00, 0.85},
    debugWarn = {1.00, 0.85, 0.30},
}

-- DM HUD palette
Config.colours.dmHud = {
    bg         = {0.04, 0.04, 0.06},
    panel      = {0.08, 0.07, 0.10},
    border     = {0.22, 0.18, 0.28},
    text       = {0.85, 0.85, 0.85},
    label      = {0.45, 0.40, 0.55},
    accent     = {0.70, 0.35, 1.00},
    danger     = {1.00, 0.25, 0.25},
    warn       = {1.00, 0.80, 0.20},
    essFill    = {0.60, 0.20, 1.00},
    essLow     = {1.00, 0.25, 0.25},
    essBg      = {0.12, 0.08, 0.18},
    abilityBtn = {0.13, 0.10, 0.18},
    abilityRdy = {0.22, 0.15, 0.32},
    abilityCd  = {0.10, 0.08, 0.12},
    pawnLabel  = {0.55, 0.55, 0.65},
    title      = {0.80, 0.55, 1.00},
}

-- DM map tile colours  (index matches tile ID in Config.map.tiles)
Config.colours.dmTiles = {
    [0] = {0.18, 0.16, 0.22},   -- floor
    [1] = {0.08, 0.07, 0.10},   -- wall
    [2] = {0.25, 0.70, 0.45},   -- shop
    [3] = {0.90, 0.20, 0.20},   -- enemy
    [4] = {0.30, 0.55, 1.00},   -- portal in
    [5] = {0.20, 0.35, 0.85},   -- portal out
    [6] = {1.00, 0.85, 0.20},   -- exit
    [7] = {1.00, 0.75, 0.10},   -- gold
}


-- ---------------------------------------------------------------------------
--  KEYBINDS
-- ---------------------------------------------------------------------------
Config.keys = {
    menu      = "escape",
    camToggle = "f1",
    fogToggle = "f2",
    dbgToggle = "f3",
    dmSwitch  = "f5",
    cfgReload = "f9",   -- dev only: hot-reload config without restarting

    move = {
        up    = "up",
        down  = "down",
        left  = "left",
        right = "right",
    },

    -- DM ability keys in order — must match Config.dm.abilities order
    dmAbilities = {"q", "w", "e", "r", "t", "y"},
}


-- ---------------------------------------------------------------------------
--  ASSETS
-- ---------------------------------------------------------------------------
Config.assets = {
    tileSheet = "assets/media/images/sheets/tiles.png",
}

-- Quad layout in the tile sheet
-- Row 0 (srcY = 0)  → map tiles 0-7, each 32×32
-- Row 1 (srcY = 32) → player sprite at column 0
Config.assets.quads = {
    mapTiles   = { rowY = 0,  count = 8, size = 32 },
    playerTile = { srcX = 0,  srcY  = 32, w = 32, h = 32 },
}


-- ---------------------------------------------------------------------------
--  HOT-RELOAD HELPER  (dev only)
-- ---------------------------------------------------------------------------
-- Call from love.keypressed:
--   if key == Config.keys.cfgReload then Config = Config.reload() end
function Config.reload()
    package.loaded["config"] = nil
    local fresh = require("config")
    print("[Config] reloaded.")
    return fresh
end


return Config