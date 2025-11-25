-- BLOX FRUITS 2025 | AIMBOT + ESP NHỎ + FIX BOUNTY 100% + NÚT TẮT
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
_G.AimbotTarget = nil
_G.AimbotEnabled = true
local bountyValue = 0

-- ===================== GUI =====================
local gui = Instance.new("ScreenGui")
gui.Name = "BloxAimbot2025"
gui.ResetOnSpawn = false
gui.Parent = game.CoreGui

-- Top bar
local topBar = Instance.new("TextLabel", gui)
topBar.Size = UDim2.new(1,0,0,50)
topBar.BackgroundColor3 = Color3.fromRGB(8,8,30)
topBar.BackgroundTransparency = 0.15
topBar.Text = "FPS: 0 | Bounty: 0$ | Aimbot: OFF"
topBar.TextColor3 = Color3.new(1,1,1)
topBar.Font = Enum.Font.GothamBlack
topBar.TextSize = 28
topBar.TextXAlignment = Enum.TextXAlignment.Center
Instance.new("UICorner", topBar).CornerRadius = UDim.new(0,12)

-- Nút TARGET & TOGGLE (giữ nguyên đẹp)
local targetBtn = Instance.new("TextButton", gui)
targetBtn.Size = UDim2.new(0,100,0,100)
targetBtn.Position = UDim2.new(1,-230,0,10)
targetBtn.BackgroundColor3 = Color3.fromRGB(255,80,0)
targetBtn.Text = "TARGET"
targetBtn.TextColor3 = Color3.new(1,1,1)
targetBtn.Font = Enum.Font.GothamBlack
targetBtn.TextSize = 28
Instance.new("UICorner", targetBtn).CornerRadius = UDim.new(0,24)
Instance.new("UIStroke", targetBtn).Thickness = 4
Instance.new("UIStroke", targetBtn).Color = Color3.fromRGB(255,200,0)

local toggleBtn = Instance.new("TextButton", gui)
toggleBtn.Size = UDim2.new(0,100,0,100)
toggleBtn.Position = UDim2.new(1,-115,0,10)
toggleBtn.BackgroundColor3 = Color3.fromRGB(0,200,0)
toggleBtn.Text = "AIM\nON"
toggleBtn.TextColor3 = Color3.new(1,1,1)
toggleBtn.Font = Enum.Font.GothamBlack
toggleBtn.TextSize = 28
Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(0,24)
local strokeToggle = Instance.new("UIStroke", toggleBtn)
strokeToggle.Thickness = 4
strokeToggle.Color = Color3.fromRGB(0,255,0)

-- List người chơi (giữ nguyên)
-- ... (code phần list giữ nguyên như cũ, mình rút gọn cho dễ đọc)

-- ======== FIX BOUNTY 100% (hỗ trợ mọi kiểu) ========
spawn(function()
    repeat task.wait() until player:FindFirstChild("leaderstats")
    local ls = player.leaderstats

    local function getBounty()
        -- Kiểu mới: Bounty/Honor trực tiếp
        if ls:FindFirstChild("Bounty") and ls.Bounty:IsA("IntValue") then
            return ls.Bounty
        elseif ls:FindFirstChild("Honor") and ls.Honor:IsA("IntValue") then
            return ls.Honor
        -- Kiểu cũ: folder Bounty/Honor
        elseif ls:FindFirstChild("Bounty") and ls.Bounty:FindFirstChild("Honor") then
            return ls.Bounty.Honor
        end
        return nil
    end

    local bountyObj = getBounty()
    if bountyObj then
        bountyValue = bountyObj.Value
        bountyObj:GetPropertyChangedSignal("Value"):Connect(function()
            bountyValue = bountyObj.Value
        end)
    end
end)

-- ======== ESP NHỎ GỌN TRÊN ĐẦU (tên + máu) ========
local espFolder = Instance.new("Folder")
espFolder.Name = "EnemyESP"
espFolder.Parent = gui

local function createESP(plr)
    if plr == player then return end
    local bill = Instance.new("BillboardGui")
    bill.Name = plr.Name
    bill.Adornee = nil
    bill.Size = UDim2.new(0, 160, 0, 40)
    bill.StudsOffset = Vector3.new(0, 3, 0)
    bill.AlwaysOnTop = true
    bill.Parent = espFolder

    local frame = Instance.new("Frame", bill)
    frame.Size = UDim2.new(1,0,1,0)
    frame.BackgroundTransparency = 1

    local nameLabel = Instance.new("TextLabel", frame)
    nameLabel.Size = UDim2.new(1,0,0.5,0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = plr.DisplayName
    nameLabel.TextColor3 = Color3.fromRGB(255,50,50)
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextStrokeTransparency = 0
    nameLabel.TextStrokeColor3 = Color3.fromRGB(255,215,0)
    nameLabel.TextSize = 16

    local healthLabel = Instance.new("TextLabel", frame)
    healthLabel.Position = UDim2.new(0,0,0.5,0)
    healthLabel.Size = UDim2.new(1,0,0.5,0)
    healthLabel.BackgroundTransparency = 1
    healthLabel.TextColor3 = Color3.fromRGB(255,100,100)
    healthLabel.Font = Enum.Font.GothamBold
    healthLabel.TextStrokeTransparency = 0
    healthLabel.TextStrokeColor3 = Color3.new(0,0,0)
    healthLabel.TextSize = 14

    local connection
    connection = RunService.Heartbeat:Connect(function()
        if plr.Character and plr.Character:FindFirstChild("Head") and plr.Character:FindFirstChild("Humanoid") and plr.Character.Humanoid.Health > 0 then
            bill.Adornee = plr.Character.Head
            bill.Enabled = true
            healthLabel.Text = math.floor(plr.Character.Humanoid.Health) .. "/" .. plr.Character.Humanoid.MaxHealth
        else
            bill.Enabled = false
        end
        if not plr.Parent then
            bill:Destroy()
            connection:Disconnect()
        end
    end)
end

-- Tạo ESP cho người đang có + người mới vào
for _, p in pairs(Players:GetPlayers()) do
    if p ~= player then createESP(p) end
end
Players.PlayerAdded:Connect(function(p)
    if p ~= player then task.wait(2); createESP(p) end
end)

-- ======== PHẦN AIMBOT + FPS + TOGGLE (giữ nguyên + nhỏ fix) ========
-- (code phần target list, toggle, aimbot giữ nguyên như bản trước, chỉ thêm 1 dòng nhỏ)
-- ... (đoạn cũ của bạn)

RunService.Heartbeat:Connect(function()
    fpsCount += 1
    if tick() - lastTime >= 1 then
        local fps = fpsCount
        fpsCount = 0
        lastTime = tick()

        local bountyTxt = tostring(bountyValue):reverse():gsub("(%d%d%d)","%1."):reverse():gsub("^%.","") .. "$"
        topBar.Text = string.format("FPS: %d | Bounty: %s | Aimbot: %s",
            fps,
            bountyTxt,
            _G.AimbotEnabled and (_G.AimbotTarget and _G.AimbotTarget.DisplayName or "ON") or "OFF"
        )

        local t = tick() * 3
        topBar.TextColor3 = Color3.fromHSV(t % 1, 1, 1) -- rainbow mượt hơn
    end

    if _G.AimbotEnabled and _G.AimbotTarget and _G.AimbotTarget.Character and _G.AimbotTarget.Character:FindFirstChild("Head") then
        local head = _G.AimbotTarget.Character.Head
        local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        if root then
            root.CFrame = CFrame.new(root.Position, head.Position + Vector3.new(0,1.5,0))
            workspace.CurrentCamera.CFrame = CFrame.lookAt(workspace.CurrentCamera.CFrame.Position, head.Position)
        end
    end
end)

-- Thông báo
game:GetService("StarterGui"):SetCore("SendNotification",{
    Title = "DONI HUB 2025",
    Text = "ESP + AIM + BOUNTY FIX HOÀN CHỈNH - SỐNG DAI THÀNH HUYỀN THOẠI",
    Duration = 10
})
