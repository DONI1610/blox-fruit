-- ========================================
-- FRUIT COLLECTOR SCRIPT - BY DONI HUB
-- ========================================
-- Tính năng:
-- - Auto Team Pirates
-- - Auto Collect Fruit (Teleport)
-- - Auto Hop khi hết fruit
-- - Auto Store Fruit
-- - No Clip (xuyên tường)
-- ========================================

local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/Myvkhuy/BearLibrary/Bearlib/V8.1.lua"))()
local Window = Library:MakeWindow({
    Title = "DONI HUB - Fruit Collector",
    SubTitle = "by Quang Huy",
    SaveFolder = true,
    Image = "82107905019656"
})

-- ========================================
-- SERVICES & VARIABLES
-- ========================================
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TeleportService = game:GetService("TeleportService")
local RunService = game:GetService("RunService")
local VirtualUser = game:GetService("VirtualUser")
local VirtualInputManager = game:GetService("VirtualInputManager")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local HttpService = game:GetService("HttpService")

local player = Players.LocalPlayer
local replicated = ReplicatedStorage
local hopDelay = 30 * 60 -- 30 phút mặc định

-- Biến toàn cục
_G.AutoCollect = false
_G.AutoHopFruit = false
_G.AutoStore = false
_G.NoClip = false
_G.HopTimer = nil

-- ========================================
-- HÀM HỖ TRỢ
-- ========================================

-- Đợi nhân vật load
repeat task.wait() until player.Character and player.Character:FindFirstChild("HumanoidRootPart")
local Root = player.Character.HumanoidRootPart

-- Hàm lấy item từ backpack/character
local function GetBP(itemName)
    return player.Backpack:FindFirstChild(itemName) or player.Character:FindFirstChild(itemName)
end

-- Hàm dịch chuyển (tween)
local RipPart = Instance.new("Part", Workspace)
RipPart.Size = Vector3.new(1, 1, 1)
RipPart.Name = "Rip_Indra"
RipPart.Anchored = true
RipPart.CanCollide = false
RipPart.CanTouch = false
RipPart.Transparency = 1

local function tweenTo(targetCFrame)
    local char = player.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    
    local hrp = char.HumanoidRootPart
    local distance = (targetCFrame.Position - hrp.Position).Magnitude
    local speed = 300
    local tweenInfo = TweenInfo.new(distance / speed, Enum.EasingStyle.Linear)
    local tween = TweenService:Create(RipPart, tweenInfo, {CFrame = targetCFrame})
    
    tween:Play()
    while tween.PlaybackState == Enum.PlaybackState.Playing do
        if char.Humanoid.Sit then
            RipPart.CFrame = CFrame.new(RipPart.Position.X, targetCFrame.Y, RipPart.Position.Z)
        end
        task.wait(0.1)
    end
end

-- Hàm dịch chuyển tức thời
local function teleport(targetCFrame)
    local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if hrp then
        hrp.CFrame = targetCFrame
    end
end

-- ========================================
-- AUTO TEAM PIRATES
-- ========================================
local desiredTeam = "Pirates"

if not player.Team or player.Team.Name ~= desiredTeam then
    pcall(function()
        ReplicatedStorage.Remotes.CommF_:InvokeServer("SetTeam", desiredTeam)
        Library:Notify({
            Title = "Team",
            Message = "Đã chọn team Pirates",
            Duration = 3
        })
    end)
end

-- ========================================
-- NO CLIP (Xuyên tường)
-- ========================================
RunService.Stepped:Connect(function()
    if _G.NoClip then
        local char = player.Character
        if char then
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end
    end
end)

-- ========================================
-- HÀM THU THẬP TRÁI CÂY
-- ========================================
local function collectFruits()
    local char = player.Character
    if not char then return false end
    
    local fruitsFound = false
    
    for _, obj in pairs(Workspace:GetChildren()) do
        if string.find(obj.Name, "Fruit") and obj:FindFirstChild("Handle") then
            fruitsFound = true
            
            -- Teleport đến vị trí trái cây
            tweenTo(obj.Handle.CFrame * CFrame.new(0, 3, 0))
            task.wait(0.5)
            
            -- Nhặt bằng ClickDetector nếu có
            if obj.Handle:FindFirstChild("ClickDetector") then
                fireclickdetector(obj.Handle.ClickDetector)
            end
        end
    end
    
    return fruitsFound
end

-- ========================================
-- HÀM HOP SERVER
-- ========================================
local function hopServer()
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
-- HÀM LƯU TRỮ TRÁI CÂY
-- ========================================
local function storeFruits()
    for _, item in next, player.Backpack:GetChildren() do
        local eatRemote = item:FindFirstChild("EatRemote", true)
        if eatRemote then
            pcall(function()
                ReplicatedStorage.Remotes.CommF_:InvokeServer(
                    "StoreFruit", 
                    eatRemote.Parent:GetAttribute("OriginalName"), 
                    player.Backpack:FindFirstChild(item.Name)
                )
            end)
        end
    end
end

-- ========================================
-- MAIN LOOP
-- ========================================
task.spawn(function()
    while task.wait(2) do
        if _G.AutoCollect then
            local found = collectFruits()
            
            -- Nếu không tìm thấy trái cây và bật auto hop
            if not found and _G.AutoHopFruit then
                Library:Notify({
                    Title = "Fruit Collector",
                    Message = "Không còn trái cây, đang tìm server mới...",
                    Duration = 3
                })
                task.wait(1)
                hopServer()
            end
        end
    end
end)

-- Loop auto store
task.spawn(function()
    while task.wait(3) do
        if _G.AutoStore then
            pcall(storeFruits)
        end
    end
end)

-- Auto hop server định kỳ
task.spawn(function()
    while task.wait(1) do
        if _G.AutoHopServer then
            if not _G.HopTimer then
                _G.HopTimer = tick()
            end
            
            if tick() - _G.HopTimer >= hopDelay then
                _G.HopTimer = tick()
                Library:Notify({
                    Title = "Server Hop",
                    Message = "Đang chuyển server...",
                    Duration = 2
                })
                hopServer()
            end
        else
            _G.HopTimer = nil
        end
    end
end)

-- ========================================
-- WORLD DETECTION
-- ========================================
local World1, World2, World3 = false, false, false
local placeId = game.PlaceId

if placeId == 2753915549 or placeId == 85211729168715 then
    World1 = true
elseif placeId == 4442272183 or placeId == 79091703265657 then
    World2 = true
elseif placeId == 7449423635 or placeId == 100117331123089 then
    World3 = true
end

-- ========================================
-- TẠO GUI
-- ========================================

-- Tab chính
local MainTab = Window:MakeTab({
    Title = "Main",
    Icon = "rbxassetid://10709769508"
})

-- Tab Fruit
local FruitTab = Window:MakeTab({
    Title = "Fruit",
    Icon = "rbxassetid://10709790875"
})

-- Tab Settings
local SettingsTab = Window:MakeTab({
    Title = "Settings",
    Icon = "rbxassetid://10734950309"
})

-- Tab Info
local InfoTab = Window:MakeTab({
    Title = "Info",
    Icon = "rbxassetid://73132811772878"
})

-- ========================================
-- MAIN TAB
-- ========================================
MainTab:AddSection({"Trạng thái"})

local TimePara = MainTab:AddParagraph({
    Title = "Thời gian",
    Desc = ""
})

local FruitPara = MainTab:AddParagraph({
    Title = "Trái cây trên map",
    Desc = "Đang kiểm tra..."
})

-- Cập nhật thời gian
spawn(function()
    while task.wait(1) do
        local gameTime = math.floor(workspace.DistributedGameTime)
        local hour = math.floor(gameTime / 3600) % 24
        local minute = math.floor(gameTime / 60) % 60
        local second = gameTime % 60
        TimePara:SetDesc(string.format("%02d:%02d:%02d", hour, minute, second))
    end
end)

-- Cập nhật số lượng trái cây
spawn(function()
    while task.wait(3) do
        local count = 0
        for _, obj in pairs(Workspace:GetChildren()) do
            if string.find(obj.Name, "Fruit") then
                count = count + 1
            end
        end
        FruitPara:SetDesc("Có " .. count .. " trái cây trên map")
    end
end)

-- ========================================
-- FRUIT TAB
-- ========================================
FruitTab:AddSection({"Thu thập trái cây"})

FruitTab:AddToggle({
    Name = "Auto Collect Fruit",
    Default = false,
    Callback = function(Value)
        _G.AutoCollect = Value
    end
})

FruitTab:AddToggle({
    Name = "Auto Hop khi hết fruit",
    Default = false,
    Callback = function(Value)
        _G.AutoHopFruit = Value
    end
})

FruitTab:AddToggle({
    Name = "Auto Store Fruit",
    Default = false,
    Callback = function(Value)
        _G.AutoStore = Value
    end
})

FruitTab:AddButton({
    Name = "Store Fruit Ngay",
    Callback = function()
        storeFruits()
        Library:Notify({
            Title = "Store",
            Message = "Đã lưu trữ trái cây",
            Duration = 2
        })
    end
})

-- ========================================
-- SETTINGS TAB
-- ========================================
SettingsTab:AddSection({"Di chuyển"})

SettingsTab:AddToggle({
    Name = "No Clip (Xuyên tường)",
    Default = false,
    Callback = function(Value)
        _G.NoClip = Value
    end
})

SettingsTab:AddSection({"Server Hop"})

SettingsTab:AddToggle({
    Name = "Auto Hop Server",
    Default = false,
    Callback = function(Value)
        _G.AutoHopServer = Value
    end
})

SettingsTab:AddSlider({
    Name = "Hop Delay (Phút)",
    Min = 5,
    Max = 120,
    Default = 30,
    Increment = 1,
    Callback = function(Value)
        hopDelay = Value * 60
    end
})

SettingsTab:AddButton({
    Name = "Hop Server Ngay",
    Callback = function()
        hopServer()
    end
})

SettingsTab:AddButton({
    Name = "Copy Job ID",
    Callback = function()
        setclipboard(tostring(game.JobId))
        Library:Notify({
            Title = "Copy",
            Message = "Đã copy Job ID",
            Duration = 2
        })
    end
})

SettingsTab:AddSection({"Team"})

SettingsTab:AddButton({
    Name = "Chọn Marines",
    Callback = function()
        pcall(function()
            ReplicatedStorage.Remotes.CommF_:InvokeServer("SetTeam", "Marines")
            Library:Notify({
                Title = "Team",
                Message = "Đã chọn Marines",
                Duration = 2
            })
        end)
    end
})

SettingsTab:AddButton({
    Name = "Chọn Pirates",
    Callback = function()
        pcall(function()
            ReplicatedStorage.Remotes.CommF_:InvokeServer("SetTeam", "Pirates")
            Library:Notify({
                Title = "Team",
                Message = "Đã chọn Pirates",
                Duration = 2
            })
        end)
    end
})

-- ========================================
-- INFO TAB
-- ========================================
InfoTab:AddParagraph({
    "DONI HUB - Fruit Collector",
    "• Phiên bản: 1.0\n• Tác giả: Quang Huy\n• Tính năng:\n  - Auto Team Pirates\n  - Auto Collect Fruit\n  - Auto Hop khi hết fruit\n  - Auto Store Fruit\n  - No Clip\n  - Auto Hop Server"
})

InfoTab:AddButton({
    Name = "Join Discord",
    Callback = function()
        setclipboard("https://discord.gg/4XtcBYZ89")
        Library:Notify({
            Title = "Discord",
            Message = "Đã copy link Discord",
            Duration = 3
        })
    end
})

-- ========================================
-- KHỞI TẠO HOÀN TẤT
-- ========================================
Library:Notify({
    Title = "DONI HUB",
    Message = "Script đã sẵn sàng!",
    Duration = 5
})
