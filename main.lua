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

Bump = require("lib.bump.bump")
bump_debug = require("lib.bump_debug")

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
	bump = Bump.newWorld(64)
	Signal.clearPattern(".*")

	-- setup fixed timestepping
	tick.framerate = 60
	tick.rate = 0.016666
  	
	-- local crosshair = Image['crosshair.png']
	-- local cursor = love.mouse.newCursor(crosshair:getData(), crosshair:getWidth()/2, crosshair:getHeight()/2)
	-- love.mouse.setCursor(cursor)

	game.over = false
	game.paused = false

	game.gfx.initialize()
	
	game.sound.start()
	game.sound.register()

	time_update = 0
	time_collisions = 0
	time_draw = 0

	world = World()

	player = Player(bump)
	enemies = Enemies(bump)
	scoreboard = Scoreboard()
	modifiers = Modifiers()

	gibs = GibsSystem()
	bullets = BulletSystem(bump)

	collisionResolver = CollisionResolver()

	camera = Camera(player.position.x, player.position.y, Camera.smooth.damped(3))
	camera:zoomTo(scale)

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
		
		if player:is_dead() then
			game.over = true
		end

		camera:lockPosition(player.position.x, player.position.y)
	else
		-- update nothing
	end
end

function update_objects(dt)
	local t1 = love.timer.getTime()

	-- TODO: figure out if I can get away with skipping lots of the updates
	-- local visible_items, len = bump:queryRect(get_visible_world_bounds())
	-- for i=1,len do
	-- 	visible_items[i]:update(dt)
	-- end
	for i, object in ipairs(updateables) do
		object:update(dt)
	end
	
	local t2 = love.timer.getTime()

	time_update = (t2-t1) * 1000
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
	draw_with_camera()

	scoreboard:draw()

	if game.debug_level == 'debug' or game.debug_level == 'info' then
		local fps = love.timer.getFPS()
		local mem = collectgarbage("count")
		local stats = ("obj: %d, upd: %.2fms, drw: %.2fms, fps: %d, mem: %.2fMB, tex_mem: %.2f MB"):format(bump:countItems(), time_update, time_draw, fps, mem / 1024, love.graphics.getStats().texturememory / 1024 / 1024)

		love.graphics.setFont(Font[15])
		love.graphics.setColor(255, 255, 255)
		love.graphics.printf(stats, 10, love.graphics.getHeight() - 20, love.graphics.getWidth(), "left")

		local camera_stats = string.format("camera: centroid: (%d, %d)", camera:position())
		love.graphics.printf(camera_stats, -10, love.graphics.getHeight() - 20, love.graphics.getWidth(), "right")
	end
	local t2 = love.timer.getTime()
	time_draw = (t2 - t1) * 1000
end

function draw_with_camera()
	camera:draw(draw_grid)
	if game.debug_level == 'info' then
		camera:draw(draw_bump_debug)
	end

	camera:draw(draw_objects)
end

function draw_grid()
	local step = 100
	local x = step
	local y = step

	love.graphics.setColor(game.colors.hsl(212, 100, 22, 64))

	local left, top, right, bottom = get_visible_world_bounds()

	while y < world.height do
		love.graphics.line(left, y, right, y)
		y = y + step
	end
	while x < world.width do
		love.graphics.line(x, top, x, bottom)
		x = x + step
	end
end

function draw_objects()
	local visible_items, len = bump:queryRect(get_visible_world_bounds())
	for i=1, len do
		visible_items[i]:draw()
	end
end

function get_visible_world_bounds()
	local left, top = camera:worldCoords(0,0)
	local right, bottom = camera:worldCoords(screen_width, screen_height)
	return left, top, right, bottom
end

function draw_bump_debug()
	bump_debug.draw(bump)
end

function love.keypressed(k)
	if k == "escape" then love.event.quit() end
	if k == "tab" then
		game.cycle_debug_level()
		print(string.format("Debug level is now: %s", game.debug_level))
	end
	if k == "delete" then collectgarbage("collect") end
	if k == "pause" then game.toggle_pause() end
	if k == "r" then love.load() end
	if k == "f1" then
		if tick.timescale == 1 then
			tick.timescale = 0.5
		else
			tick.timescale = 1
		end
	end
end

