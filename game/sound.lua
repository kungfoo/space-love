do
	local ripple = require("lib/ripple/ripple")

	game.sound.updated = {}

	game.sound.tags = {
		sfx = ripple.newTag(),
		master = ripple.newTag()
	}

	game.sound.effects = {
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
	game.sound.effects.hit_enemy.volume.v = 1
end