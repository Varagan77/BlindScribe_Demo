local Dice      = require("Code.Scripts.ScriptStates.ScriptDice.diceEvent")
local Encounter = require("Code.Scripts.ScriptPlayer.PlayerEncounter.playerEncounterEvent")
local TileSys   = require("Code.Managers.TileManager.tileSys")
local Sprites   = require("Code.Scripts.ScriptUtil.sprites")

-- 'player' is intentionally a global so grid.lua, hud, camera etc. can all read it

function player_load()
	local PC = Config.player

	player = {
		grid_x = spawnX * 32,
		grid_y = spawnY * 32,
		act_x  = spawnX * 32,
		act_y  = spawnY * 32,
		speed  = PC.speed,

		hp = PC.hp,
		gold = PC.gold,
		damageTaken = 0,
		movePoints = 0,
		stepsLeft = stepBudget or 60,   -- dungeon feeds on each step taken
		shopVisited = false,
	}

	Dice.load(Config, {})
end

function player_update(dt)
	player.act_x = player.act_x + (player.grid_x - player.act_x) * player.speed * dt
	player.act_y = player.act_y + (player.grid_y - player.act_y) * player.speed * dt

	if Dice.isActive() or Encounter.isActive() then return end

	if player.hp <= 0 and gameState == "newGame" then
		gameState = "lose"
	end
end

function player_draw()
	love.graphics.setColor(1,1,1)
	Sprites.draw("player", player.act_x, player.act_y)
end

function player_keypressed(key)
	if gameState ~= "newGame" then return end

	local K = Config.keys.move

	local x = math.floor(player.grid_x / 32)
	local y = math.floor(player.grid_y / 32)

	if key == K.up then y = y - 1
	elseif key == K.down then y = y + 1
	elseif key == K.left then x = x - 1
	elseif key == K.right then x = x + 1
	else return end

	if testMap(x - math.floor(player.grid_x/32), y - math.floor(player.grid_y/32)) then
		player.grid_x = x * 32
		player.grid_y = y * 32

		player.movePoints = player.movePoints + 1
		player.stepsLeft  = player.stepsLeft  - 1
		fog_update(x,y)

		local tile = map[y][x]
		local result = TileSys.handleStep(tile,x,y,{player=player,map=map})

		if result then
			Encounter.start(result)
		end

		-- Dungeon consumed the last step — soul devoured
		if player.stepsLeft <= 0 and gameState == "newGame" then
			gameState = "lose"
		end
	end
end

return player