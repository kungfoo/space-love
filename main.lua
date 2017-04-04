require("lib/middleclass")
require("game/game")

function love.load()
	game.gfx.initialize()

	player = game.newPlayer()
	enemies = game.newEnemies()
	
	drawables = { enemies, player }
	updateables = { enemies, player }
end

function love.update(dt)

	game.gfx.update(dt)

	for i, object in ipairs(updateables) do
		object:update(dt)
	end

	for i, enemy in ipairs(enemies.enemies) do
		for j, bullet in ipairs(player.bullets) do
			if bullet:collides_with_enemy(enemy) then
				enemy:hit()
				if enemy:is_dead() then
					enemies:increase_kill_count()
					table.remove(enemies.enemies, i)
				end

				table.remove(player.bullets, j)
			end
		end

		if player:collides_with_enemy(enemy) then
			player:hit()
			if player:is_dead() then
				-- todo: end the game here...
			end
		end
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
	game.gfx.fx:draw(function()
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
	end)
end

function love.keypressed(k)
	if k == "escape" then love.event.quit() end
	if k == "tab" then game.toggle_debug() end
	if k == "delete" then collectgarbage("collect") end
end

