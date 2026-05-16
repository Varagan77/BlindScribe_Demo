local Dice = {}

local Config
local Fonts
local D
local TileSys  -- loaded lazily to avoid circular require

Dice.state = nil

function Dice.load(config, fonts)
	Config = config
	Fonts = {
		f28 = (fonts and fonts.f28) or love.graphics.newFont(28),
		f16 = (fonts and fonts.f16) or love.graphics.newFont(16),
	}
	D = Config.player.dice
	TileSys = TileSys or require("Code.Managers.TileManager.tileSys")
end

function Dice.startRoll(isGold, result)
	Dice.state = {
		isGold = isGold,
		result = result,
		showing = 1,
		elapsed = 0,
		spinTimer = 0,
		angle = 0
	}
end

function Dice.isActive()
	return Dice.state ~= nil
end

function Dice.update(dt)
	local dice = Dice.state
	if not dice then return end

	dice.elapsed = dice.elapsed + dt
	local e = dice.elapsed

	-- end cutscene — apply deferred stat change NOW
	if e >= D.totalTime then
		if TileSys and TileSys.applyPending then
			TileSys.applyPending()
		end
		Dice.state = nil
		return
	end

	-- spinning logic
	if e >= D.spinStart and e < D.spinEnd then
		local progress = (e - D.spinStart) / (D.spinEnd - D.spinStart)
		local interval = D.minInterval + progress * (D.maxInterval - D.minInterval)

		dice.spinTimer = dice.spinTimer + dt
		if dice.spinTimer >= interval then
			dice.spinTimer = 0
			dice.showing = love.math.random(1, 6)
		end
	end
end

function Dice.draw()
	local dice = Dice.state
	if not dice then return end

	local D = Config.player.dice
	local sw = love.graphics.getWidth()
	local sh = love.graphics.getHeight()
	local e  = dice.elapsed

	local cx = sw / 2
	local cy = sh / 2

	-- dark overlay
	local overlayAlpha = math.min(e / 0.8, 1) * 0.75
	love.graphics.setColor(0, 0, 0, overlayAlpha)
	love.graphics.rectangle("fill", 0, 0, sw, sh)

	local cubeAlpha = math.min(e / 0.6, 1)
	if cubeAlpha <= 0 then return end

	-- rotation
	local angle
	if e >= D.spinStart and e < D.spinEnd then
		local progress = (e - D.spinStart) / (D.spinEnd - D.spinStart)
		local spinSpeed = 18 * (1 - progress) + 1
		dice.angle = (dice.angle or 0) + spinSpeed * (1 / 60)
		angle = dice.angle
	else
		angle = dice.angle or 0
	end

	local size = 40
	local isGold = dice.isGold

	-- cube body
	if isGold then
		love.graphics.setColor(1, 0.85, 0, cubeAlpha)
	else
		love.graphics.setColor(0.9, 0.1, 0.1, cubeAlpha)
	end

	love.graphics.rectangle("fill", cx - size, cy - size - 10, size * 2, size * 2)

	-- number display
	local numText
	if e < D.spinStart then
		numText = "?"
	elseif e >= D.spinEnd then
		numText = tostring(dice.result)
	else
		numText = tostring(dice.showing)
	end

	love.graphics.setFont(Fonts.f28)
	love.graphics.setColor(1, 1, 1, cubeAlpha)
	love.graphics.printf(numText, cx - size, cy - size + 10, size * 2, "center")

	-- result text
	if e >= D.spinEnd + 0.5 then
		local alpha = math.min((e - (D.spinEnd + 0.5)) / 0.3, 1)
		love.graphics.setFont(Fonts.f16)

		if isGold then
			love.graphics.setColor(1, 1, 0.4, alpha)
			love.graphics.printf("+" .. dice.result .. " gold", 0, cy + size + 20, sw, "center")
		else
			love.graphics.setColor(1, 0.3, 0.3, alpha)
			love.graphics.printf("-" .. dice.result .. " hp", 0, cy + size + 20, sw, "center")
		end
	end

	love.graphics.setColor(1, 1, 1)
end

return Dice