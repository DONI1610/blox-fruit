--[[
    Script tự động Random Fruit, Nhặt Fruit và Hop Server
    Tính năng:
    - Tự động random fruit khi có đủ tiền
    - Tự động nhặt fruit khi xuất hiện trên map
    - Tự động hop server khi không còn fruit trên map
    - Hiển thị thông tin fruit và khoảng cách
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local VirtualUser = game:GetService("VirtualUser")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local RootPart = Character:WaitForChild("HumanoidRootPart")

-- Cấu hình
local Settings = {
    AutoRandom = true,           -- Tự động random fruit
    AutoCollect = true,          -- Tự động nhặt fruit
    AutoHop = true,              -- Tự động hop server khi hết fruit
    MinBeliForRandom = 500000,   -- Tiền tối thiểu để random (500k)
    CheckInterval = 2,           -- Thời gian kiểm tra (giây)
    TeleportSpeed = 300,         -- Tốc độ di chuyển
    HopWhenNoFruit = true,       -- Hop khi không còn fruit trên map
    ShowESP = true,              -- Hiển thị ESP cho fruit
}

-- Biến toàn cục
local FruitsOnMap = {}
local FruitList = {}
local Collecting = false
local CurrentFruit = nil
local FruitConnection = nil
local IsHopping = false

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
    
    -- Đồng bộ vị trí người chơi với part
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

-- Hàm teleport tức thời
local function teleportTo(cframe)
    if not cframe then return end
    RootPart.CFrame = cframe
end

-- Kiểm tra kết nối game
repeat
    wait(1)
until game:IsLoaded() and LocalPlayer.PlayerGui:FindFirstChild("Main")

-- Xác định world
local World
if game.PlaceId == 2753915549 then
    World = 1
elseif game.PlaceId == 4442272183 then
    World = 2
elseif game.PlaceId == 7449423635 then
    World = 3
end

-- Anti-AFK
LocalPlayer.Idled:Connect(function()
    VirtualUser:Button2Down(Vector2.new(0, 0), Workspace.CurrentCamera.CFrame)
    wait(1)
    VirtualUser:Button2Up(Vector2.new(0, 0), Workspace.CurrentCamera.CFrame)
end)

-- Hàm lấy số lượng Beli
local function getBeli()
    return LocalPlayer.Data.Beli.Value
end

-- Hàm random fruit
local function randomFruit()
    if not Settings.AutoRandom then return end
    
    local beli = getBeli()
    if beli >= Settings.MinBeliForRandom then
        print("🎲 Đang random fruit...")
        ReplicatedStorage.Remotes.CommF_:InvokeServer("Cousin", "Buy")
        wait(1)
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
    
    -- Sắp xếp theo khoảng cách gần nhất
    table.sort(FruitsOnMap, function(a, b)
        return a.Distance < b.Distance
    end)
    
    return #FruitsOnMap > 0
end

-- Hàm tạo ESP cho fruit
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
    
    print("🍎 Đang di chuyển đến: " .. fruitData.Name .. " | " .. math.floor(fruitData.Distance/3) .. "m")
    
    -- Di chuyển đến fruit
    local tween = tweenTo(CFrame.new(fruitData.Position))
    
    -- Đợi đến khi đến nơi
    while tween and tween.PlaybackState == Enum.PlaybackState.Playing do
        -- Kiểm tra nếu fruit đã biến mất
        if not fruitData.Model or not fruitData.Model.Parent then
            tween:Cancel()
            Collecting = false
            return
        end
        wait(0.1)
    end
    
    -- Chạm vào fruit để nhặt
    if fruitData.Model and fruitData.Model.Parent then
        wait(0.5)
        firetouchinterest(RootPart, fruitData.Handle, 0)
        wait(0.1)
        firetouchinterest(RootPart, fruitData.Handle, 1)
        print("✅ Đã nhặt: " .. fruitData.Name)
        wait(0.5)
    end
    
    Collecting = false
    CurrentFruit = nil
end

-- Hàm kiểm tra và hop server
local function checkAndHop()
    if not Settings.AutoHop or IsHopping then return end
    
    local fruitCount = scanForFruits()
    
    if fruitCount == 0 and Settings.HopWhenNoFruit then
        print("🔄 Không còn fruit trên map, đang tìm server mới...")
        hopToLowestServer()
    end
end

-- Hàm hop đến server có ít người nhất
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
        print("🌍 Đang chuyển đến server có " .. lowestServer.playing .. " người...")
        wait(1)
        TeleportService:TeleportToPlaceInstance(game.PlaceId, lowestServer.id, LocalPlayer)
    else
        print("❌ Không tìm thấy server phù hợp")
        IsHopping = false
    end
end

-- Vòng lặp chính
spawn(function()
    while wait(Settings.CheckInterval) do
        pcall(function()
            -- Random fruit nếu có đủ tiền
            randomFruit()
            
            -- Scan fruit trên map
            local hasFruits = scanForFruits()
            
            -- Tạo ESP cho fruit
            if Settings.ShowESP then
                for _, fruit in pairs(FruitsOnMap) do
                    createFruitESP(fruit)
                end
            end
            
            -- Thu thập fruit gần nhất nếu không đang thu thập
            if Settings.AutoCollect and hasFruits and not Collecting then
                collectFruit(FruitsOnMap[1])
            end
            
            -- Kiểm tra và hop server
            checkAndHop()
            
            -- Hiển thị thông tin
            print("📊 Có " .. #FruitsOnMap .. " fruit trên map")
        end)
    end
end)

-- Xóa ESP khi fruit biến mất
local function cleanupESP(obj)
    if obj:FindFirstChild("Handle") then
        local handle = obj.Handle
        if handle:FindFirstChild("FruitESP") then
            handle.FruitESP:Destroy()
        end
    end
end

-- Theo dõi fruit mới xuất hiện
local function watchForNewFruits()
    Workspace.ChildAdded:Connect(function(child)
        if child.Name:find("Fruit") and child:IsA("Model") then
            wait(0.5) -- Đợi fruit load hoàn chỉnh
            print("✨ Fruit mới xuất hiện: " .. child.Name)
            
            -- Tự động thu thập nếu đang bật
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
    
    Workspace.ChildRemoved:Connect(function(child)
        if child.Name:find("Fruit") then
            cleanupESP(child)
        end
    end)
end

watchForNewFruits()

-- Tạo GUI đơn giản
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "FruitCollectorGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer.PlayerGui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 250, 0, 150)
MainFrame.Position = UDim2.new(0, 10, 0, 10)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.BackgroundTransparency = 0.2
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 10)
UICorner.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 30)
Title.Position = UDim2.new(0, 0, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "🍎 Fruit Collector"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextScaled = true
Title.Font = Enum.Font.GothamBold
Title.Parent = MainFrame

local StatusText = Instance.new("TextLabel")
StatusText.Size = UDim2.new(1, 0, 0, 25)
StatusText.Position = UDim2.new(0, 0, 0, 35)
StatusText.BackgroundTransparency = 1
StatusText.Text = "Đang quét fruit..."
StatusText.TextColor3 = Color3.fromRGB(200, 200, 200)
StatusText.TextScaled = true
StatusText.Font = Enum.Font.Gotham
StatusText.Parent = MainFrame

local FruitCountText = Instance.new("TextLabel")
FruitCountText.Size = UDim2.new(1, 0, 0, 25)
FruitCountText.Position = UDim2.new(0, 0, 0, 65)
FruitCountText.BackgroundTransparency = 1
FruitCountText.Text = "Fruit: 0"
FruitCountText.TextColor3 = Color3.fromRGB(100, 255, 100)
FruitCountText.TextScaled = true
FruitCountText.Font = Enum.Font.Gotham
FruitCountText.Parent = MainFrame

local BeliText = Instance.new("TextLabel")
BeliText.Size = UDim2.new(1, 0, 0, 25)
BeliText.Position = UDim2.new(0, 0, 0, 95)
BeliText.BackgroundTransparency = 1
BeliText.Text = "Beli: 0"
BeliText.TextColor3 = Color3.fromRGB(255, 255, 100)
BeliText.TextScaled = true
BeliText.Font = Enum.Font.Gotham
BeliText.Parent = MainFrame

-- Cập nhật GUI
spawn(function()
    while wait(1) do
        pcall(function()
            local fruitCount = #FruitsOnMap
            local beli = getBeli()
            
            FruitCountText.Text = "Fruit: " .. fruitCount
            BeliText.Text = "Beli: " .. string.format("%.0f", beli/1000) .. "k"
            
            if Collecting and CurrentFruit then
                StatusText.Text = "Đang nhặt: " .. CurrentFruit.Name
                StatusText.TextColor3 = Color3.fromRGB(255, 200, 0)
            elseif fruitCount > 0 then
                StatusText.Text = "Đang tìm fruit..."
                StatusText.TextColor3 = Color3.fromRGB(100, 255, 100)
            else
                StatusText.Text = "Chờ fruit xuất hiện..."
                StatusText.TextColor3 = Color3.fromRGB(255, 100, 100)
            end
        end)
    end
end)

print("✅ Script Fruit Collector đã khởi động!")
print("💰 Beli hiện tại: " .. getBeli()/1000 .. "k")
