-- Essentials – Script Loader (with keep-on-teleport)

local Players = game:GetService("Players")

-- ====== AUTO REEXECUTE ON TELEPORT (KEEP LOADER) ======
local queue = queue_on_teleport or queueteleport or syn and syn.queue_on_teleport
local LOADER_URL = "https://raw.githubusercontent.com/HKS-M4/essentials-loader/main/loader.lua"

if queue and not getgenv()._EssentialsKeepInit then
    getgenv()._EssentialsKeepInit = true
    Players.LocalPlayer.OnTeleport:Connect(function(state)
        if state == Enum.TeleportState.Started then
            queue(string.format([[
                loadstring(game:HttpGet(%q))()
            ]], LOADER_URL))
        end
    end)
end
-- ======================================================

local TweenService = game:GetService("TweenService")

local lp = Players.LocalPlayer
local playerGui = lp:WaitForChild("PlayerGui")

-- Destroy old hub if re-run
local old = playerGui:FindFirstChild("ScriptHub")
if old then old:Destroy() end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ScriptHub"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.Parent = playerGui

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 260, 0, 165)
mainFrame.Position = UDim2.new(0.5, -130, 0.22, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(5, 3, 15)
mainFrame.BorderSizePixel = 0
mainFrame.BackgroundTransparency = 0.02
mainFrame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 10)
corner.Parent = mainFrame

local stroke = Instance.new("UIStroke")
stroke.Thickness = 4
stroke.LineJoinMode = Enum.LineJoinMode.Round
stroke.Color = Color3.fromRGB(140, 90, 255)
stroke.Transparency = 0.12
stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
stroke.Parent = mainFrame

task.spawn(function()
    while mainFrame.Parent do
        TweenService:Create(
            stroke,
            TweenInfo.new(1.3, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
            {Transparency = 0.65, Thickness = 3}
        ):Play()
        task.wait(1.3)
        TweenService:Create(
            stroke,
            TweenInfo.new(1.3, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
            {Transparency = 0.05, Thickness = 5}
        ):Play()
        task.wait(1.3)
    end
end)

local grad = Instance.new("UIGradient")
grad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(60, 25, 190)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(20, 8, 60))
})
grad.Rotation = 90
grad.Parent = mainFrame

-- Title
local title = Instance.new("TextLabel")
title.BackgroundTransparency = 1
title.Size = UDim2.new(1, -40, 0, 20)
title.Position = UDim2.new(0, 8, 0, 4)
title.Font = Enum.Font.GothamSemibold
title.TextSize = 14
title.TextColor3 = Color3.fromRGB(240, 235, 255)
title.TextXAlignment = Enum.TextXAlignment.Left
title.Text = "Essentials – Script Loader"
title.Parent = mainFrame

local subtitle = Instance.new("TextLabel")
subtitle.BackgroundTransparency = 1
subtitle.Size = UDim2.new(1, -10, 0, 16)
subtitle.Position = UDim2.new(0, 8, 0, 24)
subtitle.Font = Enum.Font.Gotham
subtitle.TextSize = 11
subtitle.TextColor3 = Color3.fromRGB(190, 180, 240)
subtitle.TextXAlignment = Enum.TextXAlignment.Left
subtitle.Text = "Select scripts to run"
subtitle.Parent = mainFrame

-- Close button (X)
local closeButton = Instance.new("TextButton")
closeButton.Size = UDim2.new(0, 24, 0, 24)
closeButton.Position = UDim2.new(1, -28, 0, 6)
closeButton.BackgroundColor3 = Color3.fromRGB(35, 20, 90)
closeButton.AutoButtonColor = true
closeButton.Text = "X"
closeButton.Font = Enum.Font.GothamSemibold
closeButton.TextSize = 12
closeButton.TextColor3 = Color3.fromRGB(235, 230, 255)
closeButton.Parent = mainFrame

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 6)
closeCorner.Parent = closeButton

local closeStroke = Instance.new("UIStroke")
closeStroke.Thickness = 1.5
closeStroke.Color = Color3.fromRGB(180, 120, 255)
closeStroke.Transparency = 0.2
closeStroke.Parent = closeButton

closeButton.MouseButton1Click:Connect(function()
    local tween = TweenService:Create(
        mainFrame,
        TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        {BackgroundTransparency = 1}
    )
    tween:Play()
    tween.Completed:Connect(function()
        screenGui:Destroy()
    end)
end)

------------------------------------------------
-- DRAGGING
------------------------------------------------
do
    local dragging = false
    local dragStart
    local startOffset
    local currentTween

    local function tweenTo(pos, duration)
        if currentTween then currentTween:Cancel() end
        local tweenInfo = TweenInfo.new(
            duration,
            Enum.EasingStyle.Sine,
            Enum.EasingDirection.Out
        )
        currentTween = TweenService:Create(mainFrame, tweenInfo, {Position = pos})
        currentTween:Play()
    end

    local function getViewportSize()
        return screenGui.AbsoluteSize.X > 0 and screenGui.AbsoluteSize
            or (workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(1920, 1080))
    end

    local function clampToScreen(offsetX, offsetY)
        local viewportSize = getViewportSize()
        local frameSize = mainFrame.AbsoluteSize
        local x = math.clamp(offsetX, 0, viewportSize.X - frameSize.X)
        local y = math.clamp(offsetY, 0, viewportSize.Y - frameSize.Y)
        return UDim2.new(0, x, 0, y)
    end

    mainFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            local viewportSize = getViewportSize()
            local pos = mainFrame.Position
            local currentX = pos.X.Scale * viewportSize.X + pos.X.Offset
            local currentY = pos.Y.Scale * viewportSize.Y + pos.Y.Offset
            startOffset = Vector2.new(currentX, currentY)
            if currentTween then currentTween:Cancel() end
        end
    end)

    mainFrame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement and dragging then
            local delta = input.Position - dragStart
            local newOffsetX = startOffset.X + delta.X
            local newOffsetY = startOffset.Y + delta.Y
            mainFrame.Position = clampToScreen(newOffsetX, newOffsetY)
        end
    end)

    mainFrame.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 and dragging then
            dragging = false
            tweenTo(mainFrame.Position, 0.4)
        end
    end)
end

------------------------------------------------
-- BUTTON LIST
------------------------------------------------
local buttonHolder = Instance.new("Frame")
buttonHolder.BackgroundTransparency = 1
buttonHolder.Size = UDim2.new(1, -10, 0, 120)
buttonHolder.Position = UDim2.new(0, 5, 0, 50)
buttonHolder.Parent = mainFrame

local listLayout = Instance.new("UIListLayout")
listLayout.FillDirection = Enum.FillDirection.Vertical
listLayout.Padding = UDim.new(0, 6)
listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
listLayout.VerticalAlignment = Enum.VerticalAlignment.Top
listLayout.Parent = buttonHolder

local function createButton(text)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -10, 0, 22)
    btn.BackgroundColor3 = Color3.fromRGB(35, 20, 90)
    btn.AutoButtonColor = true
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 13
    btn.TextColor3 = Color3.fromRGB(235, 230, 255)
    btn.Text = text

    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 6)
    c.Parent = btn

    btn.Parent = buttonHolder
    return btn
end

-- Buttons
local invisBtn    = createButton("FE Invisibility (Universal)")
local flinguiBtn  = createButton("FE Fling GUI (R6 & R15 Support)")
local infyieldBtn = createButton("Infinite Yield (Universal)")
local mm2espBtn   = createButton("MM2 ESP")

-- Script bindings
invisBtn.MouseButton1Click:Connect(function()
    loadstring(game:HttpGet("https://gist.githubusercontent.com/HKS-M4/4fdaa1a8c4d9fb60fc93967c7bc8fd0e/raw/b1c8a68997d5281b5686108d823c166334b1da32/FE%2520INVIS%2520NEW.lua"))()
end)

flinguiBtn.MouseButton1Click:Connect(function()
    loadstring(game:HttpGet("https://gist.githubusercontent.com/HKS-M4/3ba6217f9f785e4610c0da13a1f3bd04/raw/150a2ee3ab833ce55aa33d87cacb471790d32d23/FE%2520NEW%2520Fling%2520UI%2520%255BR6+R15%255D.lua"))()
end)

infyieldBtn.MouseButton1Click:Connect(function()
    loadstring(game:HttpGet("https://gist.githubusercontent.com/HKS-M4/183eb1e1f97c0af8c4e6c2aabc7dd9bf/raw/7876bcb91001c089cd2544879f7a720701e7feb7/Infyield.lua"))()
end)

mm2espBtn.MouseButton1Click:Connect(function()
    loadstring(game:HttpGet("https://gist.githubusercontent.com/HKS-M4/cefc0b0aedc91b9ef36becbbe9315adb/raw/bc99590f872024842ba0a27addd2f251b8e84c31/MM2%2520ESP.lua"))()
end)
