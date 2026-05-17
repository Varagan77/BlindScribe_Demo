local about = {}

function about.load()
end

function about.enter()
	gameState = "about"
end

function about.keypressed(key)
	if key == "escape" then
		gameState = "menu"
		selectedIndex = 1
	end
end

function about.draw(sw, sh)
	love.graphics.printf("About", 0, sh/2, sw, "center")
end

return about