local multiplayer  = require("Code.Scripts.ScriptStates.StateMultiPlayer.multiplayerMenu")
local options      = require("Code.Scripts.ScriptStates.StateSettings.settingsMenu")
local about        = require("Code.Scripts.ScriptStates.StateAbout.aboutMenu")
local singleplayer = require("Code.Scripts.ScriptStates.StateSinglePlayer.singlePlayerMenu")
local exit_state   = require("Code.Scripts.ScriptStates.StateExit.exitMenu")

local states = {}

local bigFont
local smallFont

function menu_load()

	gameState = "menu"
	selectedIndex = 1

	bigFont = love.graphics.newFont(24)
	smallFont = love.graphics.newFont(14)

	menuItems = {
		{ text = "Single Player", state = "newGame"     },
		{ text = "Multiplayer",   state = "multiPlayer" },
		{ text = "Options",       state = "options"     },
		{ text = "About",         state = "about"       },
		{ text = "Exit",          state = "exit"        },
	}

	states = {
		newGame     = singleplayer,
		multiPlayer = multiplayer,
		options     = options,
		about       = about,
		exit        = exit_state
	}
end

function menu_update(dt)

	if gameState == "menu" then return end

	local state = states[gameState]
	if state and state.update then
		state.update(dt)
	end
end

function menu_keypressed(key)

	-------------------------------------------------
	-- MAIN MENU INPUT
	-------------------------------------------------
	if gameState == "menu" then

		if key == "down" then
			selectedIndex = (selectedIndex % #menuItems) + 1

		elseif key == "up" then
			selectedIndex = (selectedIndex - 2) % #menuItems + 1

		elseif key == "return" then

			local chosen = menuItems[selectedIndex].state
			gameState = chosen

			local state = states[gameState]

			if state and state.load then
				state.load()
			end
		end

		return
	end

	-------------------------------------------------
	-- EXIT 
	-------------------------------------------------
	if gameState == "exit" then

		if key == "return" then
			love.event.quit()

		elseif key == "escape" then
			gameState = "menu"
			selectedIndex = 1
		end

		return
	end

	-------------------------------------------------
	-- DELEGATE TO STATE
	-------------------------------------------------
	local state = states[gameState]

	if state and state.keypressed then
		state.keypressed(key)
	end
end

function menu_draw()

	local sw = love.graphics.getWidth()
	local sh = love.graphics.getHeight()

	-------------------------------------------------
	-- MAIN MENU
	-------------------------------------------------
	if gameState == "menu" then

		love.graphics.setFont(bigFont)
		love.graphics.setColor(1, 1, 1, 1)
		love.graphics.printf("BlindScribe", 0, 100, sw, "center")

		for i, item in ipairs(menuItems) do

			local y = 200 + (i - 1) * 40

			if i == selectedIndex then
				love.graphics.setColor(1, 1, 0, 1)
				love.graphics.printf("> " .. item.text, 0, y, sw, "center")
			else
				love.graphics.setColor(1, 1, 1, 1)
				love.graphics.printf(item.text, 0, y, sw, "center")
			end
		end

		return
	end

	-------------------------------------------------
	-- EXIT SCREEN
	-------------------------------------------------
	if gameState == "exit" then

		love.graphics.setFont(bigFont)
		love.graphics.setColor(1, 1, 1, 1)

		love.graphics.printf(
			"Press ENTER to quit\nor ESC to return to menu.",
			0,
			sh / 2 - 40,
			sw,
			"center"
		)

		return
	end

	-------------------------------------------------
	-- DELEGATE DRAW TO STATE
	-------------------------------------------------
	local state = states[gameState]

	if state and state.draw then
		state.draw(sw, sh)
	end
end