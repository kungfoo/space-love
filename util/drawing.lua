function game.graphics.rotated_rectangle( mode, x, y, w, h, rx, ry, segments, r, ox, oy )
	-- Check to see if you want the rectangle to be rounded or not:
	if not oy and rx then r, ox, oy = rx, ry, segments end
	-- Set defaults for rotation, offset x and y
	r = r or 0
	ox = ox or w / 2
	oy = oy or h / 2

	love.graphics.push()
	
	love.graphics.translate( x + ox, y + oy )
	love.graphics.rotate( -r )
	
	love.graphics.rectangle(mode, -ox, -oy, w, h, rx, ry, segments)
	
	love.graphics.pop()
end