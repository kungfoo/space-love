Enemies = Class { }

require("game.enemy")
require("game.enemies.gibs")

function Enemies:init()
	self.spawningTimer = 0.5
	self.level = 0.2
	self.kills = 0

	self.enemies = {}

	Signal.register("enemy-killed", function(x, y)
		gibs:insert(Enemies.Gibs(x, y))
	end)
end

function Enemies:update(dt)
	local level_scaled = ((self.kills / 10.0) + 1.0) * self.level

	self.spawningTimer = self.spawningTimer - dt * level_scaled

	if self.spawningTimer < 0 then
		local enemy = Enemy()
		table.insert(self.enemies, enemy)
		self.spawningTimer = 0.5
	end

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

