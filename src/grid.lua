local Cfg = require("config.settings")

local tileImage = nil
local tileQuads = {}
local SHEET_TS  = 16   -- source tile size in the PNG
local SCALE     = Cfg.TILE_SIZE / SHEET_TS  -- e.g. 32/16 = 2

local function makeQuad(col, row)
	return love.graphics.newQuad(
		col * SHEET_TS,
		row * SHEET_TS,
		SHEET_TS, SHEET_TS,
		tileImage:getDimensions()
	)
end

function grid_load()
	-- Load tileset once
	if not tileImage then
		tileImage = love.graphics.newImage("assets/sprites/dungeon_.png")
		tileImage:setFilter("nearest", "nearest")  -- keeps pixels crisp when scaled up

		tileQuads = {
			[0] = makeQuad(1,  1),   -- floor
			[1] = makeQuad( 0,  4),   -- wall
			[2] = makeQuad(11,  7),   -- shop
			[3] = makeQuad(11,  4),   -- enemy
			[4] = makeQuad( 3, 11),   -- portal in
			[5] = makeQuad( 2, 11),   -- portal out
			[6] = makeQuad(11, 10),   -- exit
			[7] = makeQuad(13, 11),   -- gold
		}
	end

	local mapModule = require("src.map")
	map, spawnX, spawnY, carveLog = mapModule.generate(Cfg.MAP_WIDTH, Cfg.MAP_HEIGHT)

	debugMap = {}
	for y = 1, #map do
		debugMap[y] = {}
		for x = 1, #map[y] do
			debugMap[y][x] = 1
		end
	end

	debugStep  = 0
	debugTimer = 0
	debugSpeed = Cfg.DEBUG_ANIM_SPEED
	debugDone  = false
end

function grid_update(dt)
	if not debugDone then
		debugTimer = debugTimer + dt
		while debugTimer >= debugSpeed and debugStep < #carveLog do
			debugTimer = debugTimer - debugSpeed
			debugStep  = debugStep + 1
			local step = carveLog[debugStep]
			debugMap[step.y][step.x] = step.v
		end
		if debugStep >= #carveLog then
			debugDone = true
		end
	end
end

function grid_draw()
	local ts        = Cfg.TILE_SIZE
	local activeMap = debugDone and map or debugMap

	love.graphics.setColor(1, 1, 1)
	for y = 1, #activeMap do
		for x = 1, #activeMap[y] do
			local v = activeMap[y][x]
			local q = tileQuads[v]
			if q then
				love.graphics.draw(tileImage, q, x * ts, y * ts, 0, SCALE, SCALE)
			end
		end
	end

	if not debugDone then
		love.graphics.setColor(1, 1, 1, 0.7)
		love.graphics.setFont(love.graphics.newFont(12))
		love.graphics.print("Generating... " .. debugStep .. "/" .. #carveLog, 8, 8)
	end

	love.graphics.setColor(1, 1, 1)
end

function testMap(x, y)
	local ts   = Cfg.TILE_SIZE
	local newX = (player.grid_x / ts) + x
	local newY = (player.grid_y / ts) + y

	if not map[newY] or not map[newY][newX] then
		return false
	end

	return map[newY][newX] ~= 1
end

function grid_unload()
	tileImage = nil
	tileQuads = {}
end

function gridReady()
	return debugDone
end