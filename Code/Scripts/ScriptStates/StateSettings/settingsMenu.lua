local options = {}

function options.load()
end

function options.update(dt)
end

function options.keypressed(key)
	if key == "escape" or key == "return" then
		gameState = "menu"
		selectedIndex = 1
	end
end

function options.draw(sw, sh)
	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.printf("Options", 0, sh / 2 - 60, sw, "center")

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

return options