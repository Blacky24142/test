-- Roblox GUI ähnlich Discord Style (Voidware Style) komplett + ChestFarm + CurrencyCheck + Diamonds Debug

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
local tabs = {"Main","Help","Teleport","Bring Stuff","Local","ChestFarm","CurrencyCheck","Diamonds Debug"}

local function clearContent()
    for _, child in ipairs(contentFrame:GetChildren()) do
        if not child:IsA("UIListLayout") then
            child:Destroy()
        end
    end
end

-- Suche Currency
local function searchForCurrency()
    local results = {}
    local keywords = {"coin","coins","gold","money","cash","gems","gem","diamond","diamonds"}
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

-- Suche Diamond RemoteEvents
local function searchDiamondRemotes()
    local results = {}
    for _, obj in ipairs(game.ReplicatedStorage:GetDescendants()) do
        local name = obj.Name:lower()
        if name:find("diamond") or name:find("gem") then
            if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
                table.insert(results, obj)
            end
        end
    end
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

        -- 💎 CURRENCYCHECK
        if tabName == "CurrencyCheck" then
            local label = Instance.new("TextLabel", contentFrame)
            label.Size = UDim2.new(1,0,0,40)
            label.Text = "Gefundene Currency Objekte"
            label.TextColor3 = Color3.fromRGB(255,255,255)
            label.BackgroundTransparency = 1
            label.Font = Enum.Font.GothamBold
            label.TextScaled = true

            local scroll = Instance.new("ScrollingFrame", contentFrame)
            scroll.Size = UDim2.new(1,-20,0,350)
            scroll.Position = UDim2.new(0,10,0,50)
            scroll.BackgroundTransparency = 1
            scroll.BorderSizePixel = 0
            scroll.ScrollBarThickness = 8
            scroll.CanvasSize = UDim2.new(0,0,0,0)

            local layout = Instance.new("UIListLayout", scroll)
            layout.Padding = UDim.new(0,5)
            layout.SortOrder = Enum.SortOrder.LayoutOrder

            local results = searchForCurrency()
            local collectedText = {}

            if #results == 0 then
                local noLabel = Instance.new("TextLabel", scroll)
                noLabel.Size = UDim2.new(1,0,0,30)
                noLabel.Text = "❌ Keine Currency Objekte gefunden."
                noLabel.TextColor3 = Color3.fromRGB(255,200,200)
                noLabel.BackgroundTransparency = 1
                noLabel.Font = Enum.Font.Gotham
                noLabel.TextScaled = true
            else
                for _, obj in ipairs(results) do
                    local line = Instance.new("TextLabel", scroll)
                    line.Size = UDim2.new(1,0,0,25)
                    line.Text = obj:GetFullName() .. " [" .. obj.ClassName .. "]"
                    line.TextColor3 = Color3.fromRGB(200,255,200)
                    line.BackgroundTransparency = 1
                    line.Font = Enum.Font.Code
                    line.TextSize = 14
                    line.TextXAlignment = Enum.TextXAlignment.Left
                    table.insert(collectedText, line.Text)
                end
                scroll.CanvasSize = UDim2.new(0,0,0,#results * 30)
            end

            local copyBtn = Instance.new("TextButton", contentFrame)
            copyBtn.Size = UDim2.new(0,200,0,40)
            copyBtn.Position = UDim2.new(0,20,0,420)
            copyBtn.Text = "Alles kopieren"
            copyBtn.BackgroundColor3 = Color3.fromRGB(80,120,180)
            copyBtn.TextColor3 = Color3.fromRGB(255,255,255)
            copyBtn.Font = Enum.Font.GothamBold
            copyBtn.TextScaled = true
            copyBtn.MouseButton1Click:Connect(function()
                if #collectedText > 0 then
                    local output = table.concat(collectedText, "\n")
                    if setclipboard then
                        setclipboard(output)
                        print("📋 Currency Objekte in Zwischenablage kopiert.")
                    else
                        warn("⚠️ Dein Executor unterstützt setclipboard nicht.")
                    end
                else
                    warn("Keine Daten zum Kopieren gefunden.")
                end
            end)
        end

        -- 💎 DIAMONDS DEBUG
        if tabName == "Diamonds Debug" then
            local label = Instance.new("TextLabel", contentFrame)
            label.Size = UDim2.new(1,0,0,40)
            label.Text = "Diamond RemoteEvents / Functions"
            label.TextColor3 = Color3.fromRGB(255,255,255)
            label.BackgroundTransparency = 1
            label.Font = Enum.Font.GothamBold
            label.TextScaled = true

            local scroll = Instance.new("ScrollingFrame", contentFrame)
            scroll.Size = UDim2.new(1,-20,1,-50)
            scroll.Position = UDim2.new(0,10,0,50)
            scroll.BackgroundTransparency = 1
            scroll.ScrollBarThickness = 8
            scroll.CanvasSize = UDim2.new(0,0,0,0)

            local layout = Instance.new("UIListLayout", scroll)
            layout.Padding = UDim.new(0,5)
            layout.SortOrder = Enum.SortOrder.LayoutOrder

            local remotes = searchDiamondRemotes()
            if #remotes == 0 then
                local noLabel = Instance.new("TextLabel", scroll)
                noLabel.Size = UDim2.new(1,0,0,30)
                noLabel.Text = "❌ Keine Diamond Remotes gefunden."
                noLabel.TextColor3 = Color3.fromRGB(255,200,200)
                noLabel.BackgroundTransparency = 1
                noLabel.Font = Enum.Font.Gotham
                noLabel.TextScaled = true
            else
                for _, remote in ipairs(remotes) do
                    local container = Instance.new("Frame", scroll)
                    container.Size = UDim2.new(1,-10,0,30)
                    container.BackgroundTransparency = 1

                    local objLabel = Instance.new("TextLabel", container)
                    objLabel.Size = UDim2.new(0.5,0,1,0)
                    objLabel.Text = remote:GetFullName()
                    objLabel.TextColor3 = Color3.fromRGB(255,255,255)
                    objLabel.Font = Enum.Font.Code
                    objLabel.TextSize = 12
                    objLabel.BackgroundTransparency = 1
                    objLabel.TextXAlignment = Enum.TextXAlignment.Left

                    local input = Instance.new("TextBox", container)
                    input.Size = UDim2.new(0,60,1,0)
                    input.Position = UDim2.new(0.55,0,0,0)
                    input.PlaceholderText = "10"
                    input.Text = ""
                    input.TextSize = 12
                    input.Font = Enum.Font.Gotham
                    input.BackgroundColor3 = Color3.fromRGB(70,65,130)
                    input.TextColor3 = Color3.fromRGB(255,255,255)

                    local fireBtn = Instance.new("TextButton", container)
                    fireBtn.Size = UDim2.new(0,80,1,0)
                    fireBtn.Position = UDim2.new(0.7,0,0,0)
                    fireBtn.Text = "FireServer"
                    fireBtn.BackgroundColor3 = Color3.fromRGB(100,80,160)
                    fireBtn.TextColor3 = Color3.fromRGB(255,255,255)
                    fireBtn.Font = Enum.Font.GothamBold
                    fireBtn.TextSize = 12

                    fireBtn.MouseButton1Click:Connect(function()
                        local amount = tonumber(input.Text) or 10
                        if remote:IsA("RemoteEvent") then
                            remote:FireServer(amount)
                            print("🔥 FireServer:", remote:GetFullName(), amount)
                        elseif remote:IsA("RemoteFunction") then
                            local result = remote:InvokeServer(amount)
                            print("📡 InvokeServer:", remote:GetFullName(), amount, "->", result)
                        end
                    end)
                end
                scroll.CanvasSize = UDim2.new(0,0,0,#remotes * 35)
            end
        end
    end)
end
