-- PHIÊN BẢN CUỐI: TO ĐẸP GIỮA MÀN HÌNH, KHÔNG CÒN "TÍ XÍU" NỮA
-- Text to hơn, font đẹp hơn, kích thước cố định to đùng

local player = game.Players.LocalPlayer
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

local WEBHOOK = "https://discord.com/api/webhooks/1440329549454770308/oYvPfxFwuIqaKnXFqSKJuBmIYg-nxmzrgPGi8AteK95IV-y3lC3PR3rhErBkvG3k_gH9"

local gui = Instance.new("ScreenGui")
gui.Name = "BigCenterStats"
gui.ResetOnSpawn = false
gui.Parent = game:GetService("CoreGui")

-- Frame to đùng luôn
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 500, 0, 360)        -- TO GẤP ĐÔI
frame.Position = UDim2.new(0.5, -250, 0.5, -180)
frame.AnchorPoint = Vector2.new(0.5, 0.5)
frame.BackgroundColor3 = Color3.fromRGB(10, 10, 30)
frame.BackgroundTransparency = 0.1
frame.BorderSizePixel = 0
frame.Parent = gui

Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 28)
local stroke = Instance.new("UIStroke", frame)
stroke.Thickness = 7
stroke.Color = Color3.fromRGB(255, 180, 0)

-- 1 TextLabel duy nhất, TO RÕ ĐẸP
local label = Instance.new("TextLabel", frame)
label.Size = UDim2.new(1, -50, 1, -30)
label.Position = UDim2.new(0, 25, 0, 15)
label.BackgroundTransparency = 1
label.Font = Enum.Font.GothamBlack
label.TextSize = 52          -- TO VÃI
label.TextColor3 = Color3.fromRGB(255,255,255)
label.TextStrokeTransparency = 0.6
label.TextStrokeColor3 = Color3.new(0,0,0)
label.TextXAlignment = Enum.TextXAlignment.Center
label.TextYAlignment = Enum.TextYAlignment.Center
label.Parent = frame

-- Nút toggle
local btn = Instance.new("TextButton", gui)
btn.Size = UDim2.new(0,160,0,60)
btn.Position = UDim2.new(1,-175,1,-70)
btn.BackgroundColor3 = Color3.fromRGB(0,220,0)
btn.Text = "HIDE"
btn.TextScaled = true
btn.Font = Enum.Font.GothamBlack
Instance.new("UICorner", btn).CornerRadius = UDim.new(0,15)

local show = true
btn.MouseButton1Click:Connect(function()
    show = not show
    frame.Visible = show
    btn.Text = show and "HIDE" or "SHOW"
end)

-- FPS + Update
local fps = 0; local count = 0; local last = tick()
RunService.Heartbeat:Connect(function()
    count += 1
    if tick()-last >= 1 then fps = count; count = 0; last = tick() end

    local ls = player:FindFirstChild("leaderstats")
    if ls then
        local bounty = (ls:FindFirstChild("Bounty") or ls:FindFirstChild("Bounty/Honor") or ls:FindFirstChild("Honor") or {Value=0}).Value
        local level = (ls:FindFirstChild("Level") or {Value=0}).Value
        local beli = (ls:FindFirstChild("Beli") or {Value=0}).Value
        local frag = (ls:FindFirstChild("Fragments") or ls:FindFirstChild("Fragment") or {Value=0}).Value

        -- Rainbow FPS
        local t = tick() * 3
        local r,g,b = math.sin(t)*127+128, math.sin(t+2)*127+128, math.sin(t+4)*127+128

        label.Text = string.format(
            "FPS: %d\n\nBounty: %s$\nLevel: %d\nBeli: %s\nFragments: %s",
            fps,
            tostring(bounty):reverse():gsub("(%d%d%d)", "%1."):reverse():gsub("^%", ""),
            level,
            tostring(beli):reverse():gsub("(%d%d%d)", "%1."):reverse():gsub("^%", ""),
            tostring(frag):reverse():gsub("(%d%d%d)", "%1."):reverse():gsub("^%", "")
        )
        label.TextColor3 = Color3.fromRGB(r,g,b)

        -- Viền đổi màu
        stroke.Color = bounty >= 25000000 and Color3.fromRGB(255,0,0) or (bounty >= 10000000 and Color3.fromRGB(255,120,0) or Color3.fromRGB(255,180,0))
    end
end)

-- Webhook
local function send()
    local ls = player.leaderstats
    if ls then
        local b = (ls.Bounty or ls["Bounty/Honor"] or ls.Honor or {Value=0}).Value
        local l = (ls.Level or {Value=0}).Value
        local beli = (ls.Beli or {Value=0}).Value
        local frag = (ls.Fragments or ls.Fragment or {Value=0}).Value
        pcall(function() HttpService:PostAsync(WEBHOOK, HttpService:JSONEncode({embeds={{title="Stats Update",description=string.format("**%s**\nBounty: %s\nLevel: %s\nBeli: %s\nFrag: %s",player.Name,b,l,beli,frag),color=3447003}}})) end)
    end
end
send()
spawn(function() while wait(300) do send() end end)

game.StarterGui:SetCore("SendNotification",{Title="TO ĐÙNG GIỮA MÀN HÌNH RỒI",Text="Không còn bé tí nữa, nhìn rõ từ xa luôn!",Duration=8})
