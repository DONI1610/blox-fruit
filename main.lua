--[[
    Blox Fruits PvP + Farm Level Script
    Based on doni.lua - GIỮ NGUYÊN CƠ CHẾ AIMBOT + THÊM FARM LEVEL
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

-- Biến cơ bản (GIỐNG SCRIPT GỐC)
local ply = Players
local plr = ply.LocalPlayer
local Root = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
local replicated = ReplicatedStorage
local vim1 = VirtualInputManager
local vim2 = VirtualUser
local TeamSelf = plr.Team
local RunSer = RunService
local Energy = plr.Character and plr.Character:FindFirstChild("Energy") and plr.Character.Energy.Value or 100
local Sec = 0.1
local MousePos = Vector3.new(0, 0, 0)
local ABmethod = "Auto Aimbots"

-- Biến cho Farm Level
local Lv = plr.Data and plr.Data.Level and plr.Data.Level.Value or 1
local Enemies = workspace.Enemies
local World1, World2, World3 = false, false, false

-- Kiểm tra game
if game.PlaceId == 2753915549 or game.PlaceId == 85211729168715 then
    World1 = true
elseif game.PlaceId == 4442272183 or game.PlaceId == 79091703265657 then
    World2 = true
elseif game.PlaceId == 7449423635 or game.PlaceId == 100117331123089 then
    World3 = true
else
    plr:Kick("❌ Map không được hỗ trợ!")
end

-- Chờ game load
repeat
    wait()
until plr.PlayerGui:FindFirstChild("Main") and plr.PlayerGui.Main:FindFirstChild("Loading") and game:IsLoaded()

-- =============================================
-- HÀM INFINITY_ABILITY (GIỐNG SCRIPT GỐC 100%)
-- =============================================

getInfinity_Ability = function(ability, enabled)
    if not Root then
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
-- HOOK REMOTE AIMBOT (GIỐNG SCRIPT GỐC 100%)
-- =============================================

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
-- GET CONNECTION ENEMIES (GIỐNG SCRIPT GỐC)
-- =============================================

GetConnectionEnemies = function(enemyName)
    for _, obj in pairs(replicated:GetChildren()) do
        if obj:IsA("Model") and ((typeof(enemyName) == "table" and table.find(enemyName, obj.Name) or obj.Name == enemyName) and (obj:FindFirstChild("Humanoid") and obj.Humanoid.Health > 0)) then
            return obj
        end
    end
    
    for _, obj in next, workspace.Enemies:GetChildren() do
        if obj:IsA("Model") and ((typeof(enemyName) == "table" and table.find(enemyName, obj.Name) or obj.Name == enemyName) and (obj:FindFirstChild("Humanoid") and obj.Humanoid.Health > 0)) then
            return obj
        end
    end
end

-- =============================================
-- HÀM DỊCH CHUYỂN (TỪ DONI.LUA)
-- =============================================

local C = Instance.new("Part", workspace)
C.Size = Vector3.new(1, 1, 1)
C.Name = "Rip_Indra"
C.Anchored = true
C.CanCollide = false
C.CanTouch = false
C.Transparency = 1

local M = workspace:FindFirstChild(C.Name)
if M and M ~= C then
    M:Destroy()
end

_tp = function(targetCFrame)
    local character = plr.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then
        return
    end
    local rootPart = character.HumanoidRootPart
    local distance = (targetCFrame.Position - rootPart.Position).Magnitude
    local tweenInfo = TweenInfo.new(distance / 300, Enum.EasingStyle.Linear)
    local tween = TweenService:Create(C, tweenInfo, { CFrame = targetCFrame })
    
    if plr.Character.Humanoid.Sit == true then
        C.CFrame = CFrame.new(C.Position.X, targetCFrame.Y, C.Position.Z)
    end
    tween:Play()
    
    task.spawn(function()
        while tween.PlaybackState == Enum.PlaybackState.Playing do
            if not shouldTween then
                tween:Cancel()
                break
            end
            task.wait(0.1)
        end
    end)
end

notween = function(targetCFrame)
    plr.Character.HumanoidRootPart.CFrame = targetCFrame
end

-- =============================================
-- BIẾN TOÀN CỤC
-- =============================================

local CurrentTarget = nil
local TargetInfo = { Name = "None", Distance = 0, Health = 0 }
local shouldTween = false

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
    local shortestDist = math.huge
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= plr then
            if player.Character and player.Character:FindFirstChild("Head") and player.Character.Humanoid.Health > 0 then
                if _G.AimCam or _G.AimMethod then
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
    end
    return closest
end

-- =============================================
-- HÀM FARM LEVEL (TỪ DONI.LUA)
-- =============================================

function QuestCheck()
    local level = plr.Data.Level.Value
    
    if World1 then
        if level == 1 or level <= 9 then
            if tostring(TeamSelf) == "Marines" then
                Mon = "Trainee"
                Qname = "MarineQuest"
                Qdata = 1
                NameMon = "Trainee"
                PosM = CFrame.new(-2709.67944, 24.5206585, 2104.24585)
                PosQ = CFrame.new(-2709.67944, 24.5206585, 2104.24585)
            else
                Mon = "Bandit"
                Qdata = 1
                Qname = "BanditQuest1"
                NameMon = "Bandit"
                PosM = CFrame.new(1045.9626464844, 27.002508163452, 1560.8203125)
                PosQ = CFrame.new(1045.9626464844, 27.002508163452, 1560.8203125)
            end
        elseif level == 10 or level <= 14 then
            Mon = "Monkey"
            Qdata = 1
            Qname = "JungleQuest"
            NameMon = "Monkey"
            PosQ = CFrame.new(-1598.08911, 35.5501175, 153.377838)
            PosM = CFrame.new(-1448.5180664062, 67.853012084961, 11.465796470642)
        elseif level == 15 or level <= 29 then
            Mon = "Gorilla"
            Qdata = 2
            Qname = "JungleQuest"
            NameMon = "Gorilla"
            PosQ = CFrame.new(-1598.08911, 35.5501175, 153.377838)
            PosM = CFrame.new(-1129.8836669922, 40.46354675293, -525.42370605469)
        elseif level == 30 or level <= 39 then
            Mon = "Pirate"
            Qdata = 1
            Qname = "BuggyQuest1"
            NameMon = "Pirate"
            PosQ = CFrame.new(-1141.07483, 4.10001802, 3831.5498)
            PosM = CFrame.new(-1103.5134277344, 13.752052307129, 3896.0910644531)
        elseif level == 40 or level <= 59 then
            Mon = "Brute"
            Qdata = 2
            Qname = "BuggyQuest1"
            NameMon = "Brute"
            PosQ = CFrame.new(-1141.07483, 4.10001802, 3831.5498)
            PosM = CFrame.new(-1140.0837402344, 14.809885025024, 4322.9213867188)
        elseif level == 60 or level <= 74 then
            Mon = "Desert Bandit"
            Qdata = 1
            Qname = "DesertQuest"
            NameMon = "Desert Bandit"
            PosQ = CFrame.new(894.488647, 5.14000702, 4392.43359)
            PosM = CFrame.new(924.7998046875, 6.4486746788025, 4481.5859375)
        elseif level == 75 or level <= 89 then
            Mon = "Desert Officer"
            Qdata = 2
            Qname = "DesertQuest"
            NameMon = "Desert Officer"
            PosQ = CFrame.new(894.488647, 5.14000702, 4392.43359)
            PosM = CFrame.new(1608.2822265625, 8.6142244338989, 4371.0073242188)
        elseif level == 90 or level <= 99 then
            Mon = "Snow Bandit"
            Qdata = 1
            Qname = "SnowQuest"
            NameMon = "Snow Bandit"
            PosQ = CFrame.new(1389.74451, 88.1519318, -1298.90796)
            PosM = CFrame.new(1354.3479003906, 87.272773742676, -1393.9465332031)
        elseif level == 100 or level <= 119 then
            Mon = "Snowman"
            Qdata = 2
            Qname = "SnowQuest"
            NameMon = "Snowman"
            PosQ = CFrame.new(1389.74451, 88.1519318, -1298.90796)
            PosM = CFrame.new(6241.9951171875, 51.522083282471, -1243.9771728516)
        elseif level == 120 or level <= 149 then
            Mon = "Chief Petty Officer"
            Qdata = 1
            Qname = "MarineQuest2"
            NameMon = "Chief Petty Officer"
            PosQ = CFrame.new(-5039.58643, 27.3500385, 4324.68018)
            PosM = CFrame.new(-4881.2309570312, 22.652044296265, 4273.7524414062)
        elseif level == 150 or level <= 174 then
            Mon = "Sky Bandit"
            Qdata = 1
            Qname = "SkyQuest"
            NameMon = "Sky Bandit"
            PosQ = CFrame.new(-4839.53027, 716.368591, -2619.44165)
            PosM = CFrame.new(-4953.20703125, 295.74420166016, -2899.2290039062)
        elseif level == 175 or level <= 189 then
            Mon = "Dark Master"
            Qdata = 2
            Qname = "SkyQuest"
            NameMon = "Dark Master"
            PosQ = CFrame.new(-4839.53027, 716.368591, -2619.44165)
            PosM = CFrame.new(-5259.8447265625, 391.39767456055, -2229.0354003906)
        elseif level == 190 or level <= 209 then
            Mon = "Prisoner"
            Qdata = 1
            Qname = "PrisonerQuest"
            NameMon = "Prisoner"
            PosQ = CFrame.new(5308.93115, 1.65517521, 475.120514)
            PosM = CFrame.new(5098.9736328125, -0.3204058110714, 474.23733520508)
        elseif level == 210 or level <= 249 then
            Mon = "Dangerous Prisoner"
            Qdata = 2
            Qname = "PrisonerQuest"
            NameMon = "Dangerous Prisoner"
            PosQ = CFrame.new(5308.93115, 1.65517521, 475.120514)
            PosM = CFrame.new(5654.5634765625, 15.633401870728, 866.29919433594)
        elseif level == 250 or level <= 274 then
            Mon = "Toga Warrior"
            Qdata = 1
            Qname = "ColosseumQuest"
            NameMon = "Toga Warrior"
            PosQ = CFrame.new(-1580.04663, 6.35000277, -2986.47534)
            PosM = CFrame.new(-1820.21484375, 51.683856964111, -2740.6650390625)
        elseif level == 275 or level <= 299 then
            Mon = "Gladiator"
            Qdata = 2
            Qname = "ColosseumQuest"
            NameMon = "Gladiator"
            PosQ = CFrame.new(-1580.04663, 6.35000277, -2986.47534)
            PosM = CFrame.new(-1292.8381347656, 56.380882263184, -3339.0314941406)
        elseif level == 300 or level <= 324 then
            Mon = "Military Soldier"
            Qdata = 1
            Qname = "MagmaQuest"
            NameMon = "Military Soldier"
            PosQ = CFrame.new(-5313.37012, 10.9500084, 8515.29395)
            PosM = CFrame.new(-5411.1645507812, 11.081554412842, 8454.29296875)
        elseif level == 325 or level <= 374 then
            Mon = "Military Spy"
            Qdata = 2
            Qname = "MagmaQuest"
            NameMon = "Military Spy"
            PosQ = CFrame.new(-5313.37012, 10.9500084, 8515.29395)
            PosM = CFrame.new(-5802.8681640625, 86.262413024902, 8828.859375)
        elseif level == 375 or level <= 399 then
            Mon = "Fishman Warrior"
            Qdata = 1
            Qname = "FishmanQuest"
            NameMon = "Fishman Warrior"
            PosQ = CFrame.new(61122.65234375, 18.497442245483, 1569.3997802734)
            PosM = CFrame.new(60878.30078125, 18.482830047607, 1543.7574462891)
        elseif level == 400 or level <= 449 then
            Mon = "Fishman Commando"
            Qdata = 2
            Qname = "FishmanQuest"
            NameMon = "Fishman Commando"
            PosQ = CFrame.new(61122.65234375, 18.497442245483, 1569.3997802734)
            PosM = CFrame.new(61922.6328125, 18.482830047607, 1493.9343261719)
        elseif level == 450 or level <= 474 then
            Mon = "God's Guard"
            Qdata = 1
            Qname = "SkyExp1Quest"
            NameMon = "God's Guard"
            PosQ = CFrame.new(-4721.88867, 843.874695, -1949.96643)
            PosM = CFrame.new(-4710.04296875, 845.27697753906, -1927.3079833984)
        elseif level == 475 or level <= 524 then
            Mon = "Shanda"
            Qdata = 2
            Qname = "SkyExp1Quest"
            NameMon = "Shanda"
            PosQ = CFrame.new(-7859.09814, 5544.19043, -381.476196)
            PosM = CFrame.new(-7678.4897460938, 5566.4038085938, -497.21560668945)
        elseif level == 525 or level <= 549 then
            Mon = "Royal Squad"
            Qdata = 1
            Qname = "SkyExp2Quest"
            NameMon = "Royal Squad"
            PosQ = CFrame.new(-7906.81592, 5634.6626, -1411.99194)
            PosM = CFrame.new(-7624.2524414062, 5658.1333007812, -1467.3542480469)
        elseif level == 550 or level <= 624 then
            Mon = "Royal Soldier"
            Qdata = 2
            Qname = "SkyExp2Quest"
            NameMon = "Royal Soldier"
            PosQ = CFrame.new(-7906.81592, 5634.6626, -1411.99194)
            PosM = CFrame.new(-7836.7534179688, 5645.6640625, -1790.6236572266)
        elseif level == 625 or level <= 649 then
            Mon = "Galley Pirate"
            Qdata = 1
            Qname = "FountainQuest"
            NameMon = "Galley Pirate"
            PosQ = CFrame.new(5259.81982, 37.3500175, 4050.0293)
            PosM = CFrame.new(5551.0219726562, 78.901351928711, 3930.4128417969)
        elseif level >= 650 then
            Mon = "Galley Captain"
            Qdata = 2
            Qname = "FountainQuest"
            NameMon = "Galley Captain"
            PosQ = CFrame.new(5259.81982, 37.3500175, 4050.0293)
            PosM = CFrame.new(5441.9516601562, 42.502059936523, 4950.09375)
        end
    elseif World2 then
        if level == 700 or level <= 724 then
            Mon = "Raider"
            Qdata = 1
            Qname = "Area1Quest"
            NameMon = "Raider"
            PosQ = CFrame.new(-429.543518, 71.7699966, 1836.18188)
            PosM = CFrame.new(-728.32672119141, 52.779319763184, 2345.7705078125)
        elseif level == 725 or level <= 774 then
            Mon = "Mercenary"
            Qdata = 2
            Qname = "Area1Quest"
            NameMon = "Mercenary"
            PosQ = CFrame.new(-429.543518, 71.7699966, 1836.18188)
            PosM = CFrame.new(-1004.3244018555, 80.158866882324, 1424.6193847656)
        elseif level == 775 or level <= 799 then
            Mon = "Swan Pirate"
            Qdata = 1
            Qname = "Area2Quest"
            NameMon = "Swan Pirate"
            PosQ = CFrame.new(638.43811, 71.769989, 918.282898)
            PosM = CFrame.new(1068.6643066406, 137.61428833008, 1322.1060791016)
        elseif level == 800 or level <= 874 then
            Mon = "Factory Staff"
            Qname = "Area2Quest"
            Qdata = 2
            NameMon = "Factory Staff"
            PosQ = CFrame.new(632.698608, 73.1055908, 918.666321)
            PosM = CFrame.new(73.078674316406, 81.863441467285, -27.470672607422)
        elseif level == 875 or level <= 899 then
            Mon = "Marine Lieutenant"
            Qdata = 1
            Qname = "MarineQuest3"
            NameMon = "Marine Lieutenant"
            PosQ = CFrame.new(-2440.79639, 71.7140732, -3216.06812)
            PosM = CFrame.new(-2821.3723144531, 75.897277832031, -3070.0891113281)
        elseif level == 900 or level <= 949 then
            Mon = "Marine Captain"
            Qdata = 2
            Qname = "MarineQuest3"
            NameMon = "Marine Captain"
            PosQ = CFrame.new(-2440.79639, 71.7140732, -3216.06812)
            PosM = CFrame.new(-1861.2310791016, 80.176582336426, -3254.6975097656)
        elseif level == 950 or level <= 974 then
            Mon = "Zombie"
            Qdata = 1
            Qname = "ZombieQuest"
            NameMon = "Zombie"
            PosQ = CFrame.new(-5497.06152, 47.5923004, -795.237061)
            PosM = CFrame.new(-5657.7768554688, 78.969734191895, -928.68701171875)
        elseif level == 975 or level <= 999 then
            Mon = "Vampire"
            Qdata = 2
            Qname = "ZombieQuest"
            NameMon = "Vampire"
            PosQ = CFrame.new(-5497.06152, 47.5923004, -795.237061)
            PosM = CFrame.new(-6037.66796875, 32.184638977051, -1340.6597900391)
        elseif level == 1000 or level <= 1049 then
            Mon = "Snow Trooper"
            Qdata = 1
            Qname = "SnowMountainQuest"
            NameMon = "Snow Trooper"
            PosQ = CFrame.new(609.858826, 400.119904, -5372.25928)
            PosM = CFrame.new(549.14733886719, 427.38705444336, -5563.6987304688)
        elseif level == 1050 or level <= 1099 then
            Mon = "Winter Warrior"
            Qdata = 2
            Qname = "SnowMountainQuest"
            NameMon = "Winter Warrior"
            PosQ = CFrame.new(609.858826, 400.119904, -5372.25928)
            PosM = CFrame.new(1142.7451171875, 475.63980102539, -5199.4165039062)
        elseif level == 1100 or level <= 1124 then
            Mon = "Lab Subordinate"
            Qdata = 1
            Qname = "IceSideQuest"
            NameMon = "Lab Subordinate"
            PosQ = CFrame.new(-6064.06885, 15.2422857, -4902.97852)
            PosM = CFrame.new(-5707.4716796875, 15.951709747314, -4513.3920898438)
        elseif level == 1125 or level <= 1174 then
            Mon = "Horned Warrior"
            Qdata = 2
            Qname = "IceSideQuest"
            NameMon = "Horned Warrior"
            PosQ = CFrame.new(-6064.06885, 15.2422857, -4902.97852)
            PosM = CFrame.new(-6341.3666992188, 15.951770782471, -5723.162109375)
        elseif level == 1175 or level <= 1199 then
            Mon = "Magma Ninja"
            Qdata = 1
            Qname = "FireSideQuest"
            NameMon = "Magma Ninja"
            PosQ = CFrame.new(-5428.03174, 15.0622921, -5299.43457)
            PosM = CFrame.new(-5449.6728515625, 76.658744812012, -5808.2006835938)
        elseif level == 1200 or level <= 1249 then
            Mon = "Lava Pirate"
            Qdata = 2
            Qname = "FireSideQuest"
            NameMon = "Lava Pirate"
            PosQ = CFrame.new(-5428.03174, 15.0622921, -5299.43457)
            PosM = CFrame.new(-5213.3315429688, 49.737880706787, -4701.451171875)
        elseif level == 1250 or level <= 1274 then
            Mon = "Ship Deckhand"
            Qdata = 1
            Qname = "ShipQuest1"
            NameMon = "Ship Deckhand"
            PosQ = CFrame.new(1037.80127, 125.092171, 32911.6016)
            PosM = CFrame.new(1212.0111083984, 150.79205322266, 33059.24609375)
        elseif level == 1275 or level <= 1299 then
            Mon = "Ship Engineer"
            Qdata = 2
            Qname = "ShipQuest1"
            NameMon = "Ship Engineer"
            PosQ = CFrame.new(1037.80127, 125.092171, 32911.6016)
            PosM = CFrame.new(919.47863769531, 43.544013977051, 32779.96875)
        elseif level == 1300 or level <= 1324 then
            Mon = "Ship Steward"
            Qdata = 1
            Qname = "ShipQuest2"
            NameMon = "Ship Steward"
            PosQ = CFrame.new(968.80957, 125.092171, 33244.125)
            PosM = CFrame.new(919.43853759766, 129.55599975586, 33436.03515625)
        elseif level == 1325 or level <= 1349 then
            Mon = "Ship Officer"
            Qdata = 2
            Qname = "ShipQuest2"
            NameMon = "Ship Officer"
            PosQ = CFrame.new(968.80957, 125.092171, 33244.125)
            PosM = CFrame.new(1036.0179443359, 181.4390411377, 33315.7265625)
        elseif level == 1350 or level <= 1374 then
            Mon = "Arctic Warrior"
            Qdata = 1
            Qname = "FrostQuest"
            NameMon = "Arctic Warrior"
            PosQ = CFrame.new(5667.6582, 26.7997818, -6486.08984)
            PosM = CFrame.new(5966.24609375, 62.970020294189, -6179.3828125)
        elseif level == 1375 or level <= 1424 then
            Mon = "Snow Lurker"
            Qdata = 2
            Qname = "FrostQuest"
            NameMon = "Snow Lurker"
            PosQ = CFrame.new(5667.6582, 26.7997818, -6486.08984)
            PosM = CFrame.new(5407.0737304688, 69.194374084473, -6880.8803710938)
        elseif level == 1425 or level <= 1449 then
            Mon = "Sea Soldier"
            Qdata = 1
            Qname = "ForgottenQuest"
            NameMon = "Sea Soldier"
            PosQ = CFrame.new(-3054.44458, 235.544281, -10142.8193)
            PosM = CFrame.new(-3028.2236328125, 64.674514770508, -9775.4267578125)
        elseif level >= 1450 then
            Mon = "Water Fighter"
            Qdata = 2
            Qname = "ForgottenQuest"
            NameMon = "Water Fighter"
            PosQ = CFrame.new(-3054.44458, 235.544281, -10142.8193)
            PosM = CFrame.new(-3352.9013671875, 285.01556396484, -10534.841796875)
        end
    elseif World3 then
        if level == 1500 or level <= 1524 then
            Mon = "Pirate Millionaire"
            Qdata = 1
            Qname = "PiratePortQuest"
            NameMon = "Pirate Millionaire"
            PosQ = CFrame.new(-712.82727050781, 98.577049255371, 5711.9541015625)
            PosM = CFrame.new(-712.82727050781, 98.577049255371, 5711.9541015625)
        elseif level == 1525 or level <= 1574 then
            Mon = "Pistol Billionaire"
            Qdata = 2
            Qname = "PiratePortQuest"
            NameMon = "Pistol Billionaire"
            PosQ = CFrame.new(-723.43316650391, 147.42906188965, 5931.9931640625)
            PosM = CFrame.new(-723.43316650391, 147.42906188965, 5931.9931640625)
        elseif level == 1575 or level <= 1599 then
            Mon = "Dragon Crew Warrior"
            Qdata = 1
            Qname = "AmazonQuest"
            NameMon = "Dragon Crew Warrior"
            PosQ = CFrame.new(6779.0327148438, 111.16865539551, -801.21307373047)
            PosM = CFrame.new(6779.0327148438, 111.16865539551, -801.21307373047)
        elseif level == 1600 or level <= 1624 then
            Mon = "Dragon Crew Archer"
            Qname = "AmazonQuest"
            Qdata = 2
            NameMon = "Dragon Crew Archer"
            PosQ = CFrame.new(6955.8974609375, 546.66589355469, 309.04013061523)
            PosM = CFrame.new(6955.8974609375, 546.66589355469, 309.04013061523)
        elseif level == 1625 or level <= 1649 then
            Mon = "Hydra Enforcer"
            Qname = "VenomCrewQuest"
            Qdata = 1
            NameMon = "Hydra Enforcer"
            PosQ = CFrame.new(4620.6157226562, 1002.2954711914, 399.08688354492)
            PosM = CFrame.new(4620.6157226562, 1002.2954711914, 399.08688354492)
        elseif level == 1650 or level <= 1699 then
            Mon = "Venomous Assailant"
            Qname = "VenomCrewQuest"
            Qdata = 2
            NameMon = "Venomous Assailant"
            PosQ = CFrame.new(4697.5918, 1100.65137, 946.401978)
            PosM = CFrame.new(4697.5918, 1100.65137, 946.401978)
        elseif level == 1700 or level <= 1724 then
            Mon = "Marine Commodore"
            Qdata = 1
            Qname = "MarineTreeIsland"
            NameMon = "Marine Commodore"
            PosQ = CFrame.new(2180.54126, 27.8156815, -6741.5498)
            PosM = CFrame.new(2286.0078125, 73.133918762207, -7159.8090820312)
        elseif level == 1725 or level <= 1774 then
            Mon = "Marine Rear Admiral"
            NameMon = "Marine Rear Admiral"
            Qname = "MarineTreeIsland"
            Qdata = 2
            PosQ = CFrame.new(2179.98828125, 28.731239318848, -6740.0551757813)
            PosM = CFrame.new(3656.7736816406, 160.52406311035, -7001.5986328125)
        elseif level == 1775 or level <= 1799 then
            Mon = "Fishman Raider"
            Qdata = 1
            Qname = "DeepForestIsland3"
            NameMon = "Fishman Raider"
            PosQ = CFrame.new(-10581.6563, 330.872955, -8761.18652)
            PosM = CFrame.new(-10407.526367188, 331.76263427734, -8368.5166015625)
        elseif level == 1800 or level <= 1824 then
            Mon = "Fishman Captain"
            Qdata = 2
            Qname = "DeepForestIsland3"
            NameMon = "Fishman Captain"
            PosQ = CFrame.new(-10581.6563, 330.872955, -8761.18652)
            PosM = CFrame.new(-10994.701171875, 352.38140869141, -9002.1103515625)
        elseif level == 1825 or level <= 1849 then
            Mon = "Forest Pirate"
            Qdata = 1
            Qname = "DeepForestIsland"
            NameMon = "Forest Pirate"
            PosQ = CFrame.new(-13234.04, 331.488495, -7625.40137)
            PosM = CFrame.new(-13274.478515625, 332.37814331055, -7769.5805664062)
        elseif level == 1850 or level <= 1899 then
            Mon = "Mythological Pirate"
            Qdata = 2
            Qname = "DeepForestIsland"
            NameMon = "Mythological Pirate"
            PosQ = CFrame.new(-13234.04, 331.488495, -7625.40137)
            PosM = CFrame.new(-13680.607421875, 501.08154296875, -6991.189453125)
        elseif level == 1900 or level <= 1924 then
            Mon = "Jungle Pirate"
            Qdata = 1
            Qname = "DeepForestIsland2"
            NameMon = "Jungle Pirate"
            PosQ = CFrame.new(-12680.3818, 389.971039, -9902.01953)
            PosM = CFrame.new(-12256.16015625, 331.73828125, -10485.836914062)
        elseif level == 1925 or level <= 1974 then
            Mon = "Musketeer Pirate"
            Qdata = 2
            Qname = "DeepForestIsland2"
            NameMon = "Musketeer Pirate"
            PosQ = CFrame.new(-12680.3818, 389.971039, -9902.01953)
            PosM = CFrame.new(-13457.904296875, 391.54565429688, -9859.177734375)
        elseif level == 1975 or level <= 1999 then
            Mon = "Reborn Skeleton"
            Qdata = 1
            Qname = "HauntedQuest1"
            NameMon = "Reborn Skeleton"
            PosQ = CFrame.new(-9479.2168, 141.215088, 5566.09277)
            PosM = CFrame.new(-8763.7236328125, 165.72299194336, 6159.8618164062)
        elseif level == 2000 or level <= 2024 then
            Mon = "Living Zombie"
            Qdata = 2
            Qname = "HauntedQuest1"
            NameMon = "Living Zombie"
            PosQ = CFrame.new(-9479.2168, 141.215088, 5566.09277)
            PosM = CFrame.new(-10144.131835938, 138.6266784668, 5838.0888671875)
        elseif level == 2025 or level <= 2049 then
            Mon = "Demonic Soul"
            Qdata = 1
            Qname = "HauntedQuest2"
            NameMon = "Demonic Soul"
            PosQ = CFrame.new(-9516.99316, 172.017181, 6078.46533)
            PosM = CFrame.new(-9505.8720703125, 172.10482788086, 6158.9931640625)
        elseif level == 2050 or level <= 2074 then
            Mon = "Posessed Mummy"
            Qdata = 2
            Qname = "HauntedQuest2"
            NameMon = "Posessed Mummy"
            PosQ = CFrame.new(-9516.99316, 172.017181, 6078.46533)
            PosM = CFrame.new(-9582.0224609375, 6.2515273094177, 6205.478515625)
        elseif level == 2075 or level <= 2099 then
            Mon = "Peanut Scout"
            Qdata = 1
            Qname = "NutsIslandQuest"
            NameMon = "Peanut Scout"
            PosQ = CFrame.new(-2104.3908691406, 38.104167938232, -10194.21875)
            PosM = CFrame.new(-2143.2419433594, 47.721984863281, -10029.995117188)
        elseif level == 2100 or level <= 2124 then
            Mon = "Peanut President"
            Qdata = 2
            Qname = "NutsIslandQuest"
            NameMon = "Peanut President"
            PosQ = CFrame.new(-2104.3908691406, 38.104167938232, -10194.21875)
            PosM = CFrame.new(-1859.3540039062, 38.103168487549, -10422.4296875)
        elseif level == 2125 or level <= 2149 then
            Mon = "Ice Cream Chef"
            Qdata = 1
            Qname = "IceCreamIslandQuest"
            NameMon = "Ice Cream Chef"
            PosQ = CFrame.new(-820.64825439453, 65.819526672363, -10965.795898438)
            PosM = CFrame.new(-872.24658203125, 65.81957244873, -10919.95703125)
        elseif level == 2150 or level <= 2199 then
            Mon = "Ice Cream Commander"
            Qdata = 2
            Qname = "IceCreamIslandQuest"
            NameMon = "Ice Cream Commander"
            PosQ = CFrame.new(-820.64825439453, 65.819526672363, -10965.795898438)
            PosM = CFrame.new(-558.06103515625, 112.04895782471, -11290.774414062)
        elseif level == 2200 or level <= 2224 then
            Mon = "Cookie Crafter"
            Qdata = 1
            Qname = "CakeQuest1"
            NameMon = "Cookie Crafter"
            PosQ = CFrame.new(-2021.32007, 37.7982254, -12028.7295)
            PosM = CFrame.new(-2374.13671875, 37.798263549805, -12125.30859375)
        elseif level == 2225 or level <= 2249 then
            Mon = "Cake Guard"
            Qdata = 2
            Qname = "CakeQuest1"
            NameMon = "Cake Guard"
            PosQ = CFrame.new(-2021.32007, 37.7982254, -12028.7295)
            PosM = CFrame.new(-1598.3070068359, 43.773197174072, -12244.581054688)
        elseif level == 2250 or level <= 2274 then
            Mon = "Baking Staff"
            Qdata = 1
            Qname = "CakeQuest2"
            NameMon = "Baking Staff"
            PosQ = CFrame.new(-1927.91602, 37.7981339, -12842.5391)
            PosM = CFrame.new(-1887.8099365234, 77.618507385254, -12998.350585938)
        elseif level == 2275 or level <= 2299 then
            Mon = "Head Baker"
            Qdata = 2
            Qname = "CakeQuest2"
            NameMon = "Head Baker"
            PosQ = CFrame.new(-1927.91602, 37.7981339, -12842.5391)
            PosM = CFrame.new(-2216.1882324219, 82.884521484375, -12869.293945312)
        elseif level == 2300 or level <= 2324 then
            Mon = "Cocoa Warrior"
            Qdata = 1
            Qname = "ChocQuest1"
            NameMon = "Cocoa Warrior"
            PosQ = CFrame.new(233.22836303711, 29.876001358032, -12201.233398438)
            PosM = CFrame.new(-21.553283691406, 80.574996948242, -12352.387695312)
        elseif level == 2325 or level <= 2349 then
            Mon = "Chocolate Bar Battler"
            Qdata = 2
            Qname = "ChocQuest1"
            NameMon = "Chocolate Bar Battler"
            PosQ = CFrame.new(233.22836303711, 29.876001358032, -12201.233398438)
            PosM = CFrame.new(582.59057617188, 77.188095092773, -12463.162109375)
        elseif level == 2350 or level <= 2374 then
            Mon = "Sweet Thief"
            Qdata = 1
            Qname = "ChocQuest2"
            NameMon = "Sweet Thief"
            PosQ = CFrame.new(150.50663757324, 30.693693161011, -12774.502929688)
            PosM = CFrame.new(165.1884765625, 76.058853149414, -12600.836914062)
        elseif level == 2375 or level <= 2399 then
            Mon = "Candy Rebel"
            Qdata = 2
            Qname = "ChocQuest2"
            NameMon = "Candy Rebel"
            PosQ = CFrame.new(150.50663757324, 30.693693161011, -12774.502929688)
            PosM = CFrame.new(134.86563110352, 77.247680664062, -12876.547851562)
        end
    end
end

function QuestNeta()
    QuestCheck()
    return {
        [1] = Mon,
        [2] = Qdata,
        [3] = Qname,
        [4] = PosM,
        [5] = NameMon,
        [6] = PosQ,
    }
end

-- Hàm kill dùng cho farm
G = {}
G.Alive = function(enemy)
    if not enemy then return false end
    local humanoid = enemy:FindFirstChild("Humanoid")
    return humanoid and humanoid.Health > 0
end

G.Kill = function(enemy, isFarming)
    if enemy and isFarming then
        if not enemy:GetAttribute("Locked") then
            enemy:SetAttribute("Locked", enemy.HumanoidRootPart.CFrame)
        end
        PosMon = (enemy:GetAttribute("Locked")).Position
        EquipWeapon(_G.SelectWeapon)
        
        local tool = plr.Character:FindFirstChildOfClass("Tool")
        local toolTip = tool and tool.ToolTip
        
        if toolTip == "Blox Fruit" then
            _tp(enemy.HumanoidRootPart.CFrame * CFrame.new(0, 10, 0) * CFrame.Angles(0, math.rad(90), 0))
        else
            _tp(enemy.HumanoidRootPart.CFrame * CFrame.new(0, 30, 0) * CFrame.Angles(0, math.rad(180), 0))
        end
    end
end

-- Hàm trang bị vũ khí
EquipWeapon = function(weaponName)
    if not weaponName then return end
    if plr.Backpack:FindFirstChild(weaponName) then
        plr.Character.Humanoid:EquipTool(plr.Backpack:FindFirstChild(weaponName))
    end
end

-- =============================================
-- AIMBOT LOOP
-- =============================================

task.spawn(function()
    while task.wait() do
        pcall(function()
            if _G.AimMethod then
                if ABmethod == "AimBots Skill" then
                    for _, player in ipairs(Players:GetPlayers()) do
                        if player.Name == _G.PlayersList and player.Team ~= plr.Team then
                            if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                                MousePos = player.Character.HumanoidRootPart.Position
                                CurrentTarget = player
                            end
                        end
                    end
                elseif ABmethod == "Auto Aimbots" then
                    local closest = GetClosestPlayer()
                    if closest and closest.Character and closest.Character:FindFirstChild("HumanoidRootPart") then
                        MousePos = closest.Character.HumanoidRootPart.Position
                        CurrentTarget = closest
                    else
                        CurrentTarget = nil
                    end
                end
            end
            
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
                
                local function closestplayer()
                    local closest = nil
                    local shortestDist = math.huge
                    
                    for _, player in next, ply:GetPlayers() do
                        if player ~= plr then
                            if player.Character and player.Character:FindFirstChild("Head") and _G.AimCam and player.Character.Humanoid.Health > 0 then
                                local dist = (player.Character.Head.Position - plr.Character.Head.Position).Magnitude
                                if dist < shortestDist then
                                    shortestDist = dist
                                    closest = player
                                end
                            end
                        end
                    end
                    return closest
                end
                
                local target = closestplayer()
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

task.spawn(function()
    while wait(0.5) do
        if _G.InfSoru then
            pcall(function()
                getInfinity_Ability("Soru", _G.InfSoru)
            end)
        end
    end
end)

task.spawn(function()
    while wait(0.5) do
        if _G.infEnergy then
            pcall(function()
                getInfinity_Ability("Energy", _G.infEnergy)
            end)
        end
    end
end)

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
    while wait(0.2) do
        pcall(function()
            if _G.RaceClickAutov4 then
                if plr.Character and plr.Character:FindFirstChild("RaceEnergy") then
                    if plr.Character.RaceEnergy.Value == 1 then
                        vim1:SendKeyEvent(true, "Y", false, game)
                        wait(0.1)
                        vim1:SendKeyEvent(false, "Y", false, game)
                    end
                end
            end
        end)
    end
end)

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
-- FARM LEVEL LOOP (TỪ DONI.LUA)
-- =============================================

task.spawn(function()
    while wait(Sec) do
        if _G.AutoFarmLevel then
            pcall(function()
                QuestCheck()
                
                local questInfo = QuestNeta()
                local questTitle = plr.PlayerGui.Main.Quest.Container.QuestTitle.Title.Text
                
                -- Kiểm tra quest hiện tại
                if not string.find(questTitle, questInfo[5]) then
                    replicated.Remotes.CommF_:InvokeServer("AbandonQuest")
                end
                
                -- Nếu chưa có quest
                if plr.PlayerGui.Main.Quest.Visible == false then
                    shouldTween = true
                    _tp(questInfo[6])
                    
                    if (Root.Position - questInfo[6].Position).Magnitude <= 5 then
                        replicated.Remotes.CommF_:InvokeServer("StartQuest", questInfo[3], questInfo[2])
                    end
                    
                -- Nếu đã có quest
                elseif plr.PlayerGui.Main.Quest.Visible == true then
                    if workspace.Enemies:FindFirstChild(questInfo[1]) then
                        for _, enemy in pairs(workspace.Enemies:GetChildren()) do
                            if G.Alive(enemy) and enemy.Name == questInfo[1] then
                                if string.find(questTitle, questInfo[5]) then
                                    repeat
                                        wait()
                                        shouldTween = true
                                        G.Kill(enemy, _G.AutoFarmLevel)
                                    until not _G.AutoFarmLevel or enemy.Humanoid.Health <= 0 or not enemy.Parent or plr.PlayerGui.Main.Quest.Visible == false
                                else
                                    replicated.Remotes.CommF_:InvokeServer("AbandonQuest")
                                end
                            end
                        end
                    else
                        shouldTween = true
                        _tp(questInfo[4])
                        if replicated:FindFirstChild(questInfo[1]) then
                            _tp(replicated:FindFirstChild(questInfo[1]).HumanoidRootPart.CFrame * CFrame.new(0, 30, 0))
                        end
                    end
                end
            end)
        else
            shouldTween = false
        end
    end
end)

-- =============================================
-- ESP FUNCTIONS
-- =============================================

EspPly = function()
    for _, player in next, Players:GetChildren() do
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
                for _, player in ipairs(ply:GetChildren()) do
                    if player ~= plr and player.Character and player.Character:FindFirstChild("Humanoid") then
                        replicated.Remotes.CommF_:InvokeServer("AcceptAlly", player.Name)
                    end
                end
            end)
        end
    end
end)

-- =============================================
-- HOP SERVER
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
-- ANTI AFK
-- =============================================

plr.Idled:connect(function()
    vim2:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
    wait(1)
    vim2:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
end)

-- =============================================
-- LOAD THƯ VIỆN UI
-- =============================================

local Library = (loadstring(game:HttpGet("https://pastefy.app/J1FR5ssM/raw")))()

-- =============================================
-- TẠO WINDOW VÀ TABS
-- =============================================

local Window = Library:NewWindow()
local CombatTab = Window:T("⚔️ COMBAT PVP")
local FarmTab = Window:T("🌾 FARM LEVEL")

-- =============================================
-- FARM LEVEL TAB (TỪ DONI.LUA)
-- =============================================

local farmSection = FarmTab:AddSection("🌾 AUTO FARM LEVEL")

farmSection:AddToggle({
    Title = "Auto Farm Level",
    Description = "Tự động farm level theo quest",
    Default = false,
    Callback = function(value)
        _G.AutoFarmLevel = value
        if not value then
            shouldTween = false
        end
    end
})

farmSection:AddSeperator("THÔNG TIN")

-- Paragraph hiển thị level hiện tại
local levelPara = farmSection:AddParagraph({
    Title = "Level Hiện Tại",
    Content = "Đang tải..."
})

-- Cập nhật level
task.spawn(function()
    while wait(1) do
        pcall(function()
            local level = plr.Data.Level.Value
            levelPara:SetDesc("Level: " .. level)
        end)
    end
end)

-- =============================================
-- COMBAT PVP TAB (GIỮ NGUYÊN)
-- =============================================

local aimbotSection = CombatTab:AddSection("🎯 AIMBOT SETTINGS")

aimbotSection:AddToggle({
    Title = "Aimbot Method Skills",
    Description = "",
    Default = false,
    Callback = function(value)
        _G.AimMethod = value
    end
})

local aimMethods = { "AimBots Skill", "Auto Aimbots" }
aimbotSection:AddDropdown({
    Title = "Choose Aim Method",
    Description = "",
    Values = aimMethods,
    Default = "Auto Aimbots",
    Multi = false,
    Callback = function(value)
        ABmethod = value
    end
})

local playerList = {}
for _, player in ipairs(Players:GetPlayers()) do
    table.insert(playerList, player.Name)
end

aimbotSection:AddDropdown({
    Title = "Choose Players",
    Description = "",
    Values = playerList,
    Default = false,
    Multi = false,
    Callback = function(value)
        _G.PlayersList = value
    end
})

aimbotSection:AddToggle({
    Title = "Aimbot Camera Closest Players",
    Description = "",
    Default = false,
    Callback = function(value)
        _G.AimCam = value
    end
})

aimbotSection:AddToggle({
    Title = "Ignore Same Teams",
    Description = "turn on for ignore not aimbot same team",
    Default = false,
    Callback = function(value)
        _G.NoAimTeam = value
    end
})

-- INFINITY ABILITIES
local infinitySection = CombatTab:AddSection("♾️ INFINITY ABILITIES")

infinitySection:AddToggle({
    Title = "Instance Soru [ INF ]",
    Description = "turn on for make soru infinity",
    Default = false,
    Callback = function(value)
        _G.InfSoru = value
        if value then
            getInfinity_Ability("Soru", _G.InfSoru)
        end
    end
})

infinitySection:AddToggle({
    Title = "Instance Energy [ INF ]",
    Description = "turn on for make energy infinity",
    Default = false,
    Callback = function(value)
        _G.infEnergy = value
        if value then
            getInfinity_Ability("Energy", _G.infEnergy)
        end
    end
})

infinitySection:AddToggle({
    Title = "Instance Observation Range [ INF ]",
    Description = "turn on for make observation range infinity",
    Default = false,
    Callback = function(value)
        _G.InfiniteObRange = value
        if value then
            getInfinity_Ability("Observation", _G.InfiniteObRange)
        end
    end
})

-- RACE ABILITIES
local raceSection = CombatTab:AddSection("👤 RACE ABILITIES")

raceSection:AddToggle({
    Title = "Auto Turn on Race V3",
    Description = "",
    Default = false,
    Callback = function(value)
        _G.RaceClickAutov3 = value
    end
})

raceSection:AddToggle({
    Title = "Auto Turn on Race V4",
    Description = "",
    Default = false,
    Callback = function(value)
        _G.RaceClickAutov4 = value
    end
})

-- ESP
local espSection = CombatTab:AddSection("👁️ ESP")

espSection:AddToggle({
    Title = "Esp Players",
    Description = "",
    Default = false,
    Callback = function(value)
        PlayerEsp = value
    end
})

espSection:AddToggle({
    Title = "Esp Fruits",
    Description = "",
    Default = false,
    Callback = function(value)
        DevilFruitESP = value
    end
})

-- VISUAL INDICATORS
local visualSection = CombatTab:AddSection("📊 VISUAL INDICATORS")

visualSection:AddToggle({
    Title = "Show FPS",
    Description = "",
    Default = true,
    Callback = function(value)
        _G.ShowFPS = value
    end
})

visualSection:AddToggle({
    Title = "Show Ping",
    Description = "",
    Default = true,
    Callback = function(value)
        _G.ShowPing = value
    end
})

visualSection:AddToggle({
    Title = "Show Target Info",
    Description = "",
    Default = true,
    Callback = function(value)
        _G.ShowTargetInfo = value
    end
})

-- UTILITIES
local utilitySection = CombatTab:AddSection("🛠️ UTILITIES")

utilitySection:AddToggle({
    Title = "Accept Allies",
    Description = "turn on for auto accept ally",
    Default = false,
    Callback = function(value)
        _G.AcceptAlly = value
    end
})

utilitySection:AddToggle({
    Title = "Teleport to choose players",
    Description = "",
    Default = false,
    Callback = function(value)
        _G.TpPly = value
        if value then
            spawn(function()
                pcall(function()
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
            end)
        end
    end
})

utilitySection:AddToggle({
    Title = "Spectate Choose Players",
    Description = "",
    Default = false,
    Callback = function(value)
        if value then
            spawn(function()
                repeat
                    task.wait(0.1)
                    if _G.PlayersList and Players[_G.PlayersList] and Players[_G.PlayersList].Character then
                        workspace.Camera.CameraSubject = Players[_G.PlayersList].Character.Humanoid
                    end
                until not value
                workspace.Camera.CameraSubject = plr.Character.Humanoid
            end)
        end
    end
})

utilitySection:AddButton({
    Title = "Hop Server",
    Description = "",
    Callback = function()
        Hop()
    end
})

utilitySection:AddButton({
    Title = "Rejoin Server",
    Description = "",
    Callback = function()
        TeleportService:Teleport(game.PlaceId, plr)
    end
})

-- =============================================
-- THÔNG BÁO
-- =============================================

print("✅ Blox Fruits PvP + Farm Level Script!")
print("⚔️ Tab Combat PVP - GIỐNG HỆT DONI.LUA")
print("🌾 Tab Farm Level - TỪ DONI.LUA")
