require('socket')

-- hot code swap and brower debug console. awesome.
lovebird = require("lib.lovebird.lovebird")
lurker = require("lib.lurker.lurker")
lume = require("lib.lurker.lume")

-- actual libs
Signal = require("lib.hump.signal")
Class = require("lib.hump.class")
Camera = require("lib.hump.camera")
Vector = require("lib.hump.vector")

inspect = require("lib.inspect.inspect")
tick = require("lib.tick.tick")

uuid = require("lib.uuid")
uuid.seed()

lg = love.graphics

game = {}

require("game/game")
require("util")

local screen_width, screen_height = love.graphics.getDimensions()
print("screen dimensions: ".. screen_width .. ', '.. screen_height)

local scale_x = screen_width / 1920
local scale_y = screen_height / 1080
local scale = math.min(scale_x, scale_y)
print("display scale is: "..scale)

function love.load()
	Signal.clearPattern(".*")

	-- setup fixed timestepping
	tick.framerate = 60
	tick.rate = 0.016666
  	
	local crosshair = Image['crosshair.png']
	local cursor = love.mouse.newCursor(crosshair:getData(), crosshair:getWidth()/2, crosshair:getHeight()/2)
	love.mouse.setCursor(cursor)

	game.over = false
	game.paused = false

	game.gfx.initialize()
	
	game.sound.start()
	game.sound.register()

	time_update = 0
	time_collisions = 0
	time_draw = 0

	world = World()

	player = Player()
	enemies = Enemies()
	scoreboard = Scoreboard()
	modifiers = Modifiers()

	gibs = GibsSystem()
	bullets = BulletSystem()

	collisionResolver = CollisionResolver()

	camera = Camera(player.position.x, player.position.y)
	camera:zoomTo(scale)

	drawables = { enemies, modifiers, gibs, bullets, player }
	updateables = { enemies, gibs, bullets, player }
end

function love.update(dt)

	lovebird.update()
	lurker.update()

	love.graphics.setBackgroundColor(60, 60, 60)

	game.gfx.update(dt)
	game.sound.update(dt)
	scoreboard:update(dt)

	if not game.over and not game.paused then
		
		update_objects(dt)

		modifiers:apply(player)
		check_collisions()

		camera:lockPosition(player.position.x, player.position.y, Camera.smooth.damped(3))
	else
		-- update nothing
	end
end

function update_objects(dt)
	local t1 = love.timer.getTime()
	for i, object in ipairs(updateables) do
		object:update(dt)
	end
	local t2 = love.timer.getTime()

	time_update = (t2-t1) * 1000
end

function check_collisions()
	local t1 = love.timer.getTime()

	bullets:check_collisions()
	player:check_collisions()

	if player:is_dead() then
		game.over = true
	end
	
	local t2 = love.timer.getTime()
	time_collisions = (t2-t1) * 1000
end

function love.focus(focused)
	game.paused = not focused
end

function love.joystickpressed(stick, button)
	if stick:isGamepad() and button == 'y' then
		camera:zoom(0.5)
	end
end

function love.joystickreleased(stick, button)
	if stick:isGamepad() and button == 'y' then
		camera:zoom(1)
	end
end

function love.joystickaxis(stick, axis, value)
	player:joystick_axis_moved(stick, axis, value)
end

function love.draw()
	game.gfx.fx:draw(function()
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
	end)
end

function draw_game()
	local t1 = love.timer.getTime()
	camera:draw(draw_grid)
	camera:draw(draw_objects)

	scoreboard:draw()

	if game.show_debug then
		local fps = love.timer.getFPS()
		local mem = collectgarbage("count")
		local stats = ("cols: %.2fms, upd: %.2fms, drw: %.2fms, fps: %d, mem: %.2fMB, tex_mem: %.2f MB"):format(time_collisions, time_update, time_draw, fps, mem / 1024, love.graphics.getStats().texturememory / 1024 / 1024)

		love.graphics.setFont(Font[15])
		love.graphics.setColor(255, 255, 255)
		love.graphics.printf(stats, 10, love.graphics.getHeight() - 20, love.graphics.getWidth(), "left")

		local camera_stats = string.format("camera: centroid: (%d, %d)", camera:position())
		love.graphics.printf(camera_stats, -10, love.graphics.getHeight() - 20, love.graphics.getWidth(), "right")
	end
	local t2 = love.timer.getTime()
	time_draw = (t2 - t1) * 1000
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

