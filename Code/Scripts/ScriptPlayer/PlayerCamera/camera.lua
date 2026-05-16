-- ---------------------------------------------------------------------------
--  CAMERA
-- ---------------------------------------------------------------------------

camera = {
	x       = 0,
	y       = 0,
	speed   = Config.camera.speed,
	enabled = Config.camera.enabled,
	zoom    = Config.camera.zoom or 1,
}

local function getScreenSize()
	local sw = love.graphics.getWidth()  / camera.zoom
	local sh = love.graphics.getHeight() / camera.zoom
	return sw, sh
end

function camera_load()
	local sw, sh = getScreenSize()

	camera.x = player.act_x - sw / 2 + 16
	camera.y = player.act_y - sh / 2 + 16
end

function camera_update(dt)
	if not camera.enabled then return end

	local sw, sh = getScreenSize()

	local tx = player.act_x - sw / 2 + 16
	local ty = player.act_y - sh / 2 + 16

	camera.x = camera.x + (tx - camera.x) * camera.speed * dt
	camera.y = camera.y + (ty - camera.y) * camera.speed * dt
	-- camera.zoom = camera.zoom + (Config.camera.zoom - camera.zoom) * dt * camera.speed --keep out for now
end

function camera_attach()
	if not camera.enabled then return end

	love.graphics.push()

	-- scale world first (zoom)
	love.graphics.scale(camera.zoom, camera.zoom)

	-- then translate camera position
	love.graphics.translate(
		-math.floor(camera.x),
		-math.floor(camera.y)
	)
end

function camera_detach()
	if not camera.enabled then return end
	love.graphics.pop()
end

function camera_keypressed(key)
	if key == Config.keys.camToggle then
		camera.enabled = not camera.enabled

		if not camera.enabled then
			camera.x = 0
			camera.y = 0
		else
			local sw, sh = getScreenSize()
			camera.x = player.act_x - sw / 2 + 16
			camera.y = player.act_y - sh / 2 + 16
		end
	end
end