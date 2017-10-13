Player = Class {
	type = 'player',
	__includes = GameObject,
	max_health = 500,
	max_velocity = 400,
	acceleration = 1000,
	friction = 1/350,
	radius = 10
}

function Player:init(bump)
	-- initial position
	self.position = Vector(math.random(200, world.width - 200), math.random(200, world.height - 200))

	local left, top, width, height = self.position.x - Player.radius, self.position.y - Player.radius, 2 * Player.radius, 2 * Player.radius
	GameObject.init(self, bump, left, top, width, height)

	self.velocity = Vector(0,0)
	
	self.health = Player.max_health
	self.firing = false

	-- previous values of stick input
	self.left = Vector(0,0)
	self.right = Vector(0,0)

	-- current (sanitized, deadzoned) values of sticks
	self.l_stick = Vector(0,0)
	self.r_stick = Vector(0,0)

	-- start out with plasma gun
	self.weapon = Weapons.Plasma(bump)
end

function Player:move(dt)
	local left = love.keyboard.isDown('a', 'left')
	local right = love.keyboard.isDown('d', 'right')
	local up = love.keyboard.isDown('w', 'up')
	local down = love.keyboard.isDown('s', 'down')

	local delta = Vector(0,0)

	if left then delta.x = -1 end
	if right then delta.x = 1 end
	if up then delta.y = -1 end
	if down then delta.y = 1 end

	-- HACK: override keyboard with controller
	local stick_delta = self.l_stick
	if stick_delta:len() > 0 then
		delta = stick_delta
	end

	if delta:len() > 0 then
		delta:normalizeInplace()
		self.velocity = self.velocity + (delta * self.acceleration * dt)
	else
		self.velocity = self.velocity * math.pow(self.friction, dt)
	end

	self.velocity:trimInplace(self.max_velocity)

	local future_position = self.position + self.velocity * dt
	
	-- TODO: deal with filtered collisions
	local next_left, next_top, collisions, len = self.bump:move(self, future_position.x - self.radius, future_position.y - self.radius, self.filter)
	for i=1,len do
		local other = collisions[i].other
		Signal.emit("collision", self, other)
	end

	self.position = Vector(next_left + self.radius, next_top + self.radius)

	local fire = love.keyboard.isDown('space') or self.firing
	if fire and self.r_stick:len() > 0.25 then
		self.weapon:trigger(self.velocity, self.position, self.r_stick)
	end
end

function Player:filter(other)
	local type = other.type
	if type == 'enemy' then
		return 'touch'
	elseif type == 'modifier' then
		return 'cross'
	else
		return nil
	end
end

function Player:joystick_axis_moved(stick, axis, value)
	if stick:isGamepad() and axis == 1 then
		self.left.x = value
	end

	if stick:isGamepad() and axis == 2 then
		self.left.y = value
	end

	if stick:isGamepad() and axis == 4 then
		self.right.x = value
	end

	if stick:isGamepad() and axis == 5 then
		self.right.y = value
	end

	self.l_stick = Vector(self:correctStick(self.left.x, self.left.y))
	self.r_stick = Vector(self:correctStick(self.right.x, self.right.y))
end

function Player:correctStick(x, y) --raw x, y axis data from stick
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
	love.graphics.circle("fill", self.position.x, self.position.y, self.radius, 20)

	if game.debug_level == 'info' then
		game.draw_collision_box(self)
	end

	if self.r_stick:len() > 0 then
		local aimpoint = self.position + self.r_stick * 200
		love.graphics.setColor(255, 255, 255, 128)
		love.graphics.line(self.position.x, self.position.y, aimpoint.x, aimpoint.y)
	end

	if self.r_stick:len() > 0.5 then
		self.firing = true
	else
		self.firing = false
	end
end

function Player:update(dt)
	self.weapon:update(dt)
	self:move(dt)
end

function Player:hit()
	self.health = self.health - 100
	Signal.emit("player-hit")
end

-- function Player:destroy()
-- 	-- TODO: remove from bump world
-- end

function Player:is_dead()
	return self.health <= 0
end

function Player:pickup(item)
	item:apply(self)
end
