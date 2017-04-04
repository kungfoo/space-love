
-- do not buffer stdout
io.stdout:setvbuf("no")

function love.conf(t)
	t.title = "Can has animated player"
	t.window.width = 480
	t.window.height = 800
end