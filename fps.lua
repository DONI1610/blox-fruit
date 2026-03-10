--[[
    BEAR HUB - FARM ONLY EXTRACT
    Chỉ bao gồm các chức năng farm chính
    Không bao gồm: PvP, ESP, Shop, Teleport, Sea Events, v.v.
--]]

local Services = setmetatable({}, {
    __index = function(self, serviceName)
        local service = game:GetService(serviceName)
        rawset(self, serviceName, service)
        return service
    end
})

local Players = Services.Players
local ReplicatedStorage = Services.ReplicatedStorage
local TeleportService = Services.TeleportService
local TW = Services.TweenService
local Lighting = Services.Lighting
local vim1 = Services.VirtualInputManager
local vim2 = Services.VirtualUser
local RunSer = Services.RunService
local Stats = Services.Stats
local HttpService = Services.HttpService
local CollectionService = Services.CollectionService

local player = Players.LocalPlayer
local replicated = ReplicatedStorage

-- ========================================
-- GLOBAL VARIABLES
-- ========================================
_G = _G or {}
_G.BringRange = _G.BringRange or 235
_G.MaxBringMobs = _G.MaxBringMobs or 3
_G.MobHeight = _G.MobHeight or 20
_G.TweenSpeedFar = _G.TweenSpeedFar or 300
_G.TweenSpeedNear = _G.TweenSpeedNear or 900

-- World Detection
local placeId = game.PlaceId
if placeId == 2753915549 or placeId == 85211729168715 then
    World1 = true
elseif placeId == 4442272183 or placeId == 79091703265657 then
    World2 = true
elseif placeId == 7449423635 or placeId == 100117331123089 then
    World3 = true
end

-- ========================================
-- HELPER FUNCTIONS
-- ========================================

local function GetBP(itemName)
    return player.Backpack:FindFirstChild(itemName) or player.Character:FindFirstChild(itemName)
end

local function EquipWeapon(weaponName)
    if not weaponName then return end
    if player.Backpack:FindFirstChild(weaponName) then
        player.Character.Humanoid:EquipTool(player.Backpack:FindFirstChild(weaponName))
    end
end

local function weaponSc(toolTip)
    for _, tool in pairs(player.Backpack:GetChildren()) do
        if tool:IsA("Tool") and tool.ToolTip == toolTip then
            EquipWeapon(tool.Name)
        end
    end
end

local function Useskills(category, key)
    if category == "Melee" then
        weaponSc("Melee")
        vim1:SendKeyEvent(true, key, false, game)
        vim1:SendKeyEvent(false, key, false, game)
    elseif category == "Sword" then
        weaponSc("Sword")
        vim1:SendKeyEvent(true, key, false, game)
        vim1:SendKeyEvent(false, key, false, game)
    elseif category == "Blox Fruit" then
        weaponSc("Blox Fruit")
        vim1:SendKeyEvent(true, key, false, game)
        vim1:SendKeyEvent(false, key, false, game)
    elseif category == "Gun" then
        weaponSc("Gun")
        vim1:SendKeyEvent(true, key, false, game)
        vim1:SendKeyEvent(false, key, false, game)
    elseif category == "nil" and key == "Y" then
        vim1:SendKeyEvent(true, "Y", false, game)
        vim1:SendKeyEvent(false, "Y", false, game)
    end
end

-- Tween function
local RipPart = Instance.new("Part", workspace)
RipPart.Size = Vector3.new(1, 1, 1)
RipPart.Name = "Rip_Indra_Farm"
RipPart.Anchored = true
RipPart.CanCollide = false
RipPart.CanTouch = false
RipPart.Transparency = 1

local function _tp(targetCFrame)
    local char = player.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local hrp = char.HumanoidRootPart
    local dist = (targetCFrame.Position - hrp.Position).Magnitude
    local speed = dist <= 90 and _G.TweenSpeedNear or _G.TweenSpeedFar
    local tweenInfo = TweenInfo.new(dist / speed, Enum.EasingStyle.Linear)
    local tween = TW:Create(RipPart, tweenInfo, {CFrame = targetCFrame})
    tween:Play()
    task.spawn(function()
        while tween.PlaybackState == Enum.PlaybackState.Playing do
            if not _G.FarmActive then tween:Cancel() break end
            task.wait(0.1)
        end
    end)
end

local function notween(targetCFrame)
    local char = player.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        char.HumanoidRootPart.CFrame = targetCFrame
    end
end

-- ========================================
-- BRING ENEMY SYSTEM
-- ========================================

local function IsRaidMob(mob)
    local name = mob.Name:lower()
    if name:find("raid") or name:find("microchip") or name:find("island") then return true end
    if mob:GetAttribute("IsRaid") or mob:GetAttribute("RaidMob") or mob:GetAttribute("IsBoss") then return true end
    local hum = mob:FindFirstChild("Humanoid")
    if hum and hum.WalkSpeed == 0 then return true end
    return false
end

local function FarmActive()
    return _G.Level or _G.AutoFarm_Bone or _G.AutoFarm_Cake or _G.AutoTyrant or 
           _G.AutoFarmNear or (getgenv()).AutoMaterial or _G.FarmMastery_Dev or 
           _G.FarmMastery_G or _G.FarmMastery_S
end

_G.FarmActive = false
_G.BringActive = false

local function BringEnemy()
    if not FarmActive() or not _G.BringActive then return end

    local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    pcall(function() sethiddenproperty(player, "SimulationRadius", math.huge) end)

    local targetPos = _G.PosMon or hrp.Position
    local enemies = workspace.Enemies:GetChildren()
    local count = 0

    for _, mob in ipairs(enemies) do
        if count >= _G.MaxBringMobs then break end

        local hum = mob:FindFirstChild("Humanoid")
        local root = mob:FindFirstChild("HumanoidRootPart")

        if hum and root and hum.Health > 0 and not IsRaidMob(mob) then
            local dist = (root.Position - targetPos).Magnitude
            if dist <= _G.BringRange and not root:GetAttribute("Tweening") then
                count = count + 1
                root:SetAttribute("Tweening", true)

                local tween = TW:Create(
                    root,
                    TweenInfo.new(0.45, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
                    {CFrame = CFrame.new(targetPos)}
                )

                tween:Play()
                tween.Completed:Once(function()
                    if root then root:SetAttribute("Tweening", false) end
                end)
            end
        end
    end
end

-- Bring loop
task.spawn(function()
    while task.wait(1) do
        if FarmActive() then
            _G.BringActive = true
            BringEnemy()
            task.wait(3)
            _G.BringActive = false
            task.wait(5)
        else
            _G.BringActive = false
            task.wait(1)
        end
    end
end)

-- ========================================
-- AUTO KEN (Observation)
-- ========================================

_G.AutoKen = true
local commE = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("CommE")

local function HasKen()
    local char = player.Character
    return char and CollectionService:HasTag(char, "Ken")
end

task.spawn(function()
    while _G.AutoKen do
        task.wait(0.2)
        if not HasKen() then
            pcall(function() commE:FireServer("Ken", true) end)
        end
    end
end)

-- ========================================
-- AUTO HAKI (Buso)
-- ========================================

_G.AutoHaki = true

task.spawn(function()
    while task.wait(0.2) do
        pcall(function()
            if _G.AutoHaki then
                if not player.Character:FindFirstChild("HasBuso") then
                    replicated.Remotes.CommF_:InvokeServer("Buso")
                end
            end
        end)
    end
end)

-- ========================================
-- FARM LEVEL SYSTEM
-- ========================================

_G.Level = false
_G.StartFarm = false
_G.AcceptQuest = true

-- Quest data tables (simplified)
local QuestData = {}

if World1 then
    QuestData = {
        [1] = { Mon = "Bandit", Qname = "BanditQuest1", Qdata = 1, NameMon = "Bandit", 
                PosQ = CFrame.new(1045.96, 27.00, 1560.82), PosM = CFrame.new(1045.96, 27.00, 1560.82) },
        [10] = { Mon = "Monkey", Qname = "JungleQuest", Qdata = 1, NameMon = "Monkey",
                 PosQ = CFrame.new(-1598.08, 35.55, 153.37), PosM = CFrame.new(-1448.51, 67.85, 11.46) },
        [15] = { Mon = "Gorilla", Qname = "JungleQuest", Qdata = 2, NameMon = "Gorilla",
                 PosQ = CFrame.new(-1598.08, 35.55, 153.37), PosM = CFrame.new(-1129.88, 40.46, -525.42) },
        [30] = { Mon = "Pirate", Qname = "BuggyQuest1", Qdata = 1, NameMon = "Pirate",
                 PosQ = CFrame.new(-1141.07, 4.10, 3831.54), PosM = CFrame.new(-1103.51, 13.75, 3896.09) },
        [40] = { Mon = "Brute", Qname = "BuggyQuest1", Qdata = 2, NameMon = "Brute",
                 PosQ = CFrame.new(-1141.07, 4.10, 3831.54), PosM = CFrame.new(-1140.08, 14.80, 4322.92) },
        [60] = { Mon = "Desert Bandit", Qname = "DesertQuest", Qdata = 1, NameMon = "Desert Bandit",
                 PosQ = CFrame.new(894.48, 5.14, 4392.43), PosM = CFrame.new(924.79, 6.44, 4481.58) },
        [75] = { Mon = "Desert Officer", Qname = "DesertQuest", Qdata = 2, NameMon = "Desert Officer",
                 PosQ = CFrame.new(894.48, 5.14, 4392.43), PosM = CFrame.new(1608.28, 8.61, 4371.00) },
        [90] = { Mon = "Snow Bandit", Qname = "SnowQuest", Qdata = 1, NameMon = "Snow Bandit",
                 PosQ = CFrame.new(1389.74, 88.15, -1298.90), PosM = CFrame.new(1354.34, 87.27, -1393.94) },
        [100] = { Mon = "Snowman", Qname = "SnowQuest", Qdata = 2, NameMon = "Snowman",
                  PosQ = CFrame.new(1389.74, 88.15, -1298.90), PosM = CFrame.new(1201.64, 144.57, -1550.06) },
        [120] = { Mon = "Chief Petty Officer", Qname = "MarineQuest2", Qdata = 1, NameMon = "Chief Petty Officer",
                  PosQ = CFrame.new(-5039.58, 27.35, 4324.68), PosM = CFrame.new(-4881.23, 22.65, 4273.75) },
        [150] = { Mon = "Sky Bandit", Qname = "SkyQuest", Qdata = 1, NameMon = "Sky Bandit",
                  PosQ = CFrame.new(-4839.53, 716.36, -2619.44), PosM = CFrame.new(-4953.20, 295.74, -2899.22) },
        [175] = { Mon = "Dark Master", Qname = "SkyQuest", Qdata = 2, NameMon = "Dark Master",
                  PosQ = CFrame.new(-4839.53, 716.36, -2619.44), PosM = CFrame.new(-5259.84, 391.39, -2229.03) },
        [190] = { Mon = "Prisoner", Qname = "PrisonerQuest", Qdata = 1, NameMon = "Prisoner",
                  PosQ = CFrame.new(5308.93, 1.65, 475.12), PosM = CFrame.new(5098.97, -0.32, 474.23) },
        [210] = { Mon = "Dangerous Prisoner", Qname = "PrisonerQuest", Qdata = 2, NameMon = "Dangerous Prisoner",
                  PosQ = CFrame.new(5308.93, 1.65, 475.12), PosM = CFrame.new(5654.56, 15.63, 866.29) },
        [250] = { Mon = "Toga Warrior", Qname = "ColosseumQuest", Qdata = 1, NameMon = "Toga Warrior",
                  PosQ = CFrame.new(-1580.04, 6.35, -2986.47), PosM = CFrame.new(-1820.21, 51.68, -2740.66) },
        [275] = { Mon = "Gladiator", Qname = "ColosseumQuest", Qdata = 2, NameMon = "Gladiator",
                  PosQ = CFrame.new(-1580.04, 6.35, -2986.47), PosM = CFrame.new(-1292.83, 56.38, -3339.03) },
        [300] = { Mon = "Military Soldier", Qname = "MagmaQuest", Qdata = 1, NameMon = "Military Soldier",
                  PosQ = CFrame.new(-5313.37, 10.95, 8515.29), PosM = CFrame.new(-5411.16, 11.08, 8454.29) },
        [325] = { Mon = "Military Spy", Qname = "MagmaQuest", Qdata = 2, NameMon = "Military Spy",
                  PosQ = CFrame.new(-5313.37, 10.95, 8515.29), PosM = CFrame.new(-5802.86, 86.26, 8828.85) },
        [375] = { Mon = "Fishman Warrior", Qname = "FishmanQuest", Qdata = 1, NameMon = "Fishman Warrior",
                  PosQ = CFrame.new(61122.65, 18.49, 1569.39), PosM = CFrame.new(60878.30, 18.48, 1543.75) },
        [400] = { Mon = "Fishman Commando", Qname = "FishmanQuest", Qdata = 2, NameMon = "Fishman Commando",
                  PosQ = CFrame.new(61122.65, 18.49, 1569.39), PosM = CFrame.new(61922.63, 18.48, 1493.93) },
        [450] = { Mon = "God's Guard", Qname = "SkyExp1Quest", Qdata = 1, NameMon = "God's Guard",
                  PosQ = CFrame.new(-4721.88, 843.87, -1949.96), PosM = CFrame.new(-4710.04, 845.27, -1927.30) },
        [475] = { Mon = "Shanda", Qname = "SkyExp1Quest", Qdata = 2, NameMon = "Shanda",
                  PosQ = CFrame.new(-7859.09, 5544.19, -381.47), PosM = CFrame.new(-7678.48, 5566.40, -497.21) },
        [525] = { Mon = "Royal Squad", Qname = "SkyExp2Quest", Qdata = 1, NameMon = "Royal Squad",
                  PosQ = CFrame.new(-7906.81, 5634.66, -1411.99), PosM = CFrame.new(-7624.25, 5658.13, -1467.35) },
        [550] = { Mon = "Royal Soldier", Qname = "SkyExp2Quest", Qdata = 2, NameMon = "Royal Soldier",
                  PosQ = CFrame.new(-7906.81, 5634.66, -1411.99), PosM = CFrame.new(-7836.75, 5645.66, -1790.62) },
        [625] = { Mon = "Galley Pirate", Qname = "FountainQuest", Qdata = 1, NameMon = "Galley Pirate",
                  PosQ = CFrame.new(5259.81, 37.35, 4050.02), PosM = CFrame.new(5551.02, 78.90, 3930.41) },
        [650] = { Mon = "Galley Captain", Qname = "FountainQuest", Qdata = 2, NameMon = "Galley Captain",
                  PosQ = CFrame.new(5259.81, 37.35, 4050.02), PosM = CFrame.new(5441.95, 42.50, 4950.09) }
    }
elseif World2 then
    QuestData = {
        [700] = { Mon = "Raider", Qname = "Area1Quest", Qdata = 1, NameMon = "Raider",
                  PosQ = CFrame.new(-429.54, 71.76, 1836.18), PosM = CFrame.new(-728.32, 52.77, 2345.77) },
        [725] = { Mon = "Mercenary", Qname = "Area1Quest", Qdata = 2, NameMon = "Mercenary",
                  PosQ = CFrame.new(-429.54, 71.76, 1836.18), PosM = CFrame.new(-1004.32, 80.15, 1424.61) },
        [775] = { Mon = "Swan Pirate", Qname = "Area2Quest", Qdata = 1, NameMon = "Swan Pirate",
                  PosQ = CFrame.new(638.43, 71.76, 918.28), PosM = CFrame.new(1068.66, 137.61, 1322.10) },
        [800] = { Mon = "Factory Staff", Qname = "Area2Quest", Qdata = 2, NameMon = "Factory Staff",
                  PosQ = CFrame.new(632.69, 73.10, 918.66), PosM = CFrame.new(73.07, 81.86, -27.47) },
        [875] = { Mon = "Marine Lieutenant", Qname = "MarineQuest3", Qdata = 1, NameMon = "Marine Lieutenant",
                  PosQ = CFrame.new(-2440.79, 71.71, -3216.06), PosM = CFrame.new(-2821.37, 75.89, -3070.08) },
        [900] = { Mon = "Marine Captain", Qname = "MarineQuest3", Qdata = 2, NameMon = "Marine Captain",
                  PosQ = CFrame.new(-2440.79, 71.71, -3216.06), PosM = CFrame.new(-1861.23, 80.17, -3254.69) },
        [950] = { Mon = "Zombie", Qname = "ZombieQuest", Qdata = 1, NameMon = "Zombie",
                  PosQ = CFrame.new(-5497.06, 47.59, -795.23), PosM = CFrame.new(-5657.77, 78.96, -928.68) },
        [975] = { Mon = "Vampire", Qname = "ZombieQuest", Qdata = 2, NameMon = "Vampire",
                  PosQ = CFrame.new(-5497.06, 47.59, -795.23), PosM = CFrame.new(-6037.66, 32.18, -1340.65) },
        [1000] = { Mon = "Snow Trooper", Qname = "SnowMountainQuest", Qdata = 1, NameMon = "Snow Trooper",
                   PosQ = CFrame.new(609.85, 400.11, -5372.25), PosM = CFrame.new(549.14, 427.38, -5563.69) },
        [1050] = { Mon = "Winter Warrior", Qname = "SnowMountainQuest", Qdata = 2, NameMon = "Winter Warrior",
                   PosQ = CFrame.new(609.85, 400.11, -5372.25), PosM = CFrame.new(1142.74, 475.63, -5199.41) },
        [1100] = { Mon = "Lab Subordinate", Qname = "IceSideQuest", Qdata = 1, NameMon = "Lab Subordinate",
                   PosQ = CFrame.new(-6064.06, 15.24, -4902.97), PosM = CFrame.new(-5707.47, 15.95, -4513.39) },
        [1125] = { Mon = "Horned Warrior", Qname = "IceSideQuest", Qdata = 2, NameMon = "Horned Warrior",
                   PosQ = CFrame.new(-6064.06, 15.24, -4902.97), PosM = CFrame.new(-6341.36, 15.95, -5723.16) },
        [1175] = { Mon = "Magma Ninja", Qname = "FireSideQuest", Qdata = 1, NameMon = "Magma Ninja",
                   PosQ = CFrame.new(-5428.03, 15.06, -5299.43), PosM = CFrame.new(-5449.67, 76.65, -5808.20) },
        [1200] = { Mon = "Lava Pirate", Qname = "FireSideQuest", Qdata = 2, NameMon = "Lava Pirate",
                   PosQ = CFrame.new(-5428.03, 15.06, -5299.43), PosM = CFrame.new(-5213.33, 49.73, -4701.45) },
        [1250] = { Mon = "Ship Deckhand", Qname = "ShipQuest1", Qdata = 1, NameMon = "Ship Deckhand",
                   PosQ = CFrame.new(1037.80, 125.09, 32911.60), PosM = CFrame.new(1212.01, 150.79, 33059.24) },
        [1275] = { Mon = "Ship Engineer", Qname = "ShipQuest1", Qdata = 2, NameMon = "Ship Engineer",
                   PosQ = CFrame.new(1037.80, 125.09, 32911.60), PosM = CFrame.new(919.47, 43.54, 32779.96) },
        [1300] = { Mon = "Ship Steward", Qname = "ShipQuest2", Qdata = 1, NameMon = "Ship Steward",
                   PosQ = CFrame.new(968.80, 125.09, 33244.12), PosM = CFrame.new(919.43, 129.55, 33436.03) },
        [1325] = { Mon = "Ship Officer", Qname = "ShipQuest2", Qdata = 2, NameMon = "Ship Officer",
                   PosQ = CFrame.new(968.80, 125.09, 33244.12), PosM = CFrame.new(1036.01, 181.43, 33315.72) },
        [1350] = { Mon = "Arctic Warrior", Qname = "FrostQuest", Qdata = 1, NameMon = "Arctic Warrior",
                   PosQ = CFrame.new(5667.65, 26.79, -6486.08), PosM = CFrame.new(5966.24, 62.97, -6179.38) },
        [1375] = { Mon = "Snow Lurker", Qname = "FrostQuest", Qdata = 2, NameMon = "Snow Lurker",
                   PosQ = CFrame.new(5667.65, 26.79, -6486.08), PosM = CFrame.new(5407.07, 69.19, -6880.88) },
        [1425] = { Mon = "Sea Soldier", Qname = "ForgottenQuest", Qdata = 1, NameMon = "Sea Soldier",
                   PosQ = CFrame.new(-3054.44, 235.54, -10142.81), PosM = CFrame.new(-3028.22, 64.67, -9775.42) },
        [1450] = { Mon = "Water Fighter", Qname = "ForgottenQuest", Qdata = 2, NameMon = "Water Fighter",
                   PosQ = CFrame.new(-3054.44, 235.54, -10142.81), PosM = CFrame.new(-3352.90, 285.01, -10534.84) }
    }
elseif World3 then
    QuestData = {
        [1500] = { Mon = "Pirate Millionaire", Qname = "PiratePortQuest", Qdata = 1, NameMon = "Pirate Millionaire",
                   PosQ = CFrame.new(-290.07, 42.90, 5581.59), PosM = CFrame.new(-246.00, 47.31, 5584.10) },
        [1525] = { Mon = "Pistol Billionaire", Qname = "PiratePortQuest", Qdata = 2, NameMon = "Pistol Billionaire",
                   PosQ = CFrame.new(-290.07, 42.90, 5581.59), PosM = CFrame.new(-187.33, 86.24, 6013.51) },
        [1575] = { Mon = "Dragon Crew Warrior", Qname = "DragonCrewQuest", Qdata = 1, NameMon = "Dragon Crew Warrior",
                   PosQ = CFrame.new(6737.06, 127.41, -712.30), PosM = CFrame.new(6709.76, 52.34, -1139.02) },
        [1600] = { Mon = "Dragon Crew Archer", Qname = "DragonCrewQuest", Qdata = 2, NameMon = "Dragon Crew Archer",
                   PosQ = CFrame.new(6737.06, 127.41, -712.30), PosM = CFrame.new(6668.76, 481.37, 329.12) },
        [1625] = { Mon = "Hydra Enforcer", Qname = "VenomCrewQuest", Qdata = 1, NameMon = "Hydra Enforcer",
                   PosQ = CFrame.new(5206.40, 1004.10, 748.35), PosM = CFrame.new(4547.11, 1003.10, 334.19) },
        [1650] = { Mon = "Venomous Assailant", Qname = "VenomCrewQuest", Qdata = 2, NameMon = "Venomous Assailant",
                   PosQ = CFrame.new(5206.40, 1004.10, 748.35), PosM = CFrame.new(4674.92, 1134.82, 996.30) },
        [1700] = { Mon = "Marine Commodore", Qname = "MarineTreeIsland", Qdata = 1, NameMon = "Marine Commodore",
                   PosQ = CFrame.new(2180.54, 27.81, -6741.54), PosM = CFrame.new(2286.00, 73.13, -7159.80) },
        [1725] = { Mon = "Marine Rear Admiral", Qname = "MarineTreeIsland", Qdata = 2, NameMon = "Marine Rear Admiral",
                   PosQ = CFrame.new(2179.98, 28.73, -6740.05), PosM = CFrame.new(3656.77, 160.52, -7001.59) },
        [1775] = { Mon = "Fishman Raider", Qname = "DeepForestIsland3", Qdata = 1, NameMon = "Fishman Raider",
                   PosQ = CFrame.new(-10581.65, 330.87, -8761.18), PosM = CFrame.new(-10407.52, 331.76, -8368.51) },
        [1800] = { Mon = "Fishman Captain", Qname = "DeepForestIsland3", Qdata = 2, NameMon = "Fishman Captain",
                   PosQ = CFrame.new(-10581.65, 330.87, -8761.18), PosM = CFrame.new(-10994.70, 352.38, -9002.11) },
        [1825] = { Mon = "Forest Pirate", Qname = "DeepForestIsland", Qdata = 1, NameMon = "Forest Pirate",
                   PosQ = CFrame.new(-13234.04, 331.48, -7625.40), PosM = CFrame.new(-13274.47, 332.37, -7769.58) },
        [1850] = { Mon = "Mythological Pirate", Qname = "DeepForestIsland", Qdata = 2, NameMon = "Mythological Pirate",
                   PosQ = CFrame.new(-13234.04, 331.48, -7625.40), PosM = CFrame.new(-13680.60, 501.08, -6991.18) },
        [1900] = { Mon = "Jungle Pirate", Qname = "DeepForestIsland2", Qdata = 1, NameMon = "Jungle Pirate",
                   PosQ = CFrame.new(-12680.38, 389.97, -9902.01), PosM = CFrame.new(-12256.16, 331.73, -10485.83) },
        [1925] = { Mon = "Musketeer Pirate", Qname = "DeepForestIsland2", Qdata = 2, NameMon = "Musketeer Pirate",
                   PosQ = CFrame.new(-12680.38, 389.97, -9902.01), PosM = CFrame.new(-13457.90, 391.54, -9859.17) },
        [1975] = { Mon = "Reborn Skeleton", Qname = "HauntedQuest1", Qdata = 1, NameMon = "Reborn Skeleton",
                   PosQ = CFrame.new(-9479.21, 141.21, 5566.09), PosM = CFrame.new(-8763.72, 165.72, 6159.86) },
        [2000] = { Mon = "Living Zombie", Qname = "HauntedQuest1", Qdata = 2, NameMon = "Living Zombie",
                   PosQ = CFrame.new(-9479.21, 141.21, 5566.09), PosM = CFrame.new(-10144.13, 138.62, 5838.08) },
        [2025] = { Mon = "Demonic Soul", Qname = "HauntedQuest2", Qdata = 1, NameMon = "Demonic Soul",
                   PosQ = CFrame.new(-9516.99, 172.01, 6078.46), PosM = CFrame.new(-9505.87, 172.10, 6158.99) },
        [2050] = { Mon = "Posessed Mummy", Qname = "HauntedQuest2", Qdata = 2, NameMon = "Posessed Mummy",
                   PosQ = CFrame.new(-9516.99, 172.01, 6078.46), PosM = CFrame.new(-9582.02, 6.25, 6205.47) },
        [2075] = { Mon = "Peanut Scout", Qname = "NutsIslandQuest", Qdata = 1, NameMon = "Peanut Scout",
                   PosQ = CFrame.new(-2104.39, 38.10, -10194.21), PosM = CFrame.new(-2143.24, 47.72, -10029.99) },
        [2100] = { Mon = "Peanut President", Qname = "NutsIslandQuest", Qdata = 2, NameMon = "Peanut President",
                   PosQ = CFrame.new(-2104.39, 38.10, -10194.21), PosM = CFrame.new(-1859.35, 38.10, -10422.42) },
        [2125] = { Mon = "Ice Cream Chef", Qname = "IceCreamIslandQuest", Qdata = 1, NameMon = "Ice Cream Chef",
                   PosQ = CFrame.new(-820.64, 65.81, -10965.79), PosM = CFrame.new(-872.24, 65.81, -10919.95) },
        [2150] = { Mon = "Ice Cream Commander", Qname = "IceCreamIslandQuest", Qdata = 2, NameMon = "Ice Cream Commander",
                   PosQ = CFrame.new(-820.64, 65.81, -10965.79), PosM = CFrame.new(-558.06, 112.04, -11290.77) },
        [2200] = { Mon = "Cookie Crafter", Qname = "CakeQuest1", Qdata = 1, NameMon = "Cookie Crafter",
                   PosQ = CFrame.new(-2021.32, 37.79, -12028.72), PosM = CFrame.new(-2374.13, 37.79, -12125.30) },
        [2225] = { Mon = "Cake Guard", Qname = "CakeQuest1", Qdata = 2, NameMon = "Cake Guard",
                   PosQ = CFrame.new(-2021.32, 37.79, -12028.72), PosM = CFrame.new(-1598.30, 43.77, -12244.58) },
        [2250] = { Mon = "Baking Staff", Qname = "CakeQuest2", Qdata = 1, NameMon = "Baking Staff",
                   PosQ = CFrame.new(-1927.91, 37.79, -12842.53), PosM = CFrame.new(-1887.80, 77.61, -12998.35) },
        [2275] = { Mon = "Head Baker", Qname = "CakeQuest2", Qdata = 2, NameMon = "Head Baker",
                   PosQ = CFrame.new(-1927.91, 37.79, -12842.53), PosM = CFrame.new(-2216.18, 82.88, -12869.29) },
        [2300] = { Mon = "Cocoa Warrior", Qname = "ChocQuest1", Qdata = 1, NameMon = "Cocoa Warrior",
                   PosQ = CFrame.new(233.22, 29.87, -12201.23), PosM = CFrame.new(-21.55, 80.57, -12352.38) },
        [2325] = { Mon = "Chocolate Bar Battler", Qname = "ChocQuest1", Qdata = 2, NameMon = "Chocolate Bar Battler",
                   PosQ = CFrame.new(233.22, 29.87, -12201.23), PosM = CFrame.new(582.59, 77.18, -12463.16) },
        [2350] = { Mon = "Sweet Thief", Qname = "ChocQuest2", Qdata = 1, NameMon = "Sweet Thief",
                   PosQ = CFrame.new(150.50, 30.69, -12774.50), PosM = CFrame.new(165.18, 76.05, -12600.83) },
        [2375] = { Mon = "Candy Rebel", Qname = "ChocQuest2", Qdata = 2, NameMon = "Candy Rebel",
                   PosQ = CFrame.new(150.50, 30.69, -12774.50), PosM = CFrame.new(134.86, 77.24, -12876.54) },
        [2400] = { Mon = "Candy Pirate", Qname = "CandyQuest1", Qdata = 1, NameMon = "Candy Pirate",
                   PosQ = CFrame.new(-1150.04, 20.37, -14446.33), PosM = CFrame.new(-1310.50, 26.01, -14562.40) },
        [2450] = { Mon = "Isle Outlaw", Qname = "TikiQuest1", Qdata = 1, NameMon = "Isle Outlaw",
                   PosQ = CFrame.new(-16548.81, 55.60, -172.81), PosM = CFrame.new(-16479.90, 226.61, -300.31) },
        [2475] = { Mon = "Island Boy", Qname = "TikiQuest1", Qdata = 2, NameMon = "Island Boy",
                   PosQ = CFrame.new(-16548.81, 55.60, -172.81), PosM = CFrame.new(-16849.39, 192.86, -150.78) },
        [2500] = { Mon = "Sun-kissed Warrior", Qname = "TikiQuest2", Qdata = 1, NameMon = "kissed Warrior",
                   PosQ = CFrame.new(-16538, 55, 1049), PosM = CFrame.new(-16347, 64, 984) },
        [2525] = { Mon = "Isle Champion", Qname = "TikiQuest2", Qdata = 2, NameMon = "Isle Champion",
                   PosQ = CFrame.new(-16541.02, 57.30, 1051.46), PosM = CFrame.new(-16602.10, 130.38, 1087.24) },
        [2551] = { Mon = "Serpent Hunter", Qname = "TikiQuest3", Qdata = 1, NameMon = "Serpent Hunter",
                   PosQ = CFrame.new(-16668.03, 105.32, 1568.60), PosM = CFrame.new(-16645.64, 163.09, 1352.87) },
        [2575] = { Mon = "Skull Slayer", Qname = "TikiQuest3", Qdata = 2, NameMon = "Skull Slayer",
                   PosQ = CFrame.new(-16668.03, 105.32, 1568.60), PosM = CFrame.new(-16709.49, 419.68, 1751.09) }
    }
end

local function GetQuestData()
    local level = player.Data.Level.Value
    local bestMatch = nil
    local bestLevel = 0
    
    for lvl, data in pairs(QuestData) do
        if level >= lvl and lvl > bestLevel then
            bestMatch = data
            bestLevel = lvl
        end
    end
    
    return bestMatch
end

local function GetNearestMob(targetName)
    local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end
    local closest, shortest = nil, math.huge
    for _, mob in pairs(workspace.Enemies:GetChildren()) do
        if mob.Name == targetName and mob:FindFirstChild("Humanoid") and mob.Humanoid.Health > 0 and mob:FindFirstChild("HumanoidRootPart") then
            local dist = (mob.HumanoidRootPart.Position - hrp.Position).Magnitude
            if dist < shortest then
                shortest = dist
                closest = mob
            end
        end
    end
    return closest
end

-- Level Farm loop
task.spawn(function()
    while task.wait() do
        if _G.Level and _G.StartFarm then
            pcall(function()
                local questData = GetQuestData()
                if not questData then return end
                
                local questUI = player.PlayerGui.Main.Quest
                local questVisible = questUI.Visible
                local questTitle = questVisible and questUI.Container.QuestTitle.Title.Text or ""
                
                if not string.find(questTitle, questData.NameMon) then
                    replicated.Remotes.CommF_:InvokeServer("AbandonQuest")
                end
                
                if not questVisible and _G.AcceptQuest then
                    _tp(questData.PosQ)
                    if (player.Character.HumanoidRootPart.Position - questData.PosQ.Position).Magnitude <= 10 then
                        task.wait(1)
                        replicated.Remotes.CommF_:InvokeServer("StartQuest", questData.Qname, questData.Qdata)
                    end
                    return
                end
                
                local mob = GetNearestMob(questData.Mon)
                if mob then
                    if not mob:GetAttribute("Locked") then
                        mob:SetAttribute("Locked", mob.HumanoidRootPart.CFrame)
                    end
                    _G.PosMon = mob:GetAttribute("Locked").Position
                    _tp(mob.HumanoidRootPart.CFrame * CFrame.new(0, _G.MobHeight, 0))
                    EquipWeapon(_G.SelectWeapon)
                    
                    repeat
                        task.wait()
                        if not mob.Parent or mob.Humanoid.Health <= 0 then break end
                        if not mob:GetAttribute("Locked") then
                            mob:SetAttribute("Locked", mob.HumanoidRootPart.CFrame)
                        end
                        _G.PosMon = mob:GetAttribute("Locked").Position
                    until not _G.Level or not _G.StartFarm or not mob.Parent or mob.Humanoid.Health <= 0
                else
                    _tp(questData.PosM)
                end
            end)
        end
    end
end)

-- ========================================
-- AUTO FARM BONE (World 3)
-- ========================================

_G.AutoFarm_Bone = false
local BONE_MOBS = {"Reborn Skeleton", "Living Zombie", "Demonic Soul", "Posessed Mummy"}

task.spawn(function()
    while task.wait() do
        if _G.AutoFarm_Bone and _G.StartFarm and World3 then
            pcall(function()
                local questUI = player.PlayerGui.Main.Quest
                
                if _G.AcceptQuest and not questUI.Visible then
                    local npcPos = CFrame.new(-9516.99, 172.01, 6078.46)
                    _tp(npcPos)
                    if (player.Character.HumanoidRootPart.Position - npcPos.Position).Magnitude <= 5 then
                        task.wait(0.5)
                        local quests = {
                            {"StartQuest","HauntedQuest1",1},
                            {"StartQuest","HauntedQuest1",2},
                            {"StartQuest","HauntedQuest2",1},
                            {"StartQuest","HauntedQuest2",2}
                        }
                        replicated.Remotes.CommF_:InvokeServer(unpack(quests[math.random(1,#quests)]))
                    end
                    return
                end
                
                local mob = nil
                local shortest = math.huge
                for _, mobName in pairs(BONE_MOBS) do
                    for _, m in pairs(workspace.Enemies:GetChildren()) do
                        if m.Name == mobName and m:FindFirstChild("Humanoid") and m.Humanoid.Health > 0 and m:FindFirstChild("HumanoidRootPart") then
                            local dist = (m.HumanoidRootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude
                            if dist < shortest then
                                shortest = dist
                                mob = m
                            end
                        end
                    end
                end
                
                if mob then
                    if not mob:GetAttribute("Locked") then
                        mob:SetAttribute("Locked", mob.HumanoidRootPart.CFrame)
                    end
                    _G.PosMon = mob:GetAttribute("Locked").Position
                    _tp(mob.HumanoidRootPart.CFrame * CFrame.new(0, _G.MobHeight, 0))
                    EquipWeapon(_G.SelectWeapon)
                    
                    repeat
                        task.wait()
                        if not mob.Parent or mob.Humanoid.Health <= 0 then break end
                        if not mob:GetAttribute("Locked") then
                            mob:SetAttribute("Locked", mob.HumanoidRootPart.CFrame)
                        end
                        _G.PosMon = mob:GetAttribute("Locked").Position
                    until not _G.AutoFarm_Bone or not _G.StartFarm or not mob.Parent or mob.Humanoid.Health <= 0
                else
                    _tp(CFrame.new(-9495.68, 453.58, 5977.34))
                end
            end)
        end
    end
end)

-- ========================================
-- AUTO FARM CAKE PRINCE (World 3)
-- ========================================

_G.AutoFarm_Cake = false
local CAKE_MOBS = {"Cookie Crafter", "Cake Guard", "Baking Staff", "Head Baker"}

task.spawn(function()
    while task.wait() do
        if _G.AutoFarm_Cake and _G.StartFarm and World3 then
            pcall(function()
                local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                if not hrp then return end
                
                local enemies = workspace.Enemies
                local mirror = workspace.Map:FindFirstChild("CakeLoaf") and workspace.Map.CakeLoaf:FindFirstChild("BigMirror")
                local other = mirror and mirror:FindFirstChild("Other")
                local portalOpen = other and other.Transparency == 0
                local boss = enemies:FindFirstChild("Cake Prince") or enemies:FindFirstChild("Dough King")
                
                local cakePos = CFrame.new(-2091.91, 70.00, -12142.83)
                local portalEntrance = CFrame.new(-2151.82, 149.32, -12404.91)
                
                if not boss and not portalOpen and (hrp.Position - cakePos.Position).Magnitude > 3000 then
                    _tp(cakePos)
                    return
                end
                
                if boss or portalOpen then
                    if boss and boss:FindFirstChild("Humanoid") and boss.Humanoid.Health > 0 and boss:FindFirstChild("HumanoidRootPart") then
                        if not boss:GetAttribute("Locked") then
                            boss:SetAttribute("Locked", boss.HumanoidRootPart.CFrame)
                        end
                        _G.PosMon = boss:GetAttribute("Locked").Position
                        _tp(boss.HumanoidRootPart.CFrame * CFrame.new(0, _G.MobHeight, 0))
                        EquipWeapon(_G.SelectWeapon)
                        
                        repeat
                            task.wait()
                            if not boss.Parent or boss.Humanoid.Health <= 0 then break end
                            if not boss:GetAttribute("Locked") then
                                boss:SetAttribute("Locked", boss.HumanoidRootPart.CFrame)
                            end
                            _G.PosMon = boss:GetAttribute("Locked").Position
                        until not _G.AutoFarm_Cake or not _G.StartFarm or not boss.Parent or boss.Humanoid.Health <= 0
                        return
                    end
                    _tp(portalEntrance)
                    return
                end
                
                if _G.AcceptQuest and not player.PlayerGui.Main.Quest.Visible then
                    local questPos = CFrame.new(-1927.92, 37.80, -12842.54)
                    _tp(questPos)
                    if (hrp.Position - questPos.Position).Magnitude <= 10 then
                        local q = {
                            {"StartQuest", "CakeQuest2", 2},
                            {"StartQuest", "CakeQuest2", 1},
                            {"StartQuest", "CakeQuest1", 1},
                            {"StartQuest", "CakeQuest1", 2}
                        }
                        replicated.Remotes.CommF_:InvokeServer(unpack(q[math.random(1, 4)]))
                    end
                    return
                end
                
                local mob = nil
                local shortest = math.huge
                for _, mobName in pairs(CAKE_MOBS) do
                    for _, m in pairs(enemies:GetChildren()) do
                        if m.Name == mobName and m:FindFirstChild("Humanoid") and m.Humanoid.Health > 0 and m:FindFirstChild("HumanoidRootPart") then
                            local dist = (m.HumanoidRootPart.Position - hrp.Position).Magnitude
                            if dist < shortest then
                                shortest = dist
                                mob = m
                            end
                        end
                    end
                end
                
                if mob then
                    if not mob:GetAttribute("Locked") then
                        mob:SetAttribute("Locked", mob.HumanoidRootPart.CFrame)
                    end
                    _G.PosMon = mob:GetAttribute("Locked").Position
                    _tp(mob.HumanoidRootPart.CFrame * CFrame.new(0, _G.MobHeight, 0))
                    EquipWeapon(_G.SelectWeapon)
                    
                    repeat
                        task.wait()
                        if not mob.Parent or mob.Humanoid.Health <= 0 then break end
                        if not mob:GetAttribute("Locked") then
                            mob:SetAttribute("Locked", mob.HumanoidRootPart.CFrame)
                        end
                        _G.PosMon = mob:GetAttribute("Locked").Position
                    until not _G.AutoFarm_Cake or not _G.StartFarm or not mob.Parent or mob.Humanoid.Health <= 0
                else
                    _tp(CFrame.new(-1927.92, 37.80, -12842.54))
                end
            end)
        end
    end
end)

-- ========================================
-- AUTO FARM TYRANT OF THE SKIES (World 3)
-- ========================================

_G.AutoTyrant = false

local function GetTyrantTarget()
    local level = player.Data.Level.Value
    
    if level >= 2575 then
        return {
            Name = "Skull Slayer",
            QuestArgs = {"StartQuest", "TikiQuest3", 2},
            QuestPos = CFrame.new(-16665.08, 105.27, 1577.61),
            FarmPos = CFrame.new(-16709.49, 419.68, 1751.09)
        }
    elseif level > 2550 then
        return {
            Name = "Serpent Hunter",
            QuestArgs = {"StartQuest", "TikiQuest3", 1},
            QuestPos = CFrame.new(-16665.08, 105.27, 1577.61),
            FarmPos = CFrame.new(-16645.64, 163.09, 1352.87)
        }
    elseif level >= 2525 then
        return {
            Name = "Isle Champion",
            QuestArgs = {"StartQuest", "TikiQuest2", 2},
            QuestPos = CFrame.new(-16546.74, 55.72, -172.86),
            FarmPos = CFrame.new(-16602.10, 130.38, 1087.24)
        }
    elseif level >= 2500 then
        return {
            Name = "Sun-kissed Warrior",
            QuestArgs = {"StartQuest", "TikiQuest2", 1},
            QuestPos = CFrame.new(-16546.74, 55.72, -172.86),
            FarmPos = CFrame.new(-16347, 64, 984)
        }
    elseif level >= 2475 then
        return {
            Name = "Island Boy",
            QuestArgs = {"StartQuest", "TikiQuest1", 2},
            QuestPos = CFrame.new(-16546.74, 55.72, -172.86),
            FarmPos = CFrame.new(-16670, 43, -270)
        }
    else
        return {
            Name = "Isle Outlaw",
            QuestArgs = {"StartQuest", "TikiQuest1", 1},
            QuestPos = CFrame.new(-16546.74, 55.72, -172.86),
            FarmPos = CFrame.new(-16350, 45, -180)
        }
    end
end

local function GetEyesCount()
    local model = workspace.Map:FindFirstChild("TikiOutpost") and workspace.Map.TikiOutpost:FindFirstChild("IslandModel")
    if not model then return 0 end
    local count = 0
    local eye1 = model:FindFirstChild("Eye1")
    local eye2 = model:FindFirstChild("Eye2")
    local chunks = model:FindFirstChild("IslandChunks")
    local eye3 = chunks and chunks:FindFirstChild("E") and chunks.E:FindFirstChild("Eye3")
    local eye4 = chunks and chunks:FindFirstChild("E") and chunks.E:FindFirstChild("Eye4")
    if eye1 and eye1.Transparency == 0 then count = count + 1 end
    if eye2 and eye2.Transparency == 0 then count = count + 1 end
    if eye3 and eye3.Transparency == 0 then count = count + 1 end
    if eye4 and eye4.Transparency == 0 then count = count + 1 end
    return count
end

local VaseIndex = 1
local vasePositions = {
    CFrame.new(-16335.1, 158.1, 1465.6), CFrame.new(-16288.6, 158.1, 1470.3),
    CFrame.new(-16258.0, 156.7, 1461.4), CFrame.new(-16212.4, 158.1, 1466.3),
    CFrame.new(-16335.0, 159.3, 1324.8), CFrame.new(-16286.0, 155.9, 1323.8),
    CFrame.new(-16250.3, 159.3, 1316.3)
}

task.spawn(function()
    while task.wait() do
        if _G.AutoTyrant and _G.StartFarm and World3 then
            pcall(function()
                local boss = workspace.Enemies:FindFirstChild("Tyrant of the Skies")
                local eyes = GetEyesCount()
                
                if boss and boss.Humanoid.Health > 0 then
                    if not boss:GetAttribute("Locked") then
                        boss:SetAttribute("Locked", boss.HumanoidRootPart.CFrame)
                    end
                    _G.PosMon = boss:GetAttribute("Locked").Position
                    _tp(boss.HumanoidRootPart.CFrame * CFrame.new(0, _G.MobHeight, 0))
                    EquipWeapon(_G.SelectWeapon)
                    
                    repeat
                        task.wait()
                        if not boss.Parent or boss.Humanoid.Health <= 0 then break end
                        if not boss:GetAttribute("Locked") then
                            boss:SetAttribute("Locked", boss.HumanoidRootPart.CFrame)
                        end
                        _G.PosMon = boss:GetAttribute("Locked").Position
                    until not _G.AutoTyrant or not _G.StartFarm or not boss.Parent or boss.Humanoid.Health <= 0
                    
                elseif eyes == 4 then
                    local pos = vasePositions[VaseIndex]
                    if pos then
                        _tp(pos)
                        if (player.Character.HumanoidRootPart.Position - pos.Position).Magnitude < 15 then
                            player.Character.HumanoidRootPart.Anchored = true
                            task.wait(0.1)
                            player.Character.HumanoidRootPart.Anchored = false
                            VaseIndex = VaseIndex + 1
                            if VaseIndex > #vasePositions then VaseIndex = 1 end
                        end
                    end
                    
                else
                    local target = GetTyrantTarget()
                    local questUI = player.PlayerGui.Main.Quest
                    
                    if _G.AcceptQuest and not questUI.Visible then
                        _tp(target.QuestPos)
                        if (player.Character.HumanoidRootPart.Position - target.QuestPos.Position).Magnitude <= 5 then
                            task.wait(0.1)
                            replicated.Remotes.CommF_:InvokeServer(unpack(target.QuestArgs))
                        end
                    else
                        local mob = GetNearestMob(target.Name)
                        if mob then
                            if not mob:GetAttribute("Locked") then
                                mob:SetAttribute("Locked", mob.HumanoidRootPart.CFrame)
                            end
                            _G.PosMon = mob:GetAttribute("Locked").Position
                            _tp(mob.HumanoidRootPart.CFrame * CFrame.new(0, _G.MobHeight, 0))
                            EquipWeapon(_G.SelectWeapon)
                            
                            repeat
                                task.wait()
                                if not mob.Parent or mob.Humanoid.Health <= 0 then break end
                                if not mob:GetAttribute("Locked") then
                                    mob:SetAttribute("Locked", mob.HumanoidRootPart.CFrame)
                                end
                                _G.PosMon = mob:GetAttribute("Locked").Position
                            until not _G.AutoTyrant or not _G.StartFarm or not mob.Parent or mob.Humanoid.Health <= 0
                        else
                            _tp(target.FarmPos)
                        end
                    end
                end
            end)
        end
    end
end)

-- ========================================
-- AUTO FARM NEAREST MOBS
-- ========================================

_G.AutoFarmNear = false
_G.MaxFarmDistance = 325

task.spawn(function()
    while task.wait() do
        pcall(function()
            if not _G.AutoFarmNear then return end
            
            local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
            if not hrp then return end
            
            local closestEnemy = nil
            local shortestDist = math.huge
            
            for _, e in pairs(workspace.Enemies:GetChildren()) do
                if e:FindFirstChild("Humanoid") and e:FindFirstChild("HumanoidRootPart") and e.Humanoid.Health > 0 then
                    local dist = (hrp.Position - e.HumanoidRootPart.Position).Magnitude
                    if dist < shortestDist and dist <= _G.MaxFarmDistance then
                        shortestDist = dist
                        closestEnemy = e
                    end
                end
            end
            
            if closestEnemy then
                if not closestEnemy:GetAttribute("Locked") then
                    closestEnemy:SetAttribute("Locked", closestEnemy.HumanoidRootPart.CFrame)
                end
                _G.PosMon = closestEnemy:GetAttribute("Locked").Position
                _tp(closestEnemy.HumanoidRootPart.CFrame * CFrame.new(0, _G.MobHeight, 0))
                EquipWeapon(_G.SelectWeapon)
                
                repeat
                    task.wait()
                    if not closestEnemy.Parent or closestEnemy.Humanoid.Health <= 0 then break end
                    if not closestEnemy:GetAttribute("Locked") then
                        closestEnemy:SetAttribute("Locked", closestEnemy.HumanoidRootPart.CFrame)
                    end
                    _G.PosMon = closestEnemy:GetAttribute("Locked").Position
                until not _G.AutoFarmNear or not closestEnemy.Parent or closestEnemy.Humanoid.Health <= 0
            end
        end)
    end
end)

-- ========================================
-- AUTO FARM MATERIAL
-- ========================================

(getgenv()).AutoMaterial = false
(getgenv()).SelectMaterial = "Leather + Scrap Metal"

local MaterialData = {}

if World1 then
    MaterialData = {
        ["Angel Wings"] = {
            MMon = {"Shanda", "Royal Squad", "Royal Soldier", "Wysper", "Thunder God"},
            MPos = CFrame.new(-4698, 845, -1912),
            Entrance = Vector3.new(-4607.82275, 872.54248, -1667.55688)
        },
        ["Leather + Scrap Metal"] = {
            MMon = {"Brute", "Pirate"},
            MPos = CFrame.new(-1145, 15, 4350)
        },
        ["Magma Ore"] = {
            MMon = {"Military Soldier", "Military Spy", "Magma Admiral"},
            MPos = CFrame.new(-5815, 84, 8820)
        },
        ["Fish Tail"] = {
            MMon = {"Fishman Warrior", "Fishman Commando", "Fishman Lord"},
            MPos = CFrame.new(61123, 19, 1569),
            Entrance = Vector3.new(61163.8515625, 5.342342376709, 1819.7841796875)
        }
    }
elseif World2 then
    MaterialData = {
        ["Leather + Scrap Metal"] = {
            MMon = {"Marine Captain"},
            MPos = CFrame.new(-2010.5059814453, 73.001159667969, -3326.6208496094)
        },
        ["Magma Ore"] = {
            MMon = {"Magma Ninja", "Lava Pirate"},
            MPos = CFrame.new(-5428, 78, -5959)
        },
        ["Ectoplasm"] = {
            MMon = {"Ship Deckhand", "Ship Engineer", "Ship Steward", "Ship Officer"},
            MPos = CFrame.new(911.35827636719, 125.95812988281, 33159.5390625),
            Entrance = Vector3.new(923.21252441406, 126.9760055542, 32852.83203125)
        },
        ["Mystic Droplet"] = {
            MMon = {"Water Fighter"},
            MPos = CFrame.new(-3385, 239, -10542)
        },
        ["Radioactive Material"] = {
            MMon = {"Factory Staff"},
            MPos = CFrame.new(295, 73, -56)
        },
        ["Vampire Fang"] = {
            MMon = {"Vampire"},
            MPos = CFrame.new(-6033, 7, -1317)
        }
    }
elseif World3 then
    MaterialData = {
        ["Scrap Metal"] = {
            MMon = {"Jungle Pirate", "Forest Pirate"},
            MPos = CFrame.new(-11975.78515625, 331.77340698242, -10620.030273438)
        },
        ["Fish Tail"] = {
            MMon = {"Fishman Raider", "Fishman Captain"},
            MPos = CFrame.new(-10993, 332, -8940)
        },
        ["Conjured Cocoa"] = {
            MMon = {"Chocolate Bar Battler", "Cocoa Warrior"},
            MPos = CFrame.new(620.63446044922, 78.936447143555, -12581.369140625)
        },
        ["Dragon Scale"] = {
            MMon = {"Dragon Crew Archer", "Dragon Crew Warrior"},
            MPos = CFrame.new(6594, 383, 139)
        },
        ["Gunpowder"] = {
            MMon = {"Pistol Billionaire"},
            MPos = CFrame.new(-84.855690002441, 85.620613098145, 6132.0087890625)
        },
        ["Mini Tusk"] = {
            MMon = {"Mythological Pirate"},
            MPos = CFrame.new(-13545, 470, -6917)
        },
        ["Demonic Wisp"] = {
            MMon = {"Demonic Soul"},
            MPos = CFrame.new(-9495.6806640625, 453.58624267578, 5977.3486328125)
        }
    }
end

task.spawn(function()
    while task.wait() do
        if (getgenv()).AutoMaterial and (getgenv()).SelectMaterial then
            pcall(function()
                local data = MaterialData[(getgenv()).SelectMaterial]
                if not data then return end
                
                if data.Entrance and (player.Character.HumanoidRootPart.Position - data.Entrance).Magnitude > 1000 then
                    replicated.Remotes.CommF_:InvokeServer("requestEntrance", data.Entrance)
                end
                
                _tp(data.MPos)
                
                for _, mobName in ipairs(data.MMon) do
                    for _, mob in pairs(workspace.Enemies:GetChildren()) do
                        if mob.Name == mobName and mob:FindFirstChild("Humanoid") and mob.Humanoid.Health > 0 and mob:FindFirstChild("HumanoidRootPart") then
                            if not mob:GetAttribute("Locked") then
                                mob:SetAttribute("Locked", mob.HumanoidRootPart.CFrame)
                            end
                            _G.PosMon = mob:GetAttribute("Locked").Position
                            _tp(mob.HumanoidRootPart.CFrame * CFrame.new(0, _G.MobHeight, 0))
                            EquipWeapon(_G.SelectWeapon)
                            
                            repeat
                                task.wait()
                                if not mob.Parent or mob.Humanoid.Health <= 0 then break end
                                if not mob:GetAttribute("Locked") then
                                    mob:SetAttribute("Locked", mob.HumanoidRootPart.CFrame)
                                end
                                _G.PosMon = mob:GetAttribute("Locked").Position
                            until not (getgenv()).AutoMaterial or not mob.Parent or mob.Humanoid.Health <= 0
                        end
                    end
                end
            end)
        end
    end
end)

-- ========================================
-- AUTO FARM MASTERY FRUIT
-- ========================================

_G.FarmMastery_Dev = false
_G.FruitSkills = { Z = false, X = false, C = false, V = false, F = false }
_G.SelectedIsland = "Cake"

local CAKE_MOBS_MASTERY = {"Cookie Crafter", "Cake Guard", "Baking Staff", "Head Baker"}
local BONE_MOBS_MASTERY = {"Reborn Skeleton", "Living Zombie", "Demonic Soul", "Posessed Mummy"}

local function UseFruitSkills()
    weaponSc("Blox Fruit")
    if _G.FruitSkills.Z then Useskills("Blox Fruit", "Z") end
    if _G.FruitSkills.X then Useskills("Blox Fruit", "X") end
    if _G.FruitSkills.C then Useskills("Blox Fruit", "C") end
    if _G.FruitSkills.V then Useskills("Blox Fruit", "V") end
    if _G.FruitSkills.F then
        vim1:SendKeyEvent(true, "F", false, game)
        vim1:SendKeyEvent(false, "F", false, game)
    end
end

local function GetNearestMobFromList(mobList)
    local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end
    local closest, shortest = nil, math.huge
    for _, mob in pairs(workspace.Enemies:GetChildren()) do
        if mob:FindFirstChild("Humanoid") and mob.Humanoid.Health > 0 and mob:FindFirstChild("HumanoidRootPart") then
            for _, mobName in pairs(mobList) do
                if mob.Name == mobName then
                    local dist = (mob.HumanoidRootPart.Position - hrp.Position).Magnitude
                    if dist < shortest then
                        shortest = dist
                        closest = mob
                    end
                end
            end
        end
    end
    return closest
end

local function HasAliveMob(mobList)
    for _, mob in pairs(workspace.Enemies:GetChildren()) do
        if mob:FindFirstChild("Humanoid") and mob.Humanoid.Health > 0 then
            for _, mobName in pairs(mobList) do
                if mob.Name == mobName then return true end
            end
        end
    end
    return false
end

task.spawn(function()
    while task.wait(0.1) do
        if _G.FarmMastery_Dev then
            pcall(function()
                local list = (_G.SelectedIsland == "Cake") and CAKE_MOBS_MASTERY or BONE_MOBS_MASTERY
                local mob = GetNearestMobFromList(list)
                
                if mob then
                    if not mob:GetAttribute("Locked") then
                        mob:SetAttribute("Locked", mob.HumanoidRootPart.CFrame)
                    end
                    _G.PosMon = mob:GetAttribute("Locked").Position
                    _tp(mob.HumanoidRootPart.CFrame * CFrame.new(0, _G.MobHeight, 0))
                    EquipWeapon(_G.SelectWeapon)
                    
                    repeat
                        task.wait()
                        if not mob.Parent or mob.Humanoid.Health <= 0 then break end
                        UseFruitSkills()
                        if not mob:GetAttribute("Locked") then
                            mob:SetAttribute("Locked", mob.HumanoidRootPart.CFrame)
                        end
                        _G.PosMon = mob:GetAttribute("Locked").Position
                    until not _G.FarmMastery_Dev or not HasAliveMob(list)
                    
                else
                    if _G.SelectedIsland == "Cake" then
                        _tp(CFrame.new(-1943.6765, 251.5095, -12337.8808))
                    else
                        _tp(CFrame.new(-9495.6806, 453.5862, 5977.3486))
                    end
                end
            end)
        end
    end
end)

-- ========================================
-- AUTO FARM MASTERY GUN
-- ========================================

_G.FarmMastery_G = false
_G.SoulGuitar = false

task.spawn(function()
    while task.wait(0.1) do
        if _G.FarmMastery_G then
            pcall(function()
                local list = (_G.SelectedIsland == "Cake") and CAKE_MOBS_MASTERY or BONE_MOBS_MASTERY
                local mob = GetNearestMobFromList(list)
                
                if mob then
                    if not mob:GetAttribute("Locked") then
                        mob:SetAttribute("Locked", mob.HumanoidRootPart.CFrame)
                    end
                    _G.PosMon = mob:GetAttribute("Locked").Position
                    _tp(mob.HumanoidRootPart.CFrame * CFrame.new(0, _G.MobHeight, 0))
                    EquipWeapon(_G.SelectWeapon)
                    
                    local modules = replicated:FindFirstChild("Modules")
                    local net = modules and modules:FindFirstChild("Net")
                    local shoot = net and net:FindFirstChild("RE/ShootGunEvent")
                    local tool = player.Character and player.Character:FindFirstChildOfClass("Tool")
                    
                    repeat
                        task.wait()
                        if not mob.Parent or mob.Humanoid.Health <= 0 then break end
                        
                        _G.MousePos = mob.HumanoidRootPart.Position
                        
                        if tool and tool.Name == "Skull Guitar" then
                            _G.SoulGuitar = true
                            if tool:FindFirstChild("RemoteEvent") then
                                tool.RemoteEvent:FireServer("TAP", _G.MousePos)
                            end
                        elseif tool and shoot then
                            _G.SoulGuitar = false
                            shoot:FireServer(_G.MousePos, {mob.HumanoidRootPart})
                        end
                        
                        if not mob:GetAttribute("Locked") then
                            mob:SetAttribute("Locked", mob.HumanoidRootPart.CFrame)
                        end
                        _G.PosMon = mob:GetAttribute("Locked").Position
                        
                    until not _G.FarmMastery_G or not HasAliveMob(list)
                    
                    _G.SoulGuitar = false
                    
                else
                    if _G.SelectedIsland == "Cake" then
                        _tp(CFrame.new(-1943.6765, 251.5095, -12337.8808))
                    else
                        _tp(CFrame.new(-9495.6806, 453.5862, 5977.3486))
                    end
                end
            end)
        end
    end
end)

-- ========================================
-- AUTO FARM MASTERY SWORD
-- ========================================

_G.FarmMastery_S = false

task.spawn(function()
    while task.wait(0.1) do
        if _G.FarmMastery_S then
            pcall(function()
                local list = (_G.SelectedIsland == "Cake") and CAKE_MOBS_MASTERY or BONE_MOBS_MASTERY
                local mob = GetNearestMobFromList(list)
                
                local inventory = replicated.Remotes.CommF_:InvokeServer("getInventory")
                for _, item in pairs(inventory) do
                    if type(item) == "table" and item.Type == "Sword" and tonumber(item.Mastery) < 600 then
                        local swordName = item.Name
                        
                        if GetBP(swordName) then
                            if mob then
                                if not mob:GetAttribute("Locked") then
                                    mob:SetAttribute("Locked", mob.HumanoidRootPart.CFrame)
                                end
                                _G.PosMon = mob:GetAttribute("Locked").Position
                                weaponSc("Sword")
                                _tp(mob.HumanoidRootPart.CFrame * CFrame.new(0, _G.MobHeight, 0))
                                
                                repeat
                                    task.wait()
                                    if not mob.Parent or mob.Humanoid.Health <= 0 then break end
                                    if not mob:GetAttribute("Locked") then
                                        mob:SetAttribute("Locked", mob.HumanoidRootPart.CFrame)
                                    end
                                    _G.PosMon = mob:GetAttribute("Locked").Position
                                until not _G.FarmMastery_S or not HasAliveMob(list)
                                
                            else
                                if _G.SelectedIsland == "Cake" then
                                    _tp(CFrame.new(-1943.6765, 251.5095, -12337.8808))
                                else
                                    _tp(CFrame.new(-9495.6806, 453.5862, 5977.3486))
                                end
                            end
                        else
                            replicated.Remotes.CommF_:InvokeServer("LoadItem", swordName)
                        end
                        break
                    end
                end
            end)
        end
    end
end)

-- ========================================
-- SELECT WEAPON SYSTEM
-- ========================================

_G.ChooseWP = "Melee"
_G.SelectWeapon = nil

task.spawn(function()
    while task.wait(0.1) do
        pcall(function()
            for _, tool in pairs(player.Backpack:GetChildren()) do
                if tool.ToolTip == _G.ChooseWP then
                    _G.SelectWeapon = tool.Name
                end
            end
        end)
    end
end)

-- ========================================
-- SIMPLE GUI
-- ========================================

local library = loadstring(game:HttpGet("https://raw.githubusercontent.com/bloodball/-backups-/main/uilibrary.lua"))()
local Window = library:CreateWindow("Bear Hub - Farm Only")
local FarmTab = Window:AddTab("Farming")
local MasteryTab = Window:AddTab("Mastery")
local ConfigTab = Window:AddTab("Config")

-- Farm Tab
FarmTab:AddSection({"Main Farm"})

FarmTab:AddToggle("StartFarm", "Start Farming", false, function(v)
    _G.StartFarm = v
end)

FarmTab:AddToggle("AcceptQuest", "Accept Quests", true, function(v)
    _G.AcceptQuest = v
end)

FarmTab:AddToggle("LevelFarm", "Auto Farm Level", false, function(v)
    _G.Level = v
end)

if World3 then
    FarmTab:AddToggle("BoneFarm", "Auto Farm Bone", false, function(v)
        _G.AutoFarm_Bone = v
    end)
    
    FarmTab:AddToggle("CakeFarm", "Auto Farm Cake Prince", false, function(v)
        _G.AutoFarm_Cake = v
    end)
    
    FarmTab:AddToggle("TyrantFarm", "Auto Farm Tyrant", false, function(v)
        _G.AutoTyrant = v
    end)
end

FarmTab:AddToggle("NearFarm", "Auto Farm Nearest", false, function(v)
    _G.AutoFarmNear = v
end)

FarmTab:AddSection({"Material Farm"})

FarmTab:AddDropdown("SelectMaterial", "Select Material", {
    "Leather + Scrap Metal",
    "Angel Wings",
    "Magma Ore",
    "Fish Tail",
    "Ectoplasm",
    "Mystic Droplet",
    "Radioactive Material",
    "Vampire Fang",
    "Scrap Metal",
    "Demonic Wisp",
    "Conjured Cocoa",
    "Dragon Scale",
    "Gunpowder",
    "Mini Tusk"
}, "Leather + Scrap Metal", function(v)
    (getgenv()).SelectMaterial = v
end)

FarmTab:AddToggle("AutoMaterial", "Auto Farm Material", false, function(v)
    (getgenv()).AutoMaterial = v
end)

-- Mastery Tab
MasteryTab:AddSection({"Mastery Settings"})

MasteryTab:AddDropdown("SelectIsland", "Select Island", {"Cake", "Bone"}, "Cake", function(v)
    _G.SelectedIsland = v
end)

MasteryTab:AddToggle("FarmMasteryDev", "Auto Mastery Fruit", false, function(v)
    _G.FarmMastery_Dev = v
end)

MasteryTab:AddToggle("FarmMasteryG", "Auto Mastery Gun", false, function(v)
    _G.FarmMastery_G = v
end)

MasteryTab:AddToggle("FarmMasteryS", "Auto Mastery Sword", false, function(v)
    _G.FarmMastery_S = v
end)

MasteryTab:AddSection({"Fruit Skills"})
MasteryTab:AddToggle("FruitZ", "Use Z", false, function(v) _G.FruitSkills.Z = v end)
MasteryTab:AddToggle("FruitX", "Use X", false, function(v) _G.FruitSkills.X = v end)
MasteryTab:AddToggle("FruitC", "Use C", false, function(v) _G.FruitSkills.C = v end)
MasteryTab:AddToggle("FruitV", "Use V", false, function(v) _G.FruitSkills.V = v end)
MasteryTab:AddToggle("FruitF", "Use F", false, function(v) _G.FruitSkills.F = v end)

-- Config Tab
ConfigTab:AddSection({"Combat Settings"})

ConfigTab:AddDropdown("ChooseWP", "Select Weapon", {"Melee","Sword","Blox Fruit","Gun"}, "Melee", function(v)
    _G.ChooseWP = v
end)

ConfigTab:AddToggle("AutoHaki", "Auto Buso Haki", true, function(v)
    _G.AutoHaki = v
end)

ConfigTab:AddToggle("AutoKen", "Auto Observation", true, function(v)
    _G.AutoKen = v
end)

ConfigTab:AddSection({"Bring Settings"})

ConfigTab:AddTextBox("BringRange", "Bring Range", "235", function(v)
    local num = tonumber(v)
    if num then _G.BringRange = num end
end)

ConfigTab:AddTextBox("MaxBringMobs", "Max Bring Mobs", "3", function(v)
    local num = tonumber(v)
    if num then _G.MaxBringMobs = num end
end)

ConfigTab:AddTextBox("MobHeight", "Farm Height", "20", function(v)
    local num = tonumber(v)
    if num then _G.MobHeight = num end
end)
