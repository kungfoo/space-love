
function love.load()
	require("game")
	require("player")
	require("bullet")
	require("enemies")

	zap = love.graphics.newImage("resources/images/zap.png")

	player = game.newPlayer()
	enemies = game.newEnemies()
	
	drawables = { enemies, player }
	updateables = { enemies, player }
end

function love.update(dt)
	escape = love.keyboard.isDown('escape')
	if escape then
		love.event.push('quit')
	end

	for i, object in ipairs(updateables) do
		object:update(dt)
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
	for i, object in ipairs(drawables) do
		object:draw()
	end
end