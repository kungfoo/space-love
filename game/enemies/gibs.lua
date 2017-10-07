
Enemies.Gibs = Class { }
Enemies.Gibs.Particle = Class {
	min_ttl = 2,
	max_ttl = 4,
	initial_speed = 300
}

function Enemies.Gibs:init(x, y)
	self.ttl = math.random(Enemies.Gibs.Particle.min_ttl, Enemies.Gibs.Particle.max_ttl)
	self.ttl_timer = self.ttl
	self.particles = self:create_particles(x,y)
end

function Enemies.Gibs:create_particles(x, y)
	local p = {}

	for i = 1, math.random(24, 32) do
		table.insert(p, Enemies.Gibs.Particle(x, y, Enemies.Gibs.Particle.initial_speed))
	end

	for i = 1, math.random(6, 24) do
		table.insert(p, Enemies.Gibs.Particle(x, y,  Enemies.Gibs.Particle.initial_speed * 3))
	end

	return p
end

function Enemies.Gibs:draw()
	for _, particle in ipairs(self.particles) do
		particle:draw(self.ttl_timer / self.ttl)
	end
end

function Enemies.Gibs:update(dt)
	for _, particle in ipairs(self.particles) do
		particle:update(dt)
	end
	self.ttl_timer = self.ttl_timer - 2 * dt
end

function Enemies.Gibs:is_alive()
	return self.ttl_timer > 0
end

function Enemies.Gibs.Particle:init(x, y, speed)
	self.position = Vector(x,y)
	self.velocity = Vector(math.random()-0.5, math.random()-0.5) * speed

	self.hue = math.random(5, 50)
end

function Enemies.Gibs.Particle:draw(timer_scaled)
	lg.setColor(game.colors.hsl(self.hue, 80, 50, timer_scaled * 255))
	lg.rectangle("fill", self.position.x, self.position.y, timer_scaled * 10, timer_scaled * 10)
end

function Enemies.Gibs.Particle:update(dt)
	self.position = self.position + dt * self.velocity

	-- slow down
	self.velocity = self.velocity + (dt * -self.velocity)
end
