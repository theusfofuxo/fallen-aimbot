-- Utils/Tween.lua
local TweenService = game:GetService("TweenService")

local Tween = {}

function Tween:Create(object, tweenInfo, properties)
    return TweenService:Create(object, tweenInfo, properties)
end

function Tween:Play(tween)
    tween:Play()
end

return Tween
