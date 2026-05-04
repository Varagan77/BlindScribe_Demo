local Cfg = require("config.settings")

fog = {
	enabled = Cfg.FOG_ON,
	visited = {},
}

function fog_load()
	fog.visited = {}
	for y = 1, #map do
		fog.visited[y] = {}
		for x = 1, #map[y] do
			fog.visited[y][x] = false
		end
	end
end

function fog_reveal(tileX, tileY)
	if fog.visited[tileY] and fog.visited[tileY][tileX] ~= nil then
		fog.visited[tileY][tileX] = true
	end
end

function fog_draw()
	if not fog.enabled then return end

	local ts = Cfg.TILE_SIZE
	love.graphics.setColor(0, 0, 0, 1)
	for y = 1, #map do
		for x = 1, #map[y] do
			if not fog.visited[y][x] then
				love.graphics.rectangle("fill", x * ts, y * ts, ts, ts)
			end
		end
	end
	love.graphics.setColor(1, 1, 1)
end

function fog_keypressed(key)
	if key == "f2" then
		fog.enabled = not fog.enabled
	end
end