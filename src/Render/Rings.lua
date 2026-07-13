-- Render/Rings.lua
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local Rings = {}
local RingPool = {} -- player -> {PullGui, SlowGui, LockGui}

function Rings.clearPlayerRings(player)
    if RingPool[player] then
        pcall(function() RingPool[player].PullGui:Destroy() end)
        pcall(function() RingPool[player].SlowGui:Destroy() end)
        pcall(function() RingPool[player].LockGui:Destroy() end)
        RingPool[player] = nil
    end
end

function Rings.getCharacterRings(player, ringsFolder)
    if RingPool[player] then return RingPool[player] end

    local function CreateHudRing(name, color)
        local bbgui = Instance.new("BillboardGui")
        bbgui.Name = "MagnetRing_" .. name .. "_" .. player.Name
        bbgui.AlwaysOnTop = true
        bbgui.ResetOnSpawn = false
        bbgui.Enabled = false
        bbgui.Parent = ringsFolder

        local frame = Instance.new("Frame", bbgui)
        frame.Size = UDim2.new(1, 0, 1, 0)
        frame.AnchorPoint = Vector2.new(0.5, 0.5)
        frame.Position = UDim2.new(0.5, 0, 0.5, 0)
        frame.BackgroundTransparency = 1
        Instance.new("UICorner", frame).CornerRadius = UDim.new(1, 0)
        local stroke = Instance.new("UIStroke", frame)
        stroke.Color = color
        stroke.Thickness = 1.2
        return bbgui
    end

    local pullGui = CreateHudRing("Pull", Color3.fromRGB(0, 122, 255))  -- Theme.Accent
    local slowGui = CreateHudRing("Slow", Color3.fromRGB(255, 180, 0))
    local lockGui = CreateHudRing("Lock", Color3.fromRGB(255, 60, 100))

    RingPool[player] = { PullGui = pullGui, SlowGui = slowGui, LockGui = lockGui }
    return RingPool[player]
end

function Rings.updateRings(player, rings, config, camera, isVisible, onScreen, dist2D, distance3D)
    if not rings then return end

    if isVisible and onScreen and config.MagneticAssist then
        local targetRoot = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        local targetHead = player.Character and player.Character:FindFirstChild("Head")
        if targetRoot and targetHead then
            rings.PullGui.Adornee = targetRoot
            rings.SlowGui.Adornee = targetRoot
            rings.LockGui.Adornee = targetHead
            rings.PullGui.Enabled = true
            rings.SlowGui.Enabled = true
            rings.LockGui.Enabled = true

            local function getScreenDiameter(radiusInStuds)
                local fovRad = math.rad(camera.FieldOfView / 2)
                local screenHeightAtDist = 2 * distance3D * math.tan(fovRad)
                if screenHeightAtDist <= 0 then return 0 end
                return ((radiusInStuds * 2) * camera.ViewportSize.Y) / screenHeightAtDist
            end

            local pxLock = math.clamp(getScreenDiameter(1.4), 4, 120)
            local pxSlow = math.clamp(getScreenDiameter(3.2), 10, 250)
            local pxPull = math.clamp(getScreenDiameter(5.8), 16, 450)
            rings.LockGui.Size = UDim2.new(0, pxLock, 0, pxLock)
            rings.SlowGui.Size = UDim2.new(0, pxSlow, 0, pxSlow)
            rings.PullGui.Size = UDim2.new(0, pxPull, 0, pxPull)
        else
            rings.PullGui.Enabled = false
            rings.SlowGui.Enabled = false
            rings.LockGui.Enabled = false
        end
    else
        rings.PullGui.Enabled = false
        rings.SlowGui.Enabled = false
        rings.LockGui.Enabled = false
    end
end

return Rings
