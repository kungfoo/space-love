Enemies = Class { }

require("game.enemy")
require("game.enemies.gibs")

function Enemies:init()
	self.level = 0.2
	self.kills = 0

	self.enemies = {}

	Signal.register("enemy-killed", function(position)
		gibs:insert(Enemies.Gibs(position.x, position.y))
	end)

	self:spawn_random_enemies(500)
end

function Enemies:spawn_random_enemies(n)
	for i = 0, n do
		local position = Vector(math.random(100, world.width-100), math.random(100, world.height-100))
		self.enemies[Enemy(position)] = true
	end
end

function Enemies:update(dt)
	for enemy, _ in pairs(self.enemies) do
		enemy:update(dt)

		if enemy:is_offscreen() or enemy:is_dead() then
			self:remove(enemy)
		end
	end
end

function Enemies:draw()
	for enemy, _ in pairs(self.enemies) do
		enemy:draw()
	end
end

function Enemies:remove(enemy)
	self.enemies[enemy]:destroy()
	self.enemies[enemy] = nil
end

