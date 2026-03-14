--[[
    Script tự động Random Fruit + Auto Store + Auto Hop (10s nếu không có fruit) + Auto Join Team
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

-- Cấu hình
local Settings = {
    AutoRandom = true,           -- Tự động random fruit
    AutoCollect = true,          -- Tự động nhặt fruit
    AutoStore = true,            -- Tự động lưu trữ fruit
    AutoHop = true,              -- Tự động hop server
    AutoJoinTeam = true,         -- Tự động chọn phe
    
    -- Cấu hình thời gian
    HopDelay = 10,                -- Số giây chờ trước khi hop nếu không có fruit (10s)
    CheckInterval = 3,            -- Thời gian kiểm tra (giây)
    NoFruitCheckCount = 3,        -- Số lần kiểm tra liên tiếp không có fruit thì hop
    
    -- Cấu hình tiền
    MinBeliForRandom = 500000,    -- Tiền tối thiểu để random (500k)
    MaxFruitsInInventory = 5,      -- Số fruit tối đa trong hành trang
    
    -- Cấu hình di chuyển
    TeleportSpeed = 300,           -- Tốc độ di chuyển
    
    -- Cấu hình hiển thị
    ShowESP = true,                -- Hiển thị ESP cho fruit
    
    -- Chọn phe (1 = Hải tặc, 2 = Hải quân)
    TeamToJoin = 1,                 -- 1: Hải tặc, 2: Hải quân
}

-- Biến toàn cục
local FruitsOnMap = {}
local Collecting = false
local CurrentFruit = nil
local IsHopping = false
local StoredFruits = {}
local NoFruitCount = 0              -- Đếm số lần liên tiếp không có fruit
local JoinedTeam = false            -- Đã chọn phe chưa
local StartTime = tick()            -- Thời gian bắt đầu

-- Tạo Part để teleport
local TweenPart = Instance.new("Part", Workspace)
TweenPart.Name = "FruitCollector_Part"
TweenPart.Size = Vector3.new(1, 1, 1)
TweenPart.Anchored = true
TweenPart.CanCollide = false
TweenPart.CanTouch = false
TweenPart.Transparency = 1

-- Hàm teleport mượt mà
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

-- Anti-AFK
LocalPlayer.Idled:Connect(function()
    VirtualUser:Button2Down(Vector2.new(0, 0), Workspace.CurrentCamera.CFrame)
    wait(1)
    VirtualUser:Button2Up(Vector2.new(0, 0), Workspace.CurrentCamera.CFrame)
end)

-- Kiểm tra kết nối game
repeat
    wait(1)
until game:IsLoaded() and LocalPlayer.PlayerGui:FindFirstChild("Main")

-- Xác định world
local World
if game.PlaceId == 2753915549 or game.PlaceId == 85211729168715 then
    World = 1
elseif game.PlaceId == 4442272183 or game.PlaceId == 79091703265657 then
    World = 2
elseif game.PlaceId == 7449423635 or game.PlaceId == 100117331123089 then
    World = 3
else
    LocalPlayer:Kick("Không hỗ trợ server này!")
end

-- Hàm TỰ ĐỘNG GIA NHẬP PHE
local function joinTeam()
    if not Settings.AutoJoinTeam or JoinedTeam then return end
    
    -- Kiểm tra xem đã có phe chưa
    if LocalPlayer.Team ~= nil then
        print("✅ Đã có phe: " .. tostring(LocalPlayer.Team))
        JoinedTeam = true
        return
    end
    
    print("🔄 Đang chọn phe...")
    
    if Settings.TeamToJoin == 1 then
        -- Gia nhập Hải tặc
        local success = pcall(function()
            ReplicatedStorage.Remotes.CommF_:InvokeServer("SetTeam", "Pirates")
        end)
        if success then
            print("🏴‍☠️ Đã gia nhập Hải tặc!")
        end
    elseif Settings.TeamToJoin == 2 then
        -- Gia nhập Hải quân
        local success = pcall(function()
            ReplicatedStorage.Remotes.CommF_:InvokeServer("SetTeam", "Marines")
        end)
        if success then
            print("⚓ Đã gia nhập Hải quân!")
        end
    end
    
    JoinedTeam = true
    wait(2) -- Đợi phe được cập nhật
end

-- Hàm lấy số lượng Beli
local function getBeli()
    return LocalPlayer.Data.Beli.Value
end

-- Hàm đếm số lượng fruit trong hành trang
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

-- Hàm lấy danh sách fruit trong hành trang
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

-- Hàm kiểm tra fruit đã được lưu trữ chưa
local function isFruitStored(fruitName)
    for _, stored in pairs(StoredFruits) do
        if stored == fruitName then
            return true
        end
    end
    return false
end

-- Hàm lưu trữ fruit vào kho
local function storeFruit(fruitItem, fruitName)
    if not Settings.AutoStore then return end
    
    if isFruitStored(fruitName) then
        return
    end
    
    local eatRemote = fruitItem:FindFirstChild("EatRemote", true)
    if not eatRemote then
        return
    end
    
    local success, result = pcall(function()
        return ReplicatedStorage.Remotes.CommF_:InvokeServer("StoreFruit", fruitItem)
    end)
    
    if success then
        print("💾 Đã lưu trữ: " .. fruitName)
        table.insert(StoredFruits, fruitName)
    end
end

-- Hàm lưu trữ TẤT CẢ fruit
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

-- Hàm random fruit
local function randomFruit()
    if not Settings.AutoRandom then return end
    
    -- Kiểm tra phe trước khi random (vì random fruit cần phe)
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

-- Hàm phát hiện fruit trên map
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

-- Hàm tạo ESP
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

-- Hàm thu thập fruit
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

-- Hàm HOP SERVER với cơ chế 10 giây
local function checkAndHop()
    if not Settings.AutoHop or IsHopping then return end
    
    local fruitCount = scanForFruits()
    
    -- Nếu KHÔNG có fruit trên map
    if fruitCount == 0 then
        NoFruitCount = NoFruitCount + 1
        local timeOnServer = math.floor(tick() - StartTime)
        
        print("⏳ Lần " .. NoFruitCount .. "/" .. Settings.NoFruitCheckCount .. " không có fruit (Đã ở server: " .. timeOnServer .. "s)")
        
        -- Nếu đã đủ số lần kiểm tra liên tiếp không có fruit
        if NoFruitCount >= Settings.NoFruitCheckCount then
            print("🔄 Server không có fruit sau " .. Settings.HopDelay .. " giây, đang tìm server mới...")
            
            -- Lưu trữ fruit trước khi hop
            if Settings.AutoStore then
                storeAllFruits()
            end
            
            -- Đếm ngược 10 giây
            for i = Settings.HopDelay, 1, -1 do
                print("⏱️ Hop sau " .. i .. " giây...")
                wait(1)
            end
            
            hopToLowestServer()
        end
    else
        -- Nếu có fruit, reset bộ đếm
        NoFruitCount = 0
    end
end

-- Hàm hop đến server ít người nhất
local function hopToLowestServer()
    IsHopping = true
    
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
    local lowestServer = nil
    local lowestPlayers = 999
    
    for _, server in pairs(servers) do
        if server.playing < server.maxPlayers and server.playing < lowestPlayers then
            lowestPlayers = server.playing
            lowestServer = server
        end
    end
    
    if lowestServer then
        print("🌍 Chuyển đến server có " .. lowestServer.playing .. " người...")
        wait(1)
        TeleportService:TeleportToPlaceInstance(game.PlaceId, lowestServer.id, LocalPlayer)
    else
        print("❌ Không tìm thấy server phù hợp")
        IsHopping = false
    end
end

-- Vòng lặp chính
spawn(function()
    -- Chọn phe ngay khi vào server
    if Settings.AutoJoinTeam and not JoinedTeam then
        joinTeam()
    end
    
    while wait(Settings.CheckInterval) do
        pcall(function()
            -- Random fruit
            randomFruit()
            
            -- Scan fruit trên map
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
            
            -- Kiểm tra và hop server (10s nếu không có fruit)
            checkAndHop()
        end)
    end
end)

-- Theo dõi fruit mới
Workspace.ChildAdded:Connect(function(child)
    if child.Name:find("Fruit") and child:IsA("Model") then
        wait(0.5)
        print("✨ Fruit mới: " .. child.Name)
        
        -- Reset bộ đếm không fruit khi có fruit mới
        NoFruitCount = 0
        
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

-- Xóa ESP khi fruit biến mất
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

-- Tạo GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "FruitCollectorGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer.PlayerGui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 320, 0, 250)
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

local HopText = Instance.new("TextLabel")
HopText.Size = UDim2.new(1, 0, 0, 25)
HopText.Position = UDim2.new(0, 0, 0, 190)
HopText.BackgroundTransparency = 1
HopText.Text = "Hop sau: 0s (0/3)"
HopText.TextColor3 = Color3.fromRGB(255, 100, 100)
HopText.TextScaled = true
HopText.Font = Enum.Font.Gotham
HopText.Parent = MainFrame

local TimeText = Instance.new("TextLabel")
TimeText.Size = UDim2.new(1, 0, 0, 25)
TimeText.Position = UDim2.new(0, 0, 0, 220)
TimeText.BackgroundTransparency = 1
TimeText.Text = "Thời gian: 0s"
TimeText.TextColor3 = Color3.fromRGB(200, 200, 200)
TimeText.TextScaled = true
TimeText.Font = Enum.Font.Gotham
TimeText.Parent = MainFrame

-- Cập nhật GUI
spawn(function()
    while wait(1) do
        pcall(function()
            local fruitOnMap = #FruitsOnMap
            local fruitInInventory = countFruitsInInventory()
            local beli = getBeli()
            local timeOnServer = math.floor(tick() - StartTime)
            
            FruitMapText.Text = "Fruit trên map: " .. fruitOnMap
            InventoryText.Text = "Fruit trong túi: " .. fruitInInventory .. "/" .. Settings.MaxFruitsInInventory
            StoredText.Text = "Đã lưu trữ: " .. #StoredFruits
            TimeText.Text = "Thời gian: " .. timeOnServer .. "s"
            
            -- Hiển thị phe
            if LocalPlayer.Team then
                TeamText.Text = "Phe: " .. tostring(LocalPlayer.Team)
                TeamText.TextColor3 = Color3.fromRGB(100, 255, 100)
            else
                TeamText.Text = "Phe: Chưa chọn"
                TeamText.TextColor3 = Color3.fromRGB(255, 100, 100)
            end
            
            -- Hiển thị trạng thái hop
            HopText.Text = "Hop sau: " .. (fruitOnMap == 0 and Settings.HopDelay or 0) .. "s (" .. NoFruitCount .. "/" .. Settings.NoFruitCheckCount .. ")"
            HopText.TextColor3 = fruitOnMap == 0 and Color3.fromRGB(255, 100, 100) or Color3.fromRGB(100, 255, 100)
            
            if Collecting and CurrentFruit then
                StatusText.Text = "Đang nhặt: " .. CurrentFruit.Name
                StatusText.TextColor3 = Color3.fromRGB(255, 200, 0)
            elseif fruitOnMap > 0 then
                StatusText.Text = "Đang tìm fruit..."
                StatusText.TextColor3 = Color3.fromRGB(100, 255, 100)
            elseif fruitInInventory >= Settings.MaxFruitsInInventory then
                StatusText.Text = "Đang lưu trữ..."
                StatusText.TextColor3 = Color3.fromRGB(100, 200, 255)
            else
                StatusText.Text = "Chờ fruit (" .. NoFruitCount .. "/" .. Settings.NoFruitCheckCount .. ")"
                StatusText.TextColor3 = Color3.fromRGB(255, 100, 100)
            end
        end)
    end
end)

print("✅ Script đã khởi động!")
print("💰 Beli: " .. getBeli()/1000 .. "k")
print("🏴‍☠️ Tự động chọn phe: " .. (Settings.AutoJoinTeam and "BẬT" or "TẮT"))
print("⏱️ Hop sau " .. Settings.HopDelay .. " giây nếu không có fruit")
