local exit_state = {}

function exit_state.enter()
	gameState = "exit"
end

function exit_state.keypressed(key)
	if key == "return" then
		love.event.quit()
	elseif key == "escape" then
		gameState = "menu"
		selectedIndex = 1
	end
end

function exit_state.draw(sw, sh)
	love.graphics.printf("Press ENTER to quit\nESC to cancel", 0, sh/2, sw, "center")
end

return exit_state