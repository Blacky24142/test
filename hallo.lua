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

-- 🔎 Suche nach Day/Tag Objekten
local function searchForDayObjects()
    local results = {}
    local keywords = {"day","tage","tag","night","survived"}

    local function scan(obj)
        for _, child in ipairs(obj:GetChildren()) do
            for _, key in ipairs(keywords) do
                if string.find(child.Name:lower(), key) then
                    table.insert(results, child)
                end
            end
            scan(child)
        end
    end

    scan(game)
    return results
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
            local titleLabel = Instance.new("TextLabel", contentFrame)
            titleLabel.Size = UDim2.new(1,0,0,40)
            titleLabel.Text = "Day/Tag-Objekte im Spiel"
            titleLabel.TextColor3 = Color3.fromRGB(255,255,255)
            titleLabel.BackgroundTransparency = 1
            titleLabel.Font = Enum.Font.GothamBold
            titleLabel.TextScaled = true

            -- ScrollingFrame für Ergebnisse
            local scroll = Instance.new("ScrollingFrame", contentFrame)
            scroll.Size = UDim2.new(1,-20,1,-60)
            scroll.Position = UDim2.new(0,10,0,50)
            scroll.BackgroundTransparency = 1
            scroll.BorderSizePixel = 0
            scroll.ScrollBarThickness = 8
            scroll.CanvasSize = UDim2.new(0,0,0,0)

            local layout = Instance.new("UIListLayout", scroll)
            layout.Padding = UDim.new(0,5)
            layout.SortOrder = Enum.SortOrder.LayoutOrder

            local results = searchForDayObjects()
            if #results == 0 then
                local noLabel = Instance.new("TextLabel", scroll)
                noLabel.Size = UDim2.new(1,0,0,30)
                noLabel.Text = "❌ Keine Day/Tag Objekte gefunden."
                noLabel.TextColor3 = Color3.fromRGB(255,200,200)
                noLabel.BackgroundTransparency = 1
                noLabel.Font = Enum.Font.Gotham
                noLabel.TextScaled = true
            else
                for _, obj in ipairs(results) do
                    local container = Instance.new("Frame", scroll)
                    container.Size = UDim2.new(1,-10,0,25)
                    container.BackgroundTransparency = 1

                    local objLabel = Instance.new("TextLabel", container)
                    objLabel.Size = UDim2.new(0.6,0,1,0)
                    objLabel.Position = UDim2.new(0,0,0,0)
                    objLabel.Text = obj:GetFullName()
                    objLabel.TextColor3 = Color3.fromRGB(255,255,255)
                    objLabel.Font = Enum.Font.Code
                    objLabel.TextSize = 12
                    objLabel.BackgroundTransparency = 1
                    objLabel.TextXAlignment = Enum.TextXAlignment.Left

                    local input = Instance.new("TextBox", container)
                    input.Size = UDim2.new(0,60,1,0)
                    input.Position = UDim2.new(0.65,0,0,0)
                    input.PlaceholderText = "50"
                    input.Text = ""
                    input.TextSize = 12
                    input.Font = Enum.Font.Gotham
                    input.BackgroundColor3 = Color3.fromRGB(70,65,130)
                    input.TextColor3 = Color3.fromRGB(255,255,255)

                    local setBtn = Instance.new("TextButton", container)
                    setBtn.Size = UDim2.new(0,60,1,0)
                    setBtn.Position = UDim2.new(0.8,0,0,0)
                    setBtn.Text = "Setzen"
                    setBtn.BackgroundColor3 = Color3.fromRGB(90,70,150)
                    setBtn.TextColor3 = Color3.fromRGB(255,255,255)
                    setBtn.Font = Enum.Font.GothamBold
                    setBtn.TextSize = 12

                    setBtn.MouseButton1Click:Connect(function()
                        local val = tonumber(input.Text)
                        if not val then return end

                        if obj:IsA("IntValue") or obj:IsA("NumberValue") then
                            obj.Value = val
                            print("✅ DayValue geändert:", obj:GetFullName(), val)
                        elseif obj:IsA("StringValue") then
                            obj.Value = tostring(val)
                            print("✅ StringValue geändert:", obj:GetFullName(), val)
                        elseif obj:IsA("TextLabel") or obj:IsA("TextButton") then
                            obj.Text = "Day " .. tostring(val)
                            print("✅ GUI-Text geändert:", obj:GetFullName(), obj.Text)
                        else
                            warn("⚠️ Kann Objekt nicht ändern:", obj.ClassName)
                        end
                    end)
                end
                scroll.CanvasSize = UDim2.new(0,0,0,#results * 30)
            end
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

            local function bringFiltered(keyword)
                for _, obj in pairs(workspace:GetDescendants()) do
                    local name = obj.Name:lower()
                    if (keyword == "log" and name:find("log")) 
                    or (keyword == "scrap" and name:find("scrap")) then
                        if obj:IsA("BasePart") and obj.Size.Magnitude < 8 then
                            obj.CFrame = root.CFrame + Vector3.new(5, spawnY, 0)
                            obj.Anchored = false
                        elseif obj:IsA("Model") and obj.PrimaryPart and obj:GetExtentsSize().Magnitude < 8 then
                            obj:PivotTo(root.CFrame + Vector3.new(5, spawnY, 0))
                        end
                    end
                end
            end

            local logsBtn = Instance.new("TextButton", contentFrame)
            logsBtn.Size = UDim2.new(0,200,0,50)
            logsBtn.Position = UDim2.new(0,20,0,80)
            logsBtn.Text = "Bring Logs"
            logsBtn.BackgroundColor3 = Color3.fromRGB(70,65,130)
            logsBtn.TextColor3 = Color3.fromRGB(255,255,255)
            logsBtn.MouseButton1Click:Connect(function() bringFiltered("log") end)

            local scrapBtn = Instance.new("TextButton", contentFrame)
            scrapBtn.Size = UDim2.new(0,200,0,50)
            scrapBtn.Position = UDim2.new(0,20,0,140)
            scrapBtn.Text = "Bring Scrap"
            scrapBtn.BackgroundColor3 = Color3.fromRGB(70,65,130)
            scrapBtn.TextColor3 = Color3.fromRGB(255,255,255)
            scrapBtn.MouseButton1Click:Connect(function() bringFiltered("scrap") end)
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

            local sliderBack = Instance.new("Frame", contentFrame)
            sliderBack.Size = UDim2.new(0,300,0,10)
            sliderBack.Position = UDim2.new(0,20,0,100)
            sliderBack.BackgroundColor3 = Color3.fromRGB(80,80,150)

            local slider = Instance.new("Frame", sliderBack)
            slider.Size = UDim2.new(0,20,0,20)
            slider.Position = UDim2.new(0,0,-0.5,0)
            slider.BackgroundColor3 = Color3.fromRGB(255,255,255)

            local dragging = false
            slider.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true end
            end)
            slider.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
            end)
            UserInputService.InputChanged:Connect(function(input)
                if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                    local rel = math.clamp((input.Position.X - sliderBack.AbsolutePosition.X)/sliderBack.AbsoluteSize.X,0,1)
                    slider.Position = UDim2.new(rel,-10,-0.5,0)
                    local speed = 16 + math.floor(rel*100)
                    if player.Character and player.Character:FindFirstChildOfClass("Humanoid") then
                        player.Character:FindFirstChildOfClass("Humanoid").WalkSpeed = speed
                    end
                end
            end)
        end
    end)
end
