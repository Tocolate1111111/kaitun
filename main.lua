--[[
    DevTools - Premium Version (Production V1)
    - Re-engineered & Visual Overhaul
    - Developed by / Credits to: in3eme
    - X Button: Hard Shutdown (Kills listeners, cleans instances)
    - F4 Button: Safely toggles UI visibility
    - F Button: Toggle flight engine (Works while UI is hidden)
]]

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

local player = Players.LocalPlayer
local cam = workspace.CurrentCamera

------------------------------------------------
--// STATE & CONFIG ENGINE
------------------------------------------------
local flying = false
local tpClickEnabled = false
local btoolsEnabled = false
local espEnabled = false
local infJumpEnabled = false

local flySpeed = 75
local MIN_SPEED, MAX_SPEED = 10, 300

local customSpeedEnabled = false
local targetWalkSpeed = 50
local customJumpEnabled = false
local targetJumpPower = 100

local savedPosition = nil

local bodyVelocity, bodyGyro
local char, hum, root
local flyButtonInstance = nil
local savedPosLabelInstance = nil 

------------------------------------------------
--// CHARACTER HANDLER
------------------------------------------------
local characterConnection
local function bindCharacter(c)
    char = c
    hum = char:WaitForChild("Humanoid", 5)
    root = char:WaitForChild("HumanoidRootPart", 5)

    flying = false
    if bodyVelocity then bodyVelocity:Destroy() end
    if bodyGyro then bodyGyro:Destroy() end
end

characterConnection = player.CharacterAdded:Connect(bindCharacter)
if player.Character then bindCharacter(player.Character) end

------------------------------------------------
--// CLEANUP & INITIALIZATION
------------------------------------------------
if CoreGui:FindFirstChild("DevTools_Apex") then
    CoreGui.DevTools_Apex:Destroy()
end

local gui = Instance.new("ScreenGui")
gui.Name = "DevTools_Apex"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.Parent = CoreGui

------------------------------------------------
--// UI PALETTE CONFIG
------------------------------------------------
local COL_BG       = Color3.fromRGB(11, 12, 17)
local COL_SIDEBAR  = Color3.fromRGB(16, 17, 24)
local COL_PANEL_BG = Color3.fromRGB(20, 21, 30)
local COL_ACCENT   = Color3.fromRGB(140, 90, 255)
local COL_ACCENT_2 = Color3.fromRGB(46, 204, 113) 
local COL_TEXT     = Color3.fromRGB(255, 255, 255)
local COL_SUBTEXT  = Color3.fromRGB(150, 155, 170)
local COL_BTN      = Color3.fromRGB(28, 30, 43)
local COL_BORDER   = Color3.fromRGB(40, 43, 60)

local function corner(inst, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or 10)
    c.Parent = inst
    return c
end

local function stroke(inst, color, thickness, trans)
    local s = Instance.new("UIStroke")
    s.Color = color or COL_BORDER
    s.Thickness = thickness or 1
    s.Transparency = trans or 0
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.Parent = inst
    return s
end

local function createHoverEffect(btn, targetColor, originalColor)
    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = targetColor}):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = originalColor}):Play()
    end)
end

------------------------------------------------
--// ENGINE SYSTEMS
------------------------------------------------
local function startFlying()
    if not root or not hum then return end

    bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.Name = "ApexFly_Vel"
    bodyVelocity.MaxForce = Vector3.new(1e6, 1e6, 1e6)
    bodyVelocity.Velocity = Vector3.zero
    bodyVelocity.Parent = root

    bodyGyro = Instance.new("BodyGyro")
    bodyGyro.Name = "ApexFly_Gyro"
    bodyGyro.MaxTorque = Vector3.new(1e6, 1e6, 1e6)
    bodyGyro.CFrame = root.CFrame
    bodyGyro.Parent = root

    flying = true
    hum:ChangeState(Enum.HumanoidStateType.Physics)
end

local function stopFlying()
    flying = false
    if bodyVelocity then bodyVelocity:Destroy() end
    if bodyGyro then bodyGyro:Destroy() end
    if hum then hum:ChangeState(Enum.HumanoidStateType.GettingUp) end
end

local function updateFlyButtonUI()
    if flyButtonInstance and flyButtonInstance.Parent then
        flyButtonInstance.Text = flying and "Fly: ON  (F)" or "Fly: OFF  (F)"
        TweenService:Create(flyButtonInstance, TweenInfo.new(0.15), {
            BackgroundColor3 = flying and COL_ACCENT_2 or COL_BTN
        }):Play()
    end
end

local function toggleFly()
    if flying then stopFlying() else startFlying() end
    updateFlyButtonUI()
end

local function super3DDash()
    if not root or not hum then return end

    local dashDirection = cam.CFrame.LookVector
    local moveDirection = hum.MoveDirection

    if moveDirection.Magnitude > 0 then
        local horizontalVector = Vector3.new(moveDirection.X, 0, moveDirection.Z).Unit
        dashDirection = Vector3.new(horizontalVector.X, cam.CFrame.LookVector.Y, horizontalVector.Z).Unit
    end

    local dashVelocity = Instance.new("LinearVelocity")
    local attachment = Instance.new("Attachment")
    attachment.Parent = root

    dashVelocity.MaxForce = 9999999
    dashVelocity.VectorVelocity = dashDirection * (flySpeed * 3)
    dashVelocity.Attachment0 = attachment
    dashVelocity.Parent = root

    task.delay(0.2, function()
        dashVelocity:Destroy()
        attachment:Destroy()
    end)
end

local function updateSavedPosUI()
    if savedPosLabelInstance and savedPosLabelInstance.Parent then
        if savedPosition then
            savedPosLabelInstance.Text = string.format("SAVED INDEX: X: %.1f, Y: %.1f, Z: %.1f", savedPosition.Position.X, savedPosition.Position.Y, savedPosition.Position.Z)
            savedPosLabelInstance.TextColor3 = COL_ACCENT_2
        else
            savedPosLabelInstance.Text = "SAVED INDEX: NO POSITION BOOKMARKED"
            savedPosLabelInstance.TextColor3 = COL_SUBTEXT
        end
    end
end

local function saveCurrentSpot()
    if root then
        savedPosition = root.CFrame
        updateSavedPosUI()
    end
end

local function loadSavedSpot()
    if root and savedPosition then
        if bodyVelocity then bodyVelocity.Velocity = Vector3.zero end
        root.CFrame = savedPosition
    end
end

local function refreshESP()
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= player and p.Character then
            local b = p.Character:FindFirstChild("ApexESP")
            if espEnabled then
                if not b then
                    local box = Instance.new("Highlight")
                    box.Name = "ApexESP"
                    box.FillColor = COL_ACCENT
                    box.FillTransparency = 0.6
                    box.OutlineColor = COL_TEXT
                    box.OutlineTransparency = 0.1
                    box.Adornee = p.Character
                    box.Parent = p.Character
                end
            else
                if b then b:Destroy() end
            end
        end
    end
end

------------------------------------------------
--// RUNSERVICE RENDER SYSTEM
------------------------------------------------
local renderConnection
renderConnection = RunService.RenderStepped:Connect(function()
    if espEnabled then refreshESP() end

    if hum then
        if customSpeedEnabled and hum.WalkSpeed ~= targetWalkSpeed then hum.WalkSpeed = targetWalkSpeed end
        if customJumpEnabled and hum.JumpPower ~= targetJumpPower then 
            hum.UseJumpPower = true
            hum.JumpPower = targetJumpPower 
        end
    end

    if not flying or not root or not bodyVelocity or not bodyGyro then return end

    local move = Vector3.zero
    if UIS:IsKeyDown(Enum.KeyCode.W) then move += cam.CFrame.LookVector end
    if UIS:IsKeyDown(Enum.KeyCode.S) then move -= cam.CFrame.LookVector end
    if UIS:IsKeyDown(Enum.KeyCode.A) then move -= cam.CFrame.RightVector end
    if UIS:IsKeyDown(Enum.KeyCode.D) then move += cam.CFrame.RightVector end
    if UIS:IsKeyDown(Enum.KeyCode.Space) then move += Vector3.new(0, 1, 0) end
    if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then move -= Vector3.new(0, 1, 0) end

    if move.Magnitude > 0 then
        bodyVelocity.Velocity = move.Unit * flySpeed
    else
        bodyVelocity.Velocity = Vector3.zero
    end
    bodyGyro.CFrame = cam.CFrame
end)

local jumpRequestConnection
jumpRequestConnection = UIS.JumpRequest:Connect(function()
    if infJumpEnabled and hum then
        hum:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

------------------------------------------------
--// BASE PANEL CONSTRUCTION
------------------------------------------------
local main = Instance.new("Frame")
main.Name = "Main"
main.Size = UDim2.new(0, 540, 0, 380)
main.Position = UDim2.new(0.5, -270, 0.5, -190)
main.BackgroundColor3 = COL_BG
main.Active = true
main.ClipsDescendants = true
main.Parent = gui
corner(main, 14)
stroke(main, COL_BORDER, 1.5, 0)

local topBar = Instance.new("Frame")
topBar.Size = UDim2.new(1, 0, 0, 50)
topBar.BackgroundColor3 = COL_SIDEBAR
topBar.BorderSizePixel = 0
topBar.Parent = main

local titleLabel = Instance.new("TextLabel")
titleLabel.Text = "PREMIUM VERSION // By In3eme "
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextSize = 13
titleLabel.TextColor3 = COL_TEXT
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.BackgroundTransparency = 1
titleLabel.Size = UDim2.new(1, -60, 1, 0)
titleLabel.Position = UDim2.new(0, 20, 0, 0)
titleLabel.Parent = topBar

local close = Instance.new("TextButton")
close.Size = UDim2.new(0, 28, 0, 28)
close.Position = UDim2.new(1, -40, 0, 11)
close.Text = "X"
close.Font = Enum.Font.GothamBold
close.TextSize = 12
close.BackgroundColor3 = COL_BTN
close.TextColor3 = Color3.fromRGB(231, 76, 60)
close.AutoButtonColor = false
close.Parent = topBar
corner(close, 6)
stroke(close, COL_BORDER, 1)
createHoverEffect(close, Color3.fromRGB(192, 57, 43), COL_BTN)

------------------------------------------------
--// ROBUST DRAGGING ENGINE
------------------------------------------------
local dragStart, startPos
local dragging = false

topBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = main.Position
    end
end)

UIS.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        main.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
    end
end)

UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

------------------------------------------------
--// HOTKEYS & BACKGROUND ENGINE INPUTS
------------------------------------------------
local inputConnection
inputConnection = UIS.InputBegan:Connect(function(input, gp)
    if input.KeyCode == Enum.KeyCode.F4 then
        main.Visible = not main.Visible
        return
    end

    if gp then return end -- Only block typing in chat / UI focus

    if input.KeyCode == Enum.KeyCode.F then
        toggleFly()
    elseif input.KeyCode == Enum.KeyCode.Q then
        super3DDash()
    elseif input.KeyCode == Enum.KeyCode.K then
        saveCurrentSpot()
    elseif input.KeyCode == Enum.KeyCode.L then
        loadSavedSpot()
    elseif input.UserInputType == Enum.UserInputType.MouseButton1 then
        -- Only process screen clicks if the UI is actually visible to prevent missclicks
        if not main.Visible then return end
        
        local mouse = player:GetMouse()
        if tpClickEnabled and mouse.Hit and root then
            root.CFrame = CFrame.new(mouse.Hit.Position + Vector3.new(0, 3, 0))
        elseif btoolsEnabled and mouse.Target and mouse.Target ~= workspace then
            if not mouse.Target:IsA("Terrain") and not mouse.Target:IsDescendantOf(char) then
                mouse.Target:Destroy()
            end
        end
    end
end)

close.MouseButton1Click:Connect(function()
    stopFlying()
    espEnabled = false
    refreshESP()
    if hum then
        hum.WalkSpeed = 16
        hum.JumpPower = 50
    end

    if inputConnection then inputConnection:Disconnect() end
    if renderConnection then renderConnection:Disconnect() end
    if jumpRequestConnection then jumpRequestConnection:Disconnect() end
    if characterConnection then characterConnection:Disconnect() end

    gui:Destroy()
end)

------------------------------------------------
-- SIDEBAR NAVIGATION
------------------------------------------------
local side = Instance.new("Frame")
side.Size = UDim2.new(0, 150, 1, -68)
side.Position = UDim2.new(0, 14, 0, 64)
side.BackgroundColor3 = COL_SIDEBAR
side.Parent = main
corner(side, 10)
stroke(side, COL_BORDER, 1)

local sideList = Instance.new("UIListLayout")
sideList.Padding = UDim.new(0, 6)
sideList.Parent = side

local sidePad = Instance.new("UIPadding")
sidePad.PaddingTop = UDim.new(0, 12)
sidePad.PaddingLeft = UDim.new(0, 10)
sidePad.PaddingRight = UDim.new(0, 10)
sidePad.Parent = side

local navButtons = {}
local function navBtn(text, order)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, 0, 0, 36)
    b.Text = "  " .. text
    b.Font = Enum.Font.GothamMedium
    b.TextSize = 11
    b.TextXAlignment = Enum.TextXAlignment.Left
    b.BackgroundColor3 = COL_BTN
    b.TextColor3 = COL_SUBTEXT
    b.AutoButtonColor = false
    b.LayoutOrder = order
    b.Parent = side
    corner(b, 6)
    stroke(b, COL_BORDER, 1)
    navButtons[text] = b
    return b
end

local mNav1 = navBtn("Movement", 1)
local mNav2 = navBtn("Player", 2)
local mNav3 = navBtn("Tools", 3)
local mNav4 = navBtn("Visuals / ESP", 4)
local mNav5 = navBtn("Performance Hub", 5)

local function setActiveNav(name)
    for txt, b in pairs(navButtons) do
        if txt == name then
            b.BackgroundColor3 = COL_ACCENT
            b.TextColor3 = Color3.new(1, 1, 1)
        else
            b.BackgroundColor3 = COL_BTN
            b.TextColor3 = COL_SUBTEXT
        end
    end
end

------------------------------------------------
-- PANEL CONTAINER
------------------------------------------------
local panel = Instance.new("Frame")
panel.Size = UDim2.new(1, -194, 1, -68)
panel.Position = UDim2.new(0, 178, 0, 64)
panel.BackgroundColor3 = COL_PANEL_BG
panel.Parent = main
corner(panel, 10)
stroke(panel, COL_BORDER, 1)

local panelPad = Instance.new("UIPadding")
panelPad.PaddingTop = UDim.new(0, 16)
panelPad.PaddingLeft = UDim.new(0, 18)
panelPad.PaddingRight = UDim.new(0, 18)
panelPad.Parent = panel

local panelTitle = Instance.new("TextLabel")
panelTitle.Size = UDim2.new(1, 0, 0, 24)
panelTitle.Font = Enum.Font.GothamBold
panelTitle.TextSize = 15
panelTitle.TextColor3 = COL_TEXT
panelTitle.TextXAlignment = Enum.TextXAlignment.Left
panelTitle.BackgroundTransparency = 1
panelTitle.Parent = panel

local function clearPanel()
    for _, v in ipairs(panel:GetChildren()) do
        if v.Name == "PanelContent" then v:Destroy() end
    end
end

local function bigButton(parentFrame, text, yPos, color)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, 0, 0, 36)
    b.Position = UDim2.new(0, 0, 0, yPos)
    b.Text = text
    b.Font = Enum.Font.GothamBold
    b.TextSize = 12
    b.TextColor3 = Color3.new(1, 1, 1)
    b.BackgroundColor3 = color or COL_BTN
    b.AutoButtonColor = false
    b.Parent = parentFrame
    corner(b, 8)
    stroke(b, COL_BORDER, 1)
    return b
end

------------------------------------------------
-- INTERFACE CONTROLLERS
------------------------------------------------
local showMovementPage, showPlayerPage, showWorldPage, showVisualsPage, showPerfPage

-- BACKGROUND ANTI-FLING LOGIC LOOP
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

RunService.Heartbeat:Connect(function()
    if not antiFlingEnabled then return end
    
    local char = LocalPlayer.Character
    if not char then return end
    
    -- Loop through all other players to neutralize flinging parts
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            for _, part in ipairs(player.Character:GetChildren()) do
                if part:IsA("BasePart") then
                    -- If a part is spinning or moving at insane velocities (classic fling exploit)
                    if part.Velocity.Magnitude > 50 or part.RotVelocity.Magnitude > 50 then
                        part.CanCollide = false
                        part.Velocity = Vector3.new(0, 0, 0)
                        part.RotVelocity = Vector3.new(0, 0, 0)
                    end
                end
            end
        end
    end
end)

showMovementPage = function()
    clearPanel()
    panelTitle.Text = "Movement"
    setActiveNav("Movement")
    savedPosLabelInstance = nil

    local content = Instance.new("Frame")
    content.Name = "PanelContent"
    content.Size = UDim2.new(1, 0, 1, -30)
    content.Position = UDim2.new(0, 0, 0, 30)
    content.BackgroundTransparency = 1
    content.Parent = panel

    flyButtonInstance = bigButton(content, flying and "Fly: ON  (F)" or "Fly: OFF  (F)", 0, flying and COL_ACCENT_2 or COL_BTN)
    flyButtonInstance.MouseButton1Click:Connect(function() toggleFly() end)

    local dashBtn = bigButton(content, "Dash  (Q)", 44, COL_BTN)
    dashBtn.MouseButton1Click:Connect(super3DDash)

    local infBtn = bigButton(content, infJumpEnabled and "Infinite Jump: ACTIVE" or "Infinite Jump: DISABLED", 88, infJumpEnabled and COL_ACCENT_2 or COL_BTN)
    infBtn.MouseButton1Click:Connect(function()
        infJumpEnabled = not infJumpEnabled
        infBtn.Text = infJumpEnabled and "Infinite Jump: ACTIVE" or "Infinite Jump: DISABLED"
        TweenService:Create(infBtn, TweenInfo.new(0.15), {BackgroundColor3 = infJumpEnabled and COL_ACCENT_2 or COL_BTN}):Play()
    end)

    local flingBtn = bigButton(content, antiFlingEnabled and "Anti Fling: ACTIVE" or "Anti Fling: DISABLED", 132, antiFlingEnabled and COL_ACCENT_2 or COL_BTN)
    flingBtn.MouseButton1Click:Connect(function()
        antiFlingEnabled = not antiFlingEnabled
        flingBtn.Text = antiFlingEnabled and "Anti Fling: ACTIVE" or "Anti Fling: DISABLED"
        TweenService:Create(flingBtn, TweenInfo.new(0.15), {BackgroundColor3 = antiFlingEnabled and COL_ACCENT_2 or COL_BTN}):Play()
    end)

    local speedLabel = Instance.new("TextLabel")
    speedLabel.Size = UDim2.new(1, 0, 0, 18)
    speedLabel.Position = UDim2.new(0, 0, 0, 188)
    speedLabel.BackgroundTransparency = 1
    speedLabel.Font = Enum.Font.GothamBold
    speedLabel.TextSize = 11
    speedLabel.TextColor3 = COL_SUBTEXT
    speedLabel.TextXAlignment = Enum.TextXAlignment.Left
    speedLabel.Text = ("Speed : %d"):format(flySpeed)
    speedLabel.Parent = content

    local track = Instance.new("Frame")
    track.Size = UDim2.new(1, 0, 0, 6)
    track.Position = UDim2.new(0, 0, 0, 212)
    track.BackgroundColor3 = COL_BTN
    track.Parent = content
    corner(track, 3)

    local fill = Instance.new("Frame")
    fill.BackgroundColor3 = COL_ACCENT
    fill.Size = UDim2.new((flySpeed - MIN_SPEED) / (MAX_SPEED - MIN_SPEED), 0, 1, 0)
    fill.Parent = track
    corner(fill, 3)

    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 14, 0, 14)
    knob.AnchorPoint = Vector2.new(0.5, 0.5)
    knob.Position = UDim2.new(fill.Size.X.Scale, 0, 0.5, 0)
    knob.BackgroundColor3 = Color3.new(1, 1, 1)
    knob.ZIndex = 5
    knob.Parent = track
    corner(knob, 7)

    local draggingSlider = false
    local function updateFromX(xPos)
        local relative = math.clamp((xPos - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
        flySpeed = math.floor(MIN_SPEED + relative * (MAX_SPEED - MIN_SPEED))
        fill.Size = UDim2.new(relative, 0, 1, 0)
        knob.Position = UDim2.new(relative, 0, 0.5, 0)
        speedLabel.Text = ("Speed : %d"):format(flySpeed)
    end

    knob.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then draggingSlider = true end
    end)
    track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then updateFromX(input.Position.X) draggingSlider = true end
    end)
    UIS.InputChanged:Connect(function(input)
        if draggingSlider and input.UserInputType == Enum.UserInputType.MouseMovement then updateFromX(input.Position.X) end
    end)
    UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then draggingSlider = false end
    end)
end

showPlayerPage = function()
    clearPanel()
    panelTitle.Text = "Teleportation"
    setActiveNav("Player")
    flyButtonInstance = nil
    savedPosLabelInstance = nil

    local content = Instance.new("Frame")
    content.Name = "PanelContent"
    content.Size = UDim2.new(1, 0, 1, -30)
    content.Position = UDim2.new(0, 0, 0, 30)
    content.BackgroundTransparency = 1
    content.Parent = panel
    
    -- ================================================
    -- // TRACKING ENGINE & AUTOCOMPLETE (TOP LAYER)
    -- ================================================
    local searchBox = Instance.new("TextBox")
    searchBox.Size = UDim2.new(1, 0, 0, 34)
    searchBox.Position = UDim2.new(0, 0, 0, 0)
    searchBox.BackgroundColor3 = COL_BTN
    searchBox.Text = ""
    searchBox.Font = Enum.Font.GothamBold
    searchBox.TextColor3 = COL_TEXT
    searchBox.TextSize = 12
    searchBox.PlaceholderText = "Target Username..."
    searchBox.Parent = content
    corner(searchBox, 6)
    stroke(searchBox, COL_BORDER, 1)

    local matchesLabel = Instance.new("TextLabel")
    matchesLabel.Size = UDim2.new(1, 0, 0, 20)
    matchesLabel.Position = UDim2.new(0, 4, 0, 38)
    matchesLabel.BackgroundTransparency = 1
    matchesLabel.Font = Enum.Font.GothamMedium
    matchesLabel.TextSize = 11
    matchesLabel.TextColor3 = COL_SUBTEXT
    matchesLabel.TextXAlignment = Enum.TextXAlignment.Left
    matchesLabel.Text = "Matches: None"
    matchesLabel.Parent = content

    local function getTargetPlayer()
        local text = searchBox.Text
        if text == "" then return nil end
        for _, p in ipairs(Players:GetPlayers()) do
            if string.sub(string.lower(p.Name), 1, string.len(text)) == string.lower(text) then
                return p
            end
        end
        return nil
    end

    searchBox:GetPropertyChangedSignal("Text"):Connect(function()
        local text = searchBox.Text
        if text == "" then
            matchesLabel.Text = "Matches: None"
            matchesLabel.TextColor3 = COL_SUBTEXT
            return
        end
        
        local matches = {}
        for _, p in ipairs(Players:GetPlayers()) do
            if string.sub(string.lower(p.Name), 1, string.len(text)) == string.lower(text) then
                table.insert(matches, p.Name)
            end
        end
        
        if #matches == 0 then
            matchesLabel.Text = "Matches: None"
            matchesLabel.TextColor3 = COL_SUBTEXT
        else
            matchesLabel.Text = "Matches: " .. table.concat(matches, ", ")
            matchesLabel.TextColor3 = COL_ACCENT_2
        end
    end)

    -- ================================================
    -- // UNRESTRICTED LONG-DISTANCE TOOLBAR
    -- ================================================
    
    -- Absolute Instant Over-Distance Vector Warp Button
    local gotoBtn = bigButton(content, "Goto", 62, COL_ACCENT)
    gotoBtn.Size = UDim2.new(0, 100, 0, 30)

    gotoBtn.MouseButton1Click:Connect(function()
        local target = getTargetPlayer()
        if target and target.Character and root then
            if flying then bodyVelocity.Velocity = Vector3.zero end
            
            -- Pull raw pivot coordinates directly
            local targetCFrame = target.Character:GetPivot()
            local destination = targetCFrame.Position + Vector3.new(0, 4, 0) -- Placed slightly higher to avoid ground collision
            
            -- FIX: Teleport instantly first so the button registers immediately, then force asset stream loads
            root.CFrame = CFrame.new(destination)
            
            task.spawn(function()
                task.wait(0.01)
                if player and player.Parent then
                    player:RequestStreamAroundAsync(destination)
                end
            end)
        end
    end)

    -- Clean Throttled Long-Distance Spectator Box
    local viewBtn = bigButton(content, "View: OFF", 62, COL_BTN)
    viewBtn.Size = UDim2.new(0, 100, 0, 30)
    viewBtn.Position = UDim2.new(0, 110, 0, 62)

    local spectating = false
    local viewConnection = nil

    viewBtn.MouseButton1Click:Connect(function()
        local target = getTargetPlayer()
        
        if not spectating and target and target.Character then
            spectating = true
            viewBtn.Text = "View: ON"
            viewBtn.BackgroundColor3 = COL_ACCENT_2
            
            cam.CameraType = Enum.CameraType.Scriptable
            
            -- THREAD 1: Pure frame updates for smooth camera tracking motion
            viewConnection = RunService.RenderStepped:Connect(function()
                if target and target.Character then
                    local targetCFrame = target.Character:GetPivot()
                    local targetPos = targetCFrame.Position
                    cam.CFrame = CFrame.new(targetPos + Vector3.new(0, 12, 15), targetPos)
                else
                    if viewConnection then viewConnection:Disconnect() end
                    cam.CameraType = Enum.CameraType.Custom
                    if hum then cam.CameraSubject = hum end
                    spectating = false
                    viewBtn.Text = "View: OFF"
                    viewBtn.BackgroundColor3 = COL_BTN
                end
            end)
            
            -- THREAD 2: Throttled map chunk streaming loader thread
            task.spawn(function()
                while spectating and target and target.Character and player do
                    local targetCFrame = target.Character:GetPivot()
                    player:RequestStreamAroundAsync(targetCFrame.Position)
                    task.wait(0.5) 
                end
            end)
        else
            spectating = false
            viewBtn.Text = "View: OFF"
            viewBtn.BackgroundColor3 = COL_BTN
            
            if viewConnection then viewConnection:Disconnect() end
            cam.CameraType = Enum.CameraType.Custom
            if hum then cam.CameraSubject = hum end
        end
    end)

    Players.PlayerRemoving:Connect(function(leftPlayer)
        local target = getTargetPlayer()
        if leftPlayer == target and spectating then
            spectating = false
            viewBtn.Text = "View: OFF"
            viewBtn.BackgroundColor3 = COL_BTN
            if viewConnection then viewConnection:Disconnect() end
            cam.CameraType = Enum.CameraType.Custom
            if hum then cam.CameraSubject = hum end
        end
    end)

    -- ================================================
    -- // SPEED & JUMP LAYERS (SHIFTED DOWN)
    -- ================================================
    local speedBtn = bigButton(content, customSpeedEnabled and "Custom Speed: ACTIVE" or "Custom Speed: DISABLED", 112, customSpeedEnabled and COL_ACCENT_2 or COL_BTN)
    speedBtn.MouseButton1Click:Connect(function()
        customSpeedEnabled = not customSpeedEnabled
        if not customSpeedEnabled and hum then hum.WalkSpeed = 16 end
        showPlayerPage()
    end)

    local speedBox = Instance.new("TextBox")
    speedBox.Size = UDim2.new(1, 0, 0, 34)
    speedBox.Position = UDim2.new(0, 0, 0, 154)
    speedBox.BackgroundColor3 = COL_BTN
    speedBox.Text = tostring(targetWalkSpeed)
    speedBox.Font = Enum.Font.GothamBold
    speedBox.TextColor3 = COL_TEXT
    speedBox.TextSize = 12
    speedBox.PlaceholderText = "Set WalkSpeed Value..."
    speedBox.Parent = content
    corner(speedBox, 6)
    stroke(speedBox, COL_BORDER, 1)

    speedBox.FocusLost:Connect(function()
        local val = tonumber(speedBox.Text)
        if val then targetWalkSpeed = val else speedBox.Text = tostring(targetWalkSpeed) end
    end)

    local jumpBtn = bigButton(content, customJumpEnabled and "Custom Jump: ACTIVE" or "Custom Jump: DISABLED", 204, customJumpEnabled and COL_ACCENT_2 or COL_BTN)
    jumpBtn.MouseButton1Click:Connect(function()
        customJumpEnabled = not customJumpEnabled
        if not customJumpEnabled and hum then hum.JumpPower = 50 end
        showPlayerPage()
    end)

    local jumpBox = Instance.new("TextBox")
    jumpBox.Size = UDim2.new(1, 0, 0, 34)
    jumpBox.Position = UDim2.new(0, 0, 0, 246)
    jumpBox.BackgroundColor3 = COL_BTN
    jumpBox.Text = tostring(targetJumpPower)
    jumpBox.Font = Enum.Font.GothamBold
    jumpBox.TextColor3 = COL_TEXT
    jumpBox.TextSize = 12
    jumpBox.PlaceholderText = "Set JumpPower Value..."
    jumpBox.Parent = content
    corner(jumpBox, 6)
    stroke(jumpBox, COL_BORDER, 1)

    jumpBox.FocusLost:Connect(function()
        local val = tonumber(jumpBox.Text)
        if val then targetJumpPower = val else jumpBox.Text = tostring(targetJumpPower) end
    end)
end


showWorldPage = function()
    clearPanel()
    panelTitle.Text = "Tp tool Btools etc"
    setActiveNav("Tools")
    flyButtonInstance = nil

    local content = Instance.new("Frame")
    content.Name = "PanelContent"
    content.Size = UDim2.new(1, 0, 1, -30)
    content.Position = UDim2.new(0, 0, 0, 30)
    content.BackgroundTransparency = 1
    content.Parent = panel

    local tpBtn = bigButton(content, tpClickEnabled and "Click TP: ACTIVE" or "Click TP: DISABLED", 0, tpClickEnabled and COL_ACCENT_2 or COL_BTN)
    tpBtn.MouseButton1Click:Connect(function()
        tpClickEnabled = not tpClickEnabled
        btoolsEnabled = false
        showWorldPage()
    end)

    local btBtn = bigButton(content, btoolsEnabled and "Click Delete (BTools): ACTIVE" or "Click Delete (BTools / Visual): DISABLED", 42, btoolsEnabled and COL_ACCENT_2 or COL_BTN)
    btBtn.MouseButton1Click:Connect(function()
        btoolsEnabled = not btoolsEnabled
        tpClickEnabled = false
        showWorldPage()
    end)

    local saveBtn = bigButton(content, "Save Current Spot  (K)", 92, COL_BTN)
    saveBtn.MouseButton1Click:Connect(saveCurrentSpot)

    local loadBtn = bigButton(content, "Load Saved Spot  (L)", 134, COL_BTN)
    loadBtn.MouseButton1Click:Connect(loadSavedSpot)

    savedPosLabelInstance = Instance.new("TextLabel")
    savedPosLabelInstance.Size = UDim2.new(1, 0, 0, 18)
    savedPosLabelInstance.Position = UDim2.new(0, 0, 0, 178)
    savedPosLabelInstance.BackgroundTransparency = 1
    savedPosLabelInstance.Font = Enum.Font.GothamBold
    savedPosLabelInstance.TextSize = 10
    savedPosLabelInstance.TextXAlignment = Enum.TextXAlignment.Left
    savedPosLabelInstance.Parent = content
    updateSavedPosUI()

end

showVisualsPage = function()
    clearPanel()
    panelTitle.Text = "Visual & Rendering"
    setActiveNav("Visuals / ESP")
    flyButtonInstance = nil
    savedPosLabelInstance = nil

    local content = Instance.new("Frame")
    content.Name = "PanelContent"
    content.Size = UDim2.new(1, 0, 1, -30)
    content.Position = UDim2.new(0, 0, 0, 30)
    content.BackgroundTransparency = 1
    content.Parent = panel

    _G.FovCircleActive = _G.FovCircleActive or false
    _G.AutoLockActive = _G.AutoLockActive or false
    _G.FovRadiusSize = _G.FovRadiusSize or 150

    local espBtn = bigButton(content, espEnabled and "Player ESP: ACTIVE" or "Player ESP: DISABLED", 0, espEnabled and COL_ACCENT_2 or COL_BTN)
    espBtn.MouseButton1Click:Connect(function()
        espEnabled = not espEnabled
        espBtn.Text = espEnabled and "Player ESP: ACTIVE" or "Player ESP: DISABLED"
        TweenService:Create(espBtn, TweenInfo.new(0.15), {BackgroundColor3 = espEnabled and COL_ACCENT_2 or COL_BTN}):Play()
        if not espEnabled then refreshESP() end
    end)

    local lockBtn = bigButton(content, _G.AutoLockActive and "Camera Lock: ACTIVE (Hold R)" or "Camera Lock: DISABLED", 44, _G.AutoLockActive and COL_ACCENT_2 or COL_BTN)
    lockBtn.MouseButton1Click:Connect(function()
        _G.AutoLockActive = not _G.AutoLockActive
        lockBtn.Text = _G.AutoLockActive and "Camera Lock: ACTIVE (Hold R)" or "Camera Lock: DISABLED"
        TweenService:Create(lockBtn, TweenInfo.new(0.15), {BackgroundColor3 = _G.AutoLockActive and COL_ACCENT_2 or COL_BTN}):Play()
    end)

    local fovBtn = bigButton(content, _G.FovCircleActive and "FOV Circle: VISIBLE" or "FOV Circle: HIDDEN", 88, _G.FovCircleActive and COL_ACCENT_2 or COL_BTN)
    fovBtn.MouseButton1Click:Connect(function()
        _G.FovCircleActive = not _G.FovCircleActive
        fovBtn.Text = _G.FovCircleActive and "FOV Circle: VISIBLE" or "FOV Circle: HIDDEN"
        TweenService:Create(fovBtn, TweenInfo.new(0.15), {BackgroundColor3 = _G.FovCircleActive and COL_ACCENT_2 or COL_BTN}):Play()
        if _G.FovCircle then _G.FovCircle.Visible = _G.FovCircleActive end
    end)

    local sliderLabel = Instance.new("TextLabel")
    sliderLabel.Size = UDim2.new(1, 0, 0, 18)
    sliderLabel.Position = UDim2.new(0, 0, 0, 140)
    sliderLabel.BackgroundTransparency = 1
    sliderLabel.Font = Enum.Font.GothamBold
    sliderLabel.TextSize = 11
    sliderLabel.TextColor3 = COL_SUBTEXT
    sliderLabel.TextXAlignment = Enum.TextXAlignment.Left
    sliderLabel.Text = ("FOV TRACKING LOCK RADIUS: %d PX"):format(_G.FovRadiusSize)
    sliderLabel.Parent = content

    local track = Instance.new("Frame")
    track.Size = UDim2.new(1, 0, 0, 6)
    track.Position = UDim2.new(0, 0, 0, 164)
    track.BackgroundColor3 = COL_BTN
    track.Parent = content
    corner(track, 3)

    local MIN_FOV, MAX_FOV = 30, 400
    local fill = Instance.new("Frame")
    fill.BackgroundColor3 = COL_ACCENT
    fill.Size = UDim2.new((_G.FovRadiusSize - MIN_FOV) / (MAX_FOV - MIN_FOV), 0, 1, 0)
    fill.Parent = track
    corner(fill, 3)

    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 14, 0, 14)
    knob.AnchorPoint = Vector2.new(0.5, 0.5)
    knob.Position = UDim2.new(fill.Size.X.Scale, 0, 0.5, 0)
    knob.BackgroundColor3 = Color3.new(1, 1, 1)
    knob.ZIndex = 5
    knob.Parent = track
    corner(knob, 7)

    local draggingSlider = false
    local function updateFovFromX(xPos)
        local relative = math.clamp((xPos - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
        _G.FovRadiusSize = math.floor(MIN_FOV + relative * (MAX_FOV - MIN_FOV))
        fill.Size = UDim2.new(relative, 0, 1, 0)
        knob.Position = UDim2.new(relative, 0, 0.5, 0)
        sliderLabel.Text = ("FOV TRACKING LOCK RADIUS: %d PX"):format(_G.FovRadiusSize)
        if _G.FovCircle then _G.FovCircle.Radius = _G.FovRadiusSize end
    end

    knob.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then draggingSlider = true end
    end)
    track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then updateFovFromX(input.Position.X) draggingSlider = true end
    end)
    UIS.InputChanged:Connect(function(input)
        if draggingSlider and input.UserInputType == Enum.UserInputType.MouseMovement then updateFovFromX(input.Position.X) end
    end)
    UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then draggingSlider = false end
    end)

    local TARGET_PART = "Head"
    local MAX_STUD_DISTANCE = 300

    if not _G.FovCircle then
        _G.FovCircle = Drawing.new("Circle")
        _G.FovCircle.Thickness = 1.5
        _G.FovCircle.Color = Color3.fromRGB(140, 90, 255)
        _G.FovCircle.Filled = false
        _G.FovCircle.Transparency = 0.8
        _G.FovCircle.NumSides = 64
    end

    local function getClosestPlayerToMouse()
        local closestTarget = nil
        local shortestDistance = math.huge
        local currentLp = game.Players.LocalPlayer
        local currentCam = workspace.CurrentCamera
        local mouse = currentLp:GetMouse()

        if not currentLp.Character or not currentLp.Character:FindFirstChild("HumanoidRootPart") then return nil end
        local myRoot = currentLp.Character.HumanoidRootPart

        for _, p in ipairs(game.Players:GetPlayers()) do
            if p ~= currentLp and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p.Character:FindFirstChild(TARGET_PART) then
                local targetPart = p.Character[TARGET_PART]
                local targetRoot = p.Character.HumanoidRootPart
                
                local studDistance = (myRoot.Position - targetRoot.Position).Magnitude
                if studDistance <= MAX_STUD_DISTANCE then
                    local screenPos, onScreen = currentCam:WorldToViewportPoint(targetPart.Position)
                    if onScreen then
                        local mousePos = Vector2.new(mouse.X, mouse.Y)
                        local distanceToMouse = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                        
                        if distanceToMouse < shortestDistance and distanceToMouse <= _G.FovRadiusSize then
                            local humanoid = p.Character:FindFirstChildOfClass("Humanoid")
                            if humanoid and humanoid.Health > 0 then
                                shortestDistance = distanceToMouse
                                closestTarget = p.Character
                            end
                        end
                    end
                end
            end
        end
        return closestTarget
    end

    if _G.FovRenderConnection then _G.FovRenderConnection:Disconnect() end
    _G.FovRenderConnection = game:GetService("RunService").RenderStepped:Connect(function()
        local currentLp = game.Players.LocalPlayer
        local currentCam = workspace.CurrentCamera
        local mouse = currentLp:GetMouse()
        
        if _G.FovCircleActive and _G.FovCircle then
            _G.FovCircle.Radius = _G.FovRadiusSize
            _G.FovCircle.Position = Vector2.new(mouse.X, mouse.Y + 36)
            _G.FovCircle.Visible = true
        elseif _G.FovCircle then
            _G.FovCircle.Visible = false
        end

        if _G.AutoLockActive and game:GetService("UserInputService"):IsKeyDown(Enum.KeyCode.R) then
            local targetChar = getClosestPlayerToMouse()
            if targetChar and targetChar:FindFirstChild(TARGET_PART) then
                currentCam.CFrame = CFrame.new(currentCam.CFrame.Position, targetChar[TARGET_PART].Position)
            end
        end
    end)
end

showPerfPage = function()
    clearPanel()
    panelTitle.Text = "Performance"
    setActiveNav("Performance Hub")
    flyButtonInstance = nil
    savedPosLabelInstance = nil

    local content = Instance.new("Frame")
    content.Name = "PanelContent"
    content.Size = UDim2.new(1, 0, 1, -30)
    content.Position = UDim2.new(0, 0, 0, 30)
    content.BackgroundTransparency = 1
    content.Parent = panel

    local pingLabel = Instance.new("TextLabel")
    pingLabel.Size = UDim2.new(1, 0, 0, 24)
    pingLabel.Position = UDim2.new(0, 0, 0, 10)
    pingLabel.BackgroundTransparency = 1
    pingLabel.Font = Enum.Font.GothamBold
    pingLabel.TextSize = 12
    pingLabel.TextColor3 = COL_TEXT
    pingLabel.TextXAlignment = Enum.TextXAlignment.Left
    pingLabel.Parent = content

    local fpsLabel = Instance.new("TextLabel")
    fpsLabel.Size = UDim2.new(1, 0, 0, 24)
    fpsLabel.Position = UDim2.new(0, 0, 0, 40)
    fpsLabel.BackgroundTransparency = 1
    fpsLabel.Font = Enum.Font.GothamBold
    fpsLabel.TextSize = 12
    fpsLabel.TextColor3 = COL_TEXT
    fpsLabel.TextXAlignment = Enum.TextXAlignment.Left
    fpsLabel.Parent = content

    task.spawn(function()
        while content and content.Parent do
            local startUpdate = os.clock()
            RunService.RenderStepped:Wait()
            local fps = 1 / (os.clock() - startUpdate)
            local ping = player:GetNetworkPing() * 1000
            
            pingLabel.Text = string.format("Ping : %.1f ms", ping)
            fpsLabel.Text = string.format("%.0f FPS", fps)
            task.wait(0.5)
        end
    end)
end

mNav1.MouseButton1Click:Connect(showMovementPage)
mNav2.MouseButton1Click:Connect(showPlayerPage)
mNav3.MouseButton1Click:Connect(showWorldPage)
mNav4.MouseButton1Click:Connect(showVisualsPage)
mNav5.MouseButton1Click:Connect(showPerfPage)

showMovementPage()
