local Players = game:GetService("Players")
local player = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")

-- GUI erstellen
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "HalloGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

-- Hauptframe
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 600, 0, 400)
mainFrame.Position = UDim2.new(0.5, -300, 0.5, -200)
mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 35)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 20)
mainCorner.Parent = mainFrame

-- Neon Rahmen
local uiStroke = Instance.new("UIStroke")
uiStroke.Color = Color3.fromRGB(0, 170, 255)
uiStroke.Thickness = 2
uiStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
uiStroke.Parent = mainFrame

-- Draggable Funktion
local dragging = false
local dragInput, dragStart, startPos

local function update(input)
    local delta = input.Position - dragStart
    mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

mainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

mainFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        update(input)
    end
end)

-- Close Button
local closeButton = Instance.new("TextButton")
closeButton.Size = UDim2.new(0, 30, 0, 30)
closeButton.Position = UDim2.new(1, -40, 0, 10)
closeButton.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
closeButton.Text = "X"
closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
closeButton.Font = Enum.Font.GothamBold
closeButton.TextScaled = true
closeButton.Parent = mainFrame

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 5)
closeCorner.Parent = closeButton

closeButton.MouseButton1Click:Connect(function()
    screenGui:Destroy()
end)

-- Minimize Button
local minimizeButton = Instance.new("TextButton")
minimizeButton.Size = UDim2.new(0, 30, 0, 30)
minimizeButton.Position = UDim2.new(1, -80, 0, 10)
minimizeButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
minimizeButton.Text = "-"
minimizeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
minimizeButton.Font = Enum.Font.GothamBold
minimizeButton.TextScaled = true
minimizeButton.Parent = mainFrame

local minCorner = Instance.new("UICorner")
minCorner.CornerRadius = UDim.new(0, 5)
minCorner.Parent = minimizeButton

local isMinimized = false
minimizeButton.MouseButton1Click:Connect(function()
    if isMinimized then
        mainFrame.Size = UDim2.new(0, 600, 0, 400)
        contentFrame.Visible = true
        sideBar.Visible = true
        isMinimized = false
    else
        mainFrame.Size = UDim2.new(0, 200, 0, 40)
        contentFrame.Visible = false
        sideBar.Visible = false
        isMinimized = true
    end
end)

-- Seitenleiste
local sideBar = Instance.new("Frame")
sideBar.Size = UDim2.new(0, 140, 1, 0)
sideBar.BackgroundColor3 = Color3.fromRGB(10, 10, 25)
sideBar.BorderSizePixel = 0
sideBar.Parent = mainFrame

local sideCorner = Instance.new("UICorner")
sideCorner.CornerRadius = UDim.new(0, 20)
sideCorner.Parent = sideBar

-- Spieler Info oben links
local playerFrame = Instance.new("Frame")
playerFrame.Size = UDim2.new(0, 130, 0, 50)
playerFrame.Position = UDim2.new(0, 10, 0, 10)
playerFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 50)
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
nameLabel.Size = UDim2.new(0, 85, 1, 0)
nameLabel.Position = UDim2.new(0, 50, 0, 0)
nameLabel.BackgroundTransparency = 1
nameLabel.TextColor3 = Color3.fromRGB(0, 255, 255)
nameLabel.TextScaled = true
nameLabel.Font = Enum.Font.GothamBold
nameLabel.TextXAlignment = Enum.TextXAlignment.Left
nameLabel.Text = player.Name
nameLabel.Parent = playerFrame

-- Hauptcontent-Bereich
local contentFrame = Instance.new("Frame")
contentFrame.Size = UDim2.new(1, -140, 1, 0)
contentFrame.Position = UDim2.new(0, 140, 0, 0)
contentFrame.BackgroundTransparency = 1
contentFrame.Parent = mainFrame

-- Kategorien-Buttons und Content wie bisher
local categories = {
    {Name = "Main", Icon = "rbxassetid://6031094670"},
    {Name = "Help", Icon = "rbxassetid://6031094639"},
    {Name = "Support", Icon = "rbxassetid://6031094667"},
    {Name = "BringStuff", Icon = "rbxassetid://6031094647"},
    {Name = "Teleport", Icon = "rbxassetid://6031094654"}
}

local function showContent(name)
    for _, frame in pairs(contentFrame:GetChildren()) do
        if frame:IsA("Frame") then
            frame.Visible = frame.Name == name
        end
    end
end

for i, cat in ipairs(categories) do
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, -20, 0, 50)
    button.Position = UDim2.new(0, 10, 0, 20 + (i-1)*70)
    button.BackgroundColor3 = Color3.fromRGB(0, 50, 100)
    button.BorderSizePixel = 0
    button.Text = ""
    button.Parent = sideBar

    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0, 15)
    buttonCorner.Parent = button

    local glow = Instance.new("UIStroke")
    glow.Color = Color3.fromRGB(0, 170, 255)
    glow.Thickness = 2
    glow.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    glow.Parent = button

    local icon = Instance.new("ImageLabel")
    icon.Size = UDim2.new(0, 30, 0, 30)
    icon.Position = UDim2.new(0, 10, 0, 10)
    icon.BackgroundTransparency = 1
    icon.Image = cat.Icon
    icon.Parent = button

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -50, 1, 0)
    label.Position = UDim2.new(0, 50, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = cat.Name
    label.TextColor3 = Color3.fromRGB(0, 255, 255)
    label.TextScaled = true
    label.Font = Enum.Font.GothamBold
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = button

    button.MouseButton1Click:Connect(function()
        showContent(cat.Name)
    end)
end

-- Content Frames
for _, cat in ipairs(categories) do
    local frame = Instance.new("Frame")
    frame.Name = cat.Name
    frame.Size = UDim2.new(1, -20, 1, -20)
    frame.Position = UDim2.new(0, 10, 0, 10)
    frame.BackgroundColor3 = Color3.fromRGB(5, 5, 40)
    frame.Visible = cat.Name == "Main"
    frame.Parent = contentFrame

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -20, 0, 50)
    title.Position = UDim2.new(0, 10, 0, 10)
    title.BackgroundTransparency = 1
    title.Text = cat.Name
    title.TextColor3 = Color3.fromRGB(0, 200, 255)
    title.TextScaled = true
    title.Font = Enum.Font.GothamBold
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = frame

    local light = Instance.new("Frame")
    light.Size = UDim2.new(1, 0, 0, 5)
    light.Position = UDim2.new(0, 0, 0, 0)
    light.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
    light.BorderSizePixel = 0
    light.Parent = frame
end
