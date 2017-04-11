Modifiers = Class {
	
}

require "game.modifiers.plus_n"

function Modifiers:init()
	self.modifiers = {}
	for i=1, 4 do
		table.insert(self.modifiers, Modifiers.PlusN())
	end
end

function Modifiers:draw()
	for i, m in ipairs(self.modifiers) do
		m:draw()
	end
end

function Modifiers:apply(player)
	for i, m in ipairs(self.modifiers) do
		if m:collides_with(player) then
			player:pickup(m)
			table.remove(self.modifiers, i)
		end
	end
end