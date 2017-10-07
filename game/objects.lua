-- base class for all game objects

GameObject = Class {
}

function GameObject:init(position)
	self.uuid = uuid()
	self.position = position:clone()
end

Snapple = Class {
	__includes = GameObject,
	type = 'snapple'
}

function Snapple:init(position)
	GameObject.init(self, position)
end