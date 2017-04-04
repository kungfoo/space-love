
function game.newEnemy()
	
	Enemy = {
		
		x = math.random(10, love.graphics.getWidth() - 10),
		y = 0,

		width = 20,
		height = 20,

		health = math.random(30, 100),

		speed = 150
	}

	function Enemy:draw()
		love.graphics.setColor(self:color())
		love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
	end

	function Enemy:color()
		local hue = (self.health/100) * 360
		local alpha = (self.health/100) * 255

		return game.colors.hsl(hue, self.health, 50, alpha)
	end

	function Enemy:update(dt)
		self.y = self.y + self.speed * dt
	end

	function Enemy:is_offscreen()
		return self.y > love.graphics.getHeight() + 10
	end

	function Enemy:hit()
		self.health = self.health - 10
	end

	function Enemy:is_dead()
		return self.health <= 0
	end
	
	return Enemy
end
