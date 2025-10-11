-- Roblox GUI ähnlich Discord Style (Voidware Style) + Fly-System v3 + Statusanzeige
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer

-------------------------------------------------------------
-- 🧱 GUI SETUP
-------------------------------------------------------------
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ModernDashboard"
screenGui.ResetOnSpawn = false
screenGui.Parent = game:GetService("CoreGui")

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 750, 0, 500)
mainFrame.Position = UDim2.new(0.5, -375, 0.5, -250)
mainFrame.BackgroundColor3 = Color3.fromRGB(45, 40, 90)
mainFrame.Parent = screenGui
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 12)

-- Toggle GUI mit RightShift
UserInputService.InputBegan:Connect(function(input, processed)
	if not processed and input.KeyCode == Enum.KeyCode.RightShift then
		mainFrame.Visible = not mainFrame.Visible
	end
end)

-------------------------------------------------------------
-- 🧾 HEADER
-------------------------------------------------------------
local header = Instance.new("Frame")
header.Size = UDim2.new(1,0,0,45)
header.BackgroundColor3 = Color3.fromRGB(35,30,70)
header.Parent = mainFrame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1,-100,1,0)
title.Position = UDim2.new(0,15,0,0)
title.Text = "Voidware Dashboard"
title.TextColor3 = Color3.fromRGB(255,255,255)
title.Font = Enum.Font.GothamBold
title.TextScaled = true
title.TextXAlignment = Enum.TextXAlignment.Left
title.BackgroundTransparency = 1
title.Parent = header

local closeButton = Instance.new("TextButton")
closeButton.Size = UDim2.new(0,40,0,40)
closeButton.Position = UDim2.new(1,-45,0.5,-20)
closeButton.Text = "✕"
closeButton.TextColor3 = Color3.fromRGB(255,255,255)
closeButton.Font = Enum.Font.GothamBold
closeButton.TextScaled = true
closeButton.BackgroundTransparency = 1
closeButton.Parent = header
closeButton.MouseButton1Click:Connect(function() screenGui:Destroy() end)

-------------------------------------------------------------
-- 📂 SIDEBAR
-------------------------------------------------------------
local sidebar = Instance.new("Frame")
sidebar.Size = UDim2.new(0,180,1,-45)
sidebar.Position = UDim2.new(0,0,0,45)
sidebar.BackgroundColor3 = Color3.fromRGB(40,35,80)
sidebar.Parent = mainFrame

-- Profil unten
local profileFrame = Instance.new("Frame")
profileFrame.Size = UDim2.new(1,0,0,70)
profileFrame.Position = UDim2.new(0,0,1,-70)
profileFrame.BackgroundColor3 = Color3.fromRGB(35,30,70)
profileFrame.Parent = sidebar
Instance.new("UICorner", profileFrame).CornerRadius = UDim.new(0,10)

local thumb, _ = Players:GetUserThumbnailAsync(player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
local avatar = Instance.new("ImageLabel")
avatar.Size = UDim2.new(0,45,0,45)
avatar.Position = UDim2.new(0,10,0.5,-22)
avatar.Image = thumb
avatar.BackgroundTransparency = 1
avatar.Parent = profileFrame

local nameLabel = Instance.new("TextLabel")
nameLabel.Size = UDim2.new(1,-65,1,0)
nameLabel.Position = UDim2.new(0,60,0,0)
nameLabel.Text = player.Name .. "\n@" .. player.UserId
nameLabel.TextColor3 = Color3.fromRGB(200,200,255)
nameLabel.Font = Enum.Font.Gotham
nameLabel.TextScaled = true
nameLabel.TextXAlignment = Enum.TextXAlignment.Left
nameLabel.BackgroundTransparency = 1
nameLabel.Parent = profileFrame

-------------------------------------------------------------
-- 🪟 CONTENT
-------------------------------------------------------------
local contentFrame = Instance.new("Frame")
contentFrame.Size = UDim2.new(1,-180,1,-45)
contentFrame.Position = UDim2.new(0,180,0,45)
contentFrame.BackgroundColor3 = Color3.fromRGB(55,50,100)
contentFrame.Parent = mainFrame

local function clearContent()
	for _, child in ipairs(contentFrame:GetChildren()) do
		if not child:IsA("UIListLayout") then child:Destroy() end
	end
end

-------------------------------------------------------------
-- 💠 TABS
-------------------------------------------------------------
local tabs = {"Main","Help","Teleport","Bring Stuff","Local","ChestFarm","CurrencyCheck","Diamonds Debug"}
for i, tabName in ipairs(tabs) do
	local tabButton = Instance.new("TextButton")
	tabButton.Size = UDim2.new(1,0,0,40)
	tabButton.Position = UDim2.new(0,0,0,(i-1)*45)
	tabButton.Text = tabName
	tabButton.TextColor3 = Color3.fromRGB(255,255,255)
	tabButton.BackgroundColor3 = Color3.fromRGB(60,55,110)
	tabButton.Font = Enum.Font.GothamBold
	tabButton.TextScaled = true
	tabButton.Parent = sidebar
end

-------------------------------------------------------------
-- 🕊️ FLY SYSTEM (stabil & smooth)
-------------------------------------------------------------
local flying = false
local flySpeed = 80
local bodyGyro, bodyVel
local flyConnection

local function setFly(active)
	local char = player.Character
	if not char or not char:FindFirstChild("HumanoidRootPart") then return end
	local hrp = char.HumanoidRootPart

	flying = active
	if active then
		bodyGyro = Instance.new("BodyGyro", hrp)
		bodyGyro.MaxTorque = Vector3.new(1e9, 1e9, 1e9)
		bodyGyro.P = 1e5
		bodyGyro.CFrame = hrp.CFrame

		bodyVel = Instance.new("BodyVelocity", hrp)
		bodyVel.MaxForce = Vector3.new(1e9, 1e9, 1e9)
		bodyVel.Velocity = Vector3.zero

		flyConnection = RunService.RenderStepped:Connect(function()
			local cam = workspace.CurrentCamera
			local move = Vector3.zero
			if UserInputService:IsKeyDown(Enum.KeyCode.W) then move += cam.CFrame.LookVector end
			if UserInputService:IsKeyDown(Enum.KeyCode.S) then move -= cam.CFrame.LookVector end
			if UserInputService:IsKeyDown(Enum.KeyCode.A) then move -= cam.CFrame.RightVector end
			if UserInputService:IsKeyDown(Enum.KeyCode.D) then move += cam.CFrame.RightVector end
			if UserInputService:IsKeyDown(Enum.KeyCode.Space) then move += Vector3.new(0,1,0) end
			if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then move -= Vector3.new(0,1,0) end

			bodyGyro.CFrame = cam.CFrame
			bodyVel.Velocity = move.Magnitude > 0 and move.Unit * flySpeed or Vector3.zero
		end)
	else
		if flyConnection then flyConnection:Disconnect() end
		if bodyGyro then bodyGyro:Destroy() end
		if bodyVel then bodyVel:Destroy() end
	end
end

-- Taste F = Fly umschalten
UserInputService.InputBegan:Connect(function(input, gpe)
	if not gpe and input.KeyCode == Enum.KeyCode.F then
		setFly(not flying)
	end
end)

-------------------------------------------------------------
-- 🌈 Local Tab mit Speedsteuerung
-------------------------------------------------------------
for _, button in ipairs(sidebar:GetChildren()) do
	if button:IsA("TextButton") and button.Text == "Local" then
		button.MouseButton1Click:Connect(function()
			clearContent()

			local header = Instance.new("TextLabel", contentFrame)
			header.Size = UDim2.new(1,0,0,40)
			header.Text = "🕊️ Fly System"
			header.Font = Enum.Font.GothamBold
			header.TextColor3 = Color3.fromRGB(255,255,255)
			header.TextScaled = true
			header.BackgroundTransparency = 1

			local info = Instance.new("TextLabel", contentFrame)
			info.Size = UDim2.new(1,0,0,30)
			info.Position = UDim2.new(0,0,0,45)
			info.Text = "[F] Fly ein/aus • [Space]/[Shift] hoch/runter"
			info.TextColor3 = Color3.fromRGB(200,200,255)
			info.Font = Enum.Font.Gotham
			info.TextScaled = true
			info.BackgroundTransparency = 1

			local speedLabel = Instance.new("TextLabel", contentFrame)
			speedLabel.Size = UDim2.new(0,200,0,30)
			speedLabel.Position = UDim2.new(0,10,0,90)
			speedLabel.Text = "Speed: " .. flySpeed
			speedLabel.TextColor3 = Color3.fromRGB(255,255,255)
			speedLabel.Font = Enum.Font.GothamBold
			speedLabel.TextScaled = true
			speedLabel.BackgroundTransparency = 1

			local add = Instance.new("TextButton", contentFrame)
			add.Size = UDim2.new(0,80,0,40)
			add.Position = UDim2.new(0,220,0,85)
			add.Text = "+ Speed"
			add.Font = Enum.Font.GothamBold
			add.TextScaled = true
			add.BackgroundColor3 = Color3.fromRGB(80,120,180)
			add.TextColor3 = Color3.fromRGB(255,255,255)
			add.MouseButton1Click:Connect(function()
				flySpeed = math.clamp(flySpeed + 10, 10, 300)
				speedLabel.Text = "Speed: " .. flySpeed
			end)

			local sub = Instance.new("TextButton", contentFrame)
			sub.Size = UDim2.new(0,80,0,40)
			sub.Position = UDim2.new(0,310,0,85)
			sub.Text = "- Speed"
			sub.Font = Enum.Font.GothamBold
			sub.TextScaled = true
			sub.BackgroundColor3 = Color3.fromRGB(150,80,80)
			sub.TextColor3 = Color3.fromRGB(255,255,255)
			sub.MouseButton1Click:Connect(function()
				flySpeed = math.clamp(flySpeed - 10, 10, 300)
				speedLabel.Text = "Speed: " .. flySpeed
			end)
		end)
	end
end

-------------------------------------------------------------
-- ✅ STATUS-ANZEIGE (unten rechts)
-------------------------------------------------------------
local statusFrame = Instance.new("Frame")
statusFrame.Size = UDim2.new(0,220,0,40)
statusFrame.Position = UDim2.new(1,-230,1,-50)
statusFrame.BackgroundColor3 = Color3.fromRGB(40,35,90)
statusFrame.BackgroundTransparency = 0.2
statusFrame.Parent = screenGui
Instance.new("UICorner", statusFrame).CornerRadius = UDim.new(0,10)

local statusText = Instance.new("TextLabel")
statusText.Size = UDim2.new(1,0,1,0)
statusText.Text = "✅ Voidware Script geladen – bereit"
statusText.Font = Enum.Font.GothamBold
statusText.TextScaled = true
statusText.TextColor3 = Color3.fromRGB(200,255,200)
statusText.BackgroundTransparency = 1
statusText.Parent = statusFrame

-- Sanftes Einblenden
statusFrame.BackgroundTransparency = 1
statusText.TextTransparency = 1
TweenService:Create(statusFrame, TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 0.2}):Play()
TweenService:Create(statusText, TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextTransparency = 0}):Play()

-- Automatisches Ausblenden nach 8 Sekunden
task.delay(8, function()
	TweenService:Create(statusFrame, TweenInfo.new(1.5), {BackgroundTransparency = 1}):Play()
	TweenService:Create(statusText, TweenInfo.new(1.5), {TextTransparency = 1}):Play()
	task.wait(1.5)
	statusFrame:Destroy()
end)
