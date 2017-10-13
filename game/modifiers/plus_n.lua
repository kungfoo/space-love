
Modifiers.PlusN = Class {
	type = 'modifier',
	__includes = GameObject,
	MinPlus = 1,
	MaxPlus = 3,
	radius = 20,
	collision_margin = 3
}

function Modifiers.PlusN:init()
	local random = math.random()
	if random > 0.93 then
		self.n = 3
	elseif random > 0.7 then
		self.n = 2
	else
		self.n = 1
	end
	self.position = Vector(math.random(0, world.width), math.random(0, world.height))
	GameObject.init(self, bump, self:top_left_width_height())
end

function Modifiers.PlusN:draw()
	lg.setColor(255, 255, 255, 255)
	lg.circle("line", self.position.x, self.position.y, self.radius, 20)
	lg.setFont(Font[20])
	lg.print("+"..self.n, self.position.x-15, self.position.y-10)

	if game.debug_level == 'info' then
		game.draw_collision_box(self)
	end
end

function Modifiers.PlusN:top_left_width_height()
	return
		self.position.x - self.radius + self.collision_margin,
		self.position.y - self.radius + self.collision_margin,
		self.radius*2 - 2*self.collision_margin,
		self.radius*2 - 2*self.collision_margin
end

function Modifiers.PlusN:dist(a, b)
	local dx = a.x - b.x
	local dy = a.y - b.y
	return math.sqrt(dx * dx + dy * dy)
end

function Modifiers.PlusN:apply(player)
	player.weapon.bulletsPerShot = player.weapon.bulletsPerShot + self.n
end


function Modifiers.PlusN:collides_with(player)
	local distance = self:dist(self.position, player.position)
	return distance < (player.radius + self.radius - 5)
end

