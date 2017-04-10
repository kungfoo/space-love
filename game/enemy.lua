
Enemy = Class {
	width = 20,
	height = 20,
	slow_down = 20,
	speed_up = 20
}

function Enemy:init()
	self.x = math.random(10, world.width - 10)
	self.y = 0

	self.health = math.random(30, 110)

	self.speed = math.random(50, 100) + 50
end

function Enemy:draw()
	love.graphics.setColor(self:color())
	love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
end

function Enemy:color()
	local hue = (self.health/100) * 360
	local alpha = ((self.health/100) * 200) + 55

	return game.colors.hsl(hue, 50, 50, alpha)
end

function Enemy:update(dt)
	self.y = self.y + self.speed * dt
	self.speed = self.speed + self.speed_up * dt
end

function Enemy:is_offscreen()
	return self.y > world.height + 10
end

function Enemy:hit()
	self.health = self.health - 10
	self.speed = self.speed - self.slow_down
	Signal.emit("enemy-hit")

	if self:is_dead() then
		Signal.emit("enemy-killed", self.x, self.y)
	end
end

function Enemy:is_dead()
	return self.health <= 0
end
