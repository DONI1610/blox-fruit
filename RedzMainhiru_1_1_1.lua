-- HITBOX EXPANDER 2025 + HIỆN HITBOX ĐỎ TRONG SUỐT + CHỈNH SIZE TRỰC TIẾP
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

_G.HitboxEnabled = false
_G.HitboxSize = 18  -- mặc định 18x18x18 cực to
_G.ShowHitbox = true  -- bật hiện hitbox luôn

-- GUI
local gui = Instance.new("ScreenGui")
gui.Name = "HitboxExpanderVisible"
gui.ResetOnSpawn = false
gui.Parent = game.CoreGui

-- Top bar
local topBar = Instance.new("TextLabel", gui)
topBar.Size = UDim2.new(0, 350, 0, 45)
topBar.Position = UDim2.new(1, -370, 0, 10)
topBar.BackgroundColor3 = Color3.fromRGB(10, 10, 40)
topBar.BackgroundTransparency = 0.1
topBar.Text = "HITBOX: OFF | Size: 18 | Visible: ON"
topBar.TextColor3 = Color3.new(1,1,1)
topBar.Font = Enum.Font.GothamBlack
topBar.TextSize = 22
Instance.new("UICorner", topBar).CornerRadius = UDim.new(0,12)
Instance.new("UIStroke", topBar).Color = Color3.fromRGB(255, 50, 50)

-- Nút ON/OFF
local toggleBtn = Instance.new("TextButton", gui)
toggleBtn.Size = UDim2.new(0, 110, 0, 80)
toggleBtn.Position = UDim2.new(1, -130, 0, 60)
toggleBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
toggleBtn.Text = "OFF"
toggleBtn.TextColor3 = Color3.new(1,1,1)
toggleBtn.Font = Enum.Font.GothamBlack
toggleBtn.TextSize = 28
Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(0,16)
local stroke1 = Instance.new("UIStroke", toggleBtn)
stroke1.Thickness = 4
stroke1.Color = Color3.fromRGB(255, 0, 0)

-- TextBox size
local sizeBox = Instance.new("TextBox", gui)
sizeBox.Size = UDim2.new(0, 100, 0, 80)
sizeBox.Position = UDim2.new(1, -250, 0, 60)
sizeBox.BackgroundColor3 = Color3.fromRGB(40, 40, 80)
sizeBox.Text = "18"
sizeBox.TextColor3 = Color3.new(1,1,1)
sizeBox.Font = Enum.Font.GothamBold
sizeBox.TextSize = 30
Instance.new("UICorner", sizeBox).CornerRadius = UDim.new(0,16)
Instance.new("UIStroke", sizeBox).Color = Color3.fromRGB(0, 255, 255)

-- Nút bật/tắt hiện hitbox
local visibleBtn = Instance.new("TextButton", gui)
visibleBtn.Size = UDim2.new(0, 80, 0, 50)
visibleBtn.Position = UDim2.new(1, -340, 0, 75)
visibleBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
visibleBtn.Text = "VISIBLE"
visibleBtn.TextColor3 = Color3.new(1,1,1)
visibleBtn.Font = Enum.Font.GothamBold
visibleBtn.TextSize = 16
Instance.new("UICorner", visibleBtn).CornerRadius = UDim.new(0,10)

-- Hàm update GUI
local function updateGUI()
    topBar.Text = string.format("HITBOX: %s | Size: %d | Visible: %s", 
        _G.HitboxEnabled and "ON" or "OFF", _G.HitboxSize, _G.ShowHitbox and "ON" or "OFF")
end

toggleBtn.MouseButton1Click:Connect(function()
    _G.HitboxEnabled = not _G.HitboxEnabled
    toggleBtn.Text = _G.HitboxEnabled and "ON" or "OFF"
    toggleBtn.BackgroundColor3 = _G.HitboxEnabled and Color3.fromRGB(0,200,0) or Color3.fromRGB(200,0,0)
    stroke1.Color = _G.HitboxEnabled and Color3.fromRGB(0,255,0) or Color3.fromRGB(255,0,0)
    updateGUI()
end)

visibleBtn.MouseButton1Click:Connect(function()
    _G.ShowHitbox = not _G.ShowHitbox
    visibleBtn.Text = _G.ShowHitbox and "VISIBLE" or "HIDDEN"
    visibleBtn.BackgroundColor3 = _G.ShowHitbox and Color3.fromRGB(0,200,0) or Color3.fromRGB(100,100,100)
    updateGUI()
end)

sizeBox.FocusLost:Connect(function(enter)
    if enter then
        local num = tonumber(sizeBox.Text)
        if num and num >= 5 and num <= 60 then
            _G.HitboxSize = num
            sizeBox.Text = tostring(num)
        else
            sizeBox.Text = tostring(_G.HitboxSize)
        end
        updateGUI()
    end
end)

-- Tạo Part hiện hitbox (đỏ trong suốt)
local function createVisual(part, plr)
    if part:FindFirstChild("HitboxVisual") then return end
    local visual = Instance.new("Part")
    visual.Name = "HitboxVisual"
    visual.Anchored = true
    visual.CanCollide = false
    visual.Transparency = 0.7
    visual.Color = Color3.fromRGB(255, 0, 0)
    visual.Material = Enum.Material.ForceField
    visual.Size = part.Size
    visual.CFrame = part.CFrame
    visual.Parent = part
    
    local weld = Instance.new("WeldConstraint")
    weld.Part0 = part
    weld.Part1 = visual
    weld.Parent = visual
end

-- Main loop
RunService.Heartbeat:Connect(function()
    if not _G.HitboxEnabled then 
        -- tự động xóa visual khi tắt
        for _, plr in Players:GetPlayers() do
            if plr ~= player and plr.Character then
                local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
                if hrp and hrp:FindFirstChild("HitboxVisual") then
                    hrp.HitboxVisual:Destroy()
                end
            end
        end
        return 
    end

    for _, plr in Players:GetPlayers() do
        if plr ~= player and plr.Character then
            local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                hrp.Size = Vector3.new(_G.HitboxSize, _G.HitboxSize, _G.HitboxSize)
                hrp.Transparency = _G.ShowHitbox and 0.9 or 1
                hrp.CanCollide = false
                
                if _G.ShowHitbox then
                    createVisual(hrp, plr)
                    if hrp:FindFirstChild("HitboxVisual") then
                        hrp.HitboxVisual.Size = hrp.Size
                        hrp.HitboxVisual.Transparency = 0.65
                        hrp.HitboxVisual.Color = Color3.fromRGB(255, 30, 30)
                    end
                else
                    if hrp:FindFirstChild("HitboxVisual") then
                        hrp.HitboxVisual:Destroy()
                    end
                end
            end
        end
    end
end)

-- Thông báo
game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "HITBOX EXPANDER VISIBLE 2025",
    Text = "Bật ON → thấy hitbox đỏ to vl luôn | Dễ bắn cực!",
    Duration = 8
})

updateGUI()
print("HITBOX EXPANDER + HIỆN ĐỎ TRONG SUỐT HOÀN THIỆN")
