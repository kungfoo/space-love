
BulletSystem = Class {}

function BulletSystem:init(bump)
	self.bullets = {}
end

function BulletSystem:insert(bullet)
	self.bullets[bullet] = true
end

function BulletSystem:update(dt)
	for b,_ in pairs(self.bullets) do
		b:update(dt)
		if b:is_offscreen() then
			self.bullets[b] = nil
			b:destroy()
		end
	end	
end

function BulletSystem:remove(bullet)
	self.bullets[bullet] = nil
	bullet:destroy()
end

function BulletSystem:draw()
	for b, _ in pairs(self.bullets) do
		b:draw()
	end
end
