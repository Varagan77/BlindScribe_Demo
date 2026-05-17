local HUD   = {}
local Fonts = require("Code.Scripts.ScriptUtil.fonts")

local hudFont, tinyFont, titleFont, winLoseFont

local Dice = require("Code.Scripts.ScriptStates.ScriptDice.diceEvent")

-- 5-slot hotbar inventory
local INV_SLOTS = 5
local inventory = {}
for i = 1, INV_SLOTS do inventory[i] = nil end

-- Flash feedback when using an item
local useFlash = { slot = nil, timer = 0, duration = 0.4 }

local function drawPanel(x, y, w, h, bgCol, borderCol, r)
	love.graphics.setColor(bgCol[1], bgCol[2], bgCol[3], bgCol[4] or 0.95)
	love.graphics.rectangle("fill", x, y, w, h, r or 6, r or 6)
	love.graphics.setColor(borderCol[1], borderCol[2], borderCol[3], borderCol[4] or 1)
	love.graphics.setLineWidth(1.5)
	love.graphics.rectangle("line", x, y, w, h, r or 6, r or 6)
end

function hud_load()
	local CF    = Config.fonts
	hudFont    = Fonts.body(CF.hudStat)
	tinyFont   = Fonts.body(CF.hudTiny)
	titleFont  = Fonts.body(CF.hudTitle)
	winLoseFont = Fonts.title(CF.winLose)
	inventory = {}
	for i = 1, INV_SLOTS do inventory[i] = nil end
end

function hud_update(dt)
	if useFlash.timer > 0 then
		useFlash.timer = useFlash.timer - dt
		if useFlash.timer <= 0 then
			useFlash.slot = nil
		end
	end
end

function hud_addItem(item)
	for i = 1, INV_SLOTS do
		if not inventory[i] then inventory[i] = item; return true end
	end
	return false
end

-- Use item in slot idx; returns true if consumed
function hud_useItem(idx)
	if not inventory[idx] then return false end
	local item = inventory[idx]

	-- Apply the item effect
	if item.effect == "heal" then
		player.hp = math.min(Config.player.maxHp, player.hp + (item.value or 0))
	elseif item.effect == "move" then
		player.stepsLeft = player.stepsLeft + (item.value or 0)
	elseif item.effect == "spawn_enemy" then
		-- Wrath items: spawn an enemy nearby
		local T  = Config.map.tiles
		local px = math.floor(player.grid_x / 32)
		local py = math.floor(player.grid_y / 32)
		for dy = -2, 2 do
			for dx = -2, 2 do
				local nx, ny = px + dx, py + dy
				if map and map[ny] and map[ny][nx] and map[ny][nx] == T.floor then
					map[ny][nx] = T.enemy
					break
				end
			end
		end
	end

	inventory[idx] = nil
	useFlash.slot  = idx
	useFlash.timer = useFlash.duration
	return true
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
	local FLASH_COL = {0.35, 0.90, 0.55, 1.00}

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

	-- Steps remaining bar (colour-coded by urgency)
	statY = statY + HP_BAR_H + 7
	local stepsLeft  = player.stepsLeft  or 0
	local stepBudget = _G.stepBudget     or math.max(1, stepsLeft)
	local stepPct    = math.max(0, math.min(1, stepsLeft / stepBudget))
	local STEP_BAR_W = 150
	local STEP_BAR_H = 10

	love.graphics.setFont(hudFont)
	love.graphics.setColor(LABEL[1], LABEL[2], LABEL[3])
	love.graphics.print("STEPS", STATS_X, statY + 1)

	love.graphics.setColor(0.09, 0.08, 0.12)
	love.graphics.rectangle("fill", STATS_X + 46, statY, STEP_BAR_W, STEP_BAR_H, 2, 2)

	local stepFill
	if stepPct < 0.20 then stepFill = DANGER
	elseif stepPct < 0.40 then stepFill = HP_ORANGE
	else stepFill = {0.35, 0.75, 0.95} end   -- calm blue when safe
	love.graphics.setColor(stepFill[1], stepFill[2], stepFill[3])
	love.graphics.rectangle("fill", STATS_X + 46, statY, STEP_BAR_W * stepPct, STEP_BAR_H, 2, 2)
	love.graphics.setColor(BORDER[1], BORDER[2], BORDER[3])
	love.graphics.setLineWidth(1)
	love.graphics.rectangle("line", STATS_X + 46, statY, STEP_BAR_W, STEP_BAR_H, 2, 2)

	love.graphics.setFont(tinyFont)
	love.graphics.setColor(TEXT[1], TEXT[2], TEXT[3])
	love.graphics.printf(stepsLeft .. " / " .. stepBudget, STATS_X + 46, statY, STEP_BAR_W, "center")

	-- Gold
	statY = statY + STEP_BAR_H + 7
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

		-- Flash when used
		local isFlashing = useFlash.slot == i and useFlash.timer > 0
		local flashAlpha = isFlashing and (useFlash.timer / useFlash.duration) or 0

		-- Slot shadow/depth
		love.graphics.setColor(0, 0, 0, 0.4)
		love.graphics.rectangle("fill", sx + 2, sy + 2, SLOT_SIZE, SLOT_SIZE, 4, 4)

		-- Slot bg
		if isFlashing then
			love.graphics.setColor(
				SLOT_BG[1] + flashAlpha * 0.2,
				SLOT_BG[2] + flashAlpha * 0.4,
				SLOT_BG[3] + flashAlpha * 0.2)
		else
			love.graphics.setColor(SLOT_BG[1], SLOT_BG[2], SLOT_BG[3])
		end
		love.graphics.rectangle("fill", sx, sy, SLOT_SIZE, SLOT_SIZE, 4, 4)

		local borderCol = isFlashing and FLASH_COL or SLOT_BOR
		love.graphics.setColor(borderCol[1], borderCol[2], borderCol[3], isFlashing and (0.5 + flashAlpha*0.5) or 1)
		love.graphics.setLineWidth(isFlashing and 2 or 1)
		love.graphics.rectangle("line", sx, sy, SLOT_SIZE, SLOT_SIZE, 4, 4)

		-- Slot number label (dim, bottom-right corner)
		love.graphics.setFont(tinyFont)
		love.graphics.setColor(LABEL[1], LABEL[2], LABEL[3], 0.5)
		love.graphics.print(tostring(i), sx + SLOT_SIZE - 9, sy + SLOT_SIZE - 12)

		if inventory[i] then
			local item = inventory[i]
			love.graphics.setFont(tinyFont)

			-- Colour by effect type
			local itemCol
			if item.effect == "heal" then itemCol = {0.35, 0.90, 0.55}
			elseif item.effect == "move" then itemCol = {0.40, 0.70, 1.00}
			elseif item.effect == "spawn_enemy" then itemCol = {1.00, 0.40, 0.35}
			else itemCol = GOLD_COL end

			love.graphics.setColor(itemCol[1], itemCol[2], itemCol[3])
			local name = (item.name or "?"):sub(1, 7)
			love.graphics.printf(name, sx + 2, sy + 8, SLOT_SIZE - 4, "center")

			-- Price tag tiny
			love.graphics.setColor(GOLD_COL[1], GOLD_COL[2], GOLD_COL[3], 0.6)
			if item.price then
				love.graphics.printf(item.price .. "g", sx, sy + SLOT_SIZE - 22, SLOT_SIZE - 4, "center")
			end
		end
	end

	-- Hotbar label
	love.graphics.setFont(tinyFont)
	love.graphics.setColor(LABEL[1], LABEL[2], LABEL[3], 0.5)
	love.graphics.printf("INVENTORY  [1-5 to use]", HOTBAR_X, CONSOLE_Y + 4, HOTBAR_W, "center")

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
	love.graphics.printf("[M] DRAW", BTN_X, BTN_Y + 27, BTN_W, "center")

	-- Footer
	love.graphics.setFont(tinyFont)
	love.graphics.setColor(LABEL[1], LABEL[2], LABEL[3], 0.4)
	love.graphics.printf("PLAYER CONSOLE", 0, sh - 11, sw, "center")

	-- ── Win / Lose overlays ───────────────────────────────────────────
	if gameState == "win" then
		love.graphics.setColor(0, 0, 0, 0.78)
		love.graphics.rectangle("fill", 0, 0, sw, sh)
		love.graphics.setFont(winLoseFont)
		love.graphics.setColor(ACCENT[1], ACCENT[2], ACCENT[3])
		love.graphics.printf("YOU WIN", 0, sh / 2 - 60, sw, "center")
		love.graphics.setFont(titleFont)
		love.graphics.setColor(TEXT[1], TEXT[2], TEXT[3])
		love.graphics.printf("Press ESC to return to menu", 0, sh / 2 + 20, sw, "center")
	elseif gameState == "lose" then
		love.graphics.setColor(0, 0, 0, 0.78)
		love.graphics.rectangle("fill", 0, 0, sw, sh)
		love.graphics.setFont(winLoseFont)
		love.graphics.setColor(DANGER[1], DANGER[2], DANGER[3])
		love.graphics.printf("SOUL DEVOURED", 0, sh / 2 - 70, sw, "center")
		love.graphics.setFont(titleFont)
		love.graphics.setColor(TEXT[1], TEXT[2], TEXT[3])
		love.graphics.printf("The dungeon fed on your every step.", 0, sh / 2 + 10, sw, "center")
		love.graphics.setFont(hudFont)
		love.graphics.setColor(LABEL[1], LABEL[2], LABEL[3])
		love.graphics.printf("Press ESC to return to menu", 0, sh / 2 + 38, sw, "center")
	end

	love.graphics.setColor(1, 1, 1)
end

return HUD
