
Enemy = Class {
	width = 20,
	height = 20,
	slow_down = 20,
	speed_up = 20,

	mass = 100,
	friction = 1/100
}

function Enemy:init(position)
	self.position = position
	self.health = math.random(30, 110)
	self.velocity = Vector(0, 0)
end

function Enemy:draw()
	love.graphics.setColor(self:color())
	love.graphics.rectangle("fill", self.position.x, self.position.y, self.width, self.height)
end

function Enemy:color()
	local hue = (self.health/100) * 360
	local alpha = ((self.health/100) * 200) + 55

	return game.colors.hsl(hue, 50, 50, alpha)
end

function Enemy:update(dt)
	self.position = self.position + self.velocity * dt
	self.velocity = self.velocity * math.pow(self.friction, dt)
end

function Enemy:is_offscreen()
	return world:out_of_bounds(self.position)
end

function Enemy:hit(bullet)
	self.health = self.health - bullet.damage
	-- vollkommen elasticher stoss:
	self.velocity = ((self.mass - bullet.mass) * self.velocity + 2 * bullet.mass * bullet.velocity) / (self.mass + bullet.mass)
	
	Signal.emit("enemy-hit")

	if self:is_dead() then
		Signal.emit("enemy-killed", self.position)
	end
end

function Enemy:is_dead()
	return self.health <= 0
end
