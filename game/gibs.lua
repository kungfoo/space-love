
GibsSystem = Class {
}

function GibsSystem:init()
	self.gibs = {}
end

function GibsSystem:update(dt)
	for g, _ in pairs(self.gibs) do
		g:update(dt)

		if not g:is_alive() then
			self.gibs[g] = nil
			g:destroy()
		end
	end
end

function GibsSystem:draw()
	-- for g, _ in pairs(self.gibs) do
	-- 	g:draw()
	-- end
end

function GibsSystem:insert(gibs)
	self.gibs[gibs] = true
end
