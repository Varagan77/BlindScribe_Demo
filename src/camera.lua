local Cfg = require("config.settings")

camera = {
	x       = 0,
	y       = 0,
	speed   = Cfg.CAMERA_SPEED,
	enabled = Cfg.CAMERA_ON,
}

function camera_load()
	local sw = love.graphics.getWidth()
	local sh = love.graphics.getHeight()
	camera.x = player.act_x - sw / 2 + Cfg.TILE_SIZE / 2
	camera.y = player.act_y - sh / 2 + Cfg.TILE_SIZE / 2
end

function camera_update(dt)
	if not camera.enabled then return end

	local sw = love.graphics.getWidth()
	local sh = love.graphics.getHeight()

	local tx = player.act_x - sw / 2 + Cfg.TILE_SIZE / 2
	local ty = player.act_y - sh / 2 + Cfg.TILE_SIZE / 2

	camera.x = camera.x + (tx - camera.x) * camera.speed * dt
	camera.y = camera.y + (ty - camera.y) * camera.speed * dt
end

function camera_attach()
	if not camera.enabled then return end
	love.graphics.push()
	love.graphics.translate(-math.floor(camera.x), -math.floor(camera.y))
end

function camera_detach()
	if not camera.enabled then return end
	love.graphics.pop()
end

function camera_keypressed(key)
	if key == "f1" then
		camera.enabled = not camera.enabled
		if not camera.enabled then
			camera.x = 0
			camera.y = 0
		else
			local sw = love.graphics.getWidth()
			local sh = love.graphics.getHeight()
			camera.x = player.act_x - sw / 2 + Cfg.TILE_SIZE / 2
			camera.y = player.act_y - sh / 2 + Cfg.TILE_SIZE / 2
		end
	end
end
