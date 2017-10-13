
BulletSystem = Class {}

function BulletSystem:init(bump)
	self.bullets = {}
end

function BulletSystem:insert(bullet)
	self.bullets[bullet] = bullet
end

function BulletSystem:update(dt)
	for b,_ in pairs(self.bullets) do
		b:update(dt)
		if b:is_offscreen() then
			self:remove(b)
		end
	end	
end

function BulletSystem:remove(bullet)
	self.bullets[bullet] = nil
	bullet:destroy()
end

