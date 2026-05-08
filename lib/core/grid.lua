local tileset
local quads = {}

function grid_load(seed)
	local mapModule = require("lib.states.map")

	worldSeed = seed or os.time()
	love.math.setRandomSeed(worldSeed)

	map, spawnX, spawnY, carveLog = mapModule.generate(15, 15)

	-- LOAD TILESET
	tileset = love.graphics.newImage("assets/tiles.png")

	-- CREATE QUADS
	for i = 0, 7 do
		quads[i] = love.graphics.newQuad(
			i * 32,
			0,
			32,
			32,
			tileset:getDimensions()
		)
	end

	debugMap = {}

	for y = 1, #map do
		debugMap[y] = {}

		for x = 1, #map[y] do
			debugMap[y][x] = 1
		end
	end

	debugStep = 0
	debugTimer = 0
	debugSpeed = 0.04
	debugDone = false
end


function grid_update(dt)
	if not debugDone then
		debugTimer = debugTimer + dt

		while debugTimer >= debugSpeed and debugStep < #carveLog do
			debugTimer = debugTimer - debugSpeed
			debugStep = debugStep + 1

			local step = carveLog[debugStep]

			debugMap[step.y][step.x] = step.v
		end

		if debugStep >= #carveLog then
			debugDone = true
		end
	end
end


function grid_draw()
	local activeMap = debugDone and map or debugMap

	for y = 1, #activeMap do
		for x = 1, #activeMap[y] do
			local v = activeMap[y][x]

			love.graphics.setColor(1, 1, 1)

			if quads[v] then
				love.graphics.draw(
					tileset,
					quads[v],
					x * 32,
					y * 32
				)
			end
		end
	end

	if not debugDone then
		love.graphics.setColor(1, 1, 1, 0.7)
		love.graphics.setFont(love.graphics.newFont(12))

		love.graphics.print(
			"Generating... " .. debugStep .. "/" .. #carveLog,
			8,
			8
		)
	end

	love.graphics.setColor(1, 1, 1)
end


-- tile values
-- 0: empty tile
-- 1: wall
-- 2: shop
-- 3: enemy
-- 4: portal in
-- 5: portal out
-- 6: exit
-- 7: gold


function testMap(x, y)
	local newX = (player.grid_x / 32) + x
	local newY = (player.grid_y / 32) + y

	if not map[newY] or not map[newY][newX] then
		return false
	end

	if map[newY][newX] == 1 then
		return false
	end

	return true
end


function gridReady()
	return debugDone
end