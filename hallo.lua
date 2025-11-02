-- Voidware Luminous UI (Feature-Gates, moderne Optik, Fly+Speed, Teleport, ESP, Utility, Currency, Diamonds)

--// Services
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")

local player = Players.LocalPlayer

--// Utils
local function create(class, props, parent)
    local o = Instance.new(class)
    if props then for k,v in pairs(props) do o[k] = v end end
    if parent then o.Parent = parent end
    return o
end

local function safeChar(plr)
    return plr.Character or plr.CharacterAdded:Wait()
end

local function notify(txt)
    pcall(function()
        StarterGui:SetCore("SendNotification", {Title="Voidware", Text=txt, Duration=3})
    end)
end

-- weiße Vektor-Icons (Frames)
local function makeIcon_Close(parent, size)
    local holder = create("Frame", { Size = size or UDim2.fromOffset(20,20), BackgroundTransparency = 1 }, parent)
    local function line(rot)
        local l = create("Frame", {
            AnchorPoint = Vector2.new(0.5,0.5),
            Position = UDim2.fromScale(0.5,0.5),
            Size = UDim2.new(1, -4, 0, 2),
            BackgroundColor3 = Color3.fromRGB(255,255,255),
            BorderSizePixel = 0
        }, holder)
        create("UICorner",{CornerRadius=UDim.new(1,0)}, l)
        l.Rotation = rot
        return l
    end
    line(45); line(-45)
    return holder
end

local function makeIcon_Sun(parent, size)
    local holder = create("Frame", {Size=size or UDim2.fromOffset(22,22), BackgroundTransparency=1}, parent)
    local core = create("Frame", { AnchorPoint=Vector2.new(0.5,0.5), Position = UDim2.fromScale(0.5,0.5), Size = UDim2.new(0,10,0,10), BackgroundColor3 = Color3.fromRGB(255,255,255), BorderSizePixel=0 }, holder)
    create("UICorner",{CornerRadius=UDim.new(1,0)}, core)
    local function ray(rot)
        local r = create("Frame",{ AnchorPoint=Vector2.new(0.5,0.5), Position = UDim2.fromScale(0.5,0.5), Size = UDim2.new(0,14,0,2), BackgroundColor3 = Color3.fromRGB(255,255,255), BorderSizePixel=0 }, holder)
        create("UICorner",{CornerRadius=UDim.new(1,0)}, r)
        r.Rotation = rot
        return r
    end
    for i=0,7 do ray(i*45) end
    return holder
end

local function makeIcon_Moon(parent, size)
    local holder = create("Frame", {Size=size or UDim2.fromOffset(22,22), BackgroundTransparency=1}, parent)
    local big = create("Frame",{ AnchorPoint=Vector2.new(0.5,0.5), Position=UDim2.fromScale(0.5,0.5), Size = UDim2.new(0,16,0,16), BackgroundColor3 = Color3.fromRGB(255,255,255), BorderSizePixel=0 }, holder)
    create("UICorner",{CornerRadius=UDim.new(1,0)}, big)
    local cut = create("Frame",{ AnchorPoint=Vector2.new(0.5,0.5), Position=UDim2.new(0.6,0,0.45,0), Size = UDim2.new(0,16,0,16), BackgroundColor3 = Color3.fromRGB(170,170,220), BorderSizePixel=0 }, holder)
    create("UICorner",{CornerRadius=UDim.new(1,0)}, cut)
    return holder
end

--// Theme
local Theme = {
    lilac = {
        bg = Color3.fromRGB(245, 240, 255), card = Color3.fromRGB(234,226,255), side = Color3.fromRGB(222,212,255),
        accent = Color3.fromRGB(155,120,255), text = Color3.fromRGB(35,25,60), subtext = Color3.fromRGB(90,75,140),
        success = Color3.fromRGB(40,160,120), warn = Color3.fromRGB(200,140,60), danger = Color3.fromRGB(200,80,80),
        stroke = Color3.fromRGB(170,140,255), glowWhite = Color3.fromRGB(255,255,255)
    },
    lilacDark = {
        bg = Color3.fromRGB(34,28,60), card = Color3.fromRGB(46,38,85), side = Color3.fromRGB(40,34,75),
        accent = Color3.fromRGB(170,140,255), text = Color3.fromRGB(240,235,255), subtext = Color3.fromRGB(190,185,235),
        success = Color3.fromRGB(115,230,180), warn = Color3.fromRGB(255,190,120), danger = Color3.fromRGB(255,120,120),
        stroke = Color3.fromRGB(190,160,255), glowWhite = Color3.fromRGB(255,255,255)
    }
}
local currentTheme = "lilacDark"
local function C(k) return Theme[currentTheme][k] end

-- Glass-Blur (einzigartig)
for _,e in ipairs(Lighting:GetChildren()) do
    if e:IsA("BlurEffect") and e.Name == "VoidwareLuminousBlur" then e:Destroy() end
end
local blur = create("BlurEffect", {Name="VoidwareLuminousBlur", Size=8}, Lighting)

--// Permission gating (Default = alles AN für Tests)
local DefaultPermissions = {
    CanFly = true,
    CanTeleport = true,
    CanESP = true,
    CanUtility = true,
    CanInspectCurrency = true,
    CanDebugDiamonds = true,
}

-- WICHTIG: Nur ein echtes true-Attribut überschreibt. false/nil -> DefaultPermissions.
local function Allowed(feature)
    local attr = player:GetAttribute(feature)
    if attr == true then return true end
    return DefaultPermissions[feature] == true
end

--// Root GUI
local screenGui = create("ScreenGui", { Name="VoidwareLuminousUI", ResetOnSpawn=false, ZIndexBehavior=Enum.ZIndexBehavior.Global }, player:WaitForChild("PlayerGui"))

--// Main Window
local mainFrame = create("Frame", { Size = UDim2.fromOffset(940, 600), Position = UDim2.new(0.5, -470, 0.5, -300), BackgroundColor3 = C("bg"), BackgroundTransparency = 0.06 }, screenGui)
create("UICorner", {CornerRadius = UDim.new(0,18)}, mainFrame)
local mainStroke = create("UIStroke", {Thickness=2, ApplyStrokeMode=Enum.ApplyStrokeMode.Border, Color=C("stroke")}, mainFrame)

-- Inner Neon Glow (entschärft)
local innerGlow = create("Frame", { AnchorPoint = Vector2.new(0.5,0.5), Position = UDim2.fromScale(0.5,0.5), Size = UDim2.new(0.9,0,0.9,0), BackgroundColor3 = C("glowWhite"), BackgroundTransparency = 0.9, BorderSizePixel = 0 }, mainFrame)
create("UICorner", {CornerRadius=UDim.new(0,16)}, innerGlow)
local glowGrad = create("UIGradient", {
    Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0.0, Color3.fromRGB(255,255,255)),
        ColorSequenceKeypoint.new(0.25, Color3.fromRGB(255,255,255)),
        ColorSequenceKeypoint.new(1.0, Color3.fromRGB(255,255,255))
    },
    Transparency = NumberSequence.new{
        NumberSequenceKeypoint.new(0.0, 0.3),
        NumberSequenceKeypoint.new(0.6, 0.78),
        NumberSequenceKeypoint.new(1.0, 1.0)
    },
    Rotation = 0
}, innerGlow)

task.spawn(function()
    local t = 0
    while innerGlow.Parent do
        t += RunService.Heartbeat:Wait()
        local alpha = 0.25 + 0.05*math.sin(t*1.2)
        glowGrad.Transparency = NumberSequence.new{
            NumberSequenceKeypoint.new(0.0, alpha),
            NumberSequenceKeypoint.new(0.6, math.clamp(alpha+0.45,0,1)),
            NumberSequenceKeypoint.new(1.0, 1.0)
        }
    end
end)

-- Header (draggable)
local header = create("Frame", { Size = UDim2.new(1,0,0,64), BackgroundColor3 = C("card") }, mainFrame)
create("UICorner",{CornerRadius=UDim.new(0,16)}, header)
create("UIGradient", { Color = ColorSequence.new{ ColorSequenceKeypoint.new(0, Color3.fromRGB(220,210,255)), ColorSequenceKeypoint.new(1, Color3.fromRGB(210,200,255)) }, Rotation = 90 }, header)
local title = create("TextLabel", { Size = UDim2.new(1,-180,1,0), Position = UDim2.new(0,18,0,0), Text = "Voidware • Luminous", Font = Enum.Font.GothamBold, TextScaled = true, TextXAlignment = Enum.TextXAlignment.Left, TextColor3 = C("text"), BackgroundTransparency = 1 }, header)

local themeBtn = create("TextButton", { Size = UDim2.new(0,44,0,44), Position = UDim2.new(1,-110,0.5,-22), BackgroundTransparency = 1, Text = "" }, header)
local themeIcon = makeIcon_Sun(themeBtn, UDim2.fromOffset(22,22))

local closeButton = create("TextButton", { Size = UDim2.new(0,44,0,44), Position = UDim2.new(1,-60,0.5,-22), BackgroundTransparency = 1, Text = "" }, header)
makeIcon_Close(closeButton, UDim2.fromOffset(20,20))
closeButton.MouseButton1Click:Connect(function()
    screenGui:Destroy()
    if blur then blur:Destroy() end
end)

-- FPS
local fpsLabel = create("TextLabel", { Size = UDim2.new(0,120,1,0), Position = UDim2.new(1,-240,0,0), Text = "FPS: --", TextColor3 = C("success"), Font = Enum.Font.GothamBold, TextScaled = true, BackgroundTransparency = 1 }, header)
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

-- Drag
do
    local dragging = false
    local dragStart, startPos
    header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = mainFrame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

-- Sidebar
local sidebar = create("Frame", { Size = UDim2.new(0,220,1,-72), Position = UDim2.new(0,0,0,72), BackgroundColor3 = C("side") }, mainFrame)
create("UICorner",{CornerRadius=UDim.new(0,14)}, sidebar)
if currentTheme == "lilacDark" then
    sidebar.BackgroundColor3 = Color3.fromRGB(36,30,60)
end

-- Profile Footer
local profileFrame = create("Frame", { Size = UDim2.new(1,0,0,84), Position = UDim2.new(0,0,1,-84), BackgroundColor3 = C("card") }, sidebar)
create("UICorner",{CornerRadius=UDim.new(0,12)}, profileFrame)
local thumb = (function()
    local ok, img = pcall(function()
        return Players:GetUserThumbnailAsync(player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
    end)
    return ok and img or "rbxassetid://0"
end)()
create("ImageLabel", { Size = UDim2.new(0,56,0,56), Position = UDim2.new(0,14,0.5,-28), Image = thumb, BackgroundTransparency = 1 }, profileFrame)
local nameLabel = create("TextLabel", { Size = UDim2.new(1,-90,1,0), Position = UDim2.new(0,80,0,0), Text = player.Name .. "\n@" .. player.UserId, TextColor3 = C("subtext"), Font = Enum.Font.Gotham, TextScaled = true, TextXAlignment = Enum.TextXAlignment.Left, BackgroundTransparency = 1 }, profileFrame)

-- Content
local contentFrame = create("Frame", { Size = UDim2.new(1,-230,1,-72), Position = UDim2.new(0,230,0,72), BackgroundColor3 = C("card") }, mainFrame)
create("UICorner",{CornerRadius=UDim.new(0,14)}, contentFrame)

local contentGlow = create("Frame", { AnchorPoint=Vector2.new(0.5,0.5), Position=UDim2.fromScale(0.5,0.1), Size = UDim2.new(0.8,0,0,80), BackgroundColor3 = C("glowWhite"), BackgroundTransparency = 0.92, BorderSizePixel=0, Parent = contentFrame })
create("UICorner",{CornerRadius=UDim.new(0,40)}, contentGlow)
create("UIGradient", { Color = ColorSequence.new(Color3.new(1,1,1), Color3.new(1,1,1)), Transparency = NumberSequence.new{ NumberSequenceKeypoint.new(0,0.4), NumberSequenceKeypoint.new(1,1) }, Rotation = 0 }, contentGlow)
contentGlow.ZIndex = 0

local function clearContent()
    for _,c in ipairs(contentFrame:GetChildren()) do
        if not c:IsA("UIListLayout") and c ~= contentGlow then c:Destroy() end
    end
end

-- Clock
local clock = create("TextLabel", { Size=UDim2.new(0,200,0,28), Position=UDim2.new(0,16,1,-34), Text = "🕒 --:--:--", TextColor3 = C("subtext"), BackgroundTransparency=1, Font = Enum.Font.GothamBold, TextScaled = true }, mainFrame)
task.spawn(function()
    while clock.Parent do
        clock.Text = "🕒 " .. os.date("%H:%M:%S")
        task.wait(1)
    end
end)

-- Tabs (dynamisch nach Permissions)
local allTabs = {
    {name="Main", key=nil},
    {name="Local", key="CanFly"},
    {name="Teleport", key="CanTeleport"},
    {name="ESP", key="CanESP"},
    {name="Utility", key="CanUtility"},
    {name="CurrencyCheck", key="CanInspectCurrency"},
    {name="Diamonds Debug", key="CanDebugDiamonds"},
    {name="Help", key=nil},
}
local tabs = {}
for _,t in ipairs(allTabs) do
    if not t.key or Allowed(t.key) then
        table.insert(tabs, t.name)
    end
end

local tabButtons = {}
local function makeTabButton(name, index)
    local btn = create("TextButton", {
        Size = UDim2.new(1,0,0,44),
        Position = UDim2.new(0,0,0,(index-1)*48),
        Text = name,
        TextColor3 = C("text"),
        BackgroundColor3 = Color3.fromRGB(210,200,255),
        BackgroundTransparency = 0.2,
        Font = Enum.Font.GothamBold,
        TextScaled = true,
        AutoButtonColor = false,
        Parent = sidebar
    })
    create("UICorner",{CornerRadius=UDim.new(0,10)}, btn)
    create("UIStroke",{Thickness=1, Color=C("accent"), Transparency=0.5}, btn)
    btn.MouseEnter:Connect(function() TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundTransparency=0}):Play() end)
    btn.MouseLeave:Connect(function() TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundTransparency=0.2}):Play() end)
    tabButtons[name] = btn
    return btn
end

for i,tabName in ipairs(tabs) do
    makeTabButton(tabName, i)
end

-- THEME switch
local function applyTheme()
    mainFrame.BackgroundColor3 = C("bg")
    mainStroke.Color = C("stroke")
    header.BackgroundColor3 = C("card")
    sidebar.BackgroundColor3 = currentTheme=="lilacDark" and Color3.fromRGB(36,30,60) or C("side")
    profileFrame.BackgroundColor3 = C("card")
    contentFrame.BackgroundColor3 = C("card")
    title.TextColor3 = C("text")
    nameLabel.TextColor3 = C("subtext")
    fpsLabel.TextColor3 = C("success")
    clock.TextColor3 = C("subtext")
    for _,btn in pairs(tabButtons) do if btn and btn:IsA("TextButton") then btn.TextColor3 = C("text") end end
end
themeBtn.MouseButton1Click:Connect(function()
    currentTheme = (currentTheme == "lilac") and "lilacDark" or "lilac"
    applyTheme()
    themeIcon:Destroy()
    themeIcon = (currentTheme=="lilacDark") and makeIcon_Moon(themeBtn) or makeIcon_Sun(themeBtn)
end)
applyTheme()

----------------------------------------------------------------
-- STATUS HUD
----------------------------------------------------------------
local statusFrame = create("Frame", { Size = UDim2.new(0,300,0,44), Position = UDim2.new(1,-320,1,-60), BackgroundColor3 = Color3.fromRGB(230,225,255), BackgroundTransparency = 0.15, Parent = screenGui })
create("UICorner",{CornerRadius=UDim.new(0,12)}, statusFrame)
local statusText = create("TextLabel", { Size = UDim2.new(1,0,1,0), Text = "✅ Voidware Luminous geladen – bereit", Font = Enum.Font.GothamBold, TextScaled = true, TextColor3 = Color3.fromRGB(90,80,150), BackgroundTransparency = 1, Parent = statusFrame })
statusFrame.BackgroundTransparency = 1; statusText.TextTransparency = 1
TweenService:Create(statusFrame, TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 0.15}):Play()
TweenService:Create(statusText, TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextTransparency = 0}):Play()
task.delay(7, function()
    if statusFrame.Parent then
        TweenService:Create(statusFrame, TweenInfo.new(1.0), {BackgroundTransparency=1}):Play()
        TweenService:Create(statusText, TweenInfo.new(1.0), {TextTransparency=1}):Play()
        task.wait(1.05)
        if statusFrame then statusFrame:Destroy() end
    end
end)

----------------------------------------------------------------
-- UI Helpers
----------------------------------------------------------------
local function sectionTitle(text, parent, y)
    return create("TextLabel", { Size = UDim2.new(1,-24,0,42), Position = UDim2.new(0,12,0,y or 12), Text = text, Font = Enum.Font.GothamBold, TextScaled = true, TextColor3 = C("text"), BackgroundTransparency = 1, Parent = parent })
end
local function label(text, parent, pos, size, color)
    return create("TextLabel", { Size = size or UDim2.new(0,220,0,28), Position = pos or UDim2.new(0,12,0,64), Text = text, Font = Enum.Font.Gotham, TextScaled = true, TextColor3 = color or C("subtext"), BackgroundTransparency = 1, Parent = parent })
end
local function button(text, parent, pos, size, bg, cb)
    local b = create("TextButton", { Size = size or UDim2.new(0,140,0,36), Position = pos or UDim2.new(0,12,0,64), Text = text, Font = Enum.Font.GothamBold, TextScaled = true, BackgroundColor3 = bg or C("accent"), TextColor3 = Color3.fromRGB(255,255,255), AutoButtonColor=false, Parent=parent })
    create("UICorner",{CornerRadius=UDim.new(0,10)}, b)
    create("UIStroke",{Thickness=1, Color=Color3.fromRGB(255,255,255), Transparency=0.7}, b)
    if cb then b.MouseButton1Click:Connect(function() cb(b) end) end
    b.MouseEnter:Connect(function() TweenService:Create(b,TweenInfo.new(0.15),{BackgroundTransparency=0.05}):Play() end)
    b.MouseLeave:Connect(function() TweenService:Create(b,TweenInfo.new(0.15),{BackgroundTransparency=0}):Play() end)
    return b
end

local function slider(titleText, min, max, getVal, setVal, parent, y)
    label(titleText, parent, UDim2.new(0,12,0,(y or 0)), UDim2.new(0,240,0,26), C("text"))
    local container = create("Frame", { Size = UDim2.new(0, 320, 0, 10), Position = UDim2.new(0,12,0,(y or 0)+28), BackgroundColor3 = Color3.fromRGB(220,215,255), Parent = parent })
    create("UICorner",{CornerRadius=UDim.new(0,5)}, container)
    local fill = create("Frame", { Size = UDim2.new((getVal()-min)/(max-min),0,1,0), BackgroundColor3 = C("accent"), Parent = container })
    create("UICorner",{CornerRadius=UDim.new(0,5)}, fill)
    local valueLbl = label(tostring(getVal()), parent, UDim2.new(0,340,0,(y or 0)+16), UDim2.new(0,80,0,24), C("subtext"))
    local dragging = false
    container.InputBegan:Connect(function(io) if io.UserInputType == Enum.UserInputType.MouseButton1 then dragging=true end end)
    container.InputEnded:Connect(function(io) if io.UserInputType == Enum.UserInputType.MouseButton1 then dragging=false end end)
    UserInputService.InputChanged:Connect(function(io)
        if dragging and io.UserInputType==Enum.UserInputType.MouseMovement then
            local rel = math.clamp((io.Position.X - container.AbsolutePosition.X)/container.AbsoluteSize.X, 0, 1)
            local value = math.floor(min + rel*(max-min))
            fill.Size = UDim2.new(rel,0,1,0)
            pcall(function() setVal(value) end)
            valueLbl.Text = tostring(value)
        end
    end)
end

----------------------------------------------------------------
-- FLY SYSTEM
----------------------------------------------------------------
local flying, flySpeed = false, 90
local bodyGyro, bodyVel
local flyConn

local function setFly(active)
    local char = safeChar(player)
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    flying = active
    if active then
        bodyGyro = create("BodyGyro", {MaxTorque=Vector3.new(1e9,1e9,1e9), P=1e5, CFrame=hrp.CFrame}, hrp)
        bodyVel = create("BodyVelocity", {MaxForce=Vector3.new(1e9,1e9,1e9), Velocity=Vector3.zero}, hrp)
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
            bodyVel.Velocity = (move.Magnitude>0) and (move.Unit * flySpeed) or Vector3.zero
        end)
        notify("Fly aktiviert")
    else
        if flyConn then flyConn:Disconnect() end
        if bodyGyro then bodyGyro:Destroy() end
        if bodyVel then bodyVel:Destroy() end
        notify("Fly deaktiviert")
    end
end

local function tryToggleFly()
    if not Allowed("CanFly") then
        notify("Fly ist noch gesperrt (Berechtigung fehlt).")
        return
    end
    setFly(not flying)
end

UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.F then
        tryToggleFly()
    end
end)

----------------------------------------------------------------
-- TABS: Main
----------------------------------------------------------------
local function showMain()
    clearContent()
    sectionTitle("✨ Willkommen zu Voidware Luminous", contentFrame, 16)
    label("RightShift: GUI an/aus • F: Fly (falls freigeschaltet) • Sonne/Mond: Theme", contentFrame, UDim2.new(0,12,0,62))
    label("Tabs links: Local, Teleport, ESP, Utility, Currency, Diamonds, Help", contentFrame, UDim2.new(0,12,0,92))
end

if tabButtons["Main"] then
    tabButtons["Main"].MouseButton1Click:Connect(function()
        showMain()
    end)
end

----------------------------------------------------------------
-- Local (Fly + Speed)
----------------------------------------------------------------
if tabButtons["Local"] then
    tabButtons["Local"].MouseButton1Click:Connect(function()
        clearContent()
        sectionTitle("🕊️ Fly System", contentFrame, 16)
        label("F: Ein/Aus • Space/Shift: Hoch/Runter", contentFrame, UDim2.new(0,12,0,60))
        slider("Speed", 10, 300,
            function() return flySpeed end,
            function(v)
                if not Allowed("CanFly") then notify("Keine Berechtigung zum Ändern der Fly-Geschwindigkeit.") return end
                flySpeed = v
            end,
            contentFrame, 96
        )
        button((flying and "Fly AUS") or "Fly AN", contentFrame, UDim2.new(0,12,0,146), UDim2.new(0,140,0,36), C("accent"), function(b)
            if not Allowed("CanFly") then notify("Fly ist gesperrt.") return end
            setFly(not flying)
            b.Text = (flying and "Fly AUS") or "Fly AN"
        end)
    end)
end

----------------------------------------------------------------
-- Teleport
----------------------------------------------------------------
local function listPlayers(scroll)
    for _,c in ipairs(scroll:GetChildren()) do if c:IsA("Frame") then c:Destroy() end end
    local y=0
    for _,plr in ipairs(Players:GetPlayers()) do
        local row = create("Frame",{Size=UDim2.new(1,-10,0,36), Position=UDim2.new(0,5,0,y), BackgroundColor3=Color3.fromRGB(226,220,255), Parent=scroll})
        create("UICorner",{CornerRadius=UDim.new(0,8)}, row)
        label(plr.Name, row, UDim2.new(0,10,0,3), UDim2.new(0,240,0,30), C("text"))
        button("Teleport", row, UDim2.new(1,-120,0,3), UDim2.new(0,110,0,30), C("accent"), function()
            if not Allowed("CanTeleport") then notify("Teleport ist gesperrt.") return end
            local myChar, tChar = safeChar(player), safeChar(plr)
            local myHRP, tHRP = myChar:FindFirstChild("HumanoidRootPart"), tChar and tChar:FindFirstChild("HumanoidRootPart")
            if myHRP and tHRP then
                myHRP.CFrame = tHRP.CFrame + tHRP.CFrame.LookVector * 2
                notify("Teleported zu "..plr.Name)
            end
        end)
        y = y + 40
        scroll.CanvasSize = UDim2.new(0,0,0,y+8)
    end
end

if tabButtons["Teleport"] then
    tabButtons["Teleport"].MouseButton1Click:Connect(function()
        clearContent()
        sectionTitle("🧍 Teleport", contentFrame, 16)
        if not Allowed("CanTeleport") then
            label("Teleport ist aktuell gesperrt. Bitte warte auf Freischaltung.", contentFrame, UDim2.new(0,12,0,60))
            return
        end
        local scroll = create("ScrollingFrame", { Size = UDim2.new(1,-24,1,-84), Position = UDim2.new(0,12,0,58), CanvasSize = UDim2.new(0,0,0,0), ScrollBarThickness=6, BackgroundTransparency=1, Parent=contentFrame })
        button("Refresh", contentFrame, UDim2.new(1,-132,0,16), UDim2.new(0,120,0,32), C("warn"), function() listPlayers(scroll) end)
        listPlayers(scroll)
    end)
end

----------------------------------------------------------------
-- ESP
----------------------------------------------------------------
local espEnabled = false
local espMap = {}

local function setESPForPlayer(plr, on)
    if on then
        if espMap[plr] and espMap[plr].Parent then return end
        local char = safeChar(plr)
        local hl = create("Highlight", { FillColor = Theme.lilacDark.accent, OutlineColor = Color3.fromRGB(255,255,255), FillTransparency = 0.7, OutlineTransparency = 0.15, Parent = char })
        espMap[plr] = hl
    else
        if espMap[plr] then espMap[plr]:Destroy(); espMap[plr] = nil end
    end
end

local function setESP(on)
    espEnabled = on
    for _,plr in ipairs(Players:GetPlayers()) do if plr ~= player then setESPForPlayer(plr, on) end end
end

Players.PlayerAdded:Connect(function(plr)
    if espEnabled and plr~=player then task.delay(1,function() setESPForPlayer(plr,true) end) end
end)
Players.PlayerRemoving:Connect(function(plr)
    if espMap[plr] then espMap[plr]:Destroy(); espMap[plr]=nil end
end)

if tabButtons["ESP"] then
    tabButtons["ESP"].MouseButton1Click:Connect(function()
        clearContent()
        sectionTitle("🎯 ESP", contentFrame, 16)
        if not Allowed("CanESP") then
            label("ESP ist aktuell gesperrt. Bitte warte auf Freischaltung.", contentFrame, UDim2.new(0,12,0,60))
            return
        end
        button(espEnabled and "Master: ON" or "Master: OFF", contentFrame, UDim2.new(0,12,0,60), UDim2.new(0,170,0,36), C("accent"), function(b)
            setESP(not espEnabled)
            b.Text = espEnabled and "Master: ON" or "Master: OFF"
        end)
        local scroll = create("ScrollingFrame", { Size = UDim2.new(1,-24,1,-112), Position = UDim2.new(0,12,0,100), CanvasSize = UDim2.new(0,0,0,0), ScrollBarThickness=6, BackgroundTransparency=1, Parent=contentFrame })
        local y=0
        for _,plr in ipairs(Players:GetPlayers()) do
            if plr ~= player then
                local row = create("Frame",{Size=UDim2.new(1,-10,0,36), Position=UDim2.new(0,5,0,y), BackgroundColor3=Color3.fromRGB(226,220,255), Parent=scroll})
                create("UICorner",{CornerRadius=UDim.new(0,8)}, row)
                label(plr.Name, row, UDim2.new(0,10,0,3), UDim2.new(0,240,0,30), C("text"))
                button(espMap[plr] and "ON" or "OFF", row, UDim2.new(1,-120,0,3), UDim2.new(0,110,0,30), C("accent"), function(btnSelf)
                    local turnOn = not espMap[plr]
                    setESPForPlayer(plr, turnOn)
                    btnSelf.Text = turnOn and "ON" or "OFF"
                end)
                y = y + 40
            end
        end
        scroll.CanvasSize = UDim2.new(0,0,0,y+8)
    end)
end

----------------------------------------------------------------
-- Utility (WS/JP/Noclip/Freecam)
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

local freecam = false
local camConn, rotX, rotY, camPos
local function setFreecam(on)
    freecam = on
    local cam = workspace.CurrentCamera
    if on then
        cam.CameraType = Enum.CameraType.Scriptable
        camPos = cam.CFrame.Position; rotX, rotY = 0,0
        local moveSpeed = 1.6
        camConn = RunService.RenderStepped:Connect(function(dt)
            local delta = UserInputService:GetMouseDelta()
            rotX = math.clamp(rotX - delta.Y*0.002, -1.55, 1.55)
            rotY = rotY - delta.X*0.002
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

if tabButtons["Utility"] then
    tabButtons["Utility"].MouseButton1Click:Connect(function()
        clearContent()
        sectionTitle("⚡ Utility", contentFrame, 16)
        if not Allowed("CanUtility") then
            label("Utility-Tools sind derzeit gesperrt. Warte auf Freischaltung.", contentFrame, UDim2.new(0,12,0,60))
            return
        end
        local hum = safeChar(player):WaitForChild("Humanoid")
        local ws0, jp0 = hum.WalkSpeed, hum.JumpPower
        slider("WalkSpeed", 8, 200, function() return hum.WalkSpeed end, function(v) if not Allowed("CanUtility") then notify("Keine Berechtigung.") return end; hum.WalkSpeed = v end, contentFrame, 62)
        slider("JumpPower", 10, 200, function() return hum.JumpPower end, function(v) if not Allowed("CanUtility") then notify("Keine Berechtigung.") return end; hum.JumpPower = v end, contentFrame, 122)
        button(noclip and "Noclip AUS" or "Noclip AN", contentFrame, UDim2.new(0,12,0,176), UDim2.new(0,160,0,36), C("warn"), function(b) setNoclip(not noclip); b.Text = noclip and "Noclip AUS" or "Noclip AN" end)
        button(freecam and "Freecam AUS" or "Freecam AN", contentFrame, UDim2.new(0,192,0,176), UDim2.new(0,170,0,36), C("accent"), function(b) setFreecam(not freecam); b.Text = freecam and "Freecam AUS" or "Freecam AN" end)
        button("Reset WS/JP", contentFrame, UDim2.new(0,372,0,176), UDim2.new(0,160,0,36), C("danger"), function() hum.WalkSpeed, hum.JumpPower = ws0, jp0 notify("WalkSpeed/JumpPower zurückgesetzt") end)
    end)
end

----------------------------------------------------------------
-- CurrencyCheck
----------------------------------------------------------------
local function searchForCurrency()
    local results, keys = {}, {"coin","coins","gold","money","cash","gems","gem","diamond","diamonds"}
    local function scan(obj)
        for _,child in ipairs(obj:GetChildren()) do
            local n = child.Name:lower()
            for _,k in ipairs(keys) do
                if n:find(k) then table.insert(results, child); break end
            end
            scan(child)
        end
    end
    scan(game)
    return results
end

if tabButtons["CurrencyCheck"] then
    tabButtons["CurrencyCheck"].MouseButton1Click:Connect(function()
        clearContent()
        sectionTitle("💰 Currency-Objekte", contentFrame, 16)
        if not Allowed("CanInspectCurrency") then
            label("Currency-Inspection gesperrt. Bitte warte auf Freischaltung.", contentFrame, UDim2.new(0,12,0,60))
            return
        end
        local scroll = create("ScrollingFrame", { Size=UDim2.new(1,-24,1,-84), Position=UDim2.new(0,12,0,58), BackgroundTransparency=1, ScrollBarThickness=6, CanvasSize=UDim2.new(0,0,0,0), Parent=contentFrame })
        local results = searchForCurrency()
        local y=0
        if #results == 0 then
            label("❌ Keine Currency Objekte gefunden.", scroll, UDim2.new(0,10,0,0), UDim2.new(1,-20,0,30), Theme.lilacDark.danger)
        else
            for _,o in ipairs(results) do
                label(o:GetFullName().." ["..o.ClassName.."]", scroll, UDim2.new(0,10,0,y), UDim2.new(1,-20,0,24), Color3.fromRGB(90,120,90))
                y = y + 26
            end
            scroll.CanvasSize = UDim2.new(0,0,0,y+10)
        end
        button("Alles kopieren", contentFrame, UDim2.new(1,-162,0,16), UDim2.new(0,150,0,32), C("accent"), function()
            local t = {}
            for _,o in ipairs(results) do table.insert(t, o:GetFullName().." ["..o.ClassName.."]") end
            local out = table.concat(t, "\n")
            if setclipboard then setclipboard(out); notify("In Zwischenablage kopiert.") else warn("setclipboard nicht verfügbar") end
        end)
    end)
end

----------------------------------------------------------------
-- Diamonds Debug
----------------------------------------------------------------
local function searchDiamondRemotes()
    local res = {}
    for _,o in ipairs(ReplicatedStorage:GetDescendants()) do
        local n = o.Name:lower()
        if (n:find("diamond") or n:find("gem")) and (o:IsA("RemoteEvent") or o:IsA("RemoteFunction")) then
            table.insert(res, o)
        end
    end
    return res
end

if tabButtons["Diamonds Debug"] then
    tabButtons["Diamonds Debug"].MouseButton1Click:Connect(function()
        clearContent()
        sectionTitle("💎 Diamond Remotes", contentFrame, 16)
        if not Allowed("CanDebugDiamonds") then
            label("Diamond-Debugging gesperrt. Bitte warte auf Freischaltung.", contentFrame, UDim2.new(0,12,0,60))
            return
        end
        local scroll = create("ScrollingFrame", { Size=UDim2.new(1,-24,1,-84), Position=UDim2.new(0,12,0,58), BackgroundTransparency=1, ScrollBarThickness=6, CanvasSize=UDim2.new(0,0,0,0), Parent=contentFrame })
        local remotes = searchDiamondRemotes()
        local y=0
        if #remotes == 0 then
            label("❌ Keine Diamond Remotes gefunden.", scroll, UDim2.new(0,10,0,0), UDim2.new(1,-20,0,30), Theme.lilacDark.danger)
        else
            for _,r in ipairs(remotes) do
                local row = create("Frame",{Size=UDim2.new(1,-10,0,36), Position=UDim2.new(0,5,0,y), BackgroundColor3=Color3.fromRGB(226,220,255), Parent=scroll})
                create("UICorner",{CornerRadius=UDim.new(0,8)}, row)
                label(r:GetFullName(), row, UDim2.new(0,10,0,3), UDim2.new(0,360,0,30), C("text"))
                local input = create("TextBox", { Size=UDim2.new(0,70,0,28), Position=UDim2.new(0,380,0,4), PlaceholderText="10", Text="", TextSize=14, Font=Enum.Font.Gotham, BackgroundColor3=Color3.fromRGB(210,205,250), TextColor3=Color3.fromRGB(50,40,90), Parent=row })
                create("UICorner",{CornerRadius=UDim.new(0,6)}, input)
                button("Fire", row, UDim2.new(1,-90,0,4), UDim2.new(0,80,0,28), C("accent"), function()
                    local amount = tonumber(input.Text) or 10
                    if r:IsA("RemoteEvent") then r:FireServer(amount); print("🔥", r:GetFullName(), amount)
                    elseif r:IsA("RemoteFunction") then local res = r:InvokeServer(amount); print("📡", r:GetFullName(), amount, "->", res) end
                end)
                y = y + 40
            end
            scroll.CanvasSize = UDim2.new(0,0,0,y+8)
        end
    end)
end

----------------------------------------------------------------
-- Help
----------------------------------------------------------------
if tabButtons["Help"] then
    tabButtons["Help"].MouseButton1Click:Connect(function()
        clearContent()
        sectionTitle("❓ Hilfe & Shortcuts", contentFrame, 16)
        label("RightShift: GUI ein/aus", contentFrame, UDim2.new(0,12,0,60))
        label("F: Fly (nur wenn freigeschaltet) • Space/Shift: Hoch/Runter", contentFrame, UDim2.new(0,12,0,90))
        label("Theme: Button oben rechts (Sonne/Mond)", contentFrame, UDim2.new(0,12,0,120))
        label("Tabs links erscheinen automatisch, sobald Features freigeschaltet wurden.", contentFrame, UDim2.new(0,12,0,150))
    end)
end

-- Start: sicher Main anzeigen (ohne :Fire auf Events)
if tabButtons["Main"] then
    showMain()
end

print("✅ Voidware Luminous UI geladen (DefaultPermissions aktiv; Attribute=true überschreibt).")

-- OPTIONAL (nur für lokale Tests – auskommentieren entfernen, wenn gewünscht):
--[[
for _,k in ipairs({"CanFly","CanTeleport","CanESP","CanUtility","CanInspectCurrency","CanDebugDiamonds"}) do
    player:SetAttribute(k, true)
end
]]
