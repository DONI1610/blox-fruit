-- STATS + FPS RAINBOW + WEBHOOK 5P | GIỮA MÀN HÌNH | CHỈ HIỆN SỐ, ĐÉO FARM | 2025 Grok
-- Bounty/Level/Beli/Frag + FPS cầu vồng + Webhook ngay + mỗi 5p

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local player = Players.LocalPlayer

-- WEBHOOK (thay nếu cần)
local WEBHOOK_URL = "https://discord.com/api/webhooks/1440329549454770308/oYvPfxFwuIqaKnXFqSKJuBmIYg-nxmzrgPGi8AteK95IV-y3lC3PR3rhErBkvG3k_gH9"

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "StatsFPSWebhook"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.Parent = player:WaitForChild("PlayerGui")

-- Frame CHÍNH giữa màn hình
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 390, 0, 280)
mainFrame.Position = UDim2.new(0.5, -195, 0.5, -140)
mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
mainFrame.BackgroundColor3 = Color3.fromRGB(8, 8, 25)
mainFrame.BackgroundTransparency = 0.12
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

local corner = Instance.new("UICorner", mainFrame)
corner.CornerRadius = UDim.new(0, 24)

local stroke = Instance.new("UIStroke", mainFrame)
stroke.Thickness = 4
stroke.Color = Color3.fromRGB(255, 180, 0)

-- FPS RAINBOW ở trên cùng
local fpsLabel = Instance.new("TextLabel", mainFrame)
fpsLabel.Size = UDim2.new(1, -40, 0, 50)
fpsLabel.Position = UDim2.new(0, 20, 0, 8)
fpsLabel.BackgroundTransparency = 1
fpsLabel.Text = "FPS: 0"
fpsLabel.TextColor3 = Color3.fromRGB(255,255,255)
fpsLabel.TextScaled = true
fpsLabel.Font = Enum.Font.GothamBlack

-- Các stats bên dưới
local bountyLabel = Instance.new("TextLabel", mainFrame)
bountyLabel.Size = UDim2.new(1, -40, 0, 55)
bountyLabel.Position = UDim2.new(0, 20, 0, 60)
bountyLabel.BackgroundTransparency = 1
bountyLabel.Text = "Bounty/Honor: Loading..."
bountyLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
bountyLabel.TextScaled = true
bountyLabel.Font = Enum.Font.GothamBlack

local levelLabel = Instance.new("TextLabel", mainFrame)
levelLabel.Size = UDim2.new(0.48, -25, 0, 50)
levelLabel.Position = UDim2.new(0, 20, 0, 120)
levelLabel.BackgroundTransparency = 1
levelLabel.Text = "Level: ---"
levelLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
levelLabel.TextScaled = true
levelLabel.Font = Enum.Font.GothamBold

local moneyLabel = Instance.new("TextLabel", mainFrame)
moneyLabel.Size = UDim2.new(0.48, -25, 0, 50)
moneyLabel.Position = UDim2.new(0.52, 5, 0, 120)
moneyLabel.BackgroundTransparency = 1
moneyLabel.Text = "Beli: ---\nFrag: ---"
moneyLabel.TextColor3 = Color3.fromRGB(100, 220, 255)
moneyLabel.TextScaled = true
moneyLabel.Font = Enum.Font.GothamBold

-- Nút toggle
local toggleBtn = Instance.new("TextButton", screenGui)
toggleBtn.Size = UDim2.new(0, 150, 0, 60)
toggleBtn.Position = UDim2.new(1, -165, 1, -75)
toggleBtn.BackgroundColor3 = Color3.fromRGB(0, 220, 0)
toggleBtn.Text = "HIDE ALL"
toggleBtn.TextColor3 = Color3.new(1,1,1)
toggleBtn.TextScaled = true
toggleBtn.Font = Enum.Font.GothamBlack
Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(0, 15)

local visible = true
local function toggle()
    visible = not visible
    mainFrame.Visible = visible
    toggleBtn.Text = visible and "HIDE ALL" or "SHOW ALL"
    toggleBtn.BackgroundColor3 = visible and Color3.fromRGB(0,220,0) or Color3.fromRGB(220,0,0)
end
toggleBtn.MouseButton1Click:Connect(toggle)
UserInputService.InputBegan:Connect(function(k) if k.KeyCode == Enum.KeyCode.Insert then toggle() end end)

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
        HttpService:PostAsync(WEBHOOK_URL, HttpService:JSONEncode({embeds={{title="Blox Fruits Stats", description=msg, color=3447003, timestamp=os.date("!%Y-%m-%dT%H:%M:%SZ")}}}))
    end)
end

-- FPS + Update loop
local t = 0
local fps = 0
local counter = 0
local last = tick()

RunService.Heartbeat:Connect(function()
    -- FPS Rainbow
    t = t + 0.03
    local r = math.sin(t) * 127 + 128
    local g = math.sin(t + 2) * 127 + 128
    local b = math.sin(t + 4) * 127 + 128
    counter += 1
    if tick() - last >= 1 then
        fps = counter
        counter = 0
        last = tick()
    end
    fpsLabel.Text = "FPS: " .. fps
    fpsLabel.TextColor3 = Color3.fromRGB(r, g, b)

    -- Stats update
    local ls = player:FindFirstChild("leaderstats")
    if ls then
        local bounty = ls:FindFirstChild("Bounty") or ls:FindFirstChild("Bounty/Honor") or ls:FindFirstChild("Honor")
        if bounty then
            bountyLabel.Text = "Bounty/Honor: " .. bounty.Value .. "$"
            if bounty.Value >= 25000000 then
                bountyLabel.TextColor3 = Color3.fromRGB(255,30,30)
                stroke.Color = Color3.fromRGB(255,30,30)
            elseif bounty.Value >= 10000000 then
                bountyLabel.TextColor3 = Color3.fromRGB(255,150,0)
                stroke.Color = Color3.fromRGB(255,150,0)
            end
        end
        local lvl = ls:FindFirstChild("Level")
        if lvl then levelLabel.Text = "Level: " .. lvl.Value end
        local beli = ls:FindFirstChild("Beli")
        local frag = ls:FindFirstChild("Fragments") or ls:FindFirstChild("Fragment")
        if beli and frag then moneyLabel.Text = "Beli: " .. beli.Value .. "\nFrag: " .. frag.Value end
    end
end)

-- Gửi webhook ngay khi load + mỗi 5p
sendWebhook()  -- lần đầu
spawn(function()
    while wait(300) do sendWebhook() end
end)

game.StarterGui:SetCore("SendNotification", {
    Title = "STATS + FPS + WEBHOOK ON";
    Text = "Bounty/Level/Beli/Frag + FPS cầu vồng + Webhook ngay + 5p/lần";
    Duration = 8
})
