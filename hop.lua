-- FULL FIXED SCRIPT – SERVER HOP STABLE VERSION

-- SERVICES
local TS = game:GetService("TeleportService")
local HS = game:GetService("HttpService")
local PLRS = game:GetService("Players")
local SG = game:GetService("StarterGui")
local UIS = game:GetService("UserInputService")
local RS = game:GetService("RunService")

local PID = game.PlaceId
local LP = PLRS.LocalPlayer

-- WEBHOOK
local WEBHOOK_URL = "https://discord.com/api/webhooks/XXXXXXXXXXXX/XXXXXXXXXXXXXXXX"

-- =========================
-- 1. WEBHOOK START
-- =========================
local function sendStart()
    local ls = LP:FindFirstChild("leaderstats")
    if not ls then return end

    local bounty = (ls:FindFirstChild("Bounty") or ls:FindFirstChild("Bounty/Honor") or ls:FindFirstChild("Honor") or {Value = 0}).Value
    local level = (ls:FindFirstChild("Level") or {Value = 0}).Value

    pcall(function()
        HS:PostAsync(WEBHOOK_URL, HS:JSONEncode({
            embeds = {{
                title = "SCRIPT EXECUTED",
                description = string.format(
                    "%s started script\nBounty: %s\nLevel: %d",
                    LP.Name,
                    tostring(bounty):reverse():gsub("(%d%d%d)", "%1."):reverse():gsub("^%.", ""),
                    level
                ),
                color = 3447003,
                timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")
            }}
        }))
    end)
end
sendStart()

-- =========================
-- 2. NOTIFY
-- =========================
local function notify(txt)
    pcall(function()
        SG:SetCore("SendNotification", {
            Title = "Server Hop",
            Text = txt,
            Duration = 3
        })
    end)
end

-- =========================
-- 3. GET SERVERS (FIXED)
-- =========================
local function getAllServers()
    local servers = {}
    local cursor = ""

    repeat
        local url = ("https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=Asc&limit=100%s")
            :format(PID, cursor ~= "" and "&cursor=" .. cursor or "")

        local ok, res = pcall(function()
            return HS:JSONDecode(game:HttpGet(url))
        end)
        if not ok or not res then break end

        for _, v in ipairs(res.data or {}) do
            if v.playing >= 5 and v.playing <= v.maxPlayers - 5 then
                table.insert(servers, v)
            end
        end

        cursor = res.nextPageCursor or ""
    until cursor == ""

    -- shuffle
    for i = #servers, 2, -1 do
        local j = math.random(i)
        servers[i], servers[j] = servers[j], servers[i]
    end

    return servers
end

-- =========================
-- 4. HOP SERVER (FIXED)
-- =========================
local hopping = false

local function hopServer()
    if hopping then return end
    hopping = true

    local oldJob = game.JobId
    notify("Finding new server...")

    local servers = getAllServers()
    for _, srv in ipairs(servers) do
        if srv.id ~= oldJob then
            notify("Hopping: " .. srv.playing .. "/" .. srv.maxPlayers)
            task.wait(0.8)
            TS:TeleportToPlaceInstance(PID, srv.id, LP)
            task.wait(3)

            if game.JobId ~= oldJob then
                return
            end
        end
    end

    notify("Fallback random hop")
    task.wait(1)
    TS:Teleport(PID, LP)
end

-- =========================
-- 5. HOP GUI
-- =========================
local HopGui = Instance.new("ScreenGui")
HopGui.Parent = game:GetService("CoreGui")
HopGui.ResetOnSpawn = false

local HopFrame = Instance.new("Frame")
HopFrame.Parent = HopGui
HopFrame.Size = UDim2.new(0, 120, 0, 50)
HopFrame.Position = UDim2.new(1, -130, 1, -60)
HopFrame.BackgroundColor3 = Color3.fromRGB(0, 162, 255)
HopFrame.BorderSizePixel = 0
HopFrame.Active = true
HopFrame.ZIndex = 999

Instance.new("UICorner", HopFrame).CornerRadius = UDim.new(0, 12)

local label = Instance.new("TextLabel")
label.Parent = HopFrame
label.Size = UDim2.new(1, 0, 1, 0)
label.BackgroundTransparency = 1
label.Text = "HOP SV"
label.Font = Enum.Font.GothamBold
label.TextScaled = true
label.TextColor3 = Color3.new(1, 1, 1)
label.ZIndex = 1000

-- DRAG + CLICK
local dragging, dragStart, startPos, clickStart = false, nil, nil, 0

HopFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then
        clickStart = tick()
        dragging = true
        dragStart = input.Position
        startPos = HopFrame.Position
    end
end)

UIS.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
    or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        HopFrame.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
    end
end)

UIS.InputEnded:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch) then
        dragging = false
        if tick() - clickStart < 0.15 then
            hopServer()
        end
    end
end)

-- =========================
-- 6. FPS + BOUNTY
-- =========================
local FPSGui = Instance.new("ScreenGui")
FPSGui.Parent = game:GetService("CoreGui")
FPSGui.ResetOnSpawn = false

local fpsLabel = Instance.new("TextLabel", FPSGui)
fpsLabel.Position = UDim2.new(0, 12, 0, 10)
fpsLabel.Size = UDim2.new(0, 180, 0, 28)
fpsLabel.BackgroundTransparency = 1
fpsLabel.Font = Enum.Font.GothamBold
fpsLabel.TextSize = 24
fpsLabel.Text = "FPS: 0"

local bountyLabel = Instance.new("TextLabel", FPSGui)
bountyLabel.Position = UDim2.new(0, 12, 0, 42)
bountyLabel.Size = UDim2.new(0, 350, 0, 32)
bountyLabel.BackgroundTransparency = 1
bountyLabel.Font = Enum.Font.GothamBlack
bountyLabel.TextSize = 28
bountyLabel.Text = "Bounty: ..."

local frames, last, t = 0, tick(), 0

RS.Heartbeat:Connect(function()
    frames += 1
    t += 0.03

    if tick() - last >= 1 then
        fpsLabel.Text = "FPS: " .. frames
        fpsLabel.TextColor3 = Color3.fromRGB(
            math.sin(t) * 127 + 128,
            math.sin(t + 2) * 127 + 128,
            math.sin(t + 4) * 127 + 128
        )
        frames = 0
        last = tick()
    end

    local ls = LP:FindFirstChild("leaderstats")
    if ls then
        local b = ls:FindFirstChild("Bounty") or ls:FindFirstChild("Bounty/Honor") or ls:FindFirstChild("Honor")
        if b then
            bountyLabel.Text = "Bounty: " ..
                tostring(b.Value):reverse():gsub("(%d%d%d)", ".%1"):reverse():gsub("^%.", "")
        end
    end
end)

notify("Script loaded successfully")
