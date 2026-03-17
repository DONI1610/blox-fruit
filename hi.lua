-- ========================================
-- DONI HUB - AUTO BOUNTY (CÓ INF SORU TỪ CODE CŨ)
-- ========================================

-- Đợi game load
repeat task.wait() until game:IsLoaded()

-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TeleportService = game:GetService("TeleportService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")
local VirtualUser = game:GetService("VirtualUser")
local VirtualInputManager = game:GetService("VirtualInputManager")
local HttpService = game:GetService("HttpService")

local player = Players.LocalPlayer
local replicated = ReplicatedStorage

-- Đợi nhân vật load
repeat task.wait() until player.Character and player.Character:FindFirstChild("HumanoidRootPart")
local Root = player.Character.HumanoidRootPart
local plr = player  -- Giữ nguyên tên biến từ code cũ
local Energy = plr.Character.Energy.Value  -- Giữ nguyên
local Sec = 0.1  -- Giữ nguyên

-- ========================================
-- INFINITE SORU (GIỮ NGUYÊN 100% TỪ CODE CŨ)
-- ========================================
getInfinity_Ability = function(I, e)
    if not Root then
        return;
    end;
    if I == "Soru" and e then
        for I, K in next, getgc() do
            if plr.Character.Soru then
                if typeof(K) == "function" and (getfenv(K)).script == plr.Character.Soru then
                    for I, K in next, getupvalues(K) do
                        if typeof(K) == "table" then
                            repeat
                                wait(Sec);
                                K.LastUse = 0;
                            until not e or plr.Character.Humanoid.Health <= 0;
                        end;
                    end;
                end;
            end;
        end;
    elseif I == "Energy" and e then
        plr.Character.Energy.Changed:connect(function()
            if e then
                plr.Character.Energy.Value = Energy;
            end;
        end);
    elseif I == "Observation" and e then
        local I = plr.VisionRadius;
        I.Value = math.huge;
    end;
end;

-- BẬT INF SORU NGAY LẬP TỨC
task.spawn(function()
    task.wait(3)  -- Đợi game ổn định
    getInfinity_Ability("Soru", true)
    print("✅ Đã bật INFINITE SORU từ code cũ!")
end)

-- ========================================
-- TẠO GUI BÉ XINH
-- ========================================

-- Xóa GUI cũ
pcall(function() CoreGui.DoniBounty:Destroy() end)

-- Tạo ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DoniBounty"
ScreenGui.Parent = CoreGui
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Frame chính
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 240, 0, 150)
MainFrame.Position = UDim2.new(0, 20, 0.5, -75)
MainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 20)
MainFrame.BackgroundTransparency = 0.1
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Parent = ScreenGui

-- Bo góc
local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 12)
UICorner.Parent = MainFrame

-- Viền đỏ (máu)
local UIStroke = Instance.new("UIStroke")
UIStroke.Thickness = 1.5
UIStroke.Color = Color3.fromRGB(255, 50, 50)
UIStroke.Transparency = 0.3
UIStroke.Parent = MainFrame

-- Thanh tiêu đề
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 30)
TitleBar.BackgroundColor3 = Color3.fromRGB(30, 20, 30)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 12)
TitleCorner.Parent = TitleBar

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, -30, 1, 0)
TitleLabel.Position = UDim2.new(0, 10, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "⚔️ DONI AUTO BOUNTY"
TitleLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
TitleLabel.TextSize = 14
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = TitleBar

-- Cho phép kéo
local dragging = false
local dragInput, dragStart, startPos

TitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
    end
end)

TitleBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

-- Frame nội dung
local ContentFrame = Instance.new("Frame")
ContentFrame.Size = UDim2.new(1, -10, 1, -35)
ContentFrame.Position = UDim2.new(0, 5, 0, 35)
ContentFrame.BackgroundTransparency = 1
ContentFrame.Parent = MainFrame

-- Layout
local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Padding = UDim.new(0, 3)
UIListLayout.FillDirection = Enum.FillDirection.Vertical
UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
UIListLayout.VerticalAlignment = Enum.VerticalAlignment.Top
UIListLayout.Parent = ContentFrame

-- Hàm tạo dòng
local function createLine(icon, text, color)
    local line = Instance.new("TextLabel")
    line.Size = UDim2.new(1, 0, 0, 20)
    line.BackgroundTransparency = 1
    line.Text = icon .. " " .. text
    line.TextColor3 = color or Color3.fromRGB(200, 200, 200)
    line.TextSize = 13
    line.Font = Enum.Font.Gotham
    line.TextXAlignment = Enum.TextXAlignment.Left
    line.Parent = ContentFrame
    return line
end

-- Tạo các dòng
local TimeLine = createLine("⏰", "Thời gian: 00:00", Color3.fromRGB(200, 200, 100))
local BountyLine = createLine("💰", "Bounty: 0", Color3.fromRGB(255, 200, 100))
local TargetLine = createLine("🎯", "Mục tiêu: Đang tìm...", Color3.fromRGB(100, 255, 100))
local StatusLine = createLine("⚔️", "Trạng thái: Sẵn sàng", Color3.fromRGB(100, 200, 255))
local SoruLine = createLine("🌀", "Inf Soru: BẬT", Color3.fromRGB(100, 255, 100))
local HopLine = createLine("🔄", "Hop sau: 30s", Color3.fromRGB(255, 150, 100))

-- Cập nhật thời gian
spawn(function()
    while true do
        task.wait(1)
        local gameTime = math.floor(workspace.DistributedGameTime)
        local hour = math.floor(gameTime / 3600) % 24
        local minute = math.floor(gameTime / 60) % 60
        local second = gameTime % 60
        TimeLine.Text = string.format("⏰ Thời gian: %02d:%02d:%02d", hour, minute, second)
    end
end)

-- Cập nhật bounty
spawn(function()
    while true do
        task.wait(3)
        local bounty = player:FindFirstChild("Data") and player.Data:FindFirstChild("Bounty") or player:FindFirstChild("Leaderstats") and player.Leaderstats:FindFirstChild("Bounty")
        if bounty then
            BountyLine.Text = "💰 Bounty: " .. tostring(bounty.Value)
        end
    end
end)

-- ========================================
-- HÀM DỊCH CHUYỂN
-- ========================================
local RipPart = Instance.new("Part", Workspace)
RipPart.Size = Vector3.new(1, 1, 1)
RipPart.Name = "Rip_Indra"
RipPart.Anchored = true
RipPart.CanCollide = false
RipPart.Transparency = 1

local function tweenTo(targetCFrame)
    local char = player.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    
    local hrp = char.HumanoidRootPart
    local distance = (targetCFrame.Position - hrp.Position).Magnitude
    local tweenInfo = TweenInfo.new(distance / 350, Enum.EasingStyle.Linear)
    local tween = TweenService:Create(RipPart, tweenInfo, {CFrame = targetCFrame})
    
    tween:Play()
    while tween.PlaybackState == Enum.PlaybackState.Playing do
        task.wait(0.1)
    end
end

-- ========================================
-- HÀM HOP SERVER
-- ========================================
local function hopServer()
    StatusLine.Text = "⚔️ Trạng thái: Đang hop server..."
    HopLine.Text = "🔄 Đang chuyển server..."
    
    local success = pcall(function()
        local response = game:HttpGet(string.format("https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=Asc&limit=100", game.PlaceId))
        local data = HttpService:JSONDecode(response)
        if data and data.data then
            for _, server in ipairs(data.data) do
                if server.playing < server.maxPlayers and server.id ~= game.JobId then
                    TeleportService:TeleportToPlaceInstance(game.PlaceId, server.id, player)
                    return true
                end
            end
        end
    end)
    
    if not success then
        TeleportService:Teleport(game.PlaceId, player)
    end
end

-- ========================================
-- HÀM ĐẤM THƯỜNG
-- ========================================
local function punch()
    pcall(function()
        VirtualUser:CaptureController()
        VirtualUser:Button1Down(Vector2.new(0, 0))
        task.wait(0.1)
        VirtualUser:Button1Up(Vector2.new(0, 0))
    end)
end

-- ========================================
-- KIỂM TRA PVP CỦA NGƯỜI CHƠI
-- ========================================
local function hasPvpOn(targetPlayer)
    -- Kiểm tra bằng cách xem có attribute PvP không
    if targetPlayer:GetAttribute("PvP") == false then
        return false
    end
    
    -- Kiểm tra bằng cách xem có trong chiến đấu không
    local char = targetPlayer.Character
    if char then
        local humanoid = char:FindFirstChild("Humanoid")
        if humanoid and humanoid:GetAttribute("PvP") == false then
            return false
        end
    end
    
    return true
end

-- ========================================
-- TÌM MỤC TIÊU PHÙ HỢP
-- ========================================
local function findTarget()
    local myLevel = player.Data.Level.Value
    local bestTarget = nil
    local bestDistance = math.huge
    
    for _, otherPlayer in ipairs(Players:GetPlayers()) do
        -- Bỏ qua bản thân
        if otherPlayer ~= player then
            
            -- Kiểm tra level (chỉ săn người kém hơn 100 level)
            local theirLevel = otherPlayer.Data.Level.Value
            if theirLevel < myLevel and (myLevel - theirLevel) <= 100 then
                
                -- Kiểm tra PvP
                if hasPvpOn(otherPlayer) then
                    
                    -- Kiểm khoảng cách
                    local char = otherPlayer.Character
                    if char and char:FindFirstChild("HumanoidRootPart") then
                        local distance = (Root.Position - char.HumanoidRootPart.Position).Magnitude
                        
                        -- Chọn người gần nhất
                        if distance < bestDistance then
                            bestDistance = distance
                            bestTarget = otherPlayer
                        end
                    end
                end
            end
        end
    end
    
    return bestTarget
end

-- ========================================
-- TẤN CÔNG MỤC TIÊU
-- ========================================
local function attackTarget(target)
    if not target or not target.Character then return end
    
    local targetChar = target.Character
    local targetHrp = targetChar:FindFirstChild("HumanoidRootPart")
    if not targetHrp then return end
    
    -- Cập nhật GUI
    TargetLine.Text = "🎯 Mục tiêu: " .. target.Name
    TargetLine.TextColor3 = Color3.fromRGB(255, 100, 100)
    
    -- Reset thời gian không có mục tiêu
    noTargetTime = 0
    
    -- Bay đến gần
    tweenTo(targetHrp.CFrame * CFrame.new(0, 10, 5))
    
    -- Tấn công liên tục
    while target and target.Character and targetChar:FindFirstChild("Humanoid") and targetChar.Humanoid.Health > 0 do
        -- Đấm liên tục
        for i = 1, 5 do
            punch()
            task.wait(0.1)
        end
        
        -- Bay theo nếu cần
        if targetHrp then
            tweenTo(targetHrp.CFrame * CFrame.new(0, 10, 3))
        end
        
        task.wait()
    end
    
    TargetLine.Text = "🎯 Mục tiêu: Đang tìm..."
    TargetLine.TextColor3 = Color3.fromRGB(100, 255, 100)
end

-- ========================================
-- MAIN LOOP - SĂN BOUNTY + AUTO HOP
-- ========================================
local noTargetTime = 0

spawn(function()
    StatusLine.Text = "⚔️ Trạng thái: Đang săn..."
    
    while true do
        task.wait(2)
        
        -- Tìm mục tiêu mới
        local target = findTarget()
        
        if target then
            -- Có mục tiêu
            StatusLine.Text = "⚔️ Trạng thái: Đang chiến đấu"
            noTargetTime = 0
            HopLine.Text = "🔄 Hop sau: 30s"
            attackTarget(target)
        else
            -- Không có mục tiêu
            noTargetTime = noTargetTime + 2
            local timeLeft = 30 - noTargetTime
            if timeLeft < 0 then timeLeft = 0 end
            
            StatusLine.Text = "⚔️ Trạng thái: Đang tìm mục tiêu"
            HopLine.Text = "🔄 Hop sau: " .. timeLeft .. "s"
            
            -- Bay vòng quanh tìm
            tweenTo(Root.CFrame * CFrame.new(math.random(-50, 50), 0, math.random(-50, 50)))
            
            -- HOP SAU 30 GIÂY KHÔNG CÓ MỤC TIÊU
            if noTargetTime >= 30 then
                StatusLine.Text = "⚔️ Trạng thái: Hết mục tiêu, đang hop..."
                hopServer()
                break
            end
        end
    end
end)

-- ========================================
-- NO CLIP (XUYÊN TƯỜNG)
-- ========================================
RunService.Stepped:Connect(function()
    local char = player.Character
    if char then
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
end)

-- ========================================
-- HOÀN TẤT
-- ========================================
print("⚔️ DONI AUTO BOUNTY - ĐÃ SẴN SÀNG!")
print("🎯 Chỉ săn người kém hơn 100 level")
print("🔄 Auto hop sau 30s không có mục tiêu")
print("🌀 INF SORU - ĐÃ BẬT TỪ CODE CŨ")
