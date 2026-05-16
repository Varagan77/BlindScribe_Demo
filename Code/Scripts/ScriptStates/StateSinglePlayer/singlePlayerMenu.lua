local singleplayer = {}

function singleplayer.load()
	worldSeed = os.time()

	grid_load(worldSeed)
	fog_load()
	player_load()
	camera_load()
	hud_load()
end

function singleplayer.enter()
	gameState = "newGame"
end

function singleplayer.keypressed(key)
	if key == "escape" then
		gameState = "menu"
		selectedIndex = 1
	end
end

function singleplayer.draw(sw, sh)
	love.graphics.printf("Loading World...", 0, sh/2, sw, "center")
end

return singleplayer