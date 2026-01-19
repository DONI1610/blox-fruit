-- FIXED FULL SCRIPT: Hop GUI Bé Xinh (Custom Drag+Click) + FPS/Bounty Visible + Webhook (2026 BF Pro)
local TS = game:GetService("TeleportService")
local HS = game:GetService("HttpService")
local PLRS = game:GetService("Players")
local SG = game:GetService("StarterGui")
local UIS = game:GetService("UserInputService")
local RS = game:GetService("RunService")

local PID = game.PlaceId
local LP = PLRS.LocalPlayer

-- THAY WEBHOOK CỦA MÀY VÀO ĐÂY NẾU MUỐN (default của mày)
local WEBHOOK_URL = "https://discord.com/api/webhooks/1440329549454770308/oYvPfxFwuIqaKnXFqSKJuBmIYg-nxmzrgPGi8AteK95IV-y3lC3PR3rhErBkvG3k_gH9"

-- 1. WEBHOOK GỬI NGAY LẬP TỨC KHI EXECUTE
local function sendStart()
    local ls = LP:FindFirstChild("leaderstats")
    if not ls then return end
    local bounty = (ls:FindFirstChild("Bounty") or ls:FindFirstChild("Bounty/Honor") or ls:FindFirstChild("Honor") or {Value=0}).Value
    local level = (ls:FindFirstChild("Level") or {Value=0}).Value
    pcall(function()
        HS:PostAsync(WEBHOOK_URL, HS:JSONEncode({
            embeds = {{
                title = "🚀 SCRIPT ĐÃ CHẠY",
                description = string.format("**%s** vừa bật script\nBounty hiện tại: **%s$**\nLevel: **%d**", LP.Name,
                    tostring(bounty):reverse():gsub("(%d%d%d)","%1."):reverse():gsub("^%.",""), level),
                color = 3447003,
                timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")
            }}
        }))
    end)
end
sendStart()

-- 2. HOP SERVER FUNCTIONS (sortOrder=Desc → đông trước, nhanh hơn)
local function notify(txt)
    pcall(function()
        SG:SetCore("SendNotification", {
            Title = "🚀 Hop SV Pro",
            Text = txt,
            Duration = 3,
            Icon = "rbxassetid://76020773425692"
        })
    end)
end

local function getAllServers()
    local servers = {}
    local cursor = ""
    repeat
        local url = ("https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=Desc&limit=100%s"):format(PID, cursor ~= "" and "&cursor=" .. cursor or "")
        local ok, res = pcall(function() return HS:JSONDecode(game:HttpGet(url)) end)
        if not ok or not res then break end
        for _, v in ipairs(res.data or {}) do table.insert(servers, v) end
        cursor = res.nextPageCursor or ""
    until cursor == ""
    table.sort(servers, function(a, b) return a.playing > b.playing end)  -- Safe sort
    return servers
end

local function hopServer()
    spawn(function()
        notify("🔍 Đang tìm SV đông nhất...")
        local servers = getAllServers()
        for _, srv in ipairs(servers) do
            if srv.id ~= game.JobId and srv.playing < srv.maxPlayers and srv.playing > 0 then
                notify("Hop → " .. srv.playing .. "/" .. srv.maxPlayers)
                task.wait(0.5)
                TS:TeleportToPlaceInstance(PID, srv.id, LP)
                return
            end
        end
        notify("Random hop!")
        task.wait(0.5)
        TS:Teleport(PID, LP)
    end)
end

-- 3. HOP GUI BÉ XINH (FIX: Custom Drag + Quick Tap Click, ZIndex cao)
local HopGui = Instance.new("ScreenGui")
HopGui.Parent = game:GetService("CoreGui")
HopGui.Name = "HopGUI"
HopGui.ResetOnSpawn = false
HopGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local HopFrame = Instance.new("Frame")
HopFrame.Parent = HopGui
HopFrame.Size = UDim2.new(0, 120, 0, 50)
HopFrame.Position = UDim2.new(1, -130, 1, -60)
HopFrame.BackgroundColor3 = Color3.fromRGB(0, 162, 255)
HopFrame.BorderSizePixel = 0
HopFrame.Active = true
HopFrame.ZIndex = 999  -- Trước tất cả GUI khác

local HopCorner = Instance.new("UICorner")
HopCorner.CornerRadius = UDim.new(0, 12)
HopCorner.Parent = HopFrame

local HopStroke = Instance.new("UIStroke")
HopStroke.Color = Color3.fromRGB(255, 255, 255)
HopStroke.Thickness = 2
HopStroke.Parent = HopFrame

local HopLabel = Instance.new("TextLabel")
HopLabel.Parent = HopFrame
HopLabel.Size = UDim2.new(1, 0, 1, 0)
HopLabel.BackgroundTransparency = 1
HopLabel.Text = "🚀 HOP SV"
HopLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
HopLabel.TextScaled = true
HopLabel.Font = Enum.Font.GothamBold
HopLabel.TextStrokeTransparency = 0.3
HopLabel.ZIndex = 1000

-- CUSTOM DRAG + CLICK (PC/Mobile OK, Quick Tap = Hop, Hold = Drag)
local dragging = false
local dragStart = nil
local startPos = nil
local clickStart = 0

HopFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        clickStart = tick()
        dragging = true
        dragStart = input.Position
        startPos = HopFrame.Position
    end
end)

UIS.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        HopFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

UIS.InputEnded:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
        dragging = false
        if tick() - clickStart < 0.15 then  -- Quick tap = HOP!
            hopServer()
        end
    end
end)

-- 4. FPS + BOUNTY GUI (FIX: Stroke outline + ZIndex cao + Position adjust)
local FPSGui = Instance.new("ScreenGui")
FPSGui.Name = "FPSBounty"
FPSGui.ResetOnSpawn = false
FPSGui.Parent = game:GetService("CoreGui")
FPSGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local fpsLabel = Instance.new("TextLabel")
fpsLabel.Parent = FPSGui
fpsLabel.Position = UDim2.new(0, 12, 0, 10)
fpsLabel.Size = UDim2.new(0, 180, 0, 28)
fpsLabel.BackgroundTransparency = 1
fpsLabel.TextXAlignment = Enum.TextXAlignment.Left
fpsLabel.Font = Enum.Font.GothamBold
fpsLabel.TextSize = 24
fpsLabel.Text = "FPS: 0"
fpsLabel.ZIndex = 999

local fpsStroke = Instance.new("UIStroke")
fpsStroke.Parent = fpsLabel
fpsStroke.Color = Color3.new(0, 0, 0)
fpsStroke.Thickness = 1.8
fpsStroke.Transparency = 0.4

local bountyLabel = Instance.new("TextLabel")
bountyLabel.Parent = FPSGui
bountyLabel.Position = UDim2.new(0, 12, 0, 42)
bountyLabel.Size = UDim2.new(0, 350, 0, 32)
bountyLabel.BackgroundTransparency = 1
bountyLabel.TextXAlignment = Enum.TextXAlignment.Left
bountyLabel.Font = Enum.Font.GothamBlack
bountyLabel.TextSize = 28
bountyLabel.Text = "Bounty: Loading..."
bountyLabel.ZIndex = 999

local bountyStroke = Instance.new("UIStroke")
bountyStroke.Parent = bountyLabel
bountyStroke.Color = Color3.new(0, 0, 0)
bountyStroke.Thickness = 2
bountyStroke.Transparency = 0.3

-- 5. UPDATE FPS + BOUNTY (rainbow + color)
local t = 0
local count = 0
local last = tick()
RS.Heartbeat:Connect(function()
    t += 0.03
    count += 1
    if tick() - last >= 1 then
        local fps = math.floor(count + 0.5)
        count = 0
        last = tick()
        local r = math.sin(t)*127 + 128
        local g = math.sin(t+2)*127 + 128
        local b = math.sin(t+4)*127 + 128
        fpsLabel.Text = "FPS: " .. fps
        fpsLabel.TextColor3 = Color3.fromRGB(r, g, b)
    end
    local ls = LP:FindFirstChild("leaderstats")
    if ls then
        local bounty = ls:FindFirstChild("Bounty") or ls:FindFirstChild("Bounty/Honor") or ls:FindFirstChild("Honor")
        if bounty then
            local val = bounty.Value
            local color = val >= 25000000 and Color3.fromRGB(255, 80, 80) or Color3.fromRGB(255, 215, 0)
            bountyLabel.TextColor3 = color
            bountyLabel.Text = "Bounty: " .. tostring(val):reverse():gsub("(%d%d%d)", ".%1"):reverse():gsub("^%.", "") .. "$"
        end
    end
end)

notify("✅ FIXED: Hop Tap + FPS/Bounty Visible + Webhook READY! 🔥")
print("FULL FIXED SCRIPT DONE – TEST LIỀU CU!")
