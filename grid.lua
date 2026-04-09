function grid_load()   
  map = {
		{ 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1 },
		{ 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1 },
		{ 1, 0, 1, 1, 0, 0, 0, 0, 1, 0, 0, 1, 0, 1 },
		{ 1, 1, 1, 1, 0, 0, 0, 0, 1, 0, 0, 1, 0, 1 },
		{ 1, 1, 0, 1, 0, 1, 1, 1, 1, 0, 0, 0, 0, 1 },
		{ 1, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1 },
		{ 1, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1 },
		{ 1, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1 },
		{ 1, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1 },
		{ 1, 0, 0, 1, 0, 0, 0, 0, 1, 1, 1, 1, 0, 1 },
		{ 1, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1 },
		{ 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1 },
		{ 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1 }
	}
end

--MAP will add map mod later...

        -- 1: Wall
        -- 0: Empty Tile
        -- 
        --
        --




function grid_update(dt)
if map[(player.grid_y / 32) + y][(player.grid_x / 32) + x] == 1 then
		return false
	end
	return true
end


function grid_draw()
    for y=1, #map do
		for x=1, #map[y] do
			if map[y][x] == 1 then
				love.graphics.rectangle("line", x * 32, y * 32, 32, 32) 
            elseif map[y][x] == 0 then
                local offset = (32 - 1) / 2
				love.graphics.rectangle("fill", x * 32 + offset, y * 32 + offset, 1, 1) 
                end
			end
		end
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