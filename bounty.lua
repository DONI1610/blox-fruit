-- FPS + BOUNTY + BELI (TOP-LEFT) + DISCORD WEBHOOK (ARCEUS X – STABLE)

-- ================= SERVICES =================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

local player = Players.LocalPlayer

-- ================= WEBHOOK =================
local WEBHOOK_URL = "https://discord.com/api/webhooks/1448861704568963095/8TsAmk08AwtX06g_HOrgM1gmY_KlCagueGf-5VCdqh6KCJXvF3lSMYYYGcvGgY5ng8rA"

-- ================= HTTP (EXECUTOR) =================
local request = http_request or request or (syn and syn.request)
if not request then
    warn("[SCRIPT] Executor không hỗ trợ http_request")
end

-- ================= GUI =================
local gui = Instance.new("ScreenGui")
gui.Name = "FPS_BOUNTY_BELI_GUI"
gui.ResetOnSpawn = false
gui.Parent = game:GetService("CoreGui")

local fpsLabel = Instance.new("TextLabel", gui)
fpsLabel.Position = UDim2.new(0, 12, 0, 10)
fpsLabel.Size = UDim2.new(0, 200, 0, 28)
fpsLabel.BackgroundTransparency = 1
fpsLabel.TextXAlignment = Enum.TextXAlignment.Left
fpsLabel.Font = Enum.Font.GothamBold
fpsLabel.TextSize = 26
fpsLabel.Text = "FPS: 0"

local bountyLabel = Instance.new("TextLabel", gui)
bountyLabel.Position = UDim2.new(0, 12, 0, 38)
bountyLabel.Size = UDim2.new(0, 420, 0, 32)
bountyLabel.BackgroundTransparency = 1
bountyLabel.TextXAlignment = Enum.TextXAlignment.Left
bountyLabel.Font = Enum.Font.GothamBlack
bountyLabel.TextSize = 30
bountyLabel.Text = "Bounty: --"

local beliLabel = Instance.new("TextLabel", gui)
beliLabel.Position = UDim2.new(0, 12, 0, 68)
beliLabel.Size = UDim2.new(0, 420, 0, 28)
beliLabel.BackgroundTransparency = 1
beliLabel.TextXAlignment = Enum.TextXAlignment.Left
beliLabel.Font = Enum.Font.GothamBold
beliLabel.TextSize = 26
beliLabel.Text = "Beli: --"

-- ================= HELPER =================
local function formatNumber(n)
    if typeof(n) ~= "number" then
        return "0"
    end
    n = math.floor(n)
    local s = tostring(n)
    s = s:reverse():gsub("(%d%d%d)", "%1."):reverse()
    return s:gsub("^%.", "")
end

-- ================= GET DATA =================
local function getBounty()
    local ls = player:FindFirstChild("leaderstats")
    if not ls then return 0 end
    local b = ls:FindFirstChild("Bounty")
        or ls:FindFirstChild("Bounty/Honor")
        or ls:FindFirstChild("Honor")
    return b and b.Value or 0
end

local function getBeli()
    local data = player:FindFirstChild("Data")
    local b = data and data:FindFirstChild("Beli")
    return b and b.Value or 0
end

local function getLevel()
    local data = player:FindFirstChild("Data")
    local lv = data and data:FindFirstChild("Level")
    return lv and lv.Value or 0
end

-- ================= WEBHOOK FUNCTION =================
local function sendWebhook(reason)
    if not request then
        warn("[WEBHOOK] request not supported")
        return
    end

    local ok, err = pcall(function()
        local payload = {
            content = string.format(
                "[%s]\nUser: %s\nLevel: %d\nBounty: %s$\nBeli: %s",
                reason,
                player.Name,
                getLevel(),
                formatNumber(getBounty()),
                formatNumber(getBeli())
            )
        }

        request({
            Url = WEBHOOK_URL,
            Method = "POST",
            Headers = {
                ["Content-Type"] = "application/json"
            },
            Body = HttpService:JSONEncode(payload)
        })
    end)

    if ok then
        print("[WEBHOOK] Sent ->", reason)
    else
        warn("[WEBHOOK ERROR]", err)
    end
end

-- ================= START LOG =================
print("=== SCRIPT STARTED ===")
print("User  :", player.Name)
print("Level :", getLevel())
print("Bounty:", getBounty())
print("Beli  :", getBeli())
print("======================")

-- gửi sau 5s
task.delay(5, function()
    sendWebhook("SCRIPT START")
end)

-- gửi lại mỗi 5 phút
task.spawn(function()
    while task.wait(300) do
        sendWebhook("AUTO UPDATE (5 MIN)")
    end
end)

-- ================= FPS + GUI UPDATE =================
local frames = 0
local last = tick()
local hue = 0

RunService.Heartbeat:Connect(function()
    frames += 1
    hue += 0.03

    if tick() - last >= 1 then
        fpsLabel.Text = "FPS: " .. frames
        frames = 0
        last = tick()

        fpsLabel.TextColor3 = Color3.fromRGB(
            math.sin(hue) * 127 + 128,
            math.sin(hue + 2) * 127 + 128,
            math.sin(hue + 4) * 127 + 128
        )
    end

    local bounty = getBounty()
    bountyLabel.Text = "Bounty: " .. formatNumber(bounty) .. "$"
    bountyLabel.TextColor3 = bounty >= 25000000
        and Color3.fromRGB(255, 80, 80)
        or Color3.fromRGB(255, 215, 0)

    local beli = getBeli()
    beliLabel.Text = "Beli: " .. formatNumber(beli)
    beliLabel.TextColor3 = Color3.fromRGB(0, 255, 170)
end)

print("FPS + BOUNTY + BELI + WEBHOOK READY (AUTO 5 MIN)")
