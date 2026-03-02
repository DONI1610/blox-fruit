--[[
    Blox Fruits PvP Hub - Mobile Friendly Version
    Version: 2.0 (Mobile Optimized)
    Tính năng: Aimbot, ESP, Auto V4, Inf Soru, Anti Stun + Nút menu trên màn hình
]]

-- Khởi tạo Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")
local StarterGui = game:GetService("StarterGui")
local CoreGui = game:GetService("CoreGui")

-- Biến cơ bản
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Camera = workspace.CurrentCamera
local IsMobile = UserInputService.TouchEnabled

-- Kiểm tra game Blox Fruits
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
-- CẤU HÌNH MẶC ĐỊNH
-- =============================================

local DefaultConfig = {
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
    
    -- Visual Indicators
    ShowFPS = true,
    ShowPing = true,
    ShowTargetInfo = true,
    
    -- Mobile Settings
    ShowMenuButton = true,
    ButtonSize = 50,
    ButtonPosition = "BottomRight", -- TopLeft, TopRight, BottomLeft, BottomRight
    
    -- Colors
    TeamColor = Color3.fromRGB(0, 255, 0),
    EnemyColor = Color3.fromRGB(255, 0, 0),
    TargetColor = Color3.fromRGB(255, 255, 0)
}

-- Load/Save Config
local Settings = {}
local function LoadConfig()
    local success, data = pcall(function()
        return readfile("BloxFruits_PvP_Mobile.json")
    end)
    
    if success and data then
        local decoded = game:GetService("HttpService"):JSONDecode(data)
        for k, v in pairs(decoded) do
            Settings[k] = v
        end
    else
        Settings = DefaultConfig
        SaveConfig()
    end
end

local function SaveConfig()
    local success, data = pcall(function()
        local json = game:GetService("HttpService"):JSONEncode(Settings)
        writefile("BloxFruits_PvP_Mobile.json", json)
    end)
end

local function ResetToDefault()
    Settings = DefaultConfig
    SaveConfig()
    showNotification("✅ Đã reset về mặc định!", Color3.fromRGB(0, 255, 0))
end

LoadConfig()

-- Hàm thông báo
function showNotification(text, color)
    spawn(function()
        local gui = Instance.new("ScreenGui")
        gui.Name = "Notification"
        gui.Parent = LocalPlayer:FindFirstChild("PlayerGui") or CoreGui
        
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(0, 250, 0, 50)
        frame.Position = UDim2.new(0.5, -125, 0, 10)
        frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        frame.BackgroundTransparency = 0.2
        frame.BorderSizePixel = 0
        frame.Parent = gui
        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 10)
        corner.Parent = frame
        
        local textLabel = Instance.new("TextLabel")
        textLabel.Size = UDim2.new(1, -20, 1, 0)
        textLabel.Position = UDim2.new(0, 10, 0, 0)
        textLabel.BackgroundTransparency = 1
        textLabel.Text = text
        textLabel.TextColor3 = color or Color3.fromRGB(255, 255, 255)
        textLabel.TextScaled = true
        textLabel.Font = Enum.Font.GothamBold
        textLabel.Parent = frame
        
        TweenService:Create(frame, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = UDim2.new(0.5, -125, 0, 10)}):Play()
        wait(2)
        TweenService:Create(frame, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Position = UDim2.new(0.5, -125, 0, -60)}):Play()
        wait(0.5)
        gui:Destroy()
    end)
end

-- =============================================
-- BIẾN TOÀN CỤC
-- =============================================

local ESPObjects = {}
local CurrentTarget = nil
local TargetInfo = {Name = "None", Distance = 0, Health = 0}
local FPS = 0; local FPSTime = 0; local FPSFrames = 0
local Ping = 0
local MenuVisible = false
local MenuButton = nil
local Gui = nil

-- =============================================
-- HÀM HỖ TRỢ
-- =============================================

local function GetCharacter(player)
    return player and player.Character
end

local function GetRoot(character)
    return character and character:FindFirstChild("HumanoidRootPart")
end

local function GetHumanoid(character)
    return character and character:FindFirstChildOfClass("Humanoid")
end

local function IsAlive(player)
    local character = GetCharacter(player)
    local humanoid = GetHumanoid(character)
    return character and humanoid and humanoid.Health > 0
end

local function IsSameTeam(player)
    return player and LocalPlayer.Team and player.Team == LocalPlayer.Team
end

local function GetClosestPlayer()
    local closest = nil
    local shortestDistance = Settings.AimbotDistance
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and IsAlive(player) then
            if Settings.IgnoreTeam and IsSameTeam(player) then
                continue
            end
            
            local root = GetRoot(GetCharacter(player))
            if root then
                local distance = (LocalPlayer.Character.HumanoidRootPart.Position - root.Position).Magnitude
                if distance < shortestDistance then
                    shortestDistance = distance
                    closest = player
                end
            end
        end
    end
    
    return closest
end

-- =============================================
-- TÍNH NĂNG AIMBOT
-- =============================================

local function UpdateAimbot()
    if not Settings.AimbotEnabled or not LocalPlayer.Character then return end
    
    if Settings.AimbotMethod == "Closest" then
        CurrentTarget = GetClosestPlayer()
    elseif Settings.AimbotMethod == "Selected" and Settings.TargetPlayer then
        if IsAlive(Settings.TargetPlayer) then
            if not (Settings.IgnoreTeam and IsSameTeam(Settings.TargetPlayer)) then
                CurrentTarget = Settings.TargetPlayer
            else
                CurrentTarget = nil
            end
        else
            CurrentTarget = nil
        end
    end
    
    if CurrentTarget then
        local targetRoot = GetRoot(GetCharacter(CurrentTarget))
        if targetRoot then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, targetRoot.Position)
            
            -- Update target info
            TargetInfo.Name = CurrentTarget.Name
            TargetInfo.Distance = math.floor((LocalPlayer.Character.HumanoidRootPart.Position - targetRoot.Position).Magnitude)
            TargetInfo.Health = math.floor(GetHumanoid(GetCharacter(CurrentTarget)).Health)
        end
    else
        TargetInfo.Name = "None"
        TargetInfo.Distance = 0
        TargetInfo.Health = 0
    end
end

-- =============================================
-- TÍNH NĂNG INF SORU
-- =============================================

local function SetupInfSoru()
    spawn(function()
        while Settings.InfSoruEnabled do
            task.wait(0.1)
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Soru") then
                LocalPlayer.Character.Soru.Disabled = false
                
                for _, upvalue in ipairs(getupvalues(LocalPlayer.Character.Soru)) do
                    if type(upvalue) == "table" and upvalue.LastUse then
                        upvalue.LastUse = 0
                    end
                end
            end
        end
    end)
end

-- =============================================
-- TÍNH NĂNG AUTO V4
-- =============================================

local function CheckV4()
    if not Settings.AutoV4Enabled then return end
    if not LocalPlayer.Character then return end
    
    local raceEnergy = LocalPlayer.Character:FindFirstChild("RaceEnergy")
    if raceEnergy and raceEnergy.Value == 1 then
        VirtualInputManager:SendKeyEvent(true, Settings.V4Key, false, game)
        task.wait(0.1)
        VirtualInputManager:SendKeyEvent(false, Settings.V4Key, false, game)
    end
end

-- =============================================
-- TÍNH NĂNG ESP
-- =============================================

local function CreateESP(player)
    if ESPObjects[player] then return end
    
    local esp = {}
    ESPObjects[player] = esp
    
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "PlayerESP"
    billboard.Adornee = GetCharacter(player)
    billboard.Size = UDim2.new(0, IsMobile and 300 or 200, 0, IsMobile and 80 or 50)
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.AlwaysOnTop = true
    billboard.Enabled = Settings.ESPEnabled
    
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Name = "Name"
    nameLabel.Size = UDim2.new(1, 0, 0.4, 0)
    nameLabel.Position = UDim2.new(0, 0, 0, 0)
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
    
    local healthBar = Instance.new("Frame")
    healthBar.Name = "HealthBar"
    healthBar.Size = UDim2.new(1, 0, 0.05, 0)
    healthBar.Position = UDim2.new(0, 0, 0.8, 0)
    healthBar.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
    healthBar.BorderSizePixel = 0
    healthBar.Parent = billboard
    
    local healthBarBg = Instance.new("Frame")
    healthBarBg.Size = UDim2.new(1, 0, 1, 0)
    healthBarBg.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    healthBarBg.BorderSizePixel = 0
    healthBarBg.Parent = healthBar
    
    local box = Instance.new("BoxHandleAdornment")
    box.Name = "Box"
    box.Size = Vector3.new(4, 6, 4)
    box.AlwaysOnTop = true
    box.ZIndex = 10
    box.Adornee = GetCharacter(player)
    box.Visible = Settings.ESPEnabled
    box.Transparency = 0.5
    
    billboard.Parent = Camera
    box.Parent = Camera
    
    esp.Billboard = billboard
    esp.NameLabel = nameLabel
    esp.InfoLabel = infoLabel
    esp.HealthBar = healthBar
    esp.Box = box
    
    return esp
end

local function UpdateESP()
    for player, esp in pairs(ESPObjects) do
        if IsAlive(player) then
            local character = GetCharacter(player)
            local root = GetRoot(character)
            local humanoid = GetHumanoid(character)
            
            if root and humanoid then
                local color = IsSameTeam(player) and Settings.TeamColor or Settings.EnemyColor
                if player == CurrentTarget then
                    color = Settings.TargetColor
                end
                
                esp.NameLabel.TextColor3 = color
                esp.InfoLabel.TextColor3 = color
                esp.Box.Color3 = color
                
                esp.NameLabel.Text = Settings.ShowName and player.Name or ""
                
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
                
                esp.HealthBar.Size = UDim2.new(humanoid.Health / humanoid.MaxHealth, 0, 1, 0)
                
                esp.Billboard.Adornee = character
                esp.Box.Adornee = character
            end
        else
            if esp.Billboard then esp.Billboard:Destroy() end
            if esp.Box then esp.Box:Destroy() end
            ESPObjects[player] = nil
        end
    end
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and IsAlive(player) and not ESPObjects[player] then
            CreateESP(player)
        end
    end
end

-- =============================================
-- TÍNH NĂNG ANTI STUN
-- =============================================

local function AntiStun()
    if not Settings.AntiStunEnabled then return end
    if not LocalPlayer.Character then return end
    
    local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        if humanoid.PlatformStand or humanoid.Sit then
            humanoid.PlatformStand = false
            humanoid.Sit = false
        end
        
        local root = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if root and not root:FindFirstChild("AntiStunBodyVelocity") then
            local bv = Instance.new("BodyVelocity")
            bv.Name = "AntiStunBodyVelocity"
            bv.MaxForce = Vector3.new(1, 1, 1) * math.huge
            bv.Velocity = Vector3.new(0, 0, 0)
            bv.Parent = root
        end
    end
end

-- =============================================
-- VISUAL INDICATORS
-- =============================================

local function CreateVisualIndicators()
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
    
    return {
        ScreenGui = screenGui,
        MainFrame = mainFrame,
        FPS = labels[1],
        Ping = labels[2],
        Target = labels[3],
        Distance = labels[4]
    }
end

local Visuals = CreateVisualIndicators()

local function UpdateVisuals()
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
    
    if Settings.ShowTargetInfo then
        Visuals.Target.Text = "Target: " .. TargetInfo.Name
        Visuals.Distance.Text = "Distance: " .. TargetInfo.Distance .. "m"
        Visuals.Target.Visible = true
        Visuals.Distance.Visible = true
    else
        Visuals.Target.Visible = false
        Visuals.Distance.Visible = false
    end
end

-- =============================================
-- NÚT MENU TRÊN MÀN HÌNH (MOBILE)
-- =============================================

local function CreateMenuButton()
    local buttonGui = Instance.new("ScreenGui")
    buttonGui.Name = "MenuButton"
    buttonGui.Parent = LocalPlayer:FindFirstChild("PlayerGui") or CoreGui
    buttonGui.ResetOnSpawn = false
    
    local button = Instance.new("ImageButton")
    button.Name = "MenuButton"
    button.Size = UDim2.new(0, Settings.ButtonSize, 0, Settings.ButtonSize)
    button.BackgroundColor3 = Color3.fromRGB(65, 105, 225)
    button.BackgroundTransparency = 0.2
    button.Image = "rbxassetid://3926305904" -- Icon menu
    button.ImageColor3 = Color3.fromRGB(255, 255, 255)
    button.Parent = buttonGui
    
    -- Vị trí nút
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
    
    -- Hiệu ứng glow
    local glow = Instance.new("ImageLabel")
    glow.Size = UDim2.new(1.5, 0, 1.5, 0)
    glow.Position = UDim2.new(-0.25, 0, -0.25, 0)
    glow.BackgroundTransparency = 1
    glow.Image = "rbxassetid://3570695787"
    glow.ImageColor3 = Color3.fromRGB(65, 105, 225)
    glow.ImageTransparency = 0.7
    glow.Parent = button
    
    -- Animation khi nhấn
    button.MouseButton1Click:Connect(function()
        -- Hiệu ứng nhấn
        TweenService:Create(button, TweenInfo.new(0.1), {Size = UDim2.new(0, Settings.ButtonSize * 0.8, 0, Settings.ButtonSize * 0.8)}):Play()
        task.wait(0.1)
        TweenService:Create(button, TweenInfo.new(0.1), {Size = UDim2.new(0, Settings.ButtonSize, 0, Settings.ButtonSize)}):Play()
        
        -- Toggle menu
        MenuVisible = not MenuVisible
        if Gui then
            Gui.Enabled = MenuVisible
        else
            Gui = CreateGUI()
            Gui.Enabled = MenuVisible
        end
        
        showNotification(MenuVisible and "📱 Menu opened" or "📱 Menu closed", Color3.fromRGB(0, 255, 0))
    end)
    
    -- Có thể kéo nút trên mobile
    local dragging = false
    local dragStart = nil
    local startPos = nil
    
    button.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = button.Position
        end
    end)
    
    button.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch and dragging then
            local delta = input.Position - dragStart
            button.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    
    button.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
            -- Lưu vị trí mới vào settings
            Settings.ButtonPosition = "Custom"
            SaveConfig()
        end
    end)
    
    return buttonGui, button
end

-- =============================================
-- GUI MENU (TỐI ƯU CHO MOBILE)
-- =============================================

local function CreateGUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "PvPHub"
    screenGui.Parent = LocalPlayer:FindFirstChild("PlayerGui") or CoreGui
    screenGui.Enabled = MenuVisible
    
    -- Main Frame - Lớn hơn cho mobile
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, IsMobile and 350 or 400, 0, IsMobile and 600 or 500)
    mainFrame.Position = UDim2.new(0.5, IsMobile and -175 or -200, 0.5, IsMobile and -300 or -250)
    mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    mainFrame.BorderSizePixel = 0
    mainFrame.Active = true
    mainFrame.Draggable = not IsMobile -- Trên PC có thể kéo
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
    
    -- Close Button (lớn hơn cho mobile)
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
    
    -- Tabs (lớn hơn cho mobile)
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
    
    -- Content Frame (có thể cuộn)
    local contentFrame = Instance.new("ScrollingFrame")
    contentFrame.Size = UDim2.new(1, -20, 1, -(IsMobile and 160 or 120))
    contentFrame.Position = UDim2.new(0, 10, 0, IsMobile and 130 or 90)
    contentFrame.BackgroundTransparency = 1
    contentFrame.BorderSizePixel = 0
    contentFrame.ScrollBarThickness = IsMobile and 8 or 5
    contentFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    contentFrame.Parent = mainFrame
    
    -- Function to update tab content
    function UpdateTabContent(tab)
        for _, child in ipairs(contentFrame:GetChildren()) do
            child:Destroy()
        end
        
        local yPos = 0
        
        if tab == "⚔️ Combat" then
            yPos = CreateSection(contentFrame, "AIMBOT", yPos)
            yPos = CreateToggle(contentFrame, "Bật Aimbot", Settings.AimbotEnabled, function(v) Settings.AimbotEnabled = v; SaveConfig() end, yPos)
            
            local methods = {"Closest", "Selected"}
            yPos = CreateDropdown(contentFrame, "Phương thức", methods, Settings.AimbotMethod, function(v) Settings.AimbotMethod = v; SaveConfig() end, yPos)
            
            yPos = CreateSlider(contentFrame, "Khoảng cách", 50, 500, Settings.AimbotDistance, function(v) Settings.AimbotDistance = v; SaveConfig() end, yPos)
            
            yPos = CreateToggle(contentFrame, "Bỏ qua đồng đội", Settings.IgnoreTeam, function(v) Settings.IgnoreTeam = v; SaveConfig() end, yPos)
            
            yPos = CreateSection(contentFrame, "DI CHUYỂN", yPos + 20)
            yPos = CreateToggle(contentFrame, "Soru vô hạn", Settings.InfSoruEnabled, function(v) Settings.InfSoruEnabled = v; if v then SetupInfSoru() end; SaveConfig() end, yPos)
            
            yPos = CreateToggle(contentFrame, "Tự động V4", Settings.AutoV4Enabled, function(v) Settings.AutoV4Enabled = v; SaveConfig() end, yPos)
            
            yPos = CreateSection(contentFrame, "PHÒNG THỦ", yPos + 20)
            yPos = CreateToggle(contentFrame, "Chống choáng", Settings.AntiStunEnabled, function(v) Settings.AntiStunEnabled = v; SaveConfig() end, yPos)
            
        elseif tab == "👁️ ESP" then
            yPos = CreateSection(contentFrame, "CÀI ĐẶT ESP", yPos)
            yPos = CreateToggle(contentFrame, "Bật ESP", Settings.ESPEnabled, function(v) 
                Settings.ESPEnabled = v
                for _, esp in pairs(ESPObjects) do
                    if esp.Billboard then esp.Billboard.Enabled = v end
                    if esp.Box then esp.Box.Visible = v end
                end
                SaveConfig()
            end, yPos)
            
            yPos = CreateToggle(contentFrame, "Hiển thị tên", Settings.ShowName, function(v) Settings.ShowName = v; SaveConfig() end, yPos)
            yPos = CreateToggle(contentFrame, "Hiển thị khoảng cách", Settings.ShowDistance, function(v) Settings.ShowDistance = v; SaveConfig() end, yPos)
            yPos = CreateToggle(contentFrame, "Hiển thị máu", Settings.ShowHealth, function(v) Settings.ShowHealth = v; SaveConfig() end, yPos)
            yPos = CreateToggle(contentFrame, "Hiển thị khung", Settings.ShowBox, function(v) Settings.ShowBox = v; SaveConfig() end, yPos)
            
            yPos = CreateSection(contentFrame, "MÀU SẮC", yPos + 20)
            yPos = CreateColorButton(contentFrame, "Màu đồng đội", Settings.TeamColor, function(v) Settings.TeamColor = v; SaveConfig() end, yPos)
            yPos = CreateColorButton(contentFrame, "Màu kẻ địch", Settings.EnemyColor, function(v) Settings.EnemyColor = v; SaveConfig() end, yPos)
            yPos = CreateColorButton(contentFrame, "Màu mục tiêu", Settings.TargetColor, function(v) Settings.TargetColor = v; SaveConfig() end, yPos)
            
        elseif tab == "⚙️ Settings" then
            yPos = CreateSection(contentFrame, "HIỂN THỊ", yPos)
            yPos = CreateToggle(contentFrame, "Hiển thị FPS", Settings.ShowFPS, function(v) Settings.ShowFPS = v; SaveConfig() end, yPos)
            yPos = CreateToggle(contentFrame, "Hiển thị Ping", Settings.ShowPing, function(v) Settings.ShowPing = v; SaveConfig() end, yPos)
            yPos = CreateToggle(contentFrame, "Hiển thị mục tiêu", Settings.ShowTargetInfo, function(v) Settings.ShowTargetInfo = v; SaveConfig() end, yPos)
            
            yPos = CreateSection(contentFrame, "NÚT MENU", yPos + 20)
            yPos = CreateToggle(contentFrame, "Hiển thị nút menu", Settings.ShowMenuButton, function(v) 
                Settings.ShowMenuButton = v
                if MenuButton then
                    MenuButton.Parent.Enabled = v
                end
                SaveConfig()
            end, yPos)
            
            local positions = {"TopLeft", "TopRight", "BottomLeft", "BottomRight"}
            yPos = CreateDropdown(contentFrame, "Vị trí nút", positions, Settings.ButtonPosition, function(v) 
                Settings.ButtonPosition = v
                SaveConfig()
                -- Cập nhật vị trí nút
                if MenuButton then
                    local btn = MenuButton.Parent.MenuButton
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
                    MenuButton.Parent.MenuButton.Size = UDim2.new(0, v, 0, v)
                end
                SaveConfig()
            end, yPos)
            
            yPos = CreateSection(contentFrame, "CẤU HÌNH", yPos + 20)
            yPos = CreateButton(contentFrame, "💾 Lưu cấu hình", function()
                SaveConfig()
                showNotification("✅ Đã lưu cấu hình!", Color3.fromRGB(0, 255, 0))
            end, yPos)
            
            yPos = CreateButton(contentFrame, "🔄 Reset mặc định", function()
                ResetToDefault()
                showNotification("✅ Đã reset mặc định!", Color3.fromRGB(255, 255, 0))
                -- Refresh GUI
                screenGui:Destroy()
                Gui = CreateGUI()
            end, yPos)
        end
        
        contentFrame.CanvasSize = UDim2.new(0, 0, 0, yPos + 40)
    end
    
    -- Helper functions cho GUI (tối ưu mobile)
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
                -- Tạo color picker đơn giản
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
    
    -- Initialize first tab
    UpdateTabContent("⚔️ Combat")
    
    return screenGui
end

-- =============================================
-- KHỞI TẠO
-- =============================================

-- Tạo nút menu
if Settings.ShowMenuButton then
    local buttonGui, button = CreateMenuButton()
    MenuButton = button
end

-- Tạo GUI menu (ẩn ban đầu)
Gui = CreateGUI()
Gui.Enabled = false

-- =============================================
-- MAIN LOOP
-- =============================================

RunService.RenderStepped:Connect(function()
    pcall(function()
        UpdateAimbot()
        CheckV4()
        AntiStun()
        
        if Settings.ESPEnabled then
            UpdateESP()
        end
        
        UpdateVisuals()
        
        -- Cập nhật Inf Soru
        if Settings.InfSoruEnabled then
            SetupInfSoru()
        end
    end)
end)

-- =============================================
-- DỌN DẸP KHI THOÁT
-- =============================================

LocalPlayer.OnTeleport:Connect(function()
    for _, esp in pairs(ESPObjects) do
        if esp.Billboard then esp.Billboard:Destroy() end
        if esp.Box then esp.Box:Destroy() end
    end
end)

print("✅ Blox Fruits PvP Hub - Mobile Ready!")
print("📱 Nhấn nút menu trên màn hình để mở")
print("⚡ Đã tối ưu cho điện thoại!")
