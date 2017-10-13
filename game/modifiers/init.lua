Modifiers = Class {
	
}

require "game.modifiers.plus_n"

function Modifiers:init()
	self.modifiers = {}
	for i=1, 5 do
		local mod = Modifiers.PlusN()
		self.modifiers[mod] = true
	end
end

function Modifiers:remove(mod)
	self.modifiers[mod] = nil
	mod:destroy()
end
