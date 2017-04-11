
-- do not buffer stdout
io.stdout:setvbuf("no")

function love.conf(t)
	t.title = "A game in space."
	t.window.width = 1920
	t.window.height = 1080

	t.window.vsync = false
	t.window.msaa = 4
	t.window.highdrpi = false

	t.window.fullscreen = false
	t.window.fullscreentype = 'desktop'


	t.modules.physics = false
end