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
mainFrame.Size = UDim2.new(0, 400, 0, 300)
mainFrame.Position = UDim2.new(0.5, -200, 0.5, -150)
mainFrame.BackgroundColor3 = Color3.fromRGB(54, 57, 63)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 15)
mainCorner.Parent = mainFrame

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

-- Seitenleiste
local sideBar = Instance.new("Frame")
sideBar.Size = UDim2.new(0, 120, 1, 0)
sideBar.BackgroundColor3 = Color3.fromRGB(47, 49, 54)
sideBar.BorderSizePixel = 0
sideBar.Parent = mainFrame

local sideCorner = Instance.new("UICorner")
sideCorner.CornerRadius = UDim.new(0, 15)
sideCorner.Parent = sideBar

-- Hauptcontent-Bereich
local contentFrame = Instance.new("Frame")
contentFrame.Size = UDim2.new(1, -120, 1, 0)
contentFrame.Position = UDim2.new(0, 120, 0, 0)
contentFrame.BackgroundTransparency = 1
contentFrame.Parent = mainFrame

-- Funktion um Inhalte zu wechseln
local function showContent(name)
    for _, frame in pairs(contentFrame:GetChildren()) do
        if frame:IsA("Frame") then
            frame.Visible = frame.Name == name
        end
    end
end

-- Kategorien-Buttons
local categories = {"Main", "Help", "Support", "BringStuff", "Teleport"}

for i, cat in ipairs(categories) do
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, -20, 0, 40)
    button.Position = UDim2.new(0, 10, 0, 10 + (i-1)*50)
    button.BackgroundColor3 = Color3.fromRGB(64, 68, 75)
    button.BorderSizePixel = 0
    button.Text = cat
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.Font = Enum.Font.GothamBold
    button.TextScaled = true
    button.Parent = sideBar

    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0, 10)
    buttonCorner.Parent = button

    button.MouseButton1Click:Connect(function()
        showContent(cat)
    end)
end

-- Beispielinhalte für jede Kategorie
for _, cat in ipairs(categories) do
    local frame = Instance.new("Frame")
    frame.Name = cat
    frame.Size = UDim2.new(1, -20, 1, -20)
    frame.Position = UDim2.new(0, 10, 0, 10)
    frame.BackgroundColor3 = Color3.fromRGB(64, 68, 75)
    frame.Visible = cat == "Main"
    frame.Parent = contentFrame

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -20, 1, -20)
    label.Position = UDim2.new(0, 10, 0, 10)
    label.BackgroundTransparency = 1
    label.Text = cat .. " Content"
    label.TextColor3 = Color3.fromRGB(255,255,255)
    label.TextScaled = true
    label.Font = Enum.Font.GothamBold
    label.Parent = frame
end
