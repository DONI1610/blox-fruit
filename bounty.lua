-- GROK AUTO BOUNTY | HẾT NGƯỜI = HOP NGAY | 2025 FINAL
-- Chỉ cần copy nguyên cái này → execute → farm ngon lành

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local TeleportService = game:GetService("TeleportService")
local player = Players.LocalPlayer

-- CÀI ĐẶT
local CONFIG = {
    MinBounty = 5000000,        -- Muốn săn 10M+ thì sửa thành 10000000
    MaxDistance = 1500,
    AuraRange = 45,
    TP_Speed = 1300,
    HopWhenNoTarget = true,     -- Bật hop khi hết người
    HopDelay = 8,               -- Chờ 8 giây không thấy ai → hop luôn
    ChatTroll = true,
    TrollMessages = {"ez", "noob", "30M soon", "gg", "script > skill"}
}

-- Biến
local noTargetTime = 0
local lastTarget = nil
local ready = false

-- Đợi load xong mới chạy (không hop oan)
spawn(function()
    repeat wait() until player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    repeat wait() until player:FindFirstChild("leaderstats")
    wait(4)
    ready = true
    game.StarterGui:SetCore("SendNotification",{Title="GROK BOUNTY",Text="ĐÃ SẴN SÀNG – BẮT ĐẦU SĂN!",Duration=5})
end)

-- Tìm target ngon nhất
local function getTarget()
    if not ready then return nil end
    local best = nil
    local highest = CONFIG.MinBounty

    for _, v in pairs(Players:GetPlayers()) do
        if v ~= player and v.Character and v.Character:FindFirstChild("HumanoidRootPart") and v.Character:FindFirstChild("Humanoid") and v.Character.Humanoid.Health > 0 then
            local ls = v:FindFirstChild("leaderstats")
            if ls then
                local bountyVal = 0
                local bountyObj = ls:FindFirstChild("Bounty") or ls:FindFirstChild("Bounty/Honor") or ls:FindFirstChild("Honor")
                if bountyObj then bountyVal = bountyObj.Value end

                if bountyVal >= highest then
                    local dist = (v.Character.HumanoidRootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude
                    if dist <= CONFIG.MaxDistance then
                        highest = bountyVal
                        best = v
                    end
                end
            end
        end
    end
    return best
end

-- Main loop
RunService.Heartbeat:Connect(function()
    if not ready or not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then return end

    local target = getTarget()

    if target then
        noTargetTime = 0  -- Reset timer khi có người

        if target ~= lastTarget then
            lastTarget = target
            local bounty = 0
            local bObj = target:FindFirstChild("leaderstats") and (target.leaderstats:FindFirstChild("Bounty") or target.leaderstats:FindFirstChild("Bounty/Honor"))
            if bObj then bounty = bObj.Value end
            game.StarterGui:SetCore("SendNotification",{Title="TARGET",Text=target.Name.." ("..math.floor(bounty/1000000).."M)",Duration=2})
        end

        -- TP + Kill Aura
        local root = player.Character.HumanoidRootPart
        local tRoot = target.Character.HumanoidRootPart
        local dist = (root.Position - tRoot.Position).Magnitude

        if dist > 50 then
            local tween = TweenService:Create(root, TweenInfo.new(dist/CONFIG.TP_Speed, Enum.EasingStyle.Linear), {CFrame = CFrame.new(tRoot.Position + Vector3.new(0,20,0))})
            tween:Play()
        end

        if dist <= CONFIG.AuraRange then
            for _, tool in pairs(player.Backpack:GetChildren()) do
                if tool:IsA("Tool") then
                    tool.Parent = player.Character
                    tool:Activate()
                    wait(0.12)
                end
            end
        end

        -- Chat khi kill
        if target.Character.Humanoid.Health <= 0 and CONFIG.ChatTroll then
            game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents.SayMessageRequest:FireServer(
                CONFIG.TrollMessages[math.random(#CONFIG.TrollMessages)], "All")
            wait(1.5)
        end

    else
        -- HẾT ĐỨA ĐÁNH → ĐẾM NGƯỢC RỒI HOP
        noTargetTime = noTargetTime + 1

        if CONFIG.HopWhenNoTarget and noTargetTime >= CONFIG.HopDelay then
            game.StarterGui:SetCore("SendNotification",{Title="HẾT NGƯỜI",Text="Hop server mới tìm thêm thịt...",Duration=4})
            wait(3)
            TeleportService:Teleport(game.PlaceId, player)
        end
    end
end)

-- Thông báo load xong
game.StarterGui:SetCore("SendNotification",{Title="GROK BOUNTY FINAL",Text="Hết người = hop ngay sau "..CONFIG.HopDelay.."s – Ngon rồi bố ơi!",Duration=7})
print("GROK AUTO BOUNTY FINAL LOADED – HẾT ĐỨA ĐÁNH = HOP NGAY!")
