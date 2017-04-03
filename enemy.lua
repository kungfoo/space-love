
function game.newEnemy()
	local Enemy = {
		
		x = math.random(10, love.graphics.getWidth() - 10),
		y = 0,

		health = 100,
		speed = 200
	}

	function Enemy:draw()
		love.graphics.rectangle("fill", self.x, self.y, 10, 10)
	end

	function Enemy:update(dt)
		self.y = self.y + self.speed * dt
	end

	function Enemy:is_offscreen()
		return self.y > love.graphics.getHeight() + 10
	end
	
	return Enemy
end
