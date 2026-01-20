-- FPS + BOUNTY + BELI + FRAGMENTS (TOP-LEFT)
-- DISCORD WEBHOOK EMBED (AUTO 5 MIN)
-- TESTED: ARCEUS X

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
gui.Name = "FPS_BOUNTY_BELI_FRAG_GUI"
gui.ResetOnSpawn = false
gui.Parent = game:GetService("CoreGui")

local function newLabel(y, size, font)
    local t = Instance.new("TextLabel", gui)
    t.Position = UDim2.new(0, 12, 0, y)
    t.Size = UDim2.new(0, 450, 0, size)
    t.BackgroundTransparency = 1
    t.TextXAlignment = Enum.TextXAlignment.Left
    t.Font = font
    t.TextSize = size
    return t
end

local fpsLabel    = newLabel(10, 26, Enum.Font.GothamBold)
local bountyLabel = newLabel(38, 30, Enum.Font.GothamBlack)
local beliLabel   = newLabel(70, 26, Enum.Font.GothamBold)
local fragLabel   = newLabel(98, 26, Enum.Font.GothamBold)

fpsLabel.Text    = "FPS: 0"
bountyLabel.Text = "Bounty: --"
beliLabel.Text   = "Beli: --"
fragLabel.Text   = "Fragments: --"

-- ================= FORMAT =================
local function formatNumber(n)
    if typeof(n) ~= "number" then return "0" end
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
    local d = player:FindFirstChild("Data")
    local b = d and d:FindFirstChild("Beli")
    return b and b.Value or 0
end

local function getFragments()
    local d = player:FindFirstChild("Data")
    local f = d and d:FindFirstChild("Fragments")
    return f and f.Value or 0
end

local function getLevel()
    local d = player:FindFirstChild("Data")
    local l = d and d:FindFirstChild("Level")
    return l and l.Value or 0
end

-- ================= WEBHOOK =================
local function sendWebhook(reason)
    if not request then return end

    local payload = {
        embeds = {{
            title = "🍌 Blox Fruits Status",
            description = "**"..reason.."**",
            color = 16705372,
            fields = {
                {
                    name = "👤 Player",
                    value = player.Name,
                    inline = true
                },
                {
                    name = "📊 Stats",
                    value =
                        "**Level:** "..getLevel()..
                        "\n**Beli:** "..formatNumber(getBeli())..
                        "\n**Bounty:** "..formatNumber(getBounty()).."$"..
                        "\n**Fragments:** "..formatNumber(getFragments()),
                    inline = false
                }
            },
            footer = {
                text = "Auto update every 5 minutes"
            },
            timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")
        }}
    }

    pcall(function()
        request({
            Url = WEBHOOK_URL,
            Method = "POST",
            Headers = {["Content-Type"] = "application/json"},
            Body = HttpService:JSONEncode(payload)
        })
    end)
end

-- ================= START =================
task.delay(5, function()
    sendWebhook("SCRIPT STARTED")
end)

task.spawn(function()
    while task.wait(300) do
        sendWebhook("AUTO UPDATE (5 MIN)")
    end
end)

-- ================= FPS + UPDATE =================
local frames, last, hue = 0, tick(), 0

RunService.Heartbeat:Connect(function()
    frames += 1
    hue += 0.04

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

    bountyLabel.Text = "Bounty: " .. formatNumber(getBounty()) .. "$"
    bountyLabel.TextColor3 = Color3.fromRGB(255, 215, 0)

    beliLabel.Text = "Beli: " .. formatNumber(getBeli())
    beliLabel.TextColor3 = Color3.fromRGB(0, 255, 170)

    fragLabel.Text = "Fragments: " .. formatNumber(getFragments())
    fragLabel.TextColor3 = Color3.fromRGB(120, 200, 255)
end)

print("READY | FPS + BOUNTY + BELI + FRAGMENTS + WEBHOOK")
