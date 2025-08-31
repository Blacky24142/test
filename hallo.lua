-- Roblox GUI ähnlich Discord Style (Voidware Style)

local Players = game:GetService("Players")
local player = Players.LocalPlayer

-- ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Parent = player:WaitForChild("PlayerGui")
screenGui.Name = "ModernDashboard"
screenGui.ResetOnSpawn = false

-- Main Frame
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 750, 0, 500)
mainFrame.Position = UDim2.new(0.5, -375, 0.5, -250)
mainFrame.BackgroundColor3 = Color3.fromRGB(45, 40, 90)
mainFrame.Parent = screenGui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 12)
mainCorner.Parent = mainFrame

-- Header
local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 45)
header.BackgroundColor3 = Color3.fromRGB(35, 30, 70)
header.Parent = mainFrame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -100, 1, 0)
title.Position = UDim2.new(0, 15, 0, 0)
title.Text = "Voidware"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextXAlignment = Enum.TextXAlignment.Left
title.Font = Enum.Font.GothamBold
title.TextScaled = true
title.BackgroundTransparency = 1
title.Parent = header

-- Minimize und Close
local closeButton = Instance.new("TextButton")
closeButton.Size = UDim2.new(0, 40, 0, 40)
closeButton.Position = UDim2.new(1, -45, 0.5, -20)
closeButton.Text = "X"
closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
closeButton.Font = Enum.Font.GothamBold
closeButton.TextScaled = true
closeButton.BackgroundTransparency = 1
closeButton.Parent = header
closeButton.MouseButton1Click:Connect(function()
    screenGui:Destroy()
end)

local minimizeButton = Instance.new("TextButton")
minimizeButton.Size = UDim2.new(0, 40, 0, 40)
minimizeButton.Position = UDim2.new(1, -90, 0.5, -20)
minimizeButton.Text = "-"
minimizeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
minimizeButton.Font = Enum.Font.GothamBold
minimizeButton.TextScaled = true
minimizeButton.BackgroundTransparency = 1
minimizeButton.Parent = header

-- Sidebar
local sidebar = Instance.new("Frame")
sidebar.Size = UDim2.new(0, 180, 1, -45)
sidebar.Position = UDim2.new(0, 0, 0, 45)
sidebar.BackgroundColor3 = Color3.fromRGB(40, 35, 80)
sidebar.Parent = mainFrame

-- Profil unten
local profileFrame = Instance.new("Frame")
profileFrame.Size = UDim2.new(1, 0, 0, 70)
profileFrame.Position = UDim2.new(0, 0, 1, -70)
profileFrame.BackgroundColor3 = Color3.fromRGB(35, 30, 70)
profileFrame.Parent = sidebar

local profileCorner = Instance.new("UICorner")
profileCorner.CornerRadius = UDim.new(0, 10)
profileCorner.Parent = profileFrame

local thumbType = Enum.ThumbnailType.HeadShot
local thumbSize = Enum.ThumbnailSize.Size100x100
local content, isReady = Players:GetUserThumbnailAsync(player.UserId, thumbType, thumbSize)

local avatar = Instance.new("ImageLabel")
avatar.Size = UDim2.new(0, 45, 0, 45)
avatar.Position = UDim2.new(0, 10, 0.5, -22)
avatar.Image = content
avatar.BackgroundTransparency = 1
avatar.Parent = profileFrame

local nameLabel = Instance.new("TextLabel")
nameLabel.Size = UDim2.new(1, -65, 1, 0)
nameLabel.Position = UDim2.new(0, 60, 0, 0)
nameLabel.Text = player.Name .. "\n@" .. player.UserId
nameLabel.TextColor3 = Color3.fromRGB(200, 200, 255)
nameLabel.Font = Enum.Font.Gotham
nameLabel.TextScaled = true
nameLabel.TextXAlignment = Enum.TextXAlignment.Left
nameLabel.BackgroundTransparency = 1
nameLabel.Parent = profileFrame

-- Content Area
local contentFrame = Instance.new("Frame")
contentFrame.Size = UDim2.new(1, -180, 1, -45)
contentFrame.Position = UDim2.new(0, 180, 0, 45)
contentFrame.BackgroundColor3 = Color3.fromRGB(55, 50, 100)
contentFrame.Parent = mainFrame

-- Beispiel Card
local card = Instance.new("Frame")
card.Size = UDim2.new(0, 350, 0, 100)
card.Position = UDim2.new(0, 30, 0, 30)
card.BackgroundColor3 = Color3.fromRGB(65, 60, 120)
card.Parent = contentFrame

local cardCorner = Instance.new("UICorner")
cardCorner.CornerRadius = UDim.new(0, 12)
cardCorner.Parent = card

local cardText = Instance.new("TextLabel")
cardText.Size = UDim2.new(1, -20, 1, -20)
cardText.Position = UDim2.new(0, 10, 0, 10)
cardText.Text = "Voidware [Official]\nMember Count: 40564\nOnline Count: 5904"
cardText.TextColor3 = Color3.fromRGB(255, 255, 255)
cardText.Font = Enum.Font.GothamBold
cardText.TextSize = 18
cardText.TextXAlignment = Enum.TextXAlignment.Left
cardText.TextYAlignment = Enum.TextYAlignment.Top
cardText.BackgroundTransparency = 1
cardText.Parent = card
