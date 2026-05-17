local TileSys = {}

-- Pending stat change stored during dice animation
TileSys.pending = nil

-- ── Portal state ───────────────────────────────────────────────────────────────
-- When the player stands on the portal, show a "Press E" prompt.
-- On use, teleport to a random floor tile (one-time per game).
TileSys.portalPrompt = false
TileSys.portalTimer  = 0
TileSys.portalWhirl  = 0
TileSys.portalUsed   = false   -- consumed once triggered; stays on map visually

function TileSys.handleStep(tile, x, y, ctx)
	local T = Config.map.tiles

	if tile == T.gold then
		return "gold"

	elseif tile == T.enemy then
		return "enemy"

	elseif tile == T.shop then
		return "shop"

	elseif tile == T.portal and not TileSys.portalUsed then
		-- Show the "Press E" prompt; actual teleport fires on E keypress
		TileSys.portalPrompt = true
		TileSys.portalTimer  = 0
		TileSys.portalWhirl  = 0
		TileSys.portalCtx    = ctx
		return nil

	elseif tile == T.exit then
		gameState = "win"
	end

	return nil
end

-- Called from player_keypressed when key == "e"
function TileSys.tryEnterPortal()
	if not TileSys.portalPrompt then return end
	local ctx = TileSys.portalCtx
	if not ctx then return end

	TileSys.portalUsed   = true
	TileSys.portalPrompt = false

	-- Collect all floor tiles as valid landing spots
	local T      = Config.map.tiles
	local floors = {}
	for yy = 1, #ctx.map do
		for xx = 1, #ctx.map[yy] do
			if ctx.map[yy][xx] == T.floor then
				floors[#floors+1] = {x = xx, y = yy}
			end
		end
	end

	if #floors == 0 then return end   -- safety: no floor found, do nothing

	local dest = floors[love.math.random(#floors)]
	ctx.player.grid_x = dest.x * 32
	ctx.player.grid_y = dest.y * 32
	fog_update(dest.x, dest.y)
end

-- Update whirl angle (called each frame while prompt is up)
function TileSys.updatePortal(dt)
	if TileSys.portalPrompt then
		TileSys.portalTimer = TileSys.portalTimer + dt
		TileSys.portalWhirl = TileSys.portalTimer * 4
	end
end

-- Draw portal overlay (call after camera_detach, before HUD)
function TileSys.drawPortalOverlay()
	if not TileSys.portalPrompt then return end

	local sw, sh = love.graphics.getWidth(), love.graphics.getHeight()
	local cx, cy = sw / 2, sh / 2 - 60

	local t     = TileSys.portalTimer
	local pulse = 0.72 + math.sin(t * 5) * 0.08

	-- Spinning outer ring
	love.graphics.setLineWidth(3)
	local steps = 18
	for i = 0, steps - 1 do
		local a1 = TileSys.portalWhirl + (i / steps) * math.pi * 2
		local a2 = TileSys.portalWhirl + ((i + 0.7) / steps) * math.pi * 2
		local r  = 42 * pulse
		love.graphics.setColor(0.40, 0.70, 1.00, (i % 2 == 0) and 0.9 or 0.3)
		love.graphics.arc("line", cx, cy, r, a1, a2)
	end

	-- Counter-rotating inner ring
	for i = 0, steps - 1 do
		local a1 = -TileSys.portalWhirl * 1.4 + (i / steps) * math.pi * 2
		local a2 = -TileSys.portalWhirl * 1.4 + ((i + 0.6) / steps) * math.pi * 2
		local r  = 26 * pulse
		love.graphics.setColor(0.65, 0.45, 1.00, (i % 2 == 0) and 0.7 or 0.2)
		love.graphics.arc("line", cx, cy, r, a1, a2)
	end

	-- Glow core
	love.graphics.setColor(0.50, 0.80, 1.00, 0.25 + math.sin(t * 7) * 0.10)
	love.graphics.circle("fill", cx, cy, 18 * pulse)

	-- Orbiting sparkles
	for i = 1, 6 do
		local sa = TileSys.portalWhirl * 2.2 + (i / 6) * math.pi * 2
		local sr = 52 * pulse
		love.graphics.setColor(1, 1, 1, 0.5 + math.sin(t * 8 + i) * 0.4)
		love.graphics.circle("fill", cx + math.cos(sa) * sr, cy + math.sin(sa) * sr, 2.5)
	end

	-- "Press E" prompt
	love.graphics.setLineWidth(1)
	local promptA = 0.6 + math.sin(t * 3) * 0.4
	local font    = love.graphics.newFont(Config.fonts.hudStat)
	love.graphics.setFont(font)
	love.graphics.setColor(0, 0, 0, promptA * 0.6)
	love.graphics.printf("Press  E  to step through the portal", 1, cy + 58, sw, "center")
	love.graphics.setColor(0.55, 0.90, 1.00, promptA)
	love.graphics.printf("Press  E  to step through the portal", 0, cy + 57, sw, "center")

	love.graphics.setColor(1, 1, 1)
end

-- ── Encounter resolution ───────────────────────────────────────────────────────

function TileSys.resolveEncounter(kind, roll, p)
	TileSys.pending = { kind = kind, roll = roll, player = p }
end

function TileSys.applyPending()
	local pd = TileSys.pending
	if not pd then return end
	TileSys.pending = nil

	if pd.kind == "gold" then
		pd.player.gold = pd.player.gold + pd.roll
	elseif pd.kind == "enemy" then
		pd.player.hp = math.max(0, pd.player.hp - pd.roll)
		pd.player.damageTaken = (pd.player.damageTaken or 0) + pd.roll
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

-- Reset portal state when a new game starts
function TileSys.reset()
	TileSys.pending      = nil
	TileSys.portalPrompt = false
	TileSys.portalTimer  = 0
	TileSys.portalWhirl  = 0
	TileSys.portalUsed   = false
	TileSys.portalCtx    = nil
end

return TileSys
