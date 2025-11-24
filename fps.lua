-- FPS + BOUNTY GÓC TRÊN TRÁI | SIÊU NHẸ – KHÔNG UI – CHỈ 2 DÒNG CHỮ
-- Copy xong execute là hiện luôn, đéo có frame, nút, viền gì hết

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

-- Tạo 2 dòng chữ trong CoreGui (đè lên hết, hiện luôn)
local gui = Instance.new("ScreenGui")
gui.Name = "FPSBountyCorner"
gui.ResetOnSpawn = false
gui.Parent = game:GetService("CoreGui")

-- FPS
local fpsLabel = Instance.new("TextLabel", gui)
fpsLabel.Position = UDim2.new(0, 12, 0, 10)
fpsLabel.Size = UDim2.new(0, 200, 0, 30)
fpsLabel.BackgroundTransparency = 1
fpsLabel.TextXAlignment = Enum.TextXAlignment.Left
fpsLabel.Font = Enum.Font.GothamBold
fpsLabel.TextSize = 28
fpsLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
fpsLabel.TextStrokeTransparency = 0.5
fpsLabel.Text = "FPS: 0"

-- Bounty
local bountyLabel = Instance.new("TextLabel", gui)
bountyLabel.Position = UDim2.new(0, 12, 0, 40)
bountyLabel.Size = UDim2.new(0, 400, 0, 35)
bountyLabel.BackgroundTransparency = 1
bountyLabel.TextXAlignment = Enum.TextXAlignment.Left
bountyLabel.Font = Enum.Font.GothamBlack
bountyLabel.TextSize = 32
bountyLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
bountyLabel.TextStrokeTransparency = 0.5
bountyLabel.Text = "Bounty: Loading..."

-- FPS rainbow
local t = 0
local fpsCount = 0
local lastTick = tick()

RunService.Heartbeat:Connect(function()
    t += 0.03
    fpsCount += 1
    if tick() - lastTick >= 1 then
        local fps = fpsCount
        fpsCount = 0
        lastTick = tick()

        local r = math.sin(t) * 127 + 128
        local g = math.sin(t + 2) * 127 + 128
        local b = math.sin(t + 4) * 127 + 128

        fpsLabel.Text = "FPS: " .. fps
        fpsLabel.TextColor3 = Color3.fromRGB(r, g, b)
    end

    -- Update Bounty
    local ls = player:FindFirstChild("leaderstats")
    if ls then
        local bounty = ls:FindFirstChild("Bounty") or ls:FindFirstChild("Bounty/Honor") or ls:FindFirstChild("Honor")
        if bounty then
            local val = bounty.Value
            local color = val >= 25000000 and Color3.fromRGB(255,50,50) or Color3.fromRGB(255,215,0)
            bountyLabel.TextColor3 = color
            bountyLabel.Text = "Bounty: " .. string.format("%d", val):reverse():gsub("(%d%d%d)", "%1."):reverse():gsub("^%.", "") .. "$"
        end
    end
end)

print("FPS + BOUNTY GÓC TRÊN TRÁI DONE – SIÊU NHẸ, ĐẸP, KHÔNG UI")
