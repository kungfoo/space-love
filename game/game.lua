math.randomseed(os.time())

Game = {}

game = {
	show_debug = false,
	sound = {},
	gfx = {},

	over = false
}

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

function game.running_on_desktop()
	return not game.running_on_mobile()
end

function game.running_on_mobile()
	return love.system.getOS() == 'iOS' or love.system.getOS() == 'Android'
end


require("gfx.post")

require("game.objects")
require("game.collision_layers")
require("game.sound")
require("game.scoreboard")
require("game.world")
require("game.collision_resolver")
require("game.modifiers")
require("game.gibs")
require("game.player")
require("game.bullets")
require("game.weapons")
require("game.enemies")


