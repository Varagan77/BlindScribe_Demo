-- ============================================================================
-- dungeon.lua
-- ============================================================================
-- PURPOSE:
-- This file represents the LIVE dungeon during gameplay.
--
-- It is responsible for:
-- - drawing the map
-- - animating generation (debug carving)
-- - checking collisions (walkable tiles)
--
-- IMPORTANT:
-- This file does NOT generate the dungeon.
-- It only RECEIVES a generated dungeon.
-- ============================================================================

local dungeon = {}

local tileset
local quads = {}

local map
local carveLog

local debugMap
local debugStep
local debugTimer
local debugSpeed
local debugDone

-- ============================================================================
-- LOAD DUNGEON DATA
-- ============================================================================
function dungeon.load(data)

	map      = data.map
	carveLog = data.carveLog

	local MC = Config.map

	-- Load tile sprite sheet
	tileset = love.graphics.newImage(Config.map.spriteSheet)

	debugSpeed = MC.debugSpeed

	-- Build tile quads (each tile is a sprite inside the sheet)
	for i = 0, MC.tiles.gold do
		quads[i] = love.graphics.newQuad(
			i * MC.tileSize,
			0,
			MC.tileSize,
			MC.tileSize,
			tileset:getDimensions()
		)
	end

	-- Create debug map (starts fully as walls)
	debugMap = {}
	for y = 1, #map do
		debugMap[y] = {}
		for x = 1, #map[y] do
			debugMap[y][x] = MC.tiles.wall
		end
	end

	debugStep  = 0
	debugTimer = 0
	debugDone  = false
end

-- ============================================================================
-- UPDATE (DEBUG CARVE ANIMATION)
-- ============================================================================
function dungeon.update(dt)

	if debugDone then return end

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

-- ============================================================================
-- DRAW DUNGEON
-- ============================================================================
function dungeon.draw()

	local activeMap = debugDone and map or debugMap
	local tileSize = Config.map.tileSize

	for y = 1, #activeMap do
		for x = 1, #activeMap[y] do

			local v = activeMap[y][x]

			if quads[v] then
				love.graphics.setColor(1, 1, 1)
				love.graphics.draw(
					tileset,
					quads[v],
					x * tileSize,
					y * tileSize
				)
			end
		end
	end
end

-- ============================================================================
-- COLLISION CHECK
-- ============================================================================
function dungeon.isWalkable(x, y)

	local T = Config.map.tiles

	if not map[y] or not map[y][x] then
		return false
	end

	if map[y][x] == T.wall then
		return false
	end

	return true
end

-- ============================================================================
-- READY CHECK
-- ============================================================================
function dungeon.ready()
	return debugDone
end

return dungeon