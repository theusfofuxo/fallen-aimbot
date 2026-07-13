-- Utils/Math.lua
local Math = {}

function Math.clamp(value, min, max)
    return math.max(min, math.min(max, value))
end

function Math.round(value, decimals)
    local mult = 10 ^ (decimals or 0)
    return math.floor(value * mult + 0.5) / mult
end

function Math.expSmooth(current, target, gain, dt)
    local factor = 1 - math.exp(-gain * math.min(dt, 0.1))
    return current + (target - current) * factor
end

return Math
