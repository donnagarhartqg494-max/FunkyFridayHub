
-- FunkyFridayHub V1
-- Roblox / Solara
-- GUI + manual key controls

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")

local Player = Players.LocalPlayer
local Running = false
local MenuVisible = true
local Unloaded = false

local Keys = {
    Enum.KeyCode.D,
    Enum.KeyCode.F,
    Enum.KeyCode.Space,
    Enum.KeyCode.J,
    Enum.KeyCode.K
}

local Screen = Instance.new("ScreenGui")
Screen.Name = "FunkyFridayHub"
Screen.ResetOnSpawn = false
Screen.Parent = game:GetService("CoreGui")

local Main = Instance.new("Frame")
Main.Size = UDim2.fromOffset(420, 330)
Main.Position = UDim2.new(0.5, -210, 0.5, -165)
Main.BackgroundColor3 = Color3.fromRGB(20, 22, 30)
Main.BorderSizePixel = 0
Main.Parent = Screen

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 12)
Corner.Parent = Main

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 50)
Title.BackgroundTransparency = 1
Title.Text = "FunkyFridayHub"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 23
Title.Font = Enum.Font.GothamBold
Title.Parent = Main

local Status = Instance.new("TextLabel")
Status.Position = UDim2.fromOffset(20, 65)
Status.Size = UDim2.new(1, -40, 0, 30)
Status.BackgroundTransparency = 1
Status.Text = "STATUS: STOPPED"
Status.TextColor3 = Color3.fromRGB(255, 100, 100)
Status.TextSize = 15
Status.Font = Enum.Font.Gotham
Status.Parent = Main

local function createButton(name, y, callback)
    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(1, -40, 0, 42)
    Button.Position = UDim2.fromOffset(20, y)
    Button.BackgroundColor3 = Color3.fromRGB(43, 48, 65)
    Button.Text = name
    Button.TextColor3 = Color3.new(1, 1, 1)
    Button.TextSize = 15
    Button.Font = Enum.Font.GothamBold
    Button.Parent = Main

    local C = Instance.new("UICorner")
    C.CornerRadius = UDim.new(0, 8)
    C.Parent = Button

    Button.MouseButton1Click:Connect(callback)
    return Button
end

createButton("START", 110, function()
    Running = true
    Status.Text = "STATUS: RUNNING"
    Status.TextColor3 = Color3.fromRGB(80, 230, 130)
end)

createButton("STOP", 162, function()
    Running = false
    Status.Text = "STATUS: STOPPED"
    Status.TextColor3 = Color3.fromRGB(255, 100, 100)
end)

createButton("HIDE MENU", 214, function()
    Main.Visible = false
    MenuVisible = false
end)

createButton("UNLOAD", 266, function()
    Unloaded = true
    Running = false
    Screen:Destroy()
end)

UIS.InputBegan:Connect(function(input, processed)
    if processed or Unloaded then return end

    if input.KeyCode == Enum.KeyCode.F8 then
        MenuVisible = not MenuVisible
        Main.Visible = MenuVisible
    end
end)

-- Drag window
local dragging = false
local dragStart
local startPos

Title.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = Main.Position
    end
end)

UIS.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        Main.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
end)

UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

print("FunkyFridayHub loaded!")
