--[[
    Blox Fruits PvP Only Script
    Based on doni.lua - Only Combat PVP Tab Retained
]]

-- Khởi tạo Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local VirtualUser = game:GetService("VirtualUser")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")
local TeleportService = game:GetService("TeleportService")
local Stats = game:GetService("Stats")

-- Biến cơ bản
local ply = Players
local plr = ply.LocalPlayer
local Root = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
local replicated = ReplicatedStorage
local TeamSelf = plr.Team
local vim1 = VirtualInputManager
local vim2 = VirtualUser
local Sec = 0.1

-- Kiểm tra game
if game.PlaceId == 2753915549 or game.PlaceId == 85211729168715 then
    World1 = true
elseif game.PlaceId == 4442272183 or game.PlaceId == 79091703265657 then
    World2 = true
elseif game.PlaceId == 7449423635 or game.PlaceId == 100117331123089 then
    World3 = true
end

-- Chờ game load
repeat
    wait()
until plr.PlayerGui:FindFirstChild("Main") and plr.PlayerGui.Main:FindFirstChild("Loading") and game:IsLoaded()

-- =============================================
-- HÀM INFINITY ABILITY (TỪ SCRIPT GỐC)
-- =============================================

local Energy = plr.Character and plr.Character:FindFirstChild("Energy") and plr.Character.Energy.Value or 100

getInfinity_Ability = function(ability, enabled)
    if not plr.Character or not plr.Character:FindFirstChild("HumanoidRootPart") then
        return
    end
    
    if ability == "Soru" and enabled then
        for _, func in next, getgc() do
            if plr.Character.Soru then
                if typeof(func) == "function" and getfenv(func).script == plr.Character.Soru then
                    for _, upvalue in next, getupvalues(func) do
                        if typeof(upvalue) == "table" then
                            spawn(function()
                                while enabled and plr.Character and plr.Character.Humanoid.Health > 0 do
                                    wait(Sec)
                                    upvalue.LastUse = 0
                                end
                            end)
                        end
                    end
                end
            end
        end
    elseif ability == "Energy" and enabled then
        plr.Character.Energy.Changed:Connect(function()
            if enabled then
                plr.Character.Energy.Value = Energy
            end
        end)
    elseif ability == "Observation" and enabled then
        local visionRadius = plr.VisionRadius
        if visionRadius then
            visionRadius.Value = math.huge
        end
    end
end

-- =============================================
-- HÀM AIMBOT (TỪ SCRIPT GỐC)
-- =============================================

-- Hook Remote cho aimbot
local J = getrawmetatable(game)
local i = J.__namecall
setreadonly(J, false)

J.__namecall = newcclosure(function(...)
    local method = getnamecallmethod()
    local args = { ... }
    
    if tostring(method) == "FireServer" then
        if tostring(args[1]) == "RemoteEvent" then
            if tostring(args[2]) ~= "true" and tostring(args[2]) ~= "false" then
                if _G.AimMethod and (ABmethod == "AimBots Skill" or ABmethod == "Auto Aimbots") then
                    args[2] = MousePos
                    return i(unpack(args))
                end
            end
        end
    end
    return i(...)
end)

-- =============================================
-- BIẾN TOÀN CỤC CHO PVP
-- =============================================

local MousePos = Vector3.new(0, 0, 0)
local ABmethod = "Auto Aimbots"
local CurrentTarget = nil
local TargetInfo = { Name = "None", Distance = 0, Health = 0 }

-- ESP Variables
local ESPObjects = {}
local Number = math.random(1, 1000000)

-- Visual Variables
local FPS = 0
local FPSTime = 0
local FPSFrames = 0
local Ping = 0

-- =============================================
-- HÀM HỖ TRỢ
-- =============================================

function isnil(obj)
    return obj == nil
end

local function round(num)
    return math.floor(tonumber(num) + 0.5)
end

-- Kiểm tra người chơi còn sống
function IsAlive(player)
    if not player or not player.Character then return false end
    local humanoid = player.Character:FindFirstChild("Humanoid")
    return humanoid and humanoid.Health > 0
end

-- Kiểm tra cùng team
function IsSameTeam(player)
    return player and plr.Team and player.Team == plr.Team
end

-- Lấy người chơi gần nhất
function GetClosestPlayer()
    local closest = nil
    local shortestDist = 300 -- Khoảng cách mặc định
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= plr and IsAlive(player) then
            if _G.NoAimTeam and IsSameTeam(player) then
                -- Skip
            else
                local root = player.Character:FindFirstChild("HumanoidRootPart")
                if root and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                    local dist = (plr.Character.HumanoidRootPart.Position - root.Position).Magnitude
                    if dist < shortestDist then
                        shortestDist = dist
                        closest = player
                    end
                end
            end
        end
    end
    
    return closest
end

-- =============================================
-- AIMBOT LOOP
-- =============================================

task.spawn(function()
    while task.wait() do
        pcall(function()
            if _G.AimMethod then
                if ABmethod == "AimBots Skill" then
                    -- Aim vào người chơi đã chọn
                    for _, player in ipairs(Players:GetPlayers()) do
                        if player.Name == _G.PlayersList and player.Team ~= plr.Team then
                            if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                                MousePos = player.Character.HumanoidRootPart.Position
                                CurrentTarget = player
                            end
                        end
                    end
                elseif ABmethod == "Auto Aimbots" then
                    -- Auto aim người gần nhất
                    local closest = GetClosestPlayer()
                    if closest then
                        CurrentTarget = closest
                        if closest.Character and closest.Character:FindFirstChild("HumanoidRootPart") then
                            MousePos = closest.Character.HumanoidRootPart.Position
                        end
                    else
                        CurrentTarget = nil
                    end
                end
            end
            
            -- Cập nhật thông tin target
            if CurrentTarget and IsAlive(CurrentTarget) then
                local root = CurrentTarget.Character:FindFirstChild("HumanoidRootPart")
                if root and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                    TargetInfo.Name = CurrentTarget.Name
                    TargetInfo.Distance = math.floor((plr.Character.HumanoidRootPart.Position - root.Position).Magnitude)
                    TargetInfo.Health = math.floor(CurrentTarget.Character.Humanoid.Health)
                end
            else
                TargetInfo.Name = "None"
                TargetInfo.Distance = 0
                TargetInfo.Health = 0
            end
        end)
    end
end)

-- =============================================
-- AIMBOT CAMERA
-- =============================================

task.spawn(function()
    while task.wait(Sec) do
        pcall(function()
            if _G.AimCam then
                local camera = workspace.CurrentCamera
                
                local function getClosestPlayer()
                    local closest = nil
                    local shortestDist = math.huge
                    
                    for _, player in ipairs(Players:GetPlayers()) do
                        if player ~= plr then
                            if player.Character and player.Character:FindFirstChild("Head") and _G.AimCam and player.Character.Humanoid.Health > 0 then
                                if plr.Character and plr.Character:FindFirstChild("Head") then
                                    local dist = (player.Character.Head.Position - plr.Character.Head.Position).Magnitude
                                    if dist < shortestDist then
                                        shortestDist = dist
                                        closest = player
                                    end
                                end
                            end
                        end
                    end
                    return closest
                end
                
                local target = getClosestPlayer()
                if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
                    camera.CFrame = CFrame.new(camera.CFrame.Position, target.Character.HumanoidRootPart.Position)
                end
            end
        end)
    end
end)

-- =============================================
-- INFINITY ABILITIES
-- =============================================

-- Inf Soru
task.spawn(function()
    while wait(0.5) do
        if _G.InfSoru then
            pcall(function()
                getInfinity_Ability("Soru", _G.InfSoru)
            end)
        end
    end
end)

-- Inf Energy
task.spawn(function()
    while wait(0.5) do
        if _G.infEnergy then
            pcall(function()
                getInfinity_Ability("Energy", _G.infEnergy)
            end)
        end
    end
end)

-- Inf Observation Range
task.spawn(function()
    while wait(0.5) do
        if _G.InfiniteObRange then
            pcall(function()
                getInfinity_Ability("Observation", _G.InfiniteObRange)
            end)
        end
    end
end)

-- =============================================
-- AUTO V4
-- =============================================

task.spawn(function()
    while wait(0.5) do
        if _G.RaceClickAutov4 then
            pcall(function()
                if plr.Character and plr.Character:FindFirstChild("RaceEnergy") then
                    if plr.Character.RaceEnergy.Value == 1 then
                        -- Gửi phím Y để kích hoạt V4
                        vim1:SendKeyEvent(true, "Y", false, game)
                        wait(0.1)
                        vim1:SendKeyEvent(false, "Y", false, game)
                    end
                end
            end)
        end
    end
end)

-- Auto V3
task.spawn(function()
    while wait(30) do
        if _G.RaceClickAutov3 then
            pcall(function()
                replicated.Remotes.CommE:FireServer("ActivateAbility")
            end)
        end
    end
end)

-- =============================================
-- ESP FUNCTIONS
-- =============================================

-- ESP Players
EspPly = function()
    for _, player in next, Players:GetPlayers() do
        pcall(function()
            if not isnil(player.Character) then
                if PlayerEsp then
                    if not isnil(player.Character.Head) and not player.Character.Head:FindFirstChild("NameEsp" .. Number) then
                        local billboard = Instance.new("BillboardGui", player.Character.Head)
                        billboard.Name = "NameEsp" .. Number
                        billboard.ExtentsOffset = Vector3.new(0, 1, 0)
                        billboard.Size = UDim2.new(1, 200, 1, 30)
                        billboard.Adornee = player.Character.Head
                        billboard.AlwaysOnTop = true
                        
                        local label = Instance.new("TextLabel", billboard)
                        label.Font = Enum.Font.Code
                        label.FontSize = "Size14"
                        label.TextWrapped = true
                        label.Text = player.Name .. " \n" .. round((plr.Character.Head.Position - player.Character.Head.Position).Magnitude / 3) .. " M"
                        label.Size = UDim2.new(1, 0, 1, 0)
                        label.TextYAlignment = "Top"
                        label.BackgroundTransparency = 1
                        label.TextStrokeTransparency = 0.5
                        
                        if player.Team == TeamSelf then
                            label.TextColor3 = Color3.new(0, 0, 255)
                        else
                            label.TextColor3 = Color3.new(255, 0, 0)
                        end
                    else
                        if player.Character.Head and player.Character.Head:FindFirstChild("NameEsp" .. Number) then
                            local label = player.Character.Head["NameEsp" .. Number].TextLabel
                            label.Text = player.Data.Level.Value .. " | " .. player.Name .. " | " .. round((plr.Character.Head.Position - player.Character.Head.Position).Magnitude / 3) .. " M\nHealth : " .. round((player.Character.Humanoid.Health * 100) / player.Character.Humanoid.MaxHealth) .. "%"
                        end
                    end
                else
                    if player.Character.Head and player.Character.Head:FindFirstChild("NameEsp" .. Number) then
                        player.Character.Head:FindFirstChild("NameEsp" .. Number):Destroy()
                    end
                end
            end
        end)
    end
end

-- ESP Fruits
DevEsp = function()
    for _, obj in next, workspace:GetChildren() do
        pcall(function()
            if DevilFruitESP then
                if string.find(obj.Name, "Fruit") then
                    if not obj.Handle:FindFirstChild("NameEsp" .. Number) then
                        local billboard = Instance.new("BillboardGui", obj.Handle)
                        billboard.Name = "NameEsp" .. Number
                        billboard.ExtentsOffset = Vector3.new(0, 1, 0)
                        billboard.Size = UDim2.new(1, 200, 1, 30)
                        billboard.Adornee = obj.Handle
                        billboard.AlwaysOnTop = true
                        
                        local label = Instance.new("TextLabel", billboard)
                        label.Font = Enum.Font.Code
                        label.FontSize = "Size14"
                        label.TextWrapped = true
                        label.Text = obj.Name .. " \n" .. round((plr.Character.Head.Position - obj.Handle.Position).Magnitude / 3) .. " M"
                        label.Size = UDim2.new(1, 0, 1, 0)
                        label.TextYAlignment = "Top"
                        label.BackgroundTransparency = 1
                        label.TextStrokeTransparency = 0.5
                        label.TextColor3 = Color3.fromRGB(255, 255, 255)
                    else
                        obj.Handle["NameEsp" .. Number].TextLabel.Text = "[" .. obj.Name .. "]" .. "   \n" .. round((plr.Character.Head.Position - obj.Handle.Position).Magnitude / 3) .. " M"
                    end
                end
            else
                if obj.Handle and obj.Handle:FindFirstChild("NameEsp" .. Number) then
                    obj.Handle:FindFirstChild("NameEsp" .. Number):Destroy()
                end
            end
        end)
    end
end

-- =============================================
-- VISUAL INDICATORS
-- =============================================

-- Tạo GUI cho visual indicators
local Visuals = nil

task.spawn(function()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "PvPVisuals"
    screenGui.Parent = plr:FindFirstChild("PlayerGui") or game:GetService("CoreGui")
    
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
    
    Visuals = {
        ScreenGui = screenGui,
        MainFrame = mainFrame,
        FPS = fpsLabel,
        Ping = pingLabel,
        Target = targetLabel,
        Distance = distanceLabel
    }
end)

-- Cập nhật visual indicators
task.spawn(function()
    while wait(0.1) do
        pcall(function()
            if not Visuals then return end
            
            if _G.ShowFPS then
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
            
            if _G.ShowPing then
                if Stats and Stats.Network and Stats.Network.ServerStatsItem then
                    Ping = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue())
                end
                Visuals.Ping.Text = "Ping: " .. Ping .. "ms"
                Visuals.Ping.Visible = true
            else
                Visuals.Ping.Visible = false
            end
            
            if _G.ShowTargetInfo then
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
-- ESP UPDATE LOOP
-- =============================================

task.spawn(function()
    while wait(0.1) do
        pcall(function()
            if PlayerEsp then
                EspPly()
            end
            if DevilFruitESP then
                DevEsp()
            end
        end)
    end
end)

-- =============================================
-- ACCEPT ALLIES
-- =============================================

task.spawn(function()
    while wait(Sec) do
        if _G.AcceptAlly then
            pcall(function()
                for _, player in ipairs(Players:GetPlayers()) do
                    if player ~= plr and player.Character and player.Character:FindFirstChild("Humanoid") then
                        replicated.Remotes.CommF_:InvokeServer("AcceptAlly", player.Name)
                    end
                end
            end)
        end
    end
end)

-- =============================================
-- HOP SERVER FUNCTION
-- =============================================

Hop = function()
    pcall(function()
        for i = math.random(1, math.random(40, 75)), 100, 1 do
            local servers = replicated.__ServerBrowser:InvokeServer(i)
            for id, server in next, servers do
                if tonumber(server.Count) < 12 then
                    TeleportService:TeleportToPlaceInstance(game.PlaceId, id)
                end
            end
        end
    end)
end

-- =============================================
-- LOAD THƯ VIỆN UI
-- =============================================

local Library = (loadstring(game:HttpGet("https://pastefy.app/TvTv53s5/raw")))()

-- =============================================
-- TẠO WINDOW VÀ TAB
-- =============================================

local Window = Library:NewWindow()
local CombatTab = Window:T("⚔️ COMBAT PVP")

-- =============================================
-- SECTION: AIMBOT SETTINGS
-- =============================================

local aimbotSection = CombatTab:AddSection("🎯 AIMBOT SETTINGS")

aimbotSection:AddToggle({
    Title = "Enable Aimbot Skills",
    Description = "Tự động nhắm kỹ năng vào mục tiêu",
    Default = false,
    Callback = function(value)
        _G.AimMethod = value
    end
})

aimbotSection:AddToggle({
    Title = "Enable Aimbot Camera",
    Description = "Camera tự động xoay theo mục tiêu",
    Default = false,
    Callback = function(value)
        _G.AimCam = value
    end
})

local aimMethods = { "Auto Aimbots", "AimBots Skill" }
aimbotSection:AddDropdown({
    Title = "Aimbot Method",
    Description = "Chọn phương thức aimbot",
    Values = aimMethods,
    Default = "Auto Aimbots",
    Multi = false,
    Callback = function(value)
        ABmethod = value
    end
})

-- Lấy danh sách người chơi
local playerList = {}
for _, player in ipairs(Players:GetPlayers()) do
    table.insert(playerList, player.Name)
end

aimbotSection:AddDropdown({
    Title = "Select Target",
    Description = "Chọn người chơi để aim (cho AimBots Skill)",
    Values = playerList,
    Default = nil,
    Multi = false,
    Callback = function(value)
        _G.PlayersList = value
    end
})

aimbotSection:AddToggle({
    Title = "Ignore Same Team",
    Description = "Không aim vào người cùng team",
    Default = true,
    Callback = function(value)
        _G.NoAimTeam = value
    end
})

-- =============================================
-- SECTION: INFINITY ABILITIES
-- =============================================

local infinitySection = CombatTab:AddSection("♾️ INFINITY ABILITIES")

infinitySection:AddToggle({
    Title = "Infinite Soru",
    Description = "Soru không cooldown",
    Default = false,
    Callback = function(value)
        _G.InfSoru = value
    end
})

infinitySection:AddToggle({
    Title = "Infinite Energy",
    Description = "Năng lượng vô hạn",
    Default = false,
    Callback = function(value)
        _G.infEnergy = value
    end
})

infinitySection:AddToggle({
    Title = "Infinite Observation Range",
    Description = "Tầm nhìn Observation vô hạn",
    Default = false,
    Callback = function(value)
        _G.InfiniteObRange = value
    end
})

-- =============================================
-- SECTION: RACE ABILITIES
-- =============================================

local raceSection = CombatTab:AddSection("👤 RACE ABILITIES")

raceSection:AddToggle({
    Title = "Auto Race V3",
    Description = "Tự động kích hoạt kỹ năng tộc V3",
    Default = false,
    Callback = function(value)
        _G.RaceClickAutov3 = value
    end
})

raceSection:AddToggle({
    Title = "Auto Race V4",
    Description = "Tự động kích hoạt kỹ năng tộc V4 (phím Y)",
    Default = false,
    Callback = function(value)
        _G.RaceClickAutov4 = value
    end
})

-- =============================================
-- SECTION: ESP
-- =============================================

local espSection = CombatTab:AddSection("👁️ ESP")

espSection:AddToggle({
    Title = "Player ESP",
    Description = "Nhìn thấy người chơi qua tường",
    Default = false,
    Callback = function(value)
        PlayerEsp = value
    end
})

espSection:AddToggle({
    Title = "Fruit ESP",
    Description = "Nhìn thấy trái ác quỷ",
    Default = false,
    Callback = function(value)
        DevilFruitESP = value
    end
})

-- =============================================
-- SECTION: VISUAL INDICATORS
-- =============================================

local visualSection = CombatTab:AddSection("📊 VISUAL INDICATORS")

visualSection:AddToggle({
    Title = "Show FPS",
    Description = "Hiển thị FPS",
    Default = true,
    Callback = function(value)
        _G.ShowFPS = value
    end
})

visualSection:AddToggle({
    Title = "Show Ping",
    Description = "Hiển thị Ping",
    Default = true,
    Callback = function(value)
        _G.ShowPing = value
    end
})

visualSection:AddToggle({
    Title = "Show Target Info",
    Description = "Hiển thị thông tin mục tiêu",
    Default = true,
    Callback = function(value)
        _G.ShowTargetInfo = value
    end
})

-- =============================================
-- SECTION: UTILITIES
-- =============================================

local utilitySection = CombatTab:AddSection("🛠️ UTILITIES")

utilitySection:AddToggle({
    Title = "Auto Accept Allies",
    Description = "Tự động chấp nhận lời mời đồng minh",
    Default = false,
    Callback = function(value)
        _G.AcceptAlly = value
    end
})

utilitySection:AddButton({
    Title = "Hop Server",
    Description = "Chuyển sang server khác",
    Callback = function()
        Hop()
    end
})

utilitySection:AddButton({
    Title = "Rejoin Server",
    Description = "Vào lại server hiện tại",
    Callback = function()
        TeleportService:Teleport(game.PlaceId, plr)
    end
})

-- =============================================
-- TELEPORT TO PLAYER
-- =============================================

CombatTab:AddSeperator("📌 TELEPORT")

CombatTab:AddToggle({
    Title = "Teleport to Selected Player",
    Description = "Dịch chuyển đến người chơi đã chọn",
    Default = false,
    Callback = function(value)
        _G.TpPly = value
        if value then
            spawn(function()
                while _G.TpPly do
                    wait()
                    if _G.PlayersList and Players[_G.PlayersList] and Players[_G.PlayersList].Character then
                        local targetRoot = Players[_G.PlayersList].Character:FindFirstChild("HumanoidRootPart")
                        if targetRoot then
                            plr.Character.HumanoidRootPart.CFrame = targetRoot.CFrame
                        end
                    end
                end
            end)
        end
    end
})

CombatTab:AddToggle({
    Title = "Spectate Selected Player",
    Description = "Xem từ góc nhìn người chơi đã chọn",
    Default = false,
    Callback = function(value)
        if value then
            spawn(function()
                while value do
                    wait(0.1)
                    if _G.PlayersList and Players[_G.PlayersList] and Players[_G.PlayersList].Character then
                        workspace.Camera.CameraSubject = Players[_G.PlayersList].Character.Humanoid
                    end
                end
                workspace.Camera.CameraSubject = plr.Character.Humanoid
            end)
        end
    end
})

-- =============================================
-- ANTI AFK
-- =============================================

plr.Idled:connect(function()
    vim2:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
    wait(1)
    vim2:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
end)

print("✅ Blox Fruits PvP Only Script Loaded!")
print("⚔️ Only Combat PVP Tab - All Farm Features Removed")
