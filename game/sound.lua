do
	local ripple = require("lib/ripple/ripple")

	game.sound.updated = {}

	game.sound.tags = {
		sfx = ripple.newTag(),
		master = ripple.newTag()
	}

	game.sound.effects = {
		plasma = ripple.newSound(
			"/resources/sounds/plasma_shot.ogg",
			{ tags = { game.sound.tags.sfx, game.sound.tags.master } }
		),
		laser = ripple.newSound(
			"/resources/sounds/laser_shot.ogg",
			{ tags = { game.sound.tags.sfx, game.sound.tags.master } }
		),
		hit_enemy = ripple.newSound(
			"/resources/sounds/digital_hit.ogg",
			{ tags = { game.sound.tags.sfx, game.sound.tags.master } }
		),
		ship_hit = ripple.newSound(
			"/resources/sounds/metal_hit.ogg",
			{ tags = { game.sound.tags.sfx, game.sound.tags.master } }
		),
	}

	game.sound.music = {
		background_1 = ripple.newSound(
			"/resources/sounds/background_1.ogg",
			{
				tags = { game.sound.tags.master },
				mode = "stream",
				loop = true
			}
		)
	}

	game.sound.start = function()
		music = game.sound.music.background_1:play()
		table.insert(game.sound.updated, music)
	end

	game.sound.update = function(dt)
		for i, sound in ipairs(game.sound.updated) do
			sound:update(dt)
		end
	end

	-- set up ripple audio
	game.sound.tags.master:setVolume(1)
	game.sound.tags.sfx:setVolume(0.5)

	game.sound.effects.laser.volume.v = 0.1
	game.sound.effects.plasma.volume.v = 0.1
	game.sound.effects.hit_enemy.volume.v = 0.6
	game.sound.effects.ship_hit.volume.v = 0.5

	-- signals that trigger sounds
	Signal.register("plasma-shot-fired", function()
		game.sound.effects.plasma:play({
			pitch = 0.5*math.random() + 2
		})
	end)

	Signal.register("player-hit", function()
		game.sound.effects.ship_hit:play({
			pitch = 0.5*math.random() + 1
		})
	end)

	Signal.register("enemy-killed", function()
		game.sound.effects.ship_hit:play({
			pitch = 0.9*math.random() + 0.5
		})
	end)

	Signal.register("enemy-hit", function()
		game.sound.effects.hit_enemy:play({
			pitch = 0.5*math.random() + 0.7
		})
	end)

end