--[[
    Blox Fruits PvP Hub - Mobile Friendly Version
    Version: 3.0 (ĐÃ SỬA LỖI - Bật là chạy)
]]

-- Khởi tạo Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoreGui = game:GetService("CoreGui")

-- Biến cơ bản
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Camera = workspace.CurrentCamera
local IsMobile = UserInputService.TouchEnabled

-- Kiểm tra game
local GameIds = {
    [2753915549] = "World1",
    [4442272183] = "World2",
    [7449423635] = "World3"
}

local CurrentWorld = GameIds[game.PlaceId]
if not CurrentWorld then
    LocalPlayer:Kick("❌ Script chỉ hỗ trợ Blox Fruits!")
    return
end

-- =============================================
-- BIẾN TOÀN CỤC CHO CÁC TÍNH NĂNG
-- =============================================

-- Settings
local Settings = {
    -- Aimbot
    AimbotEnabled = false,
    AimbotMethod = "Closest",
    TargetPlayer = nil,
    AimbotDistance = 300,
    IgnoreTeam = true,
    
    -- Soru
    InfSoruEnabled = false,
    
    -- V4
    AutoV4Enabled = false,
    V4Key = "Y",
    
    -- ESP
    ESPEnabled = false,
    ShowName = true,
    ShowDistance = true,
    ShowHealth = true,
    ShowBox = true,
    
    -- Anti Stun
    AntiStunEnabled = false,
    
    -- Visual
    ShowFPS = true,
    ShowPing = true,
    ShowTargetInfo = true,
    
    -- Mobile
    ShowMenuButton = true,
    ButtonSize = 50,
    ButtonPosition = "BottomRight",
    
    -- Colors
    TeamColor = Color3.fromRGB(0, 255, 0),
    EnemyColor = Color3.fromRGB(255, 0, 0),
    TargetColor = Color3.fromRGB(255, 255, 0)
}

-- Biến cho các tính năng
local ESPObjects = {}
local CurrentTarget = nil
local TargetInfo = {Name = "None", Distance = 0, Health = 0}
local FPS = 0; local FPSTime = 0; local FPSFrames = 0
local Ping = 0
local MenuVisible = false
local Gui = nil
local MenuButton = nil

-- =============================================
-- CÁC VÒNG LẶP CHÍNH CHO TỪNG TÍNH NĂNG
-- =============================================

-- ===== AIMBOT LOOP =====
spawn(function()
    while wait(0.016) do -- 60 FPS
        if Settings.AimbotEnabled then
            pcall(function()
                if not LocalPlayer.Character then return end
                
                -- Chọn mục tiêu
                if Settings.AimbotMethod == "Closest" then
                    local closest = nil
                    local shortestDist = Settings.AimbotDistance
                    
                    for _, player in ipairs(Players:GetPlayers()) do
                        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                            local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
                            if humanoid and humanoid.Health > 0 then
                                if Settings.IgnoreTeam and player.Team == LocalPlayer.Team then
                                    -- Bỏ qua đồng đội
                                else
                                    local dist = (LocalPlayer.Character.HumanoidRootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude
                                    if dist < shortestDist then
                                        shortestDist = dist
                                        closest = player
                                    end
                                end
                            end
                        end
                    end
                    
                    CurrentTarget = closest
                    
                elseif Settings.AimbotMethod == "Selected" and Settings.TargetPlayer then
                    if Settings.TargetPlayer.Character and Settings.TargetPlayer.Character:FindFirstChild("HumanoidRootPart") then
                        local humanoid = Settings.TargetPlayer.Character:FindFirstChildOfClass("Humanoid")
                        if humanoid and humanoid.Health > 0 then
                            if not (Settings.IgnoreTeam and Settings.TargetPlayer.Team == LocalPlayer.Team) then
                                CurrentTarget = Settings.TargetPlayer
                            else
                                CurrentTarget = nil
                            end
                        else
                            CurrentTarget = nil
                        end
                    else
                        CurrentTarget = nil
                    end
                end
                
                -- Aimbot camera
                if CurrentTarget and CurrentTarget.Character and CurrentTarget.Character:FindFirstChild("HumanoidRootPart") then
                    local targetRoot = CurrentTarget.Character.HumanoidRootPart
                    Camera.CFrame = CFrame.new(Camera.CFrame.Position, targetRoot.Position)
                    
                    -- Update target info
                    TargetInfo.Name = CurrentTarget.Name
                    TargetInfo.Distance = math.floor((LocalPlayer.Character.HumanoidRootPart.Position - targetRoot.Position).Magnitude)
                    TargetInfo.Health = math.floor(CurrentTarget.Character.Humanoid.Health)
                else
                    TargetInfo.Name = "None"
                    TargetInfo.Distance = 0
                    TargetInfo.Health = 0
                end
            end)
        end
    end
end)

-- ===== INF SORU LOOP =====
spawn(function()
    while wait(0.5) do
        if Settings.InfSoruEnabled and LocalPlayer.Character then
            pcall(function()
                local soru = LocalPlayer.Character:FindFirstChild("Soru")
                if soru then
                    soru.Disabled = false
                    
                    -- Tìm và reset LastUse
                    for _, upvalue in ipairs(getupvalues(soru)) do
                        if type(upvalue) == "table" and upvalue.LastUse then
                            upvalue.LastUse = 0
                        end
                    end
                end
            end)
        end
    end
end)

-- ===== AUTO V4 LOOP =====
spawn(function()
    while wait(0.5) do
        if Settings.AutoV4Enabled and LocalPlayer.Character then
            pcall(function()
                local raceEnergy = LocalPlayer.Character:FindFirstChild("RaceEnergy")
                if raceEnergy and raceEnergy.Value == 1 then
                    VirtualInputManager:SendKeyEvent(true, Settings.V4Key, false, game)
                    wait(0.1)
                    VirtualInputManager:SendKeyEvent(false, Settings.V4Key, false, game)
                end
            end)
        end
    end
end)

-- ===== ANTI STUN LOOP =====
spawn(function()
    while wait(0.1) do
        if Settings.AntiStunEnabled and LocalPlayer.Character then
            pcall(function()
                local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                if humanoid then
                    -- Chống choáng
                    if humanoid.PlatformStand or humanoid.Sit then
                        humanoid.PlatformStand = false
                        humanoid.Sit = false
                    end
                    
                    -- Chống knockback
                    local root = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                    if root then
                        if not root:FindFirstChild("AntiStunBodyVelocity") then
                            local bv = Instance.new("BodyVelocity")
                            bv.Name = "AntiStunBodyVelocity"
                            bv.MaxForce = Vector3.new(1, 1, 1) * math.huge
                            bv.Velocity = Vector3.new(0, 0, 0)
                            bv.Parent = root
                        end
                    end
                end
            end)
        end
    end
end)

-- ===== ESP LOOP =====
spawn(function()
    while wait(0.1) do
        if Settings.ESPEnabled then
            pcall(function()
                -- Tạo ESP cho người chơi mới
                for _, player in ipairs(Players:GetPlayers()) do
                    if player ~= LocalPlayer and player.Character and not ESPObjects[player] then
                        -- Tạo ESP
                        local billboard = Instance.new("BillboardGui")
                        billboard.Name = "PlayerESP"
                        billboard.Adornee = player.Character
                        billboard.Size = UDim2.new(0, IsMobile and 300 or 200, 0, IsMobile and 80 or 50)
                        billboard.StudsOffset = Vector3.new(0, 3, 0)
                        billboard.AlwaysOnTop = true
                        billboard.Parent = Camera
                        
                        local nameLabel = Instance.new("TextLabel")
                        nameLabel.Name = "Name"
                        nameLabel.Size = UDim2.new(1, 0, 0.4, 0)
                        nameLabel.BackgroundTransparency = 1
                        nameLabel.TextStrokeTransparency = 0.5
                        nameLabel.TextScaled = true
                        nameLabel.Font = Enum.Font.GothamBold
                        nameLabel.Parent = billboard
                        
                        local infoLabel = Instance.new("TextLabel")
                        infoLabel.Name = "Info"
                        infoLabel.Size = UDim2.new(1, 0, 0.3, 0)
                        infoLabel.Position = UDim2.new(0, 0, 0.4, 0)
                        infoLabel.BackgroundTransparency = 1
                        infoLabel.TextStrokeTransparency = 0.5
                        infoLabel.TextScaled = true
                        infoLabel.Font = Enum.Font.GothamBold
                        infoLabel.Parent = billboard
                        
                        local box = Instance.new("BoxHandleAdornment")
                        box.Name = "Box"
                        box.Size = Vector3.new(4, 6, 4)
                        box.AlwaysOnTop = true
                        box.ZIndex = 10
                        box.Adornee = player.Character
                        box.Transparency = 0.5
                        box.Parent = Camera
                        
                        ESPObjects[player] = {
                            Billboard = billboard,
                            NameLabel = nameLabel,
                            InfoLabel = infoLabel,
                            Box = box
                        }
                    end
                end
                
                -- Cập nhật ESP
                for player, esp in pairs(ESPObjects) do
                    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                        local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
                        if humanoid and humanoid.Health > 0 then
                            local root = player.Character.HumanoidRootPart
                            
                            -- Màu sắc
                            local color = (player.Team == LocalPlayer.Team) and Settings.TeamColor or Settings.EnemyColor
                            if player == CurrentTarget then
                                color = Settings.TargetColor
                            end
                            
                            esp.NameLabel.TextColor3 = color
                            esp.InfoLabel.TextColor3 = color
                            esp.Box.Color3 = color
                            
                            -- Tên
                            esp.NameLabel.Text = Settings.ShowName and player.Name or ""
                            
                            -- Khoảng cách và máu
                            local infoText = ""
                            if Settings.ShowDistance then
                                local dist = math.floor((LocalPlayer.Character.HumanoidRootPart.Position - root.Position).Magnitude)
                                infoText = infoText .. dist .. "m"
                            end
                            if Settings.ShowHealth then
                                local healthPercent = math.floor((humanoid.Health / humanoid.MaxHealth) * 100)
                                infoText = infoText .. (infoText ~= "" and " | " or "") .. healthPercent .. "%"
                            end
                            esp.InfoLabel.Text = infoText
                            
                            -- Cập nhật vị trí
                            esp.Billboard.Adornee = player.Character
                            esp.Box.Adornee = player.Character
                        else
                            -- Xóa ESP nếu chết
                            esp.Billboard:Destroy()
                            esp.Box:Destroy()
                            ESPObjects[player] = nil
                        end
                    else
                        -- Xóa ESP nếu mất nhân vật
                        esp.Billboard:Destroy()
                        esp.Box:Destroy()
                        ESPObjects[player] = nil
                    end
                end
            end)
        else
            -- Tắt ESP
            for player, esp in pairs(ESPObjects) do
                esp.Billboard:Destroy()
                esp.Box:Destroy()
            end
            ESPObjects = {}
        end
    end
end)

-- ===== VISUAL INDICATORS =====
local Visuals = nil

spawn(function()
    -- Tạo GUI cho visual indicators
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "PvPVisuals"
    screenGui.Parent = LocalPlayer:FindFirstChild("PlayerGui") or CoreGui
    
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, IsMobile and 250 or 200, 0, IsMobile and 150 or 100)
    mainFrame.Position = UDim2.new(0, 10, 0.5, IsMobile and -75 or -50)
    mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    mainFrame.BackgroundTransparency = 0.5
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = screenGui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 5)
    corner.Parent = mainFrame
    
    local labels = {}
    local texts = {"FPS: 60", "Ping: 50ms", "Target: None", "Distance: 0m"}
    
    for i, text in ipairs(texts) do
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, -10, 0, 25)
        label.Position = UDim2.new(0, 5, 0, (i-1) * 25)
        label.BackgroundTransparency = 1
        label.Text = text
        label.TextColor3 = i <= 2 and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 255, 0)
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Font = Enum.Font.GothamBold
        label.TextSize = IsMobile and 16 or 14
        label.Parent = mainFrame
        labels[i] = label
    end
    
    Visuals = {
        ScreenGui = screenGui,
        MainFrame = mainFrame,
        FPS = labels[1],
        Ping = labels[2],
        Target = labels[3],
        Distance = labels[4]
    }
end)

-- Cập nhật visual indicators
spawn(function()
    while wait(0.1) do
        pcall(function()
            if not Visuals then return end
            
            -- FPS
            if Settings.ShowFPS then
                FPSFrames = FPSFrames + 1
                local currentTime = tick()
                if currentTime - FPSTime >= 1 then
                    FPS = FPSFrames
                    FPSFrames = 0
                    FPSTime = currentTime
                end
                Visuals.FPS.Text = "FPS: " .. FPS
                Visuals.FPS.Visible = true
            else
                Visuals.FPS.Visible = false
            end
            
            -- Ping
            if Settings.ShowPing then
                local stats = game:GetService("Stats")
                if stats and stats.Network and stats.Network.ServerStatsItem then
                    Ping = math.floor(stats.Network.ServerStatsItem["Data Ping"]:GetValue())
                end
                Visuals.Ping.Text = "Ping: " .. Ping .. "ms"
                Visuals.Ping.Visible = true
            else
                Visuals.Ping.Visible = false
            end
            
            -- Target info
            if Settings.ShowTargetInfo then
                Visuals.Target.Text = "Target: " .. TargetInfo.Name
                Visuals.Distance.Text = "Distance: " .. TargetInfo.Distance .. "m"
                Visuals.Target.Visible = true
                Visuals.Distance.Visible = true
            else
                Visuals.Target.Visible = false
                Visuals.Distance.Visible = false
            end
        end)
    end
end)

-- =============================================
-- NÚT MENU TRÊN MÀN HÌNH
-- =============================================

spawn(function()
    local buttonGui = Instance.new("ScreenGui")
    buttonGui.Name = "MenuButton"
    buttonGui.Parent = LocalPlayer:FindFirstChild("PlayerGui") or CoreGui
    buttonGui.ResetOnSpawn = false
    buttonGui.Enabled = Settings.ShowMenuButton
    
    local button = Instance.new("ImageButton")
    button.Name = "MenuButton"
    button.Size = UDim2.new(0, Settings.ButtonSize, 0, Settings.ButtonSize)
    button.BackgroundColor3 = Color3.fromRGB(65, 105, 225)
    button.BackgroundTransparency = 0.2
    button.Image = "rbxassetid://3926305904"
    button.ImageColor3 = Color3.fromRGB(255, 255, 255)
    button.Parent = buttonGui
    
    -- Vị trí
    local pos = Settings.ButtonPosition
    if pos == "TopLeft" then
        button.Position = UDim2.new(0, 10, 0, 10)
    elseif pos == "TopRight" then
        button.Position = UDim2.new(1, -(Settings.ButtonSize + 10), 0, 10)
    elseif pos == "BottomLeft" then
        button.Position = UDim2.new(0, 10, 1, -(Settings.ButtonSize + 10))
    elseif pos == "BottomRight" then
        button.Position = UDim2.new(1, -(Settings.ButtonSize + 10), 1, -(Settings.ButtonSize + 10))
    end
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, Settings.ButtonSize / 2)
    corner.Parent = button
    
    MenuButton = button
    
    -- Click event
    button.MouseButton1Click:Connect(function()
        MenuVisible = not MenuVisible
        if Gui then
            Gui.Enabled = MenuVisible
        end
    end)
end)

-- =============================================
-- GUI MENU
-- =============================================

function CreateGUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "PvPHub"
    screenGui.Parent = LocalPlayer:FindFirstChild("PlayerGui") or CoreGui
    screenGui.Enabled = false
    
    -- Main Frame
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, IsMobile and 350 or 400, 0, IsMobile and 600 or 500)
    mainFrame.Position = UDim2.new(0.5, IsMobile and -175 or -200, 0.5, IsMobile and -300 or -250)
    mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    mainFrame.BorderSizePixel = 0
    mainFrame.Active = true
    mainFrame.Draggable = not IsMobile
    mainFrame.Parent = screenGui
    
    -- Gradient
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(35, 35, 45)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(20, 20, 30))
    })
    gradient.Parent = mainFrame
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = mainFrame
    
    -- Title Bar
    local titleBar = Instance.new("Frame")
    titleBar.Size = UDim2.new(1, 0, 0, IsMobile and 60 or 40)
    titleBar.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
    titleBar.BorderSizePixel = 0
    titleBar.Parent = mainFrame
    
    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 10)
    titleCorner.Parent = titleBar
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -80, 1, 0)
    title.Position = UDim2.new(0, 10, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "⚡ BLOX FRUITS PvP"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextScaled = true
    title.Font = Enum.Font.GothamBold
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = titleBar
    
    -- Close Button
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, IsMobile and 50 or 30, 0, IsMobile and 50 or 30)
    closeBtn.Position = UDim2.new(1, -(IsMobile and 60 or 40), 0, IsMobile and 5 or 5)
    closeBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    closeBtn.Text = "✕"
    closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeBtn.TextScaled = true
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.Parent = titleBar
    
    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, IsMobile and 10 or 5)
    closeCorner.Parent = closeBtn
    
    closeBtn.MouseButton1Click:Connect(function()
        MenuVisible = false
        screenGui.Enabled = false
    end)
    
    -- Tabs
    local tabFrame = Instance.new("Frame")
    tabFrame.Size = UDim2.new(1, 0, 0, IsMobile and 60 or 40)
    tabFrame.Position = UDim2.new(0, 0, 0, IsMobile and 60 or 40)
    tabFrame.BackgroundTransparency = 1
    tabFrame.Parent = mainFrame
    
    local tabs = {"⚔️ Combat", "👁️ ESP", "⚙️ Settings"}
    local currentTab = "⚔️ Combat"
    local tabButtons = {}
    
    for i, tabName in ipairs(tabs) do
        local btn = Instance.new("TextButton")
        btn.Name = tabName
        btn.Size = UDim2.new(1/#tabs, -5, 0, IsMobile and 50 or 30)
        btn.Position = UDim2.new((i-1)/#tabs, 5, 0, IsMobile and 5 or 5)
        btn.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
        btn.Text = tabName
        btn.TextColor3 = Color3.fromRGB(200, 200, 200)
        btn.TextScaled = true
        btn.Font = Enum.Font.GothamBold
        btn.Parent = tabFrame
        
        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, IsMobile and 10 or 5)
        btnCorner.Parent = btn
        
        tabButtons[tabName] = btn
        
        btn.MouseButton1Click:Connect(function()
            currentTab = tabName
            for _, b in pairs(tabButtons) do
                b.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
                b.TextColor3 = Color3.fromRGB(200, 200, 200)
            end
            btn.BackgroundColor3 = Color3.fromRGB(65, 105, 225)
            btn.TextColor3 = Color3.fromRGB(255, 255, 255)
            UpdateTabContent(currentTab)
        end)
    end
    
    -- Content Frame
    local contentFrame = Instance.new("ScrollingFrame")
    contentFrame.Size = UDim2.new(1, -20, 1, -(IsMobile and 160 or 120))
    contentFrame.Position = UDim2.new(0, 10, 0, IsMobile and 130 or 90)
    contentFrame.BackgroundTransparency = 1
    contentFrame.BorderSizePixel = 0
    contentFrame.ScrollBarThickness = IsMobile and 8 or 5
    contentFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    contentFrame.Parent = mainFrame
    
    -- Functions tạo UI elements
    function CreateSection(parent, text, y)
        local section = Instance.new("TextLabel")
        section.Size = UDim2.new(1, -10, 0, IsMobile and 40 or 25)
        section.Position = UDim2.new(0, 5, 0, y)
        section.BackgroundTransparency = 1
        section.Text = text
        section.TextColor3 = Color3.fromRGB(100, 150, 255)
        section.TextXAlignment = Enum.TextXAlignment.Left
        section.Font = Enum.Font.GothamBold
        section.TextSize = IsMobile and 18 or 16
        section.Parent = parent
        return y + (IsMobile and 45 or 30)
    end
    
    function CreateToggle(parent, text, default, callback, y)
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, -10, 0, IsMobile and 50 or 30)
        frame.Position = UDim2.new(0, 5, 0, y)
        frame.BackgroundTransparency = 1
        frame.Parent = parent
        
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(0.7, -5, 1, 0)
        label.BackgroundTransparency = 1
        label.Text = text
        label.TextColor3 = Color3.fromRGB(255, 255, 255)
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Font = Enum.Font.Gotham
        label.TextSize = IsMobile and 16 or 14
        label.Parent = frame
        
        local toggle = Instance.new("TextButton")
        toggle.Size = UDim2.new(0, IsMobile and 70 or 40, 0, IsMobile and 40 or 20)
        toggle.Position = UDim2.new(1, -(IsMobile and 80 or 45), 0.5, -(IsMobile and 20 or 10))
        toggle.BackgroundColor3 = default and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
        toggle.Text = default and "ON" or "OFF"
        toggle.TextColor3 = Color3.fromRGB(255, 255, 255)
        toggle.TextSize = IsMobile and 16 or 12
        toggle.Font = Enum.Font.GothamBold
        toggle.Parent = frame
        
        local toggleCorner = Instance.new("UICorner")
        toggleCorner.CornerRadius = UDim.new(0, IsMobile and 10 or 5)
        toggleCorner.Parent = toggle
        
        local state = default
        
        toggle.MouseButton1Click:Connect(function()
            state = not state
            toggle.BackgroundColor3 = state and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
            toggle.Text = state and "ON" or "OFF"
            callback(state)
        end)
        
        return y + (IsMobile and 55 or 35)
    end
    
    function CreateSlider(parent, text, min, max, default, callback, y)
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, -10, 0, IsMobile and 70 or 50)
        frame.Position = UDim2.new(0, 5, 0, y)
        frame.BackgroundTransparency = 1
        frame.Parent = parent
        
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(0.7, -5, 0, IsMobile and 25 or 20)
        label.BackgroundTransparency = 1
        label.Text = text
        label.TextColor3 = Color3.fromRGB(255, 255, 255)
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Font = Enum.Font.Gotham
        label.TextSize = IsMobile and 16 or 14
        label.Parent = frame
        
        local valueLabel = Instance.new("TextLabel")
        valueLabel.Size = UDim2.new(0.3, -5, 0, IsMobile and 25 or 20)
        valueLabel.Position = UDim2.new(0.7, 0, 0, 0)
        valueLabel.BackgroundTransparency = 1
        valueLabel.Text = tostring(default)
        valueLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
        valueLabel.TextXAlignment = Enum.TextXAlignment.Right
        valueLabel.Font = Enum.Font.GothamBold
        valueLabel.TextSize = IsMobile and 16 or 14
        valueLabel.Parent = frame
        
        local sliderBg = Instance.new("Frame")
        sliderBg.Size = UDim2.new(1, 0, 0, IsMobile and 20 or 10)
        sliderBg.Position = UDim2.new(0, 0, 0, IsMobile and 30 or 25)
        sliderBg.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
        sliderBg.Parent = frame
        
        local sliderBgCorner = Instance.new("UICorner")
        sliderBgCorner.CornerRadius = UDim.new(0, IsMobile and 10 or 5)
        sliderBgCorner.Parent = sliderBg
        
        local slider = Instance.new("Frame")
        slider.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
        slider.BackgroundColor3 = Color3.fromRGB(65, 105, 225)
        slider.Parent = sliderBg
        
        local sliderCorner = Instance.new("UICorner")
        sliderCorner.CornerRadius = UDim.new(0, IsMobile and 10 or 5)
        sliderCorner.Parent = slider
        
        local dragButton = Instance.new("TextButton")
        dragButton.Size = UDim2.new(1, 0, 1, 0)
        dragButton.BackgroundTransparency = 1
        dragButton.Text = ""
        dragButton.Parent = sliderBg
        
        local value = default
        local dragging = false
        
        dragButton.MouseButton1Down:Connect(function()
            dragging = true
        end)
        
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = false
            end
        end)
        
        dragButton.MouseMoved:Connect(function()
            if dragging then
                local mousePos = UserInputService:GetMouseLocation()
                local absPos = sliderBg.AbsolutePosition
                local sizeX = sliderBg.AbsoluteSize.X
                local relativeX = math.clamp(mousePos.X - absPos.X, 0, sizeX)
                local percent = relativeX / sizeX
                value = math.floor(min + (max - min) * percent)
                value = math.clamp(value, min, max)
                
                slider.Size = UDim2.new(percent, 0, 1, 0)
                valueLabel.Text = tostring(value)
                callback(value)
            end
        end)
        
        return y + (IsMobile and 75 or 55)
    end
    
    function CreateDropdown(parent, text, options, default, callback, y)
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, -10, 0, IsMobile and 80 or 50)
        frame.Position = UDim2.new(0, 5, 0, y)
        frame.BackgroundTransparency = 1
        frame.Parent = parent
        
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, 0, 0, IsMobile and 25 or 20)
        label.BackgroundTransparency = 1
        label.Text = text
        label.TextColor3 = Color3.fromRGB(255, 255, 255)
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Font = Enum.Font.Gotham
        label.TextSize = IsMobile and 16 or 14
        label.Parent = frame
        
        local dropdown = Instance.new("TextButton")
        dropdown.Size = UDim2.new(1, 0, 0, IsMobile and 45 or 25)
        dropdown.Position = UDim2.new(0, 0, 0, IsMobile and 30 or 20)
        dropdown.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
        dropdown.Text = default or options[1]
        dropdown.TextColor3 = Color3.fromRGB(255, 255, 255)
        dropdown.TextSize = IsMobile and 16 or 14
        dropdown.Font = Enum.Font.Gotham
        dropdown.Parent = frame
        
        local dropdownCorner = Instance.new("UICorner")
        dropdownCorner.CornerRadius = UDim.new(0, IsMobile and 10 or 5)
        dropdownCorner.Parent = dropdown
        
        local isOpen = false
        local dropdownList = nil
        
        dropdown.MouseButton1Click:Connect(function()
            isOpen = not isOpen
            
            if isOpen then
                dropdownList = Instance.new("Frame")
                dropdownList.Size = UDim2.new(1, 0, 0, #options * (IsMobile and 50 or 25))
                dropdownList.Position = UDim2.new(0, 0, 1, 0)
                dropdownList.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
                dropdownList.BorderSizePixel = 0
                dropdownList.Parent = dropdown
                
                local listCorner = Instance.new("UICorner")
                listCorner.CornerRadius = UDim.new(0, IsMobile and 10 or 5)
                listCorner.Parent = dropdownList
                
                for i, option in ipairs(options) do
                    local optionBtn = Instance.new("TextButton")
                    optionBtn.Size = UDim2.new(1, 0, 0, IsMobile and 50 or 25)
                    optionBtn.Position = UDim2.new(0, 0, 0, (i-1) * (IsMobile and 50 or 25))
                    optionBtn.BackgroundTransparency = 1
                    optionBtn.Text = option
                    optionBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
                    optionBtn.TextSize = IsMobile and 16 or 14
                    optionBtn.Font = Enum.Font.Gotham
                    optionBtn.Parent = dropdownList
                    
                    optionBtn.MouseButton1Click:Connect(function()
                        dropdown.Text = option
                        callback(option)
                        dropdownList:Destroy()
                        isOpen = false
                    end)
                    
                    optionBtn.MouseEnter:Connect(function()
                        optionBtn.BackgroundTransparency = 0.5
                    end)
                    
                    optionBtn.MouseLeave:Connect(function()
                        optionBtn.BackgroundTransparency = 1
                    end)
                end
            else
                if dropdownList then
                    dropdownList:Destroy()
                end
            end
        end)
        
        return y + (IsMobile and 85 or 55)
    end
    
    function CreateColorButton(parent, text, default, callback, y)
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, -10, 0, IsMobile and 60 or 40)
        frame.Position = UDim2.new(0, 5, 0, y)
        frame.BackgroundTransparency = 1
        frame.Parent = parent
        
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(0.7, -5, 1, 0)
        label.BackgroundTransparency = 1
        label.Text = text
        label.TextColor3 = Color3.fromRGB(255, 255, 255)
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Font = Enum.Font.Gotham
        label.TextSize = IsMobile and 16 or 14
        label.Parent = frame
        
        local colorBtn = Instance.new("Frame")
        colorBtn.Size = UDim2.new(0, IsMobile and 50 or 30, 0, IsMobile and 50 or 30)
        colorBtn.Position = UDim2.new(1, -(IsMobile and 60 or 35), 0.5, -(IsMobile and 25 or 15))
        colorBtn.BackgroundColor3 = default
        colorBtn.Parent = frame
        
        local colorCorner = Instance.new("UICorner")
        colorCorner.CornerRadius = UDim.new(0, IsMobile and 10 or 5)
        colorCorner.Parent = colorBtn
        
        colorBtn.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                local r = math.random(0, 255)
                local g = math.random(0, 255)
                local b = math.random(0, 255)
                local newColor = Color3.fromRGB(r, g, b)
                colorBtn.BackgroundColor3 = newColor
                callback(newColor)
            end
        end)
        
        return y + (IsMobile and 65 or 45)
    end
    
    function CreateButton(parent, text, callback, y)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, -10, 0, IsMobile and 60 or 35)
        btn.Position = UDim2.new(0, 5, 0, y)
        btn.BackgroundColor3 = Color3.fromRGB(65, 105, 225)
        btn.Text = text
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.TextSize = IsMobile and 18 or 14
        btn.Font = Enum.Font.GothamBold
        btn.Parent = parent
        
        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, IsMobile and 10 or 5)
        btnCorner.Parent = btn
        
        btn.MouseButton1Click:Connect(callback)
        
        return y + (IsMobile and 65 or 40)
    end
    
    -- Update tab content
    function UpdateTabContent(tab)
        for _, child in ipairs(contentFrame:GetChildren()) do
            child:Destroy()
        end
        
        local yPos = 0
        
        if tab == "⚔️ Combat" then
            yPos = CreateSection(contentFrame, "AIMBOT", yPos)
            yPos = CreateToggle(contentFrame, "Bật Aimbot", Settings.AimbotEnabled, function(v) Settings.AimbotEnabled = v end, yPos)
            
            local methods = {"Closest", "Selected"}
            yPos = CreateDropdown(contentFrame, "Phương thức", methods, Settings.AimbotMethod, function(v) Settings.AimbotMethod = v end, yPos)
            
            yPos = CreateSlider(contentFrame, "Khoảng cách", 50, 500, Settings.AimbotDistance, function(v) Settings.AimbotDistance = v end, yPos)
            
            yPos = CreateToggle(contentFrame, "Bỏ qua đồng đội", Settings.IgnoreTeam, function(v) Settings.IgnoreTeam = v end, yPos)
            
            yPos = CreateSection(contentFrame, "DI CHUYỂN", yPos + 20)
            yPos = CreateToggle(contentFrame, "Soru vô hạn", Settings.InfSoruEnabled, function(v) Settings.InfSoruEnabled = v end, yPos)
            
            yPos = CreateToggle(contentFrame, "Tự động V4", Settings.AutoV4Enabled, function(v) Settings.AutoV4Enabled = v end, yPos)
            
            yPos = CreateSection(contentFrame, "PHÒNG THỦ", yPos + 20)
            yPos = CreateToggle(contentFrame, "Chống choáng", Settings.AntiStunEnabled, function(v) Settings.AntiStunEnabled = v end, yPos)
            
        elseif tab == "👁️ ESP" then
            yPos = CreateSection(contentFrame, "CÀI ĐẶT ESP", yPos)
            yPos = CreateToggle(contentFrame, "Bật ESP", Settings.ESPEnabled, function(v) Settings.ESPEnabled = v end, yPos)
            
            yPos = CreateToggle(contentFrame, "Hiển thị tên", Settings.ShowName, function(v) Settings.ShowName = v end, yPos)
            yPos = CreateToggle(contentFrame, "Hiển thị khoảng cách", Settings.ShowDistance, function(v) Settings.ShowDistance = v end, yPos)
            yPos = CreateToggle(contentFrame, "Hiển thị máu", Settings.ShowHealth, function(v) Settings.ShowHealth = v end, yPos)
            yPos = CreateToggle(contentFrame, "Hiển thị khung", Settings.ShowBox, function(v) Settings.ShowBox = v end, yPos)
            
            yPos = CreateSection(contentFrame, "MÀU SẮC", yPos + 20)
            yPos = CreateColorButton(contentFrame, "Màu đồng đội", Settings.TeamColor, function(v) Settings.TeamColor = v end, yPos)
            yPos = CreateColorButton(contentFrame, "Màu kẻ địch", Settings.EnemyColor, function(v) Settings.EnemyColor = v end, yPos)
            yPos = CreateColorButton(contentFrame, "Màu mục tiêu", Settings.TargetColor, function(v) Settings.TargetColor = v end, yPos)
            
        elseif tab == "⚙️ Settings" then
            yPos = CreateSection(contentFrame, "HIỂN THỊ", yPos)
            yPos = CreateToggle(contentFrame, "Hiển thị FPS", Settings.ShowFPS, function(v) Settings.ShowFPS = v end, yPos)
            yPos = CreateToggle(contentFrame, "Hiển thị Ping", Settings.ShowPing, function(v) Settings.ShowPing = v end, yPos)
            yPos = CreateToggle(contentFrame, "Hiển thị mục tiêu", Settings.ShowTargetInfo, function(v) Settings.ShowTargetInfo = v end, yPos)
            
            yPos = CreateSection(contentFrame, "NÚT MENU", yPos + 20)
            yPos = CreateToggle(contentFrame, "Hiển thị nút menu", Settings.ShowMenuButton, function(v) 
                Settings.ShowMenuButton = v
                if MenuButton then
                    MenuButton.Parent.Enabled = v
                end
            end, yPos)
            
            local positions = {"TopLeft", "TopRight", "BottomLeft", "BottomRight"}
            yPos = CreateDropdown(contentFrame, "Vị trí nút", positions, Settings.ButtonPosition, function(v) 
                Settings.ButtonPosition = v
                if MenuButton then
                    local btn = MenuButton
                    if v == "TopLeft" then
                        btn.Position = UDim2.new(0, 10, 0, 10)
                    elseif v == "TopRight" then
                        btn.Position = UDim2.new(1, -(Settings.ButtonSize + 10), 0, 10)
                    elseif v == "BottomLeft" then
                        btn.Position = UDim2.new(0, 10, 1, -(Settings.ButtonSize + 10))
                    elseif v == "BottomRight" then
                        btn.Position = UDim2.new(1, -(Settings.ButtonSize + 10), 1, -(Settings.ButtonSize + 10))
                    end
                end
            end, yPos)
            
            yPos = CreateSlider(contentFrame, "Kích thước nút", 40, 80, Settings.ButtonSize, function(v)
                Settings.ButtonSize = v
                if MenuButton then
                    MenuButton.Size = UDim2.new(0, v, 0, v)
                end
            end, yPos)
            
            yPos = CreateSection(contentFrame, "CẤU HÌNH", yPos + 20)
            yPos = CreateButton(contentFrame, "Áp dụng cài đặt", function()
                -- Cập nhật tất cả settings
                print("✅ Đã áp dụng cài đặt mới!")
            end, yPos)
        end
        
        contentFrame.CanvasSize = UDim2.new(0, 0, 0, yPos + 40)
    end
    
    UpdateTabContent("⚔️ Combat")
    
    return screenGui
end

-- =============================================
-- KHỞI TẠO
-- =============================================

Gui = CreateGUI()
print("✅ Blox Fruits PvP Hub - Đã sẵn sàng!")
print("📱 Nhấn nút menu để mở - Bật là chạy ngay!")
