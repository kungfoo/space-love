
Modifiers.PlusN = Class {
	MinPlus = 1,
	MaxPlus = 3,
	radius = 20
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
end

function Modifiers.PlusN:draw()
	lg.setColor(255,255,255,255)
	lg.circle("line", self.position.x, self.position.y, self.radius)
	lg.setFont(Font[20])
	lg.print("+"..self.n, self.position.x-15, self.position.y-10)
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

