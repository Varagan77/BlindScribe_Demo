local Cfg = require("config.settings")

function grid_load()
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

	for y = 1, #activeMap do
		for x = 1, #activeMap[y] do
			local v      = activeMap[y][x]
			local offset = (ts - 1) / 2

			if v == 1 then
				love.graphics.setColor(1, 1, 1)
				love.graphics.rectangle("line", x * ts, y * ts, ts, ts)
			elseif v == 0 then
				love.graphics.setColor(0.5, 0.5, 0.5)
				love.graphics.rectangle("fill", x * ts + offset, y * ts + offset, 1, 1)
			elseif v == 2 then
				love.graphics.setColor(0, 1, 0)
				love.graphics.rectangle("fill", x * ts, y * ts, ts, ts)
			elseif v == 3 then
				love.graphics.setColor(1, 0, 0)
				love.graphics.rectangle("fill", x * ts, y * ts, ts, ts)
			elseif v == 4 then
				love.graphics.setColor(0, 0, 1)
				love.graphics.rectangle("fill", x * ts, y * ts, ts, ts)
			elseif v == 5 then
				love.graphics.setColor(1, 0.5, 0)
				love.graphics.rectangle("fill", x * ts, y * ts, ts, ts)
			elseif v == 6 then
				love.graphics.setColor(0.5, 1, 1)
				love.graphics.rectangle("fill", x * ts, y * ts, ts, ts)
			elseif v == 7 then
				love.graphics.setColor(1, 1, 0)
				love.graphics.rectangle("fill", x * ts, y * ts, ts, ts)
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

function gridReady()
	return debugDone
end
