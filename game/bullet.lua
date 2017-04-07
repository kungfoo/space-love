
Bullet = Class {
	hue_start = 290, -- pinkish
	hue_end = 319,

	speed = 555
}

Bullet.Gibs = Class {}
Bullet.Gibs.Particle = Class {
	max_alive = 1
}

function Bullet:init(x, y)
	self.width = 4
	self.height = 10
	self.x = x-1 
	self.y = y

	self.hue = math.random(self.hue_start, self.hue_end)
end

function Bullet:draw()
	love.graphics.setColor(game.colors.hsl(self.hue, 100, 50))
	love.graphics.rectangle("fill", (self.x - self.width/2), self.y, self.width, self.height)
end

function Bullet:update(dt)
	self.y = self.y - dt * self.speed
end

function Bullet:is_offscreen()
	return self.y < - 20
end

function Bullet:collides_with_enemy(enemy)
	return game.check_collision(enemy.x, enemy.y, enemy.width, enemy.height,
								self.x,  self.y,  self.width,  self.height)
end

function Bullet:hit()
	gibs:insert(Bullet.Gibs(self.x, self.y))
end

function Bullet.Gibs:init(x, y)
	self.visible_timer = Bullet.Gibs.Particle.max_alive
	self.particles = self:create_particles(x, y)
end

function Bullet.Gibs:create_particles(x, y)
	local p = {}

	for i = 1, math.random(12, 16) do
		table.insert(p, Bullet.Gibs.Particle(x, y))
	end
	return p
end

function Bullet.Gibs:draw()
	for _, particle in ipairs(self.particles) do
		particle:draw(self.visible_timer / Bullet.Gibs.Particle.max_alive)
	end
end

function Bullet.Gibs:update(dt)
	for _, particle in ipairs(self.particles) do
		particle:update(dt)
	end
	self.visible_timer = self.visible_timer - 2 * dt
end

function Bullet.Gibs:is_alive()
	return self.visible_timer > 0
end


function Bullet.Gibs.Particle:init(x, y)
	local initial_speed = 300

	self.x = x
	self.y = y

	self.hue = math.random(Bullet.hue_start, Bullet.hue_end)
	self.vm = { math.random(-initial_speed, initial_speed), math.random(-initial_speed, initial_speed) }
end

function Bullet.Gibs.Particle:draw(timer_scaled)
	love.graphics.setColor(game.colors.hsl(self.hue, 80, 50, timer_scaled * 255))
	love.graphics.rectangle("fill", self.x, self.y, timer_scaled * 5, timer_scaled * 5)
end

function Bullet.Gibs.Particle:update(dt)
	-- update position
	self.x = self.x + dt * self.vm[1]
	self.y = self.y + dt * self.vm[2]

	-- slow down
	self.vm[1] = self.vm[1] + (dt * (-self.vm[1]))
	self.vm[2] = self.vm[2] + (dt * (-self.vm[2]))
end
