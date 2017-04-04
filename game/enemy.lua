
function game.newEnemy()
	
	local Enemy = {
		
		x = math.random(10, love.graphics.getWidth() - 10),
		y = 0,

		width = 20,
		height = 20,

		health = math.random(30, 100),

		speed = math.random(50, 100) + 50,

		slow_down = 20,
		speed_up = 20
	}

	function Enemy:draw()
		love.graphics.setColor(self:color())
		love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
	end

	function Enemy:color()
		local hue = (self.health/100) * 360
		local alpha = ((self.health/100) * 200) + 55

		return game.colors.hsl(hue, self.health, 50, alpha)
	end

	function Enemy:update(dt)
		self.y = self.y + self.speed * dt
		self.speed = self.speed + self.speed_up * dt
	end

	function Enemy:is_offscreen()
		return self.y > love.graphics.getHeight() + 10
	end

	function Enemy:hit()
		self.health = self.health - 10
		self.speed = self.speed - self.slow_down

		game.sound.effects.hit_enemy:play({
			pitch = 0.5*math.random() + 0.7
		})
	end

	function Enemy:is_dead()
		return self.health <= 0
	end
	
	return Enemy
end
