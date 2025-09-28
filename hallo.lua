-- Roblox GUI ähnlich Discord Style (Voidware Style) komplett

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

-- Tabs
local tabs = {"Main","Help","Teleport","Bring Stuff","Local"}

local function clearContent()
    for _, child in ipairs(contentFrame:GetChildren()) do
        if not child:IsA("UIListLayout") then
            child:Destroy()
        end
    end
end

-- 🔎 DayValue-Suche (echter Counter im Spiel)
local function findDayValue()
    local keywords = {"day","tage","tag","night","survived"}
    local foundValues = {}
    local function scan(obj)
        for _, child in ipairs(obj:GetChildren()) do
            for _, key in ipairs(keywords) do
                if string.find(child.Name:lower(), key) then
                    if child:IsA("IntValue") or child:IsA("NumberValue") then
                        table.insert(foundValues, child)
                    end
                end
            end
            scan(child)
        end
    end
    scan(game)
    return foundValues
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

            -- Eingabefeld: Day setzen
            local dayBox = Instance.new("TextBox", contentFrame)
            dayBox.Size = UDim2.new(0,100,0,40)
            dayBox.Position = UDim2.new(0,20,0,80)
            dayBox.PlaceholderText = "z.B. 50"
            dayBox.Text = ""
            dayBox.TextScaled = true
            dayBox.Font = Enum.Font.Gotham
            dayBox.BackgroundColor3 = Color3.fromRGB(70,65,130)
            dayBox.TextColor3 = Color3.fromRGB(255,255,255)

            local setDayBtn = Instance.new("TextButton", contentFrame)
            setDayBtn.Size = UDim2.new(0,120,0,40)
            setDayBtn.Position = UDim2.new(0,140,0,80)
            setDayBtn.Text = "Setze Tag"
            setDayBtn.BackgroundColor3 = Color3.fromRGB(90,70,150)
            setDayBtn.TextColor3 = Color3.fromRGB(255,255,255)
            setDayBtn.Font = Enum.Font.GothamBold
            setDayBtn.TextScaled = true

            setDayBtn.MouseButton1Click:Connect(function()
                local newDay = tonumber(dayBox.Text)
                if not newDay or newDay < 1 then
                    label.Text = "❌ Ungültige Eingabe!"
                    return
                end

                -- GUI ändern
                local guiCounter = player:FindFirstChild("PlayerGui")
                    and player.PlayerGui:FindFirstChild("Interface")
                    and player.PlayerGui.Interface:FindFirstChild("DayCounter")
                if guiCounter and guiCounter:IsA("TextLabel") then
                    guiCounter.Text = "Day " .. tostring(newDay)
                end

                -- Echten Value ändern
                local found = findDayValue()
                if #found > 0 then
                    for _, val in ipairs(found) do
                        val.Value = newDay
                    end
                    label.Text = "✅ Spiel-Tag gesetzt auf: " .. tostring(newDay)
                    print("DayValue geändert:", newDay)
                else
                    label.Text = "⚠️ Kein echter DayValue gefunden – nur GUI geändert."
                end
            end)
        end

        -- (die restlichen Tabs bleiben gleich wie in deinem Code:
        -- Help, Teleport, Bring Stuff, Local ...)
    end)
end
