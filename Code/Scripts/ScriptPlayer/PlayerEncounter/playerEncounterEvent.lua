-- =============================================================================
--  playerEncounterEvent.lua
--  Adds a "?" reveal cutscene before the encounter screen.
--  Phases:  qmark  →  reveal  →  encounter  →  (dice via diceEvent)
-- =============================================================================

local Dice    = require("Code.Scripts.ScriptStates.ScriptDice.diceEvent")
local TileSys = require("Code.Managers.TileManager.tileSys")

local Encounter = {}

local active  = nil   -- current encounter table
local qmark   = nil   -- question-mark animation state

-- ── Question-mark animation config ────────────────────────────────────────────
local QM = {
	totalTime  = 2.6,   -- seconds before handing off to encounter screen
	revealAt   = 1.8,   -- when "?" morphs into the actual type label
	fontSize   = 72,
	smallFont  = 18,
}

local qmFont    = nil
local qmSmFont  = nil

local function loadFonts()
	if not qmFont   then qmFont   = love.graphics.newFont(QM.fontSize)  end
	if not qmSmFont then qmSmFont = love.graphics.newFont(QM.smallFont) end
end

-- ── Public API ────────────────────────────────────────────────────────────────

function Encounter.start(kind)
	loadFonts()
	-- Start the "?" cutscene, then hand off to the normal encounter
	qmark = {
		kind    = kind,
		elapsed = 0,
		done    = false,
		-- pulsing scale state
		scale   = 0,
		angle   = 0,
	}
	active = nil   -- encounter screen shown only after qmark finishes
end

function Encounter.isActive()
	return active ~= nil or qmark ~= nil or Dice.isActive()
end

function Encounter.update(dt)
	if Dice.isActive() then return end

	-- ── Question-mark phase ───────────────────────────────────────────
	if qmark then
		qmark.elapsed = qmark.elapsed + dt
		local e = qmark.elapsed

		-- Grow in, then slight pulse, then hold
		if e < 0.35 then
			qmark.scale = e / 0.35        -- grow from 0→1
		else
			-- gentle bob
			qmark.scale = 1.0 + math.sin(e * 6) * 0.04
		end

		qmark.angle = math.sin(e * 3) * 0.06   -- subtle tilt

		if e >= QM.totalTime then
			-- hand off to encounter
			active  = { kind = qmark.kind }
			qmark   = nil
		end
		return
	end
end

function Encounter.draw()
	if Dice.isActive() then
		Dice.draw()
		return
	end

	local sw, sh = love.graphics.getWidth(), love.graphics.getHeight()
	local cx, cy = sw / 2, sh / 2

	-- ── Question-mark cutscene ────────────────────────────────────────
	if qmark then
		local e    = qmark.elapsed
		local kind = qmark.kind

		-- Dark overlay, fades in
		local overlayA = math.min(e / 0.4, 1) * 0.82
		love.graphics.setColor(0, 0, 0, overlayA)
		love.graphics.rectangle("fill", 0, 0, sw, sh)

		if qmark.scale <= 0 then return end

		-- Colour depends on type
		local col, glowCol
		if kind == "enemy" then
			col     = {1.00, 0.22, 0.22}
			glowCol = {0.80, 0.10, 0.10}
		elseif kind == "gold" then
			col     = {1.00, 0.88, 0.18}
			glowCol = {0.70, 0.55, 0.05}
		else
			col     = {0.70, 0.70, 0.85}
			glowCol = {0.30, 0.30, 0.50}
		end

		local s = qmark.scale
		local a = math.min(e / 0.3, 1)   -- overall alpha

		-- Glow ring (drawn behind)
		local glowR = 56 * s + math.sin(e * 5) * 4
		love.graphics.setColor(glowCol[1], glowCol[2], glowCol[3], a * 0.35)
		love.graphics.circle("fill", cx, cy - 20, glowR + 18)
		love.graphics.setColor(glowCol[1], glowCol[2], glowCol[3], a * 0.18)
		love.graphics.circle("fill", cx, cy - 20, glowR + 36)

		-- Transform: scale + tilt
		love.graphics.push()
		love.graphics.translate(cx, cy - 20)
		love.graphics.rotate(qmark.angle)
		love.graphics.scale(s, s)

		-- "?" character (or revealed type after revealAt)
		local showReveal = e >= QM.revealAt

		love.graphics.setFont(qmFont)

		-- Shadow
		love.graphics.setColor(0, 0, 0, a * 0.55)
		love.graphics.printf(showReveal and "!" or "?",
			-sw / 2 + 3, -QM.fontSize / 2 + 3, sw, "center")

		-- Main glyph
		love.graphics.setColor(col[1], col[2], col[3], a)
		love.graphics.printf(showReveal and "!" or "?",
			-sw / 2, -QM.fontSize / 2, sw, "center")

		love.graphics.pop()

		-- Suspense label — appears at revealAt
		if showReveal then
			local labelA = math.min((e - QM.revealAt) / 0.25, 1)
			local label
			if kind == "enemy" then
				label = "DANGER"
			elseif kind == "gold" then
				label = "TREASURE"
			else
				label = "???"
			end

			love.graphics.setFont(qmSmFont)
			love.graphics.setColor(0, 0, 0, labelA * 0.6)
			love.graphics.printf(label, 1, cy + 48, sw, "center")
			love.graphics.setColor(col[1], col[2], col[3], labelA)
			love.graphics.printf(label, 0, cy + 47, sw, "center")

			-- Prompt hint fades in near end
			if e >= QM.totalTime - 0.5 then
				local hintA = math.min((e - (QM.totalTime - 0.5)) / 0.4, 1)
				love.graphics.setColor(0.60, 0.58, 0.70, hintA)
				love.graphics.printf("brace yourself...", 0, cy + 74, sw, "center")
			end
		end

		love.graphics.setColor(1, 1, 1)
		return
	end

	-- ── Normal encounter screen ───────────────────────────────────────
	if not active then return end

	love.graphics.setColor(0, 0, 0, 0.72)
	love.graphics.rectangle("fill", 0, 0, sw, sh)

	love.graphics.setFont(qmSmFont or love.graphics.newFont(18))
	love.graphics.setColor(1, 1, 1)

	if active.kind == "enemy" then
		love.graphics.printf(
			"An enemy blocks your path!\n\nPress SPACE to roll the dice",
			0, sh / 2 - 30, sw, "center")
	elseif active.kind == "gold" then
		love.graphics.printf(
			"You found gold!\n\nPress SPACE to roll the dice",
			0, sh / 2 - 30, sw, "center")
	elseif active.kind == "shop" then
		love.graphics.printf(
			"A shop appears...\n\n1) Spritus (Heal)   2) Kinesis (Move)   3) Wrath (Risk)   4) Leave",
			0, sh / 2 - 30, sw, "center")
	end

	love.graphics.setColor(1, 1, 1)
end

function Encounter.keypressed(key)
	if Dice.isActive() then return end
	if qmark then return end   -- ignore all input during "?" animation
	if not active then return end

	if active.kind ~= "shop" then
		if key == "space" then
			local roll = love.math.random(1, 6)
			TileSys.resolveEncounter(active.kind, roll, player)
			Dice.startRoll(active.kind == "gold", roll)

			local tx = math.floor(player.grid_x / 32)
			local ty = math.floor(player.grid_y / 32)
			if map and map[ty] and map[ty][tx] then
				map[ty][tx] = Config.map.tiles.floor
			end

			active = nil
		end
		return
	end

	-- shop
	local shopGroups = { "spritus", "kinesis", "wrath" }
	if key == "1" or key == "2" or key == "3" then
		local idx       = tonumber(key)
		local groupName = shopGroups[idx]
		local group     = Config.shop and Config.shop.groups and Config.shop.groups[groupName]
		if group and group.items then
			local item = group.items[love.math.random(#group.items)]
			TileSys.applyShop(item, player, map)
		end
		local tx = math.floor(player.grid_x / 32)
		local ty = math.floor(player.grid_y / 32)
		if map and map[ty] and map[ty][tx] then
			map[ty][tx] = Config.map.tiles.floor
		end
		active = nil
	elseif key == "4" then
		active = nil
	end
end

return Encounter
