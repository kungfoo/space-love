function game.newPlayer()
	local Player = {
		x = 240,
		y = 720,

		speed = 200
	}

	function Player:move(dt)
		local left = love.keyboard.isDown('a', 'left')
		local right = love.keyboard.isDown('d', 'right')
		
		if left then
			self.x = math.max(0, self.x - self.speed * dt)
		elseif right then
			self.x = math.min(love.graphics.getWidth(), self.x + self.speed * dt)
		end
	end

	function Player:draw()
		love.graphics.circle("fill", Player.x, Player.y, 10)
	end

	function Player:update(dt)
		Player:move(dt)
	end

	return Player
end