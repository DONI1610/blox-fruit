do
    ply = game.Players
    plr = ply.LocalPlayer
    Root = plr.Character.HumanoidRootPart
    replicated = game:GetService("ReplicatedStorage")
    Lv = game.Players.LocalPlayer.Data.Level.Value
    TeleportService = game:GetService("TeleportService")
    TW = game:GetService("TweenService")
    Lighting = game:GetService("Lighting")
    Enemies = workspace.Enemies
    vim1 = game:GetService("VirtualInputManager")
    vim2 = game:GetService("VirtualUser")
    TeamSelf = plr.Team
    RunSer = game:GetService("RunService")
    Stats = game:GetService("Stats")
    Energy = plr.Character.Energy.Value
    Boss = {}
    BringConnections = {}
    MaterialList = {}
    NPCList = {}
    shouldTween = false
    SoulGuitar = false
    KenTest = true
    debug = false
    Brazier1 = false
    Brazier2 = false
    Brazier3 = false
    Sec = 0.1
    ClickState = 0
    Num_self = 25
end

repeat
    local start = plr.PlayerGui:WaitForChild("Main"):WaitForChild("Loading") and game:IsLoaded()
    wait()
until start
World1 = game.PlaceId == 2753915549
World2 = game.PlaceId == 4442272183
World3 = game.PlaceId == 7449423635
Sea = World1 or World2 or World3 or plr:Kick("❌ Error : A[12]Blox Fruits ❌")
Marines = function()
    replicated.Remotes.CommF_:InvokeServer("SetTeam", "Marines")
end
Pirates = function()
    replicated.Remotes.CommF_:InvokeServer("SetTeam", "Pirates")
end
if World1 then
    Boss = {
        "The Gorilla King",
        "Bobby",
        "The Saw",
        "Yeti",
        "Mob Leader",
        "Vice Admiral",
        "Saber Expert",
        "Warden",
        "Chief Warden",
        "Swan",
        "Magma Admiral",
        "Fishman Lord",
        "Wysper",
        "Thunder God",
        "Cyborg",
        "Ice Admiral",
        "Greybeard"
    }
elseif World2 then
    Boss = {
        "Diamond",
        "Jeremy",
        "Fajita",
        "Don Swan",
        "Smoke Admiral",
        "Awakened Ice Admiral",
        "Tide Keeper",
        "Darkbeard",
        "Cursed Captain",
        "Order"
    }
elseif World3 then
    Boss = {
        "Stone",
        "Hydra Leader",
        "Kilo Admiral",
        "Captain Elephant",
        "Beautiful Pirate",
        "Cake Queen",
        "Longma",
        "Soul Reaper"
    }
end
if World1 then
    MaterialList = {
        "Leather + Scrap Metal",
        "Angel Wings",
        "Magma Ore",
        "Fish Tail"
    }
elseif World2 then
    MaterialList = {
        "Leather + Scrap Metal",
        "Radioactive Material",
        "Ectoplasm",
        "Mystic Droplet",
        "Magma Ore",
        "Vampire Fang"
    }
elseif World3 then
    MaterialList = {
        "Scrap Metal",
        "Demonic Wisp",
        "Conjured Cocoa",
        "Dragon Scale",
        "Gunpowder",
        "Fish Tail",
        "Mini Tusk"
    }
end
local DungeonTables = {
    "Flame",
    "Ice",
    "Quake",
    "Light",
    "Dark",
    "String",
    "Rumble",
    "Magma",
    "Human: Buddha",
    "Sand",
    "Bird: Phoenix",
    "Dough"
}
local RenMon = {
    "Snow Lurker",
    "Arctic Warrior",
    "Hidden Key",
    "Awakened Ice Admiral"
}
local CursedTables = {
    ["Mob"] = "Mythological Pirate",
    ["Mob2"] = "Cursed Skeleton",
    "Hell's Messenger",
    ["Mob3"] = "Cursed Skeleton",
    "Heaven's Guardian"
}
local Past = {
    "Part",
    "SpawnLocation",
    "Terrain",
    "WedgePart",
    "MeshPart"
}
local BartMon = {
    "Swan Pirate",
    "Jeremy"
}
local CitizenTable = {
    "Forest Pirate",
    "Captain Elephant"
}
local Human_v3_Mob = {
    "Fajita",
    "Jeremy",
    "Diamond"
}
local AllBoats = {
    "Beast Hunter",
    "Lantern",
    "Guardian",
    "Grand Brigade",
    "Dinghy",
    "Sloop",
    "The Sentinel"
}
local mastery1 = {
    "Cookie Crafter"
}
local mastery2 = {
    "Reborn Skeleton"
}
local PosMsList = {
    ["Pirate Millionaire"] = CFrame.new(- 712.8272705078125, 98.5770492553711, 5711.9541015625),
    ["Pistol Billionaire"] = CFrame.new(- 723.4331665039062, 147.42906188964844, 5931.9931640625),
    ["Dragon Crew Warrior"] = CFrame.new(7021.50439453125, 55.76270294189453, - 730.1290893554688),
    ["Dragon Crew Archer"] = CFrame.new(6625, 378, 244),
    ["Female Islander"] = CFrame.new(4692.7939453125, 797.9766845703125, 858.8480224609375),
    ["Venomous Assailant"] = CFrame.new(4902, 670, 39),
    ["Marine Commodore"] = CFrame.new(2401, 123, - 7589),
    ["Marine Rear Admiral"] = CFrame.new(3588, 229, - 7085),
    ["Fishman Raider"] = CFrame.new(- 10941, 332, - 8760),
    ["Fishman Captain"] = CFrame.new(- 11035, 332, - 9087),
    ["Forest Pirate"] = CFrame.new(- 13446, 413, - 7760),
    ["Mythological Pirate"] = CFrame.new(- 13510, 584, - 6987),
    ["Jungle Pirate"] = CFrame.new(- 11778, 426, - 10592),
    ["Musketeer Pirate"] = CFrame.new(- 13282, 496, - 9565),
    ["Reborn Skeleton"] = CFrame.new(- 8764, 142, 5963),
    ["Living Zombie"] = CFrame.new(- 10227, 421, 6161),
    ["Demonic Soul"] = CFrame.new(- 9579, 6, 6194),
    ["Posessed Mummy"] = CFrame.new(- 9579, 6, 6194),
    ["Peanut Scout"] = CFrame.new(- 1993, 187, - 10103),
    ["Peanut President"] = CFrame.new(- 2215, 159, - 10474),
    ["Ice Cream Chef"] = CFrame.new(- 877, 118, - 11032),
    ["Ice Cream Commander"] = CFrame.new(- 877, 118, - 11032),
    ["Cookie Crafter"] = CFrame.new(- 2021, 38, - 12028),
    ["Cake Guard"] = CFrame.new(- 2024, 38, - 12026),
    ["Baking Staff"] = CFrame.new(- 1932, 38, - 12848),
    ["Head Baker"] = CFrame.new(- 1932, 38, - 12848),
    ["Cocoa Warrior"] = CFrame.new(95, 73, - 12309),
    ["Chocolate Bar Battler"] = CFrame.new(647, 42, - 12401),
    ["Sweet Thief"] = CFrame.new(116, 36, - 12478),
    ["Candy Rebel"] = CFrame.new(47, 61, - 12889),
    ["Ghost"] = CFrame.new(5251, 5, 1111)
}
EquipWeapon = function(text)
    if not text then
        return
    end
    if plr.Backpack:FindFirstChild(text) then
        plr.Character.Humanoid:EquipTool(plr.Backpack:FindFirstChild(text))
    end
end
weaponSc = function(weapon)
    for __in, v in pairs(plr.Backpack:GetChildren()) do
        if v:IsA("Tool") then
            if v.ToolTip == weapon then
                EquipWeapon(v.Name)
            end
        end
    end
end
hookfunction(require(game:GetService("ReplicatedStorage").Effect.Container.Death), function()
end)
hookfunction(require(game:GetService("ReplicatedStorage"):WaitForChild("GuideModule")).ChangeDisplayedNPC, function()
end)
hookfunction(error, function()
end)
hookfunction(warn, function()
end)
local Rock = workspace:FindFirstChild("Rocks")
if Rock then
    Rock:Destroy()
end
gay = (function()
    local lighting = game:GetService("Lighting")
    local lightingLayers = lighting:FindFirstChild("LightingLayers")
    if lightingLayers and game:GetService("Lighting") and game:GetService("Lighting") then
        local darkFog = lightingLayers:FindFirstChild("DarkFog")
        if darkFog then
            darkFog:Destroy()
        end
    end
    local Water = workspace._WorldOrigin["Foam;"]
    if Water and workspace._WorldOrigin["Foam;"] then
        Water:Destroy()
    end        
end)()
local Attack = {}
Attack.__index = Attack
Attack.Alive = function(model)
    if not model then
        return
    end
    local Humanoid = model:FindFirstChild("Humanoid")
    return Humanoid and Humanoid.Health > 0
end
Attack.Pos = function(model, dist)
    return (Root.Position - mode.Position).Magnitude <= dist
end
Attack.Dist = function(model, dist)
    return (Root.Position - model:FindFirstChild("HumanoidRootPart").Position).Magnitude <= dist
end
Attack.DistH = function(model, dist)
    return (Root.Position - model:FindFirstChild("HumanoidRootPart").Position).Magnitude > dist
end
Attack.Kill = function(model, Succes)
    if model and Succes then
        if not model:GetAttribute("Locked") then
            model:SetAttribute("Locked", model.HumanoidRootPart.CFrame)
        end
        PosMon = model:GetAttribute("Locked").Position
        BringEnemy()
        EquipWeapon(_G.SelectWeapon)
        local Equipped = game.Players.LocalPlayer.Character:FindFirstChildOfClass("Tool")
        local ToolTip = Equipped.ToolTip
        if ToolTip == "Blox Fruit" then
            _tp(model.HumanoidRootPart.CFrame * CFrame.new(0, 10, 0) * CFrame.Angles(0, math.rad(90), 0))
        else
            _tp(model.HumanoidRootPart.CFrame * CFrame.new(0, 30, 0) * CFrame.Angles(0, math.rad(180), 0))
        end
        if RandomCFrame then
            wait(.5)
            _tp(model.HumanoidRootPart.CFrame * CFrame.new(0, 30, 25))
            wait(.5)
            _tp(model.HumanoidRootPart.CFrame * CFrame.new(25, 30, 0))
            wait(.5)
            _tp(model.HumanoidRootPart.CFrame * CFrame.new(- 25, 30, 0))
            wait(.5)
            _tp(model.HumanoidRootPart.CFrame * CFrame.new(0, 30, 25))
            wait(.5)
            _tp(model.HumanoidRootPart.CFrame * CFrame.new(- 25, 30, 0))
        end
    end
end
Attack.Kill2 = function(model, Succes)
    if model and Succes then
        if not model:GetAttribute("Locked") then
            model:SetAttribute("Locked", model.HumanoidRootPart.CFrame)
        end
        PosMon = model:GetAttribute("Locked").Position
        BringEnemy()
        EquipWeapon(_G.SelectWeapon)
        local Equipped = game.Players.LocalPlayer.Character:FindFirstChildOfClass("Tool")
        local ToolTip = Equipped.ToolTip
        if ToolTip == "Blox Fruit" then
            _tp(model.HumanoidRootPart.CFrame * CFrame.new(0, 10, 0) * CFrame.Angles(0, math.rad(90), 0))
        else
            _tp(model.HumanoidRootPart.CFrame * CFrame.new(0, 30, 8) * CFrame.Angles(0, math.rad(180), 0))
        end
        if RandomCFrame then
            wait(0.1)
            _tp(model.HumanoidRootPart.CFrame * CFrame.new(0, 30, 25))
            wait(0.1)
            _tp(model.HumanoidRootPart.CFrame * CFrame.new(25, 30, 0))
            wait(0.1)
            _tp(model.HumanoidRootPart.CFrame * CFrame.new(- 25, 30, 0))
            wait(0.1)
            _tp(model.HumanoidRootPart.CFrame * CFrame.new(0, 30, 25))
            wait(0.1)
            _tp(model.HumanoidRootPart.CFrame * CFrame.new(- 25, 30, 0))
        end
    end
end
Attack.KillSea = function(model, Succes)
    if model and Succes then
        if not model:GetAttribute("Locked") then
            model:SetAttribute("Locked", model.HumanoidRootPart.CFrame)
        end
        PosMon = model:GetAttribute("Locked").Position
        BringEnemy()
        EquipWeapon(_G.SelectWeapon)
        local Equipped = game.Players.LocalPlayer.Character:FindFirstChildOfClass("Tool")
        local ToolTip = Equipped.ToolTip
        if ToolTip == "Blox Fruit" then
            _tp(model.HumanoidRootPart.CFrame * CFrame.new(0, 10, 0) * CFrame.Angles(0, math.rad(90), 0))
        else
            notween(model.HumanoidRootPart.CFrame * CFrame.new(0, 50, 8))
            wait(.85)
            notween(model.HumanoidRootPart.CFrame * CFrame.new(0, 400, 0))
            wait(1)
        end
    end
end
Attack.Sword = function(model, Succes)
    if model and Succes then
        if not model:GetAttribute("Locked") then
            model:SetAttribute("Locked", model.HumanoidRootPart.CFrame)
        end
        PosMon = model:GetAttribute("Locked").Position
        BringEnemy()
        weaponSc("Sword")
        _tp(model.HumanoidRootPart.CFrame * CFrame.new(0, 30, 0))
        if RandomCFrame then
            wait(0.1)
            _tp(model.HumanoidRootPart.CFrame * CFrame.new(0, 30, 25))
            wait(0.1)
            _tp(model.HumanoidRootPart.CFrame * CFrame.new(25, 30, 0))
            wait(0.1)
            _tp(model.HumanoidRootPart.CFrame * CFrame.new(- 25, 30, 0))
            wait(0.1)
            _tp(model.HumanoidRootPart.CFrame * CFrame.new(0, 30, 25))
            wait(0.1)
            _tp(model.HumanoidRootPart.CFrame * CFrame.new(- 25, 30, 0))
        end
    end
end
Attack.Mas = function(model, Succes)
    if model and Succes then
        if not model:GetAttribute("Locked") then
            model:SetAttribute("Locked", model.HumanoidRootPart.CFrame)
        end
        PosMon = model:GetAttribute("Locked").Position
        BringEnemy()
        if model.Humanoid.Health <= HealthM then
            _tp(model.HumanoidRootPart.CFrame * CFrame.new(0, 20, 0))
            Useskills("Blox Fruit", "Z")
            Useskills("Blox Fruit", "X")
            Useskills("Blox Fruit", "C")
        else
            weaponSc("Melee")
            _tp(model.HumanoidRootPart.CFrame * CFrame.new(0, 30, 0))
        end
    end
end
Attack.Masgun = function(model, Succes)
    if model and Succes then
        if not model:GetAttribute("Locked") then
            model:SetAttribute("Locked", model.HumanoidRootPart.CFrame)
        end
        PosMon = model:GetAttribute("Locked").Position
        BringEnemy()
        if model.Humanoid.Health <= HealthM then
            _tp(model.HumanoidRootPart.CFrame * CFrame.new(0, 35, 8))
            Useskills("Gun", "Z")
            Useskills("Gun", "X")
        else
            weaponSc("Melee")
            _tp(model.HumanoidRootPart.CFrame * CFrame.new(0, 30, 0))
        end
    end
end
statsSetings = function(Num, value)
    if Num == "Melee" then
        if plr.Data.Points.Value ~= 0 then
            replicated.Remotes.CommF_:InvokeServer("AddPoint", "Melee", value)
        end
    elseif Num == "Defense" then
        if plr.Data.Points.Value ~= 0 then
            replicated.Remotes.CommF_:InvokeServer("AddPoint", "Defense", value)
        end
    elseif Num == "Sword" then
        if plr.Data.Points.Value ~= 0 then
            replicated.Remotes.CommF_:InvokeServer("AddPoint", "Sword", value)
        end
    elseif Num == "Gun" then
        if plr.Data.Points.Value ~= 0 then
            replicated.Remotes.CommF_:InvokeServer("AddPoint", "Gun", value)
        end
    elseif Num == "Devil" then
        if plr.Data.Points.Value ~= 0 then
            replicated.Remotes.CommF_:InvokeServer("AddPoint", "Demon Fruit", value)
        end
    end
end
BringEnemy = function()
    if not _B then
        return
    end
    for _, v in pairs(workspace.Enemies:GetChildren()) do
        if v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then
            if (v.PrimaryPart.Position - PosMon).Magnitude <= 300 then
                v.PrimaryPart.CFrame = CFrame.new(PosMon)
                v.PrimaryPart.CanCollide = true;
                v:FindFirstChild("Humanoid").WalkSpeed = 0;
                v:FindFirstChild("Humanoid").JumpPower = 0;
                if v.Humanoid:FindFirstChild("Animator") then
                    v.Humanoid.Animator:Destroy()
                end;
                plr.SimulationRadius = math.huge
            end
        end
    end                    	
end
Useskills = function(weapon, skill)
    if weapon == "Melee" then
        weaponSc("Melee")
        if skill == "Z" then
            vim1:SendKeyEvent(true, "Z", false, game);
            vim1:SendKeyEvent(false, "Z", false, game);
        elseif skill == "X" then
            vim1:SendKeyEvent(true, "X", false, game);
            vim1:SendKeyEvent(false, "X", false, game);
        elseif skill == "C" then
            vim1:SendKeyEvent(true, "C", false, game);
            vim1:SendKeyEvent(false, "C", false, game);
        end
    elseif weapon == "Sword" then
        weaponSc("Sword")
        if skill == "Z" then
            vim1:SendKeyEvent(true, "Z", false, game);
            vim1:SendKeyEvent(false, "Z", false, game);
        elseif skill == "X" then
            vim1:SendKeyEvent(true, "X", false, game);
            vim1:SendKeyEvent(false, "X", false, game);
        end
    elseif weapon == "Blox Fruit" then
        weaponSc("Blox Fruit")
        if skill == "Z" then
            vim1:SendKeyEvent(true, "Z", false, game);
            vim1:SendKeyEvent(false, "Z", false, game);
        elseif skill == "X" then
            vim1:SendKeyEvent(true, "X", false, game);
            vim1:SendKeyEvent(false, "X", false, game);
        elseif skill == "C" then
            vim1:SendKeyEvent(true, "C", false, game);
            vim1:SendKeyEvent(false, "C", false, game);
        elseif skill == "V" then
            vim1:SendKeyEvent(true, "V", false, game);
            vim1:SendKeyEvent(false, "V", false, game);
        end
    elseif weapon == "Gun" then
        weaponSc("Gun")
        if skill == "Z" then
            vim1:SendKeyEvent(true, "Z", false, game);
            vim1:SendKeyEvent(false, "Z", false, game);
        elseif skill == "X" then
            vim1:SendKeyEvent(true, "X", false, game);
            vim1:SendKeyEvent(false, "X", false, game);
        end
    end
    if weapon == "nil" and skill == "Y" then
        vim1:SendKeyEvent(true, "Y", false, game);
        vim1:SendKeyEvent(false, "Y", false, game);
    end
end
local gg = getrawmetatable(game)
local old = gg.__namecall
setreadonly(gg, false)
gg.__namecall = newcclosure(function(...)
    local method = getnamecallmethod()
    local args = {
        ...
    }    
    if tostring(method) == "FireServer" then
        if tostring(args[1]) == "RemoteEvent" then
            if tostring(args[2]) ~= "true" and tostring(args[2]) ~= "false" then
                if (_G.FarmMastery_G and not SoulGuitar) or (_G.FarmMastery_Dev) or (_G.FarmBlazeEM) or (_G.Prehis_Skills) or (_G.SeaBeast1 or _G.FishBoat or _G.PGB or _G.Leviathan1 or _G.Complete_Trials) or (_G.AimMethod and ABmethod == "AimBots Skill") or (_G.AimMethod and ABmethod == "Auto Aimbots") then
                    args[2] = MousePos
                    return old(unpack(args))
                end
            end
        end
    end
    return old(...)
end)
GetConnectionEnemies = function(a)
    for i, v in pairs(replicated:GetChildren()) do
        if v:IsA("Model") and ((typeof(a) == "table" and table.find(a, v.Name)) or v.Name == a) and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then
            return v
        end
    end
    for i, v in next, game.Workspace.Enemies:GetChildren() do
        if v:IsA("Model") and ((typeof(a) == "table" and table.find(a, v.Name)) or v.Name == a) and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then
            return v
        end
    end
end
LowCpu = function()
    local decalsyeeted = true
    local g = game
    local w = g.Workspace
    local l = g.Lighting
    local t = w.Terrain
    t.WaterWaveSize = 0
    t.WaterWaveSpeed = 0
    t.WaterReflectance = 0
    t.WaterTransparency = 0
    l.GlobalShadows = false
    l.FogEnd = 9e9
    l.Brightness = 0
    settings().Rendering.QualityLevel = "Level01"
    for i, v in pairs(g:GetDescendants()) do
        if v:IsA("Part") or v:IsA("Union") or v:IsA("CornerWedgePart") or v:IsA("TrussPart") then
            v.Material = "Plastic"
            v.Reflectance = 0
        elseif v:IsA("Decal") or v:IsA("Texture") and decalsyeeted then
            v.Transparency = 1
        elseif v:IsA("ParticleEmitter") or v:IsA("Trail") then
            v.Lifetime = NumberRange.new(0)
        elseif v:IsA("Explosion") then
            v.BlastPressure = 1
            v.BlastRadius = 1
        elseif v:IsA("Fire") or v:IsA("SpotLight") or v:IsA("Smoke") or v:IsA("Sparkles") then
            v.Enabled = false
        elseif v:IsA("MeshPart") then
            v.Material = "Plastic"
            v.Reflectance = 0
            v.TextureID = 10385902758728957
        end
    end
    for i, e in pairs(l:GetChildren()) do
        if e:IsA("BlurEffect") or e:IsA("SunRaysEffect") or e:IsA("ColorCorrectionEffect") or e:IsA("BloomEffect") or e:IsA("DepthOfFieldEffect") then
            e.Enabled = false
        end
    end
end
CheckF = function()
    if GetBP("Dragon-Dragon") or GetBP("Gas-Gas") or GetBP("Yeti-Yeti") or GetBP("Kitsune-Kitsune") or GetBP("T-Rex-T-Rex") then
        return true
    end
end
CheckBoat = function()
    for i, v in pairs(workspace.Boats:GetChildren()) do
        if tostring(v.Owner.Value) == tostring(plr.Name) then
            return v
        end;
    end;
    return false
end;
CheckEnemiesBoat = function()
    for _, v in pairs(workspace.Enemies:GetChildren()) do
        if (v.Name == "FishBoat") and v:FindFirstChild("Health").Value > 0 then
            return true
        end;
    end;
    return false
end;
CheckPirateGrandBrigade = function()
    for _, v in pairs(workspace.Enemies:GetChildren()) do
        if (v.Name == "PirateGrandBrigade" or v.Name == "PirateBrigade") and v:FindFirstChild("Health").Value > 0 then
            return true
        end
    end
    return false
end
CheckShark = function()
    for _, v in pairs(workspace.Enemies:GetChildren()) do
        if v.Name == "Shark" and Attack.Alive(v) then
            return true
        end;
    end;
    return false
end;
CheckTerrorShark = function()
    for _, v in pairs(workspace.Enemies:GetChildren()) do
        if v.Name == "Terrorshark" and Attack.Alive(v) then
            return true
        end;
    end;
    return false
end;
CheckPiranha = function()
    for _, v in pairs(workspace.Enemies:GetChildren()) do
        if v.Name == "Piranha" and Attack.Alive(v) then
            return true
        end;
    end;
    return false
end;
CheckFishCrew = function()
    for _, v in pairs(workspace.Enemies:GetChildren()) do
        if (v.Name == "Fish Crew Member" or v.Name == "Haunted Crew Member") and Attack.Alive(v) then
            return true
        end;
    end;
    return false
end;
CheckHauntedCrew = function()
    for _, v in pairs(workspace.Enemies:GetChildren()) do
        if (v.Name == "Haunted Crew Member") and Attack.Alive(v) then
            return true
        end;
    end;
    return false
end;
CheckSeaBeast = function()
    if workspace.SeaBeasts:FindFirstChild("SeaBeast1") then
        return true
    end;
    return false
end;
CheckLeviathan = function()
    if workspace.SeaBeasts:FindFirstChild("Leviathan") then
        return true
    end;
    return false
end;
UpdStFruit = function()
    for z, x in next, plr.Backpack:GetChildren() do
        StoreFruit = x:FindFirstChild("EatRemote", true)
        if StoreFruit then
            replicated.Remotes.CommF_:InvokeServer("StoreFruit", StoreFruit.Parent:GetAttribute("OriginalName"), plr.Backpack:FindFirstChild(x.Name))
        end
    end
end
collectFruits = function(Succes)
    if Succes then
        local Character = plr.Character
        for _, v1 in pairs(workspace:GetChildren()) do
            if string.find(v1.Name, "Fruit") then
                v1.Handle.CFrame = Character.HumanoidRootPart.CFrame
            end
        end
    end
end
Getmoon = function()
    if World1 then
        return Lighting.FantasySky.MoonTextureId
    elseif World2 then
        return Lighting.FantasySky.MoonTextureId
    elseif World3 then
        return Lighting.Sky.MoonTextureId
    end
end
DropFruits = function()
    for _, v3 in next, plr.Backpack:GetChildren() do
        if string.find(v3.Name, "Fruit") then
            EquipWeapon(v3.Name)
            wait(.1)
            if plr.PlayerGui.Main.Dialogue.Visible == true then
                plr.PlayerGui.Main.Dialogue.Visible = false
            end
            EquipWeapon(v3.Name)
            plr.Character:FindFirstChild(v3.Name).EatRemote:InvokeServer("Drop")
        end
    end
    for a, b2 in pairs(plr.Character:GetChildren()) do
        if string.find(b2.Name, "Fruit") then
            EquipWeapon(b2.Name)
            wait(.1)
            if plr.PlayerGui.Main.Dialogue.Visible == true then
                plr.PlayerGui.Main.Dialogue.Visible = false
            end
            EquipWeapon(b2.Name)
            plr.Character:FindFirstChild(b2.Name).EatRemote:InvokeServer("Drop")
        end
    end
end
GetBP = function(v)
    return plr.Backpack:FindFirstChild(v) or plr.Character:FindFirstChild(v)
end
GetIn = function(Name)
    for _ , v1 in pairs(replicated.Remotes.CommF_:InvokeServer("getInventory")) do
        if type(v1) == "table" then
            if v1.Name == Name or plr.Character:FindFirstChild(Name) or plr.Backpack:FindFirstChild(Name) then
                return true
            end
        end
    end
    return false
end
GetM = function(Name)
    for _, tab in pairs(replicated.Remotes.CommF_:InvokeServer("getInventory")) do
        if type(tab) == "table" then
            if tab.Type == "Material" then
                if tab.Name == Name then
                    return tab.Count
                end
            end
        end
    end
    return 0
end
GetWP = function(nametool)
    for _, v4 in pairs(replicated.Remotes.CommF_:InvokeServer("getInventory")) do
        if type(v4) == "table" then
            if v4.Type == "Sword" then
                if v4.Name == nametool or plr.Character:FindFirstChild(nametool) or plr.Backpack:FindFirstChild(nametool) then
                    return true
                end
            end
        end
    end
    return false
end 
getInfinity_Ability = function(Method, Var)
    if not Root then
        return
    end
    if Method == "Soru" and Var then
        for _, gc in next, getgc() do
            if plr.Character.Soru then
                if ((typeof(gc) == "function") and (getfenv(gc).script == plr.Character.Soru)) then
                    for _, v in next, getupvalues(gc) do
                        if (typeof(v) == "table") then
                            repeat
                                wait(Sec)
                                v.LastUse = 0
                            until not Var or (plr.Character.Humanoid.Health <= 0)
                        end
                    end
                end
            end
        end
    elseif Method == "Energy" and Var then
        plr.Character.Energy.Changed:connect(function()
            if Var then
                plr.Character.Energy.Value = Energy
            end
        end)
    elseif Method == "Observation" and Var then
        local VisionRadius = plr.VisionRadius
        VisionRadius.Value = math.huge
    end
end
Hop = function()
    pcall(function()
        for count = math.random(1, math.random(40, 75)), 100 do
            local remote = replicated.__ServerBrowser:InvokeServer(count)
            for _, v in next, remote do
                if tonumber(v['Count']) < 12 then
                    TeleportService:TeleportToPlaceInstance(game.PlaceId, _)
                end
            end
        end
    end)
end
local block = Instance.new("Part", workspace)
block.Size = Vector3.new(1, 1, 1)
block.Name = "Rip_Indra"
block.Anchored = true
block.CanCollide = false
block.CanTouch = false
block.Transparency = 1
local blockfind = workspace:FindFirstChild(block.Name)
if blockfind and blockfind ~= block then
    blockfind:Destroy()
end
task.spawn(function()
    while task.wait() do
        if block and block.Parent == workspace then
            if shouldTween then
                getgenv().OnFarm = true
            else
                getgenv().OnFarm = false
            end
        else
            getgenv().OnFarm = false
        end
    end
end)
task.spawn(function()
    local a = game.Players.LocalPlayer;
    repeat
        task.wait()
    until a.Character and a.Character.PrimaryPart;
    block.CFrame = a.Character.PrimaryPart.CFrame;
    while task.wait() do
        pcall(function()
            if getgenv().OnFarm then
                if block and block.Parent == workspace then
                    local b = a.Character and a.Character.PrimaryPart;
                    if b and (b.Position - block.Position).Magnitude <= 200 then
                        b.CFrame = block.CFrame
                    else
                        block.CFrame = b.CFrame
                    end
                end;
                local c = a.Character;
                if c then
                    for d, e in pairs(c:GetChildren()) do
                        if e:IsA("BasePart") then
                            e.CanCollide = false
                        end
                    end
                end
            else
                local c = a.Character;
                if c then
                    for d, e in pairs(c:GetChildren()) do
                        if e:IsA("BasePart") then
                            e.CanCollide = true
                        end
                    end
                end
            end
        end)
    end
end)
_tp = function(target)
    local character = plr.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then
        return
    end
    local rootPart = character.HumanoidRootPart
    local distance = (target.Position - rootPart.Position).Magnitude
    local tweenInfo = TweenInfo.new(distance / 300, Enum.EasingStyle.Linear)
    local tween = game:GetService("TweenService"):Create(block, tweenInfo, {
        CFrame = target
    })
    if plr.Character.Humanoid.Sit == true then
        block.CFrame = CFrame.new(block.Position.X, target.Y, block.Position.Z)
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
TeleportToTarget = function(targetCFrame)
    if (targetCFrame.Position - plr.Character.HumanoidRootPart.Position).Magnitude > 1000 then
        _tp(targetCFrame)
    else
        _tp(targetCFrame)
    end
end
notween = function(p)
    plr.Character.HumanoidRootPart.CFrame = p
end
function BTP(p)
    local player = game.Players.LocalPlayer
    local humanoidRootPart = player.Character.HumanoidRootPart
    local humanoid = player.Character.Humanoid
    local playerGui = player.PlayerGui.Main
    local targetPosition = p.Position
    local lastPosition = humanoidRootPart.Position
    repeat
        humanoid.Health = 0
        humanoidRootPart.CFrame = p
        playerGui.Quest.Visible = false
        if (humanoidRootPart.Position - lastPosition).Magnitude > 1 then
            lastPosition = humanoidRootPart.Position
            humanoidRootPart.CFrame = p
        end
        task.wait(0.5)
    until (p.Position - humanoidRootPart.Position).Magnitude <= 2000
end
spawn(function()
    while wait(Sec) do
        if _G.SailBoat_Hydra or _G.WardenBoss or _G.AutoFactory or _G.HighestMirage or _G.HCM or _G.PGB or _G.Leviathan1 or _G.UPGDrago or _G.Complete_Trials or _G.TpDrago_Prehis or _G.BuyDrago or _G.AutoFireFlowers or _G.DT_Uzoth or _G.AutoBerry or _G.Prehis_Find or _G.Prehis_Skills or _G.Prehis_DB or _G.Prehis_DE or _G.FarmBlazeEM or _G.Dojoo or _G.CollectPresent or _G.AutoLawKak or _G.TpLab or _G.AutoPhoenixF or _G.AutoFarmChest or _G.AutoHytHallow or _G.LongsWord or _G.BlackSpikey or _G.AutoHolyTorch or _G.TrainDrago or _G.AutoSaber or _G.FarmMastery_Dev or _G.CitizenQuest or _G.AutoEctoplasm or _G.KeysRen or _G.Auto_Rainbow_Haki or _G.obsFarm or _G.AutoBigmom or _G.Doughv2 or _G.AuraBoss or _G.Raiding or _G.Auto_Cavender or _G.TpPly or _G.Bartilo_Quest or _G.Level or _G.FarmEliteHunt or _G.AutoZou or _G.AutoFarm_Bone or getgenv().AutoMaterial or _G.CraftVM or _G.FrozenTP or _G.TPDoor or _G.AcientOne or _G.AutoFarmNear or _G.AutoRaidCastle or _G.DarkBladev3 or _G.AutoFarmRaid or _G.Auto_Cake_Prince or _G.Addealer or _G.TPNpc or _G.TwinHook or _G.FindMirage or _G.FarmChestM or _G.Shark or _G.TerrorShark or _G.Piranha or _G.MobCrew or _G.SeaBeast1 or _G.FishBoat or _G.AutoPole or _G.AutoPoleV2 or _G.Auto_SuperHuman or _G.AutoDeathStep or _G.Auto_SharkMan_Karate or _G.Auto_Electric_Claw or _G.AutoDragonTalon or _G.Auto_Def_DarkCoat or _G.Auto_God_Human or _G.Auto_Tushita or _G.AutoMatSoul or _G.AutoKenVTWO or _G.AutoSerpentBow or _G.AutoFMon or _G.Auto_Soul_Guitar or _G.TPGEAR or _G.AutoSaw or _G.AutoTridentW2 or _G.Auto_StartRaid or _G.AutoEvoRace or _G.AutoGetQuestBounty or _G.MarinesCoat or _G.TravelDres or _G.Defeating or _G.DummyMan or _G.Auto_Yama or _G.Auto_SwanGG or _G.SwanCoat or _G.AutoEcBoss or _G.Auto_Mink or _G.Auto_Human or _G.Auto_Skypiea or _G.Auto_Fish or _G.CDK_TS or _G.CDK_YM or _G.CDK or _G.AutoFarmGodChalice or _G.AutoFistDarkness or _G.AutoMiror or _G.Teleport or _G.AutoKilo or _G.AutoGetUsoap or _G.Praying or _G.TryLucky or _G.AutoColShad or _G.AutoUnHaki or _G.Auto_DonAcces or _G.AutoRipIngay or _G.DragoV3 or _G.DragoV1 or _G.SailBoats or NextIs or _G.FarmGodChalice or _G.IceBossRen or senth or senth2 or _G.Lvthan or _G.beasthunter or _G.DangerLV or _G.Relic123 or _G.tweenKitsune or _G.Collect_Ember or _G.AutofindKitIs or _G.snaguine or _G.TwFruits or _G.tweenKitShrine or _G.Tp_LgS or _G.Tp_MasterA or _G.tweenShrine or _G.FarmMastery_G or _G.FarmMastery_S then
                shouldTween = true
                if not plr.Character.HumanoidRootPart:FindFirstChild("BodyClip") then
                    local Noclip = Instance.new("BodyVelocity")
                    Noclip.Name = "BodyClip"
                    Noclip.Parent = plr.Character.HumanoidRootPart
                    Noclip.MaxForce = Vector3.new(100000, 100000, 100000)
                    Noclip.Velocity = Vector3.new(0, 0, 0)
                end
                if not plr.Character:FindFirstChild('highlight') then
                    local Test = Instance.new('Highlight')
                    Test.Name = "highlight"
                    Test.Enabled = true
                    Test.FillColor = Color3.fromRGB(2, 197, 60)
                    Test.OutlineColor = Color3.fromRGB(255, 255, 255)
                    Test.FillTransparency = 0.5
                    Test.OutlineTransparency = 0.2
                    Test.Parent = plr.Character
                end
                for _, no in pairs(plr.Character:GetDescendants()) do
                    if no:IsA("BasePart") then
                        no.CanCollide = false
                    end
                end
            else
                shouldTween = false
                if plr.Character.HumanoidRootPart:FindFirstChild("BodyClip") then
                    plr.Character.HumanoidRootPart:FindFirstChild("BodyClip"):Destroy()
                end
                if plr.Character:FindFirstChild('highlight') then
                    plr.Character:FindFirstChild('highlight'):Destroy()
                end
            end
        end)
    end
end)
QuestB = function()
    if World1 then
        if _G.FindBoss == "The Gorilla King" then
            bMon = "The Gorilla King"
            Qname = "JungleQuest"
            Qdata = 3;
            PosQBoss = CFrame.new(- 1601.6553955078, 36.85213470459, 153.38809204102)
            PosB = CFrame.new(- 1088.75977, 8.13463783, - 488.559906, - 0.707134247, 0, 0.707079291, 0, 1, 0, - 0.707079291, 0, - 0.707134247)
        elseif _G.FindBoss == "Bobby" then
            bMon = "Bobby"
            Qname = "BuggyQuest1"
            Qdata = 3;
            PosQBoss = CFrame.new(- 1140.1761474609, 4.752049446106, 3827.4057617188)
            PosB = CFrame.new(- 1087.3760986328, 46.949409484863, 4040.1462402344)
        elseif _G.FindBoss == "The Saw" then
            bMon = "The Saw"
            PosB = CFrame.new(- 784.89715576172, 72.427383422852, 1603.5822753906)
        elseif _G.FindBoss == "Yeti" then
            bMon = "Yeti"
            Qname = "SnowQuest"
            Qdata = 3;
            PosQBoss = CFrame.new(1386.8073730469, 87.272789001465, - 1298.3576660156)
            PosB = CFrame.new(1218.7956542969, 138.01184082031, - 1488.0262451172)
        elseif _G.FindBoss == "Mob Leader" then
            bMon = "Mob Leader"
            PosB = CFrame.new(- 2844.7307128906, 7.4180502891541, 5356.6723632813)
        elseif _G.FindBoss == "Vice Admiral" then
            bMon = "Vice Admiral"
            Qname = "MarineQuest2"
            Qdata = 2;
            PosQBoss = CFrame.new(- 5036.2465820313, 28.677835464478, 4324.56640625)
            PosB = CFrame.new(- 5006.5454101563, 88.032081604004, 4353.162109375)
        elseif _G.FindBoss == "Saber Expert" then
            bMon = "Saber Expert"
            PosB = CFrame.new(- 1458.89502, 29.8870335, - 50.633564)
        elseif _G.FindBoss == "Warden" then
            bMon = "Warden"
            Qname = "ImpelQuest"
            Qdata = 1;
            PosB = CFrame.new(5278.04932, 2.15167475, 944.101929, 0.220546961, - 4.49946401e-06, 0.975376427, - 1.95412576e-05, 1, 9.03162072e-06, - 0.975376427, - 2.10519756e-05, 0.220546961)
            PosQBoss = CFrame.new(5191.86133, 2.84020686, 686.438721, - 0.731384635, 0, 0.681965172, 0, 1, 0, - 0.681965172, 0, - 0.731384635)
        elseif _G.FindBoss == "Chief Warden" then
            bMon = "Chief Warden"
            Qname = "ImpelQuest"
            Qdata = 2;
            PosB = CFrame.new(5206.92578, 0.997753382, 814.976746, 0.342041343, - 0.00062915677, 0.939684749, 0.00191645394, 0.999998152, - 2.80422337e-05, - 0.939682961, 0.00181045406, 0.342041939)
            PosQBoss = CFrame.new(5191.86133, 2.84020686, 686.438721, - 0.731384635, 0, 0.681965172, 0, 1, 0, - 0.681965172, 0, - 0.731384635)
        elseif _G.FindBoss == "Swan" then
            bMon = "Swan"
            Qname = "ImpelQuest"
            Qdata = 3;
            PosB = CFrame.new(5325.09619, 7.03906584, 719.570679, - 0.309060812, 0, 0.951042235, 0, 1, 0, - 0.951042235, 0, - 0.309060812)
            PosQBoss = CFrame.new(5191.86133, 2.84020686, 686.438721, - 0.731384635, 0, 0.681965172, 0, 1, 0, - 0.681965172, 0, - 0.731384635)
        elseif _G.FindBoss == "Magma Admiral" then
            bMon = "Magma Admiral"
            Qname = "MagmaQuest"
            Qdata = 3;
            PosQBoss = CFrame.new(- 5314.6220703125, 12.262420654297, 8517.279296875)
            PosB = CFrame.new(- 5765.8969726563, 82.92064666748, 8718.3046875)
        elseif _G.FindBoss == "Fishman Lord" then
            bMon = "Fishman Lord"
            Qname = "FishmanQuest"
            Qdata = 3;
            PosQBoss = CFrame.new(61122.65234375, 18.497442245483, 1569.3997802734)
            PosB = CFrame.new(61260.15234375, 30.950881958008, 1193.4329833984)
        elseif _G.FindBoss == "Wysper" then
            bMon = "Wysper"
            Qname = "SkyExp1Quest"
            Qdata = 3;
            PosQBoss = CFrame.new(- 7861.947265625, 5545.517578125, - 379.85974121094)
            PosB = CFrame.new(- 7866.1333007813, 5576.4311523438, - 546.74816894531)
        elseif _G.FindBoss == "Thunder God" then
            bMon = "Thunder God"
            Qname = "SkyExp2Quest"
            Qdata = 3;
            PosQBoss = CFrame.new(- 7903.3828125, 5635.9897460938, - 1410.923828125)
            PosB = CFrame.new(- 7994.984375, 5761.025390625, - 2088.6479492188)
        elseif _G.FindBoss == "Cyborg" then
            bMon = "Cyborg"
            Qname = "FountainQuest"
            Qdata = 3;
            PosQBoss = CFrame.new(5258.2788085938, 38.526931762695, 4050.044921875)
            PosB = CFrame.new(6094.0249023438, 73.770050048828, 3825.7348632813)
        elseif _G.FindBoss == "Ice Admiral" then
            bMon = "Ice Admiral"
            Qdata = nil;
            PosQBoss = CFrame.new(1266.08948, 26.1757946, - 1399.57678, - 0.573599219, 0, - 0.81913656, 0, 1, 0, 0.81913656, 0, - 0.573599219)
            PosB = CFrame.new(1266.08948, 26.1757946, - 1399.57678, - 0.573599219, 0, - 0.81913656, 0, 1, 0, 0.81913656, 0, - 0.573599219)
        elseif _G.FindBoss == "Greybeard" then
            bMon = "Greybeard"
            Qdata = nil;
            PosQBoss = CFrame.new(- 5081.3452148438, 85.221641540527, 4257.3588867188)
            PosB = CFrame.new(- 5081.3452148438, 85.221641540527, 4257.3588867188)
        end
    end;
    if World2 then
        if _G.FindBoss == "Diamond" then
            bMon = "Diamond"
            Qname = "Area1Quest"
            Qdata = 3;
            PosQBoss = CFrame.new(- 427.5666809082, 73.313781738281, 1835.4208984375)
            PosB = CFrame.new(- 1576.7166748047, 198.59265136719, 13.724286079407)
        elseif _G.FindBoss == "Jeremy" then
            bMon = "Jeremy"
            Qname = "Area2Quest"
            Qdata = 3;
            PosQBoss = CFrame.new(636.79943847656, 73.413787841797, 918.00415039063)
            PosB = CFrame.new(2006.9261474609, 448.95666503906, 853.98284912109)
        elseif _G.FindBoss == "Fajita" then
            bMon = "Fajita"
            Qname = "MarineQuest3"
            Qdata = 3;
            PosQBoss = CFrame.new(- 2441.986328125, 73.359344482422, - 3217.5324707031)
            PosB = CFrame.new(- 2172.7399902344, 103.32216644287, - 4015.025390625)
        elseif _G.FindBoss == "Don Swan" then
            bMon = "Don Swan"
            PosB = CFrame.new(2286.2004394531, 15.177839279175, 863.8388671875)
        elseif _G.FindBoss == "Smoke Admiral" then
            bMon = "Smoke Admiral"
            Qname = "IceSideQuest"
            Qdata = 3;
            PosQBoss = CFrame.new(- 5429.0473632813, 15.977565765381, - 5297.9614257813)
            PosB = CFrame.new(- 5275.1987304688, 20.757257461548, - 5260.6669921875)
        elseif _G.FindBoss == "Awakened Ice Admiral" then
            bMon = "Awakened Ice Admiral"
            Qname = "FrostQuest"
            Qdata = 3;
            PosQBoss = CFrame.new(5668.9780273438, 28.519989013672, - 6483.3520507813)
            PosB = CFrame.new(6403.5439453125, 340.29766845703, - 6894.5595703125)
        elseif _G.FindBoss == "Tide Keeper" then
            bMon = "Tide Keeper"
            Qname = "ForgottenQuest"
            Qdata = 3;
            PosQBoss = CFrame.new(- 3053.9814453125, 237.18954467773, - 10145.0390625)
            PosB = CFrame.new(- 3795.6423339844, 105.88877105713, - 11421.307617188)
        elseif _G.FindBoss == "Darkbeard" then
            bMon = "Darkbeard"
            Qdata = nil;
            PosQBoss = CFrame.new(3677.08203125, 62.751937866211, - 3144.8332519531)
            PosB = CFrame.new(3677.08203125, 62.751937866211, - 3144.8332519531)
        elseif _G.FindBoss == "Cursed Captaim" then
            bMon = "Cursed Captain"
            Qdata = nil;
            PosQBoss = CFrame.new(916.928589, 181.092773, 33422)
            PosB = CFrame.new(916.928589, 181.092773, 33422)
        elseif _G.FindBoss == "Order" then
            bMon = "Order"
            Qdata = nil;
            PosQBoss = CFrame.new(- 6217.2021484375, 28.047645568848, - 5053.1357421875)
            PosB = CFrame.new(- 6217.2021484375, 28.047645568848, - 5053.1357421875)
        end
    end;
    if World3 then
        if _G.FindBoss == "Stone" then
            bMon = "Stone"
            Qname = "PiratePortQuest"
            Qdata = 3;
            PosQBoss = CFrame.new(- 289.76705932617, 43.819011688232, 5579.9384765625)
            PosB = CFrame.new(- 1027.6512451172, 92.404174804688, 6578.8530273438)
        elseif _G.FindBoss == "Hydra Leader" then
            bMon = "Hydra Leader"
            Qname = "AmazonQuest2"
            Qdata = 3;
            PosQBoss = CFrame.new(5821.89794921875, 1019.0950927734375, - 73.71923065185547)
            PosB = CFrame.new(5821.89794921875, 1019.0950927734375, - 73.71923065185547)
        elseif _G.FindBoss == "Kilo Admiral" then
            bMon = "Kilo Admiral"
            Qname = "MarineTreeIsland"
            Qdata = 3;
            PosQBoss = CFrame.new(2179.3010253906, 28.731239318848, - 6739.9741210938)
            PosB = CFrame.new(2764.2233886719, 432.46154785156, - 7144.4580078125)
        elseif _G.FindBoss == "Captain Elephant" then
            bMon = "Captain Elephant"
            Qname = "DeepForestIsland"
            Qdata = 3;
            PosQBoss = CFrame.new(- 13232.682617188, 332.40396118164, - 7626.01171875)
            PosB = CFrame.new(- 13376.7578125, 433.28689575195, - 8071.392578125)
        elseif _G.FindBoss == "Beautiful Pirate" then
            bMon = "Beautiful Pirate"
            Qname = "DeepForestIsland2"
            Qdata = 3;
            PosQBoss = CFrame.new(- 12682.096679688, 390.88653564453, - 9902.1240234375)
            PosB = CFrame.new(5283.609375, 22.56223487854, - 110.78285217285)
        elseif _G.FindBoss == "Cake Queen" then
            bMon = "Cake Queen"
            Qname = "IceCreamIslandQuest"
            Qdata = 3;
            PosQBoss = CFrame.new(- 819.376709, 64.9259796, - 10967.2832, - 0.766061664, 0, 0.642767608, 0, 1, 0, - 0.642767608, 0, - 0.766061664)
            PosB = CFrame.new(- 678.648804, 381.353943, - 11114.2012, - 0.908641815, 0.00149294338, 0.41757378, 0.00837114919, 0.999857843, 0.0146408929, - 0.417492568, 0.0167988986, - 0.90852499)
        elseif _G.FindBoss == "Longma" then
            bMon = "Longma"
            Qdata = nil;
            PosQBoss = CFrame.new(- 10238.875976563, 389.7912902832, - 9549.7939453125)
            PosB = CFrame.new(- 10238.875976563, 389.7912902832, - 9549.7939453125)
        elseif _G.FindBoss == "Soul Reaper" then
            bMon = "Soul Reaper"
            Qdata = nil;
            PosQBoss = CFrame.new(- 9524.7890625, 315.80429077148, 6655.7192382813)
            PosB = CFrame.new(- 9524.7890625, 315.80429077148, 6655.7192382813)
        end
    end
end
QuestBeta = function()
    local Neta = QuestB()
    return {
        [0] = _G.FindBoss,
        [1] = bMon,
        [2] = Qdata,
        [3] = Qname,
        [4] = PosB
    }  
end
QuestCheck = function()
    local a = game.Players.LocalPlayer.Data.Level.Value;
    if World1 then
        if a == 1 or a <= 9 then
            if tostring(TeamSelf) == "Marines" then
                Mon = "Trainee"
                Qname = "MarineQuest"
                Qdata = 1;
                NameMon = "Trainee"
                PosM = CFrame.new(- 2709.67944, 24.5206585, 2104.24585, - 0.744724929, - 3.97967455e-08, - 0.667371571, 4.32403588e-08, 1, - 1.07884304e-07, 0.667371571, - 1.09201515e-07, - 0.744724929)
                PosQ = CFrame.new(- 2709.67944, 24.5206585, 2104.24585, - 0.744724929, - 3.97967455e-08, - 0.667371571, 4.32403588e-08, 1, - 1.07884304e-07, 0.667371571, - 1.09201515e-07, - 0.744724929)
            elseif tostring(TeamSelf) == "Pirates" then
                Mon = "Bandit"
                Qdata = 1;
                Qname = "BanditQuest1"
                NameMon = "Bandit"
                PosM = CFrame.new(1045.962646484375, 27.00250816345215, 1560.8203125)
                PosQ = CFrame.new(1045.962646484375, 27.00250816345215, 1560.8203125)
            end
        elseif a == 10 or a <= 14 then
            Mon = "Monkey"
            Qdata = 1;
            Qname = "JungleQuest"
            NameMon = "Monkey"
            PosQ = CFrame.new(- 1598.08911, 35.5501175, 153.377838, 0, 0, 1, 0, 1, - 0, - 1, 0, 0)
            PosM = CFrame.new(- 1448.51806640625, 67.85301208496094, 11.46579647064209)
        elseif a == 15 or a <= 29 then
            Mon = "Gorilla"
            Qdata = 2;
            Qname = "JungleQuest"
            NameMon = "Gorilla"
            PosQ = CFrame.new(- 1598.08911, 35.5501175, 153.377838, 0, 0, 1, 0, 1, - 0, - 1, 0, 0)
            PosM = CFrame.new(- 1129.8836669921875, 40.46354675292969, - 525.4237060546875)
        elseif a == 30 or a <= 39 then
            Mon = "Pirate"
            Qdata = 1;
            Qname = "BuggyQuest1"
            NameMon = "Pirate"
            PosQ = CFrame.new(- 1141.07483, 4.10001802, 3831.5498, 0.965929627, - 0, - 0.258804798, 0, 1, - 0, 0.258804798, 0, 0.965929627)
            PosM = CFrame.new(- 1103.513427734375, 13.752052307128906, 3896.091064453125)
        elseif a == 40 or a <= 59 then
            Mon = "Brute"
            Qdata = 2;
            Qname = "BuggyQuest1"
            NameMon = "Brute"
            PosQ = CFrame.new(- 1141.07483, 4.10001802, 3831.5498, 0.965929627, - 0, - 0.258804798, 0, 1, - 0, 0.258804798, 0, 0.965929627)
            PosM = CFrame.new(- 1140.083740234375, 14.809885025024414, 4322.92138671875)
        elseif a == 60 or a <= 74 then
            Mon = "Desert Bandit"
            Qdata = 1;
            Qname = "DesertQuest"
            NameMon = "Desert Bandit"
            PosQ = CFrame.new(894.488647, 5.14000702, 4392.43359, 0.819155693, - 0, - 0.573571265, 0, 1, - 0, 0.573571265, 0, 0.819155693)
            PosM = CFrame.new(924.7998046875, 6.44867467880249, 4481.5859375)
        elseif a == 75 or a <= 89 then
            Mon = "Desert Officer"
            Qdata = 2;
            Qname = "DesertQuest"
            NameMon = "Desert Officer"
            PosQ = CFrame.new(894.488647, 5.14000702, 4392.43359, 0.819155693, - 0, - 0.573571265, 0, 1, - 0, 0.573571265, 0, 0.819155693)
            PosM = CFrame.new(1608.2822265625, 8.614224433898926, 4371.00732421875)
        elseif a == 90 or a <= 99 then
            Mon = "Snow Bandit"
            Qdata = 1;
            Qname = "SnowQuest"
            NameMon = "Snow Bandit"
            PosQ = CFrame.new(1389.74451, 88.1519318, - 1298.90796, - 0.342042685, 0, 0.939684391, 0, 1, 0, - 0.939684391, 0, - 0.342042685)
     ...(truncated 363365 characters)...                    nameLabel.BackgroundTransparency = 1
                            nameLabel.TextStrokeTransparency = 0.5
                            nameLabel.TextColor3 = Color3.fromRGB(80, 245, 245)
                            nameLabel.Parent = nameEsp
                        end
                        local nameEsp = existingEsp and existingEsp:FindFirstChild("NameEsp")
                        if nameEsp then
                            local displayDistance = math.floor(distanceMagnitude / 3)
                            local chestName = Chest.Name:gsub("Label", "")
                            nameEsp.TextLabel.Text = string.format("[%s] %d M", chestName, displayDistance)
                        end
                        if _G_AutoFarmChest and distanceMagnitude <= 20 then
                            if existingEsp then
                                existingEsp:Destroy()
                            end
                        end
                    end
                end
                __DARKLUA_CONTINUE_507 = true
            until true
            if not __DARKLUA_CONTINUE_507 then
                break
            end
        end
    else
        for _, Chest in ipairs(game:GetService("CollectionService"):GetTagged("_ChestTagged")) do
            local espAttachment = Chest:FindFirstChild("ChestEspAttachment")
            if espAttachment then
                espAttachment:Destroy()
            end
        end
    end
end
berriesEsp = function()
    if BerryEsp then
        local CollectionService = game:GetService("CollectionService")
        local Players = game:GetService("Players")
        local Player = Players.LocalPlayer
        local BerryBushes = CollectionService:GetTagged("BerryBush")
        for _, Bush in ipairs(BerryBushes) do
            local bushPosition = Bush.Parent:GetPivot().Position
            for _, BerryName in pairs(Bush:GetAttributes()) do
                if BerryName and (not BerryArray or table.find(BerryArray, BerryName)) then
                    local espPartName = "BerryEspPart_" .. BerryName .. "_" .. tostring(bushPosition)
                    local existingEsp = workspace:FindFirstChild(espPartName)
                    if not existingEsp then
                        existingEsp = Instance.new("Part")
                        existingEsp.Name = espPartName
                        existingEsp.Transparency = 1
                        existingEsp.Size = Vector3.new(1, 1, 1)
                        existingEsp.Anchored = true
                        existingEsp.CanCollide = false
                        existingEsp.Parent = workspace
                        existingEsp.CFrame = CFrame.new(bushPosition)
                    end
                    if not existingEsp:FindFirstChild("NameEsp") then
                        local nameEsp = Instance.new("BillboardGui", existingEsp)
                        nameEsp.Name = "NameEsp"
                        nameEsp.ExtentsOffset = Vector3.new(0, 1, 0)
                        nameEsp.Size = UDim2.new(0, 200, 0, 30)
                        nameEsp.Adornee = existingEsp
                        nameEsp.AlwaysOnTop = true
                        local nameLabel = Instance.new("TextLabel", nameEsp)
                        nameLabel.Font = Enum.Font.Code
                        nameLabel.TextSize = 14
                        nameLabel.TextWrapped = true
                        nameLabel.Size = UDim2.new(1, 0, 1, 0)
                        nameLabel.TextYAlignment = Enum.TextYAlignment.Top
                        nameLabel.BackgroundTransparency = 1
                        nameLabel.TextStrokeTransparency = 0.5
                        nameLabel.TextColor3 = Color3.fromRGB(80, 245, 245)
                        nameLabel.Parent = nameEsp
                    end
                    local nameEsp = existingEsp:FindFirstChild("NameEsp")
                    local distance = (Player.Character.Head.Position - bushPosition).Magnitude / 3
                    nameEsp.TextLabel.Text = ('[' .. BerryName .. ']' .. " " .. math.round(distance) .. " M")
                    if _G.AutoBerry and math.round(distance) <= 20 then
                        existingEsp:Destroy()
                    end
                end
            end
        end
    else
        for _, v in ipairs(workspace:GetChildren()) do
            if v:IsA("Part") and v.Name:match("BerryEspPart_.*") then
                v:Destroy()
            end
        end
    end
end

Q = Tabs.Combat:AddToggle("Q", {
    Title = "Esp Berries",
    Description = "",
    Default = false
})
Q:OnChanged(function(Value)
    BerryEsp = Value
    while BerryEsp do
        wait()
        berriesEsp()
    end
end)

Q = Tabs.Combat:AddToggle("Q", {
    Title = "Esp Players",
    Description = "",
    Default = false
})
Q:OnChanged(function(Value)
    PlayerEsp = Value
    while PlayerEsp do
        wait()
        EspPly()
    end
end)

Q = Tabs.Combat:AddToggle("Q", {
    Title = "Esp Chests",
    Description = "",
    Default = false
})
Q:OnChanged(function(Value)
    ChestESP = Value
    while ChestESP do
        wait()
        ChestEsp()
    end
end)

Q = Tabs.Combat:AddToggle("Q", {
    Title = "Esp Fruits",
    Description = "",
    Default = false
})
Q:OnChanged(function(Value)
    DevilFruitESP = Value
    while DevilFruitESP do
        wait()
        DevEsp()
    end
end)

Q = Tabs.Combat:AddToggle("Q", {
    Title = "Esp Island Location",
    Description = "",
    Default = false
})
Q:OnChanged(function(Value)
    IslandESP = Value
    while IslandESP do
        wait()
        LocationEsp()
    end
end)

if World2 then
    Q = Tabs.Combat:AddToggle("Q", {
        Title = "Esp Flower",
        Description = "",
        Default = false
    })
    Q:OnChanged(function(Value)
        FlowerESP = Value
        while FlowerESP do
            wait()
            flowerEsp()
        end
    end)
    Q = Tabs.Combat:AddToggle("Q", {
        Title = "Esp Legendary Sword",
        Description = "",
        Default = false
    })
    Q:OnChanged(function(Value)
        LegenS = Value
        while LegenS do
            wait()
            LegenSword()
        end
    end)
end

if World2 or World3 then
    Q = Tabs.Combat:AddToggle("Q", {
        Title = "Esp Aura Colour Dealers",
        Description = "",
        Default = false
    })
    Q:OnChanged(function(Value)
        ColorEsp = Value
        while ColorEsp do
            wait()
            HakiClorEsp()
        end
    end)
end

if World3 then
    Q = Tabs.Combat:AddToggle("Q", {
        Title = "Esp Gears",
        Description = "",
        Default = false
    })
    Q:OnChanged(function(Value)
        ESPGear = Value
        while ESPGear do
            wait()
            gearEsp()
        end
    end)
    Q = Tabs.Combat:AddToggle("Q", {
        Title = "Esp SeaEvent Island",
        Description = "",
        Default = false
    })
    Q:OnChanged(function(Value)
        EspEventIsland = Value
        while EspEventIsland do
            wait()
            EventIslandEsp()
        end
    end)
    Q = Tabs.Combat:AddToggle("Q", {
        Title = "Esp Advanced Fruits Dealer",
        Description = "",
        Default = false
    })
    Q:OnChanged(function(Value)
        advanEsp = Value
        while advanEsp do
            wait()
            AdvanFruitEsp()
        end
    end)
end

Tabs.Travel:AddSection("Travel - Worlds")
Tabs.Travel:AddButton({
    Title = "Travel East Blue (World 1)",
    Description = "",
    Callback = function()
        replicated.Remotes.CommF_:InvokeServer("TravelMain")
    end
})
Tabs.Travel:AddButton({
    Title = "Travel Dressrosa (World 2)",
    Description = "",
    Callback = function()
        replicated.Remotes.CommF_:InvokeServer("TravelDressrosa")
    end
})
Tabs.Travel:AddButton({
    Title = "Travel Zou (World 3)",
    Description = "",
    Callback = function()
        replicated.Remotes.CommF_:InvokeServer("TravelZou")
    end
})
Tabs.Travel:AddSection("Travel - Island")
Location = {}
for i, v in pairs(workspace["_WorldOrigin"].Locations:GetChildren()) do
    table.insert(Location, v.Name)
end
Travelllll = Tabs.Travel:AddDropdown("Travelllll", {
    Title = "Select Travelling",
    Values = Location,
    Multi = false,
    Default = 1
})
Travelllll:OnChanged(function(Value)
    _G.Island = Value
end)
GoIsland = Tabs.Travel:AddToggle("GoIsland", {
    Title = "Auto Travel",
    Description = "Automatic teleport to pos island",
    Default = false
})
GoIsland:OnChanged(function(Value)
    _G.Teleport = Value
    if Value then
        for i, v in pairs(workspace["_WorldOrigin"].Locations:GetChildren()) do
            if v.Name == _G.Island then
                repeat
                    wait()
                    _tp(v.CFrame * CFrame.new(0, 30, 0))
                until not _G.Teleport or Root.CFrame == v.CFrame
            end
        end
    end
end)

Tabs.Travel:AddSection("Travel - Portal")
if World1 then
    Location_Portal = {
        "Sky",
        "UnderWater"
    }
elseif World2 then
    Location_Portal = {
        "SwanRoom",
        "Cursed Ship"
    }
elseif World3 then
    Location_Portal = {
        "Castle On The Sea",
        "Mansion Cafe",
        "Hydra Teleport",
        "Canvendish Room",
        "Temple of Time"
    }
end

PortalTP = Tabs.Travel:AddDropdown("PortalTP", {
    Title = "Select Portal",
    Values = Location_Portal,
    Multi = false,
    Default = 1
})
PortalTP:OnChanged(function(Value)
    _G.Island_PT = Value
end)
Tabs.Travel:AddButton({
    Title = "requestEntrance",
    Description = "",
    Callback = function()
        if _G.Island_PT == "Sky" then
            replicated.Remotes.CommF_:InvokeServer("requestEntrance", Vector3.new(- 7894, 5547, - 380))
        elseif _G.Island_PT == "UnderWater" then
            replicated.Remotes.CommF_:InvokeServer("requestEntrance", Vector3.new(61163, 11, 1819))
        elseif _G.Island_PT == "SwanRoom" then
            replicated.Remotes.CommF_:InvokeServer("requestEntrance", Vector3.new(2285, 15, 905))
        elseif _G.Island_PT == "Cursed Ship" then
            replicated.Remotes.CommF_:InvokeServer("requestEntrance", Vector3.new(923, 126, 32852))
        elseif _G.Island_PT == "Castle On The Sea" then
            replicated.Remotes.CommF_:InvokeServer("requestEntrance", Vector3.new(- 5097.93164, 316.447021, - 3142.66602, - 0.405007899, - 4.31682743e-08, 0.914313197, - 1.90943332e-08, 1, 3.8755779e-08, - 0.914313197, - 1.76180437e-09, - 0.405007899))
        elseif _G.Island_PT == "Mansion Cafe" then
            replicated.Remotes.CommF_:InvokeServer("requestEntrance", Vector3.new(- 12471.169921875, 374.94024658203, - 7551.677734375))
        elseif _G.Island_PT == "Hydra Teleport" then
            replicated.Remotes.CommF_:InvokeServer("requestEntrance", Vector3.new(5643.45263671875, 1013.0858154296875, - 340.51025390625))
        elseif _G.Island_PT == "Canvendish Room" then
            replicated.Remotes.CommF_:InvokeServer("requestEntrance", Vector3.new(5314.54638671875, 22.562219619750977, - 127.06755065917969))
        elseif _G.Island_PT == "Temple of Time" then
            replicated.Remotes.CommF_:InvokeServer("requestEntrance", Vector3.new(28310.0234, 14895.1123, 109.456741, - 0.469690144, - 2.85620132e-08, - 0.882831335, - 3.23509219e-08, 1, - 1.51411736e-08, 0.882831335, 2.14487486e-08, - 0.469690144))
        end
    end
})

Tabs.Travel:AddSection("Travel - NPCs")
for _, v in pairs(replicated.NPCs:GetChildren()) do
    table.insert(NPCList, v.Name)
end
NPCsPos = Tabs.Travel:AddDropdown("NPCsPos", {
    Title = "Select NPCs",
    Values = NPCList,
    Multi = false,
    Default = 1
})
NPCsPos:OnChanged(function(Value)
    NPClist = Value
end)
GoNPCs = Tabs.Travel:AddToggle("GoNPCs", {
    Title = "Auto Tween to NPCs",
    Description = "Automatic teleport to pos Npcs",
    Default = false
})
GoNPCs:OnChanged(function(Value)
    _G.TPNpc = Value
end)
spawn(function()
    while wait(Sec) do
        if _G.TPNpc then
            pcall(function()
                for __, v in pairs(replicated.NPCs:GetChildren()) do
                    if v.Name == NPClist then
                        _tp(v.HumanoidRootPart.CFrame)
                    end
                end
            end)
        end
    end
end)

Tabs.Fruit:AddSection("Fruits Options")
local fruitsOnSale = {}
local function addCommas(number)
    local formatted = tostring(number)
    while true do  
        formatted, k = formatted:gsub("^(-?%d+)(%d%d%d)", '%1,%2')
        if k == 0 then
            break
        end
    end
    return formatted
end
for _, fruitData in pairs(replicated.Remotes.CommF_:InvokeServer("GetFruits", true)) do
    if fruitData["OnSale"] == true then
        local priceWithCommas = addCommas(fruitData["Price"])
        local fruitInfo = fruitData["Name"]
        table.insert(fruitsOnSale, fruitInfo)
    end
end
local Nms = {}
for _, fruitData in pairs(replicated.Remotes.CommF_:InvokeServer("GetFruits", false)) do
    if fruitData["OnSale"] == true then
        local price = addCommas(fruitData["Price"])
        local NormalInFO = fruitData["Name"]
        table.insert(Nms, NormalInFO)
    end
end
Sel_NFruit = Tabs.Fruit:AddDropdown("Sel_NFruit", {
    Title = "Select Fruit Stock",
    Values = Nms,
    Multi = false,
    Default = 1
})
Sel_NFruit:OnChanged(function(Value)
    _G.SelectFruit = Value
end)
Tabs.Fruit:AddButton({
    Title = "Buy Basic Stock",
    Description = "",
    Callback = function()
        replicated.Remotes.CommF_:InvokeServer("PurchaseRawFruit", _G.SelectFruit)
    end
})
Sel_MFruit = Tabs.Fruit:AddDropdown("Sel_MFruit", {
    Title = "Select Mirage Fruit",
    Values = fruitsOnSale,
    Multi = false,
    Default = 1
})
Sel_MFruit:OnChanged(function(Value)
    SelectF_Adv = Value
end)
local Nms = {}
for _, fruitData in pairs(replicated.Remotes.CommF_:InvokeServer("GetFruits", false)) do
    if fruitData["OnSale"] == true then
        local price = addCommas(fruitData["Price"])
        local NormalInFO = fruitData["Name"]
        table.insert(Nms, NormalInFO)
    end
end
Tabs.Fruit:AddButton({
    Title = "Buy Mirage Stock",
    Description = "",
    Callback = function()
        replicated.Remotes.CommF_:InvokeServer("PurchaseRawFruit", SelectF_Adv)
    end
})
RandomFF = Tabs.Fruit:AddToggle("RandomFF", {
    Title = "Auto Random Fruit",
    Description = "Automatic random devil fruit",
    Default = false
})
RandomFF:OnChanged(function(Value)
    _G.Random_Auto = Value
end)
spawn(function()
    while wait(Sec) do
        pcall(function()
            if _G.Random_Auto then
                replicated.Remotes.CommF_:InvokeServer("Cousin", "Buy")
            end
        end)
    end
end)
DropF = Tabs.Fruit:AddToggle("DropF", {
    Title = "Auto Drop Fruit",
    Description = "Automatic drop devil fruit",
    Default = false
})
DropF:OnChanged(function(Value)
    _G.DropFruit = Value
end)
spawn(function()
    while wait(Sec) do
        if _G.DropFruit then
            pcall(function()
                DropFruits()
            end)
        end
    end
end)
StoredF = Tabs.Fruit:AddToggle("StoredF", {
    Title = "Auto Store Fruit",
    Description = "Automatic store devil fruit",
    Default = false
})
StoredF:OnChanged(function(Value)
    _G.StoreF = Value
end)
spawn(function()
    while wait(Sec) do
        if _G.StoreF then
            pcall(function()
                UpdStFruit()
            end)
        end
    end
end)
TwF = Tabs.Fruit:AddToggle("TwF", {
    Title = "Auto Tween to Fruit",
    Description = "Automatic tween to get devil fruit",
    Default = false
})
TwF:OnChanged(function(Value)
    _G.TwFruits = Value
end)
spawn(function()
    while wait(Sec) do
        if _G.TwFruits then
            pcall(function()
                for _, x1 in pairs(workspace:GetChildren()) do
                    if string.find(x1.Name, "Fruit") then
                        _tp(x1.Handle.CFrame)
                    end
                end
            end)
        end
    end
end)
BringF = Tabs.Fruit:AddToggle("BringF", {
    Title = "Auto Collect Fruit",
    Description = "Automatic bring devil fruit",
    Default = false
})
BringF:OnChanged(function(Value)
    _G.InstanceF = Value
end)
spawn(function()
    while wait(Sec) do
        if _G.InstanceF then
            pcall(function()
                collectFruits(_G.InstanceF)
            end)
        end
    end
end)

Tabs.Shop:AddSection("Shop Options")
Tabs.Shop:AddButton({
    Title = "Buy Buso",
    Description = "",
    Callback = function()
        replicated.Remotes.CommF_:InvokeServer("BuyHaki", "Buso")
    end
})
Tabs.Shop:AddButton({
    Title = "Buy Geppo",
    Description = "",
    Callback = function()
        replicated.Remotes.CommF_:InvokeServer("BuyHaki", "Geppo")
    end
})
Tabs.Shop:AddButton({
    Title = "Buy Soru",
    Description = "",
    Callback = function()
        replicated.Remotes.CommF_:InvokeServer("BuyHaki", "Soru")
    end
})
Tabs.Shop:AddButton({
    Title = "Buy Ken",
    Description = "",
    Callback = function()
        replicated.Remotes.CommF_:InvokeServer("KenTalk", "Buy")
    end
})

Tabs.Shop:AddSection("Fighting - Style")
Tabs.Shop:AddButton({
    Title = "Buy Black Leg",
    Description = "",
    Callback = function()
        replicated.Remotes.CommF_:InvokeServer("BuyBlackLeg")
    end
})
Tabs.Shop:AddButton({
    Title = "Buy Electro",
    Description = "",
    Callback = function()
        replicated.Remotes.CommF_:InvokeServer("BuyElectro")
    end
})
Tabs.Shop:AddButton({
    Title = "Buy Fishman Karate",
    Description = "",
    Callback = function()
        replicated.Remotes.CommF_:InvokeServer("BuyFishmanKarate")
    end
})
Tabs.Shop:AddButton({
    Title = "Buy DragonClaw",
    Description = "",
    Callback = function()
        replicated.Remotes.CommF_:InvokeServer("BlackbeardReward", "DragonClaw", "2")
    end
})
Tabs.Shop:AddButton({
    Title = "Buy Superhuman",
    Description = "",
    Callback = function()
        replicated.Remotes.CommF_:InvokeServer("BuySuperhuman")
    end
})
Tabs.Shop:AddButton({
    Title = "Buy Death Step",
    Description = "",
    Callback = function()
        replicated.Remotes.CommF_:InvokeServer("BuyDeathStep")
    end
})
Tabs.Shop:AddButton({
    Title = "Buy Sharkman Karate",
    Description = "",
    Callback = function()
        replicated.Remotes.CommF_:InvokeServer("BuySharkmanKarate")
    end
})
Tabs.Shop:AddButton({
    Title = "Buy ElectricClaw",
    Description = "",
    Callback = function()
        replicated.Remotes.CommF_:InvokeServer("BuyElectricClaw")
    end
})
Tabs.Shop:AddButton({
    Title = "Buy DragonTalon",
    Description = "",
    Callback = function()
        replicated.Remotes.CommF_:InvokeServer("BuyDragonTalon")
    end
})
Tabs.Shop:AddButton({
    Title = "Buy Godhuman",
    Description = "",
    Callback = function()
        replicated.Remotes.CommF_:InvokeServer("BuyGodhuman")
    end
})
Tabs.Shop:AddButton({
    Title = "Buy SanguineArt",
    Description = "",
    Callback = function()
        replicated.Remotes.CommF_:InvokeServer("BuySanguineArt")
    end
})

Tabs.Shop:AddSection("Accessory")
Tabs.Shop:AddButton({
    Title = "Buy Tomoe Ring",
    Description = "",
    Callback = function()
        replicated.Remotes.CommF_:InvokeServer("BuyItem", "Tomoe Ring")
    end
})
Tabs.Shop:AddButton({
    Title = "Buy Black Cape",
    Description = "",
    Callback = function()
        replicated.Remotes.CommF_:InvokeServer("BuyItem", "Black Cape")
    end
})
Tabs.Shop:AddButton({
    Title = "Buy Swordsman Hat",
    Description = "",
    Callback = function()
        replicated.Remotes.CommF_:InvokeServer("BuyItem", "Swordsman Hat")
    end
})
Tabs.Shop:AddButton({
    Title = "Buy Bizarre Rifle",
    Description = "",
    Callback = function()
        replicated.Remotes.CommF_:InvokeServer("Ectoplasm", "Buy", 1)
    end
})
Tabs.Shop:AddButton({
    Title = "Buy Ghoul Mask",
    Description = "",
    Callback = function()
        replicated.Remotes.CommF_:InvokeServer("Ectoplasm", "Buy", 2)
    end
})

Tabs.Shop:AddSection("Accessory SeaEvent")
Tabs.Shop:AddButton({
    Title = "Craft Dragonheart",
    Description = "",
    Callback = function()
        replicated.Remotes.CommF_:InvokeServer("CraftItem", "Craft", "Dragonheart");
    end
})
Tabs.Shop:AddButton({
    Title = "Craft Dragonstorm",
    Description = "",
    Callback = function()
        replicated.Remotes.CommF_:InvokeServer("CraftItem", "Craft", "Dragonstorm");
    end
})
Tabs.Shop:AddButton({
    Title = "Craft DinoHood",
    Description = "",
    Callback = function()
        replicated.Remotes.CommF_:InvokeServer("CraftItem", "Craft", "DinoHood");
    end
})   
Tabs.Shop:AddButton({
    Title = "Craft SharkTooth",
    Description = "",
    Callback = function()
        replicated.Remotes.CommF_:InvokeServer("CraftItem", "Craft", "SharkTooth");
    end
})   
Tabs.Shop:AddButton({
    Title = "Craft TerrorJaw",
    Description = "",
    Callback = function()
        replicated.Remotes.CommF_:InvokeServer("CraftItem", "Craft", "TerrorJaw");
    end
})   
Tabs.Shop:AddButton({
    Title = "Craft SharkAnchor",
    Description = "",
    Callback = function()
        replicated.Remotes.CommF_:InvokeServer("CraftItem", "Craft", "SharkAnchor");
    end
})   
Tabs.Shop:AddButton({
    Title = "Craft LeviathanCrown",
    Description = "",
    Callback = function()
        replicated.Remotes.CommF_:InvokeServer("CraftItem", "Craft", "LeviathanCrown");
    end
})   
Tabs.Shop:AddButton({
    Title = "Craft LeviathanShield",
    Description = "",
    Callback = function()
        replicated.Remotes.CommF_:InvokeServer("CraftItem", "Craft", "LeviathanShield");
    end
})   
Tabs.Shop:AddButton({
    Title = "Craft LeviathanBoat",
    Description = "",
    Callback = function()
        replicated.Remotes.CommF_:InvokeServer("CraftItem", "Craft", "LeviathanBoat");
    end
})   
Tabs.Shop:AddButton({
    Title = "Craft LegendaryScroll",
    Description = "",
    Callback = function()
        replicated.Remotes.CommF_:InvokeServer("CraftItem", "Craft", "LegendaryScroll");
    end
})   
Tabs.Shop:AddButton({
    Title = "Craft MythicalScroll",
    Description = "",
    Callback = function()
        replicated.Remotes.CommF_:InvokeServer("CraftItem", "Craft", "MythicalScroll");
    end
})   

Tabs.Shop:AddSection("Weapon World1")
Tabs.Shop:AddButton({
    Title = "Buy Cutlass",
    Description = "",
    Callback = function()
        replicated.Remotes.CommF_:InvokeServer("BuyItem", "Cutlass")
    end
})
Tabs.Shop:AddButton({
    Title = "Buy Katana",
    Description = "",
    Callback = function()
        replicated.Remotes.CommF_:InvokeServer("BuyItem", "Katana")
    end
})
Tabs.Shop:AddButton({
    Title = "Buy Iron Mace",
    Description = "",
    Callback = function()
        replicated.Remotes.CommF_:InvokeServer("BuyItem", "Iron Mace")
    end
})   
Tabs.Shop:AddButton({
    Title = "Buy Duel Katana",
    Description = "",
    Callback = function()
        replicated.Remotes.CommF_:InvokeServer("BuyItem", "Duel Katana")
    end
})   
Tabs.Shop:AddButton({
    Title = "Buy Triple Katana",
    Description = "",
    Callback = function()
        replicated.Remotes.CommF_:InvokeServer("BuyItem", "Triple Katana")
    end
})  
Tabs.Shop:AddButton({
    Title = "Buy Pipe",
    Description = "",
    Callback = function()
        replicated.Remotes.CommF_:InvokeServer("BuyItem", "Pipe")
    end
})  
Tabs.Shop:AddButton({
    Title = "Buy Dual-Headed Blade",
    Description = "",
    Callback = function()
        replicated.Remotes.CommF_:InvokeServer("BuyItem", "Dual-Headed Blade")
    end
})   
Tabs.Shop:AddButton({
    Title = "Buy Bisento",
    Description = "",
    Callback = function()
        replicated.Remotes.CommF_:InvokeServer("BuyItem", "Bisento")
    end
})  
Tabs.Shop:AddButton({
    Title = "Buy Soul Cane",
    Description = "",
    Callback = function()
        replicated.Remotes.CommF_:InvokeServer("BuyItem", "Soul Cane")
    end
})
Tabs.Shop:AddButton({
    Title = "Buy Slingshot",
    Description = "",
    Callback = function()
        replicated.Remotes.CommF_:InvokeServer("BuyItem", "Slingshot")
    end
})
Tabs.Shop:AddButton({
    Title = "Buy Musket",
    Description = "",
    Callback = function()
        replicated.Remotes.CommF_:InvokeServer("BuyItem", "Musket")
    end
})    
Tabs.Shop:AddButton({
    Title = "Buy Dual Flintlock",
    Description = "",
    Callback = function()
        replicated.Remotes.CommF_:InvokeServer("BuyItem", "Dual Flintlock")
    end
})   
Tabs.Shop:AddButton({
    Title = "Buy Flintlock",
    Description = "",
    Callback = function()
        replicated.Remotes.CommF_:InvokeServer("BuyItem", "Flintlock")
    end
})   
Tabs.Shop:AddButton({
    Title = "Buy Refined Flintlock",
    Description = "",
    Callback = function()
        replicated.Remotes.CommF_:InvokeServer("BuyItem", "Refined Flintlock")
    end
})   
Tabs.Shop:AddButton({
    Title = "Buy Cannon",
    Description = "",
    Callback = function()
        replicated.Remotes.CommF_:InvokeServer("BuyItem", "Cannon")
    end
}) 
Tabs.Shop:AddButton({
    Title = "Buy Kabucha",
    Description = "",
    Callback = function()
        replicated.Remotes.CommF_:InvokeServer("BlackbeardReward", "Slingshot", "2")
    end
})

Tabs.Shop:AddSection("Fragments shop")
Tabs.Shop:AddButton({
    Title = "Buy Refund Stats",
    Description = "",
    Callback = function()
        replicated.Remotes.CommF_:InvokeServer("BlackbeardReward", "Refund", "2")
    end
})
Tabs.Shop:AddButton({
    Title = "Buy Reroll Race",
    Description = "",
    Callback = function()
        replicated.Remotes.CommF_:InvokeServer("BlackbeardReward", "Reroll", "2")
    end
})   
Tabs.Shop:AddButton({
    Title = "Buy Ghoul Race (2.5k)",
    Description = "",
    Callback = function()
        replicated.Remotes.CommF_:InvokeServer("Ectoplasm", " Change", 4)
    end
})	
Tabs.Shop:AddButton({
    Title = "Buy Cyborg Race (2.5k)",
    Description = "",
    Callback = function()
        replicated.Remotes.CommF_:InvokeServer("CyborgTrainer", " Buy")
    end
})

Tabs.Misc:AddSection("Server - Function")
Tabs.Misc:AddButton({
    Title = "Rejoin Server",
    Description = "",
    Callback = function()
        game:GetService("TeleportService"):Teleport(game.PlaceId, game.Players.LocalPlayer)
    end
})
Tabs.Misc:AddButton({
    Title = "Hop Server",
    Description = "",
    Callback = function()
        Hop()
    end
})
Tabs.Misc:AddButton({
    Title = "Hop to Lowest Players",
    Description = "",
    Callback = function()
        local Http = game:GetService("HttpService")
        local TPS = game:GetService("TeleportService")
        local Api = "https://games.roblox.com/v1/games/"
        local _place = game.PlaceId
        local _servers = Api .. _place .. "/servers/Public?sortOrder=Asc&limit=100"
        function ListServers(cursor)
            local Raw = game:HttpGet(_servers .. ((cursor and "&cursor=" .. cursor) or ""))
            return Http:JSONDecode(Raw)
        end
        local Server, Next;
        repeat
            local Servers = ListServers(Next)
            Server = Servers.data[1]
            Next = Servers.nextPageCursor
        until Server
        TPS:TeleportToPlaceInstance(_place, Server.id, plr)
    end
})

Tabs.Misc:AddButton({
    Title = "Hop to Lowest Pings Server",
    Description = "",
    Callback = function()
        local HTTPService = game:GetService("HttpService")
        local TeleportService = game:GetService("TeleportService")
        local StatsService = game:GetService("Stats")
        local function fetchServersData(placeId, limit)
            local url = string.format("https://games.roblox.com/v1/games/%d/servers/Public?limit=%d", placeId, limit)
            local success, response = pcall(function()
                return HTTPService:JSONDecode(game:HttpGet(url))
            end)
            if success and response and response.data then
                return response.data
            end
            return nil
        end
        local placeId = game.PlaceId
        local serverLimit = 100
        local servers = fetchServersData(placeId, serverLimit)
        if not servers then
            return
        end
        local lowestPingServer = servers[1]
        for _, server in pairs(servers) do
            if server["ping"] < lowestPingServer["ping"] and server.maxPlayers > server.playing then
                lowestPingServer = server
            end
        end
        local commonLoadTime = 0.5
        task.wait(commonLoadTime)
        local pingThreshold = 100
        local serverStats = StatsService.Network.ServerStatsItem
        local dataPing = serverStats["Data Ping"]:GetValueString()
        local pingValue = tonumber(dataPing:match("(%d+)"))
        if pingValue >= pingThreshold then
            TeleportService:TeleportToPlaceInstance(placeId, lowestPingServer.id)
        else
    --pings
        end
    end
})

local JobID = Tabs.Misc:AddInput("JobID", {
    Title = "JobID",
    Default = "",
    Placeholder = "",
    Numeric = false, -- Only allows numbers
    Finished = false, -- Only calls callback when you press enter
    Callback = function(Value)
        _G.JobId = Value
    end
})
spawn(function()
    while wait(Sec) do
        if _G.JobId then
            pcall(function()
                local Connection
                Connection = plr.OnTeleport:Connect(function(br)
                    if br == Enum.TeleportState.Failed then
                        Connection:Disconnect()
                        if workspace:FindFirstChild("Message") then
                            workspace.Message:Destroy()
                        end
                    end
                end)
            end)
        end
    end
end)

Tabs.Misc:AddButton({
    Title = "Teleport [Job ID]",
    Description = "",
    Callback = function()
        replicated['__ServerBrowser']:InvokeServer("teleport", _G.JobId)
    end
})
Tabs.Misc:AddButton({
    Title = "Copy JobID",
    Description = "",
    Callback = function()
        setclipboard(tostring(game.JobId))
    end
})

Tabs.Misc:AddSection("Player Gui / Others")

Tabs.Misc:AddButton({
    Title = "Open Awakenings Expert",
    Description = "",
    Callback = function()
        plr.PlayerGui.Main.AwakeningToggler.Visible = true
    end
})
Tabs.Misc:AddButton({
    Title = "Open Title Selection",
    Description = "",
    Callback = function()
        replicated.Remotes.CommF_:InvokeServer("getTitles", true)
        plr.PlayerGui.Main.Titles.Visible = true
    end
})
DisbleChat = Tabs.Misc:AddToggle("DisbleChat", {
    Title = "Disable Chat GUI",
    Description = "",
    Default = false
})
DisbleChat:OnChanged(function(Value)
    _G.Rechat = Value
    if _G.Rechat == true then
        local StarterGui = game:GetService('StarterGui')
        StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Chat, false)
    elseif _G.chat == false then
        local StarterGui = game:GetService('StarterGui')
        StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Chat, true)
    end
end)
DisbleLeaderB = Tabs.Misc:AddToggle("DisbleLeaderB", {
    Title = "Disable Leader Board GUI",
    Description = "",
    Default = false
})
DisbleLeaderB:OnChanged(function(Value)
    ReLeader = Value
    if ReLeader == true then
        local StarterGui = game:GetService('StarterGui')
        StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, false)
    elseif ReLeader == false then
        local StarterGui = game:GetService('StarterGui')
        StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, true)
    end
end)
Tabs.Misc:AddButton({
    Title = "Set Pirate Team",
    Description = "",
    Callback = function()
        Pirates()
    end
})  
Tabs.Misc:AddButton({
    Title = "Set Marine Team",
    Description = "",
    Callback = function()
        Marines()
    end
})
UnPortal = Tabs.Misc:AddToggle("UnPortal", {
    Title = "Unlock All Portals",
    Description = "unlocked portal for who doesn't defeat rip_indra",
    Default = false
})
UnPortal:OnChanged(function(Value)
    _G.PortalUnLock = Value
end)
spawn(function()
    while wait(Sec) do
        pcall(function()
            if _G.PortalUnLock then
                if Attack.Pos(CstlePos_Miti, 8) then
                    replicated.Remotes.CommF_:InvokeServer("requestEntrance", Vector3.new(- 12471.169921875, 374.94024658203, - 7551.677734375))
                elseif Attack.Pos(Man3Pos_Miti, 8) then
                    replicated.Remotes.CommF_:InvokeServer("requestEntrance", Vector3.new(- 5072.08984375, 314.5412902832, - 3151.1098632812))
                elseif Attack.Pos(HydraPos_Miti, 8) then
                    replicated.Remotes.CommF_:InvokeServer("requestEntrance", Vector3.new(5748.7587890625, 610.44982910156, - 267.81704711914))
                elseif Attack.Pos(HydratoCastle, 8) then
                    replicated.Remotes.CommF_:InvokeServer("requestEntrance", Vector3.new(- 5072.08984375, 314.5412902832, - 3151.1098632812))
                end
            end
        end)
    end
end)

Tabs.Misc:AddSection("Graphics / Haki Stats")

HakiSt = {
    "State 0",
    "State 1",
    "State 2",
    "State 3",
    "State 4",
    "State 5"
}
HakiStat = Tabs.Misc:AddDropdown("HakiStat", {
    Title = "Select Haki States",
    Values = HakiSt,
    Multi = false,
    Default = 1
})
HakiStat:OnChanged(function(Value)
    _G.SelectStateHaki = Value
end)
Tabs.Misc:AddButton({
    Title = "ChangeBusoStage",
    Description = "",
    Callback = function()
        if _G.SelectStateHaki == "State 0" then
            replicated.Remotes.CommF_:InvokeServer("ChangeBusoStage", 0)
        elseif _G.SelectStateHaki == "State 1" then
            replicated.Remotes.CommF_:InvokeServer("ChangeBusoStage", 1)
        elseif _G.SelectStateHaki == "State 2" then
            replicated.Remotes.CommF_:InvokeServer("ChangeBusoStage", 2)
        elseif _G.SelectStateHaki == "State 3" then
            replicated.Remotes.CommF_:InvokeServer("ChangeBusoStage", 3)
        elseif _G.SelectStateHaki == "State 4" then
            replicated.Remotes.CommF_:InvokeServer("ChangeBusoStage", 4)
        elseif _G.SelectStateHaki == "State 5" then
            replicated.Remotes.CommF_:InvokeServer("ChangeBusoStage", 5)
        end
    end
})
rtxM = Tabs.Misc:AddToggle("rtxM", {
    Title = "Turn on RTX Mode",
    Description = "",
    Default = false
})
rtxM:OnChanged(function(Value)
    _G.RTXMode = Value
    local a = game.Lighting
    local c = Instance.new("ColorCorrectionEffect", a)
    local e = Instance.new("ColorCorrectionEffect", a)
    OldAmbient = a.Ambient
    OldBrightness = a.Brightness
    OldColorShift_Top = a.ColorShift_Top
    OldBrightnessc = c.Brightness
    OldContrastc = c.Contrast
    OldTintColorc = c.TintColor
    OldTintColore = e.TintColor
    if not _G.RTXMode then
        return
    end
    while _G.RTXMode do
        wait()
        a.Ambient = Color3.fromRGB(33, 33, 33)
        a.Brightness = 0.3
        c.Brightness = 0.176
        c.Contrast = 0.39
        c.TintColor = Color3.fromRGB(217, 145, 57)
        game.Lighting.FogEnd = 999
        if not plr.Character.HumanoidRootPart:FindFirstChild("PointLight") then
            local a2 = Instance.new("PointLight")
            a2.Parent = plr.Character.HumanoidRootPart
            a2.Range = 15
            a2.Color = Color3.fromRGB(217, 145, 57)
        end
        if not _G.RTXMode then
            a.Ambient = OldAmbient
            a.Brightness = OldBrightness
            a.ColorShift_Top = OldColorShift_Top
            c.Contrast = OldContrastc
            c.Brightness = OldBrightnessc
            c.TintColor = OldTintColorc
            e.TintColor = OldTintColore
            game.Lighting.FogEnd = 2500
            plr.Character.HumanoidRootPart:FindFirstChild("PointLight"):Destroy()
        end
    end
end)
Tabs.Misc:AddButton({
    Title = "Turn on Fast Mode",
    Description = "",
    Callback = function()
        for _, zx in next, workspace:GetDescendants() do
            if table.find(Past, zx.ClassName) then
                zx.Material = "Plastic"
            end
        end
    end
})
Tabs.Misc:AddButton({
    Title = "Turn on Low CPU",
    Description = "",
    Callback = function()
        LowCpu()
    end
})
Tabs.Misc:AddButton({
    Title = "Turn on increase Boats",
    Description = "",
    Callback = function()
        for _, v in pairs(workspace.Boats:GetDescendants()) do
            if table.find(ListSeaBoat, v.Name) and tostring(v.Owner.Value) == tostring(plr.Name) then
                v.VehicleSeat.MaxSpeed = 350
                v.VehicleSeat.Torque = 0.2
                v.VehicleSeat.TurnSpeed = 5
                v.VehicleSeat.HeadsUpDisplay = true
            end
        end
    end
})
Tabs.Misc:AddButton({
    Title = "Remove Sky Fog",
    Description = "",
    Callback = function()
        if Lighting:FindFirstChild("LightingLayers") then
            Lighting.LightingLayers:Destroy()
        end
        if Lighting:FindFirstChild("SeaTerrorCC") then
            Lighting.SeaTerrorCC:Destroy()
        end
        if Lighting:FindFirstChild("FantasySky") then
            Lighting.FantasySky:Destroy()
        end
    end
})

Tabs.Misc:AddSection("Configure - God")
Tabs.Misc:AddButton({
    Title = "Rain Fruits (Client)",
    Description = "",
    Callback = function()
        for i, v in pairs(game:GetObjects("rbxassetid://14759368201")[1]:GetChildren()) do
            v.Parent = game.Workspace.Map
            v:MoveTo(plr.Character.PrimaryPart.Position + Vector3.new(math.random(- 50, 50), 100, math.random(- 50, 50)))
            if v.Fruit:FindFirstChild("AnimationController") then
                v.Fruit:FindFirstChild("AnimationController"):LoadAnimation(v.Fruit:FindFirstChild("Idle")):Play()
            end
            v.Handle.Touched:Connect(function(otherPart)
                if otherPart.Parent == plr.Character then
                    v.Parent = plr.Backpack
                    plr.Character.Humanoid:EquipTool(v)
                end
            end)
        end
    end
})
briggt1 = Tabs.Misc:AddToggle("briggt1", {
    Title = "Turn on Full Bright",
    Description = "",
    Default = false
})
briggt1:OnChanged(function(Value)
    bright = Value
    if Value == true then
        Lighting.Ambient = Color3.new(1, 1, 1)
        Lighting.ColorShift_Bottom = Color3.new(1, 1, 1)
        Lighting.ColorShift_Top = Color3.new(1, 1, 1)
    else
        Lighting.Ambient = Color3.new(0, 0, 0)
        Lighting.ColorShift_Bottom = Color3.new(0, 0, 0)
        Lighting.ColorShift_Top = Color3.new(0, 0, 0)
    end  
end)

Cheat_DayNight = {
    "Day",
    "Night"
}
DayN = Tabs.Misc:AddDropdown("DayN", {
    Title = "Select Time",
    Values = Cheat_DayNight,
    Multi = false,
    Default = 1
})
DayN:OnChanged(function(Value)
    _G.SelectDN = Value
end)
dayornight = Tabs.Misc:AddToggle("dayornight", {
    Title = "Turn on Time",
    Description = "",
    Default = false
})
dayornight:OnChanged(function(Value)
    _G.daylightN = Value
end)
task.spawn(function()
    while task.wait() do
        if _G.daylightN then
            if _G.SelectDN == "Day" then
                Lighting.ClockTime = 12
            elseif _G.SelectDN == "Night" then
                Lighting.ClockTime = 0
            end
        end
    end
end)
walkWater = Tabs.Misc:AddToggle("walkWater", {
    Title = "Turn on Walk on Water",
    Description = "walk on water",
    Default = true
})
walkWater:OnChanged(function(Value)
    _G.WalkWater_Part = Value
    if _G.WalkWater_Part then
        game:GetService("Workspace").Map["WaterBase-Plane"].Size = Vector3.new(1000, 112, 1000)
    else
        game:GetService("Workspace").Map["WaterBase-Plane"].Size = Vector3.new(1000, 80, 1000)
    end
end)
iceWalk = Tabs.Misc:AddToggle("iceWalk", {
    Title = "Turn on Ice Walk",
    Description = "Ice walk just like walk on water but have ice effect",
    Default = false
})
iceWalk:OnChanged(function(Value)
    _G.WalkWater = Value
end)
spawn(function()
    while task.wait() do
        if _G.WalkWater then
            pcall(function()
                if plr.Character and plr.Character:FindFirstChild("LeftFoot") then
                    local upval0 = replicated.Assets.Models.IceSpikes4:Clone()
                    upval0.Parent = workspace
                    upval0.Size = Vector3.new(3 + math.random(10, 12), 1.7, 3 + math.random(10, 12))
                    upval0.Color = Color3.fromRGB(128, 187, 219)
                    upval0.CFrame = CFrame.new(plr.Character.Head.Position.X, - 3.8, plr.Character.Head.Position.Z) * CFrame.Angles((math.random() - 0.5) * 0.06, math.random() * 7, (math.random() - 0.5) * 0.07)
                    local var85 = {};
                    var85.Size = Vector3.new(0, 0.3, 0)
                    local var3 = TW:Create(upval0, TweenInfo.new(2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), var85)
                    var3.Completed:Connect(function()
                        upval0:Destroy()
                    end)
                    var3:Play()
                end
            end)
        end
    end
end)
local player = game.Players.LocalPlayer
local function IsEntityAlive(entity)
    if not entity then
        return false
    end
    local humanoid = entity:FindFirstChild("Humanoid")
    return humanoid and humanoid.Health > 0
end
local function GetEnemiesInRange(character, range)
    local enemies = game:GetService("Workspace").Enemies:GetChildren()
    local players = game:GetService("Players"):GetPlayers()
    local targets = {}
    local playerPos = character:GetPivot().Position
    for _, enemy in ipairs(enemies) do
        local rootPart = enemy:FindFirstChild("HumanoidRootPart")
        if rootPart and IsEntityAlive(enemy) then
            local distance = (rootPart.Position - playerPos).Magnitude
            if distance <= range then
                table.insert(targets, enemy)
            end
        end
    end
    for _, otherPlayer in ipairs(players) do
        if otherPlayer ~= player and otherPlayer.Character then
            local rootPart = otherPlayer.Character:FindFirstChild("HumanoidRootPart")
            if rootPart and IsEntityAlive(otherPlayer.Character) then
                local distance = (rootPart.Position - playerPos).Magnitude
                if distance <= range then
                    table.insert(targets, otherPlayer.Character)
                end
            end
        end
    end
    return targets
end
function AttackNoCoolDown()
    local player = game:GetService("Players").LocalPlayer
    local character = player.Character
    if not character then
        return
    end
    local equippedWeapon = nil
    for _, item in ipairs(character:GetChildren()) do
        if item:IsA("Tool") then
            equippedWeapon = item
            break
        end
    end
    if not equippedWeapon then
        return
    end
    local enemiesInRange = GetEnemiesInRange(character, 60)
    if # enemiesInRange == 0 then
        return
    end
    local storage = game:GetService("ReplicatedStorage")
    local modules = storage:FindFirstChild("Modules")
    if not modules then
        return
    end
    local attackEvent = storage:WaitForChild("Modules"):WaitForChild("Net"):WaitForChild("RE/RegisterAttack")
    local hitEvent = storage:WaitForChild("Modules"):WaitForChild("Net"):WaitForChild("RE/RegisterHit")
    if not attackEvent or not hitEvent then
        return
    end
    local targets, mainTarget = {}, nil
    for _, enemy in ipairs(enemiesInRange) do
        if not enemy:GetAttribute("IsBoat") then
            local HitboxLimbs = {
                "RightLowerArm",
                "RightUpperArm",
                "LeftLowerArm",
                "LeftUpperArm",
                "RightHand",
                "LeftHand"
            }
            local head = enemy:FindFirstChild(HitboxLimbs[math.random(# HitboxLimbs)]) or enemy.PrimaryPart
            if head then
                table.insert(targets, {
                    enemy,
                    head
                })
                mainTarget = head
            end
        end
    end
    if not mainTarget then
        return
    end
    attackEvent:FireServer(0)
    local playerScripts = player:FindFirstChild("PlayerScripts")
    if not playerScripts then
        return
    end
    local localScript = playerScripts:FindFirstChildOfClass("LocalScript")
    while not localScript do
        playerScripts.ChildAdded:Wait()
        localScript = playerScripts:FindFirstChildOfClass("LocalScript")
    end
    local hitFunction
    if getsenv then
        local success, scriptEnv = pcall(getsenv, localScript)
        if success and scriptEnv then
            hitFunction = scriptEnv._G.SendHitsToServer
        end
    end
    local successFlags, combatRemoteThread = pcall(function()
        return require(modules.Flags).COMBAT_REMOTE_THREAD or false
    end)
    if successFlags and combatRemoteThread and hitFunction then
        hitFunction(mainTarget, targets)
    elseif successFlags and not combatRemoteThread then
        hitEvent:FireServer(mainTarget, targets)
    end
end
CameraShakerR = require(game.ReplicatedStorage.Util.CameraShaker)
CameraShakerR:Stop()
get_Monster = function()
    for a, b in pairs(workspace.Enemies:GetChildren()) do
        local c = b:FindFirstChild("UpperTorso") or b:FindFirstChild("Head")
        if b:FindFirstChild("HumanoidRootPart", true) and c then
            if (b.Head.Position - plr.Character.HumanoidRootPart.Position).Magnitude <= 50 then
                return true, c.Position
            end
        end
    end;
    for a, d in pairs(workspace.SeaBeasts:GetChildren()) do
        if d:FindFirstChild("HumanoidRootPart") and d:FindFirstChild("Health") and d.Health.Value > 0 then
            return true, d.HumanoidRootPart.Position
        end
    end;
    for a, d in pairs(workspace.Enemies:GetChildren()) do
        if d:FindFirstChild("Health") and d.Health.Value > 0 and d:FindFirstChild("VehicleSeat") then
            return true, d.Engine.Position
        end
    end
end
Actived = function()
    local a = game.Players.LocalPlayer.Character:FindFirstChildOfClass("Tool")
    for b, c in next, getconnections(a.Activated) do
        if typeof(c.Function) == 'function' then
            getupvalues(c.Function)
        end
    end
end
task.spawn(function()
    RunSer.Heartbeat:Connect(function()
        pcall(function()
            if not _G.Seriality then
                return
            end
            AttackNoCoolDown()
            local Pretool = game.Players.LocalPlayer.Character:FindFirstChildOfClass("Tool")
            local ToolTip = Pretool.ToolTip
            local MobAura, Mon = get_Monster()
            if ToolTip == "Blox Fruit" then
                if MobAura then
                    local LeftClickRemote = Pretool:FindFirstChild('LeftClickRemote');
                    if LeftClickRemote then
                        Actived()
                        LeftClickRemote:FireServer(Vector3.new(0.01, - 500, 0.01), 1, true);
                        LeftClickRemote:FireServer(false)
                    end
                end
            end
        end)
    end)
end)
Window:SelectTab(1)
local ScreenGui = Instance.new("ScreenGui");
local ImageButton = Instance.new("ImageButton");
local UICorner = Instance.new("UICorner");
local ParticleEmitter = Instance.new("ParticleEmitter");
local TweenService = game:GetService("TweenService");
ScreenGui.Parent = game.CoreGui;
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling;
ImageButton.Parent = ScreenGui;
ImageButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0);
ImageButton.BorderSizePixel = 0;
ImageButton.Position = UDim2.new(0.120833337 - 0.1, 0, 0.0952890813 + 0.01, 0);
ImageButton.Size = UDim2.new(0, 50, 0, 50);
ImageButton.Draggable = true;
ImageButton.Image = "http://www.roblox.com/asset/?id=Id Ảnh";
UICorner.Parent = ImageButton;
UICorner.CornerRadius = UDim.new(0, 12);
ParticleEmitter.Parent = ImageButton;
ParticleEmitter.LightEmission = 1;
ParticleEmitter.Size = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.1),NumberSequenceKeypoint.new(1, 0)});
ParticleEmitter.Lifetime = NumberRange.new(0.5, 1);
ParticleEmitter.Rate = 0;
ParticleEmitter.Speed = NumberRange.new(5, 10);
ParticleEmitter.Color = ColorSequence.new(Color3.fromRGB(255, 85, 255), Color3.fromRGB(85, 255, 255));
local rotateTween = TweenService:Create(ImageButton, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Rotation=360});
ImageButton.MouseButton1Down:Connect(function()
	game:GetService("VirtualInputManager"):SendKeyEvent(true, Enum.KeyCode.End, false, game);
end);
