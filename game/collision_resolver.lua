CollisionResolver = Class {
	
}

function CollisionResolver:init()
	Signal.register("collision", function(a, b)
		self:resolve_collision(a, b) 
	end)
end

function CollisionResolver:resolve_collision(a, b)
	if a.type == 'player' then
		if b.type == 'enemy' then
			print("Hit enemy with player")
			player:hit()
			Signal.emit("enemy-killed", b.position)
			enemies:remove(b)
		end
	end

	if a.type == 'bullet' and b.type == 'enemy' then
		b:hit(a)
		a:hit()

		bullets:remove(a)
	end
end
