-- Roblox GUI ähnlich Discord Style (Voidware Style) komplett + ChestFarm Kategorie

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer

-- ScreenGui Setup
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ModernDashboard"
screenGui.ResetOnSpawn = false
screenGui.Parent = game:GetService("CoreGui")

-- Main Frame
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 750, 0, 500)
mainFrame.Position = UDim2.new(0.5, -375, 0.5, -250)
mainFrame.BackgroundColor3 = Color3.fromRGB(45, 40, 90)
mainFrame.Visible = true
mainFrame.Parent = screenGui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 12)
mainCorner.Parent = mainFrame

-- Hotkey RightShift
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.RightShift then
        mainFrame.Visible = not mainFrame.Visible
    end
end)

-- Header
local header = Instance.new("Frame")
header.Size = UDim2.new(1,0,0,45)
header.BackgroundColor3 = Color3.fromRGB(35,30,70)
header.Parent = mainFrame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1,-100,1,0)
title.Position = UDim2.new(0,15,0,0)
title.Text = "Voidware"
title.TextColor3 = Color3.fromRGB(255,255,255)
title.TextXAlignment = Enum.TextXAlignment.Left
title.Font = Enum.Font.GothamBold
title.TextScaled = true
title.BackgroundTransparency = 1
title.Parent = header

local closeButton = Instance.new("TextButton")
closeButton.Size = UDim2.new(0,40,0,40)
closeButton.Position = UDim2.new(1,-45,0.5,-20)
closeButton.Text = "X"
closeButton.TextColor3 = Color3.fromRGB(255,255,255)
closeButton.Font = Enum.Font.GothamBold
closeButton.TextScaled = true
closeButton.BackgroundTransparency = 1
closeButton.Parent = header
closeButton.MouseButton1Click:Connect(function()
    screenGui:Destroy()
end)

-- Sidebar
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

local profileCorner = Instance.new("UICorner")
profileCorner.CornerRadius = UDim.new(0,10)
profileCorner.Parent = profileFrame

local thumbType = Enum.ThumbnailType.HeadShot
local thumbSize = Enum.ThumbnailSize.Size100x100
local content, isReady = Players:GetUserThumbnailAsync(player.UserId, thumbType, thumbSize)

local avatar = Instance.new("ImageLabel")
avatar.Size = UDim2.new(0,45,0,45)
avatar.Position = UDim2.new(0,10,0.5,-22)
avatar.Image = content
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

-- Content Frame
local contentFrame = Instance.new("Frame")
contentFrame.Size = UDim2.new(1,-180,1,-45)
contentFrame.Position = UDim2.new(0,180,0,45)
contentFrame.BackgroundColor3 = Color3.fromRGB(55,50,100)
contentFrame.Parent = mainFrame

-- Tabs (neue Kategorie "ChestFarm")
local tabs = {"Main","Help","Teleport","Bring Stuff","Local","ChestFarm"}

local function clearContent()
    for _, child in ipairs(contentFrame:GetChildren()) do
        if not child:IsA("UIListLayout") then
            child:Destroy()
        end
    end
end

-- Hilfsfunktion: nächste Chest finden
local function findClosestChest()
    local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end

    local best, bestDist = nil, math.huge
    for _, obj in ipairs(workspace:GetDescendants()) do
        local name = obj.Name:lower()
        if name:find("chest") or name:find("diamond") then
            local pos
            if obj:IsA("Model") then
                pos = obj.PrimaryPart and obj.PrimaryPart.Position
            elseif obj:IsA("BasePart") then
                pos = obj.Position
            end
            if pos then
                local dist = (hrp.Position - pos).Magnitude
                if dist < bestDist then
                    bestDist = dist
                    best = obj
                end
            end
        end
    end
    return best
end

-- Sidebar Buttons
for i, tabName in ipairs(tabs) do
    local tabButton = Instance.new("TextButton")
    tabButton.Size = UDim2.new(1,0,0,40)
    tabButton.Position = UDim2.new(0,0,0,(i-1)*45)
    tabButton.Text = tabName
    tabButton.TextColor3 = Color3.fromRGB(255,255,255)
    tabButton.BackgroundColor3 = Color3.fromRGB(60,55,110)
    tabButton.Parent = sidebar

    tabButton.MouseButton1Click:Connect(function()
        clearContent()

        -- MAIN
        if tabName == "Main" then
            local label = Instance.new("TextLabel", contentFrame)
            label.Size = UDim2.new(1,0,0,50)
            label.Text = "Willkommen im Voidware Dashboard!"
            label.TextColor3 = Color3.fromRGB(255,255,255)
            label.BackgroundTransparency = 1
            label.Font = Enum.Font.GothamBold
            label.TextScaled = true
        end

        -- HELP
        if tabName == "Help" then
            local helpLabel = Instance.new("TextLabel", contentFrame)
            helpLabel.Size = UDim2.new(1,0,1,0)
            helpLabel.Text = "Hier kannst du Infos & Hilfe anzeigen."
            helpLabel.TextColor3 = Color3.fromRGB(255,255,255)
            helpLabel.BackgroundTransparency = 1
            helpLabel.Font = Enum.Font.Gotham
            helpLabel.TextScaled = true
        end

        -- TELEPORT
        if tabName == "Teleport" then
            local tpButton = Instance.new("TextButton", contentFrame)
            tpButton.Size = UDim2.new(0,200,0,50)
            tpButton.Position = UDim2.new(0,20,0,20)
            tpButton.Text = "Teleport to Spawn"
            tpButton.TextColor3 = Color3.fromRGB(255,255,255)
            tpButton.BackgroundColor3 = Color3.fromRGB(70,65,130)
            tpButton.MouseButton1Click:Connect(function()
                if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                    player.Character:MoveTo(Vector3.new(0,10,0))
                end
            end)
        end

        -- BRING STUFF
        if tabName == "Bring Stuff" then
            local spawnY = 3
            local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
            if not root then return end

            local function bringAllExisting()
                for _, obj in pairs(workspace:GetDescendants()) do
                    if obj:IsA("BasePart") and obj.Size.Magnitude < 8 then
                        obj.CFrame = root.CFrame + Vector3.new(5, spawnY, 0)
                        obj.Anchored = false
                    elseif obj:IsA("Model") and obj.PrimaryPart and obj:GetExtentsSize().Magnitude < 8 then
                        obj:PivotTo(root.CFrame + Vector3.new(5, spawnY, 0))
                    end
                end
            end

            local bringAllBtn = Instance.new("TextButton", contentFrame)
            bringAllBtn.Size = UDim2.new(0,200,0,50)
            bringAllBtn.Position = UDim2.new(0,20,0,20)
            bringAllBtn.Text = "Bring All Items"
            bringAllBtn.BackgroundColor3 = Color3.fromRGB(90,70,150)
            bringAllBtn.TextColor3 = Color3.fromRGB(255,255,255)
            bringAllBtn.MouseButton1Click:Connect(function()
                bringAllExisting()
            end)
        end

        -- LOCAL
        if tabName == "Local" then
            local infJumpEnabled = false
            local toggle = Instance.new("TextButton", contentFrame)
            toggle.Size = UDim2.new(0,200,0,50)
            toggle.Position = UDim2.new(0,20,0,20)
            toggle.Text = "Infinite Jump: OFF"
            toggle.BackgroundColor3 = Color3.fromRGB(70,65,130)
            toggle.TextColor3 = Color3.fromRGB(255,255,255)

            toggle.MouseButton1Click:Connect(function()
                infJumpEnabled = not infJumpEnabled
                toggle.Text = "Infinite Jump: " .. (infJumpEnabled and "ON" or "OFF")
            end)

            UserInputService.JumpRequest:Connect(function()
                if infJumpEnabled and player.Character and player.Character:FindFirstChildOfClass("Humanoid") then
                    player.Character:FindFirstChildOfClass("Humanoid"):ChangeState(Enum.HumanoidStateType.Jumping)
                end
            end)
        end

        -- 🌟 CHESTFARM
        if tabName == "ChestFarm" then
            local label = Instance.new("TextLabel", contentFrame)
            label.Size = UDim2.new(1,0,0,50)
            label.Text = "Diamond Chest AutoCollect"
            label.TextColor3 = Color3.fromRGB(255,255,255)
            label.BackgroundTransparency = 1
            label.Font = Enum.Font.GothamBold
            label.TextScaled = true

            local startBtn = Instance.new("TextButton", contentFrame)
            startBtn.Size = UDim2.new(0,200,0,50)
            startBtn.Position = UDim2.new(0,20,0,80)
            startBtn.Text = "Start AutoCollect"
            startBtn.BackgroundColor3 = Color3.fromRGB(100,80,180)
            startBtn.TextColor3 = Color3.fromRGB(255,255,255)
            startBtn.Font = Enum.Font.GothamBold
            startBtn.TextScaled = true

            startBtn.MouseButton1Click:Connect(function()
                local chest = findClosestChest()
                if not chest then
                    warn("❌ Keine Chest gefunden!")
                    return
                end

                -- Teleportiere hin
                local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    if chest:IsA("Model") and chest.PrimaryPart then
                        hrp.CFrame = chest.PrimaryPart.CFrame + Vector3.new(0,3,0)
                    elseif chest:IsA("BasePart") then
                        hrp.CFrame = chest.CFrame + Vector3.new(0,3,0)
                    end
                end

                -- Versuch Chest zu öffnen (lokal, nur GUI-Effekt)
                for _, d in ipairs(chest:GetDescendants()) do
                    if d:IsA("ProximityPrompt") then
                        fireproximityprompt(d) -- Exploit-Funktion, funktioniert nur in Executor
                    end
                end
            end)
        end
    end)
end
