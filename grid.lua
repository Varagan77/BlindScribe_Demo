function grid_load()   
     map = require("map")
end


function grid_update(dt)
if map[(player.grid_y / 32) + y][(player.grid_x / 32) + x] == 1 then
		return false
	end
	return true
end


function grid_draw()
    for y = 1, #map do
        for x = 1, #map[y] do
            local offset = (32 - 1) / 2

            if map[y][x] == 1 then
                love.graphics.setColor(1, 1, 1) -- white (wall)
                love.graphics.rectangle("line", x * 32, y * 32, 32, 32)

            elseif map[y][x] == 0 then
                love.graphics.setColor(0.5, 0.5, 0.5) -- gray (empty)
                love.graphics.rectangle("fill", x * 32 + offset, y * 32 + offset, 1, 1)

            elseif map[y][x] == 2 then
                love.graphics.setColor(0, 1, 0) -- green (shop)
                love.graphics.rectangle("fill" , x * 32, y * 32, 32, 32)

            elseif map[y][x] == 3 then
                love.graphics.setColor(1, 0, 0) -- red (enemy)
                love.graphics.rectangle("fill", x * 32, y * 32, 32, 32)

            elseif map[y][x] == 4 then
                love.graphics.setColor(0, 0, 1) -- blue (portal in)
                love.graphics.rectangle("fill", x * 32, y * 32, 32, 32)

            elseif map[y][x] == 5 then
                love.graphics.setColor(1, 0.5, 0) -- orange (portal out)
                love.graphics.rectangle("fill", x * 32, y * 32, 32, 32)

            elseif map[y][x] == 6 then
                love.graphics.setColor(0.5, 1, 1) -- light blue (exit)
                love.graphics.rectangle("fill", x * 32, y * 32, 32, 32)

            elseif map[y][x] == 7 then
                love.graphics.setColor(1, 1, 0) -- yellow (gold)
                love.graphics.rectangle("fill", x * 32, y * 32, 32, 32)
            end
        end
    end

    love.graphics.setColor(1, 1, 1) -- reset color
end
    -- 1: Wall
        -- 0: Empty Tile
        -- 2: shop tile
        -- 3: enemy tile
        -- 4: portal in
		-- 5: portal out 
		-- 6 exit
        -- 7: gold

function testMap(x, y) --collison testing
	if map[(player.grid_y / 32) + y][(player.grid_x / 32) + x] == 1 then
		return false
	end
	return true
end


     -- PIXEL MATH
                -- Tile size: 32x32
                -- Rectangle size: 1x1
                -- Step 1: Find the difference in size
                --   diff = tileSize - rectSize
                -- Step 2: Divide by 2 to get offset for centering
                --   offset = diff / 2
                -- Step 3: Add offset to tile position
                --   drawX = tileX + offset
                --   drawY = tileY + offset
                -- Step 4: Draw rectangle at centered position