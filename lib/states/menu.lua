function menu_load()
	gameState     = "menu"
	selectedIndex = 1

	menuItems = {
		{ text = "Single Player", state = "newGame"     },
		{ text = "Multiplayer",   state = "multiPlayer" },
		{ text = "Options",       state = "options"     },
		{ text = "About",         state = "about"       },
		{ text = "Exit",          state = "exit"        },
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
			local chosen = menuItems[selectedIndex].state

			if chosen == "newGame" then
				worldSeed = os.time()
				grid_load(worldSeed)
				fog_load()
				player_load()
				camera_load()
				hud_load()
				gameState = "newGame"
			else
				gameState = chosen
			end
		end

	elseif gameState == "multiPlayer"
		or gameState == "options"
		or gameState == "about"
	then
		if key == "escape" or key == "return" then
			gameState     = "menu"
			selectedIndex = 1
		end

	elseif gameState == "exit" then
		if key == "return" then
			love.event.quit()
		elseif key == "escape" then
			gameState     = "menu"
			selectedIndex = 1
		end
	end
end

function menu_draw()
	local sw = love.graphics.getWidth()
	local sh = love.graphics.getHeight()

	love.graphics.setFont(love.graphics.newFont(24))

	if gameState == "menu" then
		love.graphics.setColor(1, 1, 1, 1)
		love.graphics.printf("BlindScribe", 0, 100, sw, "center")

		for i, item in ipairs(menuItems) do
			local y = 200 + (i - 1) * 40
			if i == selectedIndex then
				love.graphics.setColor(1, 1, 0, 1)
				love.graphics.printf("> " .. item.text, 0, y, sw, "center")
			else
				love.graphics.setColor(1, 1, 1, 1)
				love.graphics.printf(item.text, 0, y, sw, "center")
			end
		end

	elseif gameState == "multiPlayer" then
		love.graphics.setColor(1, 1, 1, 1)
		love.graphics.printf("Multiplayer", 0, sh / 2 - 60, sw, "center")
		love.graphics.setFont(love.graphics.newFont(14))
		love.graphics.setColor(0.6, 0.6, 0.6, 1)
		love.graphics.printf("Coming soon.\n\nPress ESC or ENTER to return.", 0, sh / 2, sw, "center")

	elseif gameState == "options" then
		love.graphics.setColor(1, 1, 1, 1)
		love.graphics.printf("Options", 0, sh / 2 - 60, sw, "center")
		love.graphics.setFont(love.graphics.newFont(14))
		love.graphics.setColor(0.6, 0.6, 0.6, 1)
		love.graphics.printf("Coming soon.\n\nPress ESC or ENTER to return.", 0, sh / 2, sw, "center")

	elseif gameState == "about" then
		love.graphics.setColor(1, 1, 1, 1)
		love.graphics.printf("About", 0, sh / 2 - 60, sw, "center")
		love.graphics.setFont(love.graphics.newFont(14))
		love.graphics.setColor(0.6, 0.6, 0.6, 1)
		love.graphics.printf("BlindScribe\nA dungeon crawler with a Dungeon Master mode.\n\nPress ESC or ENTER to return.", 0, sh / 2, sw, "center")

	elseif gameState == "exit" then
		love.graphics.setColor(1, 1, 1, 1)
		love.graphics.printf("Press ENTER to quit\nor ESC to return to menu.", 0, sh / 2 - 20, sw, "center")
	end
end