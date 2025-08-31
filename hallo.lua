local Players = game:GetService("Players")
local player = Players.LocalPlayer

-- GUI erstellen
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "HalloGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

-- Hauptframe für modernen Look
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 300, 0, 150)
frame.Position = UDim2.new(0.5, -150, 0.5, -75)
frame.BackgroundColor3 = Color3.fromRGB(10, 100, 255) -- Blau
frame.BackgroundTransparency = 0
frame.BorderSizePixel = 0
frame.Parent = screenGui
frame.AnchorPoint = Vector2.new(0.5, 0.5)
frame.ClipsDescendants = true

-- Abgerundete Ecken
local uicorner = Instance.new("UICorner")
uicorner.CornerRadius = UDim.new(0, 15)
uicorner.Parent = frame

-- TextLabel
local textLabel = Instance.new("TextLabel")
textLabel.Size = UDim2.new(1, -20, 0.6, 0)
textLabel.Position = UDim2.new(0, 10, 0, 10)
textLabel.BackgroundTransparency = 1
textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
textLabel.TextScaled = true
textLabel.Font = Enum.Font.GothamBold
textLabel.Text = "Hallo :)"
textLabel.Parent = frame

-- Schließen-Button
local button = Instance.new("TextButton")
button.Size = UDim2.new(0.4, 0, 0.2, 0)
button.Position = UDim2.new(0.3, 0, 0.7, 0)
button.BackgroundColor3 = Color3.fromRGB(0, 80, 200)
button.TextColor3 = Color3.fromRGB(255, 255, 255)
button.TextScaled = true
button.Font = Enum.Font.Gotham
button.Text = "Schließen"
button.Parent = frame

button.MouseButton1Click:Connect(function()
    screenGui:Destroy()
end)

-- Player Info unten links
local playerFrame = Instance.new("Frame")
playerFrame.Size = UDim2.new(0, 200, 0, 50)
playerFrame.Position = UDim2.new(0, 10, 1, -60)
playerFrame.BackgroundTransparency = 0.2
playerFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
playerFrame.BorderSizePixel = 0
playerFrame.Parent = frame

local playerCorner = Instance.new("UICorner")
playerCorner.CornerRadius = UDim.new(0, 10)
playerCorner.Parent = playerFrame

-- Character Thumbnail
local imageLabel = Instance.new("ImageLabel")
imageLabel.Size = UDim2.new(0, 40, 0, 40)
imageLabel.Position = UDim2.new(0, 5, 0.5, -20)
imageLabel.BackgroundTransparency = 1
imageLabel.Image = Players:GetUserThumbnailAsync(player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)
imageLabel.Parent = playerFrame

-- Spielername
local nameLabel = Instance.new("TextLabel")
nameLabel.Size = UDim2.new(0, 140, 1, 0)
nameLabel.Position = UDim2.new(0, 50, 0, 0)
nameLabel.BackgroundTransparency = 1
nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
nameLabel.TextScaled = true
nameLabel.Font = Enum.Font.GothamBold
nameLabel.TextXAlignment = Enum.TextXAlignment.Left
nameLabel.Text = player.Name
nameLabel.Parent = playerFrame
