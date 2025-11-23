-- MY STATS CENTER + WEBHOOK CỨNG + TOGGLE | Blox Fruits 2025 | Grok Ultimate 🔥
-- Chỉ cần execute là xong, không cần nhập webhook nữa!
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local player = Players.LocalPlayer
-- WEBHOOK CỨNG Ở ĐÂY – THAY BẰNG WEBHOOK DISCORD CỦA MÀY (chỉ cần sửa 1 dòng này thôi!)
local WEBHOOK_URL = "https://discord.com/api/webhooks/1440329549454770308/oYvPfxFwuIqaKnXFqSKJuBmIYg-nxmzrgPGi8AteK95IV-y3lC3PR3rhErBkvG3k_gH9" -- THAY DÒNG NÀY NHA CU!!!
-- Tạo ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "MyStatsHardWebhook"
screenGui.Parent = player:WaitForChild("PlayerGui")
screenGui.ResetOnSpawn = false
-- Frame chính (CENTER MÀN HÌNH)
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 340, 0, 180)
frame.Position = UDim2.new(0.5, -170, 0.5, -90)
frame.BackgroundColor3 = Color3.new(0.05, 0.05, 0.1)
frame.BackgroundTransparency = 0.1
frame.BorderSizePixel = 0
frame.Parent = screenGui
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 18)
corner.Parent = frame
local stroke = Instance.new("UIStroke")
stroke.Color = Color3.new(1, 0.8, 0)
stroke.Thickness = 3
stroke.Parent = frame
-- Stats Frame (có thể tắt)
local statsFrame = Instance.new("Frame")
statsFrame.Size = UDim2.new(1, -20, 0.55, 0)
statsFrame.Position = UDim2.new(0, 10, 0, 10)
statsFrame.BackgroundTransparency = 1
statsFrame.Parent = frame
statsFrame.Visible = true
-- Title
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1,0,0.25,0)
title.BackgroundTransparency = 1
title.Text = "MY STATS 💰"
title.TextColor3 = Color3.new(1,1,1)
title.TextScaled = true
title.Font = Enum.Font.GothamBold
title.Parent = statsFrame
-- Bounty
local bountyLabel = Instance.new("TextLabel")
bountyLabel.Size = UDim2.new(1,0,0.4,0)
bountyLabel.Position = UDim2.new(0,0,0.25,0)
bountyLabel.BackgroundTransparency = 1
bountyLabel.Text = "Bounty/Honor: Loading..."
bountyLabel.TextColor3 = Color3.new(1,1,0)
bountyLabel.TextScaled = true
bountyLabel.Font = Enum.Font.GothamBold
bountyLabel.Parent = statsFrame
-- Level + Beli/Frag
local levelLabel = Instance.new("TextLabel")
levelLabel.Size = UDim2.new(0.48,0,0.35,0)
levelLabel.Position = UDim2.new(0,0,0.65,0)
levelLabel.BackgroundTransparency = 1
levelLabel.Text = "Level: ---"
levelLabel.TextColor3 = Color3.new(0,1,0)
levelLabel.TextScaled = true
levelLabel.Parent = statsFrame
local moneyLabel = Instance.new("TextLabel")
moneyLabel.Size = UDim2.new(0.48,0,0.35,0)
moneyLabel.Position = UDim2.new(0.52,0,0.65,0)
moneyLabel.BackgroundTransparency = 1
moneyLabel.Text = "Beli/Frag:\n---"
moneyLabel.TextColor3 = Color3.new(0.8,0.8,1)
moneyLabel.TextScaled = false
moneyLabel.TextSize = 16
moneyLabel.Parent = statsFrame
-- Nút TOGGLE STATS (duy nhất cần bấm)
local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(0.9,0,0.25,0)
toggleBtn.Position = UDim2.new(0.05,0,0.75,0)
toggleBtn.BackgroundColor3 = Color3.new(0,1,0)
toggleBtn.Text = "STATS ON"
toggleBtn.TextColor3 = Color3.new(1,1,1)
toggleBtn.TextScaled = true
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.Parent = frame
local btnCorner = Instance.new("UICorner")
btnCorner.CornerRadius = UDim.new(0,10)
btnCorner.Parent = toggleBtn
-- Hint nhỏ
local hint = Instance.new("TextLabel")
hint.Size = UDim2.new(1,-20,0.15,0)
hint.Position = UDim2.new(0,10,0.88,0)
hint.BackgroundTransparency = 1
hint.Text = "INSERT: Ẩn hẳn | Kéo thả 👆"
hint.TextColor3 = Color3.new(0.7,0.7,0.7)
hint.TextScaled = true
hint.Font = Enum.Font.Gotham
hint.Parent = frame
-- Variables
local oldBounty = 0
local statsOn = true
-- Draggable
local dragging = false
frame.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        local delta = i.Position
        local pos = frame.Position
        i.Changed:Connect(function()
            if i.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
        game:GetService("UserInputService").InputChanged:Connect(function(input)
            if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                local d = input.Position - delta
                frame.Position = UDim2.new(pos.X.Scale, pos.X.Offset + d.X, pos.Y.Scale, pos.Y.Offset + d.Y)
            end
        end)
    end
end)
-- INSERT = ẩn hẳn
UserInputService.InputBegan:Connect(function(i)
    if i.KeyCode == Enum.KeyCode.Insert then
        frame.Visible = not frame.Visible
    end
end)
-- TOGGLE STATS BUTTON
toggleBtn.MouseButton1Click:Connect(function()
    statsOn = not statsOn
    statsFrame.Visible = statsOn
    toggleBtn.Text = statsOn and "STATS ON" or "STATS OFF"
    toggleBtn.BackgroundColor3 = statsOn and Color3.new(0,1,0) or Color3.new(1,0,0)
end)
-- Gửi webhook
local function send(msg, color)
    if WEBHOOK_URL == "https://discord.com/api/webhooks/1234567890/ABCDEF..." then
        return -- chưa thay webhook thì không gửi
    end
    local data = {embeds = {{title = "Blox Fruits Bounty Alert", description = msg, color = color or 16766720, timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ"), footer = {text = player.Name.. " • "..os.date("%H:%M")}}}}
    pcall(function()
        HttpService:PostAsync(WEBHOOK_URL, HttpService:JSONEncode(data), Enum.HttpContentType.ApplicationJson)
    end)
end
-- Load + Update
spawn(function() repeat wait() until player:FindFirstChild("leaderstats") end)
RunService.Heartbeat:Connect(function()
    local ls = player.leaderstats
    if not ls then return end
    local bounty = ls:FindFirstChild("Bounty/Honor")
    if bounty then
        local val = bounty.Value
        if statsOn then
            bountyLabel.Text = "Bounty/Honor: " .. val .. "$"
            if val > 10000000 then
                bountyLabel.TextColor3 = Color3.new(1,0,0)
                stroke.Color = Color3.new(1,0,0)
            elseif val > 1000000 then
                bountyLabel.TextColor3 = Color3.new(1,0.5,0)
                stroke.Color = Color3.new(1,0.5,0)
            else
                bountyLabel.TextColor3 = Color3.new(1,1,0)
                stroke.Color = Color3.new(1,0.8,0)
            end
        end
        -- AUTO GỬI +100k
        local diff = val - oldBounty
        if diff >= 100000 then
            send("**Bounty mới: "..val.."$** | **+"..diff.."$**", val > 10000000 and 16711680 or 16755200)
            oldBounty = val
        end
    end
    if statsOn then
        local lvl = ls:FindFirstChild("Level")
        if lvl then levelLabel.Text = "Level: " .. lvl.Value end
        local beli = ls:FindFirstChild("Beli")
        local frag = ls:FindFirstChild("Fragments")
        if beli and frag then
            moneyLabel.Text = "Beli: "..beli.Value.."\nFrag: "..frag.Value
        end
    end
end)
-- Thông báo loaded
send("**SCRIPT ĐÃ LOAD!** "..player.Name.." đang online và săn bounty", 65280)
game.StarterGui:SetCore("SendNotification", {Title="STATS + WEBHOOK ON"; Text="Webhook cứng rồi! Chỉ cần execute là bay"; Duration=5})
print("WEBHOOK CỨNG LOADED ")
thêm lever beli farg đi cu cập nhật webhook sau 5p
