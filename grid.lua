function grid_load()
    local mapModule = require("map")
    map, spawnX, spawnY, carveLog = mapModule.generate(15, 15)

    
    debugMap = {}
    for y = 1, #map do
        debugMap[y] = {}
        for x = 1, #map[y] do
            debugMap[y][x] = 1  
        end
    end

    debugStep    = 0           
    debugTimer   = 0            
    debugSpeed   = 0.04         
    debugDone    = false        
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


local function drawTile(tileMap, y, x)
    local v = tileMap[y][x]
    local offset = (32 - 1) / 2

    if v == 1 then
        love.graphics.setColor(1, 1, 1)
        love.graphics.rectangle("line", x * 32, y * 32, 32, 32)

    elseif v == 0 then
        love.graphics.setColor(0.5, 0.5, 0.5)
        love.graphics.rectangle("fill", x * 32 + offset, y * 32 + offset, 1, 1)

    elseif v == 2 then
        love.graphics.setColor(0, 1, 0)
        love.graphics.rectangle("fill", x * 32, y * 32, 32, 32)

    elseif v == 3 then
        love.graphics.setColor(1, 0, 0)
        love.graphics.rectangle("fill", x * 32, y * 32, 32, 32)

    elseif v == 4 then
        love.graphics.setColor(0, 0, 1)
        love.graphics.rectangle("fill", x * 32, y * 32, 32, 32)

    elseif v == 5 then
        love.graphics.setColor(1, 0.5, 0)
        love.graphics.rectangle("fill", x * 32, y * 32, 32, 32)

    elseif v == 6 then
        love.graphics.setColor(0.5, 1, 1)
        love.graphics.rectangle("fill", x * 32, y * 32, 32, 32)

    elseif v == 7 then
        love.graphics.setColor(1, 1, 0)
        love.graphics.rectangle("fill", x * 32, y * 32, 32, 32)
    end
end


function grid_draw()
    local activeMap = debugDone and map or debugMap

    for y = 1, #activeMap do
        for x = 1, #activeMap[y] do
            drawTile(activeMap, y, x)
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