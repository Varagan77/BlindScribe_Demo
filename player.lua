function player_load()
    player = {
        grid_x = spawnX * 32,
        grid_y = spawnY * 32,
        act_x  = spawnX * 32,
        act_y  = spawnY * 32,
        speed  = 10,

        -- stats
        hp          = 10,
        gold        = 0,
        damageTaken = 0,
        shopVisited = false,
        portalUsed  = false,
    }

    diceEvent = nil  -- {isGold, roll, timer}
end


function player_update(dt)
    player.act_y = player.act_y - ((player.act_y - player.grid_y) * player.speed * dt)
    player.act_x = player.act_x - ((player.act_x - player.grid_x) * player.speed * dt)

    if diceEvent then
        diceEvent.timer = diceEvent.timer - dt
        if diceEvent.timer <= 0 then diceEvent = nil end
    end
end


local function drawRay()
    local cx = player.grid_x / 32
    local cy = player.grid_y / 32
    local dot = 5          -- dot radius
    local half = 16        -- half a tile (centres the dot)

    local neighbours = {
        {cx,     cy - 1},  -- up
        {cx,     cy + 1},  -- down
        {cx - 1, cy    },  -- left
        {cx + 1, cy    },  -- right
    }

    love.graphics.setColor(0, 1, 0, 0.85)
    for _, n in ipairs(neighbours) do
        local nx, ny = n[1], n[2]
        if map[ny] and map[ny][nx] and map[ny][nx] ~= 1 then
            love.graphics.circle("fill",
                nx * 32 + half,
                ny * 32 + half,
                dot)
        end
    end
end


function player_draw()
    if not gridReady() then return end

    -- ray dots drawn under the player
    drawRay()

    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle("fill", player.act_x, player.act_y, 32, 32)

    -- dice popup floats above the player
    if diceEvent then
        love.graphics.setFont(love.graphics.newFont(14))
        if diceEvent.isGold then
            love.graphics.setColor(1, 1, 0)
            love.graphics.print("COIN  +" .. diceEvent.roll .. "g", player.act_x - 8, player.act_y - 48)
        else
            love.graphics.setColor(1, 0.2, 0.2)
            love.graphics.print("SWORD -" .. diceEvent.roll .. "hp", player.act_x - 8, player.act_y - 48)
        end
    end

    love.graphics.setColor(1, 1, 1)
end


local function handleTile(tileX, tileY)
    local tile = map[tileY][tileX]

    if tile == 7 then                                   -- GOLD
        local roll = love.math.random(1, 6)
        player.gold = player.gold + roll
        map[tileY][tileX] = 0
        diceEvent = {isGold = true, roll = roll, timer = 1.8}

    elseif tile == 3 then                               -- ENEMY
        local roll = love.math.random(1, 6)
        player.hp          = player.hp - roll
        player.damageTaken = player.damageTaken + roll
        map[tileY][tileX] = 0                          -- monster slain
        diceEvent = {isGold = false, roll = roll, timer = 1.8}

    elseif tile == 2 then                               -- SHOP
        player.shopVisited = true

    elseif tile == 4 and not player.portalUsed then     -- PORTAL IN
        player.portalUsed = true
        for y = 1, #map do
            for x = 1, #map[y] do
                if map[y][x] == 5 then
                    player.grid_x = x * 32
                    player.grid_y = y * 32
                    return
                end
            end
        end

    elseif tile == 6 then                               -- EXIT
        gameState = "win"
    end
end


function player_keypressed(key)
    if not gridReady()    then return end
    if gameState == "win" then return end

    local moved = false
    local newX  = player.grid_x / 32
    local newY  = player.grid_y / 32

    if key == "up" and testMap(0, -1) then
        player.grid_y = player.grid_y - 32
        newY  = newY - 1
        moved = true
    elseif key == "down" and testMap(0, 1) then
        player.grid_y = player.grid_y + 32
        newY  = newY + 1
        moved = true
    elseif key == "left" and testMap(-1, 0) then
        player.grid_x = player.grid_x - 32
        newX  = newX - 1
        moved = true
    elseif key == "right" and testMap(1, 0) then
        player.grid_x = player.grid_x + 32
        newX  = newX + 1
        moved = true
    end

    if moved then handleTile(newX, newY) end
end