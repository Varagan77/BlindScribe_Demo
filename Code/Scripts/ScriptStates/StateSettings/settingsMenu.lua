local options = {}

function options.load()
end

function options.enter()
	gameState = "options"
end

function options.keypressed(key)
	if key == "escape" then
		gameState = "menu"
		selectedIndex = 1
	end
end

function options.draw(sw, sh)
	love.graphics.printf("Options (WIP)", 0, sh/2, sw, "center")
end

return options