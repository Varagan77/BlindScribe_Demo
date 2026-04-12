function player_load()
	player = {
		grid_x = spawnX * 32,
		grid_y = spawnY * 32,
		act_x = spawnX * 32,
		act_y = spawnY * 32,
		speed = 10,

		-- stats
		hp = 10,
		gold = 0,
		damageTaken = 0,
		shopVisited = false,
		portalUsed = false,
	}

	diceRoll = nil 
	entryPopup = false 
	entryTimer = 0

	fog_reveal(spawnX, spawnY)
end


function player_update(dt)
	player.act_y = player.act_y - ((player.act_y - player.grid_y) * player.speed * dt)
	player.act_x = player.act_x - ((player.act_x - player.grid_x) * player.speed * dt)

	
	if entryTimer > 0 then
		entryTimer = entryTimer - dt
	end

	if not diceRoll then return end

	
	diceRoll.elapsed = diceRoll.elapsed + dt
	local e = diceRoll.elapsed

	

	if e >= 4.0 then
		diceRoll = nil 

	elseif e >= 0.8 and e < 3.0 then
		
		local progress = (e - 0.8) / (3.0 - 0.8) 
		local interval = 0.06 + progress * 0.25 

		diceRoll.spinTimer = diceRoll.spinTimer + dt
		if diceRoll.spinTimer >= interval then
			diceRoll.spinTimer = 0
			diceRoll.showing = love.math.random(1, 6) 
		end
	end
end


function player_draw()
	if not gridReady() then return end

	
	if entryPopup == false then
		entryPopup = true
		entryTimer = 3.5
	end

	
	local cx = player.grid_x / 32
	local cy = player.grid_y / 32
	local neighbours = {
		{cx, cy - 1},
		{cx, cy + 1},
		{cx - 1, cy},
		{cx + 1, cy},
	}

	love.graphics.setColor(0, 1, 0, 0.85)
	for _, n in ipairs(neighbours) do
		local nx, ny = n[1], n[2]
		if map[ny] and map[ny][nx] and map[ny][nx] ~= 1 then
			love.graphics.circle("fill", nx * 32 + 16, ny * 32 + 16, 5)
		end
	end

	love.graphics.setColor(1, 1, 1)
	love.graphics.rectangle("fill", player.act_x, player.act_y, 32, 32)
	love.graphics.setColor(1, 1, 1)
end


function drawEntryPopup() 
	if not entryPopup or entryTimer <= 0 then return end

	local sw = love.graphics.getWidth()
	local sh = love.graphics.getHeight()
	local total = 3.5
	local elapsed = total - entryTimer

	local alpha
	if elapsed < 1 then
		alpha = elapsed
	elseif entryTimer < 1 then
		alpha = entryTimer
	else
		alpha = 1
	end

	love.graphics.setFont(love.graphics.newFont(20))
	love.graphics.setColor(0.7, 0.9, 1, alpha * 0.85)
	love.graphics.printf("You entered the dungeon...", 0, sh / 2 - 60, sw, "center")
	love.graphics.setFont(love.graphics.newFont(13))
	love.graphics.setColor(0.6, 0.6, 0.6, alpha * 0.6)
	love.graphics.printf("find the exit", 0, sh / 2 - 30, sw, "center")
	love.graphics.setColor(1, 1, 1)
end


function drawDiceCutscene() 
	if not diceRoll then return end

	local sw = love.graphics.getWidth()
	local sh = love.graphics.getHeight()
	local e = diceRoll.elapsed
	local cx = sw / 2
	local cy = sh / 2

	local isGold = diceRoll.isGold

	
	local overlayAlpha = math.min(e / 0.8, 1) * 0.75
	love.graphics.setColor(0, 0, 0, overlayAlpha)
	love.graphics.rectangle("fill", 0, 0, sw, sh)


	local cubeAlpha = math.min(e / 0.6, 1)
	if cubeAlpha <= 0 then return end


	local angle = 0
	if e >= 0.8 and e < 3.0 then
		local progress = (e - 0.8) / (3.0 - 0.8) 
		local spinSpeed = 18 * (1 - progress) + 1 
		diceRoll.angle = (diceRoll.angle or 0) + spinSpeed * (1 / 60) 
		angle = diceRoll.angle
	elseif e >= 3.0 then
		angle = 0 
	else
		angle = 0 
	end


	local size = 40
	local skew = math.sin(angle) * size * 0.4 
	local sideWidth = math.abs(math.cos(angle) * size * 0.4)

	if isGold then
		love.graphics.setColor(1, 0.85, 0, cubeAlpha) 
	else
		love.graphics.setColor(0.9, 0.1, 0.1, cubeAlpha) 
	end

	
	love.graphics.rectangle("fill", cx - size, cy - size - 10, size * 2, size * 2)

	
	if isGold then
		love.graphics.setColor(1, 1, 0.3, cubeAlpha)
	else
		love.graphics.setColor(1, 0.3, 0.3, cubeAlpha)
	end
	love.graphics.polygon("fill",
		cx - size,          cy - size - 10,
		cx + size,          cy - size - 10,
		cx + size + skew,   cy - size - 10 - sideWidth,
		cx - size + skew,   cy - size - 10 - sideWidth
	)

	
	if isGold then
		love.graphics.setColor(0.7, 0.55, 0, cubeAlpha)
	else
		love.graphics.setColor(0.6, 0.05, 0.05, cubeAlpha)
	end
	love.graphics.polygon("fill",
		cx + size,          cy - size - 10,
		cx + size,          cy + size - 10,
		cx + size + skew,   cy + size - 10 - sideWidth,
		cx + size + skew,   cy - size - 10 - sideWidth
	)

	
	local numText
	local numAlpha = cubeAlpha
	if e < 0.8 then
		numText = "?"
	elseif e >= 3.0 then
		numText = tostring(diceRoll.result)
		
		local punchProgress = math.min((e - 3.0) / 0.2, 1)
		local numSize = math.floor(28 + (1 - punchProgress) * 24)
		love.graphics.setFont(love.graphics.newFont(numSize))
		love.graphics.setColor(1, 1, 1, numAlpha)
		love.graphics.printf(numText, cx - size, cy - size + 10, size * 2, "center")
		numText = nil 
	else
		numText = tostring(diceRoll.showing)
	end

	if numText then
		love.graphics.setFont(love.graphics.newFont(28))
		love.graphics.setColor(1, 1, 1, numAlpha)
		love.graphics.printf(numText, cx - size, cy - size + 10, size * 2, "center")
	end

	
	if e >= 3.5 then
		local labelAlpha = math.min((e - 3.5) / 0.3, 1)
		love.graphics.setFont(love.graphics.newFont(16))
		if isGold then
			love.graphics.setColor(1, 1, 0.4, labelAlpha)
			love.graphics.printf("+" .. diceRoll.result .. " gold", 0, cy + size + 20, sw, "center")
		else
			love.graphics.setColor(1, 0.3, 0.3, labelAlpha)
			love.graphics.printf("-" .. diceRoll.result .. " hp", 0, cy + size + 20, sw, "center")
		end
	end

	
	if e < 0.8 then
		local suspenseAlpha = math.min(e / 0.4, 1)
		love.graphics.setFont(love.graphics.newFont(13))
		if isGold then
			love.graphics.setColor(1, 1, 0.5, suspenseAlpha * 0.7)
			love.graphics.printf("something shimmers...", 0, cy + size + 20, sw, "center")
		else
			love.graphics.setColor(1, 0.3, 0.3, suspenseAlpha * 0.7)
			love.graphics.printf("something stirs in the dark...", 0, cy + size + 20, sw, "center")
		end
	end

	love.graphics.setColor(1, 1, 1)
	love.graphics.setLineWidth(1)
end


function handleTile(tileX, tileY) 
	local tile = map[tileY][tileX]

	if tile == 7 then 
		local roll = love.math.random(1, 6)
		player.gold = player.gold + roll
		map[tileY][tileX] = 0
		diceRoll = {
			isGold = true,
			result = roll,
			showing = 1,
			elapsed = 0,
			spinTimer = 0,
			angle = 0,
		}

	elseif tile == 3 then 
		local roll = love.math.random(1, 6)
		player.hp = player.hp - roll
		player.damageTaken = player.damageTaken + roll
		map[tileY][tileX] = 0 
		diceRoll = {
			isGold = false,
			result = roll,
			showing = 1,
			elapsed = 0,
			spinTimer = 0,
			angle = 0,
		}

	elseif tile == 2 then 
		player.shopVisited = true

	elseif tile == 4 and not player.portalUsed then
		player.portalUsed = true
		for y = 1, #map do
			for x = 1, #map[y] do
				if map[y][x] == 5 then
					player.grid_x = x * 32
					player.grid_y = y * 32
					fog_reveal(x, y)
					return
				end
			end
		end

	elseif tile == 6 then 
		gameState = "win"
	end
end


function player_keypressed(key) 
	if not gridReady() then return end
	if gameState == "win" then return end
	if diceRoll then return end

	local moved = false
	local newX = player.grid_x / 32
	local newY = player.grid_y / 32

	if key == "up" and testMap(0, -1) then
		player.grid_y = player.grid_y - 32
		newY = newY - 1
		moved = true
	elseif key == "down" and testMap(0, 1) then
		player.grid_y = player.grid_y + 32
		newY = newY + 1
		moved = true
	elseif key == "left" and testMap(-1, 0) then
		player.grid_x = player.grid_x - 32
		newX = newX - 1
		moved = true
	elseif key == "right" and testMap(1, 0) then
		player.grid_x = player.grid_x + 32
		newX = newX + 1
		moved = true
	end

	if moved then
		fog_reveal(newX, newY)
		handleTile(newX, newY)
	end
end