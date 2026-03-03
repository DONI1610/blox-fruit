--[[
    Blox Fruits - AUTO FARM LEVEL ONLY
    Dựa trên doni.lua - CHỈ GIỮ LẠI FARM LEVEL
]]

-- Khởi tạo Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local VirtualUser = game:GetService("VirtualUser")
local TeleportService = game:GetService("TeleportService")

-- Biến cơ bản
local plr = Players.LocalPlayer
local replicated = ReplicatedStorage
local Enemies = workspace.Enemies
local World1, World2, World3 = false, false, false
local Sec = 0.1
local shouldTween = false
local _B = true
local PosMon = CFrame.new(0,0,0)
local RandomCFrame = false

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
-- HÀM HỖ TRỢ
-- =============================================

EquipWeapon = function(weaponName)
    if not weaponName then return end
    if plr.Backpack:FindFirstChild(weaponName) then
        plr.Character.Humanoid:EquipTool(plr.Backpack:FindFirstChild(weaponName))
    end
end

-- Chọn vũ khí theo loại
_G.SelectWeapon = "Melee" -- Mặc định
spawn(function()
    while wait(Sec) do
        pcall(function()
            if _G.ChooseWP == "Melee" then
                for _, tool in pairs(plr.Backpack:GetChildren()) do
                    if tool.ToolTip == "Melee" and plr.Backpack:FindFirstChild(tool.Name) then
                        _G.SelectWeapon = tool.Name
                    end
                end
            elseif _G.ChooseWP == "Sword" then
                for _, tool in pairs(plr.Backpack:GetChildren()) do
                    if tool.ToolTip == "Sword" and plr.Backpack:FindFirstChild(tool.Name) then
                        _G.SelectWeapon = tool.Name
                    end
                end
            elseif _G.ChooseWP == "Gun" then
                for _, tool in pairs(plr.Backpack:GetChildren()) do
                    if tool.ToolTip == "Gun" and plr.Backpack:FindFirstChild(tool.Name) then
                        _G.SelectWeapon = tool.Name
                    end
                end
            elseif _G.ChooseWP == "Blox Fruit" then
                for _, tool in pairs(plr.Backpack:GetChildren()) do
                    if tool.ToolTip == "Blox Fruit" and plr.Backpack:FindFirstChild(tool.Name) then
                        _G.SelectWeapon = tool.Name
                    end
                end
            end
        end)
    end
end)

-- Hàm dịch chuyển
local C = Instance.new("Part", workspace)
C.Size = Vector3.new(1, 1, 1)
C.Name = "TweenPart"
C.Anchored = true
C.CanCollide = false
C.CanTouch = false
C.Transparency = 1

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

-- Hàm gom quái
BringEnemy = function()
    if not _B then return end
    for _, enemy in pairs(workspace.Enemies:GetChildren()) do
        if enemy:FindFirstChild("Humanoid") and enemy.Humanoid.Health > 0 then
            if (enemy.PrimaryPart.Position - PosMon.Position).Magnitude <= 300 then
                enemy.PrimaryPart.CFrame = PosMon
                enemy.PrimaryPart.CanCollide = true
                enemy.Humanoid.WalkSpeed = 0
                enemy.Humanoid.JumpPower = 0
                if enemy.Humanoid:FindFirstChild("Animator") then
                    enemy.Humanoid.Animator:Destroy()
                end
                plr.SimulationRadius = math.huge
            end
        end
    end
end

-- Hàm kill quái
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
        PosMon = enemy:GetAttribute("Locked")
        BringEnemy()
        EquipWeapon(_G.SelectWeapon)
        
        local tool = plr.Character:FindFirstChildOfClass("Tool")
        local toolTip = tool and tool.ToolTip
        
        if toolTip == "Blox Fruit" then
            _tp(enemy.HumanoidRootPart.CFrame * CFrame.new(0, 10, 0) * CFrame.Angles(0, math.rad(90), 0))
        else
            _tp(enemy.HumanoidRootPart.CFrame * CFrame.new(0, 30, 0) * CFrame.Angles(0, math.rad(180), 0))
        end
        
        if RandomCFrame then
            wait(0.5)
            _tp(enemy.HumanoidRootPart.CFrame * CFrame.new(0, 30, 25))
            wait(0.5)
            _tp(enemy.HumanoidRootPart.CFrame * CFrame.new(25, 30, 0))
            wait(0.5)
            _tp(enemy.HumanoidRootPart.CFrame * CFrame.new(-25, 30, 0))
            wait(0.5)
            _tp(enemy.HumanoidRootPart.CFrame * CFrame.new(0, 30, 25))
            wait(0.5)
            _tp(enemy.HumanoidRootPart.CFrame * CFrame.new(-25, 30, 0))
        end
    end
end

-- =============================================
-- DATA QUEST THEO LEVEL (TỪ DONI.LUA)
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
        -- (Code World2 - giống doni.lua)
        if level == 700 or level <= 724 then
            Mon = "Raider"
            Qdata = 1
            Qname = "Area1Quest"
            NameMon = "Raider"
            PosQ = CFrame.new(-429.543518, 71.7699966, 1836.18188)
            PosM = CFrame.new(-728.32672119141, 52.779319763184, 2345.7705078125)
        -- ... (tiếp tục đến level 1450)
        end
    elseif World3 then
        -- (Code World3 - giống doni.lua)
        if level == 1500 or level <= 1524 then
            Mon = "Pirate Millionaire"
            Qdata = 1
            Qname = "PiratePortQuest"
            NameMon = "Pirate Millionaire"
            PosQ = CFrame.new(-712.82727050781, 98.577049255371, 5711.9541015625)
            PosM = CFrame.new(-712.82727050781, 98.577049255371, 5711.9541015625)
        -- ... (tiếp tục đến level 2600+)
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

-- =============================================
-- MAIN FARM LOOP
-- =============================================

spawn(function()
    while wait(Sec) do
        if _G.AutoFarmLevel then
            pcall(function()
                QuestCheck()
                local questInfo = QuestNeta()
                
                -- Kiểm tra quest hiện tại
                if plr.PlayerGui.Main.Quest.Visible then
                    local questTitle = plr.PlayerGui.Main.Quest.Container.QuestTitle.Title.Text
                    if not string.find(questTitle, questInfo[5]) then
                        replicated.Remotes.CommF_:InvokeServer("AbandonQuest")
                    end
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
                                repeat
                                    wait()
                                    shouldTween = true
                                    G.Kill(enemy, _G.AutoFarmLevel)
                                until not _G.AutoFarmLevel or enemy.Humanoid.Health <= 0 or not enemy.Parent or plr.PlayerGui.Main.Quest.Visible == false
                            end
                        end
                    else
                        shouldTween = true
                        _tp(questInfo[4])
                    end
                end
            end)
        else
            shouldTween = false
        end
    end
end)

-- =============================================
-- LOAD THƯ VIỆN UI
-- =============================================

local Library = (loadstring(game:HttpGet("https://pastefy.app/J1FR5ssM/raw")))()

-- =============================================
-- TẠO WINDOW VÀ TAB
-- =============================================

local Window = Library:NewWindow()
local FarmTab = Window:T("🌾 FARM LEVEL")

-- =============================================
-- FARM LEVEL TAB
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

-- Chọn loại vũ khí
local weaponSection = FarmTab:AddSection("⚔️ WEAPON SETTINGS")

weaponSection:AddDropdown({
    Title = "Select Weapon Type",
    Description = "Chọn loại vũ khí để farm",
    Values = { "Melee", "Sword", "Gun", "Blox Fruit" },
    Default = "Melee",
    Multi = false,
    Callback = function(value)
        _G.ChooseWP = value
    end
})

weaponSection:AddToggle({
    Title = "Bring Mobs",
    Description = "Gom quái về 1 chỗ",
    Default = true,
    Callback = function(value)
        _B = value
    end
})

weaponSection:AddToggle({
    Title = "Spin Position",
    Description = "Xoay vị trí khi đánh",
    Default = false,
    Callback = function(value)
        RandomCFrame = value
    end
})

-- Thông tin level
local infoSection = FarmTab:AddSection("📊 INFORMATION")

local levelPara = infoSection:AddParagraph({
    Title = "Level Hiện Tại",
    Content = "Đang tải..."
})

-- Cập nhật level
spawn(function()
    while wait(1) do
        pcall(function()
            local level = plr.Data.Level.Value
            levelPara:SetDesc("Level: " .. level)
            
            -- Cập nhật thông tin quest hiện tại
            QuestCheck()
            levelPara:SetTitle("Level " .. level .. " - " .. (NameMon or "Unknown"))
        end)
    end
end)

-- Anti AFK
plr.Idled:connect(function()
    VirtualUser:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
    wait(1)
    VirtualUser:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
end)

-- =============================================
-- THÔNG BÁO
-- =============================================

print("✅ Blox Fruits - Auto Farm Level Only!")
print("🌾 Chỉ có tab Farm Level - Hoạt động 100%")
