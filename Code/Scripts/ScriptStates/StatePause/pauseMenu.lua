-- =============================================================================
--  pauseMenu.lua  —  In-game pause overlay
--  Items: Continue | Options | Quit to Menu
-- =============================================================================

local Pause = {}

local items = {
	{ label = "CONTINUE",      action = "resume"   },
	{ label = "OPTIONS",       action = "options"  },
	{ label = "QUIT TO MENU",  action = "menu"     },
}

local selected    = 1
local titleFont   = nil
local itemFont    = nil
local smallFont   = nil
local alpha       = 0      -- fade-in
local FADE_SPEED  = 6

function Pause.load()
	titleFont = love.graphics.newFont(28)
	itemFont  = love.graphics.newFont(16)
	smallFont = love.graphics.newFont(10)
end

function Pause.enter()
	selected = 1
	alpha    = 0
	gameState = "paused"
end

function Pause.update(dt)
	-- Fade in
	alpha = math.min(1, alpha + dt * FADE_SPEED)
end

function Pause.keypressed(key)
	if key == "escape" then
		Pause.resume()
		return
	end

	if key == "up" or key == "w" then
		selected = (selected - 2) % #items + 1
	elseif key == "down" or key == "s" then
		selected = (selected % #items) + 1
	elseif key == "return" or key == "space" then
		Pause.activate(items[selected].action)
	end
end

function Pause.activate(action)
	if action == "resume" then
		Pause.resume()
	elseif action == "options" then
		-- WIP: just flash label for now
	elseif action == "menu" then
		gameState = "menu"
		if menu_load then menu_load() end   -- re-init main menu if needed
	end
end

function Pause.resume()
	gameState = "newGame"
end

function Pause.draw()
	local sw, sh = love.graphics.getWidth(), love.graphics.getHeight()
	local a = alpha

	-- Backdrop blur simulation: dark vignette over game
	love.graphics.setColor(0, 0, 0, 0.72 * a)
	love.graphics.rectangle("fill", 0, 0, sw, sh)

	-- Panel
	local PW, PH = 320, 220
	local px = math.floor((sw - PW) / 2)
	local py = math.floor((sh - PH) / 2)

	-- Panel shadow
	love.graphics.setColor(0, 0, 0, 0.55 * a)
	love.graphics.rectangle("fill", px + 6, py + 6, PW, PH, 10, 10)

	-- Panel body
	love.graphics.setColor(0.06, 0.05, 0.09, 0.97 * a)
	love.graphics.rectangle("fill", px, py, PW, PH, 10, 10)

	-- Panel border
	love.graphics.setColor(0.28, 0.24, 0.38, a)
	love.graphics.setLineWidth(1.5)
	love.graphics.rectangle("line", px, py, PW, PH, 10, 10)

	-- Inner accent line
	love.graphics.setColor(0.22, 0.18, 0.30, a * 0.6)
	love.graphics.setLineWidth(1)
	love.graphics.rectangle("line", px + 6, py + 6, PW - 12, PH - 12, 7, 7)

	-- Title
	love.graphics.setFont(titleFont)
	love.graphics.setColor(0.35, 0.85, 0.75, a)
	love.graphics.printf("PAUSED", px, py + 22, PW, "center")

	-- Divider
	love.graphics.setColor(0.25, 0.22, 0.34, a * 0.7)
	love.graphics.setLineWidth(1)
	love.graphics.line(px + 30, py + 62, px + PW - 30, py + 62)

	-- Menu items
	local itemSpacing = 42
	local itemStartY  = py + 78

	for i, item in ipairs(items) do
		local iy  = itemStartY + (i - 1) * itemSpacing
		local isSel = i == selected

		if isSel then
			-- Selection highlight pill
			love.graphics.setColor(0.18, 0.15, 0.26, a)
			love.graphics.rectangle("fill", px + 20, iy - 6, PW - 40, 30, 6, 6)
			love.graphics.setColor(0.35, 0.30, 0.50, a * 0.8)
			love.graphics.setLineWidth(1)
			love.graphics.rectangle("line", px + 20, iy - 6, PW - 40, 30, 6, 6)

			-- Selector chevron
			love.graphics.setColor(0.35, 0.85, 0.75, a)
			love.graphics.printf("›", px + 20, iy, 30, "center")
		end

		love.graphics.setFont(itemFont)
		if isSel then
			love.graphics.setColor(0.90, 0.88, 0.96, a)
		else
			love.graphics.setColor(0.46, 0.42, 0.58, a)
		end
		love.graphics.printf(item.label, px, iy, PW, "center")
	end

	-- Footer hint
	love.graphics.setFont(smallFont)
	love.graphics.setColor(0.30, 0.27, 0.40, a * 0.7)
	love.graphics.printf("ESC  resume   ↑↓  navigate   ENTER  select", px, py + PH - 18, PW, "center")

	love.graphics.setColor(1, 1, 1)
end

return Pause
