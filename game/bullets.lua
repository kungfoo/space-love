
BulletSystem = Class {}

function BulletSystem:init()
	self.bullets = {}
end

function BulletSystem:insert(bullet)
	self.bullets[bullet] = true
end

function BulletSystem:remove(bullet)
	HC.remove(bullet.hc_object)
	self.bullets[bullet] = nil
end

function BulletSystem:update(dt)
	for b,_ in pairs(self.bullets) do
		b:update(dt)
		if b:is_offscreen() then
			self:remove(b)
		end
	end	
end

function BulletSystem:draw()
	for b, _ in pairs(self.bullets) do
		b:draw()
	end
end

function BulletSystem:check_collisions()
	for b, _ in pairs(self.bullets) do
		local physics_collisions = CollisionLayers.filter(HC.collisions(b.hc_object), CollisionLayers.Physics)
		for other, separating_vector in pairs(physics_collisions) do
			Signal.emit("collision", b, other.game_object, separating_vector)
		end
	end
end