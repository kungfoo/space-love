
love.window.setMode(love.graphics.getWidth(), love.graphics.getHeight(), {
	vsync = true,
	msaa = 8
})

success = love.window.setFullscreen(false, 'exclusive')

math.randomseed(os.time())

game = {
	colors = {},
	math = {},
	show_debug = false,
	sound = {},
	gfx = {},

	over = false
}

require("game.sound")
require("gfx.post")

function game.check_collision(x1, y1, w1, h1, x2, y2, w2, h2)
	return 	x1 < x2+w2 and
			x2 < x1+w1 and
			y1 < y2+h2 and
			y2 < y1+h1
end

function game.toggle_debug()
	game.show_debug = not game.show_debug
end

function game.toggle_pause()
	game.paused = not game.paused
end

require("game.scoreboard")
require("game.gibs")
require("game.player")
require("game.bullet")
require("game.enemies")


