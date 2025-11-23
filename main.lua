-- My Bounty/Honor Display Blox Fruits | FIXED By Grok 🔥
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer

-- Tạo ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "MyStatsDisplay"
screenGui.Parent = player:WaitForChild("PlayerGui")
screenGui.ResetOnSpawn = false

-- Frame chính (lớn hơn, đẹp hơn)
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 280, 0, 120)
frame.Position = UDim2.new(0, 20, 0, 20)
frame.BackgroundColor3 = Color3.new(0, 0, 0)
frame.BackgroundTransparency = 0.15
frame.BorderSizePixel = 0
frame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 15)
corner.Parent = frame

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.new(1, 1, 0)
stroke.Thickness = 2.5
stroke.Parent = frame

-- Title
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -20, 0.2, 0)
title.Position = UDim2.new(0, 10, 0, 5)
title.BackgroundTransparency = 1
title.Text = "MY STATS 💎"
title.TextColor3 = Color3.new(1, 1, 1)
title.TextScaled = true
title.Font = Enum.Font.GothamBold
title.Parent = frame

-- Bounty/Honor
local bountyLabel = Instance.new("TextLabel")
bountyLabel.Size = UDim2.new(1, -20, 0.2, 0)
bountyLabel.Position = UDim2.new(0, 10, 0.2, 0)
bountyLabel.BackgroundTransparency = 1
bountyLabel.Text = "Bounty/Honor: Loading..."
bountyLabel.TextColor3 = Color3.new(1, 1, 0)
bountyLabel.TextScaled = true
bountyLabel.Font = Enum.Font.GothamBold
bountyLabel.Parent = frame

-- Level
local levelLabel = Instance.new("TextLabel")
levelLabel.Size = UDim2.new(0.5, -10, 0.2, 0)
levelLabel.Position = UDim2.new(0, 10, 0.4, 0)
levelLabel.BackgroundTransparency = 1
levelLabel.Text = "Level: Loading..."
levelLabel.TextColor3 = Color3.new(0, 1, 0)
levelLabel.TextScaled = true
levelLabel.Font = Enum.Font.Gotham
levelLabel.Parent = frame

-- Beli + Fragments
local moneyLabel = Instance.new("TextLabel")
moneyLabel.Size = UDim2.new(0.5, -10, 0.2, 0)
moneyLabel.Position = UDim2.new(0.5, 0, 0.4, 0)
moneyLabel.BackgroundTransparency = 1
moneyLabel.Text = "Beli/Frag: Loading..."
moneyLabel.TextColor3 = Color3.new(0.8, 0.8, 1)
moneyLabel.TextScaled = true
moneyLabel.Font = Enum.Font.Gotham
moneyLabel.Parent = frame

-- Toggle hint
local toggleLabel = Instance.new("TextLabel")
toggleLabel.Size = UDim2.new(1, -20, 0.2, 0)
toggleLabel.Position = UDim2.new(0, 10, 0.6, 0)
toggleLabel.BackgroundTransparency = 1
toggleLabel.Text = "Nhấn INSERT ẩn/hiện | Kéo thả 👆"
toggleLabel.TextColor3 = Color3.new(0.7, 0.7, 0.7)
toggleLabel.TextScaled = true
toggleLabel.Font = Enum.Font.Gotham
toggleLabel.Parent = frame

-- Draggable
local dragging, dragStart, startPos
frame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = frame.Position
    end
end)
frame.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
end)

-- Toggle INSERT
local visible = true
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.Insert then
        visible = not visible
        frame.Visible = visible
        game.StarterGui:SetCore("SendNotification", {
            Title = "My Stats"; Text = visible and "HIỂN THỊ 🔥" or "ẨN"; Duration = 1.5
        })
    end
end)

-- Update real-time (wait leaderstats load)
spawn(function()
    repeat wait(0.1) until player:FindFirstChild("leaderstats")
end)

RunService.Heartbeat:Connect(function()
    local leaderstats = player:FindFirstChild("leaderstats")
    if leaderstats then
        -- Bounty/Honor
        local bountyHonor = leaderstats:FindFirstChild("Bounty/Honor")
        if bountyHonor then
            bountyLabel.Text = "Bounty/Honor: " .. bountyHonor.Value .. "$ 💰"
            local val = bountyHonor.Value
            if val > 10e6 then
                bountyLabel.TextColor3 = Color3.new(1, 0, 0)
                stroke.Color = Color3.new(1, 0, 0)
            elseif val > 1e6 then
                bountyLabel.TextColor3 = Color3.new(1, 0.5, 0)
                stroke.Color = Color3.new(1, 0.5, 0)
            else
                bountyLabel.TextColor3 = Color3.new(1, 1, 0)
                stroke.Color = Color3.new(1, 1, 0)
            end
        end
        
        -- Level
        local level = leaderstats:FindFirstChild("Level")
        if level then levelLabel.Text = "Level: " .. level.Value end
        
        -- Beli & Fragments
        local beli = leaderstats:FindFirstChild("Beli")
        local frag = leaderstats:FindFirstChild("Fragments")
        if beli and frag then
            moneyLabel.Text = "Beli: " .. beli.Value .. " | Frag: " .. frag.Value
        end
    end
end)

print("FIXED Stats Display LOADED! INSERT toggle 🚀")
game.StarterGui:SetCore("SendNotification", {
    Title = "Stats FIXED"; Text = "Bounty/Honor + Full | Góc trên trái"; Duration = 4
})
