
Signal = require("lib.hump.signal")
Class = require("lib.hump.class")
Camera = require("lib.hump.camera")

inspect = require("lib.inspect.inspect")

game = {}

require("game/game")
require("util")

function love.load()

	local crosshair = Image['crosshair.png']
	cursor = love.mouse.newCursor(crosshair:getData(), crosshair:getWidth()/2, crosshair:getHeight()/2)
	love.mouse.setCursor(cursor)


	game.over = false
	game.paused = false

	game.gfx.initialize()
	game.sound.start()

	world = {
		width = 6000,
		height = 4000
	}

	player = Player()
	enemies = Enemies()
	scoreboard = Scoreboard()

	gibs = GibsSystem()
	bulletSystem = BulletSystem()

	camera = Camera(player.x, player.y)

	drawables = { enemies, gibs, bulletSystem, player }
	updateables = { enemies, gibs, bulletSystem, player }
end

function love.update(dt)

	love.graphics.setBackgroundColor(60, 60, 60)

	game.gfx.update(dt)
	game.sound.update(dt)

	scoreboard:update(dt)

	if not game.over and not game.paused then
		for i, object in ipairs(updateables) do
			object:update(dt)
		end

		for i, enemy in ipairs(enemies.enemies) do

			bulletSystem:check_collision(enemy)

			if player:collides_with_enemy(enemy) then
				player:hit()
				Signal.emit("enemy-killed", enemy.x, enemy.y)
				enemies:remove(i)

				if player:is_dead() then
					game.over = true
				end
			end

			camera:lockPosition(player.x, player.y, Camera.smooth.damped(1))
		end
	else
		-- update nothing
	end
end

function love.focus(f)
	if not f then
		game.paused = true
	else
		game.paused = false
	end
end

function love.joystickpressed(stick, button)
	player:joystick_pressed(stick, button)

	if stick:isGamepad() and button == 'y' then
		camera:zoomTo(0.5)
	end
end

function love.joystickreleased(stick, button)
	player:joystick_released(stick, button)

	if stick:isGamepad() and button == 'y' then
		camera:zoomTo(1)
	end
end

function love.joystickaxis(stick, axis, value)
	player:joystick_axis_moved(stick, axis, value)
end

function love.draw()
	game.gfx.fx:draw(
		function()
			if not game.over and not game.paused then
				draw_game()

			elseif game.paused and not game.over then
				love.graphics.setFont(Font[20])
				love.graphics.print("PAUSED", 100, 100)

			else
				love.graphics.setFont(Font[40])
				love.graphics.print("GAME OVER!", 100, 100)

				love.graphics.setFont(Font[20])
				love.graphics.print("YOU SCORED: "..scoreboard.score, 100, 150)
				love.graphics.print("PRESS 'R' TO RESTART.", 100, 180)
			end
		end
	)
end

function draw_game()
	camera:draw(draw_grid)
	camera:draw(draw_objects)

	scoreboard:draw()

	if game.show_debug then
		local fps = love.timer.getFPS()
		local mem = collectgarbage("count")
		local stats = ("fps: %d, mem: %dKB, tex_mem: %.3f MB, cam: (%.3f, %.3f)"):format(fps, mem, love.graphics.getStats().texturememory / 1024 / 1024, camera:position())

		love.graphics.setFont(Font[15])
		love.graphics.setColor(255, 255, 255)
		love.graphics.printf(stats, 10, love.graphics.getHeight() - 20, love.graphics.getWidth(), "left")
	end
end

function draw_grid()

	local step = 100
	local x = step
	local y = step

	love.graphics.setColor(game.colors.hsl(212, 100, 22))
	while y < world.height do
		love.graphics.line(0, y, world.width, y)
		y = y + step
	end
	while x < world.width do
		love.graphics.line(x, 0, x, world.height)
		x = x + step
	end
end

function draw_objects()
	for i, object in ipairs(drawables) do
		object:draw()
	end
end

function love.keypressed(k)
	if k == "escape" then love.event.quit() end
	if k == "tab" then game.toggle_debug() end
	if k == "delete" then collectgarbage("collect") end
	if k == "pause" then game.toggle_pause() end
	if k == "r" then love.load() end
end

