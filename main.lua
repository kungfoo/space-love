
Signal = require("lib.hump.signal")
Class = require("lib.hump.class")
Camera = require("lib.hump.camera")
Vector = require("lib.hump.vector")

HC = require("lib.HC")

inspect = require("lib.inspect.inspect")

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
	if arg[#arg] == "-debug" then require("mobdebug").start() end
  
	local crosshair = Image['crosshair.png']
	cursor = love.mouse.newCursor(crosshair:getData(), crosshair:getWidth()/2, crosshair:getHeight()/2)
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
	bulletSystem = BulletSystem()

	collisionResolver = CollisionResolver()

	camera = Camera(player.position.x, player.position.y)
	camera:zoomTo(scale)

	drawables = { enemies, modifiers, gibs, bulletSystem, player }
	updateables = { enemies, gibs, bulletSystem, player }
end

-- provide custom run for physics timestepping for now. 
function love.run()
 
	if love.math then
		love.math.setRandomSeed(os.time())
	end
 
	if love.load then love.load(arg) end
 
	-- We don't want the first frame's dt to include time taken by love.load.
	if love.timer then love.timer.step() end
 
	local dt = 0
 
	-- Main loop time.
	while true do
		-- Process events.
		if love.event then
			love.event.pump()
			for name, a,b,c,d,e,f in love.event.poll() do
				if name == "quit" then
					if not love.quit or not love.quit() then
						return a
					end
				end
				love.handlers[name](a,b,c,d,e,f)
			end
		end
 
		-- Update dt, as we'll be passing it to update
		if love.timer then
			love.timer.step()
			-- at most, simulate 1/60 of a second
			dt = math.min(love.timer.getDelta(), 0.016666)
		end
 
		-- Call update and draw
		if love.update then love.update(dt) end -- will pass 0 if love.timer is disabled
 
		if love.graphics and love.graphics.isActive() then
			love.graphics.clear(love.graphics.getBackgroundColor())
			love.graphics.origin()
			if love.draw then love.draw() end
			love.graphics.present()
		end
 
		if love.timer then love.timer.sleep(0.002) end
	end
end

function love.update(dt)

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

	bulletSystem:check_collisions()
	player:check_collisions()

	if player:is_dead() then
		game.over = true
	end
	
	local t2 = love.timer.getTime()
	time_collisions = (t2-t1) * 1000
end

function love.focus(f)
	if not f then
		game.paused = true
	else
		game.paused = false
	end
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

