-- =============================================================================
--  config.lua  —  Central configuration
--  DO NOT HARDCODE.
-- =============================================================================

Config = {}


-- ---------------------------------------------------------------------------
--  WORLD / MAP
-- ---------------------------------------------------------------------------
Config.map = {
    tileSize   = 32,        -- pixel size of one tile
    cols       = 15,        -- map width  in tiles
    rows       = 15,        -- map height in tiles
    seed       = nil,       -- nil  → os.time() at startup

    -- Tile IDs  (match quads in grid.lua)
    tiles = {
        floor   = 0,
        wall    = 1,
        shop    = 2,
        enemy   = 3,
        portalIn  = 4,
        portalOut = 5,
        exit    = 6,
        gold    = 7,
    },
}

-- Debug / generation animation
Config.map.debugSpeed = 0.04    -- seconds per carve-step reveal


-- ---------------------------------------------------------------------------
--  PLAYER
-- ---------------------------------------------------------------------------
Config.player = {
    hp        = 10,
    maxHp     = 10,
    gold      = 0,
    speed     = 10,     -- lerp speed (higher = snappier movement)

    -- Dice roll cutscene timing (seconds)
    dice = {
        spinStart   = 0.8,   -- when the die starts spinning
        spinEnd     = 3.0,   -- when it locks on the result
        totalTime   = 4.0,   -- when diceRoll is cleared
        minInterval = 0.06,  -- fastest face-change interval
        maxInterval = 0.31,  -- slowest face-change interval
    },

    -- Entry popup
    entryPopupDuration = 3.5,   -- seconds the "You entered…" message stays
}


-- ---------------------------------------------------------------------------
--  CAMERA
-- ---------------------------------------------------------------------------
Config.camera = {
    enabled  = true,
    lerp     = 0.12,    -- camera follow speed (0 = instant, 1 = no follow)
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
    essenceDrain = 1.5,     -- essence lost per second passively
    lowEssPct    = 0.25,    -- fraction at which "LOW" warning appears

    -- Pawn colours (up to 4; cycled with modulo for more pawns)
    pawnColours = {
        {0.30, 0.80, 1.00},   -- blue
        {1.00, 0.70, 0.20},   -- orange
        {0.30, 1.00, 0.55},   -- green
        {1.00, 0.35, 0.55},   -- pink
    },

    -- Ability definitions
    -- Fields: name, cost, cooldownMax (0 = no cooldown), desc
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
            desc        = "Seal a passage for a turn [WIP]",
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

    -- Essence reward when a pawn takes damage
    damageEssenceMultiplier = 2,   -- gain = damage * this

    -- Block ability
    blockDuration = 8,   -- seconds a Block tile stays sealed
}


-- ---------------------------------------------------------------------------
--  HUD — shared layout
-- ---------------------------------------------------------------------------
Config.hud = {
    pad    = 6,
    corner = 8,
    logDuration = 4.0,   -- seconds a log message stays visible
}

-- Player HUD
Config.hud.player = {
    topBarH   = 36,
    rightColW = 180,
    hpBarW    = 160,
    hpBarH    = 12,
    maxHp     = 10,          -- used to compute the HP bar fill fraction
    lowHpPct  = 0.4,         -- fraction below which bar turns red
}

-- DM HUD
Config.hud.dm = {
    topBarH   = 40,
    botBarH   = 72,
    rightColW = 190,
    lowEssPct = 0.25,        -- fraction below which essence bar pulses red
    essBarW   = 200,
    essBarH   = 13,
}


-- ---------------------------------------------------------------------------
--  COLOURS
-- ---------------------------------------------------------------------------

-- Player HUD palette
Config.colours = {}
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

-- DM map tile colours  (index matches tile ID)
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

    move = {
        up    = "up",
        down  = "down",
        left  = "left",
        right = "right",
    },

    -- DM ability keys in order (matches Config.dm.abilities order)
    dmAbilities = {"q", "w", "e", "r", "t", "y"},
}


-- ---------------------------------------------------------------------------
--  ASSETS
-- ---------------------------------------------------------------------------
Config.assets = {
    tileSheet = "assets/media/images/sheets/tiles.png",
}

-- Quad definitions: {srcX, srcY, w, h} in the tile sheet
-- Row 0 (y=0)  → map tiles 0-7
-- Row 1 (y=32) → player sprite at column 0
Config.assets.quads = {
    mapTiles   = { rowY = 0,  count = 8, size = 32 },
    playerTile = { srcX = 0, srcY = 32, w = 32, h = 32 },
}


return Config