--[[
  Voidware Neo UI - Clean Neon/Glass Dashboard
  - Glass/Neon UI, Gradient, animierter Glow
  - Fly (F toggle) + Speed control
  - Theme switch (Dark/Light)
  - FPS + Clock
  - Status HUD bottom-right
  - Teleport Tab (Playerliste)
  - ESP Tab (Highlight Master + pro Spieler)
  - Utility Tab (WalkSpeed, JumpPower, Noclip, Freecam)
  - CurrencyCheck + Diamonds Debug (verbessert)

  Tipp: Falls GUI nicht erscheint, stelle sicher, dass dein Executor HttpGet zulässt.
]]

--// Services
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")

local player = Players.LocalPlayer

--// Helpers
local function create(class, props, parent)
    local obj = Instance.new(class)
    if props then for k,v in pairs(props) do obj[k] = v end end
    if parent then obj.Parent = parent end
    return obj
end

local function safeChar(plr)
    return plr.Character or plr.CharacterAdded:Wait()
end

local function notify(txt)
    pcall(function() StarterGui:SetCore("SendNotification",{Title="Voidware", Text=txt, Duration=3}) end)
end

--// Theme
local Theme = {
    dark = {
        bg = Color3.fromRGB(22,20,45),
        card = Color3.fromRGB(34,30,70),
        side = Color3.fromRGB(28,25,60),
        accent = Color3.fromRGB(126,86,255),
        text = Color3.fromRGB(240,240,255),
        subtext = Color3.fromRGB(190,195,255),
        success = Color3.fromRGB(115,230,180),
        warn = Color3.fromRGB(255,180,120),
        danger = Color3.fromRGB(255,120,120),
        stroke = Color3.fromRGB(120,80,255)
    },
    light = {
        bg = Color3.fromRGB(240,242,255),
        card = Color3.fromRGB(228,232,255),
        side = Color3.fromRGB(212,216,250),
        accent = Color3.fromRGB(110,80,230),
        text = Color3.fromRGB(40,40,60),
        subtext = Color3.fromRGB(80,85,120),
        success = Color3.fromRGB(40,160,120),
        warn = Color3.fromRGB(200,140,60),
        danger = Color3.fromRGB(200,70,70),
        stroke = Color3.fromRGB(110,80,230)
    }
}
local currentTheme = "dark"
local function C(key) return Theme[currentTheme][key] end

--// Blur (Glass feel)
for _,e in ipairs(Lighting:GetChildren()) do
    if e:IsA("BlurEffect") and e.Name == "VoidwareBlur" then e:Destroy() end
end
local blur = create("BlurEffect", {Name="VoidwareBlur", Size=10}, Lighting)

--// Root GUI (PlayerGui für Kompatibilität)
local screenGui = create("ScreenGui", {
    Name="VoidwareNeoUI",
    ResetOnSpawn=false,
    ZIndexBehavior=Enum.ZIndexBehavior.Global
}, player:WaitForChild("PlayerGui"))

--// Main Frame
local mainFrame = create("Frame", {
    Size = UDim2.fromOffset(900, 560),
    Position = UDim2.new(0.5, -450, 0.5, -280),
    BackgroundColor3 = C("bg"),
    BackgroundTransparency = 0.08
}, screenGui)
create("UICorner", {CornerRadius = UDim.new(0,16)}, mainFrame)
local mainStroke = create("UIStroke", {
    Thickness=2,
    ApplyStrokeMode=Enum.ApplyStrokeMode.Border,
    Color = C("stroke")
}, mainFrame)

-- Neon border animation
task.spawn(function()
    while mainFrame.Parent do
        for h=0,1,0.004 do
            mainStroke.Color = Color3.fromHSV(h,0.7,1)
            task.wait(0.03)
        end
    end
end)

-- Toggle GUI via RightShift
UserInputService.InputBegan:Connect(function(input, gpe)
    if not gpe and input.KeyCode == Enum.KeyCode.RightShift then
        mainFrame.Visible = not mainFrame.Visible
    end
end)

-- Header
local header = create("Frame", {
    Size = UDim2.new(1,0,0,56),
    BackgroundColor3 = C("card")
}, mainFrame)
create("UICorner", {CornerRadius = UDim.new(0,14)}, header)
local headerGrad = create("UIGradient", {
    Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(80,70,180)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(45,40,90))
    },
    Rotation = 90
}, header)

local title = create("TextLabel", {
    Size = UDim2.new(1,-160,1,0),
    Position = UDim2.new(0,16,0,0),
    Text = "Voidware • Neo",
    Font = Enum.Font.GothamBold,
    TextScaled = true,
    BackgroundTransparency = 1,
    TextXAlignment = Enum.TextXAlignment.Left,
    TextColor3 = C("text")
}, header)

local themeBtn = create("TextButton", {
    Size = UDim2.new(0,44,0,44),
    Position = UDim2.new(1,-100,0.5,-22),
    Text = "☀️",
    Font = Enum.Font.GothamBold,
    TextScaled = true,
    BackgroundTransparency = 1,
    TextColor3 = C("text")
}, header)

local closeButton = create("TextButton", {
    Size = UDim2.new(0,44,0,44),
    Position = UDim2.new(1,-52,0.5,-22),
    Text = "✕",
    Font = Enum.Font.GothamBold,
    TextScaled = true,
    BackgroundTransparency = 1,
    TextColor3 = C("danger")
}, header)
closeButton.MouseButton1Click:Connect(function()
    screenGui:Destroy()
    if blur then blur:Destroy() end
end)

-- FPS
local fpsLabel = create("TextLabel", {
    Size = UDim2.new(0,120,1,0),
    Position = UDim2.new(1,-230,0,0),
    Text = "FPS: --",
    TextColor3 = C("success"),
    Font = Enum.Font.GothamBold,
    TextScaled = true,
    BackgroundTransparency = 1
}, header)

task.spawn(function()
    local last = tick()
    local count = 0
    while header.Parent do
        RunService.RenderStepped:Wait()
        count += 1
        if tick()-last >= 1 then
            fpsLabel.Text = "FPS: "..count
            count = 0
            last = tick()
        end
    end
end)

-- Sidebar
local sidebar = create("Frame", {
    Size = UDim2.new(0,210,1,-66),
    Position = UDim2.new(0,0,0,66),
    BackgroundColor3 = C("side")
}, mainFrame)
create("UICorner", {CornerRadius = UDim.new(0,14)}, sidebar)

-- Profile bottom
local profileFrame = create("Frame", {
    Size = UDim2.new(1,0,0,78),
    Position = UDim2.new(0,0,1,-78),
    BackgroundColor3 = C("card")
}, sidebar)
create("UICorner", {CornerRadius = UDim.new(0,12)}, profileFrame)

local thumb = (function()
    local ok, img = pcall(function()
        return Players:GetUserThumbnailAsync(player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
    end)
    return ok and img or "rbxassetid://0"
end)()

local avatar = create("ImageLabel", {
    Size = UDim2.new(0,52,0,52),
    Position = UDim2.new(0,12,0.5,-26),
    Image = thumb,
    BackgroundTransparency = 1
}, profileFrame)

local nameLabel = create("TextLabel", {
    Size = UDim2.new(1,-80,1,0),
    Position = UDim2.new(0,72,0,0),
    Text = player.Name .. "\n@" .. player.UserId,
    TextColor3 = C("subtext"),
    Font = Enum.Font.Gotham,
    TextScaled = true,
    TextXAlignment = Enum.TextXAlignment.Left,
    BackgroundTransparency = 1
}, profileFrame)

-- Content
local contentFrame = create("Frame", {
    Size = UDim2.new(1,-220,1,-66),
    Position = UDim2.new(0,220,0,66),
    BackgroundColor3 = C("card")
}, mainFrame)
create("UICorner", {CornerRadius = UDim.new(0,14)}, contentFrame)

local function clearContent()
    for _,child in ipairs(contentFrame:GetChildren()) do
        if not child:IsA("UIListLayout") then child:Destroy() end
    end
end

-- Clock bottom-left
local clock = create("TextLabel", {
    Size = UDim2.new(0,180,0,26),
    Position = UDim2.new(0,14,1,-30),
    TextColor3 = C("subtext"),
    BackgroundTransparency = 1,
    Font = Enum.Font.GothamBold,
    TextScaled = true,
    Text = "🕒 --:--:--"
}, mainFrame)
task.spawn(function()
    while clock.Parent do
        clock.Text = "🕒 " .. os.date("%H:%M:%S")
        task.wait(1)
    end
end)

-- Tabs
local tabs = {
    "Main","Local","Teleport","ESP","Utility","CurrencyCheck","Diamonds Debug","Help"
}
local tabButtons = {}

local function makeTabButton(name, index)
    local btn = create("TextButton", {
        Size = UDim2.new(1,0,0,42),
        Position = UDim2.new(0,0,0,(index-1)*46),
        Text = name,
        TextColor3 = C("text"),
        BackgroundColor3 = Color3.fromRGB(50,45,100),
        Font = Enum.Font.GothamBold,
        TextScaled = true,
        AutoButtonColor = false,
        Parent = sidebar
    })
    create("UICorner", {CornerRadius=UDim.new(0,10)}, btn)
    local stroke = create("UIStroke", {Thickness=1, Color = C("accent")}, btn)

    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(80,70,180)}):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(50,45,100)}):Play()
    end)

    tabButtons[name] = btn
    return btn
end

for i,tabName in ipairs(tabs) do
    makeTabButton(tabName, i)
end

-- THEME SWITCH
local recolorList = {mainFrame, header, sidebar, profileFrame, contentFrame, title, nameLabel, fpsLabel, clock, mainStroke}
local function applyTheme()
    mainFrame.BackgroundColor3 = C("bg")
    header.BackgroundColor3 = C("card")
    sidebar.BackgroundColor3 = C("side")
    profileFrame.BackgroundColor3 = C("card")
    contentFrame.BackgroundColor3 = C("card")
    mainStroke.Color = C("stroke")

    title.TextColor3 = C("text")
    nameLabel.TextColor3 = C("subtext")
    fpsLabel.TextColor3 = C("success")
    clock.TextColor3 = C("subtext")
    themeBtn.TextColor3 = C("text")
end

themeBtn.MouseButton1Click:Connect(function()
    currentTheme = (currentTheme == "dark") and "light" or "dark"
    themeBtn.Text = (currentTheme == "dark") and "☀️" or "🌙"
    applyTheme()
end)

applyTheme()

----------------------------------------------------------------
-- STATUS HUD (unten rechts)
----------------------------------------------------------------
local statusFrame = create("Frame", {
    Size = UDim2.new(0,260,0,42),
    Position = UDim2.new(1,-270,1,-52),
    BackgroundColor3 = Color3.fromRGB(40,35,90),
    BackgroundTransparency = 0.2,
    Parent = screenGui
})
create("UICorner", {CornerRadius=UDim.new(0,10)}, statusFrame)
local statusText = create("TextLabel", {
    Size = UDim2.new(1,0,1,0),
    Text = "✅ Voidware Neo geladen – bereit",
    Font = Enum.Font.GothamBold,
    TextScaled = true,
    TextColor3 = Color3.fromRGB(200,255,200),
    BackgroundTransparency = 1,
    Parent = statusFrame
})
statusFrame.BackgroundTransparency = 1
statusText.TextTransparency = 1
TweenService:Create(statusFrame, TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 0.2}):Play()
TweenService:Create(statusText, TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextTransparency = 0}):Play()
task.delay(8, function()
    if statusFrame and statusFrame.Parent then
        TweenService:Create(statusFrame, TweenInfo.new(1.2), {BackgroundTransparency = 1}):Play()
        TweenService:Create(statusText, TweenInfo.new(1.2), {TextTransparency = 1}):Play()
        task.wait(1.2)
        if statusFrame then statusFrame:Destroy() end
    end
end)

----------------------------------------------------------------
-- FEATURE: Fly (F-Toggle) + Speed
----------------------------------------------------------------
local flying, flySpeed = false, 80
local bodyGyro, bodyVel
local flyConn

local function setFly(active)
    local char = safeChar(player)
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    flying = active
    if active then
        bodyGyro = create("BodyGyro", {MaxTorque = Vector3.new(1e9,1e9,1e9), P=1e5, CFrame=hrp.CFrame}, hrp)
        bodyVel = create("BodyVelocity", {MaxForce = Vector3.new(1e9,1e9,1e9), Velocity = Vector3.zero}, hrp)

        flyConn = RunService.RenderStepped:Connect(function()
            local cam = workspace.CurrentCamera
            local move = Vector3.zero
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then move += cam.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then move -= cam.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then move -= cam.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then move += cam.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then move += Vector3.new(0,1,0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then move -= Vector3.new(0,1,0) end

            bodyGyro.CFrame = cam.CFrame
            bodyVel.Velocity = (move.Magnitude > 0) and (move.Unit * flySpeed) or Vector3.zero
        end)
        notify("Fly aktiviert")
    else
        if flyConn then flyConn:Disconnect() end
        if bodyGyro then bodyGyro:Destroy() end
        if bodyVel then bodyVel:Destroy() end
        notify("Fly deaktiviert")
    end
end

UserInputService.InputBegan:Connect(function(input, gpe)
    if not gpe and input.KeyCode == Enum.KeyCode.F then
        setFly(not flying)
    end
end)

----------------------------------------------------------------
-- BUILDERS: small UI components
----------------------------------------------------------------
local function sectionTitle(text, parent, y)
    return create("TextLabel", {
        Size = UDim2.new(1, -20, 0, 40),
        Position = UDim2.new(0,10,0,y or 10),
        Text = text,
        Font = Enum.Font.GothamBold,
        TextScaled = true,
        TextColor3 = C("text"),
        BackgroundTransparency = 1,
        Parent = parent
    })
end

local function button(text, parent, pos, size, bg, callback)
    local btn = create("TextButton", {
        Size = size or UDim2.new(0,120,0,36),
        Position = pos or UDim2.new(0,10,0,60),
        Text = text,
        Font = Enum.Font.GothamBold,
        TextScaled = true,
        BackgroundColor3 = bg or C("accent"),
        TextColor3 = Color3.fromRGB(255,255,255),
        AutoButtonColor = false,
        Parent = parent
    })
    create("UICorner", {CornerRadius=UDim.new(0,10)}, btn)
    create("UIStroke", {Thickness=1, Color=Color3.fromRGB(255,255,255), Transparency=0.7}, btn)
    btn.MouseButton1Click:Connect(function()
        if callback then callback() end
    end)
    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundTransparency = 0.05}):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundTransparency = 0}):Play()
    end)
    return btn
end

local function label(text, parent, pos, size, color)
    return create("TextLabel", {
        Size = size or UDim2.new(0,200,0,30),
        Position = pos or UDim2.new(0,10,0,100),
        Text = text,
        Font = Enum.Font.Gotham,
        TextScaled = true,
        TextColor3 = color or C("subtext"),
        BackgroundTransparency = 1,
        Parent = parent
    })
end

local function slider(titleText, min, max, getVal, setVal, parent, y)
    local title = label(titleText, parent, UDim2.new(0,10,0,y or 0), UDim2.new(0,240,0,26), C("text"))
    local container = create("Frame", {
        Size = UDim2.new(0, 300, 0, 10),
        Position = UDim2.new(0,10,0,(y or 0)+28),
        BackgroundColor3 = Color3.fromRGB(70,65,140),
        Parent = parent
    })
    create("UICorner", {CornerRadius=UDim.new(0,5)}, container)
    local fill = create("Frame", {
        Size = UDim2.new((getVal()-min)/(max-min),0,1,0),
        BackgroundColor3 = C("accent"),
        Parent = container
    })
    create("UICorner", {CornerRadius=UDim.new(0,5)}, fill)
    local valueLbl = label(tostring(getVal()), parent, UDim2.new(0,320,0,(y or 0)+16), UDim2.new(0,80,0,24), C("subtext"))

    local dragging = false
    container.InputBegan:Connect(function(io)
        if io.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true end
    end)
    container.InputEnded:Connect(function(io)
        if io.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)
    UserInputService.InputChanged:Connect(function(io)
        if dragging and io.UserInputType == Enum.UserInputType.MouseMovement then
            local rel = math.clamp((io.Position.X - container.AbsolutePosition.X)/container.AbsoluteSize.X, 0, 1)
            local value = math.floor(min + rel*(max-min))
            fill.Size = UDim2.new(rel,0,1,0)
            setVal(value)
            valueLbl.Text = tostring(value)
        end
    end)
end

----------------------------------------------------------------
-- TAB: Main
----------------------------------------------------------------
tabButtons["Main"].MouseButton1Click:Connect(function()
    clearContent()
    sectionTitle("🌈 Willkommen zu Voidware Neo", contentFrame, 10)
    label("• RightShift: GUI ein/aus", contentFrame, UDim2.new(0,10,0,58))
    label("• F: Fly Toggle", contentFrame, UDim2.new(0,10,0,88))
    label("• Light/Dark Theme per Button oben rechts", contentFrame, UDim2.new(0,10,0,118))
    label("• Tabs links für Features", contentFrame, UDim2.new(0,10,0,148))
end)

----------------------------------------------------------------
-- TAB: Local (Fly + Speed)
----------------------------------------------------------------
tabButtons["Local"].MouseButton1Click:Connect(function()
    clearContent()
    sectionTitle("🕊️ Fly System", contentFrame, 10)
    label("F: Ein/Aus • Space/Shift: Hoch/Runter", contentFrame, UDim2.new(0,10,0,54))

    slider("Speed", 10, 300, function() return flySpeed end, function(v) flySpeed = v end, contentFrame, 92)

    button(flying and "Fly AUS" or "Fly AN", contentFrame, UDim2.new(0,10,0,140), UDim2.new(0,120,0,36), C("accent"), function()
        setFly(not flying)
    end)
end)

----------------------------------------------------------------
-- TAB: Teleport (Spielerliste)
----------------------------------------------------------------
local function listPlayers(scroll)
    for _,c in ipairs(scroll:GetChildren()) do if c:IsA("Frame") then c:Destroy() end end
    local y = 0
    for _,plr in ipairs(Players:GetPlayers()) do
        local row = create("Frame",{
            Size=UDim2.new(1,-10,0,34),
            Position=UDim2.new(0,5,0,y),
            BackgroundColor3 = Color3.fromRGB(60,55,110),
            Parent=scroll
        })
        create("UICorner",{CornerRadius=UDim.new(0,8)},row)
        local name = label(plr.Name, row, UDim2.new(0,10,0,2), UDim2.new(0,220,0,30), C("text"))
        local tpBtn = button("Teleport", row, UDim2.new(1,-120,0,2), UDim2.new(0,110,0,30), C("accent"), function()
            local myChar, targetChar = safeChar(player), safeChar(plr)
            local myHRP, tHRP = myChar:FindFirstChild("HumanoidRootPart"), targetChar and targetChar:FindFirstChild("HumanoidRootPart")
            if myHRP and tHRP then
                myHRP.CFrame = tHRP.CFrame + tHRP.CFrame.LookVector * 2
                notify("Teleported to "..plr.Name)
            end
        end)
        y = y + 38
        scroll.CanvasSize = UDim2.new(0,0,0,y+10)
    end
end

tabButtons["Teleport"].MouseButton1Click:Connect(function()
    clearContent()
    sectionTitle("🧍 Teleport", contentFrame, 10)

    local scroll = create("ScrollingFrame", {
        Size = UDim2.new(1,-20,1,-70),
        Position = UDim2.new(0,10,0,52),
        CanvasSize = UDim2.new(0,0,0,0),
        ScrollBarThickness = 6,
        BackgroundTransparency = 1,
        Parent = contentFrame
    })
    button("Refresh", contentFrame, UDim2.new(1,-130,0,12), UDim2.new(0,120,0,32), C("warn"), function()
        listPlayers(scroll)
    end)
    listPlayers(scroll)
end)

----------------------------------------------------------------
-- TAB: ESP
----------------------------------------------------------------
local espEnabled = false
local espMap = {} -- plr -> Highlight

local function setESPForPlayer(plr, on)
    if on then
        if espMap[plr] and espMap[plr].Parent then return end
        local char = safeChar(plr)
        local hl = create("Highlight", {
            FillColor = C("accent"),
            OutlineColor = Color3.fromRGB(255,255,255),
            FillTransparency = 0.7,
            OutlineTransparency = 0.1,
            Parent = char
        })
        espMap[plr] = hl
    else
        if espMap[plr] then
            espMap[plr]:Destroy()
            espMap[plr] = nil
        end
    end
end

local function setESP(on)
    espEnabled = on
    for _,plr in ipairs(Players:GetPlayers()) do
        if plr ~= player then
            setESPForPlayer(plr, on)
        end
    end
end

Players.PlayerAdded:Connect(function(plr)
    if espEnabled and plr ~= player then
        task.delay(1, function() setESPForPlayer(plr, true) end)
    end
end)
Players.PlayerRemoving:Connect(function(plr)
    if espMap[plr] then espMap[plr]:Destroy() espMap[plr]=nil end
end)

tabButtons["ESP"].MouseButton1Click:Connect(function()
    clearContent()
    sectionTitle("🎯 ESP", contentFrame, 10)

    local masterBtn = button(espEnabled and "Master: ON" or "Master: OFF", contentFrame, UDim2.new(0,10,0,54), UDim2.new(0,160,0,36), C("accent"), function()
        setESP(not espEnabled)
        masterBtn.Text = espEnabled and "Master: ON" or "Master: OFF"
    end)

    local scroll = create("ScrollingFrame", {
        Size = UDim2.new(1,-20,1,-110),
        Position = UDim2.new(0,10,0,100),
        CanvasSize = UDim2.new(0,0,0,0),
        ScrollBarThickness = 6,
        BackgroundTransparency = 1,
        Parent = contentFrame
    })

    local y=0
    for _,plr in ipairs(Players:GetPlayers()) do
        if plr ~= player then
            local row = create("Frame",{
                Size=UDim2.new(1,-10,0,34),
                Position=UDim2.new(0,5,0,y),
                BackgroundColor3 = Color3.fromRGB(60,55,110),
                Parent=scroll
            })
            create("UICorner",{CornerRadius=UDim.new(0,8)},row)
            label(plr.Name, row, UDim2.new(0,10,0,2), UDim2.new(0,220,0,30), C("text"))
            button(espMap[plr] and "ON" or "OFF", row, UDim2.new(1,-120,0,2), UDim2.new(0,110,0,30), C("accent"), function(btn)
                local turnOn = not espMap[plr]
                setESPForPlayer(plr, turnOn)
                btn.Text = turnOn and "ON" or "OFF"
            end)
            y = y + 38
        end
    end
    scroll.CanvasSize = UDim2.new(0,0,0,y+10)
end)

----------------------------------------------------------------
-- TAB: Utility (WalkSpeed, JumpPower, Noclip, Freecam)
----------------------------------------------------------------
local noclip = false
local noclipConn
local function setNoclip(on)
    noclip = on
    if on then
        if noclipConn then noclipConn:Disconnect() end
        noclipConn = RunService.Stepped:Connect(function()
            local char = player.Character
            if char then
                for _,p in ipairs(char:GetDescendants()) do
                    if p:IsA("BasePart") then p.CanCollide = false end
                end
            end
        end)
        notify("Noclip an")
    else
        if noclipConn then noclipConn:Disconnect() end
        notify("Noclip aus")
    end
end

-- Freecam basic
local freecam = false
local camConn, rotX, rotY, camPos
local function setFreecam(on)
    freecam = on
    local cam = workspace.CurrentCamera
    if on then
        cam.CameraType = Enum.CameraType.Scriptable
        camPos = cam.CFrame.Position
        rotX, rotY = 0,0
        local moveSpeed = 1.5
        camConn = RunService.RenderStepped:Connect(function(dt)
            -- Rotation via Mouse Delta
            local delta = UserInputService:GetMouseDelta()
            rotX = rotX - delta.Y*0.002
            rotY = rotY - delta.X*0.002
            rotX = math.clamp(rotX, -1.55, 1.55)

            local cf = CFrame.new(camPos) * CFrame.Angles(0, rotY, 0) * CFrame.Angles(rotX, 0, 0)
            local mv = Vector3.zero
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then mv += cf.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then mv -= cf.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then mv -= cf.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then mv += cf.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then mv += Vector3.new(0,1,0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then mv -= Vector3.new(0,1,0) end

            camPos += mv * (60*dt) * moveSpeed
            cam.CFrame = CFrame.new(camPos) * CFrame.Angles(0, rotY, 0) * CFrame.Angles(rotX, 0, 0)
        end)
        notify("Freecam an")
    else
        if camConn then camConn:Disconnect() end
        workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
        notify("Freecam aus")
    end
end

tabButtons["Utility"].MouseButton1Click:Connect(function()
    clearContent()
    sectionTitle("⚡ Utility", contentFrame, 10)

    -- WalkSpeed & JumpPower
    local hum = safeChar(player):WaitForChild("Humanoid")
    local ws, jp = hum.WalkSpeed, hum.JumpPower

    slider("WalkSpeed", 8, 200, function() return hum.WalkSpeed end, function(v) hum.WalkSpeed = v end, contentFrame, 54)
    slider("JumpPower", 10, 200, function() return hum.JumpPower end, function(v) hum.JumpPower = v end, contentFrame, 114)

    button(noclip and "Noclip AUS" or "Noclip AN", contentFrame, UDim2.new(0,10,0,172), UDim2.new(0,140,0,36), C("warn"), function(btn)
        setNoclip(not noclip)
        btn.Text = noclip and "Noclip AUS" or "Noclip AN"
    end)

    button(freecam and "Freecam AUS" or "Freecam AN", contentFrame, UDim2.new(0,160,0,172), UDim2.new(0,160,0,36), C("accent"), function(btn)
        setFreecam(not freecam)
        btn.Text = freecam and "Freecam AUS" or "Freecam AN"
    end)

    button("Reset WS/JP", contentFrame, UDim2.new(0,330,0,172), UDim2.new(0,140,0,36), C("danger"), function()
        hum.WalkSpeed, hum.JumpPower = ws, jp
        notify("WalkSpeed/JumpPower zurückgesetzt")
    end)
end)

----------------------------------------------------------------
-- TAB: CurrencyCheck
----------------------------------------------------------------
local function searchForCurrency()
    local results, keywords = {}, {"coin","coins","gold","money","cash","gems","gem","diamond","diamonds"}
    local function scan(obj)
        for _,child in ipairs(obj:GetChildren()) do
            for _,key in ipairs(keywords) do
                if string.find(child.Name:lower(), key) then
                    table.insert(results, child)
                    break
                end
            end
            scan(child)
        end
    end
    scan(game)
    return results
end

tabButtons["CurrencyCheck"].MouseButton1Click:Connect(function()
    clearContent()
    sectionTitle("💰 Gefundene Currency-Objekte", contentFrame, 10)

    local scroll = create("ScrollingFrame", {
        Size = UDim2.new(1,-20,1,-70),
        Position = UDim2.new(0,10,0,52),
        BackgroundTransparency = 1,
        ScrollBarThickness = 6,
        CanvasSize = UDim2.new(0,0,0,0),
        Parent = contentFrame
    })

    local results = searchForCurrency()
    local y = 0
    if #results == 0 then
        label("❌ Keine Currency Objekte gefunden.", scroll, UDim2.new(0,10,0,0), UDim2.new(1,-20,0,30), C("danger"))
    else
        for _,obj in ipairs(results) do
            local line = label(obj:GetFullName().." ["..obj.ClassName.."]", scroll, UDim2.new(0,10,0,y), UDim2.new(1,-20,0,24), Color3.fromRGB(200,255,200))
            y = y + 28
        end
        scroll.CanvasSize = UDim2.new(0,0,0,y+10)
    end

    button("Alles kopieren", contentFrame, UDim2.new(1,-160,0,12), UDim2.new(0,150,0,32), C("accent"), function()
        local t = {}
        for _,obj in ipairs(results) do table.insert(t, obj:GetFullName().." ["..obj.ClassName.."]") end
        local output = table.concat(t, "\n")
        if setclipboard then setclipboard(output) notify("In Zwischenablage kopiert.") else warn("setclipboard nicht verfügbar") end
    end)
end)

----------------------------------------------------------------
-- TAB: Diamonds Debug
----------------------------------------------------------------
local function searchDiamondRemotes()
    local results = {}
    for _,obj in ipairs(ReplicatedStorage:GetDescendants()) do
        local n = obj.Name:lower()
        if (n:find("diamond") or n:find("gem")) and (obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction")) then
            table.insert(results, obj)
        end
    end
    return results
end

tabButtons["Diamonds Debug"].MouseButton1Click:Connect(function()
    clearContent()
    sectionTitle("💎 Diamond Remotes", contentFrame, 10)

    local scroll = create("ScrollingFrame", {
        Size = UDim2.new(1,-20,1,-70),
        Position = UDim2.new(0,10,0,52),
        BackgroundTransparency = 1,
        ScrollBarThickness = 6,
        CanvasSize = UDim2.new(0,0,0,0),
        Parent = contentFrame
    })

    local remotes = searchDiamondRemotes()
    local y = 0
    if #remotes == 0 then
        label("❌ Keine Diamond Remotes gefunden.", scroll, UDim2.new(0,10,0,0), UDim2.new(1,-20,0,30), C("danger"))
    else
        for _,remote in ipairs(remotes) do
            local row = create("Frame", {
                Size = UDim2.new(1,-10,0,34),
                Position = UDim2.new(0,5,0,y),
                BackgroundColor3 = Color3.fromRGB(60,55,110),
                Parent = scroll
            })
            create("UICorner", {CornerRadius=UDim.new(0,8)}, row)

            label(remote:GetFullName(), row, UDim2.new(0,10,0,2), UDim2.new(0,360,0,30), C("text"))

            local input = create("TextBox", {
                Size = UDim2.new(0,70,0,28),
                Position = UDim2.new(0,380,0,3),
                PlaceholderText = "10",
                Text = "",
                TextSize = 14,
                Font = Enum.Font.Gotham,
                BackgroundColor3 = Color3.fromRGB(70,65,130),
                TextColor3 = Color3.fromRGB(255,255,255),
                Parent = row
            })
            create("UICorner", {CornerRadius=UDim.new(0,6)}, input)

            button("Fire", row, UDim2.new(1,-90,0,3), UDim2.new(0,80,0,28), C("accent"), function()
                local amount = tonumber(input.Text) or 10
                if remote:IsA("RemoteEvent") then
                    remote:FireServer(amount)
                    print("🔥 FireServer:", remote:GetFullName(), amount)
                elseif remote:IsA("RemoteFunction") then
                    local result = remote:InvokeServer(amount)
                    print("📡 InvokeServer:", remote:GetFullName(), amount, "->", result)
                end
            end)

            y = y + 38
        end
        scroll.CanvasSize = UDim2.new(0,0,0,y+10)
    end
end)

----------------------------------------------------------------
-- TAB: Help
----------------------------------------------------------------
tabButtons["Help"].MouseButton1Click:Connect(function()
    clearContent()
    sectionTitle("❓ Hilfe & Shortcuts", contentFrame, 10)
    label("• RightShift: GUI ein/aus", contentFrame, UDim2.new(0,10,0,54))
    label("• F: Fly an/aus", contentFrame, UDim2.new(0,10,0,84))
    label("• ESP, Teleport, Utility in Tabs links", contentFrame, UDim2.new(0,10,0,114))
    label("• Theme Switch oben rechts", contentFrame, UDim2.new(0,10,0,144))
end)

-- Standard-Tab öffnen
tabButtons["Main"]:Activate()

-- Fertig!
print("✅ Voidware Neo UI geladen.")
