-- Einfaches Hallo-GUI
-- von dir zum Testen hochladen 🙂

local Players = game:GetService("Players")
local player = Players.LocalPlayer

-- GUI erstellen
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "HalloGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

-- TextLabel hinzufügen
local textLabel = Instance.new("TextLabel")
textLabel.Size = UDim2.new(0, 200, 0, 100)
textLabel.Position = UDim2.new(0.5, -100, 0.5, -50)
textLabel.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
textLabel.TextScaled = true
textLabel.Text = "Hallo :)"
textLabel.Parent = screenGui

-- Schließen-Button hinzufügen
local button = Instance.new("TextButton")
button.Size = UDim2.new(0, 200, 0, 50)
button.Position = UDim2.new(0.5, -100, 0.5, 60)
button.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
button.TextColor3 = Color3.fromRGB(255, 255, 255)
button.TextScaled = true
button.Text = "Schließen"
button.Parent = screenGui

button.MouseButton1Click:Connect(function()
    screenGui:Destroy()
end)
