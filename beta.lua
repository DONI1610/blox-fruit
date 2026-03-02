--[[
    Blox Fruits PvP Hub - Professional PvP Script
    Version: 1.0
    Author: Your Script
    Tính năng: 
    - Aimbot (không aim đồng đội)
    - Inf Soru
    - Tự động kích hoạt V4
    - ESP Players
    - Anti Stun
    - GUI Menu
    - Visual Indicators
    - Lưu cấu hình
    - Reset mặc định
    - Phím tắt
]]

-- Khởi tạo Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")

-- Biến cơ bản
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Camera = workspace.CurrentCamera

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
    AimbotMethod = "Closest", -- "Closest" hoặc "Selected"
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
    
    -- Hotkeys
    ToggleMenuKey = "F9",
    PanicKey = "Delete",
    AimbotHotkey = "F1",
    ESPHotkey = "F2",
    
    -- Màu sắc
    TeamColor = Color3.fromRGB(0, 255, 0),
    EnemyColor = Color3.fromRGB(255, 0, 0),
    TargetColor = Color3.fromRGB(255, 255, 0)
}

-- Load cấu hình đã lưu (nếu có)
local Settings = {}
local function LoadConfig()
    local success, data = pcall(function()
        return readfile("BloxFruits_PvP_Settings.json")
    end)
    
    if success and data then
        local decoded = game:GetService("HttpService"):JSONDecode(data)
        for k, v in pairs(decoded) do
            Settings[k] = v
        end
    else
        -- Nếu không có file, dùng cấu hình mặc định
        Settings = DefaultConfig
        SaveConfig()
    end
end

local function SaveConfig()
    local success, data = pcall(function()
        local json = game:GetService("HttpService"):JSONEncode(Settings)
        writefile("BloxFruits_PvP_Settings.json", json)
    end)
end

local function ResetToDefault()
    Settings = DefaultConfig
    SaveConfig()
    
    -- Thông báo
    if LocalPlayer.PlayerGui:FindFirstChild("Notification") then
        LocalPlayer.PlayerGui.Notification:Destroy()
    end
    
    local notif = Instance.new("ScreenGui")
    notif.Name = "Notification"
    notif.Parent = LocalPlayer.PlayerGui
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 200, 0, 50)
    frame.Position = UDim2.new(0.5, -100, 0, 10)
    frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    frame.BorderSizePixel = 0
    frame.Parent = notif
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 5)
    corner.Parent = frame
    
    local text = Instance.new("TextLabel")
    text.Size = UDim2.new(1, 0, 1, 0)
    text.BackgroundTransparency = 1
    text.Text = "✅ Đã reset về mặc định!"
    text.TextColor3 = Color3.fromRGB(0, 255, 0)
    text.TextScaled = true
    text.Font = Enum.Font.GothamBold
    text.Parent = frame
    
    game:GetService("TweenService"):Create(frame, TweenInfo.new(2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = UDim2.new(0.5, -100, 0, -50)}):Play()
    wait(2)
    notif:Destroy()
end

LoadConfig()

-- =============================================
-- BIẾN TOÀN CỤC
-- =============================================

-- ESP Variables
local ESPObjects = {}
local ESPEnabled = Settings.ESPEnabled

-- Target cho aimbot
local CurrentTarget = nil
local TargetInfo = {
    Name = "None",
    Distance = 0,
    Health = 0
}

-- FPS Counter
local FPS = 0
local FPSTime = 0
local FPSFrames = 0

-- Ping Counter
local Ping = 0

-- Anti Stun
local OldHealth = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") and LocalPlayer.Character.Humanoid.Health or 0

-- =============================================
-- HÀM HỖ TRỢ
-- =============================================

-- Lấy nhân vật của người chơi
local function GetCharacter(player)
    return player and player.Character
end

-- Lấy HumanoidRootPart
local function GetRoot(character)
    return character and character:FindFirstChild("HumanoidRootPart")
end

-- Lấy Humanoid
local function GetHumanoid(character)
    return character and character:FindFirstChild("HumanoidOfClass", "Humanoid")
end

-- Kiểm tra người chơi còn sống
local function IsAlive(player)
    local character = GetCharacter(player)
    local humanoid = GetHumanoid(character)
    return character and humanoid and humanoid.Health > 0
end

-- Kiểm tra có cùng team không
local function IsSameTeam(player)
    return player and LocalPlayer.Team and player.Team == LocalPlayer.Team
end

-- Lấy người chơi gần nhất
local function GetClosestPlayer()
    local closest = nil
    local shortestDistance = Settings.AimbotDistance
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and IsAlive(player) then
            -- Bỏ qua nếu cùng team và bật IgnoreTeam
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

-- Cập nhật thông tin target
local function UpdateTargetInfo()
    if CurrentTarget and IsAlive(CurrentTarget) then
        local root = GetRoot(GetCharacter(CurrentTarget))
        if root then
            TargetInfo.Name = CurrentTarget.Name
            TargetInfo.Distance = math.floor((LocalPlayer.Character.HumanoidRootPart.Position - root.Position).Magnitude)
            TargetInfo.Health = math.floor(GetHumanoid(GetCharacter(CurrentTarget)).Health)
        end
    else
        CurrentTarget = nil
        TargetInfo.Name = "None"
        TargetInfo.Distance = 0
        TargetInfo.Health = 0
    end
end

-- =============================================
-- TÍNH NĂNG 1: AIMBOT
-- =============================================

local function UpdateAimbot()
    if not Settings.AimbotEnabled or not LocalPlayer.Character then return end
    
    -- Cập nhật target
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
    
    -- Aimbot camera và skills
    if CurrentTarget then
        local targetRoot = GetRoot(GetCharacter(CurrentTarget))
        if targetRoot then
            -- Aimbot camera (xoay camera theo mục tiêu)
            local cameraPos = Camera.CFrame.Position
            local targetPos = targetRoot.Position
            Camera.CFrame = CFrame.new(cameraPos, targetPos)
            
            -- Aimbot skills (tự động nhắm vào mục tiêu)
            local tool = LocalPlayer.Character:FindFirstChildOfClass("Tool")
            if tool then
                -- Hook vào remote để chỉnh hướng skill
                local oldNamecall
                oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
                    local method = getnamecallmethod()
                    local args = {...}
                    
                    if method == "FireServer" and tostring(self):find("Remote") then
                        -- Nếu là skill cần aim
                        if Settings.AimbotEnabled and CurrentTarget then
                            -- Thay đổi vị trí mục tiêu thành vị trí của đối thủ
                            if type(args[2]) == "Vector3" then
                                args[2] = targetRoot.Position
                                return oldNamecall(self, unpack(args))
                            end
                        end
                    end
                    
                    return oldNamecall(self, ...)
                end)
            end
        end
    end
end

-- =============================================
-- TÍNH NĂNG 2: INF SORU
-- =============================================

local function SetupInfSoru()
    if not Settings.InfSoruEnabled then return end
    
    -- Tìm và chỉnh sửa Soru script
    local soruScript = LocalPlayer.Character:FindFirstChild("Soru")
    if soruScript then
        local connections = getconnections(soruScript.Changed)
        for _, connection in ipairs(connections) do
            connection:Disable()
        end
        
        -- Tìm upvalue LastUse và set về 0 liên tục
        for _, upvalue in ipairs(getupvalues(soruScript)) do
            if type(upvalue) == "table" then
                upvalue.LastUse = 0
            end
        end
    end
    
    -- Tạo vòng lặp giữ Soru luôn sẵn sàng
    spawn(function()
        while Settings.InfSoruEnabled do
            task.wait(0.1)
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Soru") then
                LocalPlayer.Character.Soru.Disabled = false
                
                -- Tìm và reset LastUse
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
-- TÍNH NĂNG 3: AUTO V4
-- =============================================

local function CheckV4()
    if not Settings.AutoV4Enabled then return end
    if not LocalPlayer.Character then return end
    
    -- Kiểm tra RaceEnergy
    local raceEnergy = LocalPlayer.Character:FindFirstChild("RaceEnergy")
    if raceEnergy and raceEnergy.Value == 1 then
        -- Tự động kích hoạt V4
        VirtualInputManager:SendKeyEvent(true, Settings.V4Key, false, game)
        task.wait(0.1)
        VirtualInputManager:SendKeyEvent(false, Settings.V4Key, false, game)
    end
end

-- =============================================
-- TÍNH NĂNG 4: ESP
-- =============================================

local function CreateESP(player)
    if ESPObjects[player] then return end
    
    local esp = {}
    ESPObjects[player] = esp
    
    -- Tạo BillboardGui cho tên
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "PlayerESP"
    billboard.Adornee = GetCharacter(player)
    billboard.Size = UDim2.new(0, 200, 0, 50)
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.AlwaysOnTop = true
    billboard.Enabled = Settings.ESPEnabled
    
    -- Tên người chơi
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Name = "Name"
    nameLabel.Size = UDim2.new(1, 0, 0.5, 0)
    nameLabel.Position = UDim2.new(0, 0, 0, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.TextStrokeTransparency = 0.5
    nameLabel.TextScaled = true
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.Parent = billboard
    
    -- Thông tin thêm (khoảng cách, máu)
    local infoLabel = Instance.new("TextLabel")
    infoLabel.Name = "Info"
    infoLabel.Size = UDim2.new(1, 0, 0.5, 0)
    infoLabel.Position = UDim2.new(0, 0, 0.5, 0)
    infoLabel.BackgroundTransparency = 1
    infoLabel.TextStrokeTransparency = 0.5
    infoLabel.TextScaled = true
    infoLabel.Font = Enum.Font.GothamBold
    infoLabel.Parent = billboard
    
    -- Health Bar
    local healthBar = Instance.new("Frame")
    healthBar.Name = "HealthBar"
    healthBar.Size = UDim2.new(1, 0, 0.05, 0)
    healthBar.Position = UDim2.new(0, 0, 1, 0)
    healthBar.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
    healthBar.BorderSizePixel = 0
    healthBar.Parent = billboard
    
    local healthBarBg = Instance.new("Frame")
    healthBarBg.Size = UDim2.new(1, 0, 1, 0)
    healthBarBg.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    healthBarBg.BorderSizePixel = 0
    healthBarBg.Parent = healthBar
    
    -- Box ESP
    local box = Instance.new("BoxHandleAdornment")
    box.Name = "Box"
    box.Size = Vector3.new(4, 6, 4)
    box.AlwaysOnTop = true
    box.ZIndex = 10
    box.Adornee = GetCharacter(player)
    box.Visible = Settings.ESPEnabled
    
    billboard.Parent = Camera
    box.Parent = Camera
    
    esp.Billboard = billboard
    esp.NameLabel = nameLabel
    esp.InfoLabel = infoLabel
    esp.HealthBar = healthBar
    esp.Box = box
    
    -- Cập nhật màu sắc
    local color = IsSameTeam(player) and Settings.TeamColor or Settings.EnemyColor
    if player == CurrentTarget then
        color = Settings.TargetColor
    end
    
    nameLabel.TextColor3 = color
    infoLabel.TextColor3 = color
    box.Color3 = color
    
    return esp
end

local function UpdateESP()
    for player, esp in pairs(ESPObjects) do
        if IsAlive(player) then
            local character = GetCharacter(player)
            local root = GetRoot(character)
            local humanoid = GetHumanoid(character)
            
            if root and humanoid then
                -- Cập nhật màu
                local color = IsSameTeam(player) and Settings.TeamColor or Settings.EnemyColor
                if player == CurrentTarget then
                    color = Settings.TargetColor
                end
                
                esp.NameLabel.TextColor3 = color
                esp.InfoLabel.TextColor3 = color
                esp.Box.Color3 = color
                
                -- Cập nhật tên
                if Settings.ShowName then
                    esp.NameLabel.Text = player.Name
                else
                    esp.NameLabel.Text = ""
                end
                
                -- Cập nhật khoảng cách và máu
                local infoText = ""
                if Settings.ShowDistance then
                    local dist = math.floor((LocalPlayer.Character.HumanoidRootPart.Position - root.Position).Magnitude)
                    infoText = infoText .. dist .. "m"
                end
                if Settings.ShowHealth then
                    local healthPercent = math.floor((humanoid.Health / humanoid.MaxHealth) * 100)
                    infoText = infoText .. " | " .. healthPercent .. "%"
                end
                esp.InfoLabel.Text = infoText
                
                -- Cập nhật health bar
                esp.HealthBar.Size = UDim2.new(humanoid.Health / humanoid.MaxHealth, 0, 1, 0)
                
                -- Cập nhật vị trí
                esp.Billboard.Adornee = character
                esp.Box.Adornee = character
            end
        else
            -- Xóa ESP nếu người chơi chết
            if esp.Billboard then esp.Billboard:Destroy() end
            if esp.Box then esp.Box:Destroy() end
            ESPObjects[player] = nil
        end
    end
    
    -- Tạo ESP cho người chơi mới
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and IsAlive(player) and not ESPObjects[player] then
            CreateESP(player)
        end
    end
end

-- =============================================
-- TÍNH NĂNG 5: ANTI STUN
-- =============================================

local function AntiStun()
    if not Settings.AntiStunEnabled then return end
    if not LocalPlayer.Character then return end
    
    local humanoid = LocalPlayer.Character:FindFirstChild("Humanoid")
    if humanoid then
        -- Kiểm tra nếu bị choáng (stun)
        if humanoid.PlatformStand or humanoid.Sit then
            humanoid.PlatformStand = false
            humanoid.Sit = false
            
            -- Reset animation
            if humanoid:FindFirstChild("Animator") then
                for _, track in ipairs(humanoid.Animator:GetPlayingAnimationTracks()) do
                    track:Stop()
                end
            end
        end
        
        -- Chống knockback bằng cách giữ nguyên vị trí
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
end

-- =============================================
-- VISUAL INDICATORS
-- =============================================

local function CreateVisualIndicators()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "PvPVisuals"
    screenGui.Parent = LocalPlayer.PlayerGui
    
    -- Frame chính
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 200, 0, 100)
    mainFrame.Position = UDim2.new(0, 10, 0.5, -50)
    mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    mainFrame.BackgroundTransparency = 0.5
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = screenGui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 5)
    corner.Parent = mainFrame
    
    -- FPS Counter
    local fpsLabel = Instance.new("TextLabel")
    fpsLabel.Name = "FPS"
    fpsLabel.Size = UDim2.new(1, -10, 0.25, 0)
    fpsLabel.Position = UDim2.new(0, 5, 0, 5)
    fpsLabel.BackgroundTransparency = 1
    fpsLabel.Text = "FPS: 60"
    fpsLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
    fpsLabel.TextXAlignment = Enum.TextXAlignment.Left
    fpsLabel.Font = Enum.Font.GothamBold
    fpsLabel.TextSize = 14
    fpsLabel.Parent = mainFrame
    
    -- Ping Counter
    local pingLabel = Instance.new("TextLabel")
    pingLabel.Name = "Ping"
    pingLabel.Size = UDim2.new(1, -10, 0.25, 0)
    pingLabel.Position = UDim2.new(0, 5, 0.25, 0)
    pingLabel.BackgroundTransparency = 1
    pingLabel.Text = "Ping: 50ms"
    pingLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
    pingLabel.TextXAlignment = Enum.TextXAlignment.Left
    pingLabel.Font = Enum.Font.GothamBold
    pingLabel.TextSize = 14
    pingLabel.Parent = mainFrame
    
    -- Target Info
    local targetLabel = Instance.new("TextLabel")
    targetLabel.Name = "Target"
    targetLabel.Size = UDim2.new(1, -10, 0.25, 0)
    targetLabel.Position = UDim2.new(0, 5, 0.5, 0)
    targetLabel.BackgroundTransparency = 1
    targetLabel.Text = "Target: None"
    targetLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
    targetLabel.TextXAlignment = Enum.TextXAlignment.Left
    targetLabel.Font = Enum.Font.GothamBold
    targetLabel.TextSize = 14
    targetLabel.Parent = mainFrame
    
    -- Target Distance
    local distanceLabel = Instance.new("TextLabel")
    distanceLabel.Name = "Distance"
    distanceLabel.Size = UDim2.new(1, -10, 0.25, 0)
    distanceLabel.Position = UDim2.new(0, 5, 0.75, 0)
    distanceLabel.BackgroundTransparency = 1
    distanceLabel.Text = "Distance: 0m"
    distanceLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
    distanceLabel.TextXAlignment = Enum.TextXAlignment.Left
    distanceLabel.Font = Enum.Font.GothamBold
    distanceLabel.TextSize = 14
    distanceLabel.Parent = mainFrame
    
    return {
        ScreenGui = screenGui,
        MainFrame = mainFrame,
        FPS = fpsLabel,
        Ping = pingLabel,
        Target = targetLabel,
        Distance = distanceLabel
    }
end

local Visuals = CreateVisualIndicators()

-- Cập nhật visual indicators
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
        Ping = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue())
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
-- GUI MENU
-- =============================================

local function CreateGUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "PvPHub"
    screenGui.Parent = LocalPlayer.PlayerGui
    
    -- Main Frame
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 400, 0, 500)
    mainFrame.Position = UDim2.new(0.5, -200, 0.5, -250)
    mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    mainFrame.BorderSizePixel = 0
    mainFrame.Active = true
    mainFrame.Draggable = true
    mainFrame.Parent = screenGui
    
    -- Gradient Background
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(35, 35, 45)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(20, 20, 30))
    })
    gradient.Parent = mainFrame
    
    -- Corner
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = mainFrame
    
    -- Title Bar
    local titleBar = Instance.new("Frame")
    titleBar.Size = UDim2.new(1, 0, 0, 40)
    titleBar.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
    titleBar.BorderSizePixel = 0
    titleBar.Parent = mainFrame
    
    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 10)
    titleCorner.Parent = titleBar
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -50, 1, 0)
    title.Position = UDim2.new(0, 10, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "BLOX FRUITS PvP HUB"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextScaled = true
    title.Font = Enum.Font.GothamBold
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = titleBar
    
    -- Close Button
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 30, 0, 30)
    closeBtn.Position = UDim2.new(1, -35, 0, 5)
    closeBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    closeBtn.Text = "X"
    closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeBtn.TextScaled = true
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.Parent = titleBar
    
    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 5)
    closeCorner.Parent = closeBtn
    
    closeBtn.MouseButton1Click:Connect(function()
        screenGui:Destroy()
    end)
    
    -- Tabs
    local tabFrame = Instance.new("Frame")
    tabFrame.Size = UDim2.new(1, 0, 0, 40)
    tabFrame.Position = UDim2.new(0, 0, 0, 40)
    tabFrame.BackgroundTransparency = 1
    tabFrame.Parent = mainFrame
    
    local tabs = {"Combat", "ESP", "Movement", "Settings"}
    local currentTab = "Combat"
    local tabButtons = {}
    
    for i, tabName in ipairs(tabs) do
        local btn = Instance.new("TextButton")
        btn.Name = tabName
        btn.Size = UDim2.new(0.25, -5, 0, 30)
        btn.Position = UDim2.new((i-1) * 0.25, 5, 0, 5)
        btn.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
        btn.Text = tabName
        btn.TextColor3 = Color3.fromRGB(200, 200, 200)
        btn.TextScaled = true
        btn.Font = Enum.Font.GothamBold
        btn.Parent = tabFrame
        
        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, 5)
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
    contentFrame.Size = UDim2.new(1, -20, 1, -100)
    contentFrame.Position = UDim2.new(0, 10, 0, 90)
    contentFrame.BackgroundTransparency = 1
    contentFrame.BorderSizePixel = 0
    contentFrame.ScrollBarThickness = 5
    contentFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    contentFrame.Parent = mainFrame
    
    -- Function to update tab content
    local function UpdateTabContent(tab)
        -- Clear content
        for _, child in ipairs(contentFrame:GetChildren()) do
            child:Destroy()
        end
        
        local yPos = 0
        
        if tab == "Combat" then
            -- Aimbot Section
            yPos = CreateSection(contentFrame, "Aimbot Settings", yPos)
            
            yPos = CreateToggle(contentFrame, "Enable Aimbot", Settings.AimbotEnabled, function(value)
                Settings.AimbotEnabled = value
                SaveConfig()
            end, yPos)
            
            yPos = CreateDropdown(contentFrame, "Aimbot Method", {"Closest", "Selected"}, Settings.AimbotMethod, function(value)
                Settings.AimbotMethod = value
                SaveConfig()
            end, yPos)
            
            if Settings.AimbotMethod == "Selected" then
                local players = {}
                for _, player in ipairs(Players:GetPlayers()) do
                    if player ~= LocalPlayer then
                        table.insert(players, player.Name)
                    end
                end
                
                yPos = CreateDropdown(contentFrame, "Select Target", players, Settings.TargetPlayer and Settings.TargetPlayer.Name or nil, function(value)
                    Settings.TargetPlayer = Players[value]
                    SaveConfig()
                end, yPos)
            end
            
            yPos = CreateSlider(contentFrame, "Aimbot Distance", 50, 500, Settings.AimbotDistance, function(value)
                Settings.AimbotDistance = value
                SaveConfig()
            end, yPos)
            
            yPos = CreateToggle(contentFrame, "Ignore Same Team", Settings.IgnoreTeam, function(value)
                Settings.IgnoreTeam = value
                SaveConfig()
            end, yPos)
            
            -- Soru Section
            yPos = CreateSection(contentFrame, "Movement", yPos + 10)
            
            yPos = CreateToggle(contentFrame, "Infinite Soru", Settings.InfSoruEnabled, function(value)
                Settings.InfSoruEnabled = value
                if value then SetupInfSoru() end
                SaveConfig()
            end, yPos)
            
            -- V4 Section
            yPos = CreateToggle(contentFrame, "Auto V4", Settings.AutoV4Enabled, function(value)
                Settings.AutoV4Enabled = value
                SaveConfig()
            end, yPos)
            
            if Settings.AutoV4Enabled then
                yPos = CreateInput(contentFrame, "V4 Key", Settings.V4Key, function(value)
                    Settings.V4Key = value
                    SaveConfig()
                end, yPos)
            end
            
            -- Anti Stun
            yPos = CreateSection(contentFrame, "Defense", yPos + 10)
            
            yPos = CreateToggle(contentFrame, "Anti Stun", Settings.AntiStunEnabled, function(value)
                Settings.AntiStunEnabled = value
                SaveConfig()
            end, yPos)
            
        elseif tab == "ESP" then
            yPos = CreateSection(contentFrame, "ESP Settings", yPos)
            
            yPos = CreateToggle(contentFrame, "Enable ESP", Settings.ESPEnabled, function(value)
                Settings.ESPEnabled = value
                for _, esp in pairs(ESPObjects) do
                    if esp.Billboard then
                        esp.Billboard.Enabled = value
                    end
                    if esp.Box then
                        esp.Box.Visible = value
                    end
                end
                SaveConfig()
            end, yPos)
            
            yPos = CreateToggle(contentFrame, "Show Name", Settings.ShowName, function(value)
                Settings.ShowName = value
                SaveConfig()
            end, yPos)
            
            yPos = CreateToggle(contentFrame, "Show Distance", Settings.ShowDistance, function(value)
                Settings.ShowDistance = value
                SaveConfig()
            end, yPos)
            
            yPos = CreateToggle(contentFrame, "Show Health", Settings.ShowHealth, function(value)
                Settings.ShowHealth = value
                SaveConfig()
            end, yPos)
            
            yPos = CreateToggle(contentFrame, "Show Box", Settings.ShowBox, function(value)
                Settings.ShowBox = value
                SaveConfig()
            end, yPos)
            
            -- Color Settings
            yPos = CreateSection(contentFrame, "Colors", yPos + 10)
            
            yPos = CreateColorPicker(contentFrame, "Team Color", Settings.TeamColor, function(value)
                Settings.TeamColor = value
                SaveConfig()
            end, yPos)
            
            yPos = CreateColorPicker(contentFrame, "Enemy Color", Settings.EnemyColor, function(value)
                Settings.EnemyColor = value
                SaveConfig()
            end, yPos)
            
            yPos = CreateColorPicker(contentFrame, "Target Color", Settings.TargetColor, function(value)
                Settings.TargetColor = value
                SaveConfig()
            end, yPos)
            
        elseif tab == "Movement" then
            
        elseif tab == "Settings" then
            yPos = CreateSection(contentFrame, "Visual Indicators", yPos)
            
            yPos = CreateToggle(contentFrame, "Show FPS", Settings.ShowFPS, function(value)
                Settings.ShowFPS = value
                SaveConfig()
            end, yPos)
            
            yPos = CreateToggle(contentFrame, "Show Ping", Settings.ShowPing, function(value)
                Settings.ShowPing = value
                SaveConfig()
            end, yPos)
            
            yPos = CreateToggle(contentFrame, "Show Target Info", Settings.ShowTargetInfo, function(value)
                Settings.ShowTargetInfo = value
                SaveConfig()
            end, yPos)
            
            yPos = CreateSection(contentFrame, "Hotkeys", yPos + 10)
            
            yPos = CreateInput(contentFrame, "Toggle Menu Key", Settings.ToggleMenuKey, function(value)
                Settings.ToggleMenuKey = value
                SaveConfig()
            end, yPos)
            
            yPos = CreateInput(contentFrame, "Panic Key", Settings.PanicKey, function(value)
                Settings.PanicKey = value
                SaveConfig()
            end, yPos)
            
            yPos = CreateInput(contentFrame, "Aimbot Toggle Key", Settings.AimbotHotkey, function(value)
                Settings.AimbotHotkey = value
                SaveConfig()
            end, yPos)
            
            yPos = CreateInput(contentFrame, "ESP Toggle Key", Settings.ESPHotkey, function(value)
                Settings.ESPHotkey = value
                SaveConfig()
            end, yPos)
            
            yPos = CreateSection(contentFrame, "Configuration", yPos + 10)
            
            yPos = CreateButton(contentFrame, "Save Settings", function()
                SaveConfig()
                -- Thông báo
                local notif = Instance.new("Message")
                notif.Text = "✅ Settings saved!"
                notif.Parent = LocalPlayer.PlayerGui
                task.wait(2)
                notif:Destroy()
            end, yPos)
            
            yPos = CreateButton(contentFrame, "Reset to Default", function()
                ResetToDefault()
                -- Refresh GUI
                screenGui:Destroy()
                CreateGUI()
            end, yPos)
        end
        
        contentFrame.CanvasSize = UDim2.new(0, 0, 0, yPos + 20)
    end
    
    -- Helper functions for GUI elements
    function CreateSection(parent, text, y)
        local section = Instance.new("TextLabel")
        section.Size = UDim2.new(1, -10, 0, 25)
        section.Position = UDim2.new(0, 5, 0, y)
        section.BackgroundTransparency = 1
        section.Text = text
        section.TextColor3 = Color3.fromRGB(100, 150, 255)
        section.TextXAlignment = Enum.TextXAlignment.Left
        section.Font = Enum.Font.GothamBold
        section.TextSize = 16
        section.Parent = parent
        
        return y + 30
    end
    
    function CreateToggle(parent, text, default, callback, y)
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, -10, 0, 30)
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
        label.TextSize = 14
        label.Parent = frame
        
        local toggle = Instance.new("TextButton")
        toggle.Size = UDim2.new(0, 40, 0, 20)
        toggle.Position = UDim2.new(1, -45, 0.5, -10)
        toggle.BackgroundColor3 = default and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
        toggle.Text = default and "ON" or "OFF"
        toggle.TextColor3 = Color3.fromRGB(255, 255, 255)
        toggle.TextSize = 12
        toggle.Font = Enum.Font.GothamBold
        toggle.Parent = frame
        
        local toggleCorner = Instance.new("UICorner")
        toggleCorner.CornerRadius = UDim.new(0, 5)
        toggleCorner.Parent = toggle
        
        local state = default
        
        toggle.MouseButton1Click:Connect(function()
            state = not state
            toggle.BackgroundColor3 = state and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
            toggle.Text = state and "ON" or "OFF"
            callback(state)
        end)
        
        return y + 35
    end
    
    function CreateDropdown(parent, text, options, default, callback, y)
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, -10, 0, 50)
        frame.Position = UDim2.new(0, 5, 0, y)
        frame.BackgroundTransparency = 1
        frame.Parent = parent
        
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, 0, 0, 20)
        label.BackgroundTransparency = 1
        label.Text = text
        label.TextColor3 = Color3.fromRGB(255, 255, 255)
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Font = Enum.Font.Gotham
        label.TextSize = 14
        label.Parent = frame
        
        local dropdown = Instance.new("TextButton")
        dropdown.Size = UDim2.new(1, 0, 0, 25)
        dropdown.Position = UDim2.new(0, 0, 0, 20)
        dropdown.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
        dropdown.Text = default or options[1]
        dropdown.TextColor3 = Color3.fromRGB(255, 255, 255)
        dropdown.TextSize = 14
        dropdown.Font = Enum.Font.Gotham
        dropdown.Parent = frame
        
        local dropdownCorner = Instance.new("UICorner")
        dropdownCorner.CornerRadius = UDim.new(0, 5)
        dropdownCorner.Parent = dropdown
        
        local isOpen = false
        local dropdownList = nil
        
        dropdown.MouseButton1Click:Connect(function()
            isOpen = not isOpen
            
            if isOpen then
                dropdownList = Instance.new("Frame")
                dropdownList.Size = UDim2.new(1, 0, 0, #options * 25)
                dropdownList.Position = UDim2.new(0, 0, 1, 0)
                dropdownList.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
                dropdownList.BorderSizePixel = 0
                dropdownList.Parent = dropdown
                
                local listCorner = Instance.new("UICorner")
                listCorner.CornerRadius = UDim.new(0, 5)
                listCorner.Parent = dropdownList
                
                for i, option in ipairs(options) do
                    local optionBtn = Instance.new("TextButton")
                    optionBtn.Size = UDim2.new(1, 0, 0, 25)
                    optionBtn.Position = UDim2.new(0, 0, 0, (i-1) * 25)
                    optionBtn.BackgroundTransparency = 1
                    optionBtn.Text = option
                    optionBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
                    optionBtn.TextSize = 14
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
        
        return y + 55
    end
    
    function CreateSlider(parent, text, min, max, default, callback, y)
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, -10, 0, 50)
        frame.Position = UDim2.new(0, 5, 0, y)
        frame.BackgroundTransparency = 1
        frame.Parent = parent
        
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(0.7, -5, 0, 20)
        label.BackgroundTransparency = 1
        label.Text = text
        label.TextColor3 = Color3.fromRGB(255, 255, 255)
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Font = Enum.Font.Gotham
        label.TextSize = 14
        label.Parent = frame
        
        local valueLabel = Instance.new("TextLabel")
        valueLabel.Size = UDim2.new(0.3, -5, 0, 20)
        valueLabel.Position = UDim2.new(0.7, 0, 0, 0)
        valueLabel.BackgroundTransparency = 1
        valueLabel.Text = tostring(default)
        valueLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
        valueLabel.TextXAlignment = Enum.TextXAlignment.Right
        valueLabel.Font = Enum.Font.GothamBold
        valueLabel.TextSize = 14
        valueLabel.Parent = frame
        
        local sliderBg = Instance.new("Frame")
        sliderBg.Size = UDim2.new(1, 0, 0, 10)
        sliderBg.Position = UDim2.new(0, 0, 0, 25)
        sliderBg.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
        sliderBg.Parent = frame
        
        local sliderBgCorner = Instance.new("UICorner")
        sliderBgCorner.CornerRadius = UDim.new(0, 5)
        sliderBgCorner.Parent = sliderBg
        
        local slider = Instance.new("Frame")
        slider.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
        slider.BackgroundColor3 = Color3.fromRGB(65, 105, 225)
        slider.Parent = sliderBg
        
        local sliderCorner = Instance.new("UICorner")
        sliderCorner.CornerRadius = UDim.new(0, 5)
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
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = false
            end
        end)
        
        dragButton.MouseButton1Up:Connect(function()
            dragging = false
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
        
        return y + 55
    end
    
    function CreateInput(parent, text, default, callback, y)
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, -10, 0, 50)
        frame.Position = UDim2.new(0, 5, 0, y)
        frame.BackgroundTransparency = 1
        frame.Parent = parent
        
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, 0, 0, 20)
        label.BackgroundTransparency = 1
        label.Text = text
        label.TextColor3 = Color3.fromRGB(255, 255, 255)
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Font = Enum.Font.Gotham
        label.TextSize = 14
        label.Parent = frame
        
        local input = Instance.new("TextBox")
        input.Size = UDim2.new(1, 0, 0, 25)
        input.Position = UDim2.new(0, 0, 0, 20)
        input.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
        input.Text = default
        input.TextColor3 = Color3.fromRGB(255, 255, 255)
        input.TextSize = 14
        input.Font = Enum.Font.Gotham
        input.PlaceholderText = "Enter key..."
        input.Parent = frame
        
        local inputCorner = Instance.new("UICorner")
        inputCorner.CornerRadius = UDim.new(0, 5)
        inputCorner.Parent = input
        
        input.FocusLost:Connect(function()
            callback(input.Text)
        end)
        
        return y + 55
    end
    
    function CreateColorPicker(parent, text, default, callback, y)
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, -10, 0, 40)
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
        label.TextSize = 14
        label.Parent = frame
        
        local colorBtn = Instance.new("Frame")
        colorBtn.Size = UDim2.new(0, 30, 0, 30)
        colorBtn.Position = UDim2.new(1, -35, 0.5, -15)
        colorBtn.BackgroundColor3 = default
        colorBtn.Parent = frame
        
        local colorCorner = Instance.new("UICorner")
        colorCorner.CornerRadius = UDim.new(0, 5)
        colorCorner.Parent = colorBtn
        
        -- Color picker dialog đơn giản
        colorBtn.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                -- Tạo color picker đơn giản (có thể mở rộng sau)
                local r = math.random(0, 255)
                local g = math.random(0, 255)
                local b = math.random(0, 255)
                local newColor = Color3.fromRGB(r, g, b)
                colorBtn.BackgroundColor3 = newColor
                callback(newColor)
            end
        end)
        
        return y + 45
    end
    
    function CreateButton(parent, text, callback, y)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, -10, 0, 35)
        btn.Position = UDim2.new(0, 5, 0, y)
        btn.BackgroundColor3 = Color3.fromRGB(65, 105, 225)
        btn.Text = text
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.TextSize = 14
        btn.Font = Enum.Font.GothamBold
        btn.Parent = parent
        
        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, 5)
        btnCorner.Parent = btn
        
        btn.MouseButton1Click:Connect(callback)
        
        btn.MouseEnter:Connect(function()
            btn.BackgroundColor3 = Color3.fromRGB(85, 125, 245)
        end)
        
        btn.MouseLeave:Connect(function()
            btn.BackgroundColor3 = Color3.fromRGB(65, 105, 225)
        end)
        
        return y + 40
    end
    
    -- Initialize first tab
    UpdateTabContent("Combat")
    
    return screenGui
end

-- =============================================
-- PHÍM TẮT
-- =============================================

local MenuVisible = true
local Gui = CreateGUI()

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    -- Toggle Menu
    if input.KeyCode == Enum.KeyCode[Settings.ToggleMenuKey] then
        MenuVisible = not MenuVisible
        Gui.Enabled = MenuVisible
    end
    
    -- Panic Mode (tắt tất cả)
    if input.KeyCode == Enum.KeyCode[Settings.PanicKey] then
        Settings.AimbotEnabled = false
        Settings.InfSoruEnabled = false
        Settings.AutoV4Enabled = false
        Settings.ESPEnabled = false
        Settings.AntiStunEnabled = false
        SaveConfig()
        
        -- Thông báo
        local notif = Instance.new("Message")
        notif.Text = "⚠️ PANIC MODE - All features disabled!"
        notif.Parent = LocalPlayer.PlayerGui
        task.wait(2)
        notif:Destroy()
    end
    
    -- Toggle Aimbot
    if input.KeyCode == Enum.KeyCode[Settings.AimbotHotkey] then
        Settings.AimbotEnabled = not Settings.AimbotEnabled
        SaveConfig()
    end
    
    -- Toggle ESP
    if input.KeyCode == Enum.KeyCode[Settings.ESPHotkey] then
        Settings.ESPEnabled = not Settings.ESPEnabled
        for _, esp in pairs(ESPObjects) do
            if esp.Billboard then
                esp.Billboard.Enabled = Settings.ESPEnabled
            end
            if esp.Box then
                esp.Box.Visible = Settings.ESPEnabled
            end
        end
        SaveConfig()
    end
end)

-- =============================================
-- MAIN LOOP
-- =============================================

RunService.RenderStepped:Connect(function()
    pcall(function()
        -- Cập nhật aimbot
        UpdateAimbot()
        
        -- Cập nhật thông tin target
        UpdateTargetInfo()
        
        -- Kiểm tra V4
        CheckV4()
        
        -- Anti stun
        AntiStun()
        
        -- Cập nhật ESP
        if Settings.ESPEnabled then
            UpdateESP()
        end
        
        -- Cập nhật visual indicators
        UpdateVisuals()
    end)
end)

-- Xóa ESP khi script dừng
LocalPlayer.OnTeleport:Connect(function()
    for _, esp in pairs(ESPObjects) do
        if esp.Billboard then esp.Billboard:Destroy() end
        if esp.Box then esp.Box:Destroy() end
    end
end)

print("✅ Blox Fruits PvP Hub loaded successfully!")
print("📌 Press " .. Settings.ToggleMenuKey .. " to toggle menu")
print("📌 Press " .. Settings.PanicKey .. " for panic mode")
