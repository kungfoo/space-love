function game.newBullet(a, b)
	local Bullet = {
		x = a,
		y = b,

		width = 4,
		height = 10
	}
	
	function Bullet:draw()
		love.graphics.setColor(255, 153, 0)
		love.graphics.rectangle("fill", (self.x - self.width/2), self.y, self.width, self.height)
	end

	function Bullet:update(dt)
		self.y = self.y - dt * 300
	end

	function Bullet:is_offscreen()
		return self.y < - 20
	end

	function Bullet:collides_with_enemy(enemy)
		return game.check_collision(enemy.x, enemy.y, enemy.width, enemy.height,
									self.x,  self.y,  self.width,  self.height)
	end
	
	return Bullet
end