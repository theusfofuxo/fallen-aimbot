-- Main.lua
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

-- Importar módulos
local Math = require(script.Utils.Math)
local Tween = require(script.Utils.Tween)
local PID = require(script.Core.PID)
local Prediction = require(script.Core.Prediction)
local WallCheck = require(script.Core.WallCheck)
local AimController = require(script.Core.AimController)
local Theme = require(script.UI.Theme)
local Toggle = require(script.UI.Toggle)
local Slider = require(script.UI.Slider)
local Presets = require(script.UI.Presets)
local Menu = require(script.UI.Menu)
local Rings = require(script.Render.Rings)
local FOV = require(script.Render.FOV)

-- ============================================================
-- CONFIGURAÇÃO
-- ============================================================
local Config = {
    AimTracking = true,
    MagneticAssist = true,
    MagneticLockRadius = 6.5,
    BaseSensitivity = 0.15,
    DecoupleXY = true,
    SlowdownRing = 30.0,
    PullRingRadius = 120.0,
    MagneticAcceleration = 4.0,
    MagneticCorrection = -2.0,
    WallCheck = false,
    TeamCheck = false,
    CustomFOV = false,
    FOVValue = 90.0,
    ShowFOVCircle = true,
    AimFOVRadius = 120.0,
    Prediction = true,
    BulletSpeed = 1100.0,

    UsePID = false,
    PID_Kp = 5.0,
    PID_Ki = 0.05,
    PID_Kd = 0.8,
    PID_MaxAngularSpeed = 4.0,
    PID_SmoothAim = 0.6,
    PID_OutputSmooth = 0.4
}

local DefaultConfig = {}
for k, v in pairs(Config) do DefaultConfig[k] = v end

-- ============================================================
-- SISTEMA DE ATUALIZAÇÃO DE UI
-- ============================================================
local UIUpdates = {}

local function RegisterUpdate(target, callback)
    if not UIUpdates[target] then UIUpdates[target] = {} end
    table.insert(UIUpdates[target], callback)
end

local function UpdateFeature(target, value)
    Config[target] = value
    -- Atualizar parâmetros do PID se necessário
    if target == "PID_Kp" then
        -- Precisamos acessar os PIDs do AimController, mas eles são internos.
        -- Podemos expor uma função para atualizar os ganhos.
        -- Como o AimController usa os valores diretamente do Config, não precisamos atualizar separadamente.
        -- Mas se quisermos, podemos chamar AimController.updateGains(Config)
    end
    if UIUpdates[target] then
        for _, cb in ipairs(UIUpdates[target]) do pcall(cb) end
    end
end

-- ============================================================
-- INICIALIZAÇÃO DA UI
-- ============================================================
local CameraCache = { Current = Workspace.CurrentCamera }
Workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
    CameraCache.Current = Workspace.CurrentCamera
end)

local TargetGui
if gethui then
    TargetGui = gethui()
elseif pcall(function() return game:GetService("CoreGui"):FindFirstChild("RobloxGui") end) then
    TargetGui = game:GetService("CoreGui")
else
    TargetGui = LocalPlayer:WaitForChild("PlayerGui", 15)
end

-- Criar pasta de anéis (usada pelo Render/Rings)
local RingsFolder = Instance.new("Folder")
RingsFolder.Name = "MagnetRingsFolder"
RingsFolder.Parent = TargetGui

-- Construir menu
local menuData = Menu.build(TargetGui, Config, UIUpdates, UpdateFeature)
local ScreenGui = menuData.ScreenGui
local MainPanel = menuData.MainPanel

-- Criar o círculo FOV
local visualFOVCircle = FOV.create(ScreenGui, Config)

-- ============================================================
-- CONFIGURAR RESET
-- ============================================================
menuData.ResetBtn.MouseButton1Click:Connect(function()
    for featureName, defaultValue in pairs(DefaultConfig) do
        UpdateFeature(featureName, defaultValue)
    end
    -- Atualizar todos os elementos UI
    for featureName, _ in pairs(DefaultConfig) do
        if UIUpdates[featureName] then
            for _, cb in ipairs(UIUpdates[featureName]) do pcall(cb) end
        end
    end
end)

-- ============================================================
-- GERENCIAMENTO DE CONEXÕES E ESTADO DE ANÉIS
-- ============================================================
local ENV = (getgenv and getgenv()) or _G
if ENV.MagnetConnections then
    for _, conn in ipairs(ENV.MagnetConnections) do
        pcall(function() conn:Disconnect() end)
    end
end
ENV.MagnetConnections = {}

local function onPlayerRemoved(player)
    Rings.clearPlayerRings(player)
    WallCheck.clearCache() -- opcional
end

table.insert(ENV.MagnetConnections, Players.PlayerRemoving:Connect(onPlayerRemoved))
for _, p in ipairs(Players:GetPlayers()) do
    table.insert(ENV.MagnetConnections, p.CharacterAdded:Connect(function() 
        Rings.clearPlayerRings(p) 
        WallCheck.clearCache()
    end))
end
table.insert(ENV.MagnetConnections, Players.PlayerAdded:Connect(function(p)
    table.insert(ENV.MagnetConnections, p.CharacterAdded:Connect(function()
        Rings.clearPlayerRings(p)
        WallCheck.clearCache()
    end))
end))

-- ============================================================
-- LOOP PRINCIPAL
-- ============================================================
local function isValidTarget(player)
    if not player or player == LocalPlayer or not player.Character then return false end
    if Config.TeamCheck and player.Team and LocalPlayer.Team and player.Team == LocalPlayer.Team then return false end

    local head = player.Character:FindFirstChild("Head")
    local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
    if not head or not humanoid or humanoid.Health <= 0 then return false end

    if Config.WallCheck then
        local cam = CameraCache.Current
        if not cam then return false end
        return WallCheck.isVisible(player, cam, LocalPlayer.Character, player.Character, head)
    end
    return true
end

local runConnection = RunService.PreRender:Connect(function(deltaTime)
    local cam = CameraCache.Current
    if not cam then return end

    -- Atualizar FOV
    FOV.update(visualFOVCircle, Config, cam)

    local myChar = LocalPlayer.Character
    local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
    if not myRoot then return end

    local closestTarget = nil
    local shortestDist2D = Config.AimFOVRadius

    for _, player in ipairs(Players:GetPlayers()) do
        local rings = Rings.getCharacterRings(player, RingsFolder)
        local valid = isValidTarget(player)

        if valid and player.Character then
            local targetRoot = player.Character:FindFirstChild("HumanoidRootPart") or player.Character:FindFirstChild("Head")
            local targetHead = player.Character:FindFirstChild("Head")
            if targetRoot and targetHead then
                local distance3D = (targetHead.Position - myRoot.Position).Magnitude
                local screenPos, onScreen = cam:WorldToViewportPoint(targetHead.Position)

                if onScreen then
                    local screenCenter = Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y / 2)
                    local dist2D = (Vector2.new(screenPos.X, screenPos.Y) - screenCenter).Magnitude
                    if dist2D <= Config.AimFOVRadius and dist2D < shortestDist2D then
                        shortestDist2D = dist2D
                        closestTarget = targetHead
                    end
                end

                -- Atualizar anéis
                Rings.updateRings(player, rings, Config, cam, valid, onScreen, 0, distance3D)
            else
                Rings.updateRings(player, rings, Config, cam, false, false, 0, 0)
            end
        else
            Rings.updateRings(player, rings, Config, cam, false, false, 0, 0)
        end
    end

    -- Aplicar aim se houver alvo
    if Config.AimTracking and closestTarget then
        AimController.applyAim(deltaTime, cam, myRoot, closestTarget, Config)
    else
        AimController.reset()
    end
end)

table.insert(ENV.MagnetConnections, runConnection)

print("PureMagnet HUD v20.6.0 carregado com sucesso! (Modularizado)")
