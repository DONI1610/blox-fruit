-- FPS + BOUNTY (TOP-LEFT) + DISCORD WEBHOOK (FIX 2026)
-- nhẹ, không warn ảo, debug rõ F9

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

local player = Players.LocalPlayer

-- ==== DÁN WEBHOOK DISCORD THẬT VÀO ĐÂY ====
local WEBHOOK_URL = "https://discord.com/api/webhooks/1448861704568963095/8TsAmk08AwtX06g_HOrgM1gmY_KlCagueGf-5VCdqh6KCJXvF3lSMYYYGcvGgY5ng8rA"

-- ================= GUI =================
local gui = Instance.new("ScreenGui")
gui.Name = "FPS_BOUNTY_GUI"
gui.ResetOnSpawn = false
gui.Parent = game:GetService("CoreGui")

local fpsLabel = Instance.new("TextLabel", gui)
fpsLabel.Position = UDim2.new(0, 12, 0, 10)
fpsLabel.Size = UDim2.new(0, 200, 0, 28)
fpsLabel.BackgroundTransparency = 1
fpsLabel.TextXAlignment = Left
fpsLabel.Font = Enum.Font.GothamBold
fpsLabel.TextSize = 26
fpsLabel.Text = "FPS: 0"

local bountyLabel = Instance.new("TextLabel", gui)
bountyLabel.Position = UDim2.new(0, 12, 0, 38)
bountyLabel.Size = UDim2.new(0, 420, 0, 32)
bountyLabel.BackgroundTransparency = 1
bountyLabel.TextXAlignment = Left
bountyLabel.Font = Enum.Font.GothamBlack
bountyLabel.TextSize = 30
bountyLabel.Text = "Bounty: Loading..."

-- ============ HELPER ============
local function formatNumber(n)
    return tostring(n):reverse():gsub("(%d%d%d)", "%1."):reverse():gsub("^%.", "")
end

-- ============ WEBHOOK ============
local function sendWebhook()
    task.spawn(function()
        task.wait(5)

        local ls = player:FindFirstChild("leaderstats")
        if not ls then
            warn("[WEBHOOK] Không có leaderstats")
            return
        end

        local bountyObj =
            ls:FindFirstChild("Bounty")
            or ls:FindFirstChild("Bounty/Honor")
            or ls:FindFirstChild("Honor")

        local bounty = bountyObj and bountyObj.Value or 0
        local level = (ls:FindFirstChild("Level") and ls.Level.Value) or 0

        local payload = {
            embeds = {{
                title = "SCRIPT STARTED",
                description = string.format(
                    "**%s** vừa bật script\nBounty: **%s$**\nLevel: **%d**",
                    player.Name,
                    formatNumber(bounty),
                    level
                ),
                color = 3447003
            }}
        }

        local ok, err = pcall(function()
            HttpService:PostAsync(
                WEBHOOK_URL,
                HttpService:JSONEncode(payload),
                Enum.HttpContentType.ApplicationJson
            )
        end)

        if ok then
            print("[WEBHOOK] Gửi thành công")
        else
            warn("[WEBHOOK] Lỗi:", err)
        end
    end)
end

sendWebhook()

-- ============ FPS + BOUNTY UPDATE ============
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

    local ls = player:FindFirstChild("leaderstats")
    if not ls then return end

    local bountyObj =
        ls:FindFirstChild("Bounty")
        or ls:FindFirstChild("Bounty/Honor")
        or ls:FindFirstChild("Honor")

    if bountyObj then
        local v = bountyObj.Value
        bountyLabel.Text = "Bounty: " .. formatNumber(v) .. "$"
        bountyLabel.TextColor3 = v >= 25000000
            and Color3.fromRGB(255, 80, 80)
            or Color3.fromRGB(255, 215, 0)
    end
end)

print("FPS + BOUNTY + WEBHOOK READY (check F9 after 5s)")
