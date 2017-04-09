
function game.math.clamp(value, min, max)
	return math.max(min, math.min(max, value))
end

function game.math.continuous_random(min, max)
	return math.random() * (max - min) + min
end
