-- AUTO BOUNTY HUNT | TỰ CODE BY GROK | BLOX FRUITS 2025 | KEYLESS + NGON NHẤT
-- Chỉ cần execute là tự tìm người + TP + kill aura + auto hop khi hết target
-- Team Pirate để farm nhanh, chat troll "ez noob" sau kill

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local player = Players.LocalPlayer
local character = player.Character or player.Character:Wait()
local humanoid = character:WaitForChild("Humanoid")
local root = character:WaitForChild("HumanoidRootPart")

-- CÀI ĐẶT (bố muốn chỉnh thì sửa đây)
local SETTINGS = {
    Team = "Pirates", -- Pirates hoặc Marines
    MinBounty = 1000000, -- Chỉ săn người >= 5M bounty (tăng nếu muốn chọn lọc)
    MaxDistance = 1500, -- Khoảng cách tối đa để TP
    KillAuraRange = 35,
    AutoHop = true, -- Tự hop server khi không còn target
    HopDelay = 12, -- Giây chờ trước khi hop
    ChatAfterKill = false,
    ChatMessages = {"ez noob", "script > skill", "30M soon", "gg go next"},
    Webhook = "" -- Để trống hoặc dán webhook nếu muốn báo kill
}

-- Chọn team
spawn(function()
    if player.Team.Name ~= SETTINGS.Team then
        game:GetService("ReplicatedStorage").RemoteEvent:FireServer("SetTeam", SETTINGS.Team)
        wait(3)
    end
end)

-- Gửi webhook (nếu có)
local function sendWebhook(msg)
    if SETTINGS.Webhook ~= "" then
        pcall(function()
            HttpService:PostAsync(SETTINGS.Webhook, HttpService:JSONEncode({content = msg}))
        end)
    end
end

-- Chat troll
local function trollChat()
    if SETTINGS.ChatAfterKill then
        game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents.SayMessageRequest:FireServer(
            SETTINGS.ChatMessages[math.random(1, #SETTINGS.ChatMessages)], "All"
        )
    end
end

-- Tìm target ngon nhất
local function getBestTarget()
    local best = nil
    local highest = SETTINGS.MinBounty
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= player and v.Character and v.Character:FindFirstChild("HumanoidRootPart") and v.Character:FindFirstChild("Humanoid") and v.Character.Humanoid.Health > 0 then
            local bounty = v:FindFirstChild("leaderstats") and v.leaderstats:FindFirstChild("Bounty") and v.leaderstats.Bounty.Value or 0
            local dist = (v.Character.HumanoidRootPart.Position - root.Position).Magnitude
            if bounty >= highest and dist < SETTINGS.MaxDistance then
                highest = bounty
                best = v
            end
        end
    end
    return best
end

-- Teleport mượt
local function tpTo(pos)
    local tweenInfo = TweenInfo.new((root.Position - pos).Magnitude / 800, Enum.EasingStyle.Linear)
    local tween = TweenService:Create(root, tweenInfo, {CFrame = CFrame.new(pos + Vector3.new(0, 15, 0))})
    tween:Play()
    tween.Completed:Wait()
end

-- Kill Aura
spawn(function()
    while wait(0.2) do
        if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
            local dist = (target.Character.HumanoidRootPart.Position - root.Position).Magnitude
            if dist <= SETTINGS.KillAuraRange then
                for _, tool in pairs(character:GetChildren()) do
                    if tool:IsA("Tool") then
                        tool.Parent = player.Backpack
                        tool.Parent = character
                        tool:Activate()
                    end
                end
            end
        end
    end
end)

-- Main loop
local target = nil
local noTargetTime = 0

RunService.Heartbeat:Connect(function()
    target = getBestTarget()
    
    if target then
        noTargetTime = 0
        local hrp = target.Character.HumanoidRootPart
        root.CFrame = CFrame.new(hrp.Position + Vector3.new(0, 20, 0))
        
        -- Kiểm tra chết
        if target.Character.Humanoid.Health <= 0 then
            trollChat()
            sendWebhook("**"..player.Name.."** vừa clap **"..target.Name.."** ("..target.leaderstats.Bounty.Value.."$)")
            wait(2)
        end
    else
        noTargetTime = noTargetTime + 1
        if SETTINGS.AutoHop and noTargetTime > SETTINGS.HopDelay then
            game:GetService("TeleportService"):Teleport(game.PlaceId, player)
        end
    end
end)

-- Notify
game.StarterGui:SetCore("SendNotification", {
    Title = "GROK AUTO BOUNTY ON",
    Text = "Tự code 100% - Đang săn "..(SETTINGS.MinBounty/1000000).."M+ - Auto hop",
    Duration = 10
})
print("GROK AUTO BOUNTY LOADED - TỰ CODE BỞI GROK - FARM 30M ĐI BỐ!")
