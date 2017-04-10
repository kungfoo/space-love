Player = Class {
	max_health = 500,
	speed = 350,
	radius = 10
}

function Player:init()
	-- initial position
	self.x = math.random(200, world.width)
	self.y = math.random(300, world.height)
	
	self.health = Player.max_health
	self.firing = false

	-- previous values of stick input
	self.leftx = 0
	self.lefty = 0

	-- current values of movement
	self.stickx = 0
	self.sticky = 0

	-- start out with plasma gun
	self.weapon = Weapons.Plasma()
end

function Player:move(dt)
	local left = love.keyboard.isDown('a', 'left')
	local right = love.keyboard.isDown('d', 'right')

	if left then
		self.x = math.max(0, self.x - self.speed * dt)
	elseif right then
		self.x = math.min(world.width, self.x + self.speed * dt)
	end

	-- this will yield problems, when both keyboard and gamepad are used.
	self.x = game.math.clamp(self.x + self.stickx * (self.speed * dt), 0, world.width)
	self.y = game.math.clamp(self.y + self.sticky * (self.speed * dt), 0, world.height)

	local fire = love.keyboard.isDown('space') or self.firing
	if fire then
		self.weapon:trigger(dt)
	end
end

function Player:joystick_pressed(stick, button)
	if stick:isGamepadDown('a') then
		self.firing = true
	end
end

function Player:joystick_released(stick, button)
	if not stick:isGamepadDown('a') then
		self.firing = false
	end
end

function Player:joystick_axis_moved(stick, axis, value)
	-- print(("stick: %s, axis: %s, value: %s"):format(stick, axis, value))
	if stick:isGamepad() and axis == 1 then
		self.leftx = value
	end

	if stick:isGamepad() and axis == 2 then
		self.lefty = value
	end

	self.stickx, self.sticky = self:correctStick(self.leftx, self.lefty)
end


function Player:correctStick( x, y ) --raw x, y axis data from stick
	local inDZ, outDZ = 0.25, 0.1 --deadzones

	local len = math.sqrt ( x * x + y * y )
	
	if len <= inDZ
		then x, y = 0, 0
	elseif len + outDZ >= 1 then
		x, y = x / len, y / len
	else
		len = ( len - inDZ ) / ( 1 - inDZ - outDZ )
 		x, y = x * len, y * len
 	end
	return x, y -- corrected input that you can use directly in transformations
end

function Player:draw()
	love.graphics.setColor(255, 255, 255)
	love.graphics.circle("fill", self.x, self.y, self.radius)
end

function Player:update(dt)
	self.weapon:update(dt)
	self:move(dt)
end

function Player:collides_with_enemy(enemy)
	-- closest points of rectangle
	local cx = game.math.clamp(self.x, enemy.x, enemy.x + enemy.width)
	local cy = game.math.clamp(self.y, enemy.y, enemy.y + enemy.height)
	
	-- distances to that point
	local dx = self.x - cx
	local dy = self.y - cy

	local d2 = dx*dx + dy*dy

	return d2 < math.pow(self.radius, 2)
end

function Player:hit()
	self.health = self.health - 100
	Signal.emit("player-hit")
end

function Player:is_dead()
	return self.health <= 0
end
