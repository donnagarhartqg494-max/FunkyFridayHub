-- FunkyFridayHub V18
-- Local-side-only AutoPlay with extended sustain hold.

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local Player = Players.LocalPlayer

-- Remove previous copies from every possible GUI root so the latest
-- version is always the one visible after re-executing the loader.
local guiRoots = {CoreGui}
pcall(function()
    if type(gethui) == "function" then
        local hui = gethui()
        if hui then table.insert(guiRoots, hui) end
    end
end)
pcall(function()
    local pg = Player:FindFirstChildOfClass("PlayerGui")
    if pg then table.insert(guiRoots, pg) end
end)
for _, root in ipairs(guiRoots) do
    pcall(function()
        local previous = root:FindFirstChild("FunkyFridayHub")
        if previous then previous:Destroy() end
    end)
end

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
Main.Size = UDim2.fromOffset(430, 520)
Main.Position = UDim2.new(0.5, -215, 0.5, -260)
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
Title.Text = "   FUNKY FRIDAY HUB V18  |  DRAG HERE"
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.TextColor3 = Color3.new(1, 1, 1)
Title.TextSize = 18
Title.Font = Enum.Font.GothamBold
Title.AutoButtonColor = false
Title.Active = true
Title.Parent = Main
Instance.new("UICorner", Title).CornerRadius = UDim.new(0, 8)

local Logo = Instance.new("TextLabel")
Logo.Name = "Logo"
Logo.Size = UDim2.fromOffset(34, 34)
Logo.Position = UDim2.fromOffset(6, 5)
Logo.BackgroundColor3 = Color3.fromRGB(112, 75, 220)
Logo.BorderSizePixel = 0
Logo.Text = "♫"
Logo.TextColor3 = Color3.fromRGB(255, 255, 255)
Logo.TextSize = 25
Logo.Font = Enum.Font.GothamBlack
Logo.Parent = Title
Instance.new("UICorner", Logo).CornerRadius = UDim.new(0, 9)
local LogoGradient = Instance.new("UIGradient")
LogoGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(67, 190, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(173, 76, 255))
})
LogoGradient.Rotation = 35
LogoGradient.Parent = Logo

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
local selectedSide = "Left"
local connections = {}
local pressedKeys = {}
local lastPress = {}
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
        local ok = pcall(fn, keyHex[laneIndex])
        return ok
    end
    return false
end

local function releaseAll()
    for laneIndex in pairs(pressedKeys) do
        sendKey(laneIndex, false)
        pressedKeys[laneIndex] = nil
    end
end

local function pressLane(laneIndex)
    if pressedKeys[laneIndex] then return true end
    local ok = sendKey(laneIndex, true)
    if not ok then
        running = false
        Status.Text = "INPUT BLOCKED BY EXECUTOR"
        Status.TextColor3 = Color3.fromRGB(255, 110, 110)
        releaseAll()
        return false
    end
    pressedKeys[laneIndex] = true
    return true
end

local function releaseLane(laneIndex)
    if pressedKeys[laneIndex] then
        sendKey(laneIndex, false)
        pressedKeys[laneIndex] = nil
    end
end

local function getSustainExtent(note)
    -- Return nil for taps, otherwise the estimated visible sustain length.
    -- Detection is intentionally independent from hit scheduling.
    local noteW = math.max(1, note.AbsoluteSize.X)
    local noteH = math.max(1, note.AbsoluteSize.Y)
    local extent = math.max(0, noteH - noteW)
    local found = noteH > noteW + 5

    for _, child in ipairs(note:GetDescendants()) do
        if child:IsA("GuiObject") then
            local nm = string.lower(child.Name)
            local h = child.AbsoluteSize.Y
            local w = math.max(1, child.AbsoluteSize.X)
            local named = string.find(nm, "hold") or string.find(nm, "sustain")
                or string.find(nm, "tail") or string.find(nm, "body")
                or string.find(nm, "long")
            if named or h > w + 5 then
                found = true
                extent = math.max(extent, h - math.min(w, noteW))
            end
        end
    end

    if found then return math.max(4, extent) end
    return nil
end

local function isSustainNote(note)
    return getSustainExtent(note) ~= nil
end

local function estimateHoldDuration(note, receptor, velocity)
    local extent = getSustainExtent(note)
    if not extent or velocity <= 0 then return 0.05 end
    -- Short sustains are especially easy to release early due to frame jitter.
    -- Add a modest safety buffer that scales down for longer tails.
    local raw = extent / velocity
    local safety = math.clamp(0.10, 0.04, 0.10)
    return math.clamp(raw + safety, 0.08, 8)
end

makeButton("PLAYER SIDE: LEFT  (CLICK TO SWITCH)", 95, function()
    if running then
        Status.Text = "STOP AUTOPLAY BEFORE CHANGING SIDE"
        return
    end
    selectedSide = selectedSide == "Left" and "Right" or "Left"
    local sideButton = Main:FindFirstChild("PLAYER_SIDE_BUTTON")
    if sideButton then
        sideButton.Text = "PLAYER SIDE: " .. string.upper(selectedSide) .. "  (CLICK TO SWITCH)"
    end
    Status.Text = "SELECTED SIDE: " .. string.upper(selectedSide)
end).Name = "PLAYER_SIDE_BUTTON"

makeButton("START AUTOPLAY  |  SELECTED SIDE", 145, function()
    if running then return end
    local pg = Player:FindFirstChildOfClass("PlayerGui")
    local fields = pg and pg:FindFirstChild("Window")
    fields = fields and fields:FindFirstChild("Game")
    fields = fields and fields:FindFirstChild("Fields")
    if not fields then
        Status.Text = "GAME FIELDS NOT FOUND"
        return
    end

    local playerSide = selectedSide

    local lanes = {}
    local side = fields:FindFirstChild(playerSide)
    local inner = side and side:FindFirstChild("Inner")
    for laneIndex = 1, 4 do
        local lane = inner and inner:FindFirstChild("Lane" .. laneIndex)
        local notes = lane and lane:FindFirstChild("Notes")
        local receptor = lane and lane:FindFirstChild("Receptor")
        if notes and receptor and receptor:IsA("GuiObject") then
            lanes[#lanes + 1] = {
                side = playerSide,
                index = laneIndex,
                notes = notes,
                receptor = receptor
            }
        end
    end
    if #lanes == 0 then
        Status.Text = "NO NOTE LANES FOUND"
        return
    end

    running = true
    Status.Text = "AUTOPLAY: " .. string.upper(playerSide) .. " SIDE ONLY"
    Status.TextColor3 = Color3.fromRGB(110, 230, 150)
    task.spawn(function()
        -- Prefer Funky Friday's internal chart data when the executor exposes it.
        -- This gives exact note timing and Data.Length for sustains; GUI scanning
        -- remains as a fallback for executors without getgc access.
        local framework
        if type(getgc) == "function" then
            pcall(function()
                for _, obj in ipairs(getgc(true)) do
                    if type(obj) == "table" and rawget(obj, "GameUI")
                        and type(rawget(obj, "UI")) == "table"
                        and type(rawget(obj, "SongPlayer")) == "table"
                        and type(rawget(obj, "ArrowData")) == "table" then
                        framework = obj
                        break
                    end
                end
            end)
        end

        if framework then
            local enumByValue = {}
            for _, enum in ipairs(Enum.KeyCode:GetEnumItems()) do
                enumByValue[enum.Value] = enum
            end
            local activeCounts = {}
            local function frameworkKey(keyCode, down)
                if not keyCode then return false end
                if virtualInput then
                    local ok = pcall(function()
                        virtualInput:SendKeyEvent(down, keyCode, false, nil)
                    end)
                    if ok then return true end
                end
                local fn = down and keypress or keyrelease
                local hex = string.byte(string.upper(keyCode.Name))
                if type(fn) == "function" and hex then
                    return pcall(fn, hex)
                end
                return false
            end
            local function acquire(keyCode)
                local name = keyCode.Name
                activeCounts[name] = (activeCounts[name] or 0) + 1
                if activeCounts[name] == 1 then frameworkKey(keyCode, true) end
            end
            local function release(keyCode)
                if not keyCode then return end
                local name = keyCode.Name
                activeCounts[name] = math.max(0, (activeCounts[name] or 1) - 1)
                if activeCounts[name] == 0 then
                    frameworkKey(keyCode, false)
                    activeCounts[name] = nil
                end
            end

            Status.Text = "AUTOPLAY: CHART DATA MODE"
            print("[FunkyFridayHub] Internal chart data found; exact sustain lengths enabled.")
            while running do
                local ok, arrows, count, mode, arrowData, songTime, playbackSpeed =
                    pcall(function()
                        local currentSound = framework.SongPlayer.CurrentlyPlaying
                        if typeof(currentSound) ~= "Instance" or not currentSound:IsA("Sound")
                            or currentSound.TimePosition <= 0 then
                            return {}, 4, "4Key", nil, 0, 1
                        end
                        local n = framework.SongPlayer:GetKeyCount()
                        local m = tostring(n) .. "Key"
                        local data = framework.ArrowData[m].Arrows
                        local speed = 1
                        local configs = framework.SongPlayer.CurrentSongConfigs
                        if type(configs) == "table" and type(configs.PlaybackSpeed) == "number"
                            and configs.PlaybackSpeed > 0 then
                            speed = configs.PlaybackSpeed
                        end
                        local time = framework.SongPlayer.CurrentTime / speed
                        return framework.UI:GetNotes(), n, m, data, time, speed
                    end)

                if ok and type(arrows) == "table" and type(arrowData) == "table" then
                    for _, arrow in ipairs(arrows) do
                        if type(arrow) == "table" and arrow.Side == playerSide
                            and not arrow.Marked and type(arrow.Data) == "table"
                            and type(arrow.Data.Time) == "number"
                            and type(arrow.Data.Position) == "number" then

                            local lanePosition = tostring(arrow.Data.Position % count)
                            local laneInfo = arrowData[lanePosition]
                            local keyboard = laneInfo and laneInfo.Keybinds
                                and laneInfo.Keybinds.Keyboard
                            local keyCode = keyboard and enumByValue[keyboard[1]]
                            local hitOffset = 0
                            pcall(function()
                                local settings = framework.Settings
                                local value = settings and settings.HitboxOffset
                                    and settings.HitboxOffset.Value
                                if type(value) == "number" then hitOffset = value / 1000 end
                            end)

                            local delta = math.abs(arrow.Data.Time - (songTime + hitOffset))
                            if keyCode and delta <= 0.04 then
                                arrow.Marked = true
                                acquire(keyCode)
                                local holdLength = math.max(0, tonumber(arrow.Data.Length) or 0)
                                local capturedArrow = arrow
                                local capturedKey = keyCode
                                task.spawn(function()
                                    if holdLength > 0 then
                                        task.wait(holdLength / playbackSpeed)
                                    else
                                        task.wait(0.05)
                                    end
                                    release(capturedKey)
                                    -- Keep the note marked until the game removes it,
                                    -- preventing a second hit while its object is still present.
                                end)
                            end
                        end
                    end
                elseif not ok then
                    warn("[FunkyFridayHub] Chart data read failed:", arrows)
                end
                task.wait()
            end
            for _, enum in pairs(Enum.KeyCode:GetEnumItems()) do
                if activeCounts[enum.Name] then
                    frameworkKey(enum, false)
                    activeCounts[enum.Name] = nil
                end
            end
            releaseAll()
            return
        end

        warn("[FunkyFridayHub] Internal chart API unavailable; using GUI fallback.")
        local seen = {}
        local lastPositions = {}
        local sustainHolds = {}
        local tapReleaseAt = {}
        local INPUT_LEAD = 0.035 -- small latency compensation only
        local MAX_HIT_LATE = 0.025
        while running do
            local now = os.clock()
            for laneIndex, releaseAt in pairs(tapReleaseAt) do
                if now >= releaseAt and not sustainHolds[laneIndex] then
                    releaseLane(laneIndex)
                    tapReleaseAt[laneIndex] = nil
                end
            end
            for laneIndex, heldNotes in pairs(sustainHolds) do
                local active = false
                for note in pairs(heldNotes) do
                    if note.Parent and note.Visible then
                        active = true
                    else
                        heldNotes[note] = nil
                    end
                end
                if not active then
                    sustainHolds[laneIndex] = nil
                    releaseLane(laneIndex)
                end
            end
            for _, laneData in ipairs(lanes) do
                local receptor = laneData.receptor
                local targetY = receptor.AbsolutePosition.Y
                for _, note in ipairs(laneData.notes:GetChildren()) do
                    if note:IsA("GuiObject") and note.Visible and not seen[note] then
                        local noteY = note.AbsolutePosition.Y
                        local prev = lastPositions[note]
                        if prev then
                            local dt = now - prev.t
                            local velocity = dt > 0 and (noteY - prev.y) / dt or 0
                            if velocity > 250 then
                                -- Trigger the note head using its leading edge.
                                -- A note is marked seen only after a real hit window,
                                -- so a missed velocity sample can be retried next frame.
                                local hitY = targetY
                                local timeToHit = (hitY - noteY) / velocity
                                if timeToHit <= INPUT_LEAD and timeToHit >= -MAX_HIT_LATE then
                                    local sustainExtent = getSustainExtent(note)
                                    seen[note] = true
                                    if sustainExtent then
                                        if pressLane(laneData.index) then
                                            sustainHolds[laneData.index] = sustainHolds[laneData.index] or {}
                                            sustainHolds[laneData.index][note] = true
                                        end
                                    else
                                        if pressLane(laneData.index) then
                                            tapReleaseAt[laneData.index] = math.max(
                                                tapReleaseAt[laneData.index] or 0, now + 0.05)
                                        end
                                    end
                                elseif timeToHit < -MAX_HIT_LATE then
                                    -- Do not let a late/teleported object block later processing.
                                    seen[note] = true
                                end
                            end
                        end
                        lastPositions[note] = {y = noteY, t = now}
                    end
                end
            end
            for note in pairs(seen) do
                if not note.Parent then seen[note] = nil end
            end
            for note in pairs(lastPositions) do
                if not note.Parent then lastPositions[note] = nil end
            end
            task.wait()
        end
        releaseAll()
    end)
end)

makeButton("STOP AUTOPLAY", 195, function()
    running = false
    releaseAll()
    Status.Text = "STATUS: STOPPED"
    Status.TextColor3 = Color3.fromRGB(255, 110, 110)
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

makeButton("DIAGNOSE SHORT HOLDS 10s", 345, function()
    local pg = Player:FindFirstChildOfClass("PlayerGui")
    local fields = pg and pg:FindFirstChild("Window")
    fields = fields and fields:FindFirstChild("Game")
    fields = fields and fields:FindFirstChild("Fields")
    if not fields then
        Status.Text = "GAME FIELDS NOT FOUND"
        return
    end

    Status.Text = "DIAGNOSTIC: PLAY A SHORT HOLD"
    print("=== SHORT HOLD DIAGNOSTIC START (10s) ===")
    local tracked = {}
    local cons = {}
    local function dump(obj, sideName, laneIndex)
        if not obj:IsA("GuiObject") or tracked[obj] then return end
        tracked[obj] = {side=sideName, lane=laneIndex, lastY=nil, lastT=nil, samples=0}
        print("SHORT-HOLD ADD", sideName, "Lane"..laneIndex, obj.Name,
            "Class", obj.ClassName, "Position", tostring(obj.Position),
            "AbsolutePosition", tostring(obj.AbsolutePosition),
            "AbsoluteSize", tostring(obj.AbsoluteSize),
            "AnchorPoint", tostring(obj.AnchorPoint))
        for _, child in ipairs(obj:GetDescendants()) do
            if child:IsA("GuiObject") then
                print("  PART", child:GetFullName(), child.ClassName,
                    "Position", tostring(child.Position),
                    "AbsPos", tostring(child.AbsolutePosition),
                    "AbsSize", tostring(child.AbsoluteSize),
                    "Visible", tostring(child.Visible),
                    "ClipsDescendants", tostring(child.ClipsDescendants))
            end
        end
    end

    for _, sideName in ipairs({"Left", "Right"}) do
        local side = fields:FindFirstChild(sideName)
        local inner = side and side:FindFirstChild("Inner")
        for laneIndex=1,4 do
            local lane = inner and inner:FindFirstChild("Lane"..laneIndex)
            local notes = lane and lane:FindFirstChild("Notes")
            if notes then
                for _, obj in ipairs(notes:GetChildren()) do dump(obj, sideName, laneIndex) end
                cons[#cons+1] = notes.ChildAdded:Connect(function(obj)
                    dump(obj, sideName, laneIndex)
                end)
            end
        end
    end

    local started = os.clock()
    while os.clock()-started < 10 do
        for obj, info in pairs(tracked) do
            if obj.Parent and obj:IsA("GuiObject") and info.samples < 10 then
                local now, y = os.clock(), obj.AbsolutePosition.Y
                info.samples += 1
                print("SHORT-HOLD SAMPLE", info.side, "Lane"..info.lane,
                    obj.Name, "t", string.format("%.3f", now-started),
                    "Y", y, "Size", tostring(obj.AbsoluteSize),
                    "Visible", tostring(obj.Visible))
                info.lastY, info.lastT = y, now
            end
        end
        task.wait(0.08)
    end
    for _, c in ipairs(cons) do pcall(function() c:Disconnect() end) end
    Status.Text = "DIAGNOSTIC COMPLETE: CHECK OUTPUT"
    print("=== SHORT HOLD DIAGNOSTIC END ===")
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

makeButton("HIDE MENU  [F8]", 395, function()
    Main.Visible = false
end)

makeButton("UNLOAD", 445, function()
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

local function beginDrag(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPosition = Main.Position
    end
end
connections[#connections + 1] = Title.InputBegan:Connect(beginDrag)
connections[#connections + 1] = Logo.InputBegan:Connect(beginDrag)

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

print("FunkyFridayHub V18 loaded. Chart-data AutoPlay with exact sustain lengths when available; GUI fallback enabled. Press F8 to toggle.")
