Scoreboard = Class {
	top = 40,
	padding = 20,
	height = 12
}

function Scoreboard:init()
	self.score = 0
	self.showing_score = 0

	Signal.register("enemy-hit", function()
		self:hit()
	end)

	Signal.register("enemy-killed", function()
		self:kill()
	end)
end

function Scoreboard:update(dt)
	if self.showing_score < self.score then
		-- ease towards score over time
		self.showing_score = math.min(self.score, self.showing_score + (self.score - self.showing_score) * 8 * dt)
	end
	-- snap to final score in the end
	if self.score - self.showing_score <= 1 then
		self.showing_score = self.score
	end
end

function Scoreboard:draw()
	local width = love.graphics.getWidth() - self.padding*2
	local height = self.height
	local x = self.padding
	local y = self.top

	love.graphics.setFont(Font[20])
	
	love.graphics.setColor(255, 255, 255, 230)
	love.graphics.print("HEALTH", self.padding, self.top - (self.height + 3))

	local score = ("SCORE %d"):format(self.showing_score)
	love.graphics.print(score, self.padding, self.top + self.height + 3)

	-- set health bar color...
	local health_scaled = player.health / player.max_health

	love.graphics.setColor(game.colors.hsl(health_scaled * 120, 60, 60, 128))
	love.graphics.rectangle("fill", x, y, width*health_scaled, height)
end

function Scoreboard:hit()
	self.score = self.score + 32
end

function Scoreboard:kill()
	self.score = self.score + 512
end
