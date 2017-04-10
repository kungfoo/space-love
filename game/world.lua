World = Class {
}

function World:init()
	self.width = 6000
	self.height = 4000
end

function World:out_of_bounds(position)
	return position.x < 0 or
				position.y < 0 or
				position.x > self.width,
				position.y > self.height
end

