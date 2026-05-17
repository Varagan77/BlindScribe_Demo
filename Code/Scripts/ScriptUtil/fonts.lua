-- =============================================================================
--  fonts.lua  —  Shared font cache for BlindScribe
--
--  PixelFraktur.ttf   → titles  (menus, win/lose, map header, etc.)
--  FindersKeepers.ttf → subtitles, labels, body text, hints
--
--  Sizes are pulled from Config.fonts so you can tune everything from
--  config.lua without touching this file.
--
--  Usage:
--      local Fonts = require("Code.Scripts.ScriptUtil.fonts")
--      love.graphics.setFont(Fonts.title(Config.fonts.menuTitle))
--      love.graphics.setFont(Fonts.body(Config.fonts.hudStat))
-- =============================================================================

local Fonts = {}

local titlePath    = "Art/PixelFraktur.ttf"
local subtitlePath = "Art/FindersKeepers.ttf"

-- Per-size font caches
local titleCache    = {}
local subtitleCache = {}

-- Check file availability once at module load time
local titleAvail    = love.filesystem.getInfo(titlePath)    ~= nil
local subtitleAvail = love.filesystem.getInfo(subtitlePath) ~= nil

--- PixelFraktur at the given pixel size (for titles / headers).
--- Pass a Config.fonts.* value so sizes stay centralised.
function Fonts.title(size)
    size = size or 24
    if not titleCache[size] then
        if titleAvail then
            titleCache[size] = love.graphics.newFont(titlePath, size)
        else
            titleCache[size] = love.graphics.newFont(size)
        end
    end
    return titleCache[size]
end

--- FindersKeepers at the given pixel size (subtitles / body / hints).
--- Pass a Config.fonts.* value so sizes stay centralised.
function Fonts.body(size)
    size = size or 14
    if not subtitleCache[size] then
        if subtitleAvail then
            subtitleCache[size] = love.graphics.newFont(subtitlePath, size)
        else
            subtitleCache[size] = love.graphics.newFont(size)
        end
    end
    return subtitleCache[size]
end

-- Aliases for clarity at call sites
Fonts.subtitle = Fonts.body
Fonts.hint     = Fonts.body

--- Flush all cached fonts (useful after a config hot-reload).
function Fonts.flush()
    titleCache    = {}
    subtitleCache = {}
end

return Fonts
