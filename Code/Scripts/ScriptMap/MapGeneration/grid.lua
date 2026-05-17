local tileset
local quads = {}
local Sprites = require("Code.Scripts.ScriptUtil.sprites")

function grid_load(seed)
	local mapModule = require("Code.Scripts.ScriptMap.MapGeneration.map")
	local MC = Config.map

	worldSeed = seed or os.time()
	love.math.setRandomSeed(worldSeed)

	map, spawnX, spawnY, carveLog, exitX, exitY = mapModule.generate(MC.cols, MC.rows)

	-- ── BFS: find shortest walkable path from spawn → exit ──────────────────
	local function bfsDistance(sx, sy, tx, ty)
		if sx == tx and sy == ty then return 0 end
		local T = MC.tiles
		local visited = {}
		local queue   = {{x=sx, y=sy, d=0}}
		local head    = 1
		visited[sy * 1000 + sx] = true
		local dirs = {{0,-1},{0,1},{-1,0},{1,0}}
		while head <= #queue do
			local cur = queue[head]; head = head + 1
			for _, dir in ipairs(dirs) do
				local nx, ny = cur.x + dir[1], cur.y + dir[2]
				local key = ny * 1000 + nx
				if map[ny] and map[ny][nx] ~= nil
				   and map[ny][nx] ~= T.wall
				   and not visited[key] then
					local nd = cur.d + 1
					if nx == tx and ny == ty then return nd end
					visited[key] = true
					queue[#queue+1] = {x=nx, y=ny, d=nd}
				end
			end
		end
		return 999   -- fallback (perfect maze → never reached)
	end

	-- ── Count loot tiles to compute exploration bonus ────────────────────────
	local function countLootBonus()
		local T  = MC.tiles
		local PC = Config.player
		local bonus = 0
		for y = 1, #map do
			for x = 1, #map[y] do
				local v = map[y][x]
				if     v == T.shop then bonus = bonus + PC.lootBonusShop
				elseif v == T.gold then bonus = bonus + PC.lootBonusGold
				end
			end
		end
		return bonus
	end

	local bfsMin    = bfsDistance(spawnX, spawnY, exitX, exitY)
	local lootBonus = countLootBonus()
	local mult      = Config.player.stepMultiplier or 2.5

	-- floor(BFS × mult) + loot bonus, clamped to [BFS+5 … BFS×4]
	stepBudget = math.floor(bfsMin * mult) + lootBonus
	stepBudget = math.max(bfsMin + 5, math.min(bfsMin * 4, stepBudget))
	stepBudget = math.max(1, stepBudget)

	tileset = love.graphics.newImage("Art/SpriteSheet/tiles.png")

	for i = 0, MC.tiles.gold do   
		quads[i] = love.graphics.newQuad(
			i * MC.tileSize,
			0,
			MC.tileSize,
			MC.tileSize,
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

	debugStep  = 0
	debugTimer = 0
	debugSpeed = MC.debugSpeed
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

-- Tile ID → sprite key mapping
local tileToSprite = {
    [0] = "floor",
    [1] = "wall",
    [2] = "shop",
    [3] = "enemy",
    [4] = "portal",
    [6] = "exit",
    [7] = "gold",
}

function grid_draw()
    local activeMap = debugDone and map or debugMap

    for y = 1, #activeMap do
        for x = 1, #activeMap[y] do
            local v       = activeMap[y][x]
            local sprKey  = tileToSprite[v]
            local px2     = x * 32
            local py2     = y * 32

            love.graphics.setColor(1, 1, 1)
            if sprKey then
                -- Use Sprites system (individual file or spritesheet fallback)
                Sprites.draw(sprKey, px2, py2)
            elseif quads[v] then
                -- Last resort: raw quad from spritesheet
                love.graphics.draw(tileset, quads[v], px2, py2)
            end
        end
    end

    love.graphics.setColor(1, 1, 1)
end

function grid_draw_hud()
	-- drawn in screen space (after camera_detach)
	if not debugDone then
		love.graphics.setColor(1, 1, 1, 0.9)
		love.graphics.setFont(love.graphics.newFont(Config.fonts.debugInfo))
		love.graphics.print("Generating... " .. debugStep .. "/" .. #carveLog, 8, 8)
		love.graphics.setColor(1, 1, 1)
	end
end

function testMap(dx, dy, playerRef)
	local p = playerRef or player
	if not p then return false end
	local newX = (p.grid_x / 32) + dx
	local newY = (p.grid_y / 32) + dy
	if not map[newY] or not map[newY][newX] then return false end
	if map[newY][newX] == Config.map.tiles.wall then return false end
	return true
end

function gridReady()
	return debugDone
end

-- Returns tile ID at map col/row, or nil if out of bounds
function grid_getTile(col, row)
	local activeMap = debugDone and map or debugMap
	if not activeMap then return nil end
	if not activeMap[row] then return nil end
	return activeMap[row][col]
end
