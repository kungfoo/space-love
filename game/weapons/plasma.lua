
Weapons.Plasma = Class {
	Name = "Plasma Gun",
	FireRate = 0.1,
	Spread = 0.2,
	BulletsPerShot = 1
}

Bullet = Class {
	hue_start = 290, -- pinkish
	hue_end = 319,

	speed = 1000,
	damage = 15,
	mass = 5,

	radius = 5
}

Bullet.Gibs = Class {}
Bullet.Gibs.Particle = Class {
	min_ttl = 0.3,
	max_ttl = 0.8
}

function Weapons.Plasma:init()
	self.firingTimer = Weapons.Plasma.FireRate
	self.bulletsPerShot = Weapons.Plasma.BulletsPerShot
end

function Weapons.Plasma:update(dt)
	self.firingTimer = self.firingTimer - dt * 1
	
	if self.firingTimer < 0 then
		self.canFire = true
	end
end

function Weapons.Plasma:trigger(player_velocity, position, aim)
	if self.canFire then
		for i=1, self.bulletsPerShot do
			self:fire_bullet(player_velocity, position, aim)
		end
		Signal.emit("plasma-shot-fired")
	end
end

function Weapons.Plasma:fire_bullet(player_velocity, position, aim)
	local aimz = aim:normalized()
	local spread_scaled = Weapons.Plasma.Spread * self.bulletsPerShot * 0.5
	local spread = Vector(
		(math.random() - 0.5) * spread_scaled, 
		(math.random() - 0.5) * spread_scaled
	)
	aimz = aimz + spread

	local velocity = (aimz:normalized() * Bullet.speed) + player_velocity

	local bullet = Bullet(velocity, position)
	
	bulletSystem:insert(bullet)
	self.canFire = false
	self.firingTimer = Weapons.Plasma.FireRate
end


function Bullet:init(velocity, position)
	self.position = position:clone()
	self.velocity = velocity

	self.hue = math.random(self.hue_start, self.hue_end)
end

function Bullet:draw()
	love.graphics.setColor(game.colors.hsl(self.hue, 100, 50))
	love.graphics.circle("fill", self.position.x, self.position.y, self.radius)
end

function Bullet:update(dt)
	self.position = self.position + self.velocity * dt
end

function Bullet:is_offscreen()
	return world:out_of_bounds(self.position)
end

function Bullet:collides_with_enemy(enemy)
	-- closest points of rectangle
	local cx = game.math.clamp(self.position.x, enemy.position.x, enemy.position.x + enemy.width)
	local cy = game.math.clamp(self.position.y, enemy.position.y, enemy.position.y + enemy.height)
	
	-- vector to that point
	local dv = self.position - Vector(cx, cy)
	return dv:len2() < math.pow(self.radius, 2)
end

function Bullet:hit()
	gibs:insert(Bullet.Gibs(self.position))
end

function Bullet.Gibs:init(position)
	self.ttl = math.random(Bullet.Gibs.Particle.min_ttl, Bullet.Gibs.Particle.max_ttl)
	self.ttl_timer = self.ttl
	self.particles = self:create_particles(position:unpack())
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
		particle:draw(self.ttl_timer / self.ttl)
	end
end

function Bullet.Gibs:update(dt)
	for _, particle in ipairs(self.particles) do
		particle:update(dt)
	end
	self.ttl_timer = self.ttl_timer - 2 * dt
end

function Bullet.Gibs:is_alive()
	return self.ttl_timer > 0
end


function Bullet.Gibs.Particle:init(x, y)
	local initial_speed = 400

	self.x = x
	self.y = y

	self.hue = math.random(Bullet.hue_start, Bullet.hue_end)
	self.vm = { math.random(-initial_speed, initial_speed), math.random(-initial_speed, initial_speed) }
end

function Bullet.Gibs.Particle:draw(timer_scaled)
	love.graphics.setColor(game.colors.hsl(self.hue, 100, 50, timer_scaled * 255))
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

