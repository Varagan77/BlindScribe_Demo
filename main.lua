require("src.menu")
require("src.player")
require("src.grid")
require("src.hud")
require("src.camera")
require("src.fog")
require("src.shop")

function love.load()
	menu_load()
	grid_load()
	fog_load()
	player_load()
	camera_load()
	hud_load()
end

function love.resize(w, h)
	hud_resize()
end

function love.update(dt)
	if gameState == "newGame" or gameState == "win" then
		grid_update(dt)
		player_update(dt)
		camera_update(dt)
		hud_update(dt)
	else
		menu_update(dt)
	end
end

function love.draw()
	if gameState == "win" then
		hud_draw()
	elseif gameState == "newGame" then
		hud_draw()

		local mr = hud_getMapRect()
		love.graphics.setScissor(mr.x, mr.y, mr.w, mr.h)
			camera_attach()
				grid_draw()
				player_draw()
				fog_draw()
			camera_detach()
		love.graphics.setScissor()

		drawEntryPopup()
		drawDiceCutscene()
		shop_draw()
	else
		menu_draw()
	end
end

function love.mousepressed(mx, my, btn)
	if gameState == "newGame" then
		shop_mousepressed(mx, my, btn)
	end
end

function love.keypressed(key)
	if gameState == "newGame" then
		player_keypressed(key)
		camera_keypressed(key)
		fog_keypressed(key)
		hud_keypressed(key)
		shop_keypressed(key)
	elseif gameState == "win" then
		hud_keypressed(key)
	else
		menu_keypressed(key)
	end

	if key == "escape" and gameState ~= "win" then
		if shop_isOpen() then
			shop_close()
		else
			gameState     = "menu"
			selectedIndex = 1
		end
	end
end