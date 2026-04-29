function menu_load()
	gameState     = "menu"
	selectedIndex = 1

	menuItems = {
		{ text = "New Game", state = "newGame" },
		{ text = "Options",  state = "options" },
		{ text = "About",    state = "about"   },
		{ text = "Exit",     state = "exit"    },
	}
end

function menu_update(dt)
end

function menu_keypressed(key)
	if gameState == "menu" then
		if key == "down" then
			selectedIndex = selectedIndex % #menuItems + 1
		elseif key == "up" then
			selectedIndex = (selectedIndex - 2) % #menuItems + 1
		elseif key == "return" then
			gameState = menuItems[selectedIndex].state
		end
	elseif gameState == "exit" then
		if key == "return" then
			love.event.quit()
		end
	end
end

function menu_draw()
	love.graphics.setFont(love.graphics.newFont(24))

	if gameState == "menu" then
		love.graphics.setColor(1, 1, 1, 1)
		love.graphics.printf("BlindScribe", 20, 100, love.graphics.getWidth(), "center")

		for i, item in ipairs(menuItems) do
			local y = 200 + (i - 1) * 40
			if i == selectedIndex then
				love.graphics.setColor(1, 1, 0, 1)
				love.graphics.print("> " .. item.text, 20, y)
			else
				love.graphics.setColor(1, 1, 1, 1)
				love.graphics.print(item.text, 20, y)
			end
		end

	elseif gameState == "options" then
		love.graphics.setColor(1, 0, 0, 1)
		love.graphics.printf("Options Insert \n  ESC to return", 0, 300, love.graphics.getWidth(), "center")

	elseif gameState == "about" then
		love.graphics.setColor(1, 0, 0, 1)
		love.graphics.printf("About insert \n  ESC to return", 0, 300, love.graphics.getWidth(), "center")

	elseif gameState == "exit" then
		love.graphics.setColor(1, 0, 0, 1)
		love.graphics.printf("Press ENTER to quit or ESC to return", 0, 350, love.graphics.getWidth(), "center")
	end
end
