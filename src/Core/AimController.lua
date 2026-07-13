-- Core/AimController.lua
local PID = require(script.Parent.PID)
local Prediction = require(script.Parent.Prediction)
local Math = require(script.Parent.Parent.Utils.Math)

local AimController = {}

-- Estado interno
local state = {
    smoothedAimPos = nil,
    lastClosestTarget = nil,
    yawPID = PID.new(5.0, 0.05, 0.8, 0.2),
    pitchPID = PID.new(5.0, 0.05, 0.8, 0.2)
}

function AimController.reset()
    state.smoothedAimPos = nil
    state.lastClosestTarget = nil
    state.yawPID:Reset()
    state.pitchPID:Reset()
end

function AimController.applyAim(deltaTime, camera, myRoot, targetHead, config)
    if not camera or not myRoot or not targetHead then return end

    local distance3D = (targetHead.Position - myRoot.Position).Magnitude
    local rawAimPos = targetHead.Position

    if config.Prediction then
        local enemyChar = targetHead.Parent
        local enemyRoot = enemyChar and enemyChar:FindFirstChild("HumanoidRootPart")
        rawAimPos = Prediction.predictPosition(targetHead, enemyRoot, config.BulletSpeed, distance3D)
    end

    local targetChanged = (state.lastClosestTarget ~= targetHead)
    if not state.smoothedAimPos or targetChanged then
        state.smoothedAimPos = rawAimPos
        state.yawPID:Reset()
        state.pitchPID:Reset()
    else
        local alpha = config.PID_SmoothAim
        if alpha > 0.01 then
            state.smoothedAimPos = state.smoothedAimPos:Lerp(rawAimPos, math.min(1, deltaTime * 10 * alpha))
        else
            state.smoothedAimPos = rawAimPos
        end
    end
    state.lastClosestTarget = targetHead

    local targetCFrame = CFrame.new(camera.CFrame.Position, state.smoothedAimPos)
    local forceFactor = 1.0

    if distance3D <= config.MagneticLockRadius then
        forceFactor = (config.MagneticCorrection + 16) * config.BaseSensitivity
    elseif distance3D <= config.SlowdownRing then
        forceFactor = (config.MagneticAcceleration / 20) * (distance3D / config.SlowdownRing) * config.BaseSensitivity
    else
        forceFactor = (config.MagneticAcceleration / 50) * config.BaseSensitivity
    end

    if config.UsePID then
        local currentY, currentX = camera.CFrame:ToEulerAnglesYXZ()
        local targetY, targetX = targetCFrame:ToEulerAnglesYXZ()

        local errorYaw = math.atan2(math.sin(targetY - currentY), math.cos(targetY - currentY))
        local errorPitch = math.atan2(math.sin(targetX - currentX), math.cos(targetX - currentX))

        local maxStep = math.min(forceFactor * deltaTime * 14, config.PID_MaxAngularSpeed * deltaTime)

        local outputYaw = state.yawPID:Calculate(errorYaw, deltaTime, maxStep)
        local outputPitch = state.pitchPID:Calculate(errorPitch, deltaTime, maxStep)

        local smoothFactor = 15 * (1 - config.PID_OutputSmooth)
        local finalYaw = Math.expSmooth(0, outputYaw, smoothFactor, deltaTime)
        local finalPitch = Math.expSmooth(0, outputPitch, smoothFactor, deltaTime)

        camera.CFrame = CFrame.new(camera.CFrame.Position) * CFrame.fromEulerAnglesYXZ(
            currentY + finalYaw,
            currentX + finalPitch,
            0
        )
    else
        local finalAlpha = Math.clamp(forceFactor * deltaTime * 14, 0.001, 0.99)
        if config.DecoupleXY then
            local currentY, currentX = camera.CFrame:ToEulerAnglesYXZ()
            local targetY, targetX = targetCFrame:ToEulerAnglesYXZ()
            local deltaY = math.atan2(math.sin(targetY - currentY), math.cos(targetY - currentY))
            local deltaX = math.atan2(math.sin(targetX - currentX), math.cos(targetX - currentX))
            camera.CFrame = CFrame.new(camera.CFrame.Position) * CFrame.fromEulerAnglesYXZ(
                currentY + deltaY * finalAlpha,
                currentX + deltaX * finalAlpha,
                0
            )
        else
            camera.CFrame = camera.CFrame:Lerp(targetCFrame, finalAlpha)
        end
    end
end

return AimController
