-- Core/WallCheck.lua
local Cache = require(script.Parent.Parent.Utils.Cache)

local WallCheck = {}
local visibilityCache = Cache.new(1 / 15) -- atualiza a cada ~0.066s

function WallCheck.isVisible(player, camera, localCharacter, targetCharacter, head)
    local now = os.clock()
    local cached = visibilityCache:get(player)
    if cached ~= nil then return cached end

    if not camera then return false end
    local ignoreList = {localCharacter, targetCharacter, camera}
    local obscuringParts = camera:GetPartsObscuringTarget({head.Position}, ignoreList)

    local visible = true
    for _, part in ipairs(obscuringParts) do
        if part.Transparency < 0.75 and part.CanCollide then
            visible = false
            break
        end
    end

    visibilityCache:set(player, visible)
    return visible
end

function WallCheck.clearCache()
    visibilityCache:clear()
end

return WallCheck
