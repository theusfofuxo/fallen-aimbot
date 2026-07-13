-- UI/Slider.lua
local UserInputService = game:GetService("UserInputService")
local Tween = require(script.Parent.Parent.Utils.Tween)
local Theme = require(script.Parent.Theme)
local Math = require(script.Parent.Parent.Utils.Math)

local Slider = {}

function Slider.create(parent, titleText, descText, min, max, targetKey, config, registerUpdate)
    local RowFrame = Instance.new("Frame")
    RowFrame.Size = UDim2.new(1, 0, 0, 64)
    RowFrame.BackgroundTransparency = 1

    local Label = Instance.new("TextLabel", RowFrame)
    Label.Size = UDim2.new(1, -42, 0, 14)
    Label.Position = UDim2.new(0, 4, 0, 4)
    Label.Text = titleText
    Label.TextColor3 = Theme.TextWhite
    Label.Font = Enum.Font.GothamBold
    Label.TextSize = 9.5
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.BackgroundTransparency = 1

    local Sub = Instance.new("TextLabel", RowFrame)
    Sub.Size = UDim2.new(1, -42, 0, 22)
    Sub.Position = UDim2.new(0, 4, 0, 18)
    Sub.Text = descText
    Sub.TextColor3 = Theme.TextMuted
    Sub.Font = Enum.Font.Gotham
    Sub.TextSize = 7.5
    Sub.TextXAlignment = Enum.TextXAlignment.Left
    Sub.TextWrapped = true
    Sub.BackgroundTransparency = 1

    local ValLabel = Instance.new("TextLabel", RowFrame)
    ValLabel.Size = UDim2.new(0, 36, 0, 14)
    ValLabel.Position = UDim2.new(1, -40, 0, 4)
    ValLabel.TextColor3 = Theme.Accent
    ValLabel.Font = Enum.Font.GothamBold
    ValLabel.TextSize = 9.5
    ValLabel.TextXAlignment = Enum.TextXAlignment.Right
    ValLabel.BackgroundTransparency = 1

    local Track = Instance.new("TextButton", RowFrame)
    Track.Size = UDim2.new(1, -8, 0, 4)
    Track.Position = UDim2.new(0, 4, 0, 48)
    Track.BackgroundColor3 = Theme.TrackDark
    Track.BackgroundTransparency = 0.7
    Track.Text = ""
    Track.AutoButtonColor = false
    Instance.new("UICorner", Track).CornerRadius = UDim.new(1, 0)

    local Fill = Instance.new("Frame", Track)
    Fill.BackgroundColor3 = Theme.Accent
    Fill.Size = UDim2.new(0, 0, 1, 0)
    Instance.new("UICorner", Fill).CornerRadius = UDim.new(1, 0)

    local Knob = Instance.new("Frame", Track)
    Knob.Size = UDim2.new(0, 10, 0, 10)
    Knob.AnchorPoint = Vector2.new(0.5, 0.5)
    Knob.BackgroundColor3 = Color3.new(1, 1, 1)
    Instance.new("UICorner", Knob).CornerRadius = UDim.new(1, 0)
    local kStroke = Instance.new("UIStroke", Knob)
    kStroke.Color = Color3.fromRGB(0, 0, 0)

    local Divider = Instance.new("Frame", RowFrame)
    Divider.Size = UDim2.new(1, -8, 0, 1)
    Divider.Position = UDim2.new(0, 4, 1, -1)
    Divider.BackgroundColor3 = Theme.DividerColor
    Divider.BackgroundTransparency = 0.95
    Divider.BorderSizePixel = 0

    local isDragging = false

    local function updateSliderFromMouse()
        local trackPos = Track.AbsolutePosition
        local trackSize = Track.AbsoluteSize
        local mouseX = UserInputService:GetMouseLocation().X
        local scale = Math.clamp((mouseX - trackPos.X) / trackSize.X, 0, 1)
        local val = min + (max - min) * scale
        if max > 50 then
            val = math.round(val)
        else
            val = Math.round(val, 1)
        end
        config[targetKey] = val
        refreshVisuals()
        if registerUpdate and registerUpdate[targetKey] then
            for _, cb in ipairs(registerUpdate[targetKey]) do pcall(cb) end
        end
    end

    Track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isDragging = true
            Tween:Create(Knob, TweenInfo.new(0.15), {Size = UDim2.new(0, 13, 0, 13), BackgroundColor3 = Theme.Accent}):Play()
            updateSliderFromMouse()
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if isDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            updateSliderFromMouse()
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isDragging = false
            Tween:Create(Knob, TweenInfo.new(0.15), {Size = UDim2.new(0, 10, 0, 10), BackgroundColor3 = Color3.new(1, 1, 1)}):Play()
        end
    end)

    local function refreshVisuals()
        local scale = Math.clamp((config[targetKey] - min) / (max - min), 0, 1)
        Knob.Position = UDim2.new(scale, 0, 0.5, 0)
        Fill.Size = UDim2.new(scale, 0, 1, 0)
        if max > 50 then
            ValLabel.Text = string.format("%d", config[targetKey])
        else
            ValLabel.Text = string.format("%.1f", config[targetKey])
        end
    end

    if registerUpdate then
        if not registerUpdate[targetKey] then registerUpdate[targetKey] = {} end
        table.insert(registerUpdate[targetKey], refreshVisuals)
    end

    refreshVisuals()
    RowFrame.Parent = parent
    return RowFrame
end

return Slider
