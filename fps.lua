-- BLOX FRUITS 2025 | FPS + BOUNTY HIỆN NGAY + AIMBOT CHỌN NGƯỜI (MOBILE/PC HOÀN HẢO)
-- Bounty hiện ngay lập tức, không "Loading..." nữa
-- Nút TARGET to đùng góc phải trên – click mở list chọn người

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

_G.AimbotTarget = nil
local bountyValue = 0

-- ===================== GUI =====================
local gui = Instance.new("ScreenGui")
gui.Name = "BloxAimbot2025"
gui.ResetOnSpawn = false
gui.Parent = game:GetService("CoreGui")

-- Thanh trên cùng (FPS + Bounty + Status)
local topBar = Instance.new("TextLabel", gui)
topBar.Size = UDim2.new(1, 0, 0, 50)
topBar.Position = UDim2.new(0, 0, 0, 0)
topBar.BackgroundColor3 = Color3.fromRGB(8, 8, 30)
topBar.BackgroundTransparency = 0.15
topBar.Text = "FPS: 0 | Bounty: 0$ | Aimbot: OFF"
topBar.TextColor3 = Color3.new(1, 1, 1)
topBar.Font = Enum.Font.GothamBlack
topBar.TextSize = 28
topBar.TextXAlignment = Enum.TextXAlignment.Center
Instance.new("UICorner", topBar).CornerRadius = UDim.new(0, 12)

-- Nút TARGET to đùng (mobile dễ bấm)
local targetBtn = Instance.new("TextButton", gui)
targetBtn.Size = UDim2.new(0, 100, 0, 100)
targetBtn.Position = UDim2.new(1, -115, 0, 10)
targetBtn.BackgroundColor3 = Color3.fromRGB(255, 80, 0)
targetBtn.Text = "TARGET"
targetBtn.TextColor3 = Color3.new(1, 1, 1)
targetBtn.Font = Enum.Font.GothamBlack
targetBtn.TextSize = 32
Instance.new("UICorner", targetBtn).CornerRadius = UDim.new(0, 24)
local stroke = Instance.new("UIStroke", targetBtn)
stroke.Thickness = 4
stroke.Color = Color3.fromRGB(255, 200, 0)

-- Danh sách người chơi
local listFrame = Instance.new("Frame", gui)
listFrame.Size = UDim2.new(0, 340, 0, 520)
listFrame.Position = UDim2.new(1, -355, 0, 115)
listFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 35)
listFrame.BackgroundTransparency = 0.1
listFrame.Visible = false
Instance.new("UICorner", listFrame).CornerRadius = UDim.new(0, 20)
Instance.new("UIStroke", listFrame).Thickness = 4

local title = Instance.new("TextLabel", listFrame)
title.Size = UDim2.new(1, 0, 0, 70)
title.BackgroundTransparency = 1
title.Text = "CHỌN ĐỐI THỦ"
title.TextColor3 = Color3.fromRGB(255, 215, 0)
title.Font = Enum.Font.GothamBlack
title.TextSize = 36

local scroll = Instance.new("ScrollingFrame", listFrame)
scroll.Size = UDim2.new(1, -20, 1, -90)
scroll.Position = UDim2.new(0, 10, 0, 80)
scroll.BackgroundTransparency = 1
scroll.ScrollBarThickness = 12
scroll.CanvasSize = UDim2.new(0, 0, 0, 0)

-- Toggle list
targetBtn.MouseButton1Click:Connect(function()
    listFrame.Visible = not listFrame.Visible
    targetBtn.Text = listFrame.Visible and "ĐÓNG" or "TARGET"
    targetBtn.BackgroundColor3 = listFrame.Visible and Color3.fromRGB(200, 0, 0) or Color3.fromRGB(255, 80, 0)
end)

-- Cập nhật danh sách người chơi
local function updatePlayerList()
    for _, v in pairs(scroll:GetChildren()) do
        if v:IsA("TextButton") then v:Destroy() end
    end
    local y = 0
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= player and p.Character and p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health > 0 then
            local btn = Instance.new("TextButton", scroll)
            btn.Size = UDim2.new(1, -10, 0, 80)
            btn.Position = UDim2.new(0, 5, 0, y)
            btn.BackgroundColor3 = (_G.AimbotTarget == p) and Color3.fromRGB(0, 220, 0) or Color3.fromRGB(40, 40, 80)
            btn.Text = p.DisplayName .. "\n@" .. p.Name
            btn.TextColor3 = Color3.new(1, 1, 1)
            btn.Font = Enum.Font.GothamBold
            btn.TextSize = 28
            Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 14)
            
            btn.MouseButton1Click:Connect(function()
                _G.AimbotTarget = (_G.AimbotTarget == p) and nil or p
                updatePlayerList()
            end)
            y = y + 90
        end
    end
    scroll.CanvasSize = UDim2.new(0, 0, 0, y)
end

Players.PlayerAdded:Connect(updatePlayerList)
Players.PlayerRemoving:Connect(updatePlayerList)
spawn(function() while wait(2) do updatePlayerList() end end)

-- Đợi leaderstats load chắc chắn rồi mới lấy bounty
spawn(function()
    local ls = player:WaitForChild("leaderstats", 30)
    if ls then
        local bountyObj = ls:WaitForChild("Bounty", 10) or ls:WaitForChild("Bounty/Honor", 10) or ls:WaitForChild("Honor", 10)
        if bountyObj then
            bountyValue = bountyObj.Value
            bountyObj:GetPropertyChangedSignal("Value"):Connect(function()
                bountyValue = bountyObj.Value
            end)
        end
    end
end)

-- Main loop
local fpsCount = 0
local lastTime = tick()

RunService.Heartbeat:Connect(function()
    fpsCount += 1
    if tick() - lastTime >= 1 then
        local fps = fpsCount
        fpsCount = 0
        lastTime = tick()

        -- Cập nhật thanh trên
        local bountyText = string.format("%d", bountyValue):reverse():gsub("(%d%d%d)", "%1."):reverse():gsub("^%.", "") .. "$"
        topBar.Text = string.format("FPS: %d  |  Bounty: %s  |  Aimbot: %s", 
            fps,
            bountyText,
            _G.AimbotTarget and _G.AimbotTarget.DisplayName or "OFF"
        )

        -- Rainbow FPS
        local t = tick() * 3
        topBar.TextColor3 = Color3.fromRGB(
            math.sin(t) * 127 + 128,
            math.sin(t + 2) * 127 + 128,
            math.sin(t + 4) * 127 + 128
        )
    end

    -- Aimbot: xoay người + camera về đầu địch
    if _G.AimbotTarget and _G.AimbotTarget.Character and _G.AimbotTarget.Character:FindFirstChild("Head") then
        local head = _G.AimbotTarget.Character.Head
        local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        if root then
            root.CFrame = CFrame.new(root.Position, head.Position)
            workspace.CurrentCamera.CFrame = CFrame.new(workspace.CurrentCamera.CFrame.Position, head.Position)
        end
    end
end)

-- Thông báo
game.StarterGui:SetCore("SendNotification", {
    Title = "SCRIPT SẴN SÀNG!",
    Text = "Bấm nút TARGET góc phải trên để chọn người bắn!",
    Duration = 8
})

print("BLOX FRUITS AIMBOT 2025 ĐÃ HOÀN THIỆN – BOUNTY HIỆN NGAY – MOBILE SIÊU DỄ DÙNG")
