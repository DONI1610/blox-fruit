local RunService = game:GetService("RunService")
local player = game.Players.LocalPlayer

-- Tạo GUI (dựa trên code bạn đưa)
local gui = Instance.new("ScreenGui", game.CoreGui)
gui.Name = "FPS_Username_Display"

-- Khung nền
local background = Instance.new("Frame", gui)
background.Position = UDim2.new(0, 10, 0, 10)
background.Size = UDim2.new(0, 300, 0, 60)
background.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
background.BackgroundTransparency = 0.3
background.BorderSizePixel = 0

-- Bo góc
local corner = Instance.new("UICorner", background)
corner.CornerRadius = UDim.new(0, 8)

-- Viền đẹp UIStroke
local stroke = Instance.new("UIStroke", background)
stroke.Color = Color3.fromRGB(255, 255, 255)
stroke.Thickness = 1.3
stroke.Transparency = 0.2

-- Label text dựa trên code của bạn
local label = Instance.new("TextLabel", background)
label.Size = UDim2.new(1, -10, 1, -10)
label.Position = UDim2.new(0, 5, 0, 5)
label.BackgroundTransparency = 1
label.Font = Enum.Font.GothamBold
label.TextSize = 20
label.TextXAlignment = Enum.TextXAlignment.Left
label.TextYAlignment = Enum.TextYAlignment.Top

-- biến cũ của bạn
local t = 0
local fps = 0
local counter = 0
local last = tick()

-- vòng lặp RenderStepped
RunService.RenderStepped:Connect(function()
    t += 0.03
    local r = math.sin(t) * 127 + 128
    local g = math.sin(t + 2) * 127 + 128
    local b = math.sin(t + 4) * 127 + 128

    counter += 1
    if tick() - last >= 1 then
        fps = counter
        counter = 0
        last = tick()
    end

    -- màu chữ cầu vồng như bạn dùng
    label.TextColor3 = Color3.fromRGB(r, g, b)

    -- UI có thêm nền nhưng nội dung giữ nguyên
    label.Text = "👤 " .. player.Name .. "\n📈 FPS: " .. fps
end)
