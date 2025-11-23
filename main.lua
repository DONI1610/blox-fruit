-- BLOX FRUITS STATS FIXED | FULL STATS + GỬI MỖI 5P | 2025 FINAL
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local player = Players.LocalPlayer

-- THAY WEBHOOK CỦA MÀY VÀO ĐÂY
local WEBHOOK_URL = "https://discord.com/api/webhooks/1440329549454770308/oYvPfxFwuIqaKnXFqSKJuBmIYg-nxmzrgPGi8AteK95IV-y3lC3PR3rhErBkvG3k_gH9"

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "FinalStats"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

-- MENU GIỮA MÀN HÌNH
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 360, 0, 200)
frame.Position = UDim2.new(0.5, -180, 0.5, -100)
frame.AnchorPoint = Vector2.new(0.5, 0.5)
frame.BackgroundColor3 = Color3.fromRGB(10, 10, 25)
frame.BackgroundTransparency = 0.15
frame.BorderSizePixel = 0
frame.Parent = screenGui

Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 20)
local stroke = Instance.new("UIStroke", frame)
stroke.Thickness = 4
stroke.Color = Color3.fromRGB(255, 170, 0)

-- Text Labels
local bountyLabel = Instance.new("TextLabel", frame)
bountyLabel.Size = UDim2.new(1, -30, 0.35, 0)
bountyLabel.Position = UDim2.new(0, 15, 0, 12)
bountyLabel.BackgroundTransparency = 1
bountyLabel.Text = "Bounty/Honor: Loading..."
bountyLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
bountyLabel.TextScaled = true
bountyLabel.Font = Enum.Font.GothamBlack

local levelLabel = Instance.new("TextLabel", frame)
levelLabel.Size = UDim2.new(1, -30, 0.25, 0)
levelLabel.Position = UDim2.new(0, 15, 0.35, 0)
levelLabel.BackgroundTransparency = 1
levelLabel.Text = "Level: ---"
levelLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
levelLabel.TextScaled = true
levelLabel.Font = Enum.Font.GothamBold

local moneyLabel = Instance.new("TextLabel", frame)
moneyLabel.Size = UDim2.new(1, -30, 0.35, 0)
moneyLabel.Position = UDim2.new(0, 15, 0.6, 0)
moneyLabel.BackgroundTransparency = 1
moneyLabel.Text = "Beli: ---\nFragments: ---"
moneyLabel.TextColor3 = Color3.fromRGB(170, 170, 255)
moneyLabel.TextScaled = false
moneyLabel.TextSize = 24
moneyLabel.Font = Enum.Font.GothamBold

-- NÚT ẨN/HIỆN
local toggleBtn = Instance.new("TextButton", screenGui)
toggleBtn.Size = UDim2.new(0, 140, 0, 55)
toggleBtn.Position = UDim2.new(1, -155, 1, -70)
toggleBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
toggleBtn.Text = "HIDE STATS"
toggleBtn.TextColor3 = Color3.new(1,1,1)
toggleBtn.TextScaled = true
toggleBtn.Font = Enum.Font.GothamBlack
Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(0, 14)

local visible = true
local function toggle()
    visible = not visible
    frame.Visible = visible
    toggleBtn.Text = visible and "HIDE STATS" or "SHOW STATS"
    toggleBtn.BackgroundColor3 = visible and Color3.fromRGB(0,200,0) or Color3.fromRGB(200,0,0)
end
toggleBtn.MouseButton1Click:Connect(toggle)
UserInputService.InputBegan:Connect(function(k) if k.KeyCode == Enum.KeyCode.Insert then toggle() end end)

-- GỬI WEBHOOK
local function send(msg, color)
    if not WEBHOOK_URL or WEBHOOK_URL:find("14403295") then return end
    pcall(function()
        HttpService:PostAsync(WEBHOOK_URL, HttpService:JSONEncode({
            embeds = {{description = msg, color = color or 3447003, timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")}}
        }))
    end)
end

-- UPDATE STATS (chắc chắn hiện đầy đủ ngay từ đầu)
local function updateStats()
    local ls = player:FindFirstChild("leaderstats")
    if not ls then return end

    local bounty = ls:FindFirstChild("Bounty") or ls:FindFirstChild("Honor") or ls:FindFirstChild("Bounty/Honor")
    local level = ls:FindFirstChild("Level")
    local beli = ls:FindFirstChild("Beli")
    local frag = ls:FindFirstChild("Fragments") or ls:FindFirstChild("Fragment")

    if bounty then
        local val = bounty.Value
        bountyLabel.Text = "Bounty/Honor: "..val.."$"
        if val >= 25000000 then
            bountyLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
            stroke.Color = Color3.fromRGB(255, 0, 0)
        elseif val >= 10000000 then
            bountyLabel.TextColor3 = Color3.fromRGB(255, 100, 0)
            stroke.Color = Color3.fromRGB(255, 100, 0)
        end
    end
    if level then levelLabel.Text = "Level: "..level.Value end
    if beli then moneyLabel.Text = "Beli: "..beli.Value.."\nFragments: "..(frag and frag.Value or "0") end
end

-- Loop update liên tục + đợi leaderstats
spawn(function()
    while wait(0.5) do
        if player:FindFirstChild("leaderstats") then
            updateStats()
        end
    end
end)

-- GỬI MỖI 5 PHÚT
spawn(function()
    while wait(300) do
        local ls = player:FindFirstChild("leaderstats")
        if not ls then continue end
        local b = (ls:FindFirstChild("Bounty") or ls:FindFirstChild("Honor") or ls:FindFirstChild("Bounty/Honor")) and (ls:FindFirstChild("Bounty") or ls:FindFirstChild("Honor") or ls:FindFirstChild("Bounty/Honor")).Value or 0
        local l = ls:FindFirstChild("Level") and ls.Level.Value or 0
        local be = ls:FindFirstChild("Beli") and ls.Beli.Value or 0
        local f = (ls:FindFirstChild("Fragments") or ls:FindFirstChild("Fragment")) and (ls:FindFirstChild("Fragments") or ls:FindFirstChild("Fragment")).Value or 0

        send(string.format("**%s** đang online\n**Bounty/Honor:** `%s$`\n**Level:** `%s`\n**Beli:** `%s`\n**Fragments:** `%s`", player.Name, b, l, be, f), 3447003)
    end
end)

-- Load xong
send("**SCRIPT ĐÃ LOAD 100%** – "..player.Name.." online, đang cày 30M+", 65280)
game.StarterGui:SetCore("SendNotification",{Title="STATS HOÀN HẢO", Text="Level + Beli + Frag hiện đầy đủ rồi nha bố!", Duration=6})
