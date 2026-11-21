-- FunkyFridayHub V3
-- Solara-friendly GUI, draggable window, UI diagnostics
-- AutoPlay is intentionally not enabled until the game's note objects are identified.

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local Player = Players.LocalPlayer

local old
pcall(function()
    old = CoreGui:FindFirstChild("FunkyFridayHub")
    if old then old:Destroy() end
end)

local Screen = Instance.new("ScreenGui")
Screen.Name = "FunkyFridayHub"
Screen.ResetOnSpawn = false
Screen.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local parented = pcall(function()
    if typeof(gethui) == "function" then
        Screen.Parent = gethui()
    else
        Screen.Parent = CoreGui
    end
end)
if not parented then
    Screen.Parent = Player:WaitForChild("PlayerGui")
end

local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Size = UDim2.fromOffset(430, 370)
Main.Position = UDim2.new(0.5, -215, 0.5, -185)
Main.BackgroundColor3 = Color3.fromRGB(20, 22, 32)
Main.BorderSizePixel = 0
Main.Active = true
Main.Parent = Screen
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 12)

local Stroke = Instance.new("UIStroke")
Stroke.Color = Color3.fromRGB(85, 105, 160)
Stroke.Thickness = 1
Stroke.Parent = Main

local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Size = UDim2.new(1, -20, 0, 45)
Title.Position = UDim2.fromOffset(10, 4)
Title.BackgroundTransparency = 1
Title.Text = "FunkyFridayHub V3  |  drag here"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.TextSize = 19
Title.Font = Enum.Font.GothamBold
Title.Active = true
Title.Parent = Main

local Status = Instance.new("TextLabel")
Status.Size = UDim2.new(1, -40, 0, 30)
Status.Position = UDim2.fromOffset(20, 52)
Status.BackgroundTransparency = 1
Status.Text = "STATUS: READY"
Status.TextColor3 = Color3.fromRGB(180, 190, 210)
Status.TextSize = 14
Status.Font = Enum.Font.Gotham
Status.TextXAlignment = Enum.TextXAlignment.Left
Status.Parent = Main

local function makeButton(text, y, callback)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, -40, 0, 42)
    b.Position = UDim2.fromOffset(20, y)
    b.BackgroundColor3 = Color3.fromRGB(43, 49, 68)
    b.Text = text
    b.TextColor3 = Color3.new(1, 1, 1)
    b.TextSize = 14
    b.Font = Enum.Font.GothamBold
    b.AutoButtonColor = true
    b.Parent = Main
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 8)
    b.MouseButton1Click:Connect(callback)
    return b
end

local running = false
local connections = {}

makeButton("START", 95, function()
    running = true
    Status.Text = "STATUS: READY (AUTOPLAY NOT CONFIGURED)"
    Status.TextColor3 = Color3.fromRGB(255, 205, 100)
end)

makeButton("STOP", 145, function()
    running = false
    Status.Text = "STATUS: STOPPED"
    Status.TextColor3 = Color3.fromRGB(255, 110, 110)
end)

makeButton("SCAN GAME UI", 195, function()
    local pg = Player:FindFirstChildOfClass("PlayerGui")
    if not pg then
        Status.Text = "PlayerGui not found"
        return
    end

    local found = 0
    print("=== FunkyFridayHub UI scan ===")
    for _, obj in ipairs(pg:GetDescendants()) do
        local n = string.lower(obj.Name)
        if string.find(n, "note") or string.find(n, "arrow")
            or string.find(n, "receptor") or string.find(n, "strum")
            or string.find(n, "lane") or string.find(n, "hit") then
            found += 1
            local p = ""
            if obj:IsA("GuiObject") then
                p = " | Position=" .. tostring(obj.AbsolutePosition)
                    .. " Size=" .. tostring(obj.AbsoluteSize)
            end
            print(obj:GetFullName(), obj.ClassName .. p)
        end
    end
    print("=== Scan complete. Matches:", found, "===")
    Status.Text = "UI SCAN COMPLETE: " .. found .. " matches (see console)"
end)

makeButton("HIDE MENU  [F8]", 245, function()
    Main.Visible = false
end)

makeButton("UNLOAD", 295, function()
    running = false
    for _, c in ipairs(connections) do
        pcall(function() c:Disconnect() end)
    end
    Screen:Destroy()
end)

-- Drag the window by its title bar.
local dragging = false
local dragInput = nil
local dragStart = nil
local startPosition = nil

connections[#connections + 1] = Title.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPosition = Main.Position
        dragInput = input
    end
end)

connections[#connections + 1] = UIS.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        Main.Position = UDim2.new(
            startPosition.X.Scale,
            startPosition.X.Offset + delta.X,
            startPosition.Y.Scale,
            startPosition.Y.Offset + delta.Y
        )
    end
end)

connections[#connections + 1] = UIS.InputEnded:Connect(function(input)
    if input == dragInput or input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
        dragInput = nil
    end
end)

connections[#connections + 1] = UIS.InputBegan:Connect(function(input, processed)
    if input.KeyCode == Enum.KeyCode.F8 then
        Main.Visible = not Main.Visible
    end
end)

print("FunkyFridayHub V3 loaded. Drag the title bar. Press F8 to toggle.")
