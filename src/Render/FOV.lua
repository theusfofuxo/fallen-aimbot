-- Render/FOV.lua
local Theme = require(script.Parent.Parent.UI.Theme)

local FOV = {}

function FOV.create(screenGui, config)
    local VisualFOVCircle = Instance.new("Frame")
    VisualFOVCircle.Name = "DynamicFOVCircle"
    VisualFOVCircle.AnchorPoint = Vector2.new(0.5, 0.5)
    VisualFOVCircle.Position = UDim2.new(0.5, 0, 0.5, 0)
    VisualFOVCircle.BackgroundTransparency = 1
    VisualFOVCircle.Visible = config.ShowFOVCircle
    VisualFOVCircle.Parent = screenGui
    Instance.new("UICorner", VisualFOVCircle).CornerRadius = UDim.new(1, 0)
    local fovStroke = Instance.new("UIStroke", VisualFOVCircle)
    fovStroke.Color = Theme.Accent
    fovStroke.Thickness = 1.0
    fovStroke.Transparency = 0.5

    return VisualFOVCircle
end

function FOV.update(visualFOVCircle, config, camera)
    if not visualFOVCircle then return end
    visualFOVCircle.Visible = config.ShowFOVCircle
    local fovDiameter = config.AimFOVRadius * 2
    visualFOVCircle.Size = UDim2.new(0, fovDiameter, 0, fovDiameter)

    -- Aplicar FOV customizado se habilitado
    if config.CustomFOV then
        camera.FieldOfView = config.FOVValue
    end
    -- Nota: se desativado, o FOV volta ao valor padrão do jogo (não controlado aqui)
end

return FOV
