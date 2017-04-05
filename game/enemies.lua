require("game.enemy")

function game.newEnemies()
return {

	spawningTimer = 0.5,
	level = 0.2,

	kills = 0,

	enemies = {},

	update = function(self, dt)
		local level_scaled = ((self.kills / 10.0) + 1.0) * self.level

		self.spawningTimer = self.spawningTimer - dt * level_scaled

		if self.spawningTimer < 0 then
			local enemy = game.newEnemy()
			table.insert(self.enemies, enemy)
			self.spawningTimer = 0.5
		end

		for _, enemy in ipairs(self.enemies) do
			enemy:update(dt)
		end
	end,

	draw = function(self)
		for i, enemy in ipairs(self.enemies) do
			enemy:draw()

			if enemy:is_offscreen() then
				table.remove(enemies, i)
			end
		end
	end,

	increase_kill_count = function(self)
		self.kills = self.kills + 1
		print(("kills: %d"):format(self.kills))
	end,

	remove = function(self, i)
		self:increase_kill_count()
		table.remove(self.enemies, i)
	end
}
end
