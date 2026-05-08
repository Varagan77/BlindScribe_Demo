--wip
local C = {
	tiles = {
		[0] = {0.18, 0.16, 0.22},   -- floor
		[1] = {0.08, 0.07, 0.10},   -- wall
		[2] = {0.25, 0.70, 0.45},   -- shop
		[3] = {0.90, 0.20, 0.20},   -- enemy
		[4] = {0.30, 0.55, 1.00},   -- portal in
		[5] = {0.20, 0.35, 0.85},   -- portal out
		[6] = {1.00, 0.85, 0.20},   -- exit
		[7] = {1.00, 0.75, 0.10},   -- gold
	},
	floor_grid  = {0.22, 0.20, 0.28, 0.6},
	wall        = {0.08, 0.07, 0.10},
	pawn_glow   = {1.00, 1.00, 1.00, 0.15},
	selected_ab = {0.70, 0.35, 1.00},
}


local PAWN_COLOURS = {
	{0.30, 0.80, 1.00},
	{1.00, 0.70, 0.20},
	{0.30, 1.00, 0.55},
	{1.00, 0.35, 0.55},
}


local ABILITIES = {
	{
		name        = "Spawn",
		cost        = 12,
		cooldownMax = 0,
		cooldown    = 0,
		desc        = "Place a new enemy adjacent to a pawn",
		action      = function(dm, tx, ty) dm_ability_spawn(dm, tx, ty) end,
	},
	{
		name        = "Mutate",
		cost        = 8,
		cooldownMax = 0,
		cooldown    = 0,
		desc        = "Modify a pawn's stats",
		action      = function(dm) dm_ability_mutate(dm) end,
	},
	{
		name        = "Block",
		cost        = 6,
		cooldownMax = 8,
		cooldown    = 0,
		desc        = "Seal a passage for 8 seconds",
		action      = function(dm) dm_ability_block(dm) end,
	},
	{
		name        = "Swap",
		cost        = 20,
		cooldownMax = 0,
		cooldown    = 0,
		desc        = "Teleport two pawns to each other",
		action      = function(dm) dm_ability_swap(dm) end,
	},
	{
		name        = "Inflate",
		cost        = 6,
		cooldownMax = 0,
		cooldown    = 0,
		desc        = "Raise damage or gold on next tile",
		action      = function(dm) dm_ability_inflate(dm) end,
	},
	{
		name        = "Shift",
		cost        = 10,
		cooldownMax = 12,
		cooldown    = 0,
		desc        = "Move a tile to a new position",
		action      = function(dm) dm_ability_shift(dm) end,
	},
}



function dm_load()
	
	local abs = {}
	for i, a in ipairs(ABILITIES) do
		abs[i] = {
			name        = a.name,
			cost        = a.cost,
			cooldownMax = a.cooldownMax,
			cooldown    = a.cooldown,
			desc        = a.desc,
			action      = a.action,
		}
	end

	DM = {
		-- Essence
		essence         = 100,
		essenceMax      = 100,
		essenceDrain    = 1.5,   

		
		abilities       = abs,
		selectedAbility = nil,
		targeting       = false,   -- true when waiting for a tile click
		hoverTile       = nil,     -- {x, y} tile under mouse cursor

		
		pawns           = {},

		
		totalDamageDealt = 0,
		totalEssEarned   = 0,

		
		blocks          = {},   

		
		scale           = 1,
		offsetX         = 0,
		offsetY         = 0,
	}

	dm_hud_load()
	dm_computeScale()
end



function dm_computeScale()
	if not map or not map[1] then return end
	if not dm_hud_getMapRect then return end
	local mr = dm_hud_getMapRect()
	if not mr or mr.w == 0 or mr.h == 0 then return end

	local cols  = #map[1]
	local rows  = #map
	-- grid_draw draws tile (x,y) at pixel (x*32, y*32), x in [1..cols]
	-- so world spans 32..(cols+1)*32, total = cols*32 wide (plus leading 32 pad)
	local mapW  = (cols + 1) * 32
	local mapH  = (rows + 1) * 32
	local scaleX = mr.w / mapW
	local scaleY = mr.h / mapH
	DM.scale   = math.min(scaleX, scaleY)
	DM.offsetX = mr.x + (mr.w - mapW * DM.scale) / 2
	DM.offsetY = mr.y + (mr.h - mapH * DM.scale) / 2
end



function dm_update(dt)
	if not DM then return end

	dm_hud_update(dt)

	
	for _, ab in ipairs(DM.abilities) do
		if ab.cooldown > 0 then
			ab.cooldown = math.max(0, ab.cooldown - dt)
		end
	end

	
	local stillActive = {}
	for _, blk in ipairs(DM.blocks) do
		blk.timer = blk.timer - dt
		if blk.timer > 0 then
			table.insert(stillActive, blk)
		else
			

			if map and map[blk.y] and map[blk.y][blk.x] == 1 then
				map[blk.y][blk.x] = blk.origTile
				dm_hud_log("Block expired at (" .. blk.x .. "," .. blk.y .. ")")
			end
		end
	end
	DM.blocks = stillActive

	
	if player then
		DM.pawns = {{
			name       = "Player",
			hp         = player.hp,
			gold       = player.gold,
			moves      = player.movePoints,
			movePoints = player.movePoints,
			grid_x     = player.grid_x,
			grid_y     = player.grid_y,
			colour     = PAWN_COLOURS[1],
		}}
	end

	dm_computeScale()

end


function dm_onPawnDamage(amount)
	if not DM then return end
	local gain          = amount * 2
	DM.essence          = math.min(DM.essenceMax, DM.essence + gain)
	DM.totalDamageDealt = DM.totalDamageDealt + amount
	DM.totalEssEarned   = DM.totalEssEarned   + gain
	dm_hud_log("Pawn took " .. amount .. " dmg — +" .. gain .. " essence")
end


function dm_drawMap()
	local activeMap = (debugDone and map) or (debugMap or map)
	if not activeMap or not activeMap[1] then return end

	love.graphics.push()
	love.graphics.translate(DM.offsetX, DM.offsetY)
	love.graphics.scale(DM.scale, DM.scale)

	local gap = 1
	for y = 1, #activeMap do
		for x = 1, #activeMap[y] do
			local tile = activeMap[y][x]
			local col  = C.tiles[tile] or C.tiles[0]
			love.graphics.setColor(col[1], col[2], col[3], 1)
			love.graphics.rectangle("fill", x * 32 + gap, y * 32 + gap, 32 - gap, 32 - gap)
		end
	end

	-- Block overlays
	local pulse = math.abs(math.sin(love.timer.getTime() * 3)) * 0.5 + 0.4
	for _, blk in ipairs(DM.blocks) do
		love.graphics.setColor(0.70, 0.35, 1.00, pulse)
		love.graphics.rectangle("fill", blk.x * 32 + gap, blk.y * 32 + gap, 32 - gap, 32 - gap)
	end

	-- Hover highlight while targeting
	if DM.targeting and DM.hoverTile then
		local hx = DM.hoverTile.x
		local hy = DM.hoverTile.y
		local tile = map[hy] and map[hy][hx]
		local validTarget = (tile == 0)  -- only floor tiles are valid for Spawn
		if validTarget then
			love.graphics.setColor(0.90, 0.20, 0.20, 0.55)
			love.graphics.rectangle("fill", hx * 32 + gap, hy * 32 + gap, 32 - gap, 32 - gap)
			love.graphics.setColor(1.00, 0.40, 0.40, 0.9)
			love.graphics.rectangle("line", hx * 32 + gap, hy * 32 + gap, 32 - gap, 32 - gap)
		else
			love.graphics.setColor(0.5, 0.5, 0.5, 0.35)
			love.graphics.rectangle("fill", hx * 32 + gap, hy * 32 + gap, 32 - gap, 32 - gap)
			love.graphics.setColor(0.6, 0.6, 0.6, 0.6)
			love.graphics.rectangle("line", hx * 32 + gap, hy * 32 + gap, 32 - gap, 32 - gap)
		end
	end

	love.graphics.pop()
	love.graphics.setColor(1, 1, 1)
end

function dm_drawPawns()
	if not DM.pawns then return end

	love.graphics.push()
	love.graphics.translate(DM.offsetX, DM.offsetY)
	love.graphics.scale(DM.scale, DM.scale)

	local radius = math.max(3, 32 * 0.35)

	for i, pawn in ipairs(DM.pawns) do
		if pawn.grid_x and pawn.grid_y then
			local px = pawn.grid_x + 16
			local py = pawn.grid_y + 16
			local pc = pawn.colour or PAWN_COLOURS[((i - 1) % 4) + 1]

			love.graphics.setColor(pc[1], pc[2], pc[3], 0.18)
			love.graphics.circle("fill", px, py, radius * 2.2)

			love.graphics.setColor(pc[1], pc[2], pc[3], 1)
			love.graphics.circle("fill", px, py, radius)

			love.graphics.setColor(1, 1, 1, 0.6)
			love.graphics.circle("line", px, py, radius)

			if (pawn.hp or 1) <= 0 then
				love.graphics.setColor(1, 0.2, 0.2)
				love.graphics.setLineWidth(1.5)
				local r2 = radius * 0.6
				love.graphics.line(px - r2, py - r2, px + r2, py + r2)
				love.graphics.line(px + r2, py - r2, px - r2, py + r2)
				love.graphics.setLineWidth(1)
			end
		end
	end

	love.graphics.pop()
	love.graphics.setColor(1, 1, 1)
end


function dm_keypressed(key)
	if not DM then return end

	dm_hud_keypressed(key)

	local abKeys = {q=1, w=2, e=3, r=4, t=5, y=6}
	if abKeys[key] then
		local idx = abKeys[key]
		local ab  = DM.abilities[idx]
		if not ab then return end

		if DM.targeting and DM.selectedAbility == idx then
			-- Press same key again while targeting = cancel
			DM.selectedAbility = nil
			DM.targeting = false
			dm_hud_log("Ability cancelled.")
		elseif DM.selectedAbility == idx then
			dm_activateAbility(idx)
		else
			DM.selectedAbility = idx
			DM.targeting = false
			dm_hud_log(ab.name .. " — " .. ab.desc .. "  [" .. key:upper() .. " again to confirm]")
		end
		return
	end

	if key == "escape" then
		if DM.targeting or DM.selectedAbility then
			DM.selectedAbility = nil
			DM.targeting = false
			dm_hud_log("Ability cancelled.")
		else
			gameState     = "menu"
			selectedIndex = 1
		end
	end
end


-- Convert screen pixel (mx, my) to map tile (tx, ty), or nil if outside map
function dm_screenToTile(mx, my)
	if not DM or DM.scale == 0 then return nil end
	local wx = (mx - DM.offsetX) / DM.scale
	local wy = (my - DM.offsetY) / DM.scale
	local tx = math.floor(wx / 32)
	local ty = math.floor(wy / 32)
	-- Bounds check: map uses 1-based indices, grid_draw draws at x*32 so valid x in [1..cols]
	if not map or ty < 1 or ty > #map or tx < 1 or tx > #map[1] then
		return nil
	end
	return tx, ty
end


function dm_activateAbility(idx)
	local ab = DM.abilities[idx]
	if not ab then return end

	if DM.essence < ab.cost then
		dm_hud_log("Not enough Essence! (" .. ab.name .. " costs " .. ab.cost .. ")")
		DM.selectedAbility = nil
		DM.targeting = false
		return
	end

	if (ab.cooldown or 0) > 0 then
		dm_hud_log(ab.name .. " is on cooldown (" .. string.format("%.1f", ab.cooldown) .. "s)")
		DM.selectedAbility = nil
		DM.targeting = false
		return
	end

	-- Abilities that need a tile click enter targeting mode instead of firing
	local needsTile = { [1]=true }  -- Spawn needs a tile; add others here as they're built
	if needsTile[idx] then
		DM.targeting = true
		dm_hud_log(ab.name .. " — click a floor tile to place  [ESC to cancel]")
	else
		ab.action(DM)
		DM.selectedAbility = nil
		DM.targeting = false
	end
end


function dm_mousemoved(mx, my)
	if not DM then return end
	local tx, ty = dm_screenToTile(mx, my)
	DM.hoverTile = (tx and ty) and {x=tx, y=ty} or nil
end


function dm_mousepressed(mx, my, button)
	if not DM or button ~= 1 then return end
	if not DM.targeting or not DM.selectedAbility then return end

	local wx = (mx - DM.offsetX) / DM.scale
	local wy = (my - DM.offsetY) / DM.scale
	local tx, ty = dm_screenToTile(mx, my)

	-- Store debug info for on-screen display
	DM.debugClick = string.format(
		"screen(%d,%d) world(%.0f,%.0f) tile(%s,%s) offset(%.0f,%.0f) scale(%.3f)",
		mx, my, wx, wy,
		tostring(tx), tostring(ty),
		DM.offsetX, DM.offsetY, DM.scale
	)

	if not tx then
		dm_hud_log("Click inside the map.")
		return
	end

	local ab = DM.abilities[DM.selectedAbility]
	ab.action(DM, tx, ty)
	DM.selectedAbility = nil
	DM.targeting = false
end


function dm_ability_spawn(dm, tx, ty)
	-- tx/ty provided by mouse click via dm_mousepressed
	if not tx or not ty then
		dm_hud_log("Spawn: no tile selected.")
		return
	end
	if not map[ty] or not map[ty][tx] then
		dm_hud_log("Spawn: tile out of bounds.")
		return
	end
	if map[ty][tx] ~= 0 then
		dm_hud_log("Spawn: must click an empty floor tile.")
		return
	end
	map[ty][tx] = 3
	dm.essence = dm.essence - ABILITIES[1].cost
	dm_hud_log("Spawn: enemy placed at (" .. tx .. "," .. ty .. ")!")
end

function dm_ability_mutate(dm)
	-- WIP
	dm.essence = dm.essence - ABILITIES[2].cost
	dm_hud_log("Mutate: ability WIP — no effect yet.")
end

function dm_ability_block(dm)
	
	local pawn = dm.pawns[1]
	if not pawn then
		dm_hud_log("Block: no pawns on map.")
		return
	end

	local tx  = math.floor(pawn.grid_x / 32) + 1   
	local ty  = math.floor(pawn.grid_y / 32)
	if map[ty] and map[ty][tx] and map[ty][tx] == 0 then
		local orig       = map[ty][tx]
		map[ty][tx]      = 1
		local ab         = dm.abilities[3]
		ab.cooldown      = ab.cooldownMax
		dm.essence       = dm.essence - ABILITIES[3].cost
		table.insert(dm.blocks, { x = tx, y = ty, timer = 8, origTile = orig })
		dm_hud_log("Block placed at (" .. tx .. "," .. ty .. ") for 8s.")
	else
		dm_hud_log("Block: target tile is not a floor tile.")
	end
end

function dm_ability_swap(dm)
	
	if #dm.pawns < 2 then
		dm_hud_log("Swap: need at least 2 pawns.")
		return
	end
	local p1, p2 = dm.pawns[1], dm.pawns[2]
	p1.grid_x, p2.grid_x = p2.grid_x, p1.grid_x
	p1.grid_y, p2.grid_y = p2.grid_y, p1.grid_y
	dm.essence = dm.essence - ABILITIES[4].cost
	dm_hud_log("Swap: pawns teleported to each other!")
end

function dm_ability_inflate(dm)
	
	dm.essence = dm.essence - ABILITIES[5].cost
	dm_hud_log("Inflate: ability WIP — no effect yet.")
end

function dm_ability_shift(dm)
	
	dm.essence = dm.essence - ABILITIES[6].cost
	local ab   = dm.abilities[6]
	ab.cooldown = ab.cooldownMax
	dm_hud_log("Shift: ability WIP — no effect yet.")
end