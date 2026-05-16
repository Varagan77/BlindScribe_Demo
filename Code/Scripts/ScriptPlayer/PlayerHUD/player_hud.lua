local HUD = {}

local L = Config.hud.player or {}
local C = Config.colours.playerHud or {}

local function setC(c,a)
	if not c then return end
	love.graphics.setColor(c[1] or 1,c[2] or 1,c[3] or 1,a or 1)
end

function hud_draw()
	local sw,sh = love.graphics.getWidth(), love.graphics.getHeight()

	setC(C.bg or {0,0,0})
	love.graphics.rectangle("fill",0,0,sw,sh)

	if not player then return end

	setC(C.panel)
	love.graphics.rectangle("fill",10,10,200,40)

	local hp = player.hp or 0
	local maxHp = L.maxHp or 10

	local pct = math.max(0,hp/maxHp)

	setC(C.hpBg)
	love.graphics.rectangle("fill",20,25,160,10)

	setC(C.hpFill)
	love.graphics.rectangle("fill",20,25,160*pct,10)

	setC(C.text)
	love.graphics.print(hp.." / "..maxHp,25,25)

	if gameState == "win" then
		setC({0,0,0},0.6)
		love.graphics.rectangle("fill",0,0,sw,sh)
		setC(C.accent)
		love.graphics.printf("YOU WIN",0,sh/2,sw,"center")

	elseif gameState == "lose" then
		setC({0,0,0},0.6)
		love.graphics.rectangle("fill",0,0,sw,sh)
		setC(C.danger)
		love.graphics.printf("YOU DIED",0,sh/2,sw,"center")
	end

	love.graphics.setColor(1,1,1)
end

return HUD