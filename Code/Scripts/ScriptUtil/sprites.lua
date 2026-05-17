-- =============================================================================
--  sprites.lua  —  Sprite loader for BlindScribe
--
--  Tries to load an individual PNG for each sprite.
--  If the file is missing, falls back to the corresponding quad in the
--  spritesheet (Art/SpriteSheet/tiles.png).
--
--  Usage:
--      local Sprites = require("Code.Scripts.ScriptUtil.sprites")
--      Sprites.draw("player", x, y)
--      Sprites.draw("wall",   x, y)
-- =============================================================================

local Sprites = {}

-- Cached per-sprite data: key → { image, quad|nil, w, h }
local cache = {}

-- Spritesheet (loaded once, lazily)
local sheet = nil

local function getSheet()
    if not sheet then
        sheet = love.graphics.newImage(Config.assets.tileSheet)
        sheet:setFilter("nearest", "nearest")
    end
    return sheet
end

-- Load (or return cached) sprite info for a named sprite key.
-- Returns { image, quad, w, h }  where quad is nil for individual files.
local function loadSprite(key)
    if cache[key] then return cache[key] end

    local def = Config.assets.sprites and Config.assets.sprites[key]
    if not def then
        -- Unknown key — return a placeholder
        cache[key] = { image = nil, quad = nil, w = 32, h = 32 }
        return cache[key]
    end

    local w = def.w or 32
    local h = def.h or 32

    -- Try individual file first
    if def.path and love.filesystem.getInfo(def.path) then
        local img = love.graphics.newImage(def.path)
        img:setFilter("nearest", "nearest")
        cache[key] = { image = img, quad = nil, w = w, h = h }
        return cache[key]
    end

    -- Fall back to spritesheet quad
    local s   = getSheet()
    local sw  = s:getWidth()
    local sh2 = s:getHeight()
    local q   = love.graphics.newQuad(
        def.fallbackSrcX or 0,
        def.fallbackSrcY or 0,
        w, h, sw, sh2)

    cache[key] = { image = s, quad = q, w = w, h = h }
    return cache[key]
end

--- Draw a named sprite at (x, y).  Optional scale (default 1).
function Sprites.draw(key, x, y, scaleX, scaleY)
    scaleX = scaleX or 1
    scaleY = scaleY or scaleX

    local sp = loadSprite(key)
    if not sp or not sp.image then return end

    if sp.quad then
        love.graphics.draw(sp.image, sp.quad, x, y, 0, scaleX, scaleY)
    else
        love.graphics.draw(sp.image, x, y, 0, scaleX, scaleY)
    end
end

--- Return the width/height of a named sprite (useful for alignment).
function Sprites.size(key)
    local sp = loadSprite(key)
    return sp.w, sp.h
end

--- Force-reload all sprites (handy during development).
function Sprites.flush()
    cache = {}
    sheet = nil
end

return Sprites
