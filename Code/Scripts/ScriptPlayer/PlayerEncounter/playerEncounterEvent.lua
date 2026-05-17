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

-- Shop UI state
local shopPage     = nil   -- nil, "spritus", or "kinesis" (wrath stays top-level)
local shopItems    = {}    -- 3 items displayed for current page
local shopSelected = 1
local shopFont     = nil
local shopSmFont   = nil

-- ── Question-mark animation config ────────────────────────────────────────────
local QM = {
	totalTime  = 2.6,
	revealAt   = 1.8,
	fontSize   = 72,
	smallFont  = 18,
}

local qmFont    = nil
local qmSmFont  = nil

local function loadFonts()
	if not qmFont   then qmFont   = love.graphics.newFont(QM.fontSize)  end
	if not qmSmFont then qmSmFont = love.graphics.newFont(QM.smallFont) end
	if not shopFont  then shopFont  = love.graphics.newFont(15)          end
	if not shopSmFont then shopSmFont = love.graphics.newFont(11)         end
end

-- ── Public API ────────────────────────────────────────────────────────────────

function Encounter.start(kind)
	loadFonts()
	qmark = {
		kind    = kind,
		elapsed = 0,
		done    = false,
		scale   = 0,
		angle   = 0,
	}
	active    = nil
	shopPage  = nil
	shopItems = {}
end

function Encounter.isActive()
	return active ~= nil or qmark ~= nil or Dice.isActive()
end

local function setShopPage(groupName)
	shopPage = groupName
	shopSelected = 1
	shopItems = {}
	if groupName then
		local group = Config.shop and Config.shop.groups and Config.shop.groups[groupName]
		if group and group.items then
			for i = 1, math.min(3, #group.items) do
				shopItems[i] = group.items[i]
			end
		end
	end
end

function Encounter.update(dt)
	if Dice.isActive() then return end

	-- ── Question-mark phase ───────────────────────────────────────────
	if qmark then
		qmark.elapsed = qmark.elapsed + dt
		local e = qmark.elapsed

		if e < 0.35 then
			qmark.scale = e / 0.35
		else
			qmark.scale = 1.0 + math.sin(e * 6) * 0.04
		end

		qmark.angle = math.sin(e * 3) * 0.06

		if e >= QM.totalTime then
			active    = { kind = qmark.kind }
			shopPage  = nil
			shopItems = {}
			qmark     = nil
		end
		return
	end
end

-- ── Shop drawing helpers ───────────────────────────────────────────────────────

local function drawShopPanel(x, y, w, h, selected)
	local PANEL   = {0.07, 0.06, 0.12, 0.98}
	local BORDER  = selected and {0.55, 0.90, 0.65, 1} or {0.22, 0.20, 0.34, 1}
	local r = 8
	love.graphics.setColor(PANEL[1],PANEL[2],PANEL[3],PANEL[4])
	love.graphics.rectangle("fill", x, y, w, h, r, r)
	love.graphics.setColor(BORDER[1],BORDER[2],BORDER[3])
	love.graphics.setLineWidth(selected and 2 or 1.2)
	love.graphics.rectangle("line", x, y, w, h, r, r)
end

local function drawShopItemPanel(x, y, w, h, item, idx, canAfford)
	local GOLD    = {1.00, 0.82, 0.22}
	local TEXT    = {0.90, 0.88, 0.94}
	local LABEL   = {0.46, 0.42, 0.58}
	local RED     = {1.00, 0.30, 0.30}
	local ACCENT  = {0.35, 0.85, 0.75}

	drawShopPanel(x, y, w, h, false)

	love.graphics.setFont(shopFont)
	love.graphics.setColor(TEXT[1],TEXT[2],TEXT[3])
	love.graphics.printf("[" .. idx .. "] " .. (item.name or "?"), x + 8, y + 10, w - 16, "left")

	love.graphics.setFont(shopSmFont)
	love.graphics.setColor(LABEL[1],LABEL[2],LABEL[3])
	local desc = ""
	if item.effect == "heal" then desc = "Heals " .. (item.value or 0) .. " HP"
	elseif item.effect == "move" then desc = "+" .. (item.value or 0) .. " Move Points"
	elseif item.effect == "spawn_enemy" then desc = "Spawns " .. (item.value or 1) .. " enemy"
	end
	love.graphics.printf(desc, x + 8, y + 30, w - 16, "left")

	-- Price
	local priceCol = canAfford and GOLD or RED
	love.graphics.setColor(priceCol[1],priceCol[2],priceCol[3])
	love.graphics.setFont(shopFont)
	love.graphics.printf((item.price or 0) .. "g", x, y + 10, w - 8, "right")
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

		local overlayA = math.min(e / 0.4, 1) * 0.82
		love.graphics.setColor(0, 0, 0, overlayA)
		love.graphics.rectangle("fill", 0, 0, sw, sh)

		if qmark.scale <= 0 then return end

		local col, glowCol
		if kind == "enemy" then
			col     = {1.00, 0.22, 0.22}
			glowCol = {0.80, 0.10, 0.10}
		elseif kind == "gold" then
			col     = {1.00, 0.88, 0.18}
			glowCol = {0.70, 0.55, 0.05}
		elseif kind == "shop" then
			col     = {0.35, 0.90, 0.65}
			glowCol = {0.15, 0.55, 0.35}
		else
			col     = {0.70, 0.70, 0.85}
			glowCol = {0.30, 0.30, 0.50}
		end

		local s = qmark.scale
		local a = math.min(e / 0.3, 1)

		local glowR = 56 * s + math.sin(e * 5) * 4
		love.graphics.setColor(glowCol[1], glowCol[2], glowCol[3], a * 0.35)
		love.graphics.circle("fill", cx, cy - 20, glowR + 18)
		love.graphics.setColor(glowCol[1], glowCol[2], glowCol[3], a * 0.18)
		love.graphics.circle("fill", cx, cy - 20, glowR + 36)

		love.graphics.push()
		love.graphics.translate(cx, cy - 20)
		love.graphics.rotate(qmark.angle)
		love.graphics.scale(s, s)

		local showReveal = e >= QM.revealAt

		love.graphics.setFont(qmFont)

		love.graphics.setColor(0, 0, 0, a * 0.55)
		love.graphics.printf(showReveal and "!" or "?",
			-sw / 2 + 3, -QM.fontSize / 2 + 3, sw, "center")

		love.graphics.setColor(col[1], col[2], col[3], a)
		love.graphics.printf(showReveal and "!" or "?",
			-sw / 2, -QM.fontSize / 2, sw, "center")

		love.graphics.pop()

		if showReveal then
			local labelA = math.min((e - QM.revealAt) / 0.25, 1)
			local label
			if kind == "enemy" then label = "DANGER"
			elseif kind == "gold" then label = "TREASURE"
			elseif kind == "shop" then label = "MERCHANT"
			else label = "???" end

			love.graphics.setFont(qmSmFont)
			love.graphics.setColor(0, 0, 0, labelA * 0.6)
			love.graphics.printf(label, 1, cy + 48, sw, "center")
			love.graphics.setColor(col[1], col[2], col[3], labelA)
			love.graphics.printf(label, 0, cy + 47, sw, "center")

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

	-- Colour palette
	local BG      = {0.04, 0.03, 0.08, 0.94}
	local BORDER  = {0.26, 0.22, 0.40, 1.00}
	local TEXT    = {0.90, 0.88, 0.94}
	local ACCENT  = {0.35, 0.85, 0.75}
	local GOLD    = {1.00, 0.82, 0.22}
	local RED     = {1.00, 0.28, 0.28}
	local LABEL   = {0.46, 0.42, 0.58}

	love.graphics.setColor(0, 0, 0, 0.80)
	love.graphics.rectangle("fill", 0, 0, sw, sh)

	if active.kind == "enemy" then
		love.graphics.setFont(qmSmFont or love.graphics.newFont(18))
		love.graphics.setColor(TEXT[1],TEXT[2],TEXT[3])
		love.graphics.printf(
			"An enemy blocks your path!\n\nPress SPACE to roll the dice",
			0, sh / 2 - 30, sw, "center")

	elseif active.kind == "gold" then
		love.graphics.setFont(qmSmFont or love.graphics.newFont(18))
		love.graphics.setColor(TEXT[1],TEXT[2],TEXT[3])
		love.graphics.printf(
			"You found gold!\n\nPress SPACE to roll the dice",
			0, sh / 2 - 30, sw, "center")

	elseif active.kind == "shop" then
		-- ── SHOP UI ───────────────────────────────────────────────────────
		local panelW = math.min(sw - 80, 520)
		local panelH = shopPage and 280 or 260
		local px     = (sw - panelW) / 2
		local py     = (sh - panelH) / 2

		-- Background panel
		love.graphics.setColor(BG[1],BG[2],BG[3],BG[4])
		love.graphics.rectangle("fill", px, py, panelW, panelH, 12, 12)
		love.graphics.setColor(BORDER[1],BORDER[2],BORDER[3])
		love.graphics.setLineWidth(2)
		love.graphics.rectangle("line", px, py, panelW, panelH, 12, 12)

		-- Title
		love.graphics.setFont(shopFont)
		love.graphics.setColor(ACCENT[1],ACCENT[2],ACCENT[3])
		if shopPage then
			local group = Config.shop.groups[shopPage]
			love.graphics.printf((group and group.name or shopPage) .. " — Choose an item", px, py + 14, panelW, "center")
		else
			love.graphics.printf("⚗ THE MERCHANT ⚗", px, py + 14, panelW, "center")
		end

		-- Gold display
		love.graphics.setFont(shopSmFont)
		love.graphics.setColor(GOLD[1],GOLD[2],GOLD[3])
		love.graphics.printf("Your Gold: " .. (player and player.gold or 0), px, py + 36, panelW, "center")

		-- Divider line
		love.graphics.setColor(BORDER[1],BORDER[2],BORDER[3],0.5)
		love.graphics.setLineWidth(1)
		love.graphics.line(px + 16, py + 56, px + panelW - 16, py + 56)

		if not shopPage then
			-- ── Top-level: 3 category buttons + exit ──────────────────────────
			local categories = {
				{ key="1", name="Spritus",  group="spritus",  desc="Healing & restoration",    col={0.35,0.90,0.65} },
				{ key="2", name="Kinesis",  group="kinesis",  desc="Movement & flow",           col={0.40,0.70,1.00} },
				{ key="3", name="Wrath",    group="wrath",    desc="Risk & destruction",        col={1.00,0.45,0.35} },
			}
			local btnW = (panelW - 48) / 3
			local btnH = 70
			local btnY = py + 70

			for i, cat in ipairs(categories) do
				local bx = px + 16 + (i-1) * (btnW + 8)
				love.graphics.setColor(0.07,0.06,0.12,0.98)
				love.graphics.rectangle("fill", bx, btnY, btnW, btnH, 8, 8)
				love.graphics.setColor(cat.col[1]*0.6, cat.col[2]*0.6, cat.col[3]*0.6)
				love.graphics.setLineWidth(1.5)
				love.graphics.rectangle("line", bx, btnY, btnW, btnH, 8, 8)

				love.graphics.setFont(shopFont)
				love.graphics.setColor(cat.col[1],cat.col[2],cat.col[3])
				love.graphics.printf("[" .. cat.key .. "] " .. cat.name, bx, btnY + 12, btnW, "center")

				love.graphics.setFont(shopSmFont)
				love.graphics.setColor(LABEL[1],LABEL[2],LABEL[3])
				love.graphics.printf(cat.desc, bx + 4, btnY + 36, btnW - 8, "center")
			end

			-- Wrath extra note
			love.graphics.setFont(shopSmFont)
			love.graphics.setColor(RED[1],RED[2],RED[3],0.7)
			love.graphics.printf("⚠ Wrath items spawn enemies!", px, btnY + btnH + 8, panelW, "center")

			-- Exit
			love.graphics.setFont(shopSmFont)
			love.graphics.setColor(LABEL[1],LABEL[2],LABEL[3])
			love.graphics.printf("[4] Leave the shop", px, py + panelH - 28, panelW, "center")

		else
			-- ── Item sub-page ──────────────────────────────────────────────────
			local itemH = 54
			local itemW = panelW - 32
			local playerGold = player and player.gold or 0

			for i, item in ipairs(shopItems) do
				local iy = py + 65 + (i-1) * (itemH + 6)
				local canAfford = playerGold >= (item.price or 0)
				drawShopItemPanel(px + 16, iy, itemW, itemH, item, i, canAfford)
			end

			-- Back / exit
			love.graphics.setFont(shopSmFont)
			love.graphics.setColor(LABEL[1],LABEL[2],LABEL[3])
			love.graphics.printf("[4] Back    [5] Leave shop", px, py + panelH - 26, panelW, "center")
		end
	end

	love.graphics.setColor(1, 1, 1)
end

-- ── Close encounter and consume the tile ──────────────────────────────────────
local function closeEncounter()
	local tx = math.floor(player.grid_x / 32)
	local ty = math.floor(player.grid_y / 32)
	if map and map[ty] and map[ty][tx] then
		map[ty][tx] = Config.map.tiles.floor
	end
	active    = nil
	shopPage  = nil
	shopItems = {}
end

function Encounter.keypressed(key)
	if Dice.isActive() then return end
	if qmark then return end
	if not active then return end

	if active.kind ~= "shop" then
		if key == "space" then
			local roll = love.math.random(1, 6)
			TileSys.resolveEncounter(active.kind, roll, player)
			Dice.startRoll(active.kind == "gold", roll)
			closeEncounter()
		end
		return
	end

	-- ── SHOP keypressed ────────────────────────────────────────────────────
	local playerGold = player and player.gold or 0

	if not shopPage then
		-- Top-level: choose category
		if key == "1" then
			setShopPage("spritus")
		elseif key == "2" then
			setShopPage("kinesis")
		elseif key == "3" then
			-- Wrath: pick a random item immediately (keep old behaviour)
			local group = Config.shop and Config.shop.groups and Config.shop.groups["wrath"]
			if group and group.items then
				local item = group.items[love.math.random(#group.items)]
				if playerGold >= (item.price or 0) then
					player.gold = player.gold - (item.price or 0)
					TileSys.applyShop(item, player, map)
					hud_addItem(item)
				end
			end
			closeEncounter()
		elseif key == "4" then
			closeEncounter()
		end
	else
		-- Sub-page: choose item 1-3, back=4, leave=5
		local idx = tonumber(key)
		if idx and idx >= 1 and idx <= 3 and shopItems[idx] then
			local item = shopItems[idx]
			if playerGold >= (item.price or 0) then
				player.gold = player.gold - (item.price or 0)
				TileSys.applyShop(item, player, map)
				hud_addItem(item)
				closeEncounter()
			end
			-- if can't afford: do nothing (stay in shop)
		elseif key == "4" then
			-- back to top level
			shopPage  = nil
			shopItems = {}
		elseif key == "5" then
			closeEncounter()
		end
	end
end

return Encounter
