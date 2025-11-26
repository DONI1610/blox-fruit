-- FPS + BOUNTY GÓC TRÊN TRÁI + WEBHOOK KHI CHẠY SCRIPT (gửi ngay lập tức)
-- Thêm webhook vào bản cũ – siêu nhẹ vẫn như cũ

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local player = Players.LocalPlayer

-- THAY WEBHOOK CỦA MÀY VÀO ĐÂY
local WEBHOOK_URL = "https://discord.com/api/webhooks/1440329549454770308/oYvPfxFwuIqaKnXFqSKJuBmIYg-nxmzrgPGi8AteK95IV-y3lC3PR3rhErBkvG3k_gH9"

-- GUI góc trên trái (không frame, không nút)
local gui = Instance.new("ScreenGui")
gui.Name = "FPSBountyWebhook"
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

-- Gửi webhook ngay khi execute
local function sendStart()
    local ls = player:FindFirstChild("leaderstats")
    if not ls then return end
    local bounty = (ls:FindFirstChild("Bounty") or ls:FindFirstChild("Bounty/Honor") or ls:FindFirstChild("Honor") or {Value=0}).Value
    local level = (ls:FindFirstChild("Level") or {Value=0}).Value

    pcall(function()
        HttpService:PostAsync(WEBHOOK_URL, HttpService:JSONEncode({
            embeds = {{
                title = "🚀 SCRIPT ĐÃ CHẠY",
                description = string.format("**%s** vừa bật script\nBounty hiện tại: **%s$**\nLevel: **%d**", player.Name, 
                    tostring(bounty):reverse():gsub("(%d%d%d)","%1."):reverse():gsub("^%.",""), level),
                color = 3447003,
                timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")
            }}
        }))
    end)
end
sendStart() -- Gửi ngay lập tức

-- FPS + Bounty update
local t = 0
local count = 0
local last = tick()

RunService.Heartbeat:Connect(function()
    t += 0.03
    count += 1
    if tick() - last >= 1 then
        local fps = count
        count = 0
        last = tick()

        local r = math.sin(t)*127 + 128
        local g = math.sin(t+2)*127 + 128
        local b = math.sin(t+4)*127 + 128

        fpsLabel.Text = "FPS: " .. fps
        fpsLabel.TextColor3 = Color3.fromRGB(r,g,b)
    end

    local ls = player:FindFirstChild("leaderstats")
    if ls then
        local bounty = ls:FindFirstChild("Bounty") or ls:FindFirstChild("Bounty/Honor") or ls:FindFirstChild("Honor")
        if bounty then
            local val = bounty.Value
            local color = val >= 25000000 and Color3.fromRGB(255,80,80) or Color3.fromRGB(255,215,0)
            bountyLabel.TextColor3 = color
            bountyLabel.Text = "Bounty: " .. string.format("%d", val):reverse():gsub("(%d%d%d)", "%1."):reverse():gsub("^%.", "") .. "$"
        end
    end
end)

print("FPS + BOUNTY + WEBHOOK KHI CHẠY SCRIPT DONE – NHẸ VÃI CU ƠI")
