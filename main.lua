require("menu")
require("player")
require("grid")

function love.load()
  if menu_load then menu_load() end
  if grid_load then grid_load() end
  if player_load then player_load() end
 
end

function love.update(dt)
  if gameState == "newGame" then
    if player_update then player_update(dt) end
  else
    if menu_update then menu_update(dt) end
  end
end

function love.draw()
  if gameState == "newGame" then
    if grid_draw then grid_draw() end
    if player_draw then player_draw() end
  else
    if menu_draw then menu_draw() end
  end
end

function love.keypressed(key)

  if gameState == "newGame" then
    if player_keypressed then player_keypressed(key) end
  else
    if menu_keypressed then menu_keypressed(key) end
  end

  if key == "escape" then
    gameState = "menu"
    selectedIndex = 1
  end
end