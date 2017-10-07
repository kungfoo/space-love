
-- do not buffer stdout
io.stdout:setvbuf("no")

function love.conf(t)
	t.title = "A game in space."
	t.window.width = 1920
	t.window.height = 1080

	t.window.vsync = true
	t.window.msaa = 2
	t.window.highdrpi = false

	t.window.fullscreen = false
	t.window.fullscreentype = 'desktop'
	t.window.resizable = false


	t.modules.physics = false
end