Config = require("Prefabs.Config.config")

require("Code.Scripts.ScriptStates.StateMenu.menu")
require("Code.Scripts.ScriptPlayer.PlayerMovement.playerMovement")
require("Code.Scripts.ScriptMap.MapGeneration.grid")
require("Code.Scripts.ScriptPlayer.PlayerHUD.player_hud")
require("Code.Scripts.ScriptPlayer.PlayerCamera.camera")
require("Code.Scripts.ScriptPlayer.PlayerFog.fog")
require("Code.Scripts.ScriptWIP.dm")
require("Code.Scripts.ScriptWIP.dm_hud")

function love.load()
	worldSeed = os.time()
	if menu_load   then menu_load()   end
	if grid_load   then grid_load(worldSeed)   end
	if fog_load    then fog_load()    end
	if player_load then player_load() end
	if camera_load then camera_load() end
	if hud_load    then hud_load()    end
end

function love.resize(w, h)
	if hud_resize     then hud_resize()     end
	if dm_hud_resize  then dm_hud_resize()  end
end

function love.update(dt)
	if gameState == "newGame" or gameState == "win" or gameState == "lose" then
		if grid_update   then grid_update(dt)   end
		if player_update then player_update(dt) end
		if camera_update then camera_update(dt) end
		if hud_update    then hud_update(dt)    end

	elseif gameState == "dm_game" or gameState == "dm_lose" then
		if grid_update   then grid_update(dt)   end
		if dm_update     then dm_update(dt)     end

	else
		if menu_update then menu_update(dt) end
	end
end

function love.draw()
	if gameState == "newGame" or gameState == "win" or gameState == "lose" then
		
		if hud_draw then hud_draw() end

		
		if gameState == "newGame" then
			local mr = hud_getMapRect()
			love.graphics.setScissor(mr.x, mr.y, mr.w, mr.h)
				camera_attach()
					if grid_draw   then grid_draw()   end
					if player_draw then player_draw() end
					fog_draw()
				camera_detach()
			love.graphics.setScissor()

			drawEntryPopup()
			drawDiceCutscene()
		end
		

	elseif gameState == "dm_game" or gameState == "dm_lose" then
		if dm_hud_draw then dm_hud_draw() end

		if gameState == "dm_game" then
			local mr = dm_hud_getMapRect()
			love.graphics.setScissor(mr.x, mr.y, mr.w, mr.h)
				if dm_drawMap   then dm_drawMap()   end
				if dm_drawPawns then dm_drawPawns() end
			love.graphics.setScissor()
		end

		if DM and DM.debugClick then
			love.graphics.setColor(1, 1, 0, 1)
			love.graphics.setFont(love.graphics.newFont(11))
			love.graphics.print(DM.debugClick, 6, love.graphics.getHeight() - 20)
			love.graphics.setColor(1, 1, 1)
		end

	else
		if menu_draw then menu_draw() end
	end
end

function love.mousepressed(x, y, button)
	if gameState == "dm_game" then
		if dm_mousepressed then dm_mousepressed(x, y, button) end
	end
end

function love.mousemoved(x, y)
	if gameState == "dm_game" then
		if dm_mousemoved then dm_mousemoved(x, y) end
	end
end

function love.keypressed(key)
	
	if key == Config.keys.dmSwitch then
		if gameState == "dm_game" or gameState == "dm_lose" then
			
			hud_load()
			gameState = "newGame"
		else
			if gameState ~= "newGame" and gameState ~= "win" and gameState ~= "lose" then
				worldSeed = os.time()
				grid_load(worldSeed)
				fog_load()
				player_load()
				camera_load()
				hud_load()
			end
			dm_load()
			gameState = "dm_game"
		end
		return
	end

	if gameState == "newGame" then
		if player_keypressed then player_keypressed(key) end
		if camera_keypressed then camera_keypressed(key) end
		if fog_keypressed    then fog_keypressed(key)    end
		if hud_keypressed    then hud_keypressed(key)    end

	elseif gameState == "win" or gameState == "lose" then
		if hud_keypressed then hud_keypressed(key) end

	elseif gameState == "dm_game" or gameState == "dm_lose" then
		if dm_keypressed then dm_keypressed(key) end

	else
		if menu_keypressed then menu_keypressed(key) end
	end

	
	if key == Config.keys.menu
		and gameState ~= "win"
		and gameState ~= "lose"
		and gameState ~= "dm_game"
		and gameState ~= "dm_lose"
	then
		gameState     = "menu"
		selectedIndex = 1
	end
end

function love.quit()
	
	return false
end