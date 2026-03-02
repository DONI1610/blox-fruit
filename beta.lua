--[[
    Script Infinite Soru Đơn Giản
    Lấy nguyên hàm từ code gốc và tạo nút bật/tắt
]]

local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()

-- Nguyên hàm getInfinity_Ability từ code gốc (giữ nguyên)
getInfinity_Ability = function(I, e)
    if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
        return;
    end;
    if I == "Soru" and e then
        for i, k in next, getgc() do
            if player.Character.Soru then
                if typeof(k) == "function" and getfenv and pcall(function() return (getfenv(k)).script == player.Character.Soru end) then
                    for j, upval in next, getupvalues(k) do
                        if typeof(upval) == "table" then
                                            repeat
                                                task.wait(0.1); -- Giảm thời gian chờ để mượt hơn
                                                upval.LastUse = 0;
                                            until not e or not player.Character or player.Character.Humanoid.Health <= 0;
                        end;
                    end;
                end;
            end;
        end;
    end;
end;

-- Tạo GUI đơn giản
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "InfSoruGUI"
screenGui.Parent = player.PlayerGui
screenGui.ResetOnSpawn = false

-- Tạo khung nền cho nút
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 120, 0, 40)
frame.Position = UDim2.new(0, 20, 0, 50) -- Góc trên bên trái
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.BackgroundTransparency = 0.3
frame.BorderSizePixel = 2
frame.BorderColor3 = Color3.fromRGB(0, 255, 0)
frame.Active = true
frame.Draggable = true -- Có thể kéo di chuyển
frame.Parent = screenGui

-- Tạo nút bật/tắt
local button = Instance.new("TextButton")
button.Size = UDim2.new(1, 0, 1, 0)
button.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
button.BackgroundTransparency = 0.2
button.Text = "INF SORU: OFF"
button.TextColor3 = Color3.fromRGB(255, 100, 100)
button.TextSize = 14
button.Font = Enum.Font.GothamBold
button.Parent = frame

-- Biến trạng thái
local infSoruEnabled = false

-- Xử lý khi bấm nút
button.MouseButton1Click:Connect(function()
    infSoruEnabled = not infSoruEnabled
    
    if infSoruEnabled then
        button.Text = "INF SORU: ON"
        button.TextColor3 = Color3.fromRGB(100, 255, 100)
        frame.BorderColor3 = Color3.fromRGB(0, 255, 0)
        getInfinity_Ability("Soru", true)
    else
        button.Text = "INF SORU: OFF"
        button.TextColor3 = Color3.fromRGB(255, 100, 100)
        frame.BorderColor3 = Color3.fromRGB(255, 0, 0)
        getInfinity_Ability("Soru", false)
    end
end)

-- Thông báo khi script chạy
print("Script Infinite Soru đã được tải! Bấm nút để bật/tắt.")
