
Enemy = Class {
	type = 'enemy',
	__includes = GameObject,
	width = 20,
	height = 20,
	slow_down = 20,
	speed_up = 20,

	mass = 100,
	friction = 1/100,

	flocking_radius = 200,
	state = 'flocking'
}

function Enemy:init(bump, position)
	GameObject.init(self, bump, position.x, position.y, self.width, self.height)

	self.position = position
	self.health = math.random(30, 110)
	self.velocity = Vector(0, 0)
end

function Enemy.filter(item, other)
	local type = other.type
	if type == Enemy.type then
		return 'bounce'
	else
		return nil
	end
end

function Enemy.flocking_filter(other)
	if other.type == Enemy.type then
		return 'flock'
	else
		return nil
	end
end

function Enemy:draw()
	love.graphics.setColor(self:color())
	love.graphics.rectangle("fill", self.position.x, self.position.y, self.width, self.height)

	if game.debug_level == 'info' then
		game.draw_collision_box(self)
	end
end

function Enemy:color()
	local hue = (self.health/100) * 360
	local alpha = ((self.health/100) * 200) + 55

	return game.colors.hsl(hue, 50, 50, alpha)
end

function Enemy:update(dt)

	if self.state == 'flocking' then
		local others, len = bump:queryRect(self.position.x, self.position.y, self.flocking_radius, self.flocking_radius, Enemy.flocking_filter)

		local alignment = Vector()
		local cohesion = Vector()
		local separation = Vector()

		for i=1, len do
			local other = others[i]
			alignment = alignment + other.velocity
			cohesion = cohesion + other.position
			separation = separation + (other.position - self.position)
		end

		cohesion = cohesion/len
		cohesion = cohesion - self.position

		alignment = alignment/len

		separation = separation * -1
		separation = separation/len
		
		separation:normalizeInplace()
		alignment:normalizeInplace()
		cohesion:normalizeInplace()

		self.velocity = self.velocity + separation + alignment + cohesion
	end

	local future_position = self.position + self.velocity * dt
	local next_left, next_top, collisions, len = self.bump:move(self, future_position.x, future_position.y, Enemy.filter)

	for i=1,len do
		-- TODO: deal with collisions here...
	end

	self.position = Vector(next_left, next_top)

	self.velocity = self.velocity * math.pow(self.friction, dt)
end

function Enemy:is_offscreen()
	return world:out_of_bounds(self.position)
end

function Enemy:hit(bullet)
	self.health = self.health - bullet.damage
	
	-- vollkommen elastischer stoss:
	self.velocity = ((self.mass - bullet.mass) * self.velocity + 2 * bullet.mass * bullet.velocity) / (self.mass + bullet.mass)
	
	Signal.emit("enemy-hit")

	if self:is_dead() then
		Signal.emit("enemy-killed", self.position)
	end
end

function Enemy:is_dead()
	return self.health <= 0
end
