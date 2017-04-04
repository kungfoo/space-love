function game.newPlayer()
	local Player = {
		-- initial position
		x = 240,
		y = 720,
		canFire = true,
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
			local bullet = game.newBullet(self.x, self.y)
			
			table.insert(self.bullets, bullet)
			self.canFire = false
			self.firingTimer = 0.2
		end
	end

	function Player:draw()
		for i, bullet in ipairs(self.bullets) do
			bullet:draw()
		end

		love.graphics.setColor(255, 255, 255)
		love.graphics.circle("fill", Player.x, Player.y, 10)
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
		return false
	end

	function Player:hit()
		self.health = self.health - 20
	end

	function Player:is_dead()
		return self.health <= 0
	end

	return Player
end