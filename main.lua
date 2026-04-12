require("menu")
require("player")
require("grid")
require("hud")
require("camera")
require("fog")

function love.load()
  if menu_load then menu_load() end
  if grid_load then grid_load() end
  if fog_load then fog_load() end
  if player_load then player_load() end
  if camera_load then camera_load() end
end

function love.update(dt)
  if gameState == "newGame" or gameState == "win" then
    if grid_update then grid_update(dt) end
    if player_update then player_update(dt) end
    if camera_update then camera_update(dt) end
  else
    if menu_update then menu_update(dt) end
  end
end

function love.draw()
  if gameState == "newGame" or gameState == "win" then
    camera_attach() 
      if grid_draw then grid_draw() end
      if player_draw then player_draw() end
      fog_draw()
    camera_detach()
    drawEntryPopup() 
    drawDiceCutscene() 
    if hud_draw then hud_draw() end
  else
    if menu_draw then menu_draw() end
  end
end

function love.keypressed(key)
  if gameState == "newGame" then
    if player_keypressed then player_keypressed(key) end
    if camera_keypressed then camera_keypressed(key) end
    if fog_keypressed then fog_keypressed(key) end
  elseif gameState == "win" then
    if hud_keypressed then hud_keypressed(key) end
  else
    if menu_keypressed then menu_keypressed(key) end
  end

  if key == "escape" and gameState ~= "win" then
    gameState = "menu"
    selectedIndex = 1
  end
end