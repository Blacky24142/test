--[[
  Voidware Luminous — Admin-Edition (Server + Client)
  ⚠️ Sicher & fair: Dieses Admin-Panel ist für DEINE eigenen Experiences gedacht
     und führt alle Aktionen server-seitig nur nach Rechte-Check aus.

  Features (in Kategorien organisiert):
  • Local: Fly (F), Speed-Slider, JumpPower-Slider, Theme Toggle
  • Players/TP: Teleport zu Spieler, Bring (self → target / target → self)
  • ESP: Spieler-Highlights (nur lokal sichtbar für Admins)
  • Utility: Noclip (lokal), Freecam (lokal), Reset WS/JP
  • Server: Rejoin, Shutdown (nur Place-Owner), Broadcast-Message

  Struktur:
  - ServerScriptService/AdminServer.server.lua  (SERVER)
  - StarterPlayerScripts/AdminClient.client.lua  (CLIENT)
  - ReplicatedStorage/AdminRemotes (Ordner + Remotes)
]]

----------------------------------------------------------------
-- ReplicatedStorage Setup (einmalig in Studio anlegen oder per Code)
----------------------------------------------------------------
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local RemotesFolder = ReplicatedStorage:FindFirstChild("AdminRemotes") or Instance.new("Folder")
RemotesFolder.Name = "AdminRemotes"
RemotesFolder.Parent = ReplicatedStorage

local AdminAuth = RemotesFolder:FindFirstChild("AdminAuth") or Instance.new("RemoteEvent")
AdminAuth.Name = "AdminAuth"; AdminAuth.Parent = RemotesFolder

local AdminAction = RemotesFolder:FindFirstChild("AdminAction") or Instance.new("RemoteFunction")
AdminAction.Name = "AdminAction"; AdminAction.Parent = RemotesFolder

local AdminGetPlayers = RemotesFolder:FindFirstChild("AdminGetPlayers") or Instance.new("RemoteFunction")
AdminGetPlayers.Name = "AdminGetPlayers"; AdminGetPlayers.Parent = RemotesFolder

----------------------------------------------------------------
-- ServerScriptService/AdminServer.server.lua
----------------------------------------------------------------
if script.Name ~= "AdminServer.server.lua" then script.Name = "AdminServer.server.lua" end

local ServerStorage = game:GetService("ServerStorage")
local TeleportService = game:GetService("TeleportService")

-- Admin-Konfig (anpassen):
local AdminConfig = {
	-- Erlaubte UserIds
	admins = {
		[1234567890] = true, -- Beispiel
	},
	-- Oder Gruppenrechte (optional)
	groupId = 0,
	minGroupRank = 255,
}

local function isAdmin(player)
	if AdminConfig.admins[player.UserId] then return true end
	if AdminConfig.groupId ~= 0 then
		local ok, rank = pcall(function()
			return player:GetRankInGroup(AdminConfig.groupId)
		end)
		if ok and rank >= AdminConfig.minGroupRank then return true end
	end
	return game.CreatorId == player.UserId -- Place-Owner darf immer
end

-- Signal an Admin-Clients, damit UI erscheint
Players.PlayerAdded:Connect(function(plr)
	if isAdmin(plr) then
		AdminAuth:FireClient(plr, true)
	end
end)

-- Hilfen
local function safeChar(plr)
	return plr.Character or plr.CharacterAdded:Wait()
end

-- Zentrale Action-Dispatch
AdminAction.OnServerInvoke = function(caller, action, payload)
	if not isAdmin(caller) then return {ok=false, err="no-permission"} end
	local ok, msg = pcall(function()
		if action == "set-stats" then
			local t = payload and Players:FindFirstChild(payload.userName)
			if not t then error("player-not-found") end
			local hum = safeChar(t):FindFirstChildOfClass("Humanoid")
			if not hum then error("no-humanoid") end
			hum.WalkSpeed = tonumber(payload.ws) or hum.WalkSpeed
			hum.JumpPower = tonumber(payload.jp) or hum.JumpPower
			return true

		elseif action == "tp-to" then
			local target = payload and Players:FindFirstChild(payload.toName)
			if not target then error("player-not-found") end
			local cFrom = safeChar(caller):FindFirstChild("HumanoidRootPart")
			local cTo = safeChar(target):FindFirstChild("HumanoidRootPart")
			if cFrom and cTo then cFrom.CFrame = cTo.CFrame + cTo.CFrame.LookVector * 2 end
			return true

		elseif action == "bring" then
			local target = payload and Players:FindFirstChild(payload.userName)
			if not target then error("player-not-found") end
			local adminHRP = safeChar(caller):FindFirstChild("HumanoidRootPart")
			local tHRP = safeChar(target):FindFirstChild("HumanoidRootPart")
			if adminHRP and tHRP then tHRP.CFrame = adminHRP.CFrame + adminHRP.CFrame.LookVector * 2 end
			return true

		elseif action == "broadcast" then
			local text = tostring(payload and payload.text or "")
			for _,p in ipairs(Players:GetPlayers()) do
				pcall(function()
					p:SendNotification({Title = "ADMIN", Text = text, Duration = 5})
				end)
			end
			return true

		elseif action == "rejoin" then
			TeleportService:Teleport(game.PlaceId, caller)
			return true

		elseif action == "shutdown" then
			if game.CreatorId ~= caller.UserId then error("only-owner") end
			for _,p in ipairs(Players:GetPlayers()) do
				pcall(function()
					p:Kick("Server is shutting down by owner.")
				end)
			end
			return true
		end
		error("unknown-action")
	end)
	return ok and {ok=true} or {ok=false, err=msg}
end

-- Liste der Spieler
AdminGetPlayers.OnServerInvoke = function(caller)
	if not isAdmin(caller) then return {} end
	local list = {}
	for _,p in ipairs(Players:GetPlayers()) do
		table.insert(list, {name=p.Name, userId=p.UserId})
	end
	return list
end

----------------------------------------------------------------
-- StarterPlayerScripts/AdminClient.client.lua
----------------------------------------------------------------
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local StarterGui = game:GetService("StarterGui")

local player = Players.LocalPlayer

-- Utils
local function create(class, props, parent)
	local o = Instance.new(class)
	if props then for k,v in pairs(props) do o[k]=v end end
	if parent then o.Parent = parent end
	return o
end
local function notify(msg)
	pcall(function()
		StarterGui:SetCore("SendNotification", {Title = "Voidware", Text = msg, Duration = 3})
	end)
end

-- Thema
local Theme = {
	Light = {
		bg = Color3.fromRGB(245, 240, 255), card = Color3.fromRGB(234, 226, 255),
		accent = Color3.fromRGB(155, 120, 255), text = Color3.fromRGB(35,25,60), sub = Color3.fromRGB(90,75,140)
	},
	Dark = {
		bg = Color3.fromRGB(34, 28, 60), card = Color3.fromRGB(46, 38, 85),
		accent = Color3.fromRGB(170, 140, 255), text = Color3.fromRGB(240,235,255), sub = Color3.fromRGB(190,185,235)
	}
}
local themeKey = "Light"
local function C(k) return Theme[themeKey][k] end

-- Blur
for _,e in ipairs(Lighting:GetChildren()) do if e:IsA("BlurEffect") and e.Name=="LuminousBlur" then e:Destroy() end end
local blur = create("BlurEffect", {Name="LuminousBlur", Size=8}, Lighting)

-- Root GUI (wird erst angezeigt, wenn AdminAuth kommt)
local screenGui = create("ScreenGui", {Name="VoidwareAdmin", ResetOnSpawn=false, Enabled=false, ZIndexBehavior=Enum.ZIndexBehavior.Global}, player:WaitForChild("PlayerGui"))

-- Fenster
local main = create("Frame", {Size=UDim2.fromOffset(920,560), Position=UDim2.new(0.5,-460,0.5,-280), BackgroundColor3=C("bg"), BackgroundTransparency=0.06}, screenGui)
create("UICorner", {CornerRadius=UDim.new(0,18)}, main)
create("UIStroke", {Thickness=2, ApplyStrokeMode=Enum.ApplyStrokeMode.Border, Color=Theme.Dark.accent}, main)

-- Header (draggable)
local header = create("Frame", {Size=UDim2.new(1,0,0,60), BackgroundColor3=C("card")}, main)
create("UICorner", {CornerRadius=UDim.new(0,16)}, header)
local title = create("TextLabel", {Size=UDim2.new(1,-180,1,0), Position=UDim2.new(0,18,0,0), Text="Voidware • Admin", Font=Enum.Font.GothamBold, TextScaled=true, TextXAlignment=Enum.TextXAlignment.Left, TextColor3=C("text"), BackgroundTransparency=1}, header)

local themeBtn = create("TextButton", {Size=UDim2.new(0,44,0,44), Position=UDim2.new(1,-60,0.5,-22), BackgroundTransparency=0.9, Text=""}, header)
local function applyTheme()
	main.BackgroundColor3 = C("bg")
	header.BackgroundColor3 = C("card")
	title.TextColor3 = C("text")
end

themeBtn.MouseButton1Click:Connect(function()
	themeKey = (themeKey == "Light") and "Dark" or "Light"
	applyTheme()
end)
applyTheme()

-- Drag
local dragging=false; local dragStart; local startPos
header.InputBegan:Connect(function(input)
	if input.UserInputType==Enum.UserInputType.MouseButton1 then dragging=true; dragStart=input.Position; startPos=main.Position end
end)
UserInputService.InputChanged:Connect(function(input)
	if dragging and input.UserInputType==Enum.UserInputType.MouseMovement then
		local d = input.Position - dragStart
		main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset+d.X, startPos.Y.Scale, startPos.Y.Offset+d.Y)
	end
end)
header.InputEnded:Connect(function(input) if input.UserInputState==Enum.UserInputState.End then dragging=false end end)

-- Sidebar Tabs
local sidebar = create("Frame", {Size=UDim2.new(0,210,1,-68), Position=UDim2.new(0,0,0,68), BackgroundColor3=C("card")}, main)
create("UICorner", {CornerRadius=UDim.new(0,12)}, sidebar)
local tabs = {"Main","Local","Players/TP","ESP","Utility","Server","Help"}
local tabButtons = {}
local function makeTab(name, i)
	local b = create("TextButton", {Size=UDim2.new(1,0,0,44), Position=UDim2.new(0,0,0,(i-1)*48), Text=name, Font=Enum.Font.GothamBold, TextScaled=true, TextColor3=C("text"), BackgroundColor3=Theme.Light.card, AutoButtonColor=false, Parent=sidebar})
	create("UICorner", {CornerRadius=UDim.new(0,10)}, b)
	tabButtons[name]=b
	return b
end
for i,n in ipairs(tabs) do makeTab(n,i) end

local content = create("Frame", {Size=UDim2.new(1,-220,1,-68), Position=UDim2.new(0,220,0,68), BackgroundColor3=C("card")}, main)
create("UICorner", {CornerRadius=UDim.new(0,12)}, content)

local function clearContent()
	for _,c in ipairs(content:GetChildren()) do if not c:IsA("UIListLayout") then c:Destroy() end end
end

-- Helpers
local function section(text, y)
	return create("TextLabel", {Size=UDim2.new(1,-24,0,42), Position=UDim2.new(0,12,0,y or 12), Text=text, Font=Enum.Font.GothamBold, TextScaled=true, TextColor3=C("text"), BackgroundTransparency=1, Parent=content})
end
local function label(text, pos, size)
	return create("TextLabel", {Size=size or UDim2.new(0,260,0,26), Position=pos or UDim2.new(0,12,0,60), Text=text, Font=Enum.Font.Gotham, TextScaled=true, TextColor3=Theme.Dark.sub, BackgroundTransparency=1, Parent=content})
end
local function button(txt, pos, size, cb)
	local b = create("TextButton", {Size=size or UDim2.new(0,150,0,36), Position=pos or UDim2.new(0,12,0,60), Text=txt, Font=Enum.Font.GothamBold, TextScaled=true, TextColor3=Color3.new(1,1,1), BackgroundColor3=Theme.Dark.accent, AutoButtonColor=false, Parent=content})
	create("UICorner", {CornerRadius=UDim.new(0,10)}, b)
	create("UIStroke", {Thickness=1, Color=Color3.fromRGB(255,255,255), Transparency=0.7}, b)
	b.MouseButton1Click:Connect(function() if cb then cb(b) end end)
	return b
end
local function slider(titleText, min, max, getVal, setVal, y)
	label(titleText, UDim2.new(0,12,0,(y or 0)))
	local container = create("Frame", {Size=UDim2.new(0,320,0,10), Position=UDim2.new(0,12,0,(y or 0)+26), BackgroundColor3=Color3.fromRGB(220,215,255), Parent=content})
	create("UICorner", {CornerRadius=UDim.new(0,5)}, container)
	local fill = create("Frame", {Size=UDim2.new((getVal()-min)/(max-min),0,1,0), BackgroundColor3=Theme.Dark.accent, Parent=container})
	create("UICorner", {CornerRadius=UDim.new(0,5)}, fill)
	local valueLbl = label(tostring(getVal()), UDim2.new(0,340,0,(y or 0)+14), UDim2.new(0,80,0,22))
	local dragging=false
	container.InputBegan:Connect(function(io) if io.UserInputType==Enum.UserInputType.MouseButton1 then dragging=true end end)
	container.InputEnded:Connect(function(io) if io.UserInputType==Enum.UserInputType.MouseButton1 then dragging=false end end)
	UserInputService.InputChanged:Connect(function(io)
		if dragging and io.UserInputType==Enum.UserInputType.MouseMovement then
			local rel = math.clamp((io.Position.X - container.AbsolutePosition.X)/container.AbsoluteSize.X, 0, 1)
			local v = math.floor(min + rel*(max-min))
			fill.Size = UDim2.new(rel,0,1,0)
			setVal(v)
			valueLbl.Text = tostring(v)
		end
	end)
end

----------------------------------------------------------------
-- Admin Gate: UI nur für Admins aktivieren
----------------------------------------------------------------
local authed = false
AdminAuth.OnClientEvent:Connect(function(state)
	authed = state == true
	screenGui.Enabled = authed
	notify(authed and "Admin freigeschaltet" or "Keine Admin-Rechte")
end)

----------------------------------------------------------------
-- Fly (lokal, aber nur nutzbar wenn authed)
----------------------------------------------------------------
local flying, flySpeed = false, 90
local bodyGyro, bodyVel
local flyConn
local function setFly(active)
	if not authed then return end
	local char = player.Character or player.CharacterAdded:Wait()
	local hrp = char:FindFirstChild("HumanoidRootPart")
	if not hrp then return end
	flying = active
	if active then
		bodyGyro = Instance.new("BodyGyro"); bodyGyro.MaxTorque=Vector3.new(1e9,1e9,1e9); bodyGyro.P=1e5; bodyGyro.CFrame=hrp.CFrame; bodyGyro.Parent=hrp
		bodyVel  = Instance.new("BodyVelocity"); bodyVel.MaxForce=Vector3.new(1e9,1e9,1e9); bodyVel.Velocity=Vector3.zero; bodyVel.Parent=hrp
		flyConn = RunService.RenderStepped:Connect(function()
			local cam = workspace.CurrentCamera
			local move = Vector3.zero
			if UserInputService:IsKeyDown(Enum.KeyCode.W) then move += cam.CFrame.LookVector end
			if UserInputService:IsKeyDown(Enum.KeyCode.S) then move -= cam.CFrame.LookVector end
			if UserInputService:IsKeyDown(Enum.KeyCode.A) then move -= cam.CFrame.RightVector end
			if UserInputService:IsKeyDown(Enum.KeyCode.D) then move += cam.CFrame.RightVector end
			if UserInputService:IsKeyDown(Enum.KeyCode.Space) then move += Vector3.new(0,1,0) end
			if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then move -= Vector3.new(0,1,0) end
			bodyGyro.CFrame = cam.CFrame
			bodyVel.Velocity = (move.Magnitude>0) and (move.Unit * flySpeed) or Vector3.zero
		end)
		notify("Fly an")
	else
		if flyConn then flyConn:Disconnect() end
		if bodyGyro then bodyGyro:Destroy() end
		if bodyVel then bodyVel:Destroy() end
		notify("Fly aus")
	end
end

UserInputService.InputBegan:Connect(function(input, gpe)
	if not gpe and input.KeyCode == Enum.KeyCode.F then setFly(not flying) end
end)

----------------------------------------------------------------
-- TAB: Main
----------------------------------------------------------------
local function openMain()
	clearContent()
	section("✨ Willkommen — Voidware Admin", 16)
	label("RightShift: GUI an/aus  •  F: Fly  •  Theme: Button oben rechts", UDim2.new(0,12,0,60))
	label("Tabs: Local, Players/TP, ESP, Utility, Server", UDim2.new(0,12,0,90))
end

----------------------------------------------------------------
-- TAB: Local (Fly, Speed, Jump)
----------------------------------------------------------------
local function openLocal()
	clearContent()
	section("🕊️ Local", 16)
	label("F: Fly Toggle • Space/Shift: Hoch/Runter", UDim2.new(0,12,0,54))
	slider("Fly Speed", 10, 300, function() return flySpeed end, function(v) flySpeed=v end, 88)
	local hum = (player.Character or player.CharacterAdded:Wait()):WaitForChild("Humanoid")
	slider("WalkSpeed", 8, 200, function() return hum.WalkSpeed end, function(v)
		AdminAction:InvokeServer("set-stats", {userName=player.Name, ws=v, jp=hum.JumpPower})
	end, 140)
	slider("JumpPower", 10, 200, function() return hum.JumpPower end, function(v)
		AdminAction:InvokeServer("set-stats", {userName=player.Name, ws=hum.WalkSpeed, jp=v})
	end, 200)
	button(flying and "Fly AUS" or "Fly AN", UDim2.new(0,12,0,250), UDim2.new(0,140,0,36), function(b)
		setFly(not flying); b.Text = flying and "Fly AUS" or "Fly AN"
	end)
end

----------------------------------------------------------------
-- TAB: Players/TP
----------------------------------------------------------------
local function openPlayers()
	clearContent()
	section("🧍 Players & Teleport", 16)
	local scroll = create("ScrollingFrame", {Size=UDim2.new(1,-24,1,-110), Position=UDim2.new(0,12,0,58), CanvasSize=UDim2.new(0,0,0,0), ScrollBarThickness=6, BackgroundTransparency=1, Parent=content})
	local y=0
	local list = AdminGetPlayers:InvokeServer()
	for _,item in ipairs(list) do
		local row = create("Frame", {Size=UDim2.new(1,-10,0,40), Position=UDim2.new(0,5,0,y), BackgroundColor3=Color3.fromRGB(226,220,255), Parent=scroll})
		create("UICorner", {CornerRadius=UDim.new(0,8)}, row)
		local nameLbl = create("TextLabel", {Size=UDim2.new(0.6,0,1,0), Position=UDim2.new(0,10,0,0), BackgroundTransparency=1, Text=item.name, TextScaled=true, Font=Enum.Font.Gotham, TextColor3=C("text")}, row)
		button("TP →", UDim2.new(1,-180,0,4), UDim2.new(0,80,0,32), function()
			AdminAction:InvokeServer("tp-to", {toName=item.name})
		end).Parent = row
		button("Bring", UDim2.new(1,-90,0,4), UDim2.new(0,80,0,32), function()
			AdminAction:InvokeServer("bring", {userName=item.name})
		end).Parent = row
		y = y + 44
		scroll.CanvasSize = UDim2.new(0,0,0,y+8)
	end
	button("Refresh", UDim2.new(1,-132,0,16), UDim2.new(0,120,0,32), function() openPlayers() end)
end

----------------------------------------------------------------
-- TAB: ESP (lokal sichtbar)
----------------------------------------------------------------
local espEnabled=false
local espMap={}
local function setESPFor(plr, on)
	if on then
		if espMap[plr] and espMap[plr].Parent then return end
		local char = plr.Character or plr.CharacterAdded:Wait()
		local hl = Instance.new("Highlight")
		hl.FillTransparency = 0.7; hl.OutlineTransparency=0.15
		hl.FillColor = Theme.Dark.accent; hl.OutlineColor = Color3.new(1,1,1)
		hl.Parent = char
		espMap[plr]=hl
	else
		if espMap[plr] then espMap[plr]:Destroy(); espMap[plr]=nil end
	end
end

local function openESP()
	clearContent()
	section("🎯 ESP", 16)
	button(espEnabled and "Master: ON" or "Master: OFF", UDim2.new(0,12,0,60), UDim2.new(0,170,0,36), function(b)
		espEnabled = not espEnabled
		for _,plr in ipairs(Players:GetPlayers()) do if plr~=player then setESPFor(plr, espEnabled) end end
		b.Text = espEnabled and "Master: ON" or "Master: OFF"
	end)
	local scroll = create("ScrollingFrame", {Size=UDim2.new(1,-24,1,-112), Position=UDim2.new(0,12,0,100), CanvasSize=UDim2.new(0,0,0,0), ScrollBarThickness=6, BackgroundTransparency=1, Parent=content})
	local y=0
	for _,plr in ipairs(Players:GetPlayers()) do if plr~=player then
		local row = create("Frame", {Size=UDim2.new(1,-10,0,36), Position=UDim2.new(0,5,0,y), BackgroundColor3=Color3.fromRGB(226,220,255), Parent=scroll})
		create("UICorner", {CornerRadius=UDim.new(0,8)}, row)
		create("TextLabel", {Size=UDim2.new(0.6,0,1,0), Position=UDim2.new(0,10,0,0), BackgroundTransparency=1, Text=plr.Name, TextScaled=true, Font=Enum.Font.Gotham, TextColor3=C("text")}, row)
		button(espMap[plr] and "ON" or "OFF", UDim2.new(1,-120,0,3), UDim2.new(0,110,0,30), function(btn)
			local turnOn = not espMap[plr]
			setESPFor(plr, turnOn)
			btn.Text = turnOn and "ON" or "OFF"
		end).Parent = row
		y=y+40
	end end
	scroll.CanvasSize = UDim2.new(0,0,0,y+8)
end

----------------------------------------------------------------
-- TAB: Utility (lokale Tools)
----------------------------------------------------------------
local noclip=false; local noclipConn
local function setNoclip(on)
	noclip=on
	if on then
		if noclipConn then noclipConn:Disconnect() end
		noclipConn = RunService.Stepped:Connect(function()
			local char = player.Character
			if char then for _,p in ipairs(char:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide=false end end end
		end)
		notify("Noclip an")
	else
		if noclipConn then noclipConn:Disconnect() end
		notify("Noclip aus")
	end
end

local freecam=false; local camConn, rotX, rotY, camPos
local function setFreecam(on)
	freecam=on
	local cam = workspace.CurrentCamera
	if on then
		cam.CameraType = Enum.CameraType.Scriptable
		camPos = cam.CFrame.Position; rotX, rotY = 0,0
		local moveSpeed = 1.6
		camConn = RunService.RenderStepped:Connect(function(dt)
			local delta = UserInputService:GetMouseDelta()
			rotX = math.clamp(rotX - delta.Y*0.002, -1.55, 1.55)
			rotY = rotY - delta.X*0.002
			local cf = CFrame.new(camPos) * CFrame.Angles(0, rotY, 0) * CFrame.Angles(rotX, 0, 0)
			local mv = Vector3.zero
			if UserInputService:IsKeyDown(Enum.KeyCode.W) then mv += cf.LookVector end
			if UserInputService:IsKeyDown(Enum.KeyCode.S) then mv -= cf.LookVector end
			if UserInputService:IsKeyDown(Enum.KeyCode.A) then mv -= cf.RightVector end
			if UserInputService:IsKeyDown(Enum.KeyCode.D) then mv += cf.RightVector end
			if UserInputService:IsKeyDown(Enum.KeyCode.Space) then mv += Vector3.new(0,1,0) end
			if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then mv -= Vector3.new(0,1,0) end
			camPos += mv * (60*dt) * moveSpeed
			cam.CFrame = CFrame.new(camPos) * CFrame.Angles(0, rotY, 0) * CFrame.Angles(rotX, 0, 0)
		end)
		notify("Freecam an")
	else
		if camConn then camConn:Disconnect() end
		workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
		notify("Freecam aus")
	end
end

local function openUtility()
	clearContent()
	section("⚡ Utility", 16)
	local hum = (player.Character or player.CharacterAdded:Wait()):WaitForChild("Humanoid")
	button(noclip and "Noclip AUS" or "Noclip AN", UDim2.new(0,12,0,62), UDim2.new(0,160,0,36), function(b) setNoclip(not noclip); b.Text = noclip and "Noclip AUS" or "Noclip AN" end)
	button(freecam and "Freecam AUS" or "Freecam AN", UDim2.new(0,192,0,62), UDim2.new(0,170,0,36), function(b) setFreecam(not freecam); b.Text = freecam and "Freecam AUS" or "Freecam AN" end)
	button("Reset WS/JP", UDim2.new(0,372,0,62), UDim2.new(0,160,0,36), function()
		AdminAction:InvokeServer("set-stats", {userName=player.Name, ws=16, jp=50})
		notify("Zurückgesetzt")
	end)
end

----------------------------------------------------------------
-- TAB: Server (Owner Tools)
----------------------------------------------------------------
local function openServer()
	clearContent()
	section("🛡️ Server", 16)
	local msgBox = create("TextBox", {Size=UDim2.new(0,360,0,34), Position=UDim2.new(0,12,0,60), PlaceholderText="Broadcast-Message", Text="", Font=Enum.Font.Gotham, TextSize=16, BackgroundColor3=Color3.fromRGB(225,220,255), TextColor3=Theme.Dark.text, Parent=content})
	create("UICorner", {CornerRadius=UDim.new(0,8)}, msgBox)
	button("Broadcast", UDim2.new(0,384,0,60), UDim2.new(0,140,0,34), function()
		AdminAction:InvokeServer("broadcast", {text = msgBox.Text})
	end)
	button("Rejoin", UDim2.new(0,12,0,108), UDim2.new(0,140,0,34), function() AdminAction:InvokeServer("rejoin") end)
	button("Shutdown (Owner)", UDim2.new(0,164,0,108), UDim2.new(0,180,0,34), function() AdminAction:InvokeServer("shutdown") end)
end

----------------------------------------------------------------
-- TAB: Help
----------------------------------------------------------------
local function openHelp()
	clearContent()
	section("❓ Hilfe & Shortcuts", 16)
	label("RightShift: GUI ein/aus", UDim2.new(0,12,0,58))
	label("F: Fly • Space/Shift: Hoch/Runter", UDim2.new(0,12,0,88))
	label("Tabs: Local, Players/TP, ESP, Utility, Server", UDim2.new(0,12,0,118))
end

-- Tab Routing
local routes = {
	["Main"] = openMain,
	["Local"] = openLocal,
	["Players/TP"] = openPlayers,
	["ESP"] = openESP,
	["Utility"] = openUtility,
	["Server"] = openServer,
	["Help"] = openHelp,
}
for name,btn in pairs(tabButtons) do
	btn.MouseButton1Click:Connect(function() (routes[name] or openMain)() end)
end

-- Default Tab
openMain()

-- HUD (FPS + Uhr)
local hud = create("TextLabel", {Size=UDim2.new(0,260,0,28), Position=UDim2.new(1,-280,1,-34), Text="--", TextColor3=Theme.Dark.sub, BackgroundTransparency=1, Font=Enum.Font.GothamBold, TextScaled=true, Parent=screenGui})
local last=tick(); local frames=0
RunService.RenderStepped:Connect(function()
	frames += 1
	if tick()-last>=1 then
		hud.Text = ("FPS: %d   •   %s"):format(frames, os.date("%H:%M:%S"))
		frames=0; last=tick()
	end
end)

print("✅ Voidware Luminous — Admin-Edition geladen.")
