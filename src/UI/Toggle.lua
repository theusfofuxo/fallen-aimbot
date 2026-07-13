-- UI/Toggle.lua
local Tween = require(script.Parent.Parent.Utils.Tween)
local Theme = require(script.Parent.Theme)

local Toggle = {}

function Toggle.create(parent, titleText, descText, targetKey, config, registerUpdate)
    local RowFrame = Instance.new("Frame")
    RowFrame.Size = UDim2.new(1, 0, 0, 46)
    RowFrame.BackgroundTransparency = 1

    local Label = Instance.new("TextLabel", RowFrame)
    Label.Size = UDim2.new(1, -45, 0, 14)
    Label.Position = UDim2.new(0, 4, 0, 4)
    Label.Text = titleText
    Label.TextColor3 = Theme.TextWhite
    Label.Font = Enum.Font.GothamBold
    Label.TextSize = 9.5
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.BackgroundTransparency = 1

    local Sub = Instance.new("TextLabel", RowFrame)
    Sub.Size = UDim2.new(1, -45, 0, 22)
    Sub.Position = UDim2.new(0, 4, 0, 18)
    Sub.Text = descText
    Sub.TextColor3 = Theme.TextMuted
    Sub.Font = Enum.Font.Gotham
    Sub.TextSize = 7.5
    Sub.TextXAlignment = Enum.TextXAlignment.Left
    Sub.TextWrapped = true
    Sub.BackgroundTransparency = 1

    local Switch = Instance.new("TextButton", RowFrame)
    Switch.Size = UDim2.new(0, 32, 0, 18)
    Switch.Position = UDim2.new(1, -34, 0, 14)
    Switch.Text = ""
    Switch.AutoButtonColor = false
    Instance.new("UICorner", Switch).CornerRadius = UDim.new(1, 0)
    local sStroke = Instance.new("UIStroke", Switch)
    sStroke.Color = Color3.fromRGB(80, 80, 85)

    local Knob = Instance.new("Frame", Switch)
    Knob.Size = UDim2.new(0, 14, 0, 14)
    Knob.Position = UDim2.new(0, 2, 0, 2)
    Instance.new("UICorner", Knob).CornerRadius = UDim.new(1, 0)

    local Divider = Instance.new("Frame", RowFrame)
    Divider.Size = UDim2.new(1, -8, 0, 1)
    Divider.Position = UDim2.new(0, 4, 1, -1)
    Divider.BackgroundColor3 = Theme.DividerColor
    Divider.BackgroundTransparency = 0.95
    Divider.BorderSizePixel = 0

    local function refresh()
        local enabled = config[targetKey]
        Tween:Create(Switch, TweenInfo.new(0.2), {
            BackgroundColor3 = enabled and Theme.Accent or Color3.fromRGB(50, 50, 55),
            BackgroundTransparency = enabled and 0.1 or 0.4
        }):Play()
        Tween:Create(Knob, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Position = enabled and UDim2.new(1, -16, 0, 2) or UDim2.new(0, 2, 0, 2),
            BackgroundColor3 = Color3.new(1, 1, 1)
        }):Play()
    end

    Switch.MouseButton1Click:Connect(function()
        config[targetKey] = not config[targetKey]
        refresh()
        if registerUpdate and registerUpdate[targetKey] then
            for _, cb in ipairs(registerUpdate[targetKey]) do pcall(cb) end
        end
    end)

    -- Register for external updates
    if registerUpdate then
        if not registerUpdate[targetKey] then registerUpdate[targetKey] = {} end
        table.insert(registerUpdate[targetKey], refresh)
    end

    refresh()
    RowFrame.Parent = parent
    return RowFrame
end

return Toggle
