local DM_HUD = {}

local L = Config.hud.dm
local C = Config.colours.dmHud

DM_HUD.TOP_BAR_H   = L.topBarH
DM_HUD.BOT_BAR_H   = L.botBarH
DM_HUD.RIGHT_COL_W = L.rightColW
DM_HUD.PAD         = Config.hud.pad
DM_HUD.CORNER      = Config.hud.corner

DM_HUD.logMsg   = ""
DM_HUD.logTimer = 0
DM_HUD.LOG_DUR  = Config.hud.logDuration


local function setC(t, a)
	love.graphics.setColor(t[1], t[2], t[3], a or 1)
end

local function panel(x, y, w, h, r, borderCol)
	r = r or DM_HUD.CORNER
	setC(C.panel)
	love.graphics.rectangle("fill", x, y, w, h, r, r)
	setC(borderCol or C.border)
	love.graphics.rectangle("line", x, y, w, h, r, r)
end

local function label(txt, x, y, col)
	setC(col or C.label)
	love.graphics.setFont(love.graphics.newFont(10))
	love.graphics.print(txt, x, y)
end

local function value(txt, x, y, col, size)
	setC(col or C.text)
	love.graphics.setFont(love.graphics.newFont(size or 13))
	love.graphics.print(txt, x, y)
end


function dm_hud_load()
	dm_hud_resize()
end

function dm_hud_resize()
	local sw = love.graphics.getWidth()
	local sh = love.graphics.getHeight()
	local p  = DM_HUD.PAD

	DM_HUD.mapRect = {
		x = p,
		y = DM_HUD.TOP_BAR_H + p,
		w = sw - DM_HUD.RIGHT_COL_W - p * 3,
		h = sh - DM_HUD.TOP_BAR_H - DM_HUD.BOT_BAR_H - p * 3,
	}
end

function dm_hud_log(msg)
	DM_HUD.logMsg   = msg
	DM_HUD.logTimer = DM_HUD.LOG_DUR
end

function dm_hud_update(dt)
	if DM_HUD.logTimer > 0 then
		DM_HUD.logTimer = DM_HUD.logTimer - dt
	end
end

function dm_hud_getMapRect()
	return DM_HUD.mapRect
end


function dm_hud_draw()
	if not DM then return end

	local sw = love.graphics.getWidth()
	local sh = love.graphics.getHeight()
	local p  = DM_HUD.PAD
	local mr = DM_HUD.mapRect

	setC(C.bg)
	love.graphics.rectangle("fill", 0, 0, sw, DM_HUD.TOP_BAR_H)
	love.graphics.rectangle("fill", sw - DM_HUD.RIGHT_COL_W - p, DM_HUD.TOP_BAR_H, DM_HUD.RIGHT_COL_W + p, sh - DM_HUD.TOP_BAR_H)
	local botH = DM_HUD.BOT_BAR_H + p * 2
	love.graphics.rectangle("fill", 0, sh - botH, sw - DM_HUD.RIGHT_COL_W - p, botH)
	love.graphics.rectangle("fill", 0, DM_HUD.TOP_BAR_H, mr.x, sh - DM_HUD.TOP_BAR_H)

	setC({0.06, 0.05, 0.08})
	love.graphics.rectangle("fill", mr.x, mr.y, mr.w, mr.h)
	setC(C.border)
	love.graphics.rectangle("line", mr.x, mr.y, mr.w, mr.h, 4, 4)

	dm_hud_drawTopBar(sw, sh, p)
	dm_hud_drawRightCol(sw, sh, p)
	dm_hud_drawAbilityBar(sw, sh, p)

	if gameState == "dm_lose" then
		dm_hud_drawLoseScreen(sw, sh)
	end

	love.graphics.setColor(1, 1, 1)
end


function dm_hud_drawTopBar(sw, sh, p)
	local tbH = DM_HUD.TOP_BAR_H
	panel(p, 2, sw - p * 2, tbH - 2, 6)

	local badgeW = 90
	local badgeX = p + 6
	local badgeY = 8
	setC({0.22, 0.10, 0.35})
	love.graphics.rectangle("fill", badgeX, badgeY, badgeW, tbH - 14, 4, 4)
	setC(C.accent)
	love.graphics.rectangle("line", badgeX, badgeY, badgeW, tbH - 14, 4, 4)
	love.graphics.setFont(love.graphics.newFont(12))
	setC(C.title)
	love.graphics.printf("DUNGEON MASTER", badgeX, badgeY + 5, badgeW, "center")

	local essX    = badgeX + badgeW + 14
	local essBarW = L.essBarW
	local essBarH = L.essBarH
	local essBarY = (tbH - essBarH) / 2

	label("ESSENCE", essX, 4)
	setC(C.essBg)
	love.graphics.rectangle("fill", essX, essBarY, essBarW, essBarH, 3, 3)

	local essPct = math.max(0, DM.essence / DM.essenceMax)
	local fillC  = essPct < L.lowEssPct and C.essLow or C.essFill
	if essPct > 0 then
		setC(fillC)
		love.graphics.rectangle("fill", essX, essBarY, essBarW * essPct, essBarH, 3, 3)
	end
	setC(C.border)
	love.graphics.rectangle("line", essX, essBarY, essBarW, essBarH, 3, 3)
	love.graphics.setFont(love.graphics.newFont(10))
	setC(C.text)
	love.graphics.printf(math.floor(DM.essence) .. " / " .. DM.essenceMax, essX, essBarY + 1, essBarW, "center")

	if essPct < L.lowEssPct then
		local pulse = math.abs(math.sin(love.timer.getTime() * 4))
		setC(C.danger, pulse * 0.6)
		love.graphics.rectangle("fill", essX, essBarY, essBarW, essBarH, 3, 3)
		love.graphics.setFont(love.graphics.newFont(10))
		setC(C.danger, pulse)
		love.graphics.printf("LOW", essX, essBarY + 1, essBarW, "center")
	end

	if DM_HUD.logTimer > 0 then
		local a = math.min(DM_HUD.logTimer, 1)
		setC(C.accent, a)
		love.graphics.setFont(love.graphics.newFont(13))
		love.graphics.printf(DM_HUD.logMsg, 0, 11, sw, "center")
	end

	local btnW, btnH = 80, 22
	local btnX = sw - p - btnW
	local btnY = (tbH - btnH) / 2
	setC(C.panel)
	love.graphics.rectangle("fill", btnX, btnY, btnW, btnH, 4, 4)
	setC(C.border)
	love.graphics.rectangle("line", btnX, btnY, btnW, btnH, 4, 4)
	setC(C.text)
	love.graphics.setFont(love.graphics.newFont(11))
	love.graphics.printf("MENU  [ESC]", btnX, btnY + 5, btnW, "center")
end


function dm_hud_drawRightCol(sw, sh, p)
	local rcX = sw - DM_HUD.RIGHT_COL_W - p
	local rcY = DM_HUD.TOP_BAR_H + p
	local rcW = DM_HUD.RIGHT_COL_W
	local rcH = sh - DM_HUD.TOP_BAR_H - DM_HUD.BOT_BAR_H - p * 3

	panel(rcX, rcY, rcW, rcH)
	label("PAWNS", rcX + 8, rcY + 6, C.accent)

	local py  = rcY + 24
	local px  = rcX + 8
	local pw  = rcW - 16

	local PAWN_COLOURS = Config.dm.pawnColours
	local pawns = DM.pawns or {}
	if #pawns == 0 and player then
		pawns = {{
			name   = "Player",
			hp     = player.hp,
			gold   = player.gold,
			moves  = player.movePoints,
			grid_x = player.grid_x,
			grid_y = player.grid_y,
			colour = PAWN_COLOURS[1],
		}}
	end

	for i, pawn in ipairs(pawns) do
		local pc    = pawn.colour or PAWN_COLOURS[((i - 1) % #PAWN_COLOURS) + 1]
		local cardH = 66
		local cy    = py

		setC({pc[1] * 0.15, pc[2] * 0.15, pc[3] * 0.15, 1})
		love.graphics.rectangle("fill", px - 2, cy, pw + 4, cardH, 4, 4)
		setC(pc, 0.6)
		love.graphics.rectangle("line", px - 2, cy, pw + 4, cardH, 4, 4)
		setC(pc)
		love.graphics.circle("fill", px + 8, cy + 12, 5)
		setC(C.text)
		love.graphics.setFont(love.graphics.newFont(12))
		love.graphics.print(pawn.name or ("Pawn " .. i), px + 18, cy + 6)

		local hpBarW  = pw - 4
		local hpBarH  = 9
		local hpBarY  = cy + 23
		local maxHp   = Config.player.maxHp
		local hpPct   = math.max(0, (pawn.hp or 0) / maxHp)
		local hpFillC = hpPct > 0.35 and {0.20, 0.75, 0.35} or C.danger

		setC({0.10, 0.10, 0.14})
		love.graphics.rectangle("fill", px, hpBarY, hpBarW, hpBarH, 2, 2)
		if hpPct > 0 then
			setC(hpFillC)
			love.graphics.rectangle("fill", px, hpBarY, hpBarW * hpPct, hpBarH, 2, 2)
		end
		setC(C.border)
		love.graphics.rectangle("line", px, hpBarY, hpBarW, hpBarH, 2, 2)
		love.graphics.setFont(love.graphics.newFont(9))
		setC(C.text)
		love.graphics.printf((pawn.hp or 0) .. " HP", px, hpBarY, hpBarW, "center")

		love.graphics.setFont(love.graphics.newFont(10))
		setC({1.00, 0.85, 0.25})
		love.graphics.print("G " .. (pawn.gold or 0), px, cy + 37)
		setC(C.accent)
		love.graphics.print("M " .. (pawn.moves or pawn.movePoints or 0), px + 36, cy + 37)

		if pawn.grid_x and pawn.grid_y then
			local tx = math.floor(pawn.grid_x / 32)
			local ty = math.floor(pawn.grid_y / 32)
			setC(C.label)
			love.graphics.setFont(love.graphics.newFont(9))
			love.graphics.print("(" .. tx .. "," .. ty .. ")", px, cy + 50)
		end

		if (pawn.hp or 1) <= 0 then
			setC({0, 0, 0}, 0.65)
			love.graphics.rectangle("fill", px - 2, cy, pw + 4, cardH, 4, 4)
			setC(C.danger)
			love.graphics.setFont(love.graphics.newFont(11))
			love.graphics.printf("DEAD", px - 2, cy + cardH / 2 - 7, pw + 4, "center")
		end

		py = py + cardH + 6
		if py + cardH > rcY + rcH - 10 then break end
	end

	local botY = rcY + rcH - 44
	setC(C.border)
	love.graphics.line(rcX + 6, botY, rcX + rcW - 6, botY)
	label("Pawn events", rcX + 8, botY + 4, C.label)
	setC(C.text)
	love.graphics.setFont(love.graphics.newFont(11))
	love.graphics.print("Dmg dealt : "  .. (DM.totalDamageDealt or 0),             rcX + 8, botY + 16)
	love.graphics.print("Ess. earned: " .. math.floor(DM.totalEssEarned or 0), rcX + 8, botY + 30)
end


function dm_hud_drawAbilityBar(sw, sh, p)
	if not DM or not DM.abilities then return end

	local K     = Config.keys.dmAbilities
	local barH  = DM_HUD.BOT_BAR_H
	local barY  = sh - barH - p
	local barW  = sw - DM_HUD.RIGHT_COL_W - p * 4
	local barX  = p

	panel(barX, barY, barW, barH, 6)
	label("ABILITIES", barX + 8, barY + 4, C.accent)

	local n        = #DM.abilities
	local btnW     = math.floor((barW - 16 - (n - 1) * 6) / n)
	local btnH     = barH - 22
	local btnBaseX = barX + 8
	local btnY     = barY + 18

	for i, ab in ipairs(DM.abilities) do
		local bx       = btnBaseX + (i - 1) * (btnW + 6)
		local onCd     = (ab.cooldown or 0) > 0
		local canAfford = DM.essence >= ab.cost
		local ready    = not onCd and canAfford
		local bgC      = ready and C.abilityRdy or (onCd and C.abilityCd or C.abilityBtn)

		setC(bgC)
		love.graphics.rectangle("fill", bx, btnY, btnW, btnH, 4, 4)
		setC(ready and C.accent or C.border, ready and 0.7 or 0.4)
		love.graphics.rectangle("line", bx, btnY, btnW, btnH, 4, 4)

		setC(ready and C.accent or C.label)
		love.graphics.setFont(love.graphics.newFont(9))
		love.graphics.printf("[" .. (K[i] or "?"):upper() .. "]", bx, btnY + 2, btnW, "center")

		setC(ready and C.text or C.label)
		love.graphics.setFont(love.graphics.newFont(11))
		love.graphics.printf(ab.name, bx, btnY + 13, btnW, "center")

		setC(canAfford and C.essFill or C.danger)
		love.graphics.setFont(love.graphics.newFont(9))
		love.graphics.printf(ab.cost .. " ess", bx, btnY + 27, btnW, "center")

		if onCd then
			local cdPct = ab.cooldown / ab.cooldownMax
			setC({0, 0, 0}, 0.55 * cdPct)
			love.graphics.rectangle("fill", bx, btnY, btnW, btnH * cdPct, 4, 4)
			setC(C.warn)
			love.graphics.setFont(love.graphics.newFont(10))
			love.graphics.printf(string.format("%.1fs", ab.cooldown), bx, btnY + btnH / 2 - 6, btnW, "center")
		end

		if DM.selectedAbility == i then
			setC(C.accent, 0.35)
			love.graphics.rectangle("fill", bx, btnY, btnW, btnH, 4, 4)
			setC(C.accent)
			love.graphics.rectangle("line", bx, btnY, btnW, btnH, 4, 4)
		end
	end
end


function dm_hud_drawLoseScreen(sw, sh)
	setC({0, 0, 0}, 0.86)
	love.graphics.rectangle("fill", 0, 0, sw, sh)
	love.graphics.setFont(love.graphics.newFont(30))
	setC(C.danger)
	love.graphics.printf("Your Essence fades...", 0, sh / 2 - 80, sw, "center")
	love.graphics.setFont(love.graphics.newFont(15))
	setC(C.text)
	love.graphics.printf(
		"The dungeon slips beyond your control.\n\n" ..
		"Damage dealt to Pawns : " .. (DM.totalDamageDealt or 0) .. "\n" ..
		"Essence earned        : " .. math.floor(DM.totalEssEarned or 0),
		0, sh / 2 - 10, sw, "center"
	)
	setC(C.label)
	love.graphics.setFont(love.graphics.newFont(13))
	love.graphics.printf("Press ENTER to return to menu", 0, sh / 2 + 100, sw, "center")
end


function dm_hud_keypressed(key)
	if gameState == "dm_lose" and key == "return" then
		gameState     = "menu"
		selectedIndex = 1
	end
end

return DM_HUD