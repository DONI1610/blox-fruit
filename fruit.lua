--[[
    SCRIPT SĂN FRUIT - ĐÃ SỬA LỖI HOP
    - Tự động random fruit khi đủ tiền
    - Tự động nhặt fruit trên map
    - Tự động lưu trữ vào kho
    - Tự động chọn phe (Hải tặc/Hải quân)
    - TỰ ĐỘNG HOP SAU 10 GIÂY NẾU KHÔNG CÓ FRUIT
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local VirtualUser = game:GetService("VirtualUser")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local RootPart = Character:WaitForChild("HumanoidRootPart")

-- CẤU HÌNH
local Settings = {
    AutoRandom = true,           -- Tự động random fruit
    AutoCollect = true,          -- Tự động nhặt fruit
    AutoStore = true,            -- Tự động lưu trữ fruit
    AutoHop = true,              -- Tự động hop server
    AutoJoinTeam = true,         -- Tự động chọn phe
    
    -- CẤU HÌNH THỜI GIAN HOP
    HopDelay = 10,                -- Số giây đếm ngược trước khi hop
    CheckInterval = 2,            -- Thời gian kiểm tra (giây)
    MaxNoFruitChecks = 3,         -- Số lần kiểm tra liên tiếp không có fruit
    
    -- CẤU HÌNH KHÁC
    MinBeliForRandom = 500000,    -- Tiền tối thiểu để random
    MaxFruitsInInventory = 5,      -- Số fruit tối đa trong hành trang
    TeleportSpeed = 300,           -- Tốc độ di chuyển
    ShowESP = true,                -- Hiển thị ESP
    
    -- CHỌN PHE (1 = Hải tặc, 2 = Hải quân)
    TeamToJoin = 1,
}

-- BIẾN TOÀN CỤC
local FruitsOnMap = {}
local Collecting = false
local CurrentFruit = nil
local IsHopping = false
local StoredFruits = {}
local NoFruitCount = 0
local JoinedTeam = false
local StartTime = tick()
local HopCountdown = false
local HopTimer = 0
local HopThread = nil

-- TẠO PART TELEPORT
local TweenPart = Instance.new("Part", Workspace)
TweenPart.Name = "FruitCollector_Part"
TweenPart.Size = Vector3.new(1, 1, 1)
TweenPart.Anchored = true
TweenPart.CanCollide = false
TweenPart.CanTouch = false
TweenPart.Transparency = 1

-- HÀM TELEPORT MƯỢT MÀ
local function tweenTo(targetCFrame)
    if not targetCFrame then return end
    
    local distance = (targetCFrame.Position - RootPart.Position).Magnitude
    local tweenInfo = TweenInfo.new(distance / Settings.TeleportSpeed, Enum.EasingStyle.Linear)
    local tween = TweenService:Create(TweenPart, tweenInfo, {CFrame = targetCFrame})
    
    TweenPart.CFrame = RootPart.CFrame
    tween:Play()
    
    local connection
    connection = RunService.Heartbeat:Connect(function()
        if tween.PlaybackState == Enum.PlaybackState.Playing then
            RootPart.CFrame = TweenPart.CFrame
        else
            connection:Disconnect()
        end
    end)
    
    return tween
end

-- ANTI-AFK
LocalPlayer.Idled:Connect(function()
    VirtualUser:Button2Down(Vector2.new(0, 0), Workspace.CurrentCamera.CFrame)
    wait(1)
    VirtualUser:Button2Up(Vector2.new(0, 0), Workspace.CurrentCamera.CFrame)
end)

-- KIỂM TRA KẾT NỐI GAME
repeat
    wait(1)
until game:IsLoaded() and LocalPlayer.PlayerGui:FindFirstChild("Main")

-- XÁC ĐỊNH WORLD
local World
if game.PlaceId == 2753915549 or game.PlaceId == 85211729168715 then
    World = 1
elseif game.PlaceId == 4442272183 or game.PlaceId == 79091703265657 then
    World = 2
elseif game.PlaceId == 7449423635 or game.PlaceId == 100117331123089 then
    World = 3
end

-- HÀM CHỌN PHE
local function joinTeam()
    if not Settings.AutoJoinTeam or JoinedTeam then return end
    
    if LocalPlayer.Team ~= nil then
        print("✅ Đã có phe: " .. tostring(LocalPlayer.Team))
        JoinedTeam = true
        return
    end
    
    print("🔄 Đang chọn phe...")
    
    if Settings.TeamToJoin == 1 then
        local success = pcall(function()
            ReplicatedStorage.Remotes.CommF_:InvokeServer("SetTeam", "Pirates")
        end)
        if success then
            print("🏴‍☠️ Đã gia nhập Hải tặc!")
        end
    elseif Settings.TeamToJoin == 2 then
        local success = pcall(function()
            ReplicatedStorage.Remotes.CommF_:InvokeServer("SetTeam", "Marines")
        end)
        if success then
            print("⚓ Đã gia nhập Hải quân!")
        end
    end
    
    JoinedTeam = true
    wait(2)
end

-- HÀM LẤY BELI
local function getBeli()
    return LocalPlayer.Data.Beli.Value
end

-- HÀM ĐẾM FRUIT TRONG HÀNH TRANG
local function countFruitsInInventory()
    local count = 0
    for _, item in pairs(LocalPlayer.Backpack:GetChildren()) do
        if item:IsA("Tool") and item.Name:find("Fruit") then
            count = count + 1
        end
    end
    
    for _, item in pairs(Character:GetChildren()) do
        if item:IsA("Tool") and item.Name:find("Fruit") then
            count = count + 1
        end
    end
    
    return count
end

-- HÀM LẤY DANH SÁCH FRUIT
local function getFruitsInInventory()
    local fruits = {}
    
    for _, item in pairs(LocalPlayer.Backpack:GetChildren()) do
        if item:IsA("Tool") and item.Name:find("Fruit") then
            table.insert(fruits, {
                Item = item,
                Name = item.Name,
                Location = "Backpack"
            })
        end
    end
    
    for _, item in pairs(Character:GetChildren()) do
        if item:IsA("Tool") and item.Name:find("Fruit") then
            table.insert(fruits, {
                Item = item,
                Name = item.Name,
                Location = "Character"
            })
        end
    end
    
    return fruits
end

-- HÀM KIỂM TRA FRUIT ĐÃ LƯU
local function isFruitStored(fruitName)
    for _, stored in pairs(StoredFruits) do
        if stored == fruitName then
            return true
        end
    end
    return false
end

-- HÀM LƯU TRỮ FRUIT
local function storeFruit(fruitItem, fruitName)
    if not Settings.AutoStore then return end
    
    if isFruitStored(fruitName) then return end
    
    local eatRemote = fruitItem:FindFirstChild("EatRemote", true)
    if not eatRemote then return end
    
    local success = pcall(function()
        return ReplicatedStorage.Remotes.CommF_:InvokeServer("StoreFruit", fruitItem)
    end)
    
    if success then
        print("💾 Đã lưu trữ: " .. fruitName)
        table.insert(StoredFruits, fruitName)
    end
end

-- HÀM LƯU TRỮ TẤT CẢ FRUIT
local function storeAllFruits()
    if not Settings.AutoStore then return end
    
    local fruits = getFruitsInInventory()
    if #fruits == 0 then return end
    
    print("🔄 Đang lưu " .. #fruits .. " fruit...")
    
    for _, fruit in pairs(fruits) do
        if fruit.Location == "Character" then
            fruit.Item.Parent = LocalPlayer.Backpack
            wait(0.2)
        end
        storeFruit(fruit.Item, fruit.Name)
        wait(0.3)
    end
end

-- HÀM RANDOM FRUIT
local function randomFruit()
    if not Settings.AutoRandom then return end
    
    if Settings.AutoJoinTeam and not JoinedTeam then
        joinTeam()
    end
    
    local beli = getBeli()
    if beli >= Settings.MinBeliForRandom then
        
        local fruitCount = countFruitsInInventory()
        if fruitCount >= Settings.MaxFruitsInInventory then
            storeAllFruits()
            wait(1)
        end
        
        print("🎲 Đang random fruit...")
        ReplicatedStorage.Remotes.CommF_:InvokeServer("Cousin", "Buy")
        wait(2)
    end
end

-- HÀM SCAN FRUIT TRÊN MAP
local function scanForFruits()
    FruitsOnMap = {}
    
    for _, obj in pairs(Workspace:GetChildren()) do
        if obj.Name:find("Fruit") and obj:IsA("Model") then
            local handle = obj:FindFirstChild("Handle")
            if handle then
                local distance = (handle.Position - RootPart.Position).Magnitude
                table.insert(FruitsOnMap, {
                    Model = obj,
                    Handle = handle,
                    Position = handle.Position,
                    Distance = distance,
                    Name = obj.Name
                })
            end
        end
    end
    
    table.sort(FruitsOnMap, function(a, b)
        return a.Distance < b.Distance
    end)
    
    return #FruitsOnMap
end

-- HÀM TẠO ESP
local function createFruitESP(fruitData)
    if not Settings.ShowESP then return end
    
    local handle = fruitData.Handle
    if not handle:FindFirstChild("FruitESP") then
        local billboard = Instance.new("BillboardGui")
        billboard.Name = "FruitESP"
        billboard.Size = UDim2.new(0, 200, 0, 50)
        billboard.StudsOffset = Vector3.new(0, 3, 0)
        billboard.Adornee = handle
        billboard.AlwaysOnTop = true
        
        local text = Instance.new("TextLabel")
        text.Size = UDim2.new(1, 0, 1, 0)
        text.BackgroundTransparency = 1
        text.TextColor3 = Color3.fromRGB(255, 200, 0)
        text.TextStrokeTransparency = 0.3
        text.Font = Enum.Font.GothamBold
        text.TextSize = 16
        text.Text = fruitData.Name .. "\n" .. math.floor(fruitData.Distance/3) .. "m"
        
        text.Parent = billboard
        billboard.Parent = handle
    end
end

-- HÀM THU THẬP FRUIT
local function collectFruit(fruitData)
    if Collecting then return end
    Collecting = true
    CurrentFruit = fruitData
    
    print("🍎 Đang đến: " .. fruitData.Name)
    
    local tween = tweenTo(CFrame.new(fruitData.Position))
    
    while tween and tween.PlaybackState == Enum.PlaybackState.Playing do
        if not fruitData.Model or not fruitData.Model.Parent then
            tween:Cancel()
            Collecting = false
            return
        end
        wait(0.1)
    end
    
    if fruitData.Model and fruitData.Model.Parent then
        wait(0.5)
        firetouchinterest(RootPart, fruitData.Handle, 0)
        wait(0.1)
        firetouchinterest(RootPart, fruitData.Handle, 1)
        print("✅ Đã nhặt: " .. fruitData.Name)
        
        wait(1)
        
        if Settings.AutoStore then
            for _, fruit in pairs(getFruitsInInventory()) do
                if fruit.Name == fruitData.Name and not isFruitStored(fruit.Name) then
                    storeFruit(fruit.Item, fruit.Name)
                    break
                end
            end
        end
        
        wait(0.5)
    end
    
    Collecting = false
    CurrentFruit = nil
end

-- ============================================
-- HÀM HOP SERVER - ĐÃ SỬA LỖI
-- ============================================
local function hopToNewServer()
    if IsHopping then return end
    IsHopping = true
    
    print("🔍 Đang tìm server mới...")
    
    -- PHƯƠNG ÁN 1: Hop random (đơn giản nhất)
    local success = pcall(function()
        TeleportService:Teleport(game.PlaceId, LocalPlayer)
    end)
    
    if success then
        print("🌍 Đang chuyển server...")
        return
    end
    
    -- PHƯƠNG ÁN 2: Nếu cách 1 fail, thử cách 2
    print("⚠️ Cách 1 fail, thử cách 2...")
    
    local function getServers()
        local url = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?limit=100"
        local success, response = pcall(function()
            return HttpService:JSONDecode(game:HttpGet(url))
        end)
        
        if success and response and response.data then
            return response.data
        end
        return {}
    end
    
    local servers = getServers()
    local validServers = {}
    
    for _, server in pairs(servers) do
        if server.playing < server.maxPlayers and server.id ~= game.JobId then
            table.insert(validServers, server)
        end
    end
    
    if #validServers > 0 then
        -- Chọn server có ít người nhất
        local bestServer = validServers[1]
        for _, server in pairs(validServers) do
            if server.playing < bestServer.playing then
                bestServer = server
            end
        end
        
        print("🌍 Chuyển đến server: " .. bestServer.id)
        print("👥 Số người: " .. bestServer.playing .. "/" .. bestServer.maxPlayers)
        
        TeleportService:TeleportToPlaceInstance(game.PlaceId, bestServer.id, LocalPlayer)
    else
        print("❌ Không tìm thấy server khác, thử lại sau")
        IsHopping = false
        HopCountdown = false
        NoFruitCount = 0
    end
end

-- HÀM BẮT ĐẦU ĐẾM NGƯỢC HOP
local function startHopCountdown()
    if HopCountdown or IsHopping then return end
    
    HopCountdown = true
    HopTimer = Settings.HopDelay
    
    print("🔄 BẮT ĐẦU ĐẾM NGƯỢC " .. HopTimer .. " GIÂY TRƯỚC KHI HOP!")
    
    -- Hủy thread cũ nếu có
    if HopThread then
        coroutine.close(HopThread)
        HopThread = nil
    end
    
    -- Tạo thread mới cho đếm ngược
    HopThread = coroutine.create(function()
        while HopCountdown and HopTimer > 0 do
            print("⏱️ Còn " .. HopTimer .. " giây nữa sẽ hop...")
            wait(1)
            HopTimer = HopTimer - 1
        end
        
        if HopCountdown and HopTimer <= 0 then
            print("🚀 ĐANG THỰC HIỆN HOP SERVER!")
            wait(0.5)
            hopToNewServer()
        end
        
        HopThread = nil
    end)
    
    coroutine.resume(HopThread)
end

-- HÀM HỦY ĐẾM NGƯỢC HOP
local function cancelHopCountdown()
    if HopCountdown then
        print("✅ Hủy đếm ngược hop (có fruit xuất hiện)")
        HopCountdown = false
        HopTimer = 0
        if HopThread then
            coroutine.close(HopThread)
            HopThread = nil
        end
    end
end

-- HÀM KIỂM TRA VÀ XỬ LÝ HOP
local function checkAndHandleHop()
    if not Settings.AutoHop or IsHopping then return end
    
    local fruitCount = scanForFruits()
    
    -- Nếu KHÔNG có fruit
    if fruitCount == 0 then
        NoFruitCount = NoFruitCount + 1
        
        -- Nếu đủ số lần kiểm tra không có fruit
        if NoFruitCount >= Settings.MaxNoFruitChecks and not HopCountdown then
            print("⚠️ Đã " .. NoFruitCount .. "/" .. Settings.MaxNoFruitChecks .. " lần không có fruit")
            -- Lưu trữ fruit trước khi hop
            if Settings.AutoStore then
                storeAllFruits()
            end
            -- Bắt đầu đếm ngược
            startHopCountdown()
        end
    else
        -- CÓ fruit: reset bộ đếm và hủy đếm ngược
        if NoFruitCount > 0 then
            NoFruitCount = 0
        end
        if HopCountdown then
            cancelHopCountdown()
        end
    end
end

-- ============================================
-- VÒNG LẶP CHÍNH
-- ============================================
spawn(function()
    -- Chọn phe ngay khi vào
    if Settings.AutoJoinTeam and not JoinedTeam then
        joinTeam()
    end
    
    while true do
        wait(Settings.CheckInterval)
        
        pcall(function()
            -- Random fruit
            randomFruit()
            
            -- Scan fruit
            local fruitCount = scanForFruits()
            
            -- Tạo ESP
            if Settings.ShowESP then
                for _, fruit in pairs(FruitsOnMap) do
                    createFruitESP(fruit)
                end
            end
            
            -- Thu thập fruit
            if Settings.AutoCollect and fruitCount > 0 and not Collecting then
                collectFruit(FruitsOnMap[1])
            end
            
            -- Lưu trữ nếu đầy
            if Settings.AutoStore then
                local fruitInInventory = countFruitsInInventory()
                if fruitInInventory >= Settings.MaxFruitsInInventory then
                    storeAllFruits()
                end
            end
            
            -- KIỂM TRA VÀ XỬ LÝ HOP
            checkAndHandleHop()
        end)
    end
end)

-- THEO DÕI FRUIT MỚI XUẤT HIỆN
Workspace.ChildAdded:Connect(function(child)
    if child.Name:find("Fruit") and child:IsA("Model") then
        wait(0.5)
        print("✨ Fruit mới: " .. child.Name)
        
        -- Reset trạng thái khi có fruit mới
        NoFruitCount = 0
        if HopCountdown then
            cancelHopCountdown()
        end
        
        if Settings.AutoCollect and not Collecting then
            local handle = child:FindFirstChild("Handle")
            if handle then
                local fruitData = {
                    Model = child,
                    Handle = handle,
                    Position = handle.Position,
                    Name = child.Name
                }
                collectFruit(fruitData)
            end
        end
    end
end)

-- XÓA ESP KHI FRUIT BIẾN MẤT
Workspace.ChildRemoved:Connect(function(child)
    if child.Name:find("Fruit") then
        if child:FindFirstChild("Handle") then
            local handle = child.Handle
            if handle:FindFirstChild("FruitESP") then
                handle.FruitESP:Destroy()
            end
        end
    end
end)

-- ============================================
-- TẠO GUI
-- ============================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "FruitCollectorGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer.PlayerGui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 320, 0, 280)
MainFrame.Position = UDim2.new(0, 10, 0, 10)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.BackgroundTransparency = 0.1
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 10)
UICorner.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 35)
Title.Position = UDim2.new(0, 0, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "🍎 Fruit Collector Pro"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextScaled = true
Title.Font = Enum.Font.GothamBold
Title.Parent = MainFrame

local StatusText = Instance.new("TextLabel")
StatusText.Size = UDim2.new(1, 0, 0, 25)
StatusText.Position = UDim2.new(0, 0, 0, 40)
StatusText.BackgroundTransparency = 1
StatusText.Text = "Đang chạy..."
StatusText.TextColor3 = Color3.fromRGB(200, 200, 200)
StatusText.TextScaled = true
StatusText.Font = Enum.Font.Gotham
StatusText.Parent = MainFrame

local TeamText = Instance.new("TextLabel")
TeamText.Size = UDim2.new(1, 0, 0, 25)
TeamText.Position = UDim2.new(0, 0, 0, 70)
TeamText.BackgroundTransparency = 1
TeamText.Text = "Phe: Chưa chọn"
TeamText.TextColor3 = Color3.fromRGB(255, 200, 100)
TeamText.TextScaled = true
TeamText.Font = Enum.Font.Gotham
TeamText.Parent = MainFrame

local FruitMapText = Instance.new("TextLabel")
FruitMapText.Size = UDim2.new(1, 0, 0, 25)
FruitMapText.Position = UDim2.new(0, 0, 0, 100)
FruitMapText.BackgroundTransparency = 1
FruitMapText.Text = "Fruit trên map: 0"
FruitMapText.TextColor3 = Color3.fromRGB(100, 255, 100)
FruitMapText.TextScaled = true
FruitMapText.Font = Enum.Font.Gotham
FruitMapText.Parent = MainFrame

local InventoryText = Instance.new("TextLabel")
InventoryText.Size = UDim2.new(1, 0, 0, 25)
InventoryText.Position = UDim2.new(0, 0, 0, 130)
InventoryText.BackgroundTransparency = 1
InventoryText.Text = "Fruit trong túi: 0"
InventoryText.TextColor3 = Color3.fromRGB(255, 200, 100)
InventoryText.TextScaled = true
InventoryText.Font = Enum.Font.Gotham
InventoryText.Parent = MainFrame

local StoredText = Instance.new("TextLabel")
StoredText.Size = UDim2.new(1, 0, 0, 25)
StoredText.Position = UDim2.new(0, 0, 0, 160)
StoredText.BackgroundTransparency = 1
StoredText.Text = "Đã lưu trữ: 0"
StoredText.TextColor3 = Color3.fromRGB(100, 200, 255)
StoredText.TextScaled = true
StoredText.Font = Enum.Font.Gotham
StoredText.Parent = MainFrame

local HopStatusText = Instance.new("TextLabel")
HopStatusText.Size = UDim2.new(1, 0, 0, 25)
HopStatusText.Position = UDim2.new(0, 0, 0, 190)
HopStatusText.BackgroundTransparency = 1
HopStatusText.Text = "Trạng thái: Bình thường"
HopStatusText.TextColor3 = Color3.fromRGB(100, 255, 100)
HopStatusText.TextScaled = true
HopStatusText.Font = Enum.Font.Gotham
HopStatusText.Parent = MainFrame

local HopTimerText = Instance.new("TextLabel")
HopTimerText.Size = UDim2.new(1, 0, 0, 25)
HopTimerText.Position = UDim2.new(0, 0, 0, 220)
HopTimerText.BackgroundTransparency = 1
HopTimerText.Text = "Đếm ngược: 0s"
HopTimerText.TextColor3 = Color3.fromRGB(255, 200, 100)
HopTimerText.TextScaled = true
HopTimerText.Font = Enum.Font.Gotham
HopTimerText.Parent = MainFrame

local TimeText = Instance.new("TextLabel")
TimeText.Size = UDim2.new(1, 0, 0, 25)
TimeText.Position = UDim2.new(0, 0, 0, 250)
TimeText.BackgroundTransparency = 1
TimeText.Text = "Thời gian: 0s"
TimeText.TextColor3 = Color3.fromRGB(200, 200, 200)
TimeText.TextScaled = true
TimeText.Font = Enum.Font.Gotham
TimeText.Parent = MainFrame

-- CẬP NHẬT GUI
spawn(function()
    while wait(0.5) do
        pcall(function()
            local fruitOnMap = #FruitsOnMap
            local fruitInInventory = countFruitsInInventory()
            local beli = getBeli()
            local timeOnServer = math.floor(tick() - StartTime)
            
            FruitMapText.Text = "Fruit trên map: " .. fruitOnMap
            InventoryText.Text = "Fruit trong túi: " .. fruitInInventory .. "/" .. Settings.MaxFruitsInInventory
            StoredText.Text = "Đã lưu trữ: " .. #StoredFruits
            TimeText.Text = "Thời gian: " .. timeOnServer .. "s"
            
            -- Phe
            if LocalPlayer.Team then
                TeamText.Text = "Phe: " .. tostring(LocalPlayer.Team)
                TeamText.TextColor3 = Color3.fromRGB(100, 255, 100)
            else
                TeamText.Text = "Phe: Chưa chọn"
                TeamText.TextColor3 = Color3.fromRGB(255, 100, 100)
            end
            
            -- Trạng thái hop
            if IsHopping then
                HopStatusText.Text = "Trạng thái: Đang hop..."
                HopStatusText.TextColor3 = Color3.fromRGB(255, 200, 0)
                HopTimerText.Text = "Đếm ngược: 0s"
            elseif HopCountdown then
                HopStatusText.Text = "Trạng thái: SẮP HOP (" .. NoFruitCount .. "/" .. Settings.MaxNoFruitChecks .. ")"
                HopStatusText.TextColor3 = Color3.fromRGB(255, 100, 100)
                HopTimerText.Text = "Đếm ngược: " .. HopTimer .. "s"
                HopTimerText.TextColor3 = Color3.fromRGB(255, 100, 100)
            elseif fruitOnMap == 0 then
                HopStatusText.Text = "Trạng thái: Chờ fruit (" .. NoFruitCount .. "/" .. Settings.MaxNoFruitChecks .. ")"
                HopStatusText.TextColor3 = Color3.fromRGB(255, 200, 0)
                HopTimerText.Text = "Đếm ngược: 0s"
            else
                HopStatusText.Text = "Trạng thái: Đang thu thập"
                HopStatusText.TextColor3 = Color3.fromRGB(100, 255, 100)
                HopTimerText.Text = "Đếm ngược: 0s"
            end
            
            -- Status text
            if Collecting and CurrentFruit then
                StatusText.Text = "Đang nhặt: " .. CurrentFruit.Name
                StatusText.TextColor3 = Color3.fromRGB(255, 200, 0)
            elseif fruitOnMap > 0 then
                StatusText.Text = "Đang tìm fruit..."
                StatusText.TextColor3 = Color3.fromRGB(100, 255, 100)
            elseif fruitInInventory >= Settings.MaxFruitsInInventory then
                StatusText.Text = "Đang lưu trữ..."
                StatusText.TextColor3 = Color3.fromRGB(100, 200, 255)
            elseif HopCountdown then
                StatusText.Text = "SẮP HOP: " .. HopTimer .. "s"
                StatusText.TextColor3 = Color3.fromRGB(255, 100, 100)
            else
                StatusText.Text = "Chờ fruit (" .. NoFruitCount .. "/" .. Settings.MaxNoFruitChecks .. ")"
                StatusText.TextColor3 = Color3.fromRGB(255, 100, 100)
            end
        end)
    end
end)

print("===================================")
print("✅ SCRIPT ĐÃ KHỞI ĐỘNG!")
print("💰 Beli: " .. getBeli()/1000 .. "k")
print("🏴‍☠️ Phe: " .. (Settings.TeamToJoin == 1 and "Hải tặc" or "Hải quân"))
print("⏱️ Sẽ hop sau " .. Settings.HopDelay .. " giây nếu không có fruit")
print("📊 Kiểm tra: " .. Settings.MaxNoFruitChecks .. " lần không fruit = " .. Settings.MaxNoFruitChecks*Settings.CheckInterval .. "s + đếm ngược " .. Settings.HopDelay .. "s")
print("===================================")
