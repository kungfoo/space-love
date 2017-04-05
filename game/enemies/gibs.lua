
Enemies.Gibs = Class { }
Enemies.Gibs.Particle = Class { }

function Enemies.Gibs:init(x, y)
	self.visible_timer = 5
	self.particles = self:create_particles(x,y)
end

function Enemies.Gibs:create_particles(x, y)
	local p = {}

	for i = 1, math.random(24, 32) do
		table.insert(p, Enemies.Gibs.Particle(x, y))
	end
	return p
end

function Enemies.Gibs:draw()
	for _, particle in ipairs(self.particles) do
		particle:draw(self.visible_timer / 5)
	end
end

function Enemies.Gibs:update(dt)
	for _, particle in ipairs(self.particles) do
		particle:update(dt)
	end
	self.visible_timer = self.visible_timer - 2 * dt
end

function Enemies.Gibs.Particle:init(x, y)
	local initial_speed = 70

	self.x = x
	self.y = y
	self.hue = math.random(30, 260)
	self.vm = { math.random(-initial_speed, initial_speed), math.random(-initial_speed, initial_speed) }
end

function Enemies.Gibs.Particle:draw(timer_scaled)
	love.graphics.setColor(game.colors.hsl(self.hue, 50, 50, timer_scaled * 255))
	love.graphics.rectangle("fill", self.x, self.y, timer_scaled * 10, timer_scaled * 10)
end

function Enemies.Gibs.Particle:update(dt)
	-- update position
	self.x = self.x + dt * self.vm[1]
	self.y = self.y + dt * self.vm[2]

	-- slow down
	self.vm[1] = self.vm[1] + (dt * (-self.vm[1]))
	self.vm[2] = self.vm[2] + (dt * (-self.vm[2]))
end
