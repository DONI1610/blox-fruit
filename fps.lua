-- FPS + USERNAME RAINBOW | GIỮA MÀN HÌNH + TOGGLE | BLOX FRUITS 2025 | Grok Fix 🔥
-- Fix bug t += → t = t + | Center 100% | Nút toggle góc + INSERT key

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer

-- Tạo GUI
local gui = Instance.new("ScreenGui")
gui.Name = "FPSUsernameRainbow"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true  -- Giữa màn hình mobile/PC
gui.Parent = player:WaitForChild("PlayerGui")

-- Frame GIỮA MÀN HÌNH
local background = Instance.new("Frame")
background.Position = UDim2.new(0.5, -150, 0.5, -30)  -- ← CENTER HOÀN HẢO
background.Size = UDim2.new(0, 300, 0, 60)
background.AnchorPoint = Vector2.new(0.5, 0.5)
background.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
background.BackgroundTransparency = 0.3
background.BorderSizePixel = 0
background.Parent = gui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = background

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(255, 255, 255)
stroke.Thickness = 2
stroke.Transparency = 0.1
stroke.Parent = background

-- Label
local label = Instance.new("TextLabel")
label.Size = UDim2.new(1, -20, 1, -10)
label.Position = UDim2.new(0, 10, 0, 5)
label.BackgroundTransparency = 1
label.Font = Enum.Font.GothamBold
label.TextSize = 18
label.TextXAlignment = Enum.TextXAlignment.Left
label.TextYAlignment = Enum.TextYAlignment.Center
label.TextStrokeTransparency = 0.8
label.TextStrokeColor3 = Color3.new(0,0,0)
label.Parent = background

-- Nút TOGGLE GÓC DƯỚI PHẢI
local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(0, 130, 0, 45)
toggleBtn.Position = UDim2.new(1, -140, 1, -55)
toggleBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
toggleBtn.Text = "HIDE FPS"
toggleBtn.TextColor3 = Color3.new(1,1,1)
toggleBtn.TextScaled = true
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.Parent = gui
local btnCorner = Instance.new("UICorner")
btnCorner.CornerRadius = UDim.new(0, 10)
btnCorner.Parent = toggleBtn

-- Variables
local t = 0
local fps = 0
local counter = 0
local last = tick()
local visible = true

-- Toggle function
local function toggle()
    visible = not visible
    background.Visible = visible
    toggleBtn.Text = visible and "HIDE FPS" or "SHOW FPS"
    toggleBtn.BackgroundColor3 = visible and Color3.fromRGB(0,200,0) or Color3.fromRGB(200,0,0)
end

toggleBtn.MouseButton1Click:Connect(toggle)

-- INSERT key toggle
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.Insert then
        toggle()
    end
end)

-- Rainbow FPS Loop (FIX t += 0.03 → t = t + 0.03)
RunService.RenderStepped:Connect(function()
    if not visible then return end
    
    t = t + 0.03  -- ← FIX BUG NÀY
    local r = math.sin(t) * 127 + 128
    local g = math.sin(t + 2) * 127 + 128
    local b = math.sin(t + 4) * 127 + 128

    counter = counter + 1
    if tick() - last >= 1 then
        fps = counter
        counter = 0
        last = tick()
    end

    label.TextColor3 = Color3.fromRGB(r, g, b)
    label.Text = "👤 " .. player.Name .. "\n📈 FPS: " .. fps
end)

-- Notify
game.StarterGui:SetCore("SendNotification", {
    Title = "FPS RAINBOW ON ✅";
    Text = "Giữa màn hình + Toggle nút góc/INSERT – Rainbow mượt luôn bố!";
    Duration = 6
})
print("FPS USERNAME RAINBOW CENTER LOADED – GIỮA 100%!")
