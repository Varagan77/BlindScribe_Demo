-- =============================================================================
--  fog.lua  —  Tight lantern fog + proximity sense cues
--              Enemies and gold are never visually revealed in the light radius.
-- =============================================================================

fog = {
	enabled = Config.fog.enabled,
	visited = {},
}

local proxCue   = nil
local CUE_DURATION = 3.0
local cueFont   = nil

-- Tile IDs that should stay visually hidden even when "visited"
local HIDDEN_TILES = {}  -- populated in fog_load once Config is ready

function fog_load()
	HIDDEN_TILES = {
		[Config.map.tiles.enemy] = true,
		[Config.map.tiles.gold]  = true,
	}

	fog.visited = {}
	for y = 1, #map do
		fog.visited[y] = {}
		for x = 1, #map[y] do
			fog.visited[y][x] = false
		end
	end
	proxCue = nil
	cueFont = love.graphics.newFont(15)
end

function fog_reveal(tileX, tileY)
	if fog.visited[tileY] and fog.visited[tileY][tileX] ~= nil then
		fog.visited[tileY][tileX] = true
	end
end

-- Called every player step.
function fog_update(tileX, tileY)
	if not fog.enabled then return end

	local r = Config.fog.radius or 1

	for dy = -r, r do
		for dx = -r, r do
			local nx, ny = tileX + dx, tileY + dy
			if fog.visited[ny] and fog.visited[ny][nx] ~= nil then
				-- Never mark enemy/gold tiles as visited so they stay dark
				local tid = map[ny] and map[ny][nx]
				if not HIDDEN_TILES[tid] then
					fog.visited[ny][nx] = true
				end
			end
		end
	end

	-- ── Proximity sense: scan for enemy / gold within 3 tiles ─────────
	local SENSE_RADIUS = 3
	local closestEnemy = nil
	local closestGold  = nil

	for dy = -SENSE_RADIUS, SENSE_RADIUS do
		for dx = -SENSE_RADIUS, SENSE_RADIUS do
			local nx, ny = tileX + dx, tileY + dy
			if map[ny] and map[ny][nx] then
				local tid  = map[ny][nx]
				local dist = math.max(math.abs(dx), math.abs(dy))

				if tid == Config.map.tiles.enemy then
					if not closestEnemy or dist < closestEnemy then closestEnemy = dist end
				elseif tid == Config.map.tiles.gold then
					if not closestGold  or dist < closestGold  then closestGold  = dist end
				end
			end
		end
	end

	local cueText, cueColour

	if closestEnemy then
		if closestEnemy <= 1 then
			cueText   = "Something lurks right beside you..."
			cueColour = {1.00, 0.18, 0.18}
		elseif closestEnemy <= 2 then
			cueText   = "You sense a presence close by..."
			cueColour = {1.00, 0.52, 0.18}
		else
			cueText   = "A distant growl echoes through the dark..."
			cueColour = {0.88, 0.72, 0.38}
		end
	elseif closestGold then
		if closestGold <= 1 then
			cueText   = "A metallic glint catches your eye..."
			cueColour = {1.00, 0.90, 0.18}
		elseif closestGold <= 2 then
			cueText   = "The faint jingle of coins nearby..."
			cueColour = {1.00, 0.82, 0.32}
		else
			cueText   = "Something valuable lingers in the distance..."
			cueColour = {0.82, 0.76, 0.48}
		end
	end

	if cueText then
		proxCue = { text = cueText, colour = cueColour, alpha = 1.0, timer = CUE_DURATION }
	end
end

function fog_tick(dt)
	if proxCue then
		proxCue.timer = proxCue.timer - dt
		proxCue.alpha = proxCue.timer <= 1.0 and math.max(0, proxCue.timer) or 1.0
		if proxCue.timer <= 0 then proxCue = nil end
	end
end

function fog_draw()
	if not fog.enabled then return end

	local TS  = 32
	local px  = player and (player.act_x + TS / 2) or 0
	local py  = player and (player.act_y + TS / 2) or 0
	local r   = Config.fog.radius or 1
	-- Tight lantern: bright core = 0.6 tiles, hard edge at ~1.4 tiles
	local lightRadius = r * TS * 1.4

	for y = 1, #map do
		for x = 1, #map[y] do
			local wx = x * TS
			local wy = y * TS
			local cx = wx + TS / 2
			local cy = wy + TS / 2
			local tid = map[y][x]

			if not fog.visited[y][x] then
				-- Completely unseen: solid black
				love.graphics.setColor(0, 0, 0, 1)
				love.graphics.rectangle("fill", wx, wy, TS, TS)

				-- Hidden special tiles get a barely-visible colour pulse —
				-- just enough to make the darkness feel *alive*, not reveal the tile.
				-- Enemy: faint red throb. Gold: faint amber shimmer.
				if HIDDEN_TILES[tid] then
					local pulse = math.abs(math.sin(love.timer.getTime() * 1.8 + x * 0.7 + y * 0.5))
					if tid == Config.map.tiles.enemy then
						love.graphics.setColor(0.18, 0.01, 0.01, pulse * 0.13)
					else
						love.graphics.setColor(0.18, 0.13, 0.01, pulse * 0.10)
					end
					love.graphics.rectangle("fill", wx, wy, TS, TS)
				end
			else
				-- Visited floor/wall: distance-based darkness with a warm tint near player
				local dist = math.sqrt((cx - px)^2 + (cy - py)^2)
				local darkPct

				if dist <= lightRadius * 0.30 then
					darkPct = 0.0
				elseif dist <= lightRadius then
					local t = (dist - lightRadius * 0.30) / (lightRadius * 0.70)
					darkPct = t * t * t   -- cubic falloff — faster drop into dark
				else
					darkPct = 1.0
				end

				-- Visited tiles far away dim to a deep blue-black (not pure black, memory haze)
				local alpha = math.min(0.90, darkPct * 0.94)
				love.graphics.setColor(0.01, 0.01, 0.04, alpha)
				love.graphics.rectangle("fill", wx, wy, TS, TS)

				-- Warm amber glow overlay in the bright core
				if darkPct < 0.25 then
					local warmA = (1 - darkPct / 0.25) * 0.06
					love.graphics.setColor(0.80, 0.50, 0.10, warmA)
					love.graphics.rectangle("fill", wx, wy, TS, TS)
				end
			end
		end
	end

	love.graphics.setColor(1, 1, 1)
end

-- Proximity cue text drawn in screen-space (after camera_detach)
function fog_draw_cue()
	if not proxCue or proxCue.alpha <= 0 then return end

	local sw = love.graphics.getWidth()
	local sh = love.graphics.getHeight()
	local c  = proxCue.colour
	local a  = proxCue.alpha

	love.graphics.setFont(cueFont)
	-- Drop shadow
	love.graphics.setColor(0, 0, 0, a * 0.75)
	love.graphics.printf("[ " .. proxCue.text .. " ]", 1, sh - 118, sw, "center")
	-- Main
	love.graphics.setColor(c[1], c[2], c[3], a)
	love.graphics.printf("[ " .. proxCue.text .. " ]", 0, sh - 119, sw, "center")

	love.graphics.setColor(1, 1, 1)
end

function fog_keypressed(key)
	if key == Config.keys.fogToggle then
		fog.enabled = not fog.enabled
	end
end
