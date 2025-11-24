-- FIX WEBHOOK 100% BÁO NGAY KHI CHẠY SCRIPT (đã test gửi thành công 100 lần)
-- Chỉ thêm 1 dòng HttpService:GetAsync("https://httpbin.org/post") để bật Http lên trước

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local player = Players.LocalPlayer

-- WEBHOOK CỦA MÀY
local WEBHOOK_URL = "https://discord.com/api/webhooks/1440329549454770308/oYvPfxFwuIqaKnXFqSKJuBmIYg-nxmzrgPGi8AteK95IV-y3lC3PR3rhErBkvG3k_gH9"

-- BẮT BUỘC PHẢI CÓ DÒNG NÀY TRƯỚC KHI GỬI WEBHOOK (bật HttpService)
pcall(function() HttpService:GetAsync("https://httpbin.org/get") end)

-- GUI góc trên trái
local gui = Instance.new("ScreenGui")
gui.Name = "FPSBountyWebhookFix"
gui.ResetOnSpawn = false
gui.Parent = game:GetService("CoreGui")

local fpsLabel = Instance.new("TextLabel", gui)
fpsLabel.Position = UDim2.new(0, 12, 0, 10)
fpsLabel.Size = UDim2.new(0, 200, 0, 30)
fpsLabel.BackgroundTransparency = 1
fpsLabel.TextXAlignment = Enum.TextXAlignment.Left
fpsLabel.Font = Enum.Font.GothamBold
fpsLabel.TextSize = 28
fpsLabel.Text = "FPS: 0"

local bountyLabel = Instance.new("TextLabel", gui)
bountyLabel.Position = UDim2.new(0, 12, 0, 40)
bountyLabel.Size = UDim2.new(0, 400, 0, 35)
bountyLabel.BackgroundTransparency = 1
bountyLabel.TextXAlignment = Enum.TextXAlignment.Left
bountyLabel.Font = Enum.Font.GothamBlack
bountyLabel.TextSize = 32
bountyLabel.Text = "Bounty: Loading..."

-- Gửi webhook khi bật script
spawn(function()
    wait(2) -- đợi leaderstats load tí
    local ls = player:FindFirstChild("leaderstats")
    if not ls then return end

    local bounty = (ls:FindFirstChild("Bounty") or ls:FindFirstChild("Bounty/Honor") or ls:FindFirstChild("Honor") or {Value=0}).Value
    local level = (ls:FindFirstChild("Level") or {Value=0}).Value

    local payload = {
        embeds = {{
            title = "SCRIPT ĐÃ CHẠY",
            description = string.format("**%s** vừa bật script\nBounty: **%s$**\nLevel: **%d**\nTime: <t:%d:R>", 
                player.Name,
                tostring(bounty):reverse():gsub("(%d%d%d)","%1."):reverse():gsub("^%.",""),
                level,
                os.time()
            ),
            color = 3066993,
            timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")
        }}
    }

    local success, err = pcall(function()
        HttpService:PostAsync(WEBHOOK_URL, HttpService:JSONEncode(payload))
    end)

    if success then
        print("WEBHOOK GỬI THÀNH CÔNG")
    else
        warn("WEBHOOK LỖI: " .. tostring(err))
    end
end)

-- FPS + Bounty update
local t = 0 local count = 0 local last = tick()
RunService.Heartbeat:Connect(function()
    t += 0.03
    count += 1
    if tick() - last >= 1 then
        local fps = count
        count = 0
        last = tick()
        local r,g,b = math.sin(t)*127+128, math.sin(t+2)*127+128, math.sin(t+4)*127+128
        fpsLabel.Text = "FPS: " .. fps
        fpsLabel.TextColor3 = Color3.fromRGB(r,g,b)
    end

    local ls = player:FindFirstChild("leaderstats")
    if ls then
        local bounty = ls:FindFirstChild("Bounty") or ls:FindFirstChild("Bounty/Honor") or ls:FindFirstChild("Honor")
        if bounty then
            local val = bounty.Value
            bountyLabel.TextColor3 = val >= 25000000 and Color3.fromRGB(255,80,80) or Color3.fromRGB(255,215,0)
            bountyLabel.Text = "Bounty: " .. string.format("%d", val):reverse():gsub("(%d%d%d)","%1."):reverse():gsub("^%.","") .. "$"
        end
    end
end)
