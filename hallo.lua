local Players = game:GetService("Players")
local player = Players.LocalPlayer

-- GUI erstellen
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "HalloGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

-- Hauptframe
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 400, 0, 250)
mainFrame.Position = UDim2.new(0.5, -200, 0.5, -125)
mainFrame.BackgroundColor3 = Color3.fromRGB(54, 57, 63) -- dunkles Blau/Grau
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 15)
mainCorner.Parent = mainFrame

-- Shadow-Effekt (optional)
local uiStroke = Instance.new("UIStroke")
uiStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
uiStroke.Color = Color3.fromRGB(0,0,0)
uiStroke.Thickness = 1
uiStroke.Transparency = 0.5
uiStroke.Parent = mainFrame

-- Seitenleiste
local sideBar = Instance.new("Frame")
sideBar.Size = UDim2.new(0, 100, 1, 0)
sideBar.BackgroundColor3 = Color3.fromRGB(47, 49, 54)
sideBar.BorderSizePixel = 0
sideBar.Parent = mainFrame

local sideCorner = Instance.new("UICorner")
sideCorner.CornerRadius = UDim.new(0, 15)
sideCorner.Parent = sideBar

-- Hauptcontent-Bereich
local contentFrame = Instance.new("Frame")
contentFrame.Size = UDim2.new(1, -100, 1, 0)
contentFrame.Position = UDim2.new(0, 100, 0, 0)
contentFrame.BackgroundTransparency = 1
contentFrame.Parent = mainFrame

-- Willkommenstext als Karte
local welcomeCard = Instance.new("Frame")
welcomeCard.Size = UDim2.new(0.9, 0, 0.3, 0)
welcomeCard.Position = UDim2.new(0.05, 0, 0.05, 0)
welcomeCard.BackgroundColor3 = Color3.fromRGB(64, 68, 75)
welcomeCard.Parent = contentFrame

local cardCorner = Instance.new("UICorner")
cardCorner.CornerRadius = UDim.new(0, 10)
cardCorner.Parent = welcomeCard

local welcomeText = Instance.new("TextLabel")
welcomeText.Size = UDim2.new(1, -20, 1, -20)
welcomeText.Position = UDim2.new(0, 10, 0, 10)
welcomeText.BackgroundTransparency = 1
welcomeText.Text = "Hallo " .. player.Name .. "!"
welcomeText.TextColor3 = Color3.fromRGB(255,255,255)
welcomeText.TextScaled = true
welcomeText.Font = Enum.Font.GothamBold
welcomeText.TextXAlignment = Enum.TextXAlignment.Left
welcomeText.Parent = welcomeCard

-- Spieler Info unten links
local playerFrame = Instance.new("Frame")
playerFrame.Size = UDim2.new(0, 180, 0, 50)
playerFrame.Position = UDim2.new(0, 10, 1, -60)
playerFrame.BackgroundColor3 = Color3.fromRGB(47, 49, 54)
playerFrame.BorderSizePixel = 0
playerFrame.Parent = mainFrame

local playerCorner = Instance.new("UICorner")
playerCorner.CornerRadius = UDim.new(0, 10)
playerCorner.Parent = playerFrame

local imageLabel = Instance.new("ImageLabel")
imageLabel.Size = UDim2.new(0, 40, 0, 40)
imageLabel.Position = UDim2.new(0, 5, 0.5, -20)
imageLabel.BackgroundTransparency = 1
imageLabel.Image = Players:GetUserThumbnailAsync(player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)
imageLabel.Parent = playerFrame

local nameLabel = Instance.new("TextLabel")
nameLabel.Size = UDim2.new(0, 130, 1, 0)
nameLabel.Position = UDim2.new(0, 50, 0, 0)
nameLabel.BackgroundTransparency = 1
nameLabel.TextColor3 = Color3.fromRGB(255,255,255)
nameLabel.TextScaled = true
nameLabel.Font = Enum.Font.GothamBold
nameLabel.TextXAlignment = Enum.TextXAlignment.Left
nameLabel.Text = player.Name
nameLabel.Parent = playerFrame
