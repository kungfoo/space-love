require("game.enemy")

function game.createGibs(x, y)

	local p = {}
	local initial_speed = 70

	for i = 1, math.random(24, 32) do
		table.insert(p, {
			x = x,
			y = y,

			hue = math.random(50, 200),

			vm = { math.random(-initial_speed, initial_speed), math.random(-initial_speed, initial_speed) },

			draw = function(self, timer_scaled)
				love.graphics.setColor(game.colors.hsl(self.hue, 50, 50, timer_scaled * 255))
				love.graphics.rectangle("fill", self.x, self.y, timer_scaled * 10, timer_scaled * 10)
			end,

			update = function(self, dt)
				-- update position
				self.x = self.x + dt * self.vm[1]
				self.y = self.y + dt * self.vm[2]

				-- slow down
				self.vm[1] = self.vm[1] + (dt * (-self.vm[1]))
				self.vm[2] = self.vm[2] + (dt * (-self.vm[2]))
			end
		})
	end

	local gibs = {
		x = x,
		y = y,

		visible_timer = 5,

		particles = p,

		draw = function(self)
			for _, particle in ipairs(self.particles) do
				particle:draw(self.visible_timer / 5)
			end
		end,

		update = function(self, dt)
			for _, particle in ipairs(self.particles) do
				particle:update(dt)
			end

			self.visible_timer = self.visible_timer - 2 * dt
		end
	}

	return gibs
end

function game.newEnemies()
local enemies = {

	spawningTimer = 0.5,
	level = 0.2,

	kills = 0,

	enemies = {},

	gibs = {},

	update = function(self, dt)
		local level_scaled = ((self.kills / 10.0) + 1.0) * self.level

		self.spawningTimer = self.spawningTimer - dt * level_scaled

		if self.spawningTimer < 0 then
			local enemy = game.newEnemy()
			table.insert(self.enemies, enemy)
			self.spawningTimer = 0.5
		end

		for i, enemy in ipairs(self.enemies) do
			enemy:update(dt)

			if enemy:is_offscreen() then
				table.remove(self.enemies, i)
			end
		end

		for i, g in ipairs(self.gibs) do
			g:update(dt)

			if g.visible_timer < 0 then
				table.remove(self.gibs, i)
			end
		end
	end,

	draw = function(self)
		for i, enemy in ipairs(self.enemies) do
			enemy:draw()
		end

		for _, g in ipairs(self.gibs) do
			g:draw()
		end
	end,

	increase_kill_count = function(self)
		self.kills = self.kills + 1
		print(("kills: %d"):format(self.kills))
	end,

	remove = function(self, i)
		self:increase_kill_count()
		table.remove(self.enemies, i)
	end,

	create_gibs = function(self, x, y)
		table.insert(self.gibs, game.createGibs(x, y))
	end
}

Signal.register("enemy-killed", function(x, y)
	enemies:create_gibs(x, y)
end)

return enemies
end
