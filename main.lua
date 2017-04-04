require("lib/middleclass")
require("game/game")

function love.load()
	game.over = false
	game.gfx.initialize()

	game.sound.start()

	player = game.newPlayer()
	enemies = game.newEnemies()
	scoreboard = game.newScoreboard()
	
	drawables = { enemies, player, scoreboard }
	updateables = { enemies, player }
end

function love.update(dt)

	love.graphics.setBackgroundColor(60, 60, 60)

	game.gfx.update(dt)
	game.sound.update(dt)

	if not game.over then
		for i, object in ipairs(updateables) do
			object:update(dt)
		end

		for i, enemy in ipairs(enemies.enemies) do
			for j, bullet in ipairs(player.bullets) do
				if bullet:collides_with_enemy(enemy) then
					enemy:hit()
					scoreboard:hit()

					if enemy:is_dead() then
						enemies:remove(i)
						scoreboard:kill()
					end

					table.remove(player.bullets, j)
				end
			end

			if player:collides_with_enemy(enemy) then
				player:hit()
				enemies:remove(i)

				if player:is_dead() then
					game.over = true
				end
			end
		end
	else
		-- update nothing
	end
end

function love.focus(f)
	if not f then
		print("LOST FOCUS")
	else
		print("GAINED FOCUS")
	end
end

function love.draw()
	game.gfx.fx:draw(
		function()
			if not game.over then
				for i, object in ipairs(drawables) do
					object:draw()
				end

				if game.show_debug then
					local fps = love.timer.getFPS()
					local mem = collectgarbage("count")
					local stats = ("fps: %d, mem: %dKB"):format(fps, mem)

					love.graphics.setColor(255, 255, 255)
					love.graphics.printf(stats, 10, love.graphics.getHeight() - 20, love.graphics.getWidth(), "left")
				end
			else
				love.graphics.print("GAME OVER!", 100, 100, 0, 2, 2)
				love.graphics.print("YOU SCORED: "..scoreboard.score, 100, 150, 0, 1)
				love.graphics.print("PRESS 'R' TO RESTART.", 100, 180, 0, 1, 1)
			end
		end
	)
end

function love.keypressed(k)
	if k == "escape" then love.event.quit() end
	if k == "tab" then game.toggle_debug() end
	if k == "delete" then collectgarbage("collect") end
	if k == "r" then love.load() end
end

