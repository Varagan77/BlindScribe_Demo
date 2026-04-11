function hud_draw()
    
    if not gridReady() then return end

    local font = love.graphics.newFont(12)
    love.graphics.setFont(font)

    local sw = love.graphics.getWidth()
    local sh = love.graphics.getHeight()

  
    if gameState == "win" then
        love.graphics.setColor(0, 0, 0, 0.75)
        love.graphics.rectangle("fill", 0, 0, sw, sh)

        love.graphics.setFont(love.graphics.newFont(28))
        love.graphics.setColor(0.5, 1, 1)
        love.graphics.printf("Your eyes awaken...", 0, sh / 2 - 80, sw, "center")

        love.graphics.setFont(love.graphics.newFont(16))
        love.graphics.setColor(1, 1, 1)
        love.graphics.printf(
            "Gold collected : " .. player.gold .. "\n" ..
            "Damage taken   : " .. player.damageTaken .. "\n" ..
            "Shop visited   : " .. (player.shopVisited and "Yes" or "No") .. "\n" ..
            "Portal used    : " .. (player.portalUsed  and "Yes" or "No"),
            0, sh / 2 - 20, sw, "center"
        )

        love.graphics.setColor(0.7, 0.7, 0.7)
        love.graphics.printf("Press ENTER to return to menu", 0, sh / 2 + 90, sw, "center")
        love.graphics.setColor(1, 1, 1)
        return
    end

    
    local lines = {
        "[ DEBUG ]",
        "Pos     : " .. (player.grid_x / 32) .. ", " .. (player.grid_y / 32),
        "HP      : " .. player.hp,
        "Gold    : " .. player.gold,
        "Damage  : " .. player.damageTaken,
        "Shop    : " .. (player.shopVisited and "visited" or "no"),
        "Portal  : " .. (player.portalUsed  and "used"    or "no"),
    }

    local padding = 6
    local lineH   = 16
    local panelW  = 140
    local panelH  = #lines * lineH + padding * 2

    love.graphics.setColor(0, 0, 0, 0.6)
    love.graphics.rectangle("fill", 4, 4, panelW, panelH)

    for i, line in ipairs(lines) do
        if i == 1 then
            love.graphics.setColor(0.5, 1, 1)
        elseif line:find("HP") and player.hp <= 3 then
            love.graphics.setColor(1, 0.3, 0.3)   
        else
            love.graphics.setColor(1, 1, 1)
        end
        love.graphics.print(line, padding + 4, padding + (i - 1) * lineH + 4)
    end

    love.graphics.setColor(1, 1, 1)
end


function hud_keypressed(key)
    if gameState == "win" and key == "return" then
        gameState    = "menu"
        selectedIndex = 1
     
        grid_load()
        player_load()
    end
end