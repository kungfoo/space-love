do
	local ripple = require("lib/ripple/ripple")

	game.sound.tags = {
		sfx = ripple.newTag(),
		master = ripple.newTag()
	}

	game.sound.effects = {
		laser = ripple.newSound(
			"/resources/sounds/laser-shot.wav",
			{ tags = { game.sound.tags.sfx, game.sound.tags.master } }
		),
		hit = ripple.newSound(
			"/resources/sounds/laser-hit.wav",
			{ tags = { game.sound.tags.sfx, game.sound.tags.master } }
		),
	}
end