-- Voidware Luminous • Client-Only Demo (legal in Studio)
-- Legaler Test: LocalScript unter StarterPlayerScripts, Play (F5).

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RS = game:GetService("RunService")
local Lighting = game:GetService("Lighting")

local player = Players.LocalPlayer
local pg = player:WaitForChild("PlayerGui")

-- Aufräumen & GUI anlegen
local old = pg:FindFirstChild("VoidwareDemo")
if old then old:Destroy() end

local gui = Instance.new("ScreenGui")
gui.Name = "VoidwareDemo"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.ZIndexBehavior = Enum.ZIndexBehavior.Global
gui.DisplayOrder = 100
gui.Enabled = true
gui.Parent = pg

-- Fenster
local win = Instance.new("Frame")
win.Size = UDim2.fromOffset(920,560)
win.Position = UDim2.new(0.5,-460,0.5,-280)
win.BackgroundColor3 = Color3.fromRGB(46,38,85)
win.BackgroundTransparency = 0.06
win.Parent = gui
local corner = Instance.new("UICorner"); corner.CornerRadius = UDim.new(0,18); corner.Parent = win

local header = Instance.new("Frame")
header.Size = UDim2.new(1,0,0,60)
header.BackgroundColor3 = Color3.fromRGB(58,48,105)
header.Parent = win
local hcorner = Instance.new("UICorner"); hcorner.CornerRadius = UDim.new(0,16); hcorner.Parent = header

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1,-20,1,0)
title.Position = UDim2.new(0,10,0,0)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.TextScaled = true
title.TextColor3 = Color3.fromRGB(235,230,255)
title.Text = "Voidware • Client-Only Demo"
title.Parent = header

-- Dragging
local dragging, start, startPos = false
header.InputBegan:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.MouseButton1 then
        dragging=true; start=i.Position; startPos=win.Position
    end
end)
UIS.InputChanged:Connect(function(i)
    if dragging and i.UserInputType==Enum.UserInputType.MouseMovement then
        local d = i.Position - start
        win.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset+d.X, startPos.Y.Scale, startPos.Y.Offset+d.Y)
    end
end)
header.InputEnded:Connect(function(i) if i.UserInputState==Enum.UserInputState.End then dragging=false end end)

-- Inhalt
local content = Instance.new("Frame")
content.Size = UDim2.new(1,-20,1,-70)
content.Position = UDim2.new(0,10,0,66)
content.BackgroundColor3 = Color3.fromRGB(58,48,105)
content.Parent = win
local ccorner = Instance.new("UICorner"); ccorner.CornerRadius = UDim.new(0,12); ccorner.Parent = content

local function mkBtn(txt, x, y, w, cb)
    local b = Instance.new("TextButton")
    b.Size = UDim2.fromOffset(w or 160,36)
    b.Position = UDim2.new(0,x,0,y)
    b.Text = txt
    b.Font = Enum.Font.GothamBold
    b.TextScaled = true
    b.TextColor3 = Color3.new(1,1,1)
    b.BackgroundColor3 = Color3.fromRGB(155,120,255)
    b.Parent = content
    local r = Instance.new("UICorner"); r.CornerRadius = UDim.new(0,10); r.Parent = b
    b.MouseButton1Click:Connect(function() if cb then cb(b) end end)
    return b
end

local function mkLabel(txt, x, y)
    local l = Instance.new("TextLabel")
    l.Size = UDim2.fromOffset(360,26)
    l.Position = UDim2.new(0,x,0,y)
    l.BackgroundTransparency = 1
    l.Font = Enum.Font.Gotham
    l.TextScaled = true
    l.TextColor3 = Color3.fromRGB(200,195,235)
    l.Text = txt
    l.Parent = content
    return l
end

-- Fly
local flying, flySpeed = false, 90
local gyro, vel, flyConn
local function setFly(on)
    local char = player.Character or player.CharacterAdded:Wait()
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    flying = on
    if on then
        gyro = Instance.new("BodyGyro")
        gyro.MaxTorque = Vector3.new(1e9,1e9,1e9)
        gyro.P = 1e5
        gyro.CFrame = hrp.CFrame
        gyro.Parent = hrp
        vel = Instance.new("BodyVelocity")
        vel.MaxForce = Vector3.new(1e9,1e9,1e9)
        vel.Velocity = Vector3.zero
        vel.Parent = hrp
        flyConn = RS.RenderStepped:Connect(function()
            local cam = workspace.CurrentCamera
            local m = Vector3.zero
            if UIS:IsKeyDown(Enum.KeyCode.W) then m += cam.CFrame.LookVector end
            if UIS:IsKeyDown(Enum.KeyCode.S) then m -= cam.CFrame.LookVector end
            if UIS:IsKeyDown(Enum.KeyCode.A) then m -= cam.CFrame.RightVector end
            if UIS:IsKeyDown(Enum.KeyCode.D) then m += cam.CFrame.RightVector end
            if UIS:IsKeyDown(Enum.KeyCode.Space) then m += Vector3.new(0,1,0) end
            if UIS:IsKeyDown(Enum.KeyCode.LeftShift) then m -= Vector3.new(0,1,0) end
            gyro.CFrame = cam.CFrame
            vel.Velocity = (m.Magnitude>0) and (m.Unit * flySpeed) or Vector3.zero
        end)
    else
        if flyConn then flyConn:Disconnect() end
        if gyro then gyro:Destroy() end
        if vel then vel:Destroy() end
    end
end

UIS.InputBegan:Connect(function(i,gpe)
    if not gpe and i.KeyCode==Enum.KeyCode.F then setFly(not flying) end
end)

-- Humanoid Werte
local function hum() return (player.Character or player.CharacterAdded:Wait()):WaitForChild("Humanoid") end

mkLabel("Fly: Taste F • Space/Shift = hoch/runter", 12, 8)
local flyBtn = mkBtn("Fly AN", 12, 40, 140, function(b)
    setFly(not flying); b.Text = flying and "Fly AUS" or "Fly AN"
end)

-- einfache Slider (per +/- Buttons)
local wsStep, jpStep, spdStep = 4, 5, 10
local wsL = mkLabel("WalkSpeed: 16", 12, 90)
mkBtn("- WS", 12, 120, 80, function()
    local H = hum(); H.WalkSpeed = math.max(8, H.WalkSpeed - wsStep); wsL.Text = "WalkSpeed: "..H.WalkSpeed
end)
mkBtn("+ WS", 100, 120, 80, function()
    local H = hum(); H.WalkSpeed = math.min(200, H.WalkSpeed + wsStep); wsL.Text = "WalkSpeed: "..H.WalkSpeed
end)

local jpL = mkLabel("JumpPower: 50", 200, 90)
mkBtn("- JP", 200, 120, 80, function()
    local H = hum(); H.JumpPower = math.max(10, H.JumpPower - jpStep); jpL.Text = "JumpPower: "..H.JumpPower
end)
mkBtn("+ JP", 288, 120, 80, function()
    local H = hum(); H.JumpPower = math.min(200, H.JumpPower + jpStep); jpL.Text = "JumpPower: "..H.JumpPower
end)

local spdL = mkLabel("Fly Speed: 90", 12, 164)
mkBtn("- Speed", 12, 194, 100, function()
    flySpeed = math.max(10, flySpeed - spdStep); spdL.Text = "Fly Speed: "..flySpeed
end)
mkBtn("+ Speed", 116, 194, 100, function()
    flySpeed = math.min(300, flySpeed + spdStep); spdL.Text = "Fly Speed: "..flySpeed
end)

-- Noclip / Freecam / Reset
local noclip, ncConn = false, nil
local function setNoclip(on)
    noclip = on
    if on then
        if ncConn then ncConn:Disconnect() end
        ncConn = RS.Stepped:Connect(function()
            local c = player.Character
            if c then
                for _,p in ipairs(c:GetDescendants()) do
                    if p:IsA("BasePart") then p.CanCollide = false end
                end
            end
        end)
    else
        if ncConn then ncConn:Disconnect() end
    end
end

mkBtn("Noclip AN", 12, 246, 140, function(b)
    setNoclip(not noclip); b.Text = noclip and "Noclip AUS" or "Noclip AN"
end)

local freecam, camConn, rotX, rotY, camPos = false
local function setFreecam(on)
    freecam = on
    local cam = workspace.CurrentCamera
    if on then
        cam.CameraType = Enum.CameraType.Scriptable
        camPos = cam.CFrame.Position; rotX, rotY = 0, 0
        local move = 1.6
        camConn = RS.RenderStepped:Connect(function(dt)
            local d = UIS:GetMouseDelta()
            rotX = math.clamp(rotX - d.Y*0.002, -1.55, 1.55)
            rotY = rotY - d.X*0.002
            local cf = CFrame.new(camPos) * CFrame.Angles(0, rotY, 0) * CFrame.Angles(rotX, 0, 0)
            local mv = Vector3.zero
            if UIS:IsKeyDown(Enum.KeyCode.W) then mv += cf.LookVector end
            if UIS:IsKeyDown(Enum.KeyCode.S) then mv -= cf.LookVector end
            if UIS:IsKeyDown(Enum.KeyCode.A) then mv -= cf.RightVector end
            if UIS:IsKeyDown(Enum.KeyCode.D) then mv += cf.RightVector end
            if UIS:IsKeyDown(Enum.KeyCode.Space) then mv += Vector3.new(0,1,0) end
            if UIS:IsKeyDown(Enum.KeyCode.LeftShift) then mv -= Vector3.new(0,1,0) end
            camPos += mv * (60*dt) * move
            cam.CFrame = CFrame.new(camPos) * CFrame.Angles(0, rotY, 0) * CFrame.Angles(rotX, 0, 0)
        end)
    else
        if camConn then camConn:Disconnect() end
        workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
    end
end

mkBtn("Freecam AN", 172, 246, 160, function(b)
    setFreecam(not freecam); b.Text = freecam and "Freecam AUS" or "Freecam AN"
end)

mkBtn("Reset WS/JP", 344, 246, 160, function()
    local H = hum(); H.WalkSpeed, H.JumpPower = 16, 50
end)

-- RightShift: GUI ein/aus
UIS.InputBegan:Connect(function(i,gpe)
    if not gpe and i.KeyCode==Enum.KeyCode.RightShift then
        gui.Enabled = not gui.Enabled
    end
end)

print("✅ Voidware • Client-Only Demo geladen.")
