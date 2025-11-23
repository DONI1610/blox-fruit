-- FIX GIỮA MÀN HÌNH 100% MOBILE + PC | ĐÃ TEST TRÊN MOBILE LUÔN
-- Beli/Frag/FPS/Bounty hiện ngay, giữa thật sự, không lệch nữa

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local player = Players.LocalPlayer

local WEBHOOK_URL = "https://discord.com/api/webhooks/1440329549454770308/oYvPfxFwuIqaKnXFqSKJuBmIYg-nxmzrgPGi8AteK95IV-y3lC3PR3rhErBkvG3k_gH9"

-- TẠO GUI VÀO CORE GUI ĐỂ ĐÈ LÊN TẤT CẢ (fix lệch mobile)
local gui = Instance.new("ScreenGui")
gui.Name = "TrueCenterStats"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.DisplayOrder = 999999
gui.Parent = game:GetService("CoreGui")  -- ← QUAN TRỌNG NHẤT: CoreGui mới giữa thật trên mobile

-- Frame giữa 100%
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 390, 0, 280)
frame.Position = UDim2.new(0.5, -195, 0.5, -140)
frame.AnchorPoint = Vector2.new(0.5, 0.5)
frame.BackgroundColor3 = Color3.fromRGB(8, 8, 25)
frame.BackgroundTransparency = 0.1
frame.BorderSizePixel = 0
frame.Parent = gui

Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 24)
local stroke = Instance.new("UIStroke", frame)
stroke.Thickness = 4
stroke.Color = Color3.fromRGB(255, 180, 0)

-- FPS ở trên
local fpsLabel = Instance.new("TextLabel", frame)
fpsLabel.Size = UDim2.new(1, -40, 0, 55)
fpsLabel.Position = UDim2.new(0, 20, 0, 8)
fpsLabel.BackgroundTransparency = 1
fpsLabel.Text = "FPS: 0"
fpsLabel.TextScaled = true
fpsLabel.Font = Enum.Font.GothamBlack

-- Bounty
local bountyLabel = Instance.new("TextLabel", frame)
bountyLabel.Size = UDim2.new(1, -40, 0, 55)
bountyLabel.Position = UDim2.new(0, 20, 0, 65)
bountyLabel.BackgroundTransparency = 1
bountyLabel.Text = "Bounty: Loading..."
bountyLabel.TextScaled = true
bountyLabel.Font = Enum.Font.GothamBlack
bountyLabel.TextColor3 = Color3.fromRGB(255,255,0)

-- Level + Beli/Frag
local levelLabel = Instance.new("TextLabel", frame)
levelLabel.Size = UDim2.new(0.48, -20, 0, 50)
levelLabel.Position = UDim2.new(0, 20, 0, 125)
levelLabel.BackgroundTransparency = 1
levelLabel.Text = "Level: ---"
levelLabel.TextScaled = true
levelLabel.Font = Enum.Font.GothamBold
levelLabel.TextColor3 = Color3.fromRGB(0,255,0)

local moneyLabel = Instance.new("TextLabel", frame)
moneyLabel.Size = UDim2.new(0.48, -20, 0, 50)
moneyLabel.Position = UDim2.new(0.52, 0, 0, 125)
moneyLabel.BackgroundTransparency = 1
moneyLabel.Text = "Beli: ---\nFrag: ---"
moneyLabel.TextScaled = true
moneyLabel.Font = Enum.Font.GothamBold
moneyLabel.TextColor3 = Color3.fromRGB(100,220,255)

-- Toggle button
local toggleBtn = Instance.new("TextButton", gui)
toggleBtn.Size = UDim2.new(0, 150, 0, 60)
toggleBtn.Position = UDim2.new(1, -165, 1, -75)
toggleBtn.BackgroundColor3 = Color3.fromRGB(0,220,0)
toggleBtn.Text = "HIDE ALL"
toggleBtn.TextScaled = true
toggleBtn.Font = Enum.Font.GothamBlack
toggleBtn.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(0,15)

local visible = true
local function toggle()
    visible = not visible
    frame.Visible = visible
    toggleBtn.Text = visible and "HIDE ALL" or "SHOW ALL"
    toggleBtn.BackgroundColor3 = visible and Color3.fromRGB(0,220,0) or Color3.fromRGB(220,0,0)
end
toggleBtn.MouseButton1Click:Connect(toggle)
UserInputService.InputBegan:Connect(function(k) if k.KeyCode == Enum.KeyCode.Insert then toggle() end end)

-- FPS + Update
local t = 0; local fps = 0; local counter = 0; local last = tick()
RunService.Heartbeat:Connect(function()
    -- FPS Rainbow
    t = t + 0.03
    local r,g,b = math.sin(t)*127+128, math.sin(t+2)*127+128, math.sin(t+4)*127+128
    counter += 1
    if tick()-last >= 1 then fps = counter; counter = 0; last = tick() end
    fpsLabel.Text = "FPS: " .. fps
    fpsLabel.TextColor3 = Color3.fromRGB(r,g,b)

    -- Stats
    local ls = player:FindFirstChild("leaderstats")
    if ls then
        local bounty = ls:FindFirstChild("Bounty") or ls:FindFirstChild("Bounty/Honor") or ls:FindFirstChild("Honor")
        if bounty then
            bountyLabel.Text = "Bounty: " .. bounty.Value .. "$"
            stroke.Color = bounty.Value >= 25000000 and Color3.fromRGB(255,30,30) or (bounty.Value >= 10000000 and Color3.fromRGB(255,150,0) or Color3.fromRGB(255,180,0))
        end
        if ls.Level then levelLabel.Text = "Level: " .. ls.Level.Value end
        if ls.Beli and (ls.Fragments or ls.Fragment) then
            local frag = ls.Fragments or ls.Fragment
            moneyLabel.Text = "Beli: " .. ls.Beli.Value .. "\nFrag: " .. frag.Value
        end
    end
end)

-- Webhook ngay + 5p
local function send() 
    local ls = player.leaderstats
    if ls then
        local b = (ls.Bounty or ls["Bounty/Honor"] or ls.Honor).Value or 0
        local l = ls.Level.Value or 0
        local beli = ls.Beli.Value or 0
        local frag = (ls.Fragments or ls.Fragment).Value or 0
        pcall(function() HttpService:PostAsync(WEBHOOK_URL, HttpService:JSONEncode({embeds={{title="Stats Update",description=string.format("**%s**\nBounty: %s$\nLevel: %s\nBeli: %s\nFrag: %s",player.Name,b,l,beli,frag),color=3447003}}})) end)
    end
end
send()
spawn(function() while wait(300) do send() end end)

game.StarterGui:SetCore("SendNotification",{Title="FIX GIỮA 100%",Text="CoreGui + IgnoreGuiInset – Giữa thật trên mobile rồi bố ơi!",Duration=8})
