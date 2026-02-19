local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer.WaitForChild("PlayerGui")

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = PlayerGui
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.IgnoreGuiInset = true

-- 主窗口
local Main = Instance.new("Frame")
Main.Size = UDim2.new(0.9, 0, 0.75, 0)
Main.Position = UDim2.new(0.05, 0, 0.12, 0)
Main.BackgroundTransparency = 1
Main.ClipsDescendants = true
Main.Rotation = -25
Main.BackgroundColor3 = Color3.new(1,1,1)
Main.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 20)
UICorner.Parent = Main

local UIGradient = Instance.new("UIGradient")
UIGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(255,60,80)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(90,80,255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(255,140,60)),
})
UIGradient.Rotation = 45
UIGradient.Parent = Main

-- 入场动画
task.wait(0.1)
local openTween = TweenService:Create(Main, TweenInfo.new(0.7, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
    Rotation = 0,
    BackgroundTransparency = 0
})
openTween:Play()

-- 顶部栏
local Top = Instance.new("Frame")
Top.Size = UDim2.new(1,0,0,60)
Top.BackgroundTransparency = 0.7
Top.BackgroundColor3 = Color3.new(1,1,1)
Top.Parent = Main

local topCorner = Instance.new("UICorner")
topCorner.CornerRadius = UDim.new(0,20)
topCorner.Parent = Top

local function CreateBtn(text, x)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0,50,0,50)
    btn.Position = UDim2.new(1, x, 0, 5)
    btn.BackgroundTransparency = 0.6
    btn.BackgroundColor3 = Color3.new(1,1,1)
    btn.Text = text
    btn.TextColor3 = Color3.new(1,1,1)
    btn.TextSize = 24
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(1,0)
    c.Parent = btn
    btn.Parent = Top
    return btn
end

local CloseBtn = CreateBtn("X", -60)
local MinBtn = CreateBtn("—", -120)

-- 内容区
local Content = Instance.new("Frame")
Content.Size = UDim2.new(1,-20,1,-70)
Content.Position = UDim2.new(0,10,0,65)
Content.BackgroundTransparency = 1
Content.Parent = Main

local list = Instance.new("UIListLayout")
list.Padding = UDim.new(0,12)
list.Parent = Content

-- 滑块创建函数
local function CreateSlider(name, default, min, max)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1,0,0,70)
    frame.BackgroundTransparency = 0.75
    frame.BackgroundColor3 = Color3.new(1,1,1)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0,12)
    corner.Parent = frame
    frame.Parent = Content

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.3,0,0,30)
    label.Position = UDim2.new(0.05,0,0,5)
    label.BackgroundTransparency = 1
    label.Text = name
    label.TextColor3 = Color3.new(1,1,1)
    label.TextSize = 18
    label.Parent = frame

    local valueLabel = Instance.new("TextLabel")
    valueLabel.Size = UDim2.new(0.2,0,0,30)
    valueLabel.Position = UDim2.new(0.75,0,0,5)
    valueLabel.BackgroundTransparency = 1
    valueLabel.Text = tostring(default)
    valueLabel.TextColor3 = Color3.new(1,1,1)
    valueLabel.TextSize = 18
    valueLabel.Parent = frame

    local back = Instance.new("Frame")
    back.Size = UDim2.new(0.65,0,0,12)
    back.Position = UDim2.new(0.05,0,0.5,0)
    back.BackgroundColor3 = Color3.new(0.2,0.2,0.2)
    local bc = Instance.new("UICorner")
    bc.CornerRadius = UDim.new(1,0)
    bc.Parent = back
    back.Parent = frame

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((default-min)/(max-min),0,1,0)
    fill.BackgroundColor3 = Color3.fromRGB(80,180,255)
    local fc = Instance.new("UICorner")
    fc.CornerRadius = UDim.new(1,0)
    fc.Parent = fill
    fill.Parent = back

    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0,24,0,24)
    knob.Position = UDim2.new(fill.Size.X.Scale, -12, 0.5, -12)
    knob.BackgroundColor3 = Color3.new(1,1,1)
    local kc = Instance.new("UICorner")
    kc.CornerRadius = UDim.new(1,0)
    kc.Parent = knob
    knob.Parent = back
    knob.ZIndex = 10

    local value = default
    local min = min
    local max = max

    knob.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            local dragging = true
            while dragging and task.wait() do
                local pos = UserInputService:GetMouseLocation().X
                local abs = back.AbsolutePosition.X
                local size = back.AbsoluteSize.X
                local scale = math.clamp((pos - abs) / size, 0, 1)
                value = math.round(min + (max-min)*scale)
                fill.Size = UDim2.new(scale,0,1,0)
                knob.Position = UDim2.new(scale, -12, 0.5, -12)
                valueLabel.Text = tostring(value)
            end
        end
    end)

    knob.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    return function() return value end
end

-- 创建滑块
local getSpeed = CreateSlider("移动速度", 32, 16, 100)
local getJump = CreateSlider("跳跃高度", 50, 50, 200)

-- 执行按钮
local btnFrame = Instance.new("Frame")
btnFrame.Size = UDim2.new(1,0,0,70)
btnFrame.BackgroundTransparency = 0.75
btnFrame.BackgroundColor3 = Color3.new(1,1,1)
local btnCorner = Instance.new("UICorner")
btnCorner.CornerRadius = UDim.new(0,12)
btnCorner.Parent = btnFrame
btnFrame.Parent = Content

local applyBtn = Instance.new("TextButton")
applyBtn.Size = UDim2.new(0.9,0,0.5,0)
applyBtn.Position = UDim2.new(0.05,0,0.25,0)
applyBtn.BackgroundColor3 = Color3.fromRGB(80,180,255)
applyBtn.Text = "应用速度与跳跃"
applyBtn.TextColor3 = Color3.new(1,1,1)
applyBtn.TextSize = 20
local ac = Instance.new("UICorner")
ac.CornerRadius = UDim.new(0,10)
ac.Parent = applyBtn
applyBtn.Parent = btnFrame

applyBtn.MouseButton1Click:Connect(function()
    applyBtn.Text = "应用中..."
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local hum = char:WaitForChild("Humanoid")
    hum.WalkSpeed = getSpeed()
    hum.JumpPower = getJump()
    task.wait(0.5)
    applyBtn.Text = "应用成功！"
    task.wait(1)
    applyBtn.Text = "应用速度与跳跃"
end)

-- 执行你的脚本按钮
local loadBtnFrame = Instance.new("Frame")
loadBtnFrame.Size = UDim2.new(1,0,0,70)
loadBtnFrame.BackgroundTransparency = 0.75
loadBtnFrame.BackgroundColor3 = Color3.new(1,1,1)
local lc = Instance.new("UICorner")
lc.CornerRadius = UDim.new(0,12)
lc.Parent = loadBtnFrame
loadBtnFrame.Parent = Content

local loadBtn = Instance.new("TextButton")
loadBtn.Size = UDim2.new(0.9,0,0.5,0)
loadBtn.Position = UDim2.new(0.05,0,0.25,0)
loadBtn.BackgroundColor3 = Color3.fromRGB(255,80,80)
loadBtn.Text = "加载外部脚本"
loadBtn.TextColor3 = Color3.new(1,1,1)
loadBtn.TextSize = 20
local lbc = Instance.new("UICorner")
lbc.CornerRadius = UDim.new(0,10)
lbc.Parent = loadBtn
loadBtn.Parent = loadBtnFrame

loadBtn.MouseButton1Click:Connect(function()
    loadBtn.Text = "加载中..."
    loadstring(game:HttpGet("https://raw.githubusercontent.com/Beifengmon/-a/ad2f5d6f83198503e384921a7bc71aeb29dd54dc/%E5%88%91%E5%A4%A9.lua", true))()
    loadBtn.Text = "加载完成！"
    task.wait(1.5)
    loadBtn.Text = "加载外部脚本"
end)

-- 缩小关闭
MinBtn.MouseButton1Click:Connect(function()
    Main.Size = UDim2.new(0.4,0,0,70)
    Main.Position = UDim2.new(0.05,0,0.05,0)
    Content.Visible = false
end)

CloseBtn.MouseButton1Click:Connect(function()
    Main.Visible = false
end)

-- 拖动
local dragging = false
local dragStart, startPos

Top.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = Main.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.TouchMovement or input.UserInputType == Enum.UserInputType.MouseMovement) then
        local delta = input.Position - dragStart
        Main.Position = UDim2.new(0, startPos.X.Offset + delta.X, 0, startPos.Y.Offset + delta.Y)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)
