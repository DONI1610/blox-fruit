-- FPS + BOUNTY + AIMBOT + CHIÊU BẮN TRÚNG 100% (Delta/Arceus X/Codex/Fluxus OK)
-- Chỉ 1 thanh nhỏ trên đầu + nút mở list

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local player = Players.LocalPlayer
local mouse = player:GetMouse()

_G.AimbotTarget = nil
local Enabled = true

-- GUI siêu gọn
local gui = Instance.new("ScreenGui", game.CoreGui)
gui.ResetOnSpawn = false

local topBar = Instance.new("TextLabel", gui)
topBar.Size = UDim2.new(0,480,0,38)
topBar.Position = UDim2.new(0.5,-240,0,8)
topBar.AnchorPoint = Vector2.new(0.5,0)
topBar.BackgroundColor3 = Color3.fromRGB(10,10,20)
topBar.BackgroundTransparency = 0.2
topBar.Text = "FPS: 0  |  Bounty: Loading...  |  Aimbot: OFF"
topBar.TextColor3 = Color3.new(1,1,1)
topBar.Font = Enum.Font.GothamBold
topBar.TextSize = 24
Instance.new("UICorner", topBar).CornerRadius = UDim.new(0,12)

-- Nút mở list
local openBtn = Instance.new("TextButton", gui)
openBtn.Size = UDim2.new(0,50,0,50)
openBtn.Position = UDim2.new(1,-60,0,5)
openBtn.BackgroundColor3 = Color3.fromRGB(255,180,0)
openBtn.Text = ">"
openBtn.Font = Enum.Font.GothamBlack
openBtn.TextSize = 36
Instance.new("UICorner", openBtn).CornerRadius = UDim.new(0,12)

local listFrame = Instance.new("Frame", gui)
listFrame.Size = UDim2.new(0,280,0,420)
listFrame.Position = UDim2.new(1,-290,0,60)
listFrame.BackgroundColor3 = Color3.fromRGB(10,10,25)
listFrame.BackgroundTransparency = 0.1
listFrame.Visible = false
Instance.new("UICorner", listFrame).CornerRadius = UDim.new(0,14)

local scroll = Instance.new("ScrollingFrame", listFrame)
scroll.Size = UDim2.new(1,-10,1,-10)
scroll.Position = UDim2.new(0,5,0,5)
scroll.BackgroundTransparency = 1
scroll.ScrollBarThickness = 8

openBtn.MouseButton1Click:Connect(function()
    listFrame.Visible = not listFrame.Visible
    openBtn.Text = listFrame.Visible and "<" or ">"
end)

-- Refresh list
local function refresh()
    for _,v in scroll:GetChildren() do if v:IsA("TextButton") then v:Destroy() end end
    local y = 0
    for _, p in Players:GetPlayers() do
        if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local btn = Instance.new("TextButton", scroll)
            btn.Size = UDim2.new(1,-10,0,45)
            btn.Position = UDim2.new(0,5,0,y)
            btn.BackgroundColor3 = _G.AimbotTarget == p and Color3.fromRGB(0,200,0) or Color3.fromRGB(30,30,50)
            btn.Text = p.DisplayName
            btn.TextColor3 = Color3.new(1,1,1)
            btn.Font = Enum.Font.GothamBold
            btn.TextSize = 22
            btn.MouseButton1Click:Connect(function()
                _G.AimbotTarget = (_G.AimbotTarget == p) and nil or p
                refresh()
            end)
            y = y + 50
        end
    end
    scroll.CanvasSize = UDim2.new(0,0,0,y)
end
Players.PlayerAdded:Connect(refresh)
Players.PlayerRemoving:Connect(refresh)
spawn(function() while wait(3) do refresh() end end)
refresh()

-- MAIN LOOP (FIX CHIÊU BẮN TRÚNG)
local fps = 0
local count = 0
local last = tick()

RunService.RenderStepped:Connect(function()
    count += 1
    if tick() - last >= 1 then fps = count; count = 0; last = tick() end

    -- Cập nhật thanh trên
    local ls = player.leaderstats
    local bountyVal = ls and (ls.Bounty or ls["Bounty/Honor"] or ls.Honor or {Value=0}).Value or 0
    topBar.Text = string.format("FPS: %d  |  Bounty: %s$  |  Aimbot: %s", 
        fps, 
        (tostring(bountyVal):reverse():gsub("(%d%d%d)","%1."):reverse():gsub("^%.","")),
        _G.AimbotTarget and _G.AimbotTarget.DisplayName or "OFF")
    topBar.TextColor3 = Color3.fromRGB(math.sin(tick()*3)*127+128, math.sin(tick()*3+2)*127+128, math.sin(tick()*3+4)*127+128)

    -- AIMBOT + CHIÊU BẮN TRÚNG 100%
    if _G.AimbotTarget and _G.AimbotTarget.Character and _G.AimbotTarget.Character:FindFirstChild("Head") then
        local head = _G.AimbotTarget.Character.Head
        local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        
        if root then
            -- 1. Xoay người về địch
            root.CFrame = CFrame.new(root.Position, head.Position)
            
            -- 2. Dịch chuột + camera về đầu địch → chiêu bắn trúng 100%
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, head.Position)
            if mousemoverel then
                local screenPos = Camera:WorldToScreenPoint(head.Position)
                mousemoverel(screenPos.X - mouse.X, screenPos.Y - mouse.Y)
            end
        end
    end
end)

game.StarterGui:SetCore("SendNotification",{Title="AIM + CHIÊU TRÚNG 100%",Text="Click tên → Z X C V bắn trúng đầu luôn!",Duration=6})
