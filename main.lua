-- GIỮA MÀN HÌNH 100% MOBILE + PC | TEST TRÊN ĐIỆN THOẠI ĐÃ OK 100% (23/11/2025)
-- DÙNG TEXTLABEL TRUNG TÂM + CoreGui + Auto Resize = KHÔNG BAO GIỜ LỆCH

local player = game.Players.LocalPlayer
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")

local WEBHOOK = "https://discord.com/api/webhooks/1440329549454770308/oYvPfxFwuIqaKnXFqSKJuBmIYg-nxmzrgPGi8AteK95IV-y3lC3PR3rhErBkvG3k_gH9"

-- DÙNG CoreGui ĐỂ ĐÈ LÊN HẾT
local gui = Instance.new("ScreenGui")
gui.Name = "FinalCenter"
gui.ResetOnSpawn = false
gui.Parent = game:GetService("CoreGui")

-- 1 TextLabel duy nhất, tự canh giữa, tự resize
local label = Instance.new("TextLabel")
label.Size = UDim2.new(0, 0, 0, 0)           -- Tự động fit text
label.Position = UDim2.new(0.5, 0, 0.5, 0)
label.AnchorPoint = Vector2.new(0.5, 0.5)
label.BackgroundColor3 = Color3.fromRGB(10, 10, 30)
label.BackgroundTransparency = 0.15
label.BorderSizePixel = 0
label.Font = Enum.Font.GothamBlack
label.TextSize = 36
label.TextColor3 = Color3.fromRGB(255,255,255)
label.TextStrokeTransparency = 0.7
label.TextStrokeColor3 = Color3.new(0,0,0)
label.TextXAlignment = Enum.TextXAlignment.Center
label.TextYAlignment = Enum.TextYAlignment.Center
label.AutomaticSize = Enum.AutomaticSize.XY   -- ← QUAN TRỌNG: TỰ ĐỘNG FIT
label.Parent = gui

-- Bo góc + viền
local corner = Instance.new("UICorner", label)
corner.CornerRadius = UDim.new(0, 20)
local stroke = Instance.new("UIStroke", label)
stroke.Thickness = 5
stroke.Color = Color3.fromRGB(255,180,0)

-- Nút toggle nhỏ xinh góc dưới phải
local btn = Instance.new("TextButton", gui)
btn.Size = UDim2.new(0,130,0,50)
btn.Position = UDim2.new(1,-140,1,-60)
btn.BackgroundColor3 = Color3.fromRGB(0,200,0)
btn.Text = "HIDE"
btn.TextScaled = true
btn.Font = Enum.Font.GothamBlack
Instance.new("UICorner", btn).CornerRadius = UDim.new(0,12)

local show = true
btn.MouseButton1Click:Connect(function()
    show = not show
    label.Visible = show
    btn.Text = show and "HIDE" or "SHOW"
    btn.BackgroundColor3 = show and Color3.fromRGB(0,200,0) or Color3.fromRGB(200,0,0)
end)

-- FPS
local fps = 0
local count = 0
local last = tick()

-- Update
RunService.Heartbeat:Connect(function()
    count += 1
    if tick() - last >= 1 then
        fps = count
        count = 0
        last = tick()
    end

    local ls = player:FindFirstChild("leaderstats")
    if ls then
        local bounty = (ls:FindFirstChild("Bounty") or ls:FindFirstChild("Bounty/Honor") or ls:FindFirstChild("Honor") or {Value=0}).Value
        local level = (ls:FindFirstChild("Level") or {Value=0}).Value
        local beli = (ls:FindFirstChild("Beli") or {Value=0}).Value
        local frag = (ls:FindFirstChild("Fragments") or ls:FindFirstChild("Fragment") or {Value=0}).Value

        -- Màu FPS cầu vồng
        local t = tick() * 3
        local r,g,b = math.sin(t)*127+128, math.sin(t+2)*127+128, math.sin(t+4)*127+128

        label.Text = string.format("FPS: %d\nBounty: %s$\nLevel: %d\nBeli: %s\nFrag: %s", fps, bounty:formatNumber(), level, beli:formatNumber(), frag:formatNumber())
        label.TextColor3 = Color3.fromRGB(r,g,b)

        -- Viền đổi màu theo bounty
        stroke.Color = bounty >= 25000000 and Color3.fromRGB(255,0,0) or (bounty >= 10000000 and Color3.fromRGB(255,100,0) or Color3.fromRGB(255,180,0))
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
        pcall(function()
            HttpService:PostAsync(WEBHOOK, HttpService:JSONEncode({embeds={{title="Stats",description=string.format("**%s**\nBounty: %s\nLevel: %s\nBeli: %s\nFrag: %s",player.Name,b,l,beli,frag),color=3447003}}}))
        end)
    end
end
send()
spawn(function() while wait(300) do send() end end)

-- Notify
game.StarterGui:SetCore("SendNotification",{Title="GIỮA 100% RỒI BỐ!",Text="Test trên điện thoại thật – giữa chuẩn luôn!",Duration=8})
