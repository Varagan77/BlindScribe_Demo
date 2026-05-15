local playerSprite
local playerQuad

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
	playerSprite = love.graphics.newImage("Art/SpriteSheet/tiles.png")
	playerQuad   = love.graphics.newQuad(
		AQ.srcX, AQ.srcY,
		AQ.w,    AQ.h,
		playerSprite:getDimensions()
	)

	playerUI_load()
end


function player_update(dt)
	if not player then return end

	player.act_y = player.act_y - ((player.act_y - player.grid_y) * player.speed * dt)
	player.act_x = player.act_x - ((player.act_x - player.grid_x) * player.speed * dt)

	playerUI_update(dt)
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
		if DM then dm_onPawnMove() end
	end
end