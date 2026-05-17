local multiplayer  = require("Code.Scripts.ScriptStates.StateMultiPlayer.multiplayerMenu")
local options      = require("Code.Scripts.ScriptStates.StateSettings.settingsMenu")
local about        = require("Code.Scripts.ScriptStates.StateAbout.aboutMenu")
local singleplayer = require("Code.Scripts.ScriptStates.StateSinglePlayer.singlePlayerMenu")
local exit_state   = require("Code.Scripts.ScriptStates.StateExit.exitMenu")
local Fonts        = require("Code.Scripts.ScriptUtil.fonts")

local menu = {}

local states    = {}
local menuItems = {}

local fntTitle    -- PixelFraktur — game title
local fntItem     -- FindersKeepers — menu items

-- ---------------------------------------------------------------------------
function menu.load()
    gameState     = "menu"
    selectedIndex = 1

    local CF = Config.fonts
    fntTitle = Fonts.title(CF.menuTitle)
    fntItem  = Fonts.body(CF.menuItem)

    menuItems = {
        { text = "Single Player", state = "singleplayer" },
        { text = "Multiplayer",   state = "multiplayer"  },
        { text = "Options",       state = "options"      },
        { text = "About",         state = "about"        },
        { text = "Exit",          state = "exit"         },
    }

    states = {
        singleplayer = singleplayer,
        loading      = singleplayer,   -- "loading" gameState routes to singleplayer's draw/update
        multiplayer  = multiplayer,
        options      = options,
        about        = about,
        exit         = exit_state,
    }
end

function menu.getState(name)
    return states[name]
end

-- ---------------------------------------------------------------------------
function menu.update(dt)
    local state = states[gameState]
    if state and state.update then state.update(dt) end
end

-- ---------------------------------------------------------------------------
function menu.keypressed(key)
    if gameState ~= "menu" then
        local state = states[gameState]
        if state and state.keypressed then state.keypressed(key) end
        return
    end

    if key == "down" then
        selectedIndex = (selectedIndex % #menuItems) + 1
    elseif key == "up" then
        selectedIndex = (selectedIndex - 2) % #menuItems + 1
    elseif key == "return" then
        local chosen = menuItems[selectedIndex].state
        local state  = states[chosen]
        if not state then return end
        if state.load  then state.load()  end
        if state.enter then state.enter() end
    end
end

-- ---------------------------------------------------------------------------
function menu.draw()
    local sw = love.graphics.getWidth()
    local sh = love.graphics.getHeight()

    if gameState ~= "menu" then
        local state = states[gameState]
        if state and state.draw then
            love.graphics.setFont(fntItem)
            love.graphics.setColor(1, 1, 1)
            state.draw(sw, sh)
        end
        return
    end

    -- Game title (PixelFraktur)
    love.graphics.setFont(fntTitle)
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("BlindScribe", 0, 80, sw, "center")

    -- Menu items (FindersKeepers)
    love.graphics.setFont(fntItem)
    local itemH = Config.fonts.menuItem + 16
    for i, item in ipairs(menuItems) do
        local y = 200 + (i - 1) * itemH
        if i == selectedIndex then
            love.graphics.setColor(1, 1, 0)
            love.graphics.printf("> " .. item.text, 0, y, sw, "center")
        else
            love.graphics.setColor(1, 1, 1)
            love.graphics.printf(item.text, 0, y, sw, "center")
        end
    end
end

return menu
