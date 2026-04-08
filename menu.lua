function menu_load()
  gameState = "menu"
  selectedIndex = 1

  menuItems = {
    {text = "New Game", state = "newGame"},
    {text = "Options", state = "options"},
    {text = "About", state = "about"},
    {text = "Exit", state = "exit"}
  }
end

---------------------------
function menu_update(dt)
end
---------------------------

------------------------------------------
function love.keypressed(key)

  if gameState == "menu" then

    if key == "down" then
      selectedIndex = selectedIndex + 1
      if selectedIndex > #menuItems then
        selectedIndex = 1
      end

    elseif key == "up" then
      selectedIndex = selectedIndex - 1
      if selectedIndex < 1 then
        selectedIndex = #menuItems
      end

    elseif key == "return" then
      gameState = menuItems[selectedIndex].state
    end



  else
    if key == "escape" then
      gameState = "menu"
      selectedIndex = 1
    end

    if gameState == "exit" and key == "return" then
      love.event.quit()
    end
  end

end
------------------------------------------------------

function menu_draw()
  love.graphics.setFont(love.graphics.newFont(24))

  if gameState == "menu" then

    love.graphics.setColor(1,1,1,1)
    love.graphics.printf("BlindScribe", 20, 100, love.graphics.getWidth(), "center")

    for i, item in ipairs(menuItems) do
      local y = 200 + (i - 1) * 40

      if i == selectedIndex then
        love.graphics.setColor(1,1,0,1) -- yellow highlight
        love.graphics.print("> " .. item.text, 20, y)
      else
        love.graphics.setColor(1,1,1,1) -- white
        love.graphics.print(item.text, 20, y)
      end
    end

----------------------------------------------------------------------------------------------
  elseif gameState == "newGame" then
    love.graphics.setColor(1,0,0,1)
    love.graphics.printf("New Game Insert", 0, 300, love.graphics.getWidth(),"center")
    love.graphics.printf("Press ESC to return", 0, 350, love.graphics.getWidth(),"center")

  elseif gameState == "options" then
    love.graphics.setColor(1,0,0,1)
    love.graphics.printf("Options Insert", 0, 300, love.graphics.getWidth(),"center")
    love.graphics.printf("Press ESC to return", 0, 350, love.graphics.getWidth(),"center")

  elseif gameState == "about" then
    love.graphics.setColor(1,0,0,1)
    love.graphics.printf("About insert", 0, 300, love.graphics.getWidth(),"center")
    love.graphics.printf("Press ESC to return", 0, 350, love.graphics.getWidth(),"center")

  elseif gameState == "exit" then
    love.graphics.setColor(1,0,0,1)
    love.graphics.printf("Press ENTER to quit or ESC to return", 0, 350, love.graphics.getWidth(),"center")
  end
------------------------------------------------------------------------------------------------
end