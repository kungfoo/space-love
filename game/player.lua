function game.newPlayer()
	local Player = {
		-- initial position
		x = world.width/2,
		y = world.height/2,

		radius = 10,

		canFire = true,

		max_health = 500,
		health = 500,

		-- other values
		speed = 350,
		firingTimer = 0.15,

		firing = false,

		-- previous values of stick input
		leftx = 0,
		lefty = 0,

		-- current values of movement
		stickx = 0,
		sticky = 0,

		bullets = {}
	}

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

		if fire and self.canFire then
			self:fire_bullet()
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

		self.stickx, self.sticky = correctStick(self.leftx, self.lefty)
	end


	function correctStick( x, y ) --raw x, y axis data from stick
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

	function Player:fire_bullet()
		local bullet = Bullet(self.x, self.y)
		
		table.insert(self.bullets, bullet)
		self.canFire = false
		self.firingTimer = 0.15

		Signal.emit("player-shot-fired")
	end

	function Player:draw()
		for i, bullet in ipairs(self.bullets) do
			bullet:draw()
		end

		love.graphics.setColor(255, 255, 255)
		love.graphics.circle("fill", self.x, self.y, self.radius)
	end

	function Player:update(dt)
		
		self.firingTimer = self.firingTimer - dt * 1
		
		if self.firingTimer < 0 then
			self.canFire = true
		end

		for i, bullet in ipairs(self.bullets) do
			bullet:update(dt)

			if bullet:is_offscreen() then
				table.remove(self.bullets, i)
			end
		end

		Player:move(dt)
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

	return Player
end