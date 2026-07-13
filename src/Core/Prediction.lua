-- Core/Prediction.lua
local Prediction = {}

function Prediction.predictPosition(targetHead, targetRoot, bulletSpeed, distance)
    if not targetRoot then return targetHead.Position end
    local velocity = targetRoot.AssemblyLinearVelocity or Vector3.new()
    local timeToTarget = distance / math.max(bulletSpeed, 1)
    return targetHead.Position + (velocity * timeToTarget)
end

return Prediction
