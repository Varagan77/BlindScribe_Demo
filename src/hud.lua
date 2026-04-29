local Cfg = require("config.settings")

local HUD = {}

HUD.TOP_BAR_H   = 36
HUD.RIGHT_COL_W = 180
HUD.PAD         = 6
HUD.CORNER      = 8
HUD.mapRect     = { x = 0, y = 0, w = 0, h = 0 }
HUD.debugVisible = Cfg.DEBUG_VISIBLE
HUD.logMsg      = ""
HUD.logTimer    = 0

local C = {
	bg        = { 0.05, 0.05, 0.06 },
	panel     = { 0.08, 0.08, 0.10 },
	border    = { 0.25, 0.25, 0.30 },
	text      = { 0.85, 0.85, 0.85 },
	label     = { 0.45, 0.45, 0.55 },
	accent    = { 0.35, 0.85, 0.75 },
	gold      = { 1.00, 0.85, 0.25 },
	danger    = { 1.00, 0.30, 0.30 },
	hp_fill   = { 0.20, 0.75, 0.35 },
	hp_bg     = { 0.15, 0.15, 0.18 },
	debug_hdr = { 0.40, 1.00, 0.85 },
	debug_warn= { 1.00, 0.85, 0.30 },
}

local function setC(t, a)
	love.graphics.setColor(t[1], t[2], t[3], a or 1)
end

local function panel(x, y, w, h, r)
	r = r or HUD.CORNER
	setC(C.panel)
	love.graphics.rectangle("fill", x, y, w, h, r, r)
	setC(C.border)
	love.graphics.rectangle("line", x, y, w, h, r, r)
end

local function label(txt, x, y, col)
	setC(col or C.label)
	love.graphics.setFont(love.graphics.newFont(10))
	love.graphics.print(txt, x, y)
end

local function value(txt, x, y, col)
	setC(col or C.text)
	love.graphics.setFont(love.graphics.newFont(13))
	love.graphics.print(txt, x, y)
end

function hud_load()
	hud_resize()
end

function hud_resize()
	local sw = love.graphics.getWidth()
	local sh = love.graphics.getHeight()
	local p  = HUD.PAD

	HUD.mapRect = {
		x = p,
		y = HUD.TOP_BAR_H + p,
		w = sw - HUD.RIGHT_COL_W - p * 3,
		h = sh - HUD.TOP_BAR_H - p * 2,
	}
end

function hud_log(msg)
	HUD.logMsg   = msg
	HUD.logTimer = Cfg.LOG_DURATION
end

function hud_update(dt)
	if HUD.logTimer > 0 then
		HUD.logTimer = HUD.logTimer - dt
	end
end

function hud_draw()
	local sw = love.graphics.getWidth()
	local sh = love.graphics.getHeight()
	local p  = HUD.PAD
	local mr = HUD.mapRect

	setC(C.bg)
	love.graphics.rectangle("fill", 0, 0, sw, sh)

	setC(C.border)
	love.graphics.rectangle("line", mr.x, mr.y, mr.w, mr.h, 4, 4)

	local tbY = 0
	local tbH = HUD.TOP_BAR_H

	panel(p, tbY + 2, sw - p * 2, tbH - 2, 6)

	local hpX    = p + 8
	local hpBarW = 160
	local hpBarH = 12
	local hpBarY = tbY + (tbH - hpBarH) / 2

	label("HP", hpX, tbY + 4)

	setC(C.hp_bg)
	love.graphics.rectangle("fill", hpX, hpBarY, hpBarW, hpBarH, 3, 3)

	local hpPct = math.max(0, player.hp / Cfg.PLAYER_HP)
	local fillC = hpPct > 0.4 and C.hp_fill or C.danger
	setC(fillC)
	love.graphics.rectangle("fill", hpX, hpBarY, hpBarW * hpPct, hpBarH, 3, 3)

	setC(C.border)
	love.graphics.rectangle("line", hpX, hpBarY, hpBarW, hpBarH, 3, 3)

	setC(C.text)
	love.graphics.setFont(love.graphics.newFont(10))
	love.graphics.printf(player.hp .. " / " .. Cfg.PLAYER_HP, hpX, hpBarY + 1, hpBarW, "center")

	local goldX = hpX + hpBarW + 16
	label("GOLD", goldX, tbY + 4)
	setC(C.gold)
	love.graphics.setFont(love.graphics.newFont(14))
	love.graphics.print(player.gold, goldX, tbY + 14)

	if HUD.logTimer > 0 then
		local a = math.min(HUD.logTimer, 1)
		setC(C.accent, a)
		love.graphics.setFont(love.graphics.newFont(13))
		love.graphics.printf(HUD.logMsg, 0, tbY + 10, sw, "center")
	end

	local btnW, btnH = 70, 22
	local btnX = sw - p - btnW - HUD.RIGHT_COL_W - p
	local btnY = tbY + (tbH - btnH) / 2
	setC(C.panel)
	love.graphics.rectangle("fill", btnX, btnY, btnW, btnH, 4, 4)
	setC(C.border)
	love.graphics.rectangle("line", btnX, btnY, btnW, btnH, 4, 4)
	setC(C.text)
	love.graphics.setFont(love.graphics.newFont(11))
	love.graphics.printf("MENU  [ESC]", btnX, btnY + 5, btnW, "center")

	local rcX = sw - HUD.RIGHT_COL_W - p
	local rcY = HUD.TOP_BAR_H + p
	local rcW = HUD.RIGHT_COL_W
	local rcH = sh - HUD.TOP_BAR_H - p * 2

	local statsH = math.floor(rcH * 0.48)
	local invH   = rcH - statsH - p

	panel(rcX, rcY, rcW, statsH)
	label("STATS", rcX + 8, rcY + 6, C.accent)

	local sy  = rcY + 22
	local sx  = rcX + 8
	local sw2 = rcW - 16

	local statLines = {
		{ lbl = "HP",        val = player.hp,                           col = player.hp <= 3 and C.danger or C.text },
		{ lbl = "Gold",      val = player.gold,                         col = C.gold },
		{ lbl = "Dmg taken", val = player.damageTaken,                  col = C.text },
		{ lbl = "Moves",     val = player.movePoints,                   col = C.accent },
		{ lbl = "Shop",      val = player.shopVisited and "Yes" or "No", col = C.text },
		{ lbl = "Portal",    val = player.portalUsed  and "Yes" or "No", col = C.text },
	}

	for _, s in ipairs(statLines) do
		label(s.lbl, sx, sy)
		setC(s.col or C.text)
		love.graphics.setFont(love.graphics.newFont(13))
		love.graphics.printf(tostring(s.val), sx, sy, sw2, "right")
		sy = sy + 20
	end

	sy = sy + 4
	setC(C.label)
	love.graphics.setFont(love.graphics.newFont(10))
	love.graphics.print("Cam [F1] " .. (camera.enabled and "ON" or "OFF"), sx, sy)
	sy = sy + 14
	love.graphics.print("Fog [F2] " .. (fog.enabled and "ON" or "OFF"), sx, sy)
	sy = sy + 14
	love.graphics.print("Dbg [F3] " .. (HUD.debugVisible and "ON" or "OFF"), sx, sy)

	local invY    = rcY + statsH + p
	panel(rcX, invY, rcW, invH)
	label("INVENTORY", rcX + 8, invY + 6, C.accent)

	local slotSize = 32
	local cols     = 4
	local slotPad  = 6
	local startX   = rcX + math.floor((rcW - (slotSize * cols + slotPad * (cols - 1))) / 2)
	local startY   = invY + 24

	for row = 0, 2 do
		for col = 0, cols - 1 do
			local sx2 = startX + col * (slotSize + slotPad)
			local sy2 = startY + row * (slotSize + slotPad)
			setC(C.hp_bg)
			love.graphics.rectangle("fill", sx2, sy2, slotSize, slotSize, 4, 4)
			setC(C.border)
			love.graphics.rectangle("line", sx2, sy2, slotSize, slotSize, 4, 4)
		end
	end

	if gameState == "win" then
		setC({ 0, 0, 0 }, 0.82)
		love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), sh)

		love.graphics.setFont(love.graphics.newFont(28))
		setC(C.accent)
		love.graphics.printf("The Dungeon crumbles behind you...", 0, sh / 2 - 90, love.graphics.getWidth(), "center")

		love.graphics.setFont(love.graphics.newFont(15))
		setC(C.text)
		love.graphics.printf(
			"Gold : "         .. player.gold        .. "\n" ..
			"Damage taken : " .. player.damageTaken  .. "\n" ..
			"Moves made : "   .. player.movePoints   .. "\n" ..
			"Shop visited : " .. (player.shopVisited and "Yes" or "No") .. "\n" ..
			"Portal used : "  .. (player.portalUsed  and "Yes" or "No"),
			0, sh / 2 - 20, love.graphics.getWidth(), "center"
		)

		setC(C.label)
		love.graphics.printf("Press ENTER to return to menu", 0, sh / 2 + 100, love.graphics.getWidth(), "center")
	end

	if HUD.debugVisible and gridReady() then
		local dbLines = {
			{ txt = "[ DEBUG ]",                                          col = C.debug_hdr  },
			{ txt = "Pos   : " .. (player.grid_x / Cfg.TILE_SIZE) .. ", " .. (player.grid_y / Cfg.TILE_SIZE) },
			{ txt = "HP    : " .. player.hp,                             col = player.hp <= 3 and C.danger or nil },
			{ txt = "Moves : " .. player.movePoints,                     col = C.accent     },
			{ txt = "Gold  : " .. player.gold,                           col = C.gold       },
			{ txt = "Cam   : " .. (camera.enabled and "ON" or "OFF"),    col = C.debug_warn },
			{ txt = "Fog   : " .. (fog.enabled    and "ON" or "OFF"),    col = C.debug_warn },
		}

		local lineH  = 15
		local dbPadX = 6
		local dbPadY = 4
		local dbW    = 148
		local dbH    = #dbLines * lineH + dbPadY * 2
		local dbX    = p
		local dbY    = HUD.TOP_BAR_H + p + 4

		setC({ 0, 0, 0 }, 0.70)
		love.graphics.rectangle("fill", dbX, dbY, dbW, dbH, 4, 4)
		setC(C.border)
		love.graphics.rectangle("line", dbX, dbY, dbW, dbH, 4, 4)

		for i, d in ipairs(dbLines) do
			setC(d.col or C.text)
			love.graphics.setFont(love.graphics.newFont(11))
			love.graphics.print(d.txt, dbX + dbPadX, dbY + dbPadY + (i - 1) * lineH)
		end
	end

	love.graphics.setColor(1, 1, 1)
end

function hud_keypressed(key)
	if key == "f3" then
		HUD.debugVisible = not HUD.debugVisible
	end

	if gameState == "win" and key == "return" then
		gameState     = "menu"
		selectedIndex = 1
		grid_load()
		fog_load()
		player_load()
		camera_load()
	end
end

function hud_getMapRect()
	return HUD.mapRect
end
