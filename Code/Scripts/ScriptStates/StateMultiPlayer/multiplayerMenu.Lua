local multiplayer = {}

function multiplayer.load()
end

function multiplayer.enter()
	gameState = "multiplayer"
end

function multiplayer.update(dt)
end

function multiplayer.keypressed(key)
	if key == "escape" then
		gameState = "menu"
		selectedIndex = 1
	end
end

function multiplayer.draw(sw, sh)
	love.graphics.printf("Multiplayer (WIP)", 0, sh/2, sw, "center")
end

return multiplayer