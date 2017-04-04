
love.window.setMode(love.graphics.getWidth(), love.graphics.getHeight(), {
	vsync = false,
	msaa = 8
})

math.randomseed(os.time())

game = {
	colors = {},
	math = {},
	show_debug = false,
	sound = {},
	gfx = {},

	over = false
}

require("game.sound")
require("gfx.post")

function game.check_collision(x1, y1, w1, h1, x2, y2, w2, h2)
	return 	x1 < x2+w2 and
			x2 < x1+w1 and
			y1 < y2+h2 and
			y2 < y1+h1
end

function game.toggle_debug()
	game.show_debug = not game.show_debug
end

-- convert hsv values to rgb
function game.colors.hsv(h, s, v)
	if s <= 0 then return v,v,v end
    
    h, s, v = h/360*6, s/100, v/100
    local c = v*s
    local x = (1-math.abs((h%2)-1))*c
    local m,r,g,b = (v-c), 0,0,0
    
    if h < 1     then r,g,b = c,x,0
    elseif h < 2 then r,g,b = x,c,0
    elseif h < 3 then r,g,b = 0,c,x
    elseif h < 4 then r,g,b = 0,x,c
    elseif h < 5 then r,g,b = x,0,c
    else              r,g,b = c,0,x
    
    end return (r+m)*255,(g+m)*255,(b+m)*255
end

-- convert hsl values to rgb
function game.colors.hsl(h, s, l, a)
	if s<=0 then return l,l,l,a end
	
	h, s, l = h/360*6, s/100, l/100
	local c = (1-math.abs(2*l-1))*s
	local x = (1-math.abs(h%2-1))*c
	local m,r,g,b = (l-.5*c), 0,0,0
	
	if h < 1     then r,g,b = c,x,0
	elseif h < 2 then r,g,b = x,c,0
	elseif h < 3 then r,g,b = 0,c,x
	elseif h < 4 then r,g,b = 0,x,c
	elseif h < 5 then r,g,b = x,0,c
	else              r,g,b = c,0,x
	
	end return (r+m)*255,(g+m)*255,(b+m)*255,a
end

function game.math.clamp(value, min, max)
	return math.max(min, math.min(max, value))
end

require("game.scoreboard")
require("game.player")
require("game.bullet")
require("game.enemies")


