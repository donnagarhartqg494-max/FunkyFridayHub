
-- FunkyFridayHub V2
-- GUI + key test + controls

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local old = CoreGui:FindFirstChild("FunkyFridayHub")
if old then old:Destroy() end

local Screen = Instance.new("ScreenGui")
Screen.Name = "FunkyFridayHub"
Screen.ResetOnSpawn = false
Screen.Parent = CoreGui

local Main = Instance.new("Frame")
Main.Size = UDim2.fromOffset(430, 350)
Main.Position = UDim2.new(0.5, -215, 0.5, -175)
Main.BackgroundColor3 = Color3.fromRGB(20, 22, 32)
Main.BorderSizePixel = 0
Main.Parent = Screen

Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 12)

local function label(text, pos, size)
    local obj = Instance.new("TextLabel")
    obj.Position = pos
    obj.Size = size
    obj.BackgroundTransparency = 1
    obj.Text = text
    obj.TextColor3 = Color3.new(1,1,1)
    obj.Font = Enum.Font.GothamBold
    obj.TextSize = 17
    obj.Parent = Main
    return obj
end

label("FunkyFridayHub V2", UDim2.fromOffset(15,10),
    UDim2.new(1,-30,0,40))

local Status = label("STATUS: READY",
    UDim2.fromOffset(20,55), UDim2.new(1,-40,0,30))

local function button(text, y, callback)
    local b = Instance.new("TextButton")
    b.Position = UDim2.fromOffset(20,y)
    b.Size = UDim2.new(1,-40,0,42)
    b.BackgroundColor3 = Color3.fromRGB(48,54,75)
    b.TextColor3 = Color3.new(1,1,1)
    b.Text = text
    b.Font = Enum.Font.GothamBold
    b.TextSize = 15
    b.Parent = Main
    Instance.new("UICorner",b).CornerRadius = UDim.new(0,8)
    b.MouseButton1Click:Connect(callback)
    return b
end

local running = false

button("START",105,function()
    running = true
    Status.Text = "STATUS: RUNNING"
    Status.TextColor3 = Color3.fromRGB(80,230,130)
end)

button("STOP",155,function()
    running = false
    Status.Text = "STATUS: STOPPED"
    Status.TextColor3 = Color3.fromRGB(255,100,100)
end)

button("KEYBOARD TEST",205,function()
    Status.Text = "KEYS: D F SPACE J K"
end)

button("HIDE MENU [F8]",255,function()
    Main.Visible = false
end)

button("UNLOAD",305,function()
    running = false
    Screen:Destroy()
end)

UIS.InputBegan:Connect(function(input, processed)
    if input.KeyCode == Enum.KeyCode.F8 then
        Main.Visible = not Main.Visible
    end
end)

print("FunkyFridayHub V2 loaded!")
