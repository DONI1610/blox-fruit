-- ========================================
-- AUTO TEAM PIRATES
-- ========================================
local desiredTeam = "Pirates"  -- Đổi từ Marines thành Pirates

if not player.Team or player.Team.Name ~= desiredTeam then
    pcall(function()
        ReplicatedStorage.Remotes.CommF_:InvokeServer("SetTeam", desiredTeam)
    end)
end

-- ========================================
-- AUTO COLLECT FRUIT (Teleport to fruit)
-- ========================================
_G.AutoCollectFruit = false
_G.AutoHopWhenNoFruit = false

-- Hàm thu thập trái cây bằng cách teleport đến chỗ nó
collectFruitsTeleport = function()
    local character = plr.Character
    if not character then return end
    
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    local fruitsFound = false
    
    for _, obj in pairs(workspace:GetChildren()) do
        if string.find(obj.Name, "Fruit") and obj:FindFirstChild("Handle") then
            fruitsFound = true
            -- Teleport đến vị trí trái cây
            _tp(obj.Handle.CFrame * CFrame.new(0, 3, 0))  -- Dịch chuyển đến
            wait(0.5)  -- Chờ một chút để nhặt
            -- Kích hoạt nhặt (nếu cần)
            if obj.Handle:FindFirstChild("ClickDetector") then
                fireclickdetector(obj.Handle.ClickDetector)
            end
        end
    end
    
    return fruitsFound
end

-- Hàm hop server
Hop = function()
    pcall(function()
        for i = math.random(1, math.random(40, 75)), 100, 1 do
            local servers = replicated.__ServerBrowser:InvokeServer(i)
            for id, info in next, servers do
                if tonumber(info.Count) < 12 then
                    TeleportService:TeleportToPlaceInstance(game.PlaceId, id)
                    return
                end
            end
        end
    end)
end

-- Loop chính
task.spawn(function()
    while task.wait(2) do  -- Kiểm tra mỗi 2 giây
        if _G.AutoCollectFruit then
            local found = collectFruitsTeleport()
            
            -- Nếu không tìm thấy trái cây và bật auto hop
            if not found and _G.AutoHopWhenNoFruit then
                wait(1)
                Hop()
            end
        end
    end
end)

-- ========================================
-- AUTO STORE FRUIT
-- ========================================
UpdStFruit = function()
    for _, item in next, plr.Backpack:GetChildren() do
        local eatRemote = item:FindFirstChild("EatRemote", true)
        if eatRemote then
            replicated.Remotes.CommF_:InvokeServer(
                "StoreFruit", 
                eatRemote.Parent:GetAttribute("OriginalName"), 
                plr.Backpack:FindFirstChild(item.Name)
            )
        end
    end
end

-- ========================================
-- GUI - Thêm vào tab Fruits
-- ========================================
-- Thêm các toggle này vào tab v9 (Fruits)

v9:AddSection({"Fruit Collection"})

v9:AddToggle({
    Name = "Auto Collect Fruit (Teleport)",
    Default = GetSetting("AutoCollectFruit_Save", false),
    Callback = function(Value)
        _G.AutoCollectFruit = Value
        _G.SaveData["AutoCollectFruit_Save"] = Value
        SaveSettings()
    end
})

v9:AddToggle({
    Name = "Auto Hop When No Fruit",
    Default = GetSetting("AutoHopFruit_Save", false),
    Callback = function(Value)
        _G.AutoHopWhenNoFruit = Value
        _G.SaveData["AutoHopFruit_Save"] = Value
        SaveSettings()
    end
})

v9:AddToggle({
    Name = "Auto Store Fruit",
    Default = GetSetting("StoreF_Save", false),
    Callback = function(Value)
        _G.StoreF = Value
        _G.SaveData["StoreF_Save"] = Value
        SaveSettings()
    end
})

-- Loop auto store
task.spawn(function()
    while wait(3) do
        if _G.StoreF then
            pcall(function()
                UpdStFruit()
            end)
        end
    end
end)
