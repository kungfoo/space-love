
-- do not buffer stdout
io.stdout:setvbuf("no")

function love.conf(t)
	t.title = "A game in space."
	t.window.width = 480
	t.window.height = 800
end