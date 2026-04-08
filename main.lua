require("menu")

function love.load()
  if menu_load then menu_load() end
end

function love.update(dt)
  if menu_update then menu_update(dt) end
end

function love.draw()
  if menu_draw then menu_draw() end
end