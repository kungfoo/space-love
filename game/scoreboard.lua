function game.newScoreboard()
	local scoreboard = {
		top = 40,
		padding = 20,
		height = 12,

		score = 0
	}

	function scoreboard:draw()
		local width = love.graphics.getWidth() - self.padding*2
		local height = self.height
		local x = self.padding
		local y = self.top

		love.graphics.setColor(255, 255, 255, 230)
		love.graphics.print("HEALTH", self.padding, self.top - (self.height + 3))

		local score = ("SCORE %d"):format(self.score)
		love.graphics.print(score, self.padding, self.top + self.height + 3)

		-- set health bar color...
		local health_scaled = player.health / player.max_health

		love.graphics.setColor(game.colors.hsl(health_scaled * 120, 60, 60, 128))
		love.graphics.rectangle("fill", x, y, width*health_scaled, height)
	end

	function scoreboard:hit()
		self.score = self.score + 32
	end

	function scoreboard:kill()
		self.score = self.score + 512
	end

	return scoreboard
end
