local HUD = {}

local hudFont, tinyFont, titleFont

local Dice = require("Code.Scripts.ScriptStates.ScriptDice.diceEvent")

-- 5-slot hotbar inventory
local INV_SLOTS = 5
local inventory = {}
for i = 1, INV_SLOTS do inventory[i] = nil end

local function drawPanel(x, y, w, h, bgCol, borderCol, r)
	love.graphics.setColor(bgCol[1], bgCol[2], bgCol[3], bgCol[4] or 0.95)
	love.graphics.rectangle("fill", x, y, w, h, r or 6, r or 6)
	love.graphics.setColor(borderCol[1], borderCol[2], borderCol[3], borderCol[4] or 1)
	love.graphics.setLineWidth(1.5)
	love.graphics.rectangle("line", x, y, w, h, r or 6, r or 6)
end

function hud_load()
	hudFont   = love.graphics.newFont(11)
	tinyFont  = love.graphics.newFont(9)
	titleFont = love.graphics.newFont(13)
	inventory = {}
	for i = 1, INV_SLOTS do inventory[i] = nil end
end

function hud_update(dt) end

function hud_addItem(item)
	for i = 1, INV_SLOTS do
		if not inventory[i] then inventory[i] = item; return true end
	end
	return false
end

function hud_draw()
	if not player then return end

	-- Black out the HUD entirely while dice is rolling for suspense
	if Dice and Dice.isActive and Dice.isActive() then
		local sw, sh = love.graphics.getWidth(), love.graphics.getHeight()
		local CONSOLE_H = 90
		love.graphics.setColor(0, 0, 0, 1)
		love.graphics.rectangle("fill", 0, sh - CONSOLE_H, sw, CONSOLE_H)
		love.graphics.setColor(1, 1, 1)
		return
	end

	local sw, sh = love.graphics.getWidth(), love.graphics.getHeight()

	-- Colour palette
	local BG        = {0.05, 0.04, 0.07, 0.97}
	local PANEL     = {0.08, 0.07, 0.11, 0.98}
	local BORDER    = {0.26, 0.22, 0.36, 1.00}
	local BORDER2   = {0.18, 0.16, 0.26, 1.00}
	local TEXT      = {0.90, 0.88, 0.94}
	local LABEL     = {0.46, 0.42, 0.58}
	local GOLD_COL  = {1.00, 0.82, 0.22}
	local ACCENT    = {0.35, 0.85, 0.75}
	local DANGER    = {1.00, 0.28, 0.28}
	local HP_GREEN  = {0.18, 0.72, 0.32}
	local HP_ORANGE = {0.85, 0.60, 0.10}
	local SLOT_BG   = {0.09, 0.08, 0.13, 1.00}
	local SLOT_BOR  = {0.20, 0.17, 0.28, 1.00}
	local BTN_BG    = {0.13, 0.11, 0.20, 1.00}
	local BTN_BOR   = {0.38, 0.33, 0.55, 1.00}
	local ICON_BG   = {0.07, 0.06, 0.10, 1.00}

	local PAD        = 8
	local CONSOLE_H  = 90
	local CONSOLE_Y  = sh - CONSOLE_H

	-- Full-width bottom console
	drawPanel(0, CONSOLE_Y, sw, CONSOLE_H, BG, BORDER, 0)
	love.graphics.setColor(BORDER[1], BORDER[2], BORDER[3], 0.5)
	love.graphics.setLineWidth(1)
	love.graphics.line(0, CONSOLE_Y, sw, CONSOLE_Y)

	-- ── Portrait / Icon ───────────────────────────────────────────────
	local ICON_SIZE = 72
	local ICON_X    = PAD + 2
	local ICON_Y    = CONSOLE_Y + (CONSOLE_H - ICON_SIZE) / 2

	drawPanel(ICON_X, ICON_Y, ICON_SIZE, ICON_SIZE, ICON_BG, BORDER2, 4)

	love.graphics.setFont(tinyFont)
	love.graphics.setColor(LABEL[1], LABEL[2], LABEL[3])
	love.graphics.printf("INSERT\nICON\nHERE", ICON_X, ICON_Y + ICON_SIZE / 2 - 14, ICON_SIZE, "center")

	-- ── Stats block ───────────────────────────────────────────────────
	local STATS_X = ICON_X + ICON_SIZE + PAD + 4
	local STATS_Y = CONSOLE_Y + PAD + 2

	love.graphics.setFont(titleFont)
	love.graphics.setColor(ACCENT[1], ACCENT[2], ACCENT[3])
	love.graphics.print("PLAYER 1  \xE2\x80\x94  EXPLORER", STATS_X, STATS_Y)

	local statY = STATS_Y + 18

	-- HP bar
	local hp    = player.hp or 0
	local maxHp = Config.player.maxHp or 10
	local hpPct = math.max(0, math.min(1, hp / maxHp))
	local HP_BAR_W = 150
	local HP_BAR_H = 10

	love.graphics.setFont(hudFont)
	love.graphics.setColor(LABEL[1], LABEL[2], LABEL[3])
	love.graphics.print("HP", STATS_X, statY + 1)

	love.graphics.setColor(0.09, 0.08, 0.12)
	love.graphics.rectangle("fill", STATS_X + 24, statY, HP_BAR_W, HP_BAR_H, 2, 2)

	local barFill
	if hpPct < 0.35 then barFill = DANGER
	elseif hpPct < 0.6 then barFill = HP_ORANGE
	else barFill = HP_GREEN end
	love.graphics.setColor(barFill[1], barFill[2], barFill[3])
	love.graphics.rectangle("fill", STATS_X + 24, statY, HP_BAR_W * hpPct, HP_BAR_H, 2, 2)
	love.graphics.setColor(BORDER[1], BORDER[2], BORDER[3])
	love.graphics.setLineWidth(1)
	love.graphics.rectangle("line", STATS_X + 24, statY, HP_BAR_W, HP_BAR_H, 2, 2)

	love.graphics.setFont(tinyFont)
	love.graphics.setColor(TEXT[1], TEXT[2], TEXT[3])
	love.graphics.printf(hp .. " / " .. maxHp, STATS_X + 24, statY, HP_BAR_W, "center")

	-- Moves
	statY = statY + HP_BAR_H + 7
	love.graphics.setFont(hudFont)
	love.graphics.setColor(LABEL[1], LABEL[2], LABEL[3])
	love.graphics.print("MOVES LEFT", STATS_X, statY)
	love.graphics.setColor(TEXT[1], TEXT[2], TEXT[3])
	love.graphics.print("  " .. tostring(player.movePoints or 0), STATS_X + 80, statY)

	-- Gold
	statY = statY + 14
	love.graphics.setColor(GOLD_COL[1], GOLD_COL[2], GOLD_COL[3])
	love.graphics.print("GOLD", STATS_X, statY)
	love.graphics.setColor(TEXT[1], TEXT[2], TEXT[3])
	love.graphics.print("  " .. tostring(player.gold or 0), STATS_X + 80, statY)

	-- ── 5-slot inventory hotbar ───────────────────────────────────────
	local SLOT_SIZE = 52
	local SLOT_GAP  = 4
	local HOTBAR_W  = INV_SLOTS * (SLOT_SIZE + SLOT_GAP) - SLOT_GAP
	local HOTBAR_X  = math.floor((sw - HOTBAR_W) / 2)
	local HOTBAR_Y  = CONSOLE_Y + (CONSOLE_H - SLOT_SIZE) / 2

	for i = 1, INV_SLOTS do
		local sx = HOTBAR_X + (i - 1) * (SLOT_SIZE + SLOT_GAP)
		local sy = HOTBAR_Y

		-- Slot shadow/depth
		love.graphics.setColor(0, 0, 0, 0.4)
		love.graphics.rectangle("fill", sx + 2, sy + 2, SLOT_SIZE, SLOT_SIZE, 4, 4)

		-- Slot bg
		love.graphics.setColor(SLOT_BG[1], SLOT_BG[2], SLOT_BG[3])
		love.graphics.rectangle("fill", sx, sy, SLOT_SIZE, SLOT_SIZE, 4, 4)
		love.graphics.setColor(SLOT_BOR[1], SLOT_BOR[2], SLOT_BOR[3])
		love.graphics.setLineWidth(1)
		love.graphics.rectangle("line", sx, sy, SLOT_SIZE, SLOT_SIZE, 4, 4)

		-- Slot number label (dim, bottom-right corner)
		love.graphics.setFont(tinyFont)
		love.graphics.setColor(LABEL[1], LABEL[2], LABEL[3], 0.5)
		love.graphics.print(tostring(i), sx + SLOT_SIZE - 9, sy + SLOT_SIZE - 12)

		if inventory[i] then
			love.graphics.setFont(hudFont)
			love.graphics.setColor(GOLD_COL[1], GOLD_COL[2], GOLD_COL[3])
			local name = (inventory[i].name or "?"):sub(1, 4)
			love.graphics.printf(name, sx, sy + SLOT_SIZE / 2 - 6, SLOT_SIZE, "center")
		end
	end

	-- Hotbar label
	love.graphics.setFont(tinyFont)
	love.graphics.setColor(LABEL[1], LABEL[2], LABEL[3], 0.5)
	love.graphics.printf("INVENTORY", HOTBAR_X, CONSOLE_Y + 4, HOTBAR_W, "center")

	-- ── MAP button ────────────────────────────────────────────────────
	local BTN_W = 82
	local BTN_H = 46
	local BTN_X = sw - BTN_W - PAD * 2
	local BTN_Y = CONSOLE_Y + (CONSOLE_H - BTN_H) / 2

	drawPanel(BTN_X, BTN_Y, BTN_W, BTN_H, BTN_BG, BTN_BOR, 6)
	love.graphics.setFont(titleFont)
	love.graphics.setColor(ACCENT[1], ACCENT[2], ACCENT[3])
	love.graphics.printf("MAP", BTN_X, BTN_Y + 7, BTN_W, "center")
	love.graphics.setFont(tinyFont)
	love.graphics.setColor(LABEL[1], LABEL[2], LABEL[3])
	love.graphics.printf("DRAW MAP", BTN_X, BTN_Y + 27, BTN_W, "center")

	-- Footer
	love.graphics.setFont(tinyFont)
	love.graphics.setColor(LABEL[1], LABEL[2], LABEL[3], 0.4)
	love.graphics.printf("PLAYER CONSOLE", 0, sh - 11, sw, "center")

	-- ── Win / Lose overlays ───────────────────────────────────────────
	love.graphics.setFont(titleFont)
	if gameState == "win" then
		love.graphics.setColor(0, 0, 0, 0.78)
		love.graphics.rectangle("fill", 0, 0, sw, sh)
		love.graphics.setColor(ACCENT[1], ACCENT[2], ACCENT[3])
		love.graphics.printf("YOU WIN\n\nPress ESC to return to menu", 0, sh / 2 - 40, sw, "center")
	elseif gameState == "lose" then
		love.graphics.setColor(0, 0, 0, 0.78)
		love.graphics.rectangle("fill", 0, 0, sw, sh)
		love.graphics.setColor(DANGER[1], DANGER[2], DANGER[3])
		love.graphics.printf("YOU DIED\n\nPress ESC to return to menu", 0, sh / 2 - 40, sw, "center")
	end

	love.graphics.setColor(1, 1, 1)
end

return HUD
