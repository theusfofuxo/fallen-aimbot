-- UI/Menu.lua
local UserInputService = game:GetService("UserInputService")
local Tween = require(script.Parent.Parent.Utils.Tween)
local Theme = require(script.Parent.Theme)
local Toggle = require(script.Parent.Toggle)
local Slider = require(script.Parent.Slider)
local Presets = require(script.Parent.Presets)

local Menu = {}

function Menu.build(targetGui, config, registerUpdate, updateFeature)
    -- Limpar interfaces antigas
    pcall(function() targetGui:FindFirstChild("PureMagnetUI"):Destroy() end)
    pcall(function() targetGui:FindFirstChild("MagnetRingsFolder"):Destroy() end)

    -- ScreenGui
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "PureMagnetUI"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.IgnoreGuiInset = true
    ScreenGui.DisplayOrder = 999999
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.Parent = targetGui

    -- Botão do menu
    local MenuButton = Instance.new("TextButton")
    MenuButton.Name = "MagnetCoreButton"
    MenuButton.Size = UDim2.new(0, 44, 0, 44)
    MenuButton.Position = UDim2.new(0, 25, 0, 200)
    MenuButton.BackgroundColor3 = Theme.Background
    MenuButton.BackgroundTransparency = Theme.BgTransparency
    MenuButton.Text = "🎯"
    MenuButton.TextSize = 17
    MenuButton.TextColor3 = Theme.Accent
    MenuButton.Font = Enum.Font.GothamBold
    MenuButton.Active = true
    MenuButton.Parent = ScreenGui
    Instance.new("UICorner", MenuButton).CornerRadius = UDim.new(1, 0)
    local btnStroke = Instance.new("UIStroke", MenuButton)
    btnStroke.Color = Theme.BorderColor
    btnStroke.Transparency = 0.7
    btnStroke.Thickness = 1.2

    -- Painel principal
    local MainPanel = Instance.new("Frame")
    MainPanel.Size = UDim2.new(0, 550, 0, 320)
    MainPanel.Position = UDim2.new(0.5, -275, 0.5, -160)
    MainPanel.BackgroundColor3 = Theme.Background
    MainPanel.BackgroundTransparency = Theme.BgTransparency
    MainPanel.ClipsDescendants = true
    MainPanel.Active = true
    MainPanel.Visible = false
    MainPanel.Parent = ScreenGui
    Instance.new("UICorner", MainPanel).CornerRadius = UDim.new(0, 16)
    local mainStroke = Instance.new("UIStroke", MainPanel)
    mainStroke.Color = Theme.BorderColor
    mainStroke.Transparency = 0.75
    mainStroke.Thickness = 1.2

    -- Drag
    local DragHandle = Instance.new("Frame", MainPanel)
    DragHandle.Size = UDim2.new(1, 0, 0, 28)
    DragHandle.BackgroundTransparency = 1
    DragHandle.Active = true

    local dragging, dragInput, dragStart, startPos
    DragHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = MainPanel.Position
            local releaseConn
            releaseConn = input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                    releaseConn:Disconnect()
                end
            end)
        end
    end)

    DragHandle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            MainPanel.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    -- Colunas
    local LeftColumn = Instance.new("Frame", MainPanel)
    LeftColumn.Size = UDim2.new(0, 140, 1, -24)
    LeftColumn.Position = UDim2.new(0, 10, 0, 12)
    LeftColumn.BackgroundTransparency = 1
    local LeftList = Instance.new("UIListLayout", LeftColumn)
    LeftList.Padding = UDim.new(0, 10)
    LeftList.SortOrder = Enum.SortOrder.LayoutOrder

    -- Navegação
    local NavContainer = Instance.new("Frame", LeftColumn)
    NavContainer.Size = UDim2.new(1, 0, 0, 28)
    NavContainer.BackgroundTransparency = 1
    NavContainer.LayoutOrder = 1
    local NavHorizontalList = Instance.new("UIListLayout", NavContainer)
    NavHorizontalList.FillDirection = Enum.FillDirection.Horizontal
    NavHorizontalList.Padding = UDim.new(0, 6)
    NavHorizontalList.SortOrder = Enum.SortOrder.LayoutOrder

    local function StyleNavHeader(frame)
        frame.BackgroundColor3 = Theme.CardBg
        frame.BackgroundTransparency = Theme.CardTransparency
        Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)
        local s = Instance.new("UIStroke", frame)
        s.Color = Theme.BorderColor
        s.Transparency = 0.85
    end

    local NavHeader1 = Instance.new("Frame", NavContainer)
    NavHeader1.Size = UDim2.new(0, 28, 0, 28)
    NavHeader1.ClipsDescendants = true
    NavHeader1.LayoutOrder = 1
    StyleNavHeader(NavHeader1)

    local NavLabel1 = Instance.new("TextButton", NavHeader1)
    NavLabel1.Size = UDim2.new(1, 0, 1, 0)
    NavLabel1.Text = "🎯"
    NavLabel1.TextSize = 12
    NavLabel1.TextColor3 = Theme.TextWhite
    NavLabel1.BackgroundTransparency = 1

    local NavText1 = Instance.new("TextLabel", NavHeader1)
    NavText1.Size = UDim2.new(1, -34, 1, 0)
    NavText1.Position = UDim2.new(0, 32, 0, 0)
    NavText1.Text = "Aim Assist"
    NavText1.TextColor3 = Theme.TextWhite
    NavText1.Font = Enum.Font.GothamBold
    NavText1.TextSize = 10
    NavText1.TextXAlignment = Enum.TextXAlignment.Left
    NavText1.BackgroundTransparency = 1
    NavText1.TextTransparency = 1

    local NavHeader2 = Instance.new("Frame", NavContainer)
    NavHeader2.Size = UDim2.new(0, 28, 0, 28)
    NavHeader2.ClipsDescendants = true
    NavHeader2.LayoutOrder = 2
    StyleNavHeader(NavHeader2)

    local NavLabel2 = Instance.new("TextButton", NavHeader2)
    NavLabel2.Size = UDim2.new(1, 0, 1, 0)
    NavLabel2.Text = "👑"
    NavLabel2.TextSize = 12
    NavLabel2.TextColor3 = Theme.TextWhite
    NavLabel2.BackgroundTransparency = 1

    local NavText2 = Instance.new("TextLabel", NavHeader2)
    NavText2.Size = UDim2.new(1, -34, 1, 0)
    NavText2.Position = UDim2.new(0, 32, 0, 0)
    NavText2.Text = "Owner Menu"
    NavText2.TextColor3 = Theme.TextWhite
    NavText2.Font = Enum.Font.GothamBold
    NavText2.TextSize = 10
    NavText2.TextXAlignment = Enum.TextXAlignment.Left
    NavText2.BackgroundTransparency = 1
    NavText2.TextTransparency = 1

    -- Cards de toggle (AimTracking, MagneticAssist)
    local function CreateGlassCard(order)
        local Card = Instance.new("Frame", LeftColumn)
        Card.Size = UDim2.new(1, 0, 0, 75)
        Card.Visible = true
        Card.ClipsDescendants = true
        Card.BackgroundColor3 = Theme.CardBg
        Card.BackgroundTransparency = Theme.CardTransparency
        Card.LayoutOrder = order
        Instance.new("UICorner", Card).CornerRadius = UDim.new(0, 12)
        local s = Instance.new("UIStroke", Card)
        s.Color = Theme.BorderColor
        s.Transparency = 0.88
        return Card
    end

    -- Toggle AimTracking (usando Toggle.create, mas adaptado para o card)
    local Card1 = CreateGlassCard(2)
    local C1_Txt = Instance.new("TextLabel", Card1)
    C1_Txt.Size = UDim2.new(1, -16, 0, 14)
    C1_Txt.Position = UDim2.new(0, 8, 0, 8)
    C1_Txt.Text = "Trava de Mira"
    C1_Txt.TextColor3 = Theme.TextWhite
    C1_Txt.Font = Enum.Font.GothamBold
    C1_Txt.TextSize = 10
    C1_Txt.TextXAlignment = Enum.TextXAlignment.Left
    C1_Txt.BackgroundTransparency = 1

    local C1_Sub = Instance.new("TextLabel", Card1)
    C1_Sub.Size = UDim2.new(1, -16, 0, 24)
    C1_Sub.Position = UDim2.new(0, 8, 0, 20)
    C1_Sub.Text = "Ativa o motor principal de rastreamento."
    C1_Sub.TextColor3 = Theme.TextMuted
    C1_Sub.Font = Enum.Font.Gotham
    C1_Sub.TextSize = 7.5
    C1_Sub.TextXAlignment = Enum.TextXAlignment.Left
    C1_Sub.TextWrapped = true
    C1_Sub.BackgroundTransparency = 1

    local C1_Btn = Instance.new("TextButton", Card1)
    C1_Btn.Size = UDim2.new(1, -16, 0, 22)
    C1_Btn.Position = UDim2.new(0, 8, 1, -28)
    C1_Btn.Font = Enum.Font.GothamBold
    C1_Btn.TextSize = 9
    Instance.new("UICorner", C1_Btn).CornerRadius = UDim.new(0, 8)
    local c1Stroke = Instance.new("UIStroke", C1_Btn)
    c1Stroke.Color = Theme.BorderColor

    local function refreshAimTracking()
        local isActive = config.AimTracking
        Tween:Create(C1_Btn, TweenInfo.new(0.2), {
            BackgroundColor3 = isActive and Theme.Accent or Theme.CardBg,
            BackgroundTransparency = isActive and 0.15 or 0.9,
            TextColor3 = isActive and Color3.new(1,1,1) or Theme.TextWhite
        }):Play()
        C1_Btn.Text = isActive and "Ligado" or "Desligado"
    end
    C1_Btn.MouseButton1Click:Connect(function()
        updateFeature("AimTracking", not config.AimTracking)
    end)
    if not registerUpdate.AimTracking then registerUpdate.AimTracking = {} end
    table.insert(registerUpdate.AimTracking, refreshAimTracking)
    refreshAimTracking()

    -- Toggle MagneticAssist (card 2)
    local Card2 = CreateGlassCard(3)
    local C2_Txt = Instance.new("TextLabel", Card2)
    C2_Txt.Size = UDim2.new(1, -16, 0, 14)
    C2_Txt.Position = UDim2.new(0, 8, 0, 8)
    C2_Txt.Text = "Assist. Magnético"
    C2_Txt.TextColor3 = Theme.TextWhite
    C2_Txt.Font = Enum.Font.GothamBold
    C2_Txt.TextSize = 10
    C2_Txt.TextXAlignment = Enum.TextXAlignment.Left
    C2_Txt.BackgroundTransparency = 1

    local C2_Sub = Instance.new("TextLabel", Card2)
    C2_Sub.Size = UDim2.new(1, -16, 0, 24)
    C2_Sub.Position = UDim2.new(0, 8, 0, 20)
    C2_Sub.Text = "Controla a fricção e os anéis ópticos 3D."
    C2_Sub.TextColor3 = Theme.TextMuted
    C2_Sub.Font = Enum.Font.Gotham
    C2_Sub.TextSize = 7.5
    C2_Sub.TextXAlignment = Enum.TextXAlignment.Left
    C2_Sub.TextWrapped = true
    C2_Sub.BackgroundTransparency = 1

    local C2_Btn = Instance.new("TextButton", Card2)
    C2_Btn.Size = UDim2.new(1, -16, 0, 22)
    C2_Btn.Position = UDim2.new(0, 8, 1, -28)
    C2_Btn.Font = Enum.Font.GothamBold
    C2_Btn.TextSize = 9
    Instance.new("UICorner", C2_Btn).CornerRadius = UDim.new(0, 8)
    local c2Stroke = Instance.new("UIStroke", C2_Btn)
    c2Stroke.Color = Theme.BorderColor

    local function refreshMagneticAssist()
        local isActive = config.MagneticAssist
        Tween:Create(C2_Btn, TweenInfo.new(0.2), {
            BackgroundColor3 = isActive and Theme.Accent or Theme.CardBg,
            BackgroundTransparency = isActive and 0.15 or 0.9,
            TextColor3 = isActive and Color3.new(1,1,1) or Theme.TextWhite
        }):Play()
        C2_Btn.Text = isActive and "Ligado" or "Desligado"
    end
    C2_Btn.MouseButton1Click:Connect(function()
        updateFeature("MagneticAssist", not config.MagneticAssist)
    end)
    if not registerUpdate.MagneticAssist then registerUpdate.MagneticAssist = {} end
    table.insert(registerUpdate.MagneticAssist, refreshMagneticAssist)
    refreshMagneticAssist()

    -- Presets (colocado após os cards)
    local presetContainer, presetMap = Presets.createButtons(LeftColumn, config, registerUpdate, updateFeature)
    presetContainer.LayoutOrder = 4
    presetContainer.Parent = LeftColumn

    -- Botão Reset
    local ResetBtn = Instance.new("TextButton", LeftColumn)
    ResetBtn.Size = UDim2.new(1, 0, 0, 26)
    ResetBtn.BackgroundColor3 = Theme.CardBg
    ResetBtn.BackgroundTransparency = Theme.CardTransparency
    ResetBtn.Text = "Restaurar Padrões"
    ResetBtn.TextColor3 = Theme.TextMuted
    ResetBtn.Font = Enum.Font.GothamBold
    ResetBtn.TextSize = 9.5
    ResetBtn.LayoutOrder = 5
    Instance.new("UICorner", ResetBtn).CornerRadius = UDim.new(0, 8)
    local rStroke = Instance.new("UIStroke", ResetBtn)
    rStroke.Color = Theme.BorderColor
    rStroke.Transparency = 0.88

    ResetBtn.MouseEnter:Connect(function()
        Tween:Create(ResetBtn, TweenInfo.new(0.2), {BackgroundTransparency = 0.8, TextColor3 = Theme.TextWhite}):Play()
    end)
    ResetBtn.MouseLeave:Connect(function()
        Tween:Create(ResetBtn, TweenInfo.new(0.2), {BackgroundTransparency = Theme.CardTransparency, TextColor3 = Theme.TextMuted}):Play()
    end)

    ResetBtn.MouseButton1Click:Connect(function()
        -- Restaurar padrões (implementar no Main via updateFeature)
        -- Para simplificar, vamos chamar updateFeature para cada default
        -- Mas precisamos de acesso ao DefaultConfig; passaremos por parâmetro.
        -- Vamos definir um callback no Main.
    end)

    -- Colunas central e direita (ScrollingFrames)
    local function CreateGridColumn(xOffset)
        local Scroller = Instance.new("ScrollingFrame", MainPanel)
        Scroller.Size = UDim2.new(0, 180, 1, -24)
        Scroller.Position = UDim2.new(0, xOffset, 0, 12)
        Scroller.BackgroundTransparency = 1
        Scroller.BorderSizePixel = 0
        Scroller.ScrollBarThickness = 2
        Scroller.ScrollBarImageColor3 = Theme.Accent
        Scroller.ScrollBarImageTransparency = 0.5
        Scroller.CanvasSize = UDim2.new(0, 0, 0, 0)
        Scroller.AutomaticCanvasSize = Enum.AutomaticSize.Y

        local ColumnCard = Instance.new("Frame", Scroller)
        ColumnCard.Size = UDim2.new(1, -8, 0, 0)
        ColumnCard.BackgroundColor3 = Theme.ColumnBg
        ColumnCard.BackgroundTransparency = Theme.ColTransparency
        ColumnCard.BorderSizePixel = 0
        ColumnCard.AutomaticSize = Enum.AutomaticSize.Y
        Instance.new("UICorner", ColumnCard).CornerRadius = UDim.new(0, 14)
        local cStroke = Instance.new("UIStroke", ColumnCard)
        cStroke.Color = Theme.BorderColor
        cStroke.Transparency = 0.9

        local List = Instance.new("UIListLayout", ColumnCard)
        List.Padding = UDim.new(0, 8)
        List.SortOrder = Enum.SortOrder.LayoutOrder
        local Pad = Instance.new("UIPadding", ColumnCard)
        Pad.PaddingTop = UDim.new(0, 12)
        Pad.PaddingBottom = UDim.new(0, 12)
        Pad.PaddingLeft = UDim.new(0, 10)
        Pad.PaddingRight = UDim.new(0, 10)

        return ColumnCard, Scroller
    end

    local CenterPane, CenterScroller = CreateGridColumn(165)
    local RightPane, RightScroller = CreateGridColumn(360)

    -- Owner Container
    local OwnerContainer = Instance.new("Frame", MainPanel)
    OwnerContainer.Size = UDim2.new(0, 375, 1, -24)
    OwnerContainer.Position = UDim2.new(0, 165, 0, 12)
    OwnerContainer.BackgroundColor3 = Theme.ColumnBg
    OwnerContainer.BackgroundTransparency = Theme.ColTransparency
    OwnerContainer.Visible = false
    Instance.new("UICorner", OwnerContainer).CornerRadius = UDim.new(0, 14)
    local oStroke = Instance.new("UIStroke", OwnerContainer)
    oStroke.Color = Theme.BorderColor
    oStroke.Transparency = 0.9

    local OwnerTitle = Instance.new("TextLabel", OwnerContainer)
    OwnerTitle.Size = UDim2.new(1, 0, 0, 40)
    OwnerTitle.Text = "PREMIUM SYSTEM"
    OwnerTitle.TextColor3 = Theme.TextWhite
    OwnerTitle.Font = Enum.Font.GothamBold
    OwnerTitle.TextSize = 14
    OwnerTitle.BackgroundTransparency = 1

    local OwnerDesc = Instance.new("TextLabel", OwnerContainer)
    OwnerDesc.Size = UDim2.new(1, -40, 1, -60)
    OwnerDesc.Position = UDim2.new(0, 20, 0, 40)
    OwnerDesc.Text = "Sistema v20.6.0 carregado com sucesso.\n\nFiltros anti-jitter integrados.\nControlador de amortecimento ativo.\nSliders reestruturados e fixados."
    OwnerDesc.TextColor3 = Theme.TextMuted
    OwnerDesc.Font = Enum.Font.Gotham
    OwnerDesc.TextSize = 10
    OwnerDesc.TextWrapped = true
    OwnerDesc.BackgroundTransparency = 1

    -- Criar os toggles e sliders usando os módulos
    -- Central
    Slider.create(CenterPane, "Raio de Trava (Lock)", "Círculo vermelho onde a mira fixa totalmente.", 0.5, 30.0, "MagneticLockRadius", config, registerUpdate)
    Slider.create(CenterPane, "Sensibilidade Base", "Velocidade/agilidade da resposta de movimento da câmera.", 0.1, 3.0, "BaseSensitivity", config, registerUpdate)
    Toggle.create(CenterPane, "Desacoplar Eixos X/Y", "Separa os eixos horizontal e vertical para suavizar.", "DecoupleXY", config, registerUpdate)
    Toggle.create(CenterPane, "Checagem de Parede", "Evita puxar a mira através de obstáculos.", "WallCheck", config, registerUpdate)
    Toggle.create(CenterPane, "Filtro de Equipe", "Ignora companheiros de equipe.", "TeamCheck", config, registerUpdate)

    -- Direita
    Toggle.create(RightPane, "Predição de Movimento", "Antecipa a posição do alvo baseado em velocidade.", "Prediction", config, registerUpdate)
    Slider.create(RightPane, "Intensidade da Predição", "Fator de avanço do cálculo preditivo.", 200.0, 3000.0, "BulletSpeed", config, registerUpdate)
    Slider.create(RightPane, "Anel de Redução", "Círculo amarelo que desacelera a mira ao se aproximar.", 5.0, 150.0, "SlowdownRing", config, registerUpdate)
    Slider.create(RightPane, "Anel de Atração", "Distância máxima para o magnetismo começar a agir.", 10.0, 500.0, "PullRingRadius", config, registerUpdate)
    Slider.create(RightPane, "Força Magnética", "Multiplicador de aceleração de puxada.", 0.5, 20.0, "MagneticAcceleration", config, registerUpdate)
    Slider.create(RightPane, "Correção de Fricção", "Amortece o balanço interno para estabilizar os eixos.", -10.0, 10.0, "MagneticCorrection", config, registerUpdate)
    Toggle.create(RightPane, "Exibir Círculo FOV", "Mostra o limite de FOV na tela.", "ShowFOVCircle", config, registerUpdate)
    Slider.create(RightPane, "Limite do FOV 2D", "Raio do círculo que define onde os alvos são considerados.", 10.0, 450.0, "AimFOVRadius", config, registerUpdate)
    Toggle.create(RightPane, "Substituir FOV", "Força um FOV customizado na sua câmera.", "CustomFOV", config, registerUpdate)
    Slider.create(RightPane, "Valor do FOV Angular", "Campo de visão personalizado em graus.", 30.0, 120.0, "FOVValue", config, registerUpdate)

    Toggle.create(RightPane, "Modo PID", "Ativa o controlador Proporcional-Integral-Derivativo.", "UsePID", config, registerUpdate)
    Slider.create(RightPane, "Kp (Proporcional)", "Resposta imediata ao erro. Valores altos = mais rápido.", 0.5, 20.0, "PID_Kp", config, registerUpdate)
    Slider.create(RightPane, "Ki (Integral)", "Corrige erros estáticos acumulados.", 0.0, 2.0, "PID_Ki", config, registerUpdate)
    Slider.create(RightPane, "Kd (Derivativo)", "Amortece oscilações prevendo a tendência do erro.", 0.0, 5.0, "PID_Kd", config, registerUpdate)
    Slider.create(RightPane, "Velocidade Máx. Angular", "Limite de giro (rad/s) para evitar movimentos bruscos.", 0.5, 15.0, "PID_MaxAngularSpeed", config, registerUpdate)
    Slider.create(RightPane, "Suavização do Alvo", "Filtro da posição do alvo (0 = sem filtro).", 0.0, 1.0, "PID_SmoothAim", config, registerUpdate)
    Slider.create(RightPane, "Suavização da Saída", "Amortece a resposta final do PID.", 0.0, 1.0, "PID_OutputSmooth", config, registerUpdate)

    -- Tab switching
    local activeTab = "AimAssist"
    local animInfo = TweenInfo.new(0.4, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out)

    local function SwitchTab(tabName)
        activeTab = tabName
        if activeTab == "AimAssist" then
            Tween:Create(NavHeader1, animInfo, {Size = UDim2.new(0, 95, 0, 28), BackgroundTransparency = 0.8}):Play()
            Tween:Create(NavText1, animInfo, {TextTransparency = 0}):Play()
            Tween:Create(NavHeader2, animInfo, {Size = UDim2.new(0, 28, 0, 28), BackgroundTransparency = Theme.CardTransparency}):Play()
            Tween:Create(NavText2, animInfo, {TextTransparency = 1}):Play()
            CenterScroller.Visible = true
            RightScroller.Visible = true
            OwnerContainer.Visible = false
        elseif activeTab == "Owner" then
            Tween:Create(NavHeader1, animInfo, {Size = UDim2.new(0, 28, 0, 28), BackgroundTransparency = Theme.CardTransparency}):Play()
            Tween:Create(NavText1, animInfo, {TextTransparency = 1}):Play()
            Tween:Create(NavHeader2, animInfo, {Size = UDim2.new(0, 105, 0, 28), BackgroundTransparency = 0.8}):Play()
            Tween:Create(NavText2, animInfo, {TextTransparency = 0}):Play()
            CenterScroller.Visible = false
            RightScroller.Visible = false
            OwnerContainer.Visible = true
        end
    end

    NavLabel1.MouseButton1Click:Connect(function() SwitchTab("AimAssist") end)
    NavLabel2.MouseButton1Click:Connect(function() SwitchTab("Owner") end)

    MenuButton.MouseButton1Click:Connect(function()
        MainPanel.Visible = not MainPanel.Visible
        if MainPanel.Visible then SwitchTab(activeTab) end
    end)

    -- Retornar objetos que outras partes precisam (ScreenGui, MainPanel, etc.)
    return {
        ScreenGui = ScreenGui,
        MainPanel = MainPanel,
        CenterScroller = CenterScroller,
        RightScroller = RightScroller,
        OwnerContainer = OwnerContainer,
        ResetBtn = ResetBtn,
        -- para o reset precisamos do DefaultConfig, trataremos no Main
    }
end

return Menu
