-- UI/Presets.lua
local Tween = require(script.Parent.Parent.Utils.Tween)
local Theme = require(script.Parent.Theme)

local Presets = {}

local PresetProfiles = {
    Legit = {
        AimTracking = true,
        MagneticAssist = true,
        MagneticLockRadius = 2.0,
        BaseSensitivity = 0.12,
        DecoupleXY = true,
        WallCheck = true,
        TeamCheck = true,
        SlowdownRing = 20.0,
        PullRingRadius = 75.0,
        MagneticAcceleration = 2.0,
        MagneticCorrection = 4.0,
        ShowFOVCircle = true,
        AimFOVRadius = 55.0,
        CustomFOV = false,
        FOVValue = 90.0,
        Prediction = true,
        BulletSpeed = 1600.0,
        UsePID = false
    },
    SemiLegit = {
        AimTracking = true,
        MagneticAssist = true,
        MagneticLockRadius = 6.5,
        BaseSensitivity = 0.35,
        DecoupleXY = true,
        WallCheck = true,
        TeamCheck = true,
        SlowdownRing = 35.0,
        PullRingRadius = 130.0,
        MagneticAcceleration = 5.0,
        MagneticCorrection = -1.5,
        ShowFOVCircle = true,
        AimFOVRadius = 125.0,
        CustomFOV = false,
        FOVValue = 90.0,
        Prediction = true,
        BulletSpeed = 1100.0,
        UsePID = true,
        PID_Kp = 5.0,
        PID_Ki = 0.05,
        PID_Kd = 0.8,
        PID_MaxAngularSpeed = 4.0,
        PID_SmoothAim = 0.6,
        PID_OutputSmooth = 0.4
    },
    Rage = {
        AimTracking = true,
        MagneticAssist = true,
        MagneticLockRadius = 24.0,
        BaseSensitivity = 2.2,
        DecoupleXY = false,
        WallCheck = false,
        TeamCheck = true,
        SlowdownRing = 70.0,
        PullRingRadius = 350.0,
        MagneticAcceleration = 18.0,
        MagneticCorrection = -6.0,
        ShowFOVCircle = true,
        AimFOVRadius = 400.0,
        CustomFOV = true,
        FOVValue = 115.0,
        Prediction = true,
        BulletSpeed = 2400.0,
        UsePID = false
    }
}

function Presets.apply(profileName, config, updateFeature)
    local profile = PresetProfiles[profileName]
    if not profile then return end

    for featureName, value in pairs(profile) do
        updateFeature(featureName, value)
    end
end

function Presets.createButtons(parent, config, registerUpdate, updateFeature)
    local PresetContainer = Instance.new("Frame")
    PresetContainer.Size = UDim2.new(1, 0, 0, 60)
    PresetContainer.BackgroundTransparency = 1
    PresetContainer.ClipsDescendants = true

    local PresetTitle = Instance.new("TextLabel", PresetContainer)
    PresetTitle.Size = UDim2.new(1, 0, 0, 12)
    PresetTitle.Position = UDim2.new(0, 4, 0, 0)
    PresetTitle.Text = "PRE-CONFIGURAÇÕES"
    PresetTitle.TextColor3 = Theme.TextMuted
    PresetTitle.Font = Enum.Font.GothamBold
    PresetTitle.TextSize = 8
    PresetTitle.TextXAlignment = Enum.TextXAlignment.Left
    PresetTitle.BackgroundTransparency = 1

    local PresetButtonsFrame = Instance.new("Frame", PresetContainer)
    PresetButtonsFrame.Size = UDim2.new(1, 0, 0, 36)
    PresetButtonsFrame.Position = UDim2.new(0, 0, 0, 16)
    PresetButtonsFrame.BackgroundTransparency = 1
    local PresetLayout = Instance.new("UIListLayout", PresetButtonsFrame)
    PresetLayout.FillDirection = Enum.FillDirection.Horizontal
    PresetLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    PresetLayout.Padding = UDim.new(0, 6)

    local presetButtonsMap = {}

    local function createPresetCircle(name, displayName)
        local Circle = Instance.new("TextButton", PresetButtonsFrame)
        Circle.Size = UDim2.new(0, 38, 0, 32)
        Circle.Text = ""
        Circle.BackgroundColor3 = Theme.CardBg
        Circle.BackgroundTransparency = Theme.CardTransparency
        Instance.new("UICorner", Circle).CornerRadius = UDim.new(0, 8)
        local stroke = Instance.new("UIStroke", Circle)
        stroke.Color = Theme.BorderColor
        stroke.Transparency = 0.88

        local label = Instance.new("TextLabel", Circle)
        label.Size = UDim2.new(1, 0, 1, 0)
        label.Text = displayName
        label.TextColor3 = Theme.TextMuted
        label.Font = Enum.Font.GothamBold
        label.TextSize = 8
        label.BackgroundTransparency = 1

        presetButtonsMap[name] = {Button = Circle, Label = label}
        Circle.MouseButton1Click:Connect(function()
            Presets.apply(name, config, updateFeature)
            -- Atualizar visual dos botões
            for n, data in pairs(presetButtonsMap) do
                if n == name then
                    Tween:Create(data.Button, TweenInfo.new(0.2), {BackgroundColor3 = Theme.Accent, BackgroundTransparency = 0.15}):Play()
                    Tween:Create(data.Label, TweenInfo.new(0.2), {TextColor3 = Color3.new(1,1,1)}):Play()
                else
                    Tween:Create(data.Button, TweenInfo.new(0.2), {BackgroundColor3 = Theme.CardBg, BackgroundTransparency = Theme.CardTransparency}):Play()
                    Tween:Create(data.Label, TweenInfo.new(0.2), {TextColor3 = Theme.TextMuted}):Play()
                end
            end
        end)
    end

    createPresetCircle("Legit", "LEGIT")
    createPresetCircle("SemiLegit", "SEMI")
    createPresetCircle("Rage", "RAGE")

    return PresetContainer, presetButtonsMap
end

return Presets
