local multiplayer  = require("Code.Scripts.ScriptStates.StateMultiPlayer.multiplayerMenu")
local options      = require("Code.Scripts.ScriptStates.StateSettings.settingsMenu")
local about        = require("Code.Scripts.ScriptStates.StateAbout.aboutMenu")
local singleplayer = require("Code.Scripts.ScriptStates.StateSinglePlayer.singlePlayerMenu")
local exit_state   = require("Code.Scripts.ScriptStates.StateExit.exitMenu")

local menu = {}

local states = {}
local menuItems = {}

local bigFont

-- ---------------------------------------------------------------------------
function menu.load()

	gameState = "menu"
	selectedIndex = 1

	bigFont = love.graphics.newFont(24)

	menuItems = {
		{ text = "Single Player", state = "singleplayer" },
		{ text = "Multiplayer",   state = "multiplayer" },
		{ text = "Options",       state = "options" },
		{ text = "About",         state = "about" },
		{ text = "Exit",          state = "exit" },
	}

	states = {
		singleplayer = singleplayer,
		multiplayer  = multiplayer,
		options      = options,
		about        = about,
		exit         = exit_state
	}
end

-- expose states to main.lua safely
function menu.getState(name)
	return states[name]
end

-- ---------------------------------------------------------------------------
function menu.update(dt)
	-- delegate to active sub-state if one is open
	local state = states[gameState]
	if state and state.update then
		state.update(dt)
	end
end

-- ---------------------------------------------------------------------------
function menu.keypressed(key)

	-- delegate to the active sub-state when we're inside one
	if gameState ~= "menu" then
		local state = states[gameState]
		if state and state.keypressed then
			state.keypressed(key)
		end
		return
	end

	if key == "down" then
		selectedIndex = (selectedIndex % #menuItems) + 1

	elseif key == "up" then
		selectedIndex = (selectedIndex - 2) % #menuItems + 1

	elseif key == "return" then

		local chosen = menuItems[selectedIndex].state
		local state = states[chosen]

		if not state then return end

		if state.load then state.load() end
		if state.enter then state.enter() end
	end
end

-- ---------------------------------------------------------------------------
function menu.draw()

	local sw = love.graphics.getWidth()
	local sh = love.graphics.getHeight()

	-- if a sub-state is active, delegate drawing to it
	if gameState ~= "menu" then
		local state = states[gameState]
		if state and state.draw then
			love.graphics.setFont(bigFont)
			love.graphics.setColor(1, 1, 1)
			state.draw(sw, sh)
		end
		return
	end

	love.graphics.setFont(bigFont)
	love.graphics.setColor(1, 1, 1)

	love.graphics.printf("BlindScribe", 0, 100, sw, "center")

	for i, item in ipairs(menuItems) do
		local y = 200 + (i - 1) * 40

		if i == selectedIndex then
			love.graphics.setColor(1, 1, 0)
			love.graphics.printf("> " .. item.text, 0, y, sw, "center")
		else
			love.graphics.setColor(1, 1, 1)
			love.graphics.printf(item.text, 0, y, sw, "center")
		end
	end
end

return menu