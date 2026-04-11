function player_load()
	player = {
		grid_x = spawnX * 32,
		grid_y = spawnY * 32,
		act_x = spawnX * 32,
		act_y = spawnY * 32,
		speed = 10
	}
end

function player_update(dt)
	player.act_y = player.act_y - ((player.act_y - player.grid_y) * player.speed * dt)
	player.act_x = player.act_x - ((player.act_x - player.grid_x) * player.speed * dt)
end

function player_draw()
	love.graphics.rectangle("fill", player.act_x, player.act_y, 32, 32)
end

function player_keypressed(key) --testmap from grid, collison working!
	if key == "up" then
		if testMap(0, -1) then
			player.grid_y = player.grid_y - 32
		end
	elseif key == "down" then
		if testMap(0, 1) then
			player.grid_y = player.grid_y + 32
		end
	elseif key == "left" then
		if testMap(-1, 0) then
			player.grid_x = player.grid_x - 32
		end
	elseif key == "right" then
		if testMap(1, 0) then
			player.grid_x = player.grid_x + 32
		end
	end
end