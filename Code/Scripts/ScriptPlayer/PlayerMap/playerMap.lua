-- =============================================================================
--  playerMap.lua
--  A hand-drawn "explorer's map" on aged parchment.
--  Open/close with M key.
--
--  Tools:
--    INK    — draw on the map (left-click after selecting INK)
--    SCRATCH — erase what has been drawn (left-click after selecting SCRATCH)
--
--  A small player marker sits in the centre of the paper so the player
--  has a reference point for where they might be.
--
--  The drawn state persists across the whole run; reset on win/lose.
-- =============================================================================

local Map   = {}
local Fonts = require("Code.Scripts.ScriptUtil.fonts")

-- ── Constants ─────────────────────────────────────────────────────────────────
local GRID_COLS  = 32
local GRID_ROWS  = 32
local CELL       = 14
local PANEL_PAD  = 18
local TOOLBAR_H  = 44
local FOOTER_H   = 26

-- Parchment colours
local PARCH_BG   = {0.88, 0.78, 0.52, 1.00}
local PARCH_DARK = {0.76, 0.64, 0.38, 1.00}
local PARCH_GRID = {0.62, 0.50, 0.28, 0.55}
local PARCH_EDGE = {0.55, 0.42, 0.20, 1.00}
local INK_COL    = {0.14, 0.10, 0.05, 0.88}
local TOOL_EDGE  = {0.44, 0.32, 0.14, 1.00}
local INK_ACTIVE = {0.14, 0.10, 0.05, 1.00}
local INK_TEXT_A = {0.90, 0.80, 0.55, 1.00}
local SCR_ACTIVE = {0.50, 0.38, 0.18, 1.00}
local SCR_TEXT_A = {0.18, 0.12, 0.04, 1.00}
local BTN_IDLE   = {0.80, 0.68, 0.42, 1.00}
local BTN_TEXT_I = {0.38, 0.28, 0.12, 1.00}
local TITLE_COL  = {0.30, 0.20, 0.06, 1.00}
local HINT_COL   = {0.44, 0.32, 0.14, 0.80}

-- ── State ─────────────────────────────────────────────────────────────────────
local open     = false
local cells    = {}
local painting = false
local erasing  = false
local tool     = "ink"

-- ── Fonts (lazy) ──────────────────────────────────────────────────────────────
local fntTitle, fntBtn, fntHint

local function ensureFonts()
    if not fntTitle then fntTitle = Fonts.title(Config.fonts.mapTitle) end
    if not fntBtn   then fntBtn   = Fonts.title(Config.fonts.mapBtn)   end
    if not fntHint  then fntHint  = Fonts.body(Config.fonts.mapHint)   end
end

-- ── Init / reset ──────────────────────────────────────────────────────────────

local function initCells()
    cells = {}
    for r = 1, GRID_ROWS do
        cells[r] = {}
        for c = 1, GRID_COLS do cells[r][c] = false end
    end
end

function Map.init()  initCells() end

function Map.reset()
    initCells()
    open = false; painting = false; erasing = false
end

-- ── Layout ────────────────────────────────────────────────────────────────────

local function getPanelRect()
    local sw, sh = love.graphics.getWidth(), love.graphics.getHeight()
    local gridW  = GRID_COLS * CELL
    local gridH  = GRID_ROWS * CELL
    local panelW = gridW  + PANEL_PAD * 2
    local panelH = gridH  + PANEL_PAD * 2 + TOOLBAR_H + FOOTER_H
    local px     = math.floor((sw - panelW) / 2)
    local py     = math.floor((sh - panelH) / 2)
    return px, py, panelW, panelH
end

local function getGridOrigin()
    local px, py = getPanelRect()
    return px + PANEL_PAD, py + PANEL_PAD + TOOLBAR_H
end

local function screenToCell(mx, my)
    local ox, oy = getGridOrigin()
    local col = math.floor((mx - ox) / CELL) + 1
    local row = math.floor((my - oy) / CELL) + 1
    if col >= 1 and col <= GRID_COLS and row >= 1 and row <= GRID_ROWS then
        return row, col
    end
    return nil, nil
end

-- Button hit rects (recomputed per-frame)
local btnInk = {}; local btnScratch = {}

local function computeButtons(px, py)
    local toolY = py + PANEL_PAD + 6
    local toolH = TOOLBAR_H - 14
    local toolW = 74
    btnInk.x = px + PANEL_PAD; btnInk.y = toolY; btnInk.w = toolW; btnInk.h = toolH
    btnScratch.x = btnInk.x + toolW + 8; btnScratch.y = toolY; btnScratch.w = toolW; btnScratch.h = toolH
end

local function hitBtn(btn, mx, my)
    return mx >= btn.x and mx <= btn.x + btn.w and my >= btn.y and my <= btn.y + btn.h
end

local function applyBrush(mx, my)
    local row, col = screenToCell(mx, my)
    if not row then return end
    if tool == "ink"     and painting then cells[row][col] = true  end
    if tool == "scratch" and erasing  then cells[row][col] = false end
end

-- ── Public API ────────────────────────────────────────────────────────────────

function Map.toggle()
    if not cells or #cells == 0 then initCells() end
    open = not open; painting = false; erasing = false
end

function Map.isOpen() return open end

-- ── Mouse events ──────────────────────────────────────────────────────────────

function Map.mousepressed(mx, my, button)
    if not open then return end
    ensureFonts()
    local px, py, pw = getPanelRect()
    computeButtons(px, py)

    if button == 1 then
        if hitBtn(btnInk, mx, my)     then tool = "ink";     return end
        if hitBtn(btnScratch, mx, my) then tool = "scratch";  return end
        if tool == "ink"     then painting = true; erasing  = false
        else                       erasing  = true; painting = false end
        applyBrush(mx, my)
    end
end

function Map.mousemoved(mx, my)
    if not open then return end
    if painting or erasing then applyBrush(mx, my) end
end

function Map.mousereleased(mx, my, button)
    if button == 1 then painting = false; erasing = false end
end

-- ── Draw helpers ──────────────────────────────────────────────────────────────

local function drawPlayerMarker(cx, cy)
    local s = 3
    -- Shadow
    love.graphics.setColor(0.30, 0.22, 0.08, 0.30)
    love.graphics.ellipse("fill", cx + 1, cy + s * 5 + 2, s * 2.5, s * 0.6)
    -- Silhouette
    love.graphics.setColor(0.18, 0.12, 0.05, 0.85)
    love.graphics.rectangle("fill", cx - s,   cy - 5*s, s*2, s*2)   -- head
    love.graphics.rectangle("fill", cx - s,   cy - 3*s, s*2, s*3)   -- torso
    love.graphics.rectangle("fill", cx - 2*s, cy - 3*s, s,   s*2)   -- L arm
    love.graphics.rectangle("fill", cx + s,   cy - 3*s, s,   s*2)   -- R arm
    love.graphics.rectangle("fill", cx - s,   cy,       s,   s*2)   -- L leg
    love.graphics.rectangle("fill", cx,        cy,       s,   s*2)   -- R leg
    -- Highlight
    love.graphics.setColor(0.65, 0.50, 0.22, 0.60)
    love.graphics.rectangle("fill", cx - s + 1, cy - 5*s + 1, s, s)
end

local function drawGrunge(px, py, pw, ph)
    for _, c in ipairs({{px,py},{px+pw,py},{px,py+ph},{px+pw,py+ph}}) do
        love.graphics.setColor(0.40, 0.28, 0.10, 0.16)
        love.graphics.circle("fill", c[1], c[2], pw * 0.35)
    end
    love.graphics.setColor(0.96, 0.90, 0.68, 0.10)
    love.graphics.circle("fill", px + pw/2, py + ph/2, pw * 0.30)
end

-- ── Draw ──────────────────────────────────────────────────────────────────────

function Map.draw()
    if not open then return end
    if not cells or #cells == 0 then initCells() end
    ensureFonts()

    local sw, sh = love.graphics.getWidth(), love.graphics.getHeight()
    local px, py, pw, ph = getPanelRect()
    local ox, oy = getGridOrigin()
    computeButtons(px, py)

    -- Dim
    love.graphics.setColor(0, 0, 0, 0.65)
    love.graphics.rectangle("fill", 0, 0, sw, sh)

    -- Drop shadow
    love.graphics.setColor(0.15, 0.10, 0.03, 0.50)
    love.graphics.rectangle("fill", px + 6, py + 6, pw, ph, 4, 4)

    -- Paper base
    love.graphics.setColor(PARCH_BG[1], PARCH_BG[2], PARCH_BG[3])
    love.graphics.rectangle("fill", px, py, pw, ph, 3, 3)

    -- Grunge vignette
    drawGrunge(px, py, pw, ph)

    -- Slightly darker grid area
    love.graphics.setColor(PARCH_DARK[1], PARCH_DARK[2], PARCH_DARK[3], 0.30)
    love.graphics.rectangle("fill", ox, oy, GRID_COLS * CELL, GRID_ROWS * CELL)

    -- ── Toolbar ───────────────────────────────────────────────────────

    -- INK button
    local inkA = tool == "ink"
    love.graphics.setColor(inkA and INK_ACTIVE or BTN_IDLE)
    love.graphics.rectangle("fill", btnInk.x, btnInk.y, btnInk.w, btnInk.h, 4, 4)
    love.graphics.setColor(TOOL_EDGE[1], TOOL_EDGE[2], TOOL_EDGE[3])
    love.graphics.setLineWidth(inkA and 2 or 1)
    love.graphics.rectangle("line", btnInk.x, btnInk.y, btnInk.w, btnInk.h, 4, 4)
    love.graphics.setFont(fntBtn)
    love.graphics.setColor(inkA and INK_TEXT_A or BTN_TEXT_I)
    love.graphics.printf("Ink", btnInk.x, btnInk.y + (btnInk.h - 13) / 2, btnInk.w, "center")

    -- SCRATCH button
    local scrA = tool == "scratch"
    love.graphics.setColor(scrA and SCR_ACTIVE or BTN_IDLE)
    love.graphics.rectangle("fill", btnScratch.x, btnScratch.y, btnScratch.w, btnScratch.h, 4, 4)
    love.graphics.setColor(TOOL_EDGE[1], TOOL_EDGE[2], TOOL_EDGE[3])
    love.graphics.setLineWidth(scrA and 2 or 1)
    love.graphics.rectangle("line", btnScratch.x, btnScratch.y, btnScratch.w, btnScratch.h, 4, 4)
    love.graphics.setFont(fntBtn)
    love.graphics.setColor(scrA and SCR_TEXT_A or BTN_TEXT_I)
    love.graphics.printf("Scratch", btnScratch.x, btnScratch.y + (btnScratch.h - 13) / 2, btnScratch.w, "center")

    -- Title
    love.graphics.setFont(fntTitle)
    love.graphics.setColor(TITLE_COL[1], TITLE_COL[2], TITLE_COL[3])
    local titleX = btnScratch.x + btnScratch.w + 14
    local titleY = btnInk.y + (btnInk.h - 18) / 2
    love.graphics.print("Explorer's Map", titleX, titleY)

    -- ── Grid lines ────────────────────────────────────────────────────
    love.graphics.setColor(PARCH_GRID[1], PARCH_GRID[2], PARCH_GRID[3], PARCH_GRID[4])
    love.graphics.setLineWidth(0.6)
    for c = 0, GRID_COLS do
        local lx = ox + c * CELL
        love.graphics.line(lx, oy, lx, oy + GRID_ROWS * CELL)
    end
    for r = 0, GRID_ROWS do
        local ly = oy + r * CELL
        love.graphics.line(ox, ly, ox + GRID_COLS * CELL, ly)
    end

    -- ── Inked cells ───────────────────────────────────────────────────
    love.graphics.setColor(INK_COL[1], INK_COL[2], INK_COL[3], INK_COL[4])
    for r = 1, GRID_ROWS do
        for c = 1, GRID_COLS do
            if cells[r][c] then
                love.graphics.rectangle("fill",
                    ox + (c-1)*CELL + 1, oy + (r-1)*CELL + 1,
                    CELL - 2, CELL - 2)
            end
        end
    end

    -- ── Player marker (centre of paper) ───────────────────────────────
    drawPlayerMarker(
        math.floor(ox + (GRID_COLS / 2) * CELL),
        math.floor(oy + (GRID_ROWS / 2) * CELL))

    -- ── Grid border ───────────────────────────────────────────────────
    love.graphics.setColor(PARCH_EDGE[1], PARCH_EDGE[2], PARCH_EDGE[3], 0.75)
    love.graphics.setLineWidth(1.5)
    love.graphics.rectangle("line", ox, oy, GRID_COLS * CELL, GRID_ROWS * CELL)

    -- ── Outer border ──────────────────────────────────────────────────
    love.graphics.setColor(PARCH_EDGE[1], PARCH_EDGE[2], PARCH_EDGE[3])
    love.graphics.setLineWidth(2)
    love.graphics.rectangle("line", px, py, pw, ph, 3, 3)

    -- ── Footer ────────────────────────────────────────────────────────
    local hy = oy + GRID_ROWS * CELL + 7
    love.graphics.setFont(fntHint)
    love.graphics.setColor(HINT_COL[1], HINT_COL[2], HINT_COL[3], HINT_COL[4])
    love.graphics.printf(
        "[M] Close   |   Ink: draw   |   Scratch: erase",
        px + PANEL_PAD, hy, pw - PANEL_PAD * 2, "center")

    love.graphics.setColor(1, 1, 1)
end

return Map
