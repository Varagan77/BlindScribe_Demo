local singleplayer = {}

function singleplayer.load()
	worldSeed = os.time()

	grid_load(worldSeed)
	fog_load()
	player_load()
	camera_load()
	hud_load()

	gameState = "newGame"
end

function singleplayer.update(dt)
	-- game world update happens in your main game loop, not here
end

function singleplayer.keypressed(key)
	if key == "escape" then
		gameState = "menu"
		selectedIndex = 1
	end
end

function singleplayer.draw(sw, sh)
	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.printf("Loading World...", 0, sh / 2, sw, "center")
end

return singleplayer