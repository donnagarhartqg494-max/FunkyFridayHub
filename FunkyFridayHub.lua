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

local Title = Instance.new("TextButton")
Title.Name = "Title"
Title.Size = UDim2.new(1, -20, 0, 45)
Title.Position = UDim2.fromOffset(10, 4)
Title.BackgroundColor3 = Color3.fromRGB(29, 34, 49)
Title.BorderSizePixel = 0
Title.Text = "FunkyFridayHub V3  |  DRAG HERE"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.TextSize = 18
Title.Font = Enum.Font.GothamBold
Title.AutoButtonColor = false
Title.Active = true
Title.Parent = Main
Instance.new("UICorner", Title).CornerRadius = UDim.new(0, 8)

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
    print("=== NOTE OBJECT DETAILS ===")
    local fields = pg:FindFirstChild("Window")
    fields = fields and fields:FindFirstChild("Game")
    fields = fields and fields:FindFirstChild("Fields")
    for _, sideName in ipairs({"Left", "Right"}) do
        local side = fields and fields:FindFirstChild(sideName)
        local inner = side and side:FindFirstChild("Inner")
        for laneIndex = 1, 4 do
            local lane = inner and inner:FindFirstChild("Lane" .. laneIndex)
            local notes = lane and lane:FindFirstChild("Notes")
            print("---", sideName, "Lane" .. laneIndex, "NotesFolder=", notes and notes.ClassName or "MISSING")
            if notes then
                local children = notes:GetChildren()
                print("Direct note count:", #children)
                for i = 1, math.min(#children, 8) do
                    local note = children[i]
                    local details = note.Name .. " [" .. note.ClassName .. "]"
                    if note:IsA("GuiObject") then
                        details = details .. " Pos=" .. tostring(note.AbsolutePosition)
                            .. " Size=" .. tostring(note.AbsoluteSize)
                            .. " Visible=" .. tostring(note.Visible)
                    end
                    if note:IsA("ImageLabel") or note:IsA("ImageButton") then
                        details = details .. " Image=" .. tostring(note.Image)
                    end
                    print(details)
                    for key, value in pairs(note:GetAttributes()) do
                        print("  Attribute:", key, tostring(value))
                    end
                    for _, child in ipairs(note:GetChildren()) do
                        print("  Child:", child.Name, child.ClassName)
                    end
                end
            end
        end
    end
    print("=== Scan complete. Matches:", found, "===")
    Status.Text = "SCAN COMPLETE: " .. found .. " matches + note details (see console)"
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

-- Reliable title-bar dragging (mouse and touch).
local dragging = false
local dragStart = nil
local startPosition = nil

connections[#connections + 1] = Title.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPosition = Main.Position
    end
end)

connections[#connections + 1] = UIS.InputChanged:Connect(function(input)
    if not dragging then return end
    if input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch then
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
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

connections[#connections + 1] = UIS.InputBegan:Connect(function(input, processed)
    if input.KeyCode == Enum.KeyCode.F8 then
        Main.Visible = not Main.Visible
    end
end)

print("FunkyFridayHub V3.1 loaded. Drag the highlighted title bar. Press F8 to toggle. AutoPlay is not yet configured.")
