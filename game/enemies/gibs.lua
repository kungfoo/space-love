
Enemies.Gibs = Class {
	__includes = GameObject
}

Enemies.Gibs.Particle = Class {
	min_ttl = 2,
	max_ttl = 4,
	initial_speed = 300
}

function Enemies.Gibs:init(x, y)
	local ttl = math.random(Enemies.Gibs.Particle.min_ttl, Enemies.Gibs.Particle.max_ttl)
	GameObject.init(self, bump, x, y, 1, 1)
	self.particles = self:create_particles(x, y, ttl)
end

function Enemies.Gibs:create_particles(x, y, ttl)
	local p = {}

	for i = 1, math.random(24, 32) do
		table.insert(p, Enemies.Gibs.Particle(x, y, ttl, Enemies.Gibs.Particle.initial_speed))
	end

	for i = 1, math.random(6, 24) do
		table.insert(p, Enemies.Gibs.Particle(x, y, ttl, Enemies.Gibs.Particle.initial_speed * 3))
	end

	return p
end

function Enemies.Gibs:update(dt)
	for _, particle in ipairs(self.particles) do
		particle:update(dt)
	end
end

function Enemies.Gibs:draw()
	for _, particle in ipairs(self.particles) do
		particle:draw()
	end
end

function Enemies.Gibs:is_alive()
	return self.particles[1].ttl_timer > 0
end

function Enemies.Gibs.Particle:init(x, y, ttl, speed)
	self.ttl, self.ttl_timer = ttl, ttl
	self.position = Vector(x,y)
	self.velocity = Vector(math.random()-0.5, math.random()-0.5) * speed
	self.hue = math.random(5, 50)
end

function Enemies.Gibs.Particle:draw()
	lg.setColor(game.colors.hsl(self.hue, 80, 50,  self.ttl_timer / self.ttl * 255))
	local size = self.ttl_timer / self.ttl * 10
	lg.rectangle("fill", self.position.x, self.position.y, size, size)
end

function Enemies.Gibs.Particle:update(dt)
	self.position = self.position + dt * self.velocity
	self.ttl_timer = self.ttl_timer - 2 * dt
	-- slow down
	self.velocity = self.velocity + (dt * -self.velocity)
end
