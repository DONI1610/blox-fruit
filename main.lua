-- BLOX FRUITS STATS FIXED CENTER | CHỈ GỬI MỖI 5 PHÚT | 2025
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local player = Players.LocalPlayer

-- THAY WEBHOOK CỦA MÀY VÀO ĐÂY (duy nhất 1 dòng cần sửa)
local WEBHOOK_URL = "https://discord.com/api/webhooks/1440329549454770308/oYvPfxFwuIqaKnXFqSKJuBmIYg-nxmzrgPGi8AteK95IV-y3lC3PR3rhErBkvG3k_gH9"

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "CleanStats"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

-- MENU CỐ ĐỊNH GIỮA MÀN HÌNH
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 340, 0, 180)
frame.Position = UDim2.new(0.5, -170, 0.5, -90)
frame.AnchorPoint = Vector2.new(0.5, 0.5)
frame.BackgroundColor3 = Color3.fromRGB(15, 15, 30)
frame.BackgroundTransparency = 0.1
frame.BorderSizePixel = 0
frame.Parent = screenGui

Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 18)
local stroke = Instance.new("UIStroke", frame)
stroke.Thickness = 3
stroke.Color = Color3.fromRGB(255, 200, 0)

-- Stats text
local function createLabel(parent, text, pos, color, size)
    local lbl = Instance.new("TextLabel", parent)
    lbl.Size = size or UDim2.new(1,0,0.33,0)
    lbl.Position = pos or UDim2.new(0,0,0,0)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = color or Color3.new(1,1,1)
    lbl.TextScaled = true
    lbl.Font = Enum.Font.GothamBold
    return lbl
end

local bountyLabel = createLabel(frame, "Bounty/Honor: Loading...", UDim2.new(0,15,0,15), Color3.fromRGB(255,255,0), UDim2.new(1,-30,0.35,0))
local levelLabel  = createLabel(frame, "Level: ---", UDim2.new(0,15,0.38,0), Color3.fromRGB(0,255,0))
local moneyLabel  = createLabel(frame, "Beli: ---\nFrag: ---", UDim2.new(0,15,0.58,0), Color3.fromRGB(180,180,255))
moneyLabel.TextSize = 18
moneyLabel.TextScaled = false

-- NÚT BẬT/TẮT MENU GÓC DƯỚI PHẢI
local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(0, 130, 0, 50)
toggleBtn.Position = UDim2.new(1, -145, 1, -65)
toggleBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
toggleBtn.Text = "HIDE STATS"
toggleBtn.TextColor3 = Color3.new(1,1,1)
toggleBtn.TextScaled = true
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.Parent = screenGui
Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(0,12)

local menuVisible = true
local function toggle()
    menuVisible = not menuVisible
    frame.Visible = menuVisible
    toggleBtn.Text = menuVisible and "HIDE STATS" or "SHOW STATS"
    toggleBtn.BackgroundColor3 = menuVisible and Color3.fromRGB(0,200,0) or Color3.fromRGB(200,0,0)
end
toggleBtn.MouseButton1Click:Connect(toggle)
UserInputService.InputBegan:Connect(function(k) if k.KeyCode == Enum.KeyCode.Insert then toggle() end end)

-- GỬI WEBHOOK
local function send(msg, color)
    if not WEBHOOK_URL or WEBHOOK_URL:find("14403295") then -- chỉ gửi nếu đã thay webhook thật
        pcall(function()
            HttpService:PostAsync(WEBHOOK_URL, HttpService:JSONEncode({embeds={{description=msg,color=color or 3447003}}}))
        end)
    end
end

-- UPDATE STATS TRÊN MÀN HÌNH
RunService.Heartbeat:Connect(function()
    if not player.leaderstats then return end
    local ls = player.leaderstats
    local bounty = ls:FindFirstChild("Bounty/Honor")
    local lvl = ls:FindFirstChild("Level")
    local beli = ls:FindFirstChild("Beli")
    local frag = ls:FindFirstChild("Fragments")

    if bounty then
        bountyLabel.Text = "Bounty/Honor: "..bounty.Value.."$"
        if bounty.Value > 10000000 then
            bountyLabel.TextColor3 = Color3.new(1,0,0); stroke.Color = Color3.new(1,0,0)
        elseif bounty.Value > 2000000 then
            bountyLabel.TextColor3 = Color3.new(1,0.5,0); stroke.Color = Color3.new(1,0.5,0)
        end
    end
    if lvl then levelLabel.Text = "Level: "..lvl.Value end
    if beli and frag then moneyLabel.Text = "Beli: "..beli.Value.."\nFrag: "..frag.Value end
end)

-- CHỈ GỬI MỖI 5 PHÚT MỘT LẦN – KHÔNG CẦN +100K NỮA
spawn(function()
    while wait(300) do
        if not player.leaderstats then continue end
        local ls = player.leaderstats
        local b = ls:FindFirstChild("Bounty/Honor") and ls["Bounty/Honor"].Value or 0
        local l = ls:FindFirstChild("Level") and ls.Level.Value or 0
        local be = ls:FindFirstChild("Beli") and ls.Beli.Value or 0
        local f = ls:FindFirstChild("Fragments") and ls.Fragments.Value or 0

        send(
            string.format("**%s** đang online\n**Bounty/Honor:** `%s$`\n**Level:** `%s`\n**Beli:** `%s`\n**Fragments:** `%s`",
            player.Name, b, l, be, f
        ), 3447003)
    end
end)

-- Thông báo load xong
send("**SCRIPT ĐÃ LOAD XONG!** "..player.Name.." đang online và săn bounty", 65280)
game.StarterGui:SetCore("SendNotification", {Title="STATS ON", Text="Chỉ gửi mỗi 5 phút - Menu giữa màn hình", Duration=5})
