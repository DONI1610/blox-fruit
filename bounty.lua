-- =========================================================
-- FPS + BOUNTY + BELI + FRAGMENTS + WEBHOOK + AUTO REJOIN
-- + SERVER HOP BUTTON (STABLE MERGED VERSION)
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

-- ================= GUI ROOT =================
local gui = Instance.new("ScreenGui")
gui.Name = "BF_FULL_GUI"
gui.ResetOnSpawn = false
gui.Parent = CoreGui

local function newLabel(y, size, font)
    local t = Instance.new("TextLabel", gui)
    t.Position = UDim2.new(0, 12, 0, y)
    t.Size = UDim2.new(0, 450, 0, size)
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
    pcall(function()
        request({
            Url = WEBHOOK_URL,
            Method = "POST",
            Headers = { ["Content-Type"] = "application/json" },
            Body = HttpService:JSONEncode({
                embeds = {{
                    title = "Blox Fruits Status",
                    description = "**"..reason.."**",
                    color = 3447003,
                    fields = {
                        { name = "Player", value = player.Name, inline = true },
                        {
                            name = "Stats",
                            value =
                                "**Level:** "..formatNumber(getLevel())..
                                "\n**Beli:** "..formatNumber(getBeli())..
                                "\n**Bounty:** "..formatNumber(getBounty())..
                                "\n**Fragments:** "..formatNumber(getFragments()),
                            inline = false
                        }
                    },
                    timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")
                }}
            })
        })
    end)
end

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
    local promptGui = CoreGui:WaitForChild("RobloxPromptGui", 10)
    if not promptGui then return end

    local overlay = promptGui:WaitForChild("promptOverlay", 10)
    if not overlay then return end

    overlay.ChildAdded:Connect(function(child)
        if child.Name == "ErrorPrompt" then
            sendWebhook("DISCONNECTED - REJOIN")
            task.wait(2)
            pcall(function() child:Destroy() end)
            task.wait(3)
            TeleportService:Teleport(PlaceId, player)
        end
    end)
end)

-- ================= SERVER HOP =================
local hopping = false

local function getServers()
    local servers, cursor = {}, ""
    repeat
        local url =
            "https://games.roblox.com/v1/games/"..PlaceId..
            "/servers/Public?sortOrder=Asc&limit=100"..
            (cursor ~= "" and "&cursor="..cursor or "")

        local ok, res = pcall(function()
            return HttpService:JSONDecode(game:HttpGet(url))
        end)
        if not ok or not res then break end

        for _, v in ipairs(res.data or {}) do
            if v.id ~= JobId and v.playing < v.maxPlayers then
                table.insert(servers, v.id)
            end
        end

        cursor = res.nextPageCursor or ""
    until cursor == ""

    return servers
end

local function hopServer()
    if hopping then return end
    hopping = true

    sendWebhook("SERVER HOP")

    local servers = getServers()
    if #servers > 0 then
        TeleportService:TeleportToPlaceInstance(
            PlaceId,
            servers[math.random(#servers)],
            player
        )
    else
        TeleportService:Teleport(PlaceId, player)
    end
end

-- ================= HOP BUTTON =================
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

hopBtn.MouseButton1Click:Connect(hopServer)

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

print("READY | FULL SCRIPT: FPS + STATS + WEBHOOK + AUTO REJOIN + SERVER HOP")
