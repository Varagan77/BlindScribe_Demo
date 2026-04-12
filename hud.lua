function hud_draw()
	if not gridReady() then return end

	local sw = love.graphics.getWidth()
	local sh = love.graphics.getHeight()

	
	if gameState == "win" then
		love.graphics.setColor(0, 0, 0, 0.75)
		love.graphics.rectangle("fill", 0, 0, sw, sh)

		love.graphics.setFont(love.graphics.newFont(28))
		love.graphics.setColor(0.5, 1, 1)
		love.graphics.printf("The Dungeon crumbles behind you...", 0, sh / 2 - 80, sw, "center")

		love.graphics.setFont(love.graphics.newFont(16))
		love.graphics.setColor(1, 1, 1)
		love.graphics.printf(
			"Gold collected : " .. player.gold .. "\n" ..
			"Damage taken   : " .. player.damageTaken .. "\n" ..
			"Shop visited   : " .. (player.shopVisited and "Yes" or "No") .. "\n" ..
			"Portal used    : " .. (player.portalUsed and "Yes" or "No"),
			0, sh / 2 - 20, sw, "center"
		)

		love.graphics.setColor(0.7, 0.7, 0.7)
		love.graphics.printf("Press ENTER to return to menu", 0, sh / 2 + 90, sw, "center")
		love.graphics.setColor(1, 1, 1)
		return
	end

	
	local lines = {
		"[ DEBUG ]",
		"Pos    : " .. (player.grid_x / 32) .. ", " .. (player.grid_y / 32),
		"HP     : " .. player.hp,
		"Gold   : " .. player.gold,
		"Dmg    : " .. player.damageTaken,
		"Shop   : " .. (player.shopVisited and "visited" or "no"),
		"Portal : " .. (player.portalUsed and "used" or "no"),
		"Cam    : " .. (camera.enabled and "ON  [F1]" or "OFF [F1]"),
		"Fog    : " .. (fog.enabled and "ON  [F2]" or "OFF [F2]"),
	}

	local pad = 6
	local lineH = 16
	local panelW = 150
	local panelH = #lines * lineH + pad * 2

	love.graphics.setColor(0, 0, 0, 0.6)
	love.graphics.rectangle("fill", 4, 4, panelW, panelH)

	for i, line in ipairs(lines) do
		if i == 1 then
			love.graphics.setColor(0.5, 1, 1) 
		elseif line:find("HP") and player.hp <= 3 then
			love.graphics.setColor(1, 0.3, 0.3) 
		elseif line:find("Cam") or line:find("Fog") then
			love.graphics.setColor(0.8, 0.8, 0.4) 
		else
			love.graphics.setColor(1, 1, 1)
		end
		love.graphics.setFont(love.graphics.newFont(12))
		love.graphics.print(line, pad + 4, pad + (i - 1) * lineH + 4)
	end

	love.graphics.setColor(1, 1, 1)
end


function hud_keypressed(key)
	if gameState == "win" and key == "return" then
		gameState = "menu"
		selectedIndex = 1
		grid_load() 
		fog_load()
		player_load()
		camera_load()
	end
end