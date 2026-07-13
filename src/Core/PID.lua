-- Core/PID.lua
local Math = require(script.Parent.Parent.Utils.Math)

local PID = {}
PID.__index = PID

function PID.new(kp, ki, kd, alpha)
    return setmetatable({
        kp = kp,
        ki = ki,
        kd = kd,
        alpha = alpha or 0.15,
        integral = 0,
        lastError = 0,
        filteredDerivative = 0
    }, PID)
end

function PID:Reset()
    self.integral = 0
    self.lastError = 0
    self.filteredDerivative = 0
end

function PID:Calculate(error, dt, maxOutput)
    dt = math.min(dt, 0.1)
    if dt <= 0 then return 0 end

    local rawDerivative = (error - self.lastError) / dt
    self.filteredDerivative = self.filteredDerivative + self.alpha * (rawDerivative - self.filteredDerivative)
    self.lastError = error

    local output = (error * self.kp) + (self.integral * self.ki) + (self.filteredDerivative * self.kd)

    if math.abs(output) < maxOutput then
        self.integral = self.integral + error * dt
    else
        if (error > 0 and self.integral < 0) or (error < 0 and self.integral > 0) then
            self.integral = self.integral + error * dt
        end
    end

    return Math.clamp(output, -maxOutput, maxOutput)
end

return PID
