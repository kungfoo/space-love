
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

	self.hc_object = HC.rectangle(xc, yc, self.width, self.height)
	self.hc_object.game_object = self
	self.hc_object.layer = CollisionLayers.Physics

	self.hc_circle_of_vision = HC.circle(xc, yc, self.flocking_radius)
	self.hc_circle_of_vision.game_object = self
	self.hc_circle_of_vision.layer = CollisionLayers.Vision
end

function Enemy:draw()
	love.graphics.setColor(self:color())
	love.graphics.rectangle("fill", self.position.x, self.position.y, self.width, self.height)

	if game.show_debug then
		love.graphics.setColor(0, 200, 0, 64)
		self.hc_circle_of_vision:draw()
	end
end

function Enemy:color()
	local hue = (self.health/100) * 360
	local alpha = ((self.health/100) * 200) + 55

	return game.colors.hsl(hue, 50, 50, alpha)
end

function Enemy:update(dt)
	self.position = self.position + self.velocity * dt

	local xc = self.position.x + self.width/2
	local yc = self.position.y + self.height/2
	self.hc_object:moveTo(xc, yc)
	self.hc_circle_of_vision:moveTo(xc, yc)
	
	if self.state == 'flocking' then
		local visible_objects = HC.collisions(self.hc_circle_of_vision	)

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
		-- print(string.format("separation: \t%s, alignment: \t%s, cohesion: \t%s", separation, alignment, cohesion))
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
