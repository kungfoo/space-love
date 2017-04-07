
GibsSystem = Class {}

function GibsSystem:init()
	self.gibs = {}
end

function GibsSystem:update(dt)
	for i, g in ipairs(self.gibs) do
		g:update(dt)

		if not g:is_alive() then
			table.remove(self.gibs, i)
		end
	end
end

function GibsSystem:draw()
	for _, g in ipairs(self.gibs) do
		g:draw()
	end
end

function GibsSystem:insert(gibs)
	table.insert(self.gibs, gibs)
end
