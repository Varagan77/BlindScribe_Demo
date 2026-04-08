function menu_load()
  gameState = "menu"
  timer = 5
end


function menu_update(dt)
end

function menu_draw()
  if gameState == "menu" then
    love.graphics.setFont(love.graphics.newFont(24))
    love.graphics.setColor(1,1,1,1)

    love.graphics.printf("BlindScribe",20,100, love.graphics.getWidth(),"center")
    love.graphics.printf("New Game",20,200, love.graphics.getWidth(),"left")
    love.graphics.printf("Options",20,240, love.graphics.getWidth(),"left")
    love.graphics.printf("About",20,280, love.graphics.getWidth(),"left")
    love.graphics.printf("Exit",20,320, love.graphics.getWidth(),"left")
  
  
  elseif gameState == "play" then
    love.graphics.setColor(0,1,0,1)
    love.graphics.circle("fill",400,300,30)
    
  elseif  gameState == "GameOver" then
    love.graphics.setColor(1,0,0,1)
    love.graphics.printf("Game Over, Press R to Restart", 0, 300, love.graphics.getWidth(),"center")
  end
end