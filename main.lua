Config = require("Prefabs.Config.config")

require("Code.Scripts.ScriptMap.MapGeneration.grid")
require("Code.Scripts.ScriptPlayer.PlayerFog.fog")
require("Code.Scripts.ScriptPlayer.PlayerCamera.camera")

local Dice      = require("Code.Scripts.ScriptStates.ScriptDice.diceEvent")
local Encounter = require("Code.Scripts.ScriptPlayer.PlayerEncounter.playerEncounterEvent")
local Pause     = require("Code.Scripts.ScriptStates.StatePause.pauseMenu")
local menu      = require("Code.Scripts.ScriptStates.StateMenu.menu")
local TileSys   = require("Code.Managers.TileManager.tileSys")
local PlayerMap = require("Code.Scripts.ScriptPlayer.PlayerMap.playerMap")

require("Code.Scripts.ScriptPlayer.PlayerMovement.player")
require("Code.Scripts.ScriptPlayer.PlayerHUD.player_hud")

Pause.load()

gameState = "menu"

function love.load()
	menu.load()
end

-- States that belong to the sub-menus (not gameplay, not main menu)
local subMenuStates = {
	singleplayer = true, multiplayer = true,
	options = true, about = true, exit = true,
	loading = true,   -- loading screen: menu system handles it
}

function love.update(dt)
	if gameState == "menu" or subMenuStates[gameState] then
		menu.update(dt)
		return
	end

	if gameState == "paused" then
		Pause.update(dt)
		return
	end

	if gameState == "newGame" then
		if grid_update     then grid_update(dt)     end
		if player_update   then player_update(dt)   end
		if Encounter.update then Encounter.update(dt) end
		if Dice.update     then Dice.update(dt)     end
		if hud_update      then hud_update(dt)      end
		if camera_update   then camera_update(dt)   end
		if fog_tick        then fog_tick(dt)         end
		TileSys.updatePortal(dt)
	end
end

function love.draw()
	if gameState == "menu" or subMenuStates[gameState] then
		menu.draw()
		return
	end

	-- Always draw the game world underneath (even when paused)
	if gameState == "newGame" or gameState == "paused"
	   or gameState == "win"  or gameState == "lose" then
		if camera_attach    then camera_attach()    end
		if grid_draw        then grid_draw()        end
		if fog_draw         then fog_draw()         end
		if player_draw      then player_draw()      end
		if camera_detach    then camera_detach()    end
		-- screen-space overlays
		if grid_draw_hud    then grid_draw_hud()    end
		if fog_draw_cue     then fog_draw_cue()     end
		TileSys.drawPortalOverlay()
		if Encounter.draw   then Encounter.draw()   end
		if hud_draw         then hud_draw()         end
		PlayerMap.draw()
	end

	-- Pause overlay drawn on top of everything
	if gameState == "paused" then
		Pause.draw()
	end
end

function love.keypressed(key)
	if gameState == "menu" or subMenuStates[gameState] then
		menu.keypressed(key)
		return
	end

	if gameState == "paused" then
		Pause.keypressed(key)
		return
	end

	if gameState == "newGame" then
		-- ESC opens pause instead of jumping to main menu
		if key == "escape" then
			Pause.enter()
			return
		end

		-- M toggles the player map
		if key == "m" then
			PlayerMap.toggle()
			return
		end

		-- If map is open, let it eat mouse/key events for drawing
		if PlayerMap.isOpen() then
			return
		end

		-- Item use: keys 1-5 use inventory slots
		if not Encounter.isActive() and not Dice.isActive() then
			local slot = tonumber(key)
			if slot and slot >= 1 and slot <= 5 then
				hud_useItem(slot)
				return
			end
		end

		-- E: enter portal
		if key == "e" and not Encounter.isActive() and not Dice.isActive() then
			TileSys.tryEnterPortal()
			return
		end

		if camera_keypressed then camera_keypressed(key) end
		if fog_keypressed    then fog_keypressed(key)    end
		if Encounter.keypressed then Encounter.keypressed(key) end
		if debugDone and not Encounter.isActive() then
			-- If player moves while on portal, cancel the prompt
			if TileSys.portalPrompt then
				local moveKeys = { up=true, down=true, left=true, right=true }
				if moveKeys[key] then
					TileSys.portalPrompt = false
				end
			end
			if player_keypressed then player_keypressed(key) end
		end
	end

	-- Win/lose screens: ESC goes to pause/menu
	if gameState == "win" or gameState == "lose" then
		if key == "escape" then
			PlayerMap.reset()   -- clear the drawn map on game end
			gameState = "menu"
		end
	end
end

-- Mouse events — forwarded to PlayerMap for drawing
function love.mousepressed(x, y, button)
	PlayerMap.mousepressed(x, y, button)
end

function love.mousemoved(x, y, dx, dy)
	PlayerMap.mousemoved(x, y, dx, dy)
end

function love.mousereleased(x, y, button)
	PlayerMap.mousereleased(x, y, button)
end
