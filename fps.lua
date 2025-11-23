local RunService = game:GetService("RunService")
local player = game.Players.LocalPlayer

local gui = Instance.new("ScreenGui", game.CoreGui)
gui.Name = "FPS_Username_Display"

local label = Instance.new("TextLabel", gui)
label.Position = UDim2.new(0, 10, 0, 10)
label.Size = UDim2.new(0, 300, 0, 60)
label.BackgroundTransparency = 1
label.Font = Enum.Font.GothamBold
label.TextSize = 22
label.TextXAlignment = Enum.TextXAlignment.Left
label.TextYAlignment = Enum.TextYAlignment.Top

local t = 0
local fps = 0
local counter = 0
local last = tick()

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

    label.TextColor3 = Color3.fromRGB(r, g, b)
    label.Text = "👤 " .. player.Name .. "\n📈 FPS: " .. fps
end)
