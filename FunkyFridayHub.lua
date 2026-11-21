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
Main.Size = UDim2.fromOffset(430, 470)
Main.Position = UDim2.new(0.5, -215, 0.5, -235)
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
local selectedSide = "Left"
local pressedKeys = {}
local keyCodes = {Enum.KeyCode.A, Enum.KeyCode.S, Enum.KeyCode.W, Enum.KeyCode.D}
local keyHex = {0x41, 0x53, 0x57, 0x44}
local virtualInput
pcall(function() virtualInput = game:GetService("VirtualInputManager") end)

local function sendKey(laneIndex, isDown)
    local keyCode = keyCodes[laneIndex]
    if not keyCode then return false end
    if virtualInput then
        local ok = pcall(function()
            virtualInput:SendKeyEvent(isDown, keyCode, false, game)
        end)
        if ok then return true end
    end
    local fn = isDown and keypress or keyrelease
    if type(fn) == "function" then
        return pcall(fn, keyHex[laneIndex])
    end
    return false
end

local function releaseAll()
    for laneIndex in pairs(pressedKeys) do
        sendKey(laneIndex, false)
        pressedKeys[laneIndex] = nil
    end
end

makeButton("START AUTOPLAY", 95, function()
    if running then return end
    local pg = Player:FindFirstChildOfClass("PlayerGui")
    local fields = pg and pg:FindFirstChild("Window")
    fields = fields and fields:FindFirstChild("Game")
    fields = fields and fields:FindFirstChild("Fields")
    local side = fields and fields:FindFirstChild(selectedSide)
    local inner = side and side:FindFirstChild("Inner")
    if not inner then
        Status.Text = "GAME FIELD NOT FOUND"
        return
    end
    running = true
    Status.Text = "AUTOPLAY: " .. string.upper(selectedSide)
    Status.TextColor3 = Color3.fromRGB(110, 230, 150)
    task.spawn(function()
        local noteStates = {}
        while running do
            for laneIndex = 1, 4 do
                local lane = inner:FindFirstChild("Lane" .. laneIndex)
                local notes = lane and lane:FindFirstChild("Notes")
                local receptor = lane and lane:FindFirstChild("Receptor")
                if notes and receptor and receptor:IsA("GuiObject") then
                    local targetY = receptor.AbsolutePosition.Y
                    for _, note in ipairs(notes:GetChildren()) do
                        if note:IsA("GuiObject") and not noteStates[note] then
                            local noteY = note.AbsolutePosition.Y
                            if note.Visible and noteY >= targetY - 24 then
                                noteStates[note] = true
                                if not pressedKeys[laneIndex] then
                                    local ok = sendKey(laneIndex, true)
                                    if ok then
                                        pressedKeys[laneIndex] = true
                                        task.delay(0.045, function()
                                            if pressedKeys[laneIndex] then
                                                sendKey(laneIndex, false)
                                                pressedKeys[laneIndex] = nil
                                            end
                                        end)
                                    else
                                        running = false
                                        Status.Text = "INPUT BLOCKED: SOLARA"
                                        Status.TextColor3 = Color3.fromRGB(255, 110, 110)
                                        break
                                    end
                                end
                            end
                        end
                    end
                end
            end
            for note in pairs(noteStates) do
                if not note.Parent then noteStates[note] = nil end
            end
            task.wait()
        end
        releaseAll()
    end)
end)

makeButton("STOP AUTOPLAY", 145, function()
    running = false
    releaseAll()
    Status.Text = "STATUS: STOPPED"
    Status.TextColor3 = Color3.fromRGB(255, 110, 110)
end)

local sideButton = makeButton("SIDE: LEFT (CLICK TO SWITCH)", 195, function()
    selectedSide = selectedSide == "Left" and "Right" or "Left"
    sideButton.Text = "SIDE: " .. string.upper(selectedSide) .. " (CLICK TO SWITCH)"
    Status.Text = "SELECTED SIDE: " .. string.upper(selectedSide)
end)

makeButton("SCAN GAME UI", 245, function()
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

makeButton("TRACK NOTE MOTION 8s", 295, function()
    local pg = Player:FindFirstChildOfClass("PlayerGui")
    local fields = pg and pg:FindFirstChild("Window")
    fields = fields and fields:FindFirstChild("Game")
    fields = fields and fields:FindFirstChild("Fields")
    if not fields then
        Status.Text = "GAME FIELDS NOT FOUND"
        return
    end

    Status.Text = "TRACKING: PLAY NOW"
    print("=== NOTE MOTION TRACK START (8 seconds) ===")
    local tracked = {}
    local watchConnections = {}
    local function addNote(obj, sideName, laneIndex)
        if tracked[obj] or not obj:IsA("GuiObject") then return end
        tracked[obj] = {
            side = sideName,
            lane = laneIndex,
            name = obj.Name,
            samples = 0
        }
        print("TRACK ADD", sideName, "Lane" .. laneIndex, obj.Name,
            "Position", tostring(obj.Position),
            "AbsolutePosition", tostring(obj.AbsolutePosition),
            "AnchorPoint", tostring(obj.AnchorPoint),
            "LayoutOrder", tostring(obj.LayoutOrder))
    end

    for _, sideName in ipairs({"Left", "Right"}) do
        local side = fields:FindFirstChild(sideName)
        local inner = side and side:FindFirstChild("Inner")
        for laneIndex = 1, 4 do
            local lane = inner and inner:FindFirstChild("Lane" .. laneIndex)
            local notes = lane and lane:FindFirstChild("Notes")
            local receptor = lane and lane:FindFirstChild("Receptor")
            if receptor and receptor:IsA("GuiObject") then
                print("RECEPTOR", sideName, "Lane" .. laneIndex,
                    "Position", tostring(receptor.Position),
                    "AbsolutePosition", tostring(receptor.AbsolutePosition),
                    "Size", tostring(receptor.AbsoluteSize))
            end
            if notes then
                for _, obj in ipairs(notes:GetChildren()) do
                    addNote(obj, sideName, laneIndex)
                end
                watchConnections[#watchConnections + 1] = notes.ChildAdded:Connect(function(obj)
                    addNote(obj, sideName, laneIndex)
                end)
            end
        end
    end

    local started = os.clock()
    while os.clock() - started < 8 do
        for obj, info in pairs(tracked) do
            if obj.Parent and obj:IsA("GuiObject") and info.samples < 12 then
                info.samples += 1
                print("NOTE SAMPLE", info.side, "Lane" .. info.lane,
                    info.name, "t=" .. string.format("%.2f", os.clock() - started),
                    "Y=" .. tostring(obj.AbsolutePosition.Y),
                    "PosY=" .. tostring(obj.Position.Y.Scale) .. "," .. tostring(obj.Position.Y.Offset),
                    "Visible=" .. tostring(obj.Visible))
            end
        end
        task.wait(0.1)
    end
    for _, c in ipairs(watchConnections) do
        pcall(function() c:Disconnect() end)
    end
    Status.Text = "TRACK COMPLETE: CHECK OUTPUT"
    print("=== NOTE MOTION TRACK END ===")
end)

makeButton("HIDE MENU  [F8]", 345, function()
    Main.Visible = false
end)

makeButton("UNLOAD", 395, function()
    running = false
    releaseAll()
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

print("FunkyFridayHub V4 loaded. AutoPlay: choose side, then START. Keys A/S/W/D. Press F8 to toggle.")
