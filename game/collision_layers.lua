local bit = require("bit")

CollisionLayers = Class {
	None = 		0x00000000,
	Vision = 	0x10000000,
	Physics = 	0x01000000,	
}

function CollisionLayers.is_on(object, layer)
	return bit.band(object.layer, layer) > CollisionLayers.None
end

function CollisionLayers.filter(collisions, layer_mask)
	local result = {}

	for object, separating_vector in pairs(collisions) do
		if object.layer and bit.band(object.layer, layer_mask) > CollisionLayers.None then
			result[object] = separating_vector
		end
	end
	return result
end
