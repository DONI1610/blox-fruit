-- FPS + BOUNTY + AIMBOT LIST NGƯỜI TRONG SERVER (CHỌN BẰNG NÚT)
-- Click tên → aim ngay, click lại → tắt

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

_G.AimbotTarget = nil  -- người đang bị aim

-- GUI chính (CoreGui để đè hết)
local gui = Instance.new("ScreenGui")
gui.Name = "AimbotList"
gui.ResetOnSpawn = false
gui.Parent = game:GetService("CoreGui")

-- FPS + Bounty góc trên trái
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

local statusLabel = Instance.new("TextLabel", gui)
statusLabel.Position = UDim2.new(0,12,0,75)
statusLabel.Size = UDim2.new(0,500,0,30)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "Aimbot: OFF"
statusLabel.TextColor3 = Color3.fromRGB(255,100,100)
statusLabel.Font = Enum.Font.GothamSemibold
statusLabel.TextSize = 26
statusLabel.TextXAlignment = "Left"

-- Frame danh sách người chơi (góc trên phải)
local listFrame = Instance.new("Frame", gui)
listFrame.Size = UDim2.new(0, 260, 0, 400)
listFrame.Position = UDim2.new(1, -270, 0, 10)
listFrame.BackgroundColor3 = Color3.fromRGB(10,10,20)
listFrame.BackgroundTransparency = 0.1
listFrame.BorderSizePixel = 0
Instance.new("UICorner", listFrame).CornerRadius = UDim.new(0,12)
local stroke = Instance.new("UIStroke", listFrame)
stroke.Thickness = 3
stroke.Color = Color3.fromRGB(255,180,0)

local title = Instance.new("TextLabel", listFrame)
title.Size = UDim2.new(1,0,0,40)
title.BackgroundTransparency = 1
title.Text = "SELECT TARGET"
title.TextColor3 = Color3.fromRGB(255,215,0)
title.Font = Enum.Font.GothamBlack
title.TextSize = 24

local scroll = Instance.new("ScrollingFrame", listFrame)
scroll.Size = UDim2.new(1,-10,1,-50)
scroll.Position = UDim2.new(0,5,0,45)
scroll.BackgroundTransparency = 1
scroll.ScrollBarThickness = 6
scroll.CanvasSize = UDim2.new(0,0,0,0)

-- Tạo nút cho từng người chơi
local function updateList()
    for _,v in pairs(scroll:GetChildren()) do if v:IsA("TextButton") then v:Destroy() end end
    
    local y = 0
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local btn = Instance.new("TextButton", scroll)
            btn.Size = UDim2.new(1,-10,0,40)
            btn.Position = UDim2.new(0,5,0,y)
            btn.BackgroundColor3 = Color3.fromRGB(30,30,50)
            btn.TextColor3 = Color3.fromRGB(255,255,255)
            btn.Font = Enum.Font.GothamBold
            btn.TextSize = 20
            btn.Text = p.DisplayName .. " (@" .. p.Name .. ")"
            
            -- Highlight nếu đang aim
            if _G.AimbotTarget == p then
                btn.BackgroundColor3 = Color3.fromRGB(0,150,0)
            end
            
            btn.MouseButton1Click:Connect(function()
                if _G.AimbotTarget == p then
                    _G.AimbotTarget = nil
                    statusLabel.Text = "Aimbot: OFF"
                    statusLabel.TextColor3 = Color3.fromRGB(255,100,100)
                else
                    _G.AimbotTarget = p
                    statusLabel.Text = "Aimbot: " .. p.DisplayName
                    statusLabel.TextColor3 = Color3.fromRGB(0,255,0)
                end
                updateList() -- refresh màu
            end)
            
            y += 45
        end
    end
    scroll.CanvasSize = UDim2.new(0,0,0,y)
end

-- Cập nhật danh sách mỗi 2s + khi có người vào/ra
Players.PlayerAdded:Connect(updateList)
Players.PlayerRemoving:Connect(updateList)
spawn(function() while wait(2) do updateList() end end)
updateList()

-- Aimbot loop
RunService.Heartbeat:Connect(function()
    -- FPS + Bounty
    local ls = player:FindFirstChild("leaderstats")
    if ls then
        local b = ls:FindFirstChild("Bounty") or ls:FindFirstChild("Bounty/Honor") or ls:FindFirstChild("Honor")
        if b then
            local val = b.Value
            bountyLabel.TextColor3 = val >= 25000000 and Color3.fromRGB(255,80,80) or Color3.fromRGB(255,215,0)
            bountyLabel.Text = "Bounty: "..(tostring(val):reverse():gsub("(%d%d%d)","%1."):reverse():gsub("^%.","")).."$"
        end
    end

    -- Aimbot
    if _G.AimbotTarget and _G.AimbotTarget.Character and _G.AimbotTarget.Character:FindFirstChild("Head") then
        local head = _G.AimbotTarget.Character.Head
        local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        if root then
            root.CFrame = CFrame.new(root.Position, head.Position)
        end
    end
end)

-- FPS Rainbow
local t=0; local c=0; local last=tick()
RunService.Heartbeat:Connect(function()
    t+=0.03; c+=1
    if tick()-last>=1 then
        local fps=c; c=0; last=tick()
        local r,g,b=math.sin(t)*127+128,math.sin(t+2)*127+128,math.sin(t+4)*127+128
        fpsLabel.Text="FPS: "..fps
        fpsLabel.TextColor3=Color3.fromRGB(r,g,b)
    end
end)

game.StarterGui:SetCore("SendNotification",{
    Title="AIMBOT LIST READY",
    Text="Click tên người chơi ở góc phải để aim!",
    Duration=6
})
