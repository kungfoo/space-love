function game.newPlayer()
	local Player = {
		-- initial position
		x = 240,
		y = 720,

		radius = 10,

		canFire = true,

		max_health = 500,
		health = 500,

		-- other values
		speed = 200,
		firingTimer = 0.2,

		bullets = {}
	}

	function Player:move(dt)
		local left = love.keyboard.isDown('a', 'left')
		local right = love.keyboard.isDown('d', 'right')

		if left then
			self.x = math.max(0, self.x - self.speed * dt)
		elseif right then
			self.x = math.min(love.graphics.getWidth(), self.x + self.speed * dt)
		end

		local fire = love.keyboard.isDown('space')

		if fire and self.canFire then
			self:fire_bullet()
		end
	end

	function Player:fire_bullet()
		local bullet = game.newBullet(self.x, self.y)
		
		table.insert(self.bullets, bullet)
		self.canFire = false
		self.firingTimer = 0.2

		game.sound.effects.laser:play({
			pitch = 0.5*math.random() + 2
		})
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
		game.sound.effects.ship_hit:play({
			pitch = 0.5*math.random() + 1
		})
	end

	function Player:is_dead()
		return self.health <= 0
	end

	return Player
end