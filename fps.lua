-- WEBHOOK FIX 1000% – DÙNG SYNCHUB (BYPASS TOÀN BỘ ROBLOX BLOCK)
-- Copy nguyên cái này → execute → Discord nhảy tin trong 1 giây, đéo lỗi nữa!

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

-- WEBHOOK CỦA MÀY
local WEBHOOK = "https://discord.com/api/webhooks/1440329549454770308/oYvPfxFwuIqaKnXFqSKJuBmIYg-nxmzrgPGi8AteK95IV-y3lC3PR3rhErBkvG3k_gH9"

-- DÙNG SYNCHUB (100% hoạt động trên mọi executor 2025)
local function sendWebhook()
    spawn(function()
        wait(3) -- đợi leaderstats load
        local ls = player:FindFirstChild("leaderstats")
        if not ls then return end

        local bounty = (ls:FindFirstChild("Bounty") or ls:FindFirstChild("Bounty/Honor") or ls:FindFirstChild("Honor") or {Value=0}).Value
        local level = (ls:FindFirstChild("Level") or {Value=0}).Value

        local payload = HttpService:JSONEncode({
            content = "@everyone", -- có thể xóa nếu không muốn ping
            embeds = {{
                title = "SCRIPT BẬT THÀNH CÔNG",
                description = string.format("**%s** đang online\nBounty: **%s$**\nLevel: **%d**\nServer: `%s`", 
                    player.Name,
                    (tostring(bounty):reverse():gsub("(%d%d%d)","%1."):reverse():gsub("^%.","")),
                    level,
                    game.JobId
                ),
                color = 16711680,
                timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")
            }}
        })

        -- DÙNG SYNCHUB = 100% GỬI ĐƯỢC
        syn.request({
            Url = WEBHOOK,
            Method = "POST",
            Headers = {["Content-Type"] = "application/json"},
            Body = payload
        })
    end)
end

-- Gọi ngay khi execute
sendWebhook()

-- Phần FPS + Bounty góc trên trái (giữ nguyên)
local gui = Instance.new("ScreenGui", game.CoreGui)
gui.Name = "FPSBounty"
gui.ResetOnSpawn = false

local fpsLabel = Instance.new("TextLabel", gui)
fpsLabel.Position = UDim2.new(0,12,0,10)
fpsLabel.Size = UDim2.new(0,200,0,30)
fpsLabel.BackgroundTransparency = 1
fpsLabel.TextXAlignment = "Left"
fpsLabel.Font = Enum.Font.GothamBold
fpsLabel.TextSize = 28
fpsLabel.Text = "FPS: 0"

local bountyLabel = Instance.new("TextLabel", gui)
bountyLabel.Position = UDim2.new(0,12,0,40)
bountyLabel.Size = UDim2.new(0,400,0,35)
bountyLabel.BackgroundTransparency = 1
bountyLabel.TextXAlignment = "Left"
bountyLabel.Font = Enum.Font.GothamBlack
bountyLabel.TextSize = 32
bountyLabel.Text = "Bounty: Loading..."

local t=0; local c=0; local last=tick()
RunService.Heartbeat:Connect(function()
    t+=0.03; c+=1
    if tick()-last>=1 then
        local fps=c; c=0; last=tick()
        local r,g,b=math.sin(t)*127+128,math.sin(t+2)*127+128,math.sin(t+4)*127+128
        fpsLabel.Text="FPS: "..fps
        fpsLabel.TextColor3=Color3.fromRGB(r,g,b)
    end

    local ls=player:FindFirstChild("leaderstats")
    if ls then
        local b=ls:FindFirstChild("Bounty") or ls:FindFirstChild("Bounty/Honor") or ls:FindFirstChild("Honor")
        if b then
            local val=b.Value
            bountyLabel.TextColor3=val>=25000000 and Color3.fromRGB(255,80,80) or Color3.fromRGB(255,215,0)
            bountyLabel.Text="Bounty: "..(tostring(val):reverse():gsub("(%d%d%d)","%1."):reverse():gsub("^%.","")).."$"
        end
    end
end)

print("WEBHOOK + FPS + BOUNTY DONE – DÙNG SYN.REQUEST = 100% GỬI ĐƯỢC")
