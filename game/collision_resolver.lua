CollisionResolver = Class {
	
}

function CollisionResolver:init()
	Signal.register("collision", function(a, b, separating_vector)
		self:resolve_collision(a, b, separating_vector) 
	end)
end

function CollisionResolver:resolve_collision(a, b, separating_vector)
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

		bulletSystem:remove(a)
	end
end
