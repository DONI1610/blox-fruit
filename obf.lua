--[[
    Script được trích xuất và chỉnh sửa từ doni (1).lua
    Chỉ giữ lại: Inf Soru, Hop Server (Join via JobID, Copy JobID, Hop to Lowest Players, Hop to Lowest Ping)
    Đã thêm: Inf Energy, Walk on Water, Disable Chat/Leaderboard
--]]

-- Khởi tạo các service và biến cần thiết
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TeleportService = game:GetService("TeleportService")
local Lighting = game:GetService("Lighting")
local VirtualUser = game:GetService("VirtualUser")
local HttpService = game:GetService("HttpService")
local Stats = game:GetService("Stats")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local RootPart = Character:WaitForChild("HumanoidRootPart")

-- Biến toàn cục để bật/tắt tính năng
getgenv().InfSoru = false
getgenv().InfEnergy = false
getgenv().WalkWater = false
getgenv().Rechat = false
getgenv().ReLeader = false

-- Biến cho JobID
getgenv().JobId = ""

-- Hàm EquipWeapon (giữ lại từ file gốc)
local function EquipWeapon(weaponName)
    if not weaponName then return end
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    if backpack and backpack:FindFirstChild(weaponName) then
        LocalPlayer.Character.Humanoid:EquipTool(backpack[weaponName])
    end
end

-- Hàm UseSkills (giữ lại từ file gốc, chỉ giữ phần cần thiết)
local VirtualInputManager = game:GetService("VirtualInputManager")
local function UseSkill(key)
    VirtualInputManager:SendKeyEvent(true, key, false, game)
    VirtualInputManager:SendKeyEvent(false, key, false, game)
end

-- Hàm Tween (giữ lại từ file gốc)
local RipPart = Instance.new("Part", Workspace)
RipPart.Size = Vector3.new(1, 1, 1)
RipPart.Name = "Rip_Indra_Extracted"
RipPart.Anchored = true
RipPart.CanCollide = false
RipPart.CanTouch = false
RipPart.Transparency = 1

local function tweenTo(targetCFrame)
    local character = LocalPlayer.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end
    local hrp = character.HumanoidRootPart
    local distance = (targetCFrame.Position - hrp.Position).Magnitude
    local tweenInfo = TweenInfo.new(distance / 300, Enum.EasingStyle.Linear)
    local tween = TweenService:Create(RipPart, tweenInfo, {CFrame = targetCFrame})
    tween:Play()
    while tween.PlaybackState == Enum.PlaybackState.Playing do
        if character.Humanoid.Sit then
            RipPart.CFrame = CFrame.new(RipPart.Position.X, targetCFrame.Y, RipPart.Position.Z)
        end
        task.wait(0.1)
    end
end

local function teleport(targetCFrame)
    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if hrp then
        hrp.CFrame = targetCFrame
    end
end

-- Hàm CheckBoat (giữ lại từ file gốc)
local function CheckBoat()
    for _, boat in pairs(Workspace.Boats:GetChildren()) do
        if tostring(boat.Owner.Value) == tostring(LocalPlayer.Name) then
            return boat
        end
    end
    return false
end

-- Hàm CheckEnemiesBoat (giữ lại từ file gốc)
local function CheckEnemiesBoat()
    for _, enemy in pairs(Workspace.Enemies:GetChildren()) do
        if enemy.Name == "FishBoat" and enemy:FindFirstChild("Health") and enemy.Health.Value > 0 then
            return true
        end
    end
    return false
end

-- Hàm CheckTerrorShark (giữ lại từ file gốc)
local function CheckTerrorShark()
    for _, enemy in pairs(Workspace.Enemies:GetChildren()) do
        if enemy.Name == "Terrorshark" and enemy:FindFirstChild("Humanoid") and enemy.Humanoid.Health > 0 then
            return true
        end
    end
    return false
end

-- Hàm CheckPirateGrandBrigade (giữ lại từ file gốc)
local function CheckPirateGrandBrigade()
    for _, enemy in pairs(Workspace.Enemies:GetChildren()) do
        if (enemy.Name == "PirateGrandBrigade" or enemy.Name == "PirateBrigade") and enemy:FindFirstChild("Health") and enemy.Health.Value > 0 then
            return true
        end
    end
    return false
end

-- === 1. INFINITE SORU (Giữ nguyên từ file gốc) ===
local function getInfinity_Ability(abilityName, enable)
    if not RootPart then return end
    if abilityName == "Soru" and enable then
        for _, func in next, getgc() do
            if LocalPlayer.Character.Soru then
                if typeof(func) == "function" and (getfenv(func)).script == LocalPlayer.Character.Soru then
                    for _, upvalue in next, getupvalues(func) do
                        if typeof(upvalue) == "table" then
                            coroutine.wrap(function()
                                repeat
                                    task.wait(0.1)
                                    upvalue.LastUse = 0
                                until not getgenv().InfSoru or LocalPlayer.Character.Humanoid.Health <= 0
                            end)()
                        end
                    end
                end
            end
        end
    elseif abilityName == "Energy" and enable then
        LocalPlayer.Character.Energy.Changed:Connect(function()
            if getgenv().InfEnergy then
                LocalPlayer.Character.Energy.Value = LocalPlayer.Character.Energy.Value -- Giữ nguyên giá trị
            end
        end)
    end
end

-- Toggle Inf Soru
spawn(function()
    while task.wait() do
        if getgenv().InfSoru then
            getInfinity_Ability("Soru", true)
        end
    end
end)

-- === 2. NĂNG LƯỢNG VÔ HẠN (ĐÃ THÊM) ===
spawn(function()
    while task.wait() do
        if getgenv().InfEnergy then
            getInfinity_Ability("Energy", true)
        end
    end
end)

-- === 3. CHỨC NĂNG HOP SERVER (Giữ nguyên từ file gốc) ===
-- Nút: Rejoin Server
local function rejoinServer()
    TeleportService:Teleport(game.PlaceId, LocalPlayer)
end

-- Nút: Hop Server (Ngẫu nhiên)
local function hopServer()
    pcall(function()
        for i = math.random(1, math.random(40, 75)), 100, 1 do
            local servers = ReplicatedStorage.__ServerBrowser:InvokeServer(i)
            for id, info in next, servers do
                if tonumber(info.Count) < 12 then
                    TeleportService:TeleportToPlaceInstance(game.PlaceId, id)
                end
            end
        end
    end)
end

-- Nút: Hop to Lowest Players
local function hopToLowestPlayers()
    local apiUrl = "https://games.roblox.com/v1/games/"
    local placeId = game.PlaceId
    local url = apiUrl .. placeId .. "/servers/Public?sortOrder=Asc&limit=100"
    local function listServers(cursor)
        local fullUrl = url .. (cursor and "&cursor=" .. cursor or "")
        local success, response = pcall(function()
            return HttpService:JSONDecode(game:HttpGet(fullUrl))
        end)
        if success then
            return response
        end
        return nil
    end

    local cursor, bestServer
    repeat
        local data = listServers(cursor)
        if data and data.data then
            for _, server in ipairs(data.data) do
                if not bestServer or server.playing < bestServer.playing then
                    bestServer = server
                end
            end
            cursor = data.nextPageCursor
        else
            break
        end
    until not cursor or bestServer

    if bestServer then
        TeleportService:TeleportToPlaceInstance(placeId, bestServer.id, LocalPlayer)
    end
end

-- Nút: Hop to Lowest Ping
local function hopToLowestPing()
    local function fetchServers(placeId, limit)
        local url = string.format("https://games.roblox.com/v1/games/%d/servers/Public?limit=%d", placeId, limit)
        local success, response = pcall(function()
            return HttpService:JSONDecode(game:HttpGet(url))
        end)
        if success and response and response.data then
            return response.data
        end
        return nil
    end

    local servers = fetchServers(game.PlaceId, 100)
    if not servers then return end

    local bestServer = servers[1]
    for _, server in ipairs(servers) do
        if server.ping < bestServer.ping and server.playing < server.maxPlayers then
            bestServer = server
        end
    end

    local currentPing = Stats.Network.ServerStatsItem["Data Ping"]:GetValueString()
    local pingValue = tonumber(currentPing:match("(%d+)"))
    if pingValue and pingValue >= 100 then
        TeleportService:TeleportToPlaceInstance(game.PlaceId, bestServer.id, LocalPlayer)
    else
        warn("Ping is good, no need to hop.")
    end
end

-- Nút: Teleport theo JobID
local function teleportByJobId()
    if getgenv().JobId and getgenv().JobId ~= "" then
        ReplicatedStorage.__ServerBrowser:InvokeServer("teleport", getgenv().JobId)
    else
        warn("Please enter a Job ID first.")
    end
end

-- Nút: Copy JobID
local function copyJobId()
    setclipboard(tostring(game.JobId))
end

-- === 4. TÍNH NĂNG ĐI TRÊN NƯỚC (ĐÃ THÊM) ===
spawn(function()
    while task.wait() do
        pcall(function()
            if getgenv().WalkWater then
                local waterPlane = Workspace.Map:FindFirstChild("WaterBase-Plane")
                if waterPlane then
                    waterPlane.Size = Vector3.new(1000, 112, 1000) -- Tăng chiều cao để đi trên mặt nước
                end
            else
                local waterPlane = Workspace.Map:FindFirstChild("WaterBase-Plane")
                if waterPlane then
                    waterPlane.Size = Vector3.new(1000, 80, 1000) -- Trả về kích thước mặc định
                end
            end
        end)
    end
end)

-- === 5. TẮT CHAT VÀ LEADERBOARD (ĐÃ THÊM) ===
local StarterGui = game:GetService("StarterGui")
spawn(function()
    while task.wait() do
        if getgenv().Rechat then
            StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Chat, false)
        else
            StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Chat, true)
        end

        if getgenv().ReLeader then
            StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, false)
        else
            StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, true)
        end
    end
end)

-- === 6. CHỐNG AFK (ĐÃ THÊM) ===
LocalPlayer.Idled:connect(function()
    VirtualUser:Button2Down(Vector2.new(0, 0), Workspace.CurrentCamera.CFrame)
    task.wait(1)
    VirtualUser:Button2Up(Vector2.new(0, 0), Workspace.CurrentCamera.CFrame)
end)

-- === 7. TẠO GUI ĐỂ BẬT/TẮT CÁC TÍNH NĂNG ===
local library = loadstring(game:HttpGet("https://pastebin.com/raw/vff1bQ9F"))() -- Thay bằng link library ưa thích nếu muốn

local Window = library:CreateWindow("Extracted Script + Extra")
local MainTab = Window:AddTab("Main")
local HopTab = Window:AddTab("Server Hop")
local ExtraTab = Window:AddTab("Extra")

-- Tab Main
MainTab:AddToggle("InfSoru", "Infinite Soru", false, function(state)
    getgenv().InfSoru = state
end)

MainTab:AddToggle("InfEnergy", "Infinite Energy", false, function(state)
    getgenv().InfEnergy = state
end)

-- Tab Server Hop
HopTab:AddButton("Rejoin Server", function()
    rejoinServer()
end)

HopTab:AddButton("Hop Random Server", function()
    hopServer()
end)

HopTab:AddButton("Hop to Lowest Players", function()
    hopToLowestPlayers()
end)

HopTab:AddButton("Hop to Lowest Ping", function()
    hopToLowestPing()
end)

HopTab:AddTextBox("Job ID", "Enter Job ID here...", function(value)
    getgenv().JobId = value
end)

HopTab:AddButton("Teleport via Job ID", function()
    teleportByJobId()
end)

HopTab:AddButton("Copy Current Job ID", function()
    copyJobId()
end)

-- Tab Extra
ExtraTab:AddToggle("WalkWater", "Walk on Water", false, function(state)
    getgenv().WalkWater = state
end)

ExtraTab:AddToggle("Rechat", "Disable Chat", false, function(state)
    getgenv().Rechat = state
end)

ExtraTab:AddToggle("ReLeader", "Disable Leaderboard", false, function(state)
    getgenv().ReLeader = state
end)

ExtraTab:AddLabel("Anti-AFK is always ON")

library:Init()
