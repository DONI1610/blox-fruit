-- My Bounty Display Blox Fruits | Custom Grok - Siêu đơn giản
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer

-- Tạo ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "MyBountyDisplay"
screenGui.Parent = player:WaitForChild("PlayerGui")
screenGui.ResetOnSpawn = false

-- Frame chính (đẹp, bo góc, draggable)
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 250, 0, 80)
frame.Position = UDim2.new(0, 20, 0, 20)  -- Góc trên trái
frame.BackgroundColor3 = Color3.new(0, 0, 0)
frame.BackgroundTransparency = 0.2
frame.BorderSizePixel = 0
frame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = frame

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.new(1, 0.8, 0)  -- Vàng gold bounty
stroke.Thickness = 2
stroke.Parent = frame

-- Text Bounty chính
local bountyLabel = Instance.new("TextLabel")
bountyLabel.Size = UDim2.new(1, -20, 0.7, 0)
bountyLabel.Position = UDim2.new(0, 10, 0, 10)
bountyLabel.BackgroundTransparency = 1
bountyLabel.Text = "Bounty: Loading..."
bountyLabel.TextColor3 = Color3.new(1, 1, 0)
bountyLabel.TextScaled = true
bountyLabel.Font = Enum.Font.GothamBold
bountyLabel.Parent = frame

-- Toggle text nhỏ
local toggleLabel = Instance.new("TextLabel")
toggleLabel.Size = UDim2.new(1, -20, 0.3, 0)
toggleLabel.Position = UDim2.new(0, 10, 0.7, 0)
toggleLabel.BackgroundTransparency = 1
toggleLabel.Text = "Nhấn INSERT ẩn/hiện"
toggleLabel.TextColor3 = Color3.new(0.8, 0.8, 0.8)
toggleLabel.TextScaled = true
toggleLabel.Font = Enum.Font.Gotham
toggleLabel.Parent = frame

-- Draggable (kéo thả thoải mái)
local dragging = false
local dragStart = nil
local startPos = nil

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
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

-- Toggle ON/OFF bằng INSERT
local visible = true
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.Insert then
        visible = not visible
        frame.Visible = visible
        game.StarterGui:SetCore("SendNotification", {
            Title = "My Bounty";
            Text = visible and "HIỂN THỊ" or "ẨN";
            Duration = 1.5
        })
    end
end)

-- Update Bounty real-time
RunService.Heartbeat:Connect(function()
    local leaderstats = player:FindFirstChild("leaderstats")
    if leaderstats then
        local bounty = leaderstats:FindFirstChild("Bounty")
        if bounty then
            bountyLabel.Text = "Bounty: " .. bounty.Value .. "$ 💰"
            
            -- Color theo bounty (đỏ = rich)
            if bounty.Value > 10e6 then
                bountyLabel.TextColor3 = Color3.new(1, 0, 0)
                stroke.Color = Color3.new(1, 0, 0)
            elseif bounty.Value > 1e6 then
                bountyLabel.TextColor3 = Color3.new(1, 0.5, 0)
                stroke.Color = Color3.new(1, 0.5, 0)
            else
                bountyLabel.TextColor3 = Color3.new(1, 1, 0)
                stroke.Color = Color3.new(1, 0.8, 0)
            end
        end
    end
end)

print("My Bounty Display LOADED! Kéo thả + INSERT toggle 🚀")
game.StarterGui:SetCore("SendNotification", {
    Title = "My Bounty ON";
    Text = "Góc trên trái | INSERT OFF";
    Duration = 3
})
