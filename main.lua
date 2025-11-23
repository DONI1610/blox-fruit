-- Bounty ESP Blox Fruits 2025 | By Grok (Custom)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer

local ESP = {}
local Toggle = true

UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.Insert then
        Toggle = not Toggle
        for _, v in pairs(ESP) do
            if v then v.Enabled = Toggle end
        end
        game.StarterGui:SetCore("SendNotification", {
            Title = "Bounty ESP";
            Text = Toggle and "ON 🔥" or "OFF";
            Duration = 2
        })
    end
end)

local function CreateESP(plr)
    if plr == player or ESP[plr] then return end
    
    local char = plr.Character or plr.CharacterAdded:Wait()
    local head = char:WaitForChild("Head")
    
    local bb = Instance.new("BillboardGui")
    bb.Name = "BountyESP"
    bb.Parent = head
    bb.Size = UDim2.new(0, 250, 0, 80)
    bb.StudsOffset = Vector3.new(0, 3, 0)
    bb.AlwaysOnTop = true
    
    local nameLbl = Instance.new("TextLabel", bb)
    nameLbl.Size = UDim2.new(1, 0, 0.4, 0)
    nameLbl.BackgroundTransparency = 1
    nameLbl.Text = plr.Name .. " | Lv. ?"
    nameLbl.TextColor3 = Color3.new(1,1,1)
    nameLbl.TextScaled = true
    nameLbl.Font = Enum.Font.GothamBold
    
    local bountyLbl = Instance.new("TextLabel", bb)
    bountyLbl.Size = UDim2.new(1, 0, 0.6, 0)
    bountyLbl.Position = UDim2.new(0,0,0.4,0)
    bountyLbl.BackgroundTransparency = 1
    bountyLbl.Text = "Bounty: 0"
    bountyLbl.TextColor3 = Color3.new(1, 0.8, 0)
    bountyLbl.TextScaled = true
    bountyLbl.Font = Enum.Font.GothamBold
    
    -- Border đẹp
    local stroke = Instance.new("UIStroke", nameLbl)
    stroke.Color = Color3.new(0,0,0)
    stroke.Thickness = 2
    local stroke2 = Instance.new("UIStroke", bountyLbl)
    stroke2.Color = Color3.new(0,0,0)
    stroke2.Thickness = 2
    
    ESP[plr] = bb
    
    -- Update real-time
    spawn(function()
        while char.Parent do
            wait(0.5)
            local ls = plr:FindFirstChild("leaderstats")
            if ls then
                local lvl = ls:FindFirstChild("Level")
                local bounty = ls:FindFirstChild("Bounty")
                if lvl and bounty then
                    nameLbl.Text = plr.Name .. " | Lv. " .. lvl.Value
                    bountyLbl.Text = "Bounty: " .. bounty.Value .. "$"
                    
                    -- Color theo bounty (đỏ = rich target)
                    if bounty.Value > 10e6 then
                        bountyLbl.TextColor3 = Color3.new(1,0,0)
                    elseif bounty.Value > 1e6 then
                        bountyLbl.TextColor3 = Color3.new(1,0.5,0)
                    end
                end
            end
        end
    end)
end

-- Loop all players
for _, plr in pairs(Players:GetPlayers()) do
    CreateESP(plr)
end

Players.PlayerAdded:Connect(CreateESP)
Players.PlayerRemoving:Connect(function(plr)
    if ESP[plr] then ESP[plr]:Destroy() ESP[plr] = nil end
end)

print("Bounty ESP Loaded! Nhấn INSERT toggle 🚀")
game.StarterGui:SetCore("SendNotification", {Title="Bounty ESP"; Text="ON | INSERT OFF"; Duration=3})
