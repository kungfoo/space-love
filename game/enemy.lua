
Enemy = Class {
	type = 'enemy',
	width = 20,
	height = 20,
	slow_down = 20,
	speed_up = 20,

	mass = 100,
	friction = 1/100,

	flocking_radius = 100,
	state = 'not-flocking'
}

function Enemy:init(position)
	self.position = position
	self.health = math.random(30, 110)
	self.velocity = Vector(0, 0)

	local xc = position.x + self.width/2
	local yc = position.y + self.height/2

	-- TODO: create bump world object
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

function Enemy:destroy()
	-- TODO: remove from bump world
end

function Enemy:update(dt)
	self.position = self.position + self.velocity * dt

	local xc = self.position.x + self.width/2
	local yc = self.position.y + self.height/2
	-- TODO: move collision object

	if self.state == 'flocking' then

		-- TODO: figure out others within range

		local alignment = Vector()
		local cohesion = Vector()
		local separation = Vector()

		local count = 0
		for object, separating_vector in pairs(visible_objects) do
			if object.type == 'enemy' then
				alignment = alignment + object.velocity
				cohesion = cohesion + object.position
				separation = separation + (object.position - self.position)

				count = count + 1
			end
		end
		separation = separation * -1
		
		separation:normalizeInplace()
		alignment:normalizeInplace()
		cohesion:normalizeInplace()

		self.velocity = self.velocity + separation + alignment + cohesion
	end

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
