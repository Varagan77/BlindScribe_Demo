local playerSprite
local playerQuad


local F = {}

function player_load()
	local PC = Config.player

	player = {
		grid_x = spawnX * 32,
		grid_y = spawnY * 32,
		act_x  = spawnX * 32,
		act_y  = spawnY * 32,
		speed  = PC.speed,

		hp          = PC.hp,
		gold        = PC.gold,
		damageTaken = 0,
		movePoints  = 0,
		shopVisited = false,
		portalUsed  = false,
	}

	diceRoll   = nil
	entryPopup = false
	entryTimer = 0

	fog_reveal(spawnX, spawnY)

	local AQ     = Config.assets.quads.playerTile
	playerSprite = love.graphics.newImage(Config.assets.tileSheet)
	playerQuad   = love.graphics.newQuad(
		AQ.srcX, AQ.srcY,
		AQ.w,    AQ.h,
		playerSprite:getDimensions()
	)

	F.f13 = love.graphics.newFont(13)
	F.f16 = love.graphics.newFont(16)
	F.f20 = love.graphics.newFont(20)
	F.f28 = love.graphics.newFont(28)
end


function player_update(dt)
	if not player then return end

	player.act_y = player.act_y - ((player.act_y - player.grid_y) * player.speed * dt)
	player.act_x = player.act_x - ((player.act_x - player.grid_x) * player.speed * dt)

	if entryTimer > 0 then
		entryTimer = entryTimer - dt
	end

	if not diceRoll then
		
		if player.hp <= 0 and gameState == "newGame" then
			player.hp = 0
			gameState = "lose"
		end
		return
	end

	local D = Config.player.dice
	diceRoll.elapsed = diceRoll.elapsed + dt
	local e = diceRoll.elapsed

	if e >= D.totalTime then
		diceRoll = nil
		
		if player.hp <= 0 and gameState == "newGame" then
			player.hp = 0
			gameState = "lose"
		end

	elseif e >= D.spinStart and e < D.spinEnd then
		local progress = (e - D.spinStart) / (D.spinEnd - D.spinStart)
		local interval = D.minInterval + progress * (D.maxInterval - D.minInterval)
		diceRoll.spinTimer = diceRoll.spinTimer + dt
		if diceRoll.spinTimer >= interval then
			diceRoll.spinTimer = 0
			diceRoll.showing   = love.math.random(1, 6)
		end
	end
end


function player_draw()
	if not gridReady() then return end

	if entryPopup == false then
		entryPopup = true
		entryTimer = Config.player.entryPopupDuration
	end

	local cx = player.grid_x / 32
	local cy = player.grid_y / 32
	local neighbours = {
		{cx, cy - 1}, {cx, cy + 1}, {cx - 1, cy}, {cx + 1, cy},
	}

	love.graphics.setColor(0, 1, 0, 0.85)
	for _, n in ipairs(neighbours) do
		local nx, ny = n[1], n[2]
		if map[ny] and map[ny][nx] and map[ny][nx] ~= Config.map.tiles.wall then
			love.graphics.circle("fill", nx * 32 + 16, ny * 32 + 16, 5)
		end
	end

	love.graphics.setColor(1, 1, 1)
	love.graphics.draw(playerSprite, playerQuad, player.act_x, player.act_y)
	love.graphics.setColor(1, 1, 1)
end


function drawEntryPopup()
	if not entryPopup or entryTimer <= 0 then return end

	local sw      = love.graphics.getWidth()
	local sh      = love.graphics.getHeight()
	local total   = Config.player.entryPopupDuration
	local elapsed = total - entryTimer

	local alpha
	if elapsed < 1 then       alpha = elapsed
	elseif entryTimer < 1 then alpha = entryTimer
	else                       alpha = 1 end

	love.graphics.setFont(F.f20)
	love.graphics.setColor(0.7, 0.9, 1, alpha * 0.85)
	love.graphics.printf("You entered the dungeon...", 0, sh / 2 - 60, sw, "center")
	love.graphics.setFont(F.f13)
	love.graphics.setColor(0.6, 0.6, 0.6, alpha * 0.6)
	love.graphics.printf("find the exit", 0, sh / 2 - 30, sw, "center")
	love.graphics.setColor(1, 1, 1)
end


function drawDiceCutscene()
	if not diceRoll then return end

	local D  = Config.player.dice
	local sw = love.graphics.getWidth()
	local sh = love.graphics.getHeight()
	local e  = diceRoll.elapsed
	local cx = sw / 2
	local cy = sh / 2

	local isGold = diceRoll.isGold

	local overlayAlpha = math.min(e / 0.8, 1) * 0.75
	love.graphics.setColor(0, 0, 0, overlayAlpha)
	love.graphics.rectangle("fill", 0, 0, sw, sh)

	local cubeAlpha = math.min(e / 0.6, 1)
	if cubeAlpha <= 0 then return end

	local angle = 0
	if e >= D.spinStart and e < D.spinEnd then
		local progress  = (e - D.spinStart) / (D.spinEnd - D.spinStart)
		local spinSpeed = 18 * (1 - progress) + 1
		diceRoll.angle  = (diceRoll.angle or 0) + spinSpeed * (1 / 60)
		angle = diceRoll.angle
	end

	local size      = 40
	local skew      = math.sin(angle) * size * 0.4
	local sideWidth = math.abs(math.cos(angle) * size * 0.4)

	if isGold then love.graphics.setColor(1, 0.85, 0, cubeAlpha)
	else            love.graphics.setColor(0.9, 0.1, 0.1, cubeAlpha) end
	love.graphics.rectangle("fill", cx - size, cy - size - 10, size * 2, size * 2)

	if isGold then love.graphics.setColor(1, 1, 0.3, cubeAlpha)
	else            love.graphics.setColor(1, 0.3, 0.3, cubeAlpha) end
	love.graphics.polygon("fill",
		cx - size,        cy - size - 10,
		cx + size,        cy - size - 10,
		cx + size + skew, cy - size - 10 - sideWidth,
		cx - size + skew, cy - size - 10 - sideWidth
	)

	if isGold then love.graphics.setColor(0.7, 0.55, 0, cubeAlpha)
	else            love.graphics.setColor(0.6, 0.05, 0.05, cubeAlpha) end
	love.graphics.polygon("fill",
		cx + size,        cy - size - 10,
		cx + size,        cy + size - 10,
		cx + size + skew, cy + size - 10 - sideWidth,
		cx + size + skew, cy - size - 10 - sideWidth
	)

	local numText
	local numAlpha = cubeAlpha
	if e < D.spinStart then
		numText = "?"
	elseif e >= D.spinEnd then
		numText = tostring(diceRoll.result)
		local punchProgress = math.min((e - D.spinEnd) / 0.2, 1)
		local numSize = math.floor(28 + (1 - punchProgress) * 24)
		love.graphics.setFont(love.graphics.newFont(numSize))
		love.graphics.setColor(1, 1, 1, numAlpha)
		love.graphics.printf(numText, cx - size, cy - size + 10, size * 2, "center")
		numText = nil
	else
		numText = tostring(diceRoll.showing)
	end

	if numText then
		love.graphics.setFont(F.f28)
		love.graphics.setColor(1, 1, 1, numAlpha)
		love.graphics.printf(numText, cx - size, cy - size + 10, size * 2, "center")
	end

	if e >= D.spinEnd + 0.5 then
		local labelAlpha = math.min((e - (D.spinEnd + 0.5)) / 0.3, 1)
		love.graphics.setFont(F.f16)
		if isGold then
			love.graphics.setColor(1, 1, 0.4, labelAlpha)
			love.graphics.printf("+" .. diceRoll.result .. " gold", 0, cy + size + 20, sw, "center")
		else
			love.graphics.setColor(1, 0.3, 0.3, labelAlpha)
			love.graphics.printf("-" .. diceRoll.result .. " hp", 0, cy + size + 20, sw, "center")
		end
	end

	if e < D.spinStart then
		local suspenseAlpha = math.min(e / 0.4, 1)
		love.graphics.setFont(F.f13)
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
	local T    = Config.map.tiles
	local tile = map[tileY][tileX]

	if tile == T.gold then
		local roll = love.math.random(1, 6)
		player.gold       = player.gold + roll
		map[tileY][tileX] = T.floor
		diceRoll = { isGold = true, result = roll, showing = 1, elapsed = 0, spinTimer = 0, angle = 0 }
		hud_log("Found gold!")

	elseif tile == T.enemy then
		local roll = love.math.random(1, 6)
		player.hp          = math.max(0, player.hp - roll)
		player.damageTaken = player.damageTaken + roll
		map[tileY][tileX]  = T.floor
		diceRoll = { isGold = false, result = roll, showing = 1, elapsed = 0, spinTimer = 0, angle = 0 }
		hud_log("Attacked! -" .. roll .. " HP")
		if DM then dm_onPawnDamage(roll) end

	elseif tile == T.shop then
		player.shopVisited = true
		hud_log("You found a shop.")

	elseif tile == T.portalIn and not player.portalUsed then
		player.portalUsed = true
		hud_log("Portal used!")
		for y = 1, #map do
			for x = 1, #map[y] do
				if map[y][x] == T.portalOut then
					player.grid_x = x * 32
					player.grid_y = y * 32
					fog_reveal(x, y)
					return
				end
			end
		end

	elseif tile == T.exit then
		gameState = "win"
	end
end


function player_keypressed(key)
	if not gridReady()        then return end
	if gameState ~= "newGame" then return end
	if diceRoll               then return end

	local K     = Config.keys.move
	local moved = false
	local newX  = player.grid_x / 32
	local newY  = player.grid_y / 32

	if key == K.up and testMap(0, -1) then
		player.grid_y = player.grid_y - 32
		newY = newY - 1
		moved = true
	elseif key == K.down and testMap(0, 1) then
		player.grid_y = player.grid_y + 32
		newY = newY + 1
		moved = true
	elseif key == K.left and testMap(-1, 0) then
		player.grid_x = player.grid_x - 32
		newX = newX - 1
		moved = true
	elseif key == K.right and testMap(1, 0) then
		player.grid_x = player.grid_x + 32
		newX = newX + 1
		moved = true
	end

	if moved then
		player.movePoints = player.movePoints + 1
		fog_reveal(newX, newY)
		handleTile(newX, newY)
	end
end