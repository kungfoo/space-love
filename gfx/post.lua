do
	local shine = require("lib/shine")

	game.gfx.chroma_timer = 0.5

	game.gfx.update = function(dt)
		game.gfx.chroma_timer = game.gfx.chroma_timer - dt * 1

		if game.gfx.chroma_timer < 0 then
			game.gfx.chroma.radius = math.random(2, 3)
			game.gfx.chroma_timer = math.random(0.1, 0.5)
		end
	end

	game.gfx.initialize = function()

		local separate_chroma = shine.separate_chroma()
		separate_chroma.radius = 2.5
		separate_chroma.angle = 45

		local grain = shine.filmgrain()
		grain.opacity = 0.2
		-- grain.patch_size = 256

		local crt = shine.crt()
		crt.outline = {100,90,105}
		crt.x = 0.02
		crt.y = 0.02

		local desaturate = shine.desaturate{strength = 0.2, tint = {255,250,200}}

		game.gfx.chroma = separate_chroma

		game.gfx.fx =
			separate_chroma:
			chain(desaturate):
			chain(grain):
			-- chain(desaturate):
			chain(crt)
	end
end