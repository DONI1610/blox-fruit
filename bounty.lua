-- =========================================================
-- FULL BLOX FRUITS STATUS HUB
-- FPS + STATS + FIGHTING STYLE + FRUIT + WEAPON
-- DISCORD WEBHOOK EMBED + AUTO REJOIN + SERVER HOP
-- TESTED: ARCEUS X
-- =========================================================

-- ================= SERVICES =================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local CoreGui = game:GetService("CoreGui")

local player = Players.LocalPlayer
local PlaceId = game.PlaceId
local JobId = game.JobId

-- ================= WEBHOOK =================
local WEBHOOK_URL = "https://discord.com/api/webhooks/1448861704568963095/8TsAmk08AwtX06g_HOrgM1gmY_KlCagueGf-5VCdqh6KCJXvF3lSMYYYGcvGgY5ng8rA"

local request = http_request or request or (syn and syn.request)
if not request then
    warn("[SCRIPT] Executor không hỗ trợ http_request")
end

-- ================= GUI =================
local gui = Instance.new("ScreenGui")
gui.Name = "BF_FULL_STATUS_GUI"
gui.ResetOnSpawn = false
gui.Parent = CoreGui

local function newLabel(y, size, font)
    local t = Instance.new("TextLabel", gui)
    t.Position = UDim2.new(0, 12, 0, y)
    t.Size = UDim2.new(0, 500, 0, size)
    t.BackgroundTransparency = 1
    t.TextXAlignment = Enum.TextXAlignment.Left
    t.Font = font
    t.TextSize = size
    t.Text = "--"
    return t
end

local fpsLabel    = newLabel(10, 26, Enum.Font.GothamBold)
local bountyLabel = newLabel(38, 30, Enum.Font.GothamBlack)
local beliLabel   = newLabel(70, 26, Enum.Font.GothamBold)
local fragLabel   = newLabel(98, 26, Enum.Font.GothamBold)

-- ================= FORMAT =================
local function formatNumber(n)
    n = tonumber(n) or 0
    n = math.floor(n)
    return tostring(n):reverse():gsub("(%d%d%d)", "%1."):reverse():gsub("^%.","")
end

-- ================= GET BASIC DATA =================
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
    return d and d:FindFirstChild("Beli") and d.Beli.Value or 0
end

local function getFragments()
    local d = player:FindFirstChild("Data")
    return d and d:FindFirstChild("Fragments") and d.Fragments.Value or 0
end

local function getLevel()
    local d = player:FindFirstChild("Data")
    return d and d:FindFirstChild("Level") and d.Level.Value or 0
end

-- ================= FIGHTING STYLES =================
local FightingStyles = {
    ["Combat"] = true,
    ["Dark Step"] = true,
    ["Electric"] = true,
    ["Water Kung Fu"] = true,
    ["Dragon Breath"] = true,
    ["Superhuman"] = true,
    ["Godhuman"] = true,
    ["Sharkman Karate"] = true,
    ["Death Step"] = true,
    ["Electric Claw"] = true
}

local function getFightingStyles()
    local list = {}

    local function scan(container)
        for _, v in ipairs(container:GetChildren()) do
            if v:IsA("Tool") and FightingStyles[v.Name] then
                table.insert(list, v.Name)
            end
        end
    end

    scan(player.Backpack)
    if player.Character then
        scan(player.Character)
    end

    return #list > 0 and table.concat(list, ", ") or "None"
end

-- ================= FRUITS =================
local function getEquippedFruit()
    local d = player:FindFirstChild("Data")
    local f = d and d:FindFirstChild("DevilFruit")
    return f and f.Value or "None"
end

local function getFruitInventory()
    local list = {}
    for _, v in ipairs(player.Backpack:GetChildren()) do
        if v:IsA("Tool") and string.find(v.Name, "Fruit") then
            table.insert(list, v.Name)
        end
    end
    return #list > 0 and table.concat(list, ", ") or "None"
end

-- ================= WEAPONS =================
local function getWeapons()
    local list = {}
    for _, v in ipairs(player.Backpack:GetChildren()) do
        if v:IsA("Tool") and not string.find(v.Name, "Fruit") then
            table.insert(list, v.Name)
        end
    end
    return #list > 0 and table.concat(list, ", ") or "None"
end

-- ================= WEBHOOK =================
local function sendWebhook(reason)
    if not request then return end

    local payload = {
        embeds = {{
            title = "🍌 Blox Fruits Full Status",
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
                        "**Level:** "..formatNumber(getLevel())..
                        "\n**Beli:** "..formatNumber(getBeli())..
                        "\n**Bounty:** "..formatNumber(getBounty())..
                        "\n**Fragments:** "..formatNumber(getFragments()),
                    inline = false
                },
                {
                    name = "🥋 Fighting Styles",
                    value = getFightingStyles(),
                    inline = false
                },
                {
                    name = "🍏 Fruits",
                    value =
                        "**Equipped:** "..getEquippedFruit()..
                        "\n**Inventory:** "..getFruitInventory(),
                    inline = false
                },
                {
                    name = "🗡 Weapons / Items",
                    value = getWeapons(),
                    inline = false
                }
            },
            footer = { text = "Auto update every 5 minutes" },
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

-- ================= AUTO REJOIN =================
pcall(function()
    CoreGui.RobloxPromptGui.promptOverlay.ChildAdded:Connect(function(child)
        if child.Name == "ErrorPrompt" then
            sendWebhook("DISCONNECTED - REJOIN")
            task.wait(3)
            TeleportService:Teleport(PlaceId, player)
        end
    end)
end)

-- ================= SERVER HOP BUTTON =================
local hopBtn = Instance.new("TextButton", gui)
hopBtn.Size = UDim2.new(0, 90, 0, 32)
hopBtn.Position = UDim2.new(1, -100, 0, 10)
hopBtn.Text = "HOP SV"
hopBtn.Font = Enum.Font.GothamBold
hopBtn.TextSize = 16
hopBtn.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
hopBtn.TextColor3 = Color3.new(1,1,1)
hopBtn.BorderSizePixel = 0
Instance.new("UICorner", hopBtn).CornerRadius = UDim.new(0, 8)

hopBtn.MouseButton1Click:Connect(function()
    sendWebhook("SERVER HOP")
    TeleportService:Teleport(PlaceId, player)
end)

-- ================= FPS + UI UPDATE =================
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

    bountyLabel.Text = "Bounty: " .. formatNumber(getBounty())
    bountyLabel.TextColor3 = Color3.fromRGB(255, 215, 0)

    beliLabel.Text = "Beli: " .. formatNumber(getBeli())
    beliLabel.TextColor3 = Color3.fromRGB(0, 255, 170)

    fragLabel.Text = "Fragments: " .. formatNumber(getFragments())
    fragLabel.TextColor3 = Color3.fromRGB(120, 200, 255)
end)

print("READY | FULL BLOX FRUITS STATUS HUB")
