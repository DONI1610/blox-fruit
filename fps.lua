-- STATS + WEBHOOK 5P | KHÔNG FARM BOUNTY | GIỮA MÀN HÌNH | 2025 Grok 🔥
-- Chỉ hiện Bounty/Level/Beli/Frag + Gửi webhook ngay khi load + mỗi 5p

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local player = Players.LocalPlayer

-- WEBHOOK CỦA MÀY (thay nếu cần)
local WEBHOOK_URL = "https://discord.com/api/webhooks/1440329549454770308/oYvPfxFwuIqaKnXFqSKJuBmIYg-nxmzrgPGi8AteK95IV-y3lC3PR3rhErBkvG3k_gH9"

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "SimpleStatsWebhook"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.Parent = player:WaitForChild("PlayerGui")

-- Frame GIỮA MÀN HÌNH
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 380, 0, 220)
frame.Position = UDim2.new(0.5, -190, 0.5, -110)
frame.AnchorPoint = Vector2.new(0.5, 0.5)
frame.BackgroundColor3 = Color3.fromRGB(8, 8, 25)
frame.BackgroundTransparency = 0.12
frame.BorderSizePixel = 0
frame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 22)
corner.Parent = frame

local stroke = Instance.new("UIStroke")
stroke.Thickness = 4
stroke.Color = Color3.fromRGB(255, 180, 0)
stroke.Parent = frame

-- Labels
local bountyLabel = Instance.new("TextLabel")
bountyLabel.Size = UDim2.new(1, -30, 0.3, 0)
bountyLabel.Position = UDim2.new(0, 20, 0, 10)
bountyLabel.BackgroundTransparency = 1
bountyLabel.Text = "Bounty/Honor: Loading..."
bountyLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
bountyLabel.TextScaled = true
bountyLabel.Font = Enum.Font.GothamBlack
bountyLabel.Parent = frame

local levelLabel = Instance.new("TextLabel")
levelLabel.Size = UDim2.new(0.48, 0, 0.3, 0)
levelLabel.Position = UDim2.new(0, 20, 0.32, 0)
levelLabel.BackgroundTransparency = 1
levelLabel.Text = "Level: ---"
levelLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
levelLabel.TextScaled = true
levelLabel.Font = Enum.Font.GothamBold
levelLabel.Parent = frame

local moneyLabel = Instance.new("TextLabel")
moneyLabel.Size = UDim2.new(0.48, 0, 0.3, 0)
moneyLabel.Position = UDim2.new(0.52, 0, 0.32, 0)
moneyLabel.BackgroundTransparency = 1
moneyLabel.Text = "Beli: ---\nFrag: ---"
moneyLabel.TextColor3 = Color3.fromRGB(100, 220, 255)
moneyLabel.TextScaled = true
moneyLabel.Font = Enum.Font.GothamBold
moneyLabel.Parent = frame

-- Nút toggle góc dưới phải
local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(0, 145, 0, 58)
toggleBtn.Position = UDim2.new(1, -160, 1, -73)
toggleBtn.BackgroundColor3 = Color3.fromRGB(0, 220, 0)
toggleBtn.Text = "HIDE STATS"
toggleBtn.TextColor3 = Color3.new(1,1,1)
toggleBtn.TextScaled = true
toggleBtn.Font = Enum.Font.GothamBlack
toggleBtn.Parent = screenGui
local btnCorner = Instance.new("UICorner")
btnCorner.CornerRadius = UDim.new(0, 15)
btnCorner.Parent = toggleBtn

local visible = true
local function toggle()
    visible = not visible
    frame.Visible = visible
    toggleBtn.Text = visible and "HIDE STATS" or "SHOW STATS"
    toggleBtn.BackgroundColor3 = visible and Color3.fromRGB(0,220,0) or Color3.fromRGB(220,0,0)
end
toggleBtn.MouseButton1Click:Connect(toggle)

UserInputService.InputBegan:Connect(function(k)
    if k.KeyCode == Enum.KeyCode.Insert then toggle() end
end)

-- Gửi webhook
local function sendWebhook()
    local ls = player:FindFirstChild("leaderstats")
    if not ls then return end
    local bounty = (ls:FindFirstChild("Bounty") or ls:FindFirstChild("Bounty/Honor") or ls:FindFirstChild("Honor")) and (ls:FindFirstChild("Bounty") or ls:FindFirstChild("Bounty/Honor") or ls:FindFirstChild("Honor")).Value or 0
    local level = ls:FindFirstChild("Level") and ls.Level.Value or 0
    local beli = ls:FindFirstChild("Beli") and ls.Beli.Value or 0
    local frag = (ls:FindFirstChild("Fragments") or ls:FindFirstChild("Fragment")) and (ls:FindFirstChild("Fragments") or ls:FindFirstChild("Fragment")).Value or 0

    local msg = string.format("**%s** đang online\n**Bounty/Honor:** `%s$`\n**Level:** `%s`\n**Beli:** `%s`\n**Fragments:** `%s`", player.Name, bounty, level, beli, frag)
    pcall(function()
        HttpService:PostAsync(WEBHOOK_URL, HttpService:JSONEncode({
            embeds = {{title = "Blox Fruits Stats Update", description = msg, color = 3447003, timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")}}
        }), Enum.HttpContentType.ApplicationJson)
    end)
end

-- Update GUI
RunService.Heartbeat:Connect(function()
    local ls = player:FindFirstChild("leaderstats")
    if not ls then return end

    local bounty = ls:FindFirstChild("Bounty") or ls:FindFirstChild("Bounty/Honor") or ls:FindFirstChild("Honor")
    if bounty then
        bountyLabel.Text = "Bounty/Honor: " .. bounty.Value .. "$"
        if bounty.Value >= 25000000 then
            bountyLabel.TextColor3 = Color3.fromRGB(255, 30, 30)
            stroke.Color = Color3.fromRGB(255, 30, 30)
        elseif bounty.Value >= 10000000 then
            bountyLabel.TextColor3 = Color3.fromRGB(255, 150, 0)
            stroke.Color = Color3.fromRGB(255, 150, 0)
        else
            bountyLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
            stroke.Color = Color3.fromRGB(255, 180, 0)
        end
    end

    local lvl = ls:FindFirstChild("Level")
    if lvl then levelLabel.Text = "Level: " .. lvl.Value end

    local beli = ls:FindFirstChild("Beli")
    local frag = ls:FindFirstChild("Fragments") or ls:FindFirstChild("Fragment")
    if beli and frag then
        moneyLabel.Text = "Beli: " .. beli.Value .. "\nFrag: " .. frag.Value
    end
end)

-- GỬI WEBHOOK NGAY KHI LOAD + MỖI 5P
sendWebhook()  -- Lần đầu tiên khi vào sv
spawn(function()
    while wait(300) do  -- 5 phút
        sendWebhook()
    end
end)

game.StarterGui:SetCore("SendNotification", {
    Title = "STATS + WEBHOOK ON ✅";
    Text = "Giữa màn hình – Chỉ hiện Bounty/Level/Beli/Frag + Webhook ngay + 5p/lần";
    Duration = 7
})
print("SIMPLE STATS WEBHOOK LOADED – KHÔNG FARM, CHỈ HIỆN SỐ + GỬI DISCORD!")
