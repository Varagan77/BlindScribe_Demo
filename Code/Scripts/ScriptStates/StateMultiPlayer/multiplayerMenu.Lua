local multiplayer = {}

function multiplayer.load()
	-- setup multiplayer menu / future lobby
end

function multiplayer.update(dt)
end

function multiplayer.keypressed(key)
	if key == "escape" or key == "return" then
		gameState = "menu"
		selectedIndex = 1
	end
end

function multiplayer.draw(sw, sh)
	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.printf("Multiplayer", 0, sh / 2 - 60, sw, "center")

	love.graphics.setFont(love.graphics.newFont(14))
	love.graphics.setColor(0.6, 0.6, 0.6, 1)

	love.graphics.printf(
		"Coming soon.\n\nPress ESC or ENTER to return.",
		0,
		sh / 2,
		sw,
		"center"
	)
end

return multiplayer