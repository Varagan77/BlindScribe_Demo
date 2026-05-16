local Dice = require("Code.Scripts.ScriptStates.ScriptDice.diceEvent")
local TileSys = require("Code.Managers.TileManager.tileSys")

local Encounter = {}

local active = nil
local shopState = nil

function Encounter.start(kind)
	active = { kind = kind }
end

function Encounter.isActive()
	return active ~= nil
end

function Encounter.draw()
	if not active then return end

	local sw, sh = love.graphics.getWidth(), love.graphics.getHeight()

	love.graphics.setColor(0,0,0,0.6)
	love.graphics.rectangle("fill",0,0,sw,sh)

	love.graphics.setColor(1,1,1)

	if active.kind == "enemy" then
		love.graphics.printf("Enemy!",0,sh/2,sw,"center")

	elseif active.kind == "gold" then
		love.graphics.printf("Gold found!",0,sh/2,sw,"center")

	elseif active.kind == "shop" then
		love.graphics.printf("Shop appears...",0,sh/2-80,sw,"center")
		love.graphics.printf("1 Spritus  2 Kinesis  3 Wrath  4 Leave",0,sh/2,sw,"center")
	end
end

function Encounter.keypressed(key)
	if not active then return end

	local player = player
	local map = map

	if active.kind ~= "shop" then
		if key == "space" then
			local roll = love.math.random(1,6)

			TileSys.resolveEncounter(active.kind, roll, player)
			Dice.startRoll(active.kind == "gold", roll)

			active = nil
		end
		return
	end

	if key == "4" then
		active = nil
	end
end

return Encounter