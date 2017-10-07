-- base class for all game objects

GameObject = Class {
}

function GameObject:init(bump, left, top, width, height)
	self.bump = bump
	self.uuid = uuid()
	self.bump:add(self, left, top, width, height)
	self.created_at = love.timer.getTime()
end

function GameObject:destroy()
	if game.debug then
		print(string.format("%s:%s created at %s has been destroyed", self.type, self.uuid, self.created_at))
	end
	self.bump:remove(self)
end
