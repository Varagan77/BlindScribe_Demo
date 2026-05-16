Config = require("Prefabs.Config.config")

require("Code.Scripts.ScriptMap.MapGeneration.grid")

local Dice = require("Code.Scripts.ScriptStates.ScriptDice.diceEvent")
local Encounter = require("Code.Scripts.ScriptPlayer.PlayerEncounter.playerEncounterEvent")
local menu = require("Code.Scripts.ScriptStates.StateMenu.menu")

require("Code.Scripts.ScriptPlayer.PlayerMovement.player")
require("Code.Scripts.ScriptPlayer.PlayerHUD.player_hud")

gameState = "menu"

function love.load()
	menu.load()
end

function love.update(dt)
	if gameState == "menu" then
		menu.update(dt)
		return
	end

	if player_update then player_update(dt) end
	if Encounter.update then Encounter.update(dt) end
	if Dice.update then Dice.update(dt) end
	if hud_update then hud_update(dt) end
end

function love.draw()
	if gameState == "menu" then
		menu.draw()
		return
	end

	if hud_draw then hud_draw() end

	if gameState == "newGame" then
		if player_draw then player_draw() end
		if Encounter.draw then Encounter.draw() end
		if Dice.draw then Dice.draw() end
	end
end

function love.keypressed(key)
	if gameState == "menu" then
		menu.keypressed(key)
		return
	end

	if Encounter.keypressed then Encounter.keypressed(key) end
	if player_keypressed then player_keypressed(key) end

	if key == "escape" then
		gameState = "menu"
	end
end