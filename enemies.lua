
require("enemy")

function game.newEnemies()

	local Enemies = {

		spawningTimer = 0.5,
		level = 1,

		enemies = {}
	}

	function Enemies:update(dt)
		self.spawningTimer = self.spawningTimer - dt * self.level

		if self.spawningTimer < 0 then
			table.insert(self.enemies, game.newEnemy())
			self.spawningTimer = 0.5
		end

		for i, enemy in ipairs(self.enemies) do
			enemy:update(dt)
		end
	end

	function Enemies:draw()
		for i, enemy in ipairs(self.enemies) do
			enemy:draw()

			if enemy:is_offscreen() then
				table.remove(enemies, i)
			end
		end
	end

	return Enemies
end
