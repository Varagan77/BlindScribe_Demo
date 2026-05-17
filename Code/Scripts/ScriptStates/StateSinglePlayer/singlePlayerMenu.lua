-- =============================================================================
--  singlePlayerMenu.lua
--  Starts a new game behind a flavour loading screen so the player never
--  sees the map generation animation.
--
--  Flow:
--    enter()  → gameState = "loading", kick off generation
--    update() → wait for gridReady(), then fade out and switch to "newGame"
--    draw()   → render the loading screen (parchment + flavour text)
-- =============================================================================

local singleplayer = {}

local PlayerMap = require("Code.Scripts.ScriptPlayer.PlayerMap.playerMap")
local TileSys   = require("Code.Managers.TileManager.tileSys")
local Fonts     = require("Code.Scripts.ScriptUtil.fonts")

-- ── Loading screen state ───────────────────────────────────────────────────────
local LINES = {
    "You light a torch and descend the crumbling stairs...",
    "The stone door grinds shut behind you.",
    "The darkness presses in from all sides.",
    "Something stirs deep in the dungeon.",
    "You grip your lantern and step forward.",
    "The air smells of old dust and forgotten things.",
}

local fntFlavour, fntHint
local fontsReady  = false

local fadeAlpha   = 1.0   -- 1 = fully black, 0 = fully visible
local fadeOut     = false  -- true once gen is done → fade to black then switch
local fadeIn      = false  -- true once switched → fade from black to game
local loadDone    = false  -- has gridReady() returned true yet?
local MIN_DISPLAY = 2.2    -- seconds the screen must stay up regardless
local displayTimer= 0
local chosenLine  = 1

local dots        = ""
local dotTimer    = 0
local DOT_SPEED   = 0.45

-- ── Helpers ───────────────────────────────────────────────────────────────────

local function ensureFonts()
    if fontsReady then return end
    local CF  = Config.fonts
    fntFlavour = Fonts.title(CF.menuTitle - 10)   -- slightly smaller than main menu title
    fntHint    = Fonts.body(CF.hudStat)
    fontsReady = true
end

-- ── Public API ────────────────────────────────────────────────────────────────

function singleplayer.load()
    -- Reset loading state
    fadeAlpha   = 1.0
    fadeOut     = false
    fadeIn      = false
    loadDone    = false
    displayTimer= 0
    chosenLine  = love.math.random(#LINES)
    dots        = ""
    dotTimer    = 0
    fontsReady  = false

    -- Start generation (runs synchronously; grid animates in background)
    worldSeed = os.time()
    grid_load(worldSeed)
    fog_load()
    player_load()
    camera_load()
    hud_load()
    PlayerMap.reset()
    TileSys.reset()

    if fog_update and spawnX and spawnY then
        fog_update(spawnX, spawnY)
    end
end

function singleplayer.enter()
    gameState = "loading"
    -- Fade in from black
    fadeAlpha = 1.0
    fadeIn    = true
    fadeOut   = false
end

function singleplayer.update(dt)
    ensureFonts()

    -- Animated dots
    dotTimer = dotTimer + dt
    if dotTimer >= DOT_SPEED then
        dotTimer = dotTimer - DOT_SPEED
        if #dots >= 3 then dots = "" else dots = dots .. "." end
    end

    -- Tick the hidden generation animation so gridReady() becomes true
    if grid_update then grid_update(dt) end

    displayTimer = displayTimer + dt

    if not loadDone then
        if gridReady() and displayTimer >= MIN_DISPLAY then
            loadDone = true
            -- Begin fade to black before handing off to game
            fadeOut = true
            fadeIn  = false
        end
    end

    -- Fade logic
    local SPEED = 2.2
    if fadeIn then
        fadeAlpha = math.max(0, fadeAlpha - dt * SPEED)
        if fadeAlpha <= 0 then fadeIn = false end
    end

    if fadeOut then
        fadeAlpha = math.min(1, fadeAlpha + dt * SPEED * 1.4)
        if fadeAlpha >= 1 then
            -- Switch to actual game
            fadeOut   = false
            fadeIn    = false
            gameState = "newGame"
        end
    end
end

function singleplayer.keypressed(key)
    if key == "escape" then
        gameState     = "menu"
        selectedIndex = 1
    end
end

function singleplayer.draw(sw, sh)
    ensureFonts()

    -- ── Parchment background ────────────────────────────────────────────
    love.graphics.setColor(0.10, 0.07, 0.04)
    love.graphics.rectangle("fill", 0, 0, sw, sh)

    -- Subtle vignette glow at centre
    love.graphics.setColor(0.18, 0.11, 0.05, 0.6)
    love.graphics.circle("fill", sw / 2, sh / 2, sh * 0.55)

    -- ── Flavour text (PixelFraktur) ─────────────────────────────────────
    love.graphics.setFont(fntFlavour)
    love.graphics.setColor(0.85, 0.72, 0.45)
    love.graphics.printf(LINES[chosenLine], 60, sh / 2 - 60, sw - 120, "center")

    -- ── "Loading" hint (FindersKeepers) ────────────────────────────────
    love.graphics.setFont(fntHint)
    love.graphics.setColor(0.55, 0.44, 0.28, 0.8)
    love.graphics.printf("Preparing the dungeon" .. dots, 0, sh / 2 + 60, sw, "center")

    -- ── Fade overlay ────────────────────────────────────────────────────
    if fadeAlpha > 0 then
        love.graphics.setColor(0, 0, 0, fadeAlpha)
        love.graphics.rectangle("fill", 0, 0, sw, sh)
    end

    love.graphics.setColor(1, 1, 1)
end

return singleplayer
