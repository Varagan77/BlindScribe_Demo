local TileSys = {}

function TileSys.handleStep(tile, x, y, ctx)
	local T = Config.map.tiles

	if tile == T.gold then
		return "gold"

	elseif tile == T.enemy then
		return "enemy"

	elseif tile == T.shop then
		return "shop"

	elseif tile == T.portalIn and not ctx.player.portalUsed then
		ctx.player.portalUsed = true

		for yy = 1, #ctx.map do
			for xx = 1, #ctx.map[yy] do
				if ctx.map[yy][xx] == T.portalOut then
					ctx.player.grid_x = xx * 32
					ctx.player.grid_y = yy * 32
					fog_update(xx, yy)
					return nil
				end
			end
		end

	elseif tile == T.exit then
		gameState = "win"
	end

	return nil
end

function TileSys.resolveEncounter(kind, roll, player)
	if kind == "gold" then
		player.gold = player.gold + roll

	elseif kind == "enemy" then
		player.hp = math.max(0, player.hp - roll)
		player.damageTaken = player.damageTaken + roll
	end
end

function TileSys.applyShop(item, player, map)
	if not item then return end

	local T = Config.map.tiles

	if item.effect == "heal" then
		player.hp = math.min(Config.player.maxHp, player.hp + item.value)

	elseif item.effect == "move" then
		player.movePoints = player.movePoints + item.value

	elseif item.effect == "spawn_enemy" then
		local px = math.floor(player.grid_x / 32)
		local py = math.floor(player.grid_y / 32)

		for dy = -2, 2 do
			for dx = -2, 2 do
				local nx, ny = px + dx, py + dy

				if map[ny] and map[ny][nx] and map[ny][nx] == T.floor then
					map[ny][nx] = T.enemy
					return
				end
			end
		end
	end
end

return TileSys