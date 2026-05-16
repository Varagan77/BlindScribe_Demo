local exit = {}

function exit.load()
end

function exit.update(dt)
end

function exit.keypressed(key)
	if key == "return" then
		love.event.quit()
	elseif key == "escape" then
		gameState = "menu"
		selectedIndex = 1
	end
end

function exit.draw(sw, sh)
	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.printf(
		"Press ENTER to quit\nor ESC to return to menu.",
		0,
		sh / 2,
		sw,
		"center"
	)
end

return exit