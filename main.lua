-- GIỮA MÀN HÌNH ĐỘNG 100% MOBILE/PC | TÍNH TOÁN TỰ ĐỘNG THEO SCREEN SIZE
-- FPS Rainbow + Bounty/Level/Beli/Frag TO ĐÙNG + Webhook ngay + 5p

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local player = Players.LocalPlayer

local WEBHOOK_URL = "https://discord.com/api/webhooks/1440329549454770308/oYvPfxFwuIqaKnXFqSKJuBmIYg-nxmzrgPGi8AteK95IV-y3lC3PR3rhErBkvG3k_gH9"

local gui = Instance.new("ScreenGui")
gui.Name = "DynamicCenterStats"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.Parent = player:WaitForChild("PlayerGui")

-- Frame to đùng
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 450, 0, 320)
frame.BackgroundColor3 = Color3.fromRGB(8, 8, 25)
frame.BackgroundTransparency = 0.1
frame.BorderSizePixel = 0
frame.Parent = gui

local corner = Instance.new("UICorner", frame)
corner.CornerRadius = UDim.new(0, 25)

local stroke = Instance.new("UIStroke", frame)
stroke.Thickness = 6
stroke.Color = Color3.fromRGB(255, 180, 0)

-- TextLabel to đẹp
local label = Instance.new("TextLabel", frame)
label.Size = UDim2.new(1, -40, 1, -20)
label.Position = UDim2.new(0, 20, 0, 10)
label.BackgroundTransparency = 1
label.Font = Enum.Font.GothamBlack
label.TextSize = 48
label.TextColor3 = Color3.fromRGB(255,255,255)
label.TextStrokeTransparency = 0.5
label.TextStrokeColor3 = Color3.new(0,0,0)
label.TextXAlignment = Enum.TextXAlignment.Center
label.TextYAlignment = Enum.TextYAlignment.Center

-- Nút toggle
local toggleBtn = Instance.new("TextButton", gui)
toggleBtn.Size = UDim2.new(0, 160, 0, 65)
toggleBtn.Position = UDim2.new(1, -175, 1, -75)
toggleBtn.BackgroundColor3 = Color3.fromRGB(0, 220, 0)
toggleBtn.Text = "HIDE"
toggleBtn.TextScaled = true
toggleBtn.Font = Enum.Font.GothamBlack
Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(0, 15)

local visible = true
toggleBtn.MouseButton1Click:Connect(function()
    visible = not visible
    frame.Visible = visible
    toggleBtn.Text = visible and "HIDE" or "SHOW"
    toggleBtn.BackgroundColor3 = visible and Color3.fromRGB(0,220,0) or Color3.fromRGB(220,0,0)
end)

UserInputService.InputBegan:Connect(function(k)
    if k.KeyCode == Enum.KeyCode.Insert then
        visible = not visible
        frame.Visible = visible
        toggleBtn.Text = visible and "HIDE" or "SHOW"
        toggleBtn.BackgroundColor3 = visible and Color3.fromRGB(0,220,0) or Color3.fromRGB(220,
