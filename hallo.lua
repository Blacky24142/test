-- Roblox GUI ähnlich Discord Style (Voidware Style) mit Kategorien und Funktionen

local Players = game:GetService("Players")
local player = Players.LocalPlayer
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

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

-- Tabs (Main, Help, Teleport, Bring Stuff, Local)
local categories = {"Main", "Help", "Teleport", "Bring Stuff", "Local"}
local buttons = {}
local activeTab = nil

local function clearContent()
    for _, child in pairs(contentFrame:GetChildren()) do
        if child:IsA("Frame") or child:IsA("TextLabel") or child:IsA("TextButton") or child:IsA("TextBox") then
            child:Destroy()
        end
    end
end

local function switchTab(tabName)
    clearContent()
    activeTab = tabName
    
    if tabName == "Main" then
        local text = Instance.new("TextLabel", contentFrame)
        text.Size = UDim2.new(1, 0, 0, 50)
        text.Text = "Willkommen im Voidware Dashboard"
        text.TextColor3 = Color3.fromRGB(255,255,255)
        text.Font = Enum.Font.GothamBold
        text.TextScaled = true
        text.BackgroundTransparency = 1
    elseif tabName == "Help" then
        local text = Instance.new("TextLabel", contentFrame)
        text.Size = UDim2.new(1, 0, 0, 200)
        text.Text = "Help Menü\n- Nutze Teleport um dich zu bewegen\n- Bring Stuff bringt Scrap & Logs\n- Local: Speed & Infinite Jump"
        text.TextColor3 = Color3.fromRGB(255,255,255)
        text.Font = Enum.Font.Gotham
        text.TextSize = 18
        text.BackgroundTransparency = 1
        text.TextWrapped = true
    elseif tabName == "Teleport" then
        local tpButton = Instance.new("TextButton", contentFrame)
        tpButton.Size = UDim2.new(0,200,0,50)
        tpButton.Position = UDim2.new(0,20,0,20)
        tpButton.Text = "Teleport zu Spawn"
        tpButton.BackgroundColor3 = Color3.fromRGB(70,65,130)
        tpButton.TextColor3 = Color3.fromRGB(255,255,255)
        tpButton.MouseButton1Click:Connect(function()
            if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                player.Character:MoveTo(Vector3.new(0,10,0))
            end
        end)
    elseif tabName == "Bring Stuff" then
        -- Page Frame
        local pageFrame = Instance.new("Frame", contentFrame)
        pageFrame.Size = UDim2.new(1,0,1,0)
        pageFrame.BackgroundTransparency = 1
        
        local function showPage()
            for _, child in pairs(pageFrame:GetChildren()) do
                child:Destroy()
            end

            -- Logs Button
            local logsButton = Instance.new("TextButton", pageFrame)
            logsButton.Size = UDim2.new(0,200,0,50)
            logsButton.Position = UDim2.new(0,20,0,20)
            logsButton.Text = "Bring Logs"
            logsButton.BackgroundColor3 = Color3.fromRGB(70,65,130)
            logsButton.TextColor3 = Color3.fromRGB(255,255,255)
            logsButton.MouseButton1Click:Connect(function()
                for _, obj in pairs(workspace:GetDescendants()) do
                    if obj.Name:lower():find("log") and obj:IsA("BasePart") then
                        obj.CFrame = player.Character.HumanoidRootPart.CFrame + Vector3.new(0,5,0)
                    end
                end
            end)
            
            -- Scrap Button
            local scrapButton = Instance.new("TextButton", pageFrame)
            scrapButton.Size = UDim2.new(0,200,0,50)
            scrapButton.Position = UDim2.new(0,20,0,80)
            scrapButton.Text = "Bring Scrap"
            scrapButton.BackgroundColor3 = Color3.fromRGB(70,65,130)
            scrapButton.TextColor3 = Color3.fromRGB(255,255,255)
            scrapButton.MouseButton1Click:Connect(function()
                for _, obj in pairs(workspace:GetDescendants()) do
                    if obj.Name:lower():find("scrap") and obj:IsA("BasePart") then
                        obj.CFrame = player.Character.HumanoidRootPart.CFrame + Vector3.new(0,5,0)
                    end
                end
            end)
        end
        
        showPage()
        
    elseif tabName == "Local" then
        -- Infinite Jump
        local infJumpToggle = false
        local infJumpButton = Instance.new("TextButton", contentFrame)
        infJumpButton.Size = UDim2.new(0,200,0,50)
        infJumpButton.Position = UDim2.new(0,20,0,20)
        infJumpButton.Text = "Infinite Jump: OFF"
        infJumpButton.BackgroundColor3 = Color3.fromRGB(70,65,130)
        infJumpButton.TextColor3 = Color3.fromRGB(255,255,255)
        infJumpButton.MouseButton1Click:Connect(function()
            infJumpToggle = not infJumpToggle
            infJumpButton.Text = "Infinite Jump: " .. (infJumpToggle and "ON" or "OFF")
        end)
        UserInputService.JumpRequest:Connect(function()
            if infJumpToggle and player.Character and player.Character:FindFirstChildOfClass("Humanoid") then
                player.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping")
            end
        end)
        
        -- WalkSpeed
        local speedBox = Instance.new("TextBox", contentFrame)
        speedBox.Size = UDim2.new(0,200,0,50)
        speedBox.Position = UDim2.new(0,20,0,80)
        speedBox.PlaceholderText = "WalkSpeed eingeben"
        speedBox.BackgroundColor3 = Color3.fromRGB(70,65,130)
        speedBox.TextColor3 = Color3.fromRGB(255,255,255)
        speedBox.Text = ""
        
        speedBox.FocusLost:Connect(function(enterPressed)
            if enterPressed then
                local val = tonumber(speedBox.Text)
                if val and player.Character and player.Character:FindFirstChildOfClass("Humanoid") then
                    player.Character:FindFirstChildOfClass("Humanoid").WalkSpeed = val
                end
            end
        end)
    end
end

-- Sidebar Buttons
for i, cat in ipairs(categories) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 40)
    btn.Position = UDim2.new(0, 0, 0, (i-1)*45)
    btn.Text = cat
    btn.BackgroundColor3 = Color3.fromRGB(50, 45, 90)
    btn.TextColor3 = Color3.fromRGB(255,255,255)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 16
    btn.Parent = sidebar
    btn.MouseButton1Click:Connect(function()
        switchTab(cat)
    end)
    buttons[cat] = btn
end

-- Default Tab
switchTab("Main")
