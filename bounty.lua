-- FPS + BOUNTY + BELI (TOP-LEFT) + DISCORD EMBED WEBHOOK (ARCEUS X – STABLE)

-- ================= SERVICES =================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

local player = Players.LocalPlayer

-- ================= WEBHOOK =================
local WEBHOOK_URL = "https://discord.com/api/webhooks/1448861704568963095/8TsAmk08AwtX06g_HOrgM1gmY_KlCagueGf-5VCdqh6KCJXvF3lSMYYYGcvGgY5ng8rA"

-- ================= HTTP =================
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
    if typeof(n) ~= "number" then return "0" end
    local s = tostring(math.floor(n))
    s = s:reverse():gsub("(%d%d%d)", "%1."):reverse()
    return s:gsub("^%.", "")
end

-- ================= GET DATA =================
local function getLevel()
    local d = player:FindFirstChild("Data")
    local v = d and d:FindFirstChild("Level")
    return v and v.Value or 0
end

local function getBeli()
    local d = player:FindFirstChild("Data")
    local v = d and d:FindFirstChild("Beli")
    return v and v.Value or 0
end

local function getBounty()
    local ls = player:FindFirstChild("leaderstats")
    if not ls then return 0 end
    local v = ls:FindFirstChild("Bounty")
        or ls:FindFirstChild("Bounty/Honor")
        or ls:FindFirstChild("Honor")
    return v and v.Value or 0
end

-- ================= DISCORD EMBED =================
local function sendEmbed(reason)
    if not request then return end

    local payload = {
        username = "Status Bot",
        embeds = {{
            title = reason,
            color = 16776960, -- vàng
            fields = {
                {
                    name = "👤 User",
                    value = player.Name,
                    inline = false
                },
                {
                    name = "📊 Stats",
                    value =
                        "**Level:** " .. getLevel() ..
                        "\n**Beli:** " .. formatNumber(getBeli()) ..
                        "\n**Bounty:** " .. formatNumber(getBounty()) .. "$",
                    inline = false
                }
            },
            footer = {
                text = "Auto update mỗi 5 phút"
            },
            timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")
        }}
    }

    local ok, err = pcall(function()
        request({
            Url = WEBHOOK_URL,
            Method = "POST",
            Headers = { ["Content-Type"] = "application/json" },
            Body = HttpService:JSONEncode(payload)
        })
    end)

    if ok then
        print("[WEBHOOK] Sent embed ->", reason)
    else
        warn("[WEBHOOK ERROR]", err)
    end
end

-- ================= START =================
print("=== SCRIPT STARTED ===")
print("User  :", player.Name)
print("Level :", getLevel())
print("Beli  :", getBeli())
print("Bounty:", getBounty())
print("======================")

task.delay(5, function()
    sendEmbed("🔔 STATUS START")
end)

task.spawn(function()
    while task.wait(300) do
        sendEmbed("⏱ AUTO UPDATE")
    end
end)

-- ================= FPS UPDATE =================
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

    beliLabel.Text = "Beli: " .. formatNumber(getBeli())
end)

print("FPS + GUI + DISCORD EMBED READY (AUTO 5 MIN)")
