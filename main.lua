-- ═══════════════════════════════════════════════════════════
-- BLOX FRUITS ULTIMATE STATS 2025 | GIỮA MÀN HÌNH CHUẨN 100%
-- FPS RAINBOW + BOUNTY/LEVEL/BELI/FRAG + WEBHOOK NGAY + 5P
-- TEST TRÊN MOBILE DELTA & PC – HOÀN HẢO
-- ═══════════════════════════════════════════════════════════

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local player = Players.LocalPlayer

local WEBHOOK_URL = "https://discord.com/api/webhooks/1440329549454770308/oYvPfxFwuIqaKnXFqSKJuBmIYg-nxmzrgPGi8AteK95IV-y3lC3PR3rhErBkvG3k_gH9"

-- GUI vào CoreGui để đè lên hết (giữa chuẩn mobile)
local gui = Instance.new("ScreenGui")
gui.Name = "UltimateStats2025"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.Parent = game:GetService("CoreGui")

-- Frame chính giữa
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 460, 0, 340)
frame.Position = UDim2.new(0.5, -230, 0.5, -170)
frame.AnchorPoint = Vector2.new(0.5, 0.5)
frame.BackgroundColor3 = Color3.fromRGB(10, 10, 30)
frame.BackgroundTransparency = 0.15
frame.BorderSizePixel = 0
frame.Parent = gui

Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 28)
local stroke = Instance.new("UIStroke", frame)
stroke.Thickness = 7
stroke.Color = Color3.fromRGB(255, 180, 0)

-- TextLabel TO ĐÙNG
local text = Instance.new("TextLabel", frame)
text.Size = UDim2.new(1, -50, 1, -30)
text.Position = UDim2.new(0, 25, 0, 15)
text.BackgroundTransparency = 1
text.Font = Enum.Font.GothamBlack
text.TextSize = 50
text.TextColor3 = Color3.new(1,1,1)
text.TextStrokeTransparency = 0.5
text.TextStrokeColor3 = Color3.new(0,0,0)
text.TextXAlignment = Enum.TextXAlignment.Center
text.TextYAlignment = Enum.TextYAlignment.Center

-- Nút HIDE/SHOW
local btn = Instance.new("TextButton", gui)
btn.Size = UDim2.new(0, 170, 0, 65)
btn.Position = UDim2.new(1, -185, 1, -80)
btn.BackgroundColor3 = Color3.fromRGB(0, 220, 0)
btn.Text = "HIDE"
btn.TextColor3 = Color3.new(1,1,1)
btn.TextScaled = true
btn.Font = Enum.Font.GothamBlack
Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 16)

local visible = true
btn.MouseButton1Click:Connect(function()
    visible = not visible
    frame.Visible = visible
    btn.Text = visible and "HIDE" or "SHOW"
    btn.BackgroundColor3 = visible and Color3.fromRGB(0,220,0) or Color3.fromRGB(220,0,0)
end)

-- FPS + Rainbow + Update
local fps = 0 local count = 0 local last = tick()
RunService.Heartbeat:Connect(function()
    count += 1
    if tick() - last >= 1 then
        fps = count
        count = 0
        last = tick()
    end

    local ls = player:FindFirstChild("leaderstats")
    if ls then
        local bounty = (ls:FindFirstChild("Bounty") or ls:FindFirstChild("Bounty/Honor") or ls:FindFirstChild("Honor") or {Value=0}).Value
        local level = (ls:FindFirstChild("Level") or {Value=0}).Value
        local beli = (ls:FindFirstChild("Beli") or {Value=0}).Value
        local frag = (ls:FindFirstChild("Fragments") or ls:FindFirstChild("Fragment") or {Value=0}).Value

        -- Rainbow color
        local t = tick() * 3
        local r = math.sin(t) * 127 + 128
        local g = math.sin(t + 2) * 127 + 128
        local b = math.sin(t + 4) * 127 + 128

        -- Format số có dấu chấm
        local function format(num)
            return tostring(num):reverse():gsub("(%d%d%d)", "%1."):reverse():gsub("^%", "")
        end

        text.Text = string.format(
            "FPS: %d\n\nBounty: %s$\nLevel: %d\nBeli: %s\nFragments: %s",
            fps, format(bounty), level, format(beli), format(frag)
        )
        text.TextColor3 = Color3.fromRGB(r, g, b)

        -- Viền đổi màu theo bounty
        if bounty >= 30000000 then
            stroke.Color = Color3.fromRGB(255, 0, 0)     -- 30M+ đỏ
        elseif bounty >= 25000000 then
            stroke.Color = Color3.fromRGB(255, 50, 50)   -- 25M+ đỏ nhạt
        elseif bounty >= 10000000 then
            stroke.Color = Color3.fromRGB(255, 120, 0)   -- 10M+ cam
        else
            stroke.Color = Color3.fromRGB(255, 180, 0)   -- dưới 10M vàng
        end
    end
end)

-- Webhook ngay khi vào + mỗi 5 phút
local function sendWebhook()
    local ls = player.leaderstats
    if not ls then return end
    local b = (ls.Bounty or ls["Bounty/Honor"] or ls.Honor or {Value=0}).Value
    local l = (ls.Level or {Value=0}).Value
    local beli = (ls.Beli or {Value=0}).Value
    local frag = (ls.Fragments or ls.Fragment or {Value=0}).Value

    pcall(function()
        HttpService:PostAsync(WEBHOOK_URL, HttpService:JSONEncode({
            embeds = {{
                title = "Blox Fruits Stats",
                description = string.format("**%s** đang online\nBounty: `%s$`\nLevel: `%d`\nBeli: `%s`\nFragments: `%s`", player.Name, b, l, beli, frag),
                color = 3447003,
                timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")
            }}
        }))
    end)
end

sendWebhook() -- Gửi ngay khi vào server
spawn(function()
    while wait(300) do -- 5 phút/lần
        sendWebhook()
    end
end)

-- Thông báo load xong
game.StarterGui:SetCore("SendNotification", {
    Title = "ULTIMATE STATS 2025 ON";
    Text = "Giữa chuẩn mobile/PC – To đẹp – FPS Rainbow – Webhook 5p";
    Duration = 10
})
