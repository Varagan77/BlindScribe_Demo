local M = {}

local WALL = 1
local EMPTY = 0

local function shuffle(dirs)
    for i = #dirs, 2, -1 do
        local j = love.math.random(i)
        dirs[i], dirs[j] = dirs[j], dirs[i]
    end
end

-- recursive backtracking
local function carve(map, x, y)
    local dirs = {
        {0, -2},
        {0, 2},
        {-2, 0},
        {2, 0}
    }

    shuffle(dirs)

    for _, d in ipairs(dirs) do
        local dx, dy = d[1], d[2]
        local nx, ny = x + dx, y + dy

        if map[ny] and map[ny][nx] == WALL then
            map[y + dy/2][x + dx/2] = EMPTY
            map[ny][nx] = EMPTY
            carve(map, nx, ny)
        end
    end
end

local function createMaze(width, height)
    local map = {}

    -- fill with walls
    for y = 1, height do
        map[y] = {}
        for x = 1, width do
            map[y][x] = WALL
        end
    end

    
    map[2][2] = EMPTY
    carve(map, 2, 2)

    return map
end

local function getEmpty(map)
    while true do
        local x = love.math.random(2, #map[1]-1)
        local y = love.math.random(2, #map-1)

        if map[y][x] == EMPTY then
            return x, y
        end
    end
end

function M.generate(width, height)
    
    if width % 2 == 0 then width = width - 1 end
    if height % 2 == 0 then height = height - 1 end

    local map = createMaze(width, height)

    -- PLAYER
    local px, py = getEmpty(map)

    -- EXIT
    local ex, ey = getEmpty(map)
    map[ey][ex] = 6

    -- PORTALS
    local p1x, p1y = getEmpty(map)
    map[p1y][p1x] = 4

    local p2x, p2y = getEmpty(map)
    map[p2y][p2x] = 5

    -- SHOPS (2)
    for i = 1, 2 do
        local sx, sy = getEmpty(map)
        map[sy][sx] = 2
    end

    -- ENEMIES + GOLD (<5%)
    local total = width * height
    local max = math.max(1, math.floor(total * 0.05))

    for i = 1, love.math.random(1, max) do
        local x, y = getEmpty(map)
        map[y][x] = 3
    end

    for i = 1, love.math.random(1, max) do
        local x, y = getEmpty(map)
        map[y][x] = 7
    end

    return map, px, py
end

return M