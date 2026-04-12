local M = {}

local WALL = 1
local EMPTY = 0

local function shuffle(t) 
	for i = #t, 2, -1 do
		local j = love.math.random(i)
		t[i], t[j] = t[j], t[i]
	end
end


local function carve(map, x, y, log) 
	local dirs = { {0, -2}, {0, 2}, {-2, 0}, {2, 0} }
	shuffle(dirs)
	for _, d in ipairs(dirs) do
		local nx, ny = x + d[1], y + d[2]
		if map[ny] and map[ny][nx] == WALL then
			local mx, my = y + d[2] / 2, x + d[1] / 2
			map[my][mx] = EMPTY
			map[ny][nx] = EMPTY
			log[#log + 1] = {x = mx, y = my, v = EMPTY}
			log[#log + 1] = {x = nx, y = ny, v = EMPTY}
			carve(map, nx, ny, log)
		end
	end
end


local function carveRoom(map, cx, cy, size, w, h, log) 
	local half = math.floor(size / 2)
	for ry = cy - half, cy + half do
		for rx = cx - half, cx + half do
			if ry >= 2 and ry <= h - 1 and rx >= 2 and rx <= w - 1 then
				if map[ry][rx] == WALL then
					map[ry][rx] = EMPTY
					log[#log + 1] = {x = rx, y = ry, v = EMPTY}
				end
			end
		end
	end
end


local function buildPool(map, w, h) 
	local pool = {}
	for y = 2, h - 1 do
		for x = 2, w - 1 do
			if map[y][x] == EMPTY then
				pool[#pool + 1] = {x = x, y = y}
			end
		end
	end
	shuffle(pool)
	return pool
end


local function pop(pool) 
	assert(#pool > 0, "map.lua: ERROR: SMALL ROOM INCREASE SIZE")
	local t = pool[#pool]
	pool[#pool] = nil
	return t.x, t.y
end


function M.generate(width, height)
	if width % 2 == 0 then width = width - 1 end 
	if height % 2 == 0 then height = height - 1 end

	
	local map = {}
	for y = 1, height do
		map[y] = {}
		for x = 1, width do
			map[y][x] = WALL
		end
	end

	
	local log = {}
	map[2][2] = EMPTY
	log[#log + 1] = {x = 2, y = 2, v = EMPTY}
	carve(map, 2, 2, log)

	
	for i = 1, love.math.random(3, 6) do
		local rx = love.math.random(3, width - 3)
		local ry = love.math.random(3, height - 3)
		carveRoom(map, rx, ry, love.math.random(2, 3), width, height, log)
	end

	
	local pool = buildPool(map, width, height)

	
	local px, py = pop(pool)

	local ex, ey = pop(pool) 
	map[ey][ex] = 6
	log[#log + 1] = {x = ex, y = ey, v = 6}

	local p1x, p1y = pop(pool) 
	map[p1y][p1x] = 4
	log[#log + 1] = {x = p1x, y = p1y, v = 4}

	local p2x, p2y = pop(pool) 
	map[p2y][p2x] = 5
	log[#log + 1] = {x = p2x, y = p2y, v = 5}

	for i = 1, 2 do 
		local sx, sy = pop(pool)
		map[sy][sx] = 2
		log[#log + 1] = {x = sx, y = sy, v = 2}
	end

	local enemyCount = math.min(love.math.random(3, 8), #pool)
	for i = 1, enemyCount do 
		local x, y = pop(pool)
		map[y][x] = 3
		log[#log + 1] = {x = x, y = y, v = 3}
	end

	local goldCount = math.min(love.math.random(3, 8), #pool)
	for i = 1, goldCount do 
		local x, y = pop(pool)
		map[y][x] = 7
		log[#log + 1] = {x = x, y = y, v = 7}
	end

	return map, px, py, log
end

return M

-- tile val
-- 0: empty
-- 1: wall
-- 2: shop
-- 3: enemy
-- 4: portal in
-- 5: portal out
-- 6: exit
-- 7: gold