local about = {}

function about.load()
end

function about.update(dt)
end

function about.keypressed(key)
	if key == "escape" or key == "return" then
		gameState = "menu"
		selectedIndex = 1
	end
end

function about.draw(sw, sh)
	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.printf("About", 0, sh / 2 - 80, sw, "center")

	love.graphics.setFont(love.graphics.newFont(14))
	love.graphics.setColor(0.6, 0.6, 0.6, 1)

	love.graphics.printf(
		"BlindScribe\nA dungeon crawler with a Dungeon Master mode.\n\nPress ESC or ENTER to return.",
		0,
		sh / 2,
		sw,
		"center"
	)
end

return about