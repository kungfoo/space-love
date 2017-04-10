
BulletSystem = Class {}

function BulletSystem:init()
	self.bullets = {}
end

function BulletSystem:insert(bullet)
	table.insert(self.bullets, bullet)
end

function BulletSystem:remove(i)
	table.remove(self.bullets, i)
end

function BulletSystem:update(dt)
	for i, b in ipairs(self.bullets) do
		b:update(dt)
		if b:is_offscreen() then
			self:remove(i)
		end
	end	
end

function BulletSystem:draw()

	for i, b in ipairs(self.bullets) do
		b:draw()
	end
end

function BulletSystem:check_collision(enemy)
	for j, bullet in ipairs(self.bullets) do
		if bullet:collides_with_enemy(enemy) then
			bullet:hit()
			enemy:hit()
			self:remove(j)
		end
	end
end