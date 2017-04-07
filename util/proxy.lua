
local function Proxy(f)
	return setmetatable({}, {__index = function(t,k)
		local v = f(k)
		t[k] = v
		return v
	end})
end

Font  = Proxy(function(arg)
	if tonumber(arg) then
		return love.graphics.newFont('font/slkscr.ttf', arg)
	end
	return Proxy(function(size) return love.graphics.newFont('font/'..arg..'.ttf', size) end)
end)

