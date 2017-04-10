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

	self:spawn_random_enemies(1000)
end

function Enemies:spawn_random_enemies(n)
	local i = 0
	while i < n do
		local position = Vector(math.random(100, world.width-100), math.random(100, world.height-100))
		table.insert(self.enemies, Enemy(position))
		i = i + 1
	end
end

function Enemies:update(dt)
	for i, enemy in ipairs(self.enemies) do
		enemy:update(dt)

		if enemy:is_offscreen() or enemy:is_dead() then
			table.remove(self.enemies, i)
		end
	end
end

function Enemies:draw()
	for i, enemy in ipairs(self.enemies) do
		enemy:draw()
	end
end

function Enemies:increase_kill_count()
	self.kills = self.kills + 1
end

function Enemies:remove(i)
	self:increase_kill_count()
	table.remove(self.enemies, i)
end

