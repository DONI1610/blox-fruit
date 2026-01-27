local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local VirtualUser = game:GetService("VirtualUser")
local player = Players.LocalPlayer
local function safeCall(fn, ...)
    if type(fn) ~= "function" then
        return false, "not a function"
    end
    local ok, res = pcall(fn, ...)
    return ok, res
end
local function safeLoadModule(url, name)
    local ok, res = pcall(function()
        local body = game:HttpGet(url)
        local f, err = loadstring(body)
        if not f then error(err) end
        return f()
    end)
    if ok then
        return res
    else
        warn(("Failed to load module [%s] from %s : %s"):format(tostring(name or url), tostring(url), tostring(res)))
        return nil, res
    end
end
local WindUI = nil
local ok, ui = pcall(function()
    return loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
end)
if ok and ui then
    WindUI = ui
else
    error("Failed to load WindUI. Aborting GUI load. Error: " .. tostring(ui))
end
local Window = WindUI:CreateWindow({
    Title = "doni PvP",
    Icon = "rbxassetid://111450164466537",
    Author = "by Khanhly",
    Folder = "doni pranium",
    Size = UDim2.fromOffset(580, 340),
    Transparent = true,
    Theme = "Dark",
    Resizable = true,
    SideBarWidth = 150,
    Background = "rbxassetid://119426508066372",
    BackgroundImageTransparency = 0.42,
    HideSearchBar = false,
    ScrollBarEnabled = false,
    User = { Enabled = true, Anonymous = false },
})
Window:EditOpenButton({
    Title = "khanhly Hub",
    Icon = "rbxassetid://111450164466537",
    CornerRadius = UDim.new(0,40),
    StrokeThickness = 1,
    Color = ColorSequence.new(Color3.fromHex("FF0F7B"), Color3.fromHex("F89B29")),
    Draggable = true,
})
local Tabs = {
    Ds = Window:Tab({ Title = "Discord", Icon = "ghost" }),
    Main = Window:Tab({ Title = "Main", Icon = "gem" }),
    Fus = Window:Tab({ Title = "Function", Icon = "cog" }),
    Seg = Window:Tab({ Title = "Settings", Icon = "cog" }),
}
Tabs.Ds:Button({
    Title = "Copy Link Discord Khanhly",
    Desc = "Sao chép link Discord vào clipboard",
    Callback = function()
        pcall(setclipboard, "https://discord.com/invite/shkGwKQMaM")
        StarterGui:SetCore("SendNotification", {
            Title = "Đã sao chép!",
            Text = "Link Discord Khanhly đã được copy vào clipboard.",
            Duration = 5
        })
    end,
})
Tabs.Ds:Button({
    Title = "Copy Link tiktok Khanhly",
    Desc = "Sao chép link tiktok vào clipboard",
    Callback = function()
        pcall(setclipboard, "https://www.tiktok.com/@script.khanhly?_r=1&_t=ZS-91sOTk6TLaE")
        StarterGui:SetCore("SendNotification", {
            Title = "Đã sao chép!",
            Text = "Link tiktok Khanhly đã được copy vào clipboard.",
            Duration = 5
        })
    end,
})
local modules = {}
local function registerModule(key, url, name)
    local mod, err = safeLoadModule(url, name or key)
    modules[key] = mod
    if not mod then
        WindUI:Notify({
            Title = (name or key).." Load Failed",
            Content = "Module failed to load. Check URL or network.",
            Duration = 4,
            Type = "error"
        })
    end
    return mod
end
modules.Aimbot = safeLoadModule("https://raw.githubusercontent.com/kdo91653-cpu/bloxkidPVP-/refs/heads/main/Aim%20play", "Aimbot")
modules.CamlockWave = safeLoadModule("https://raw.githubusercontent.com/kdo91653-cpu/bloxkidPVP-/refs/heads/main/Camlock", "CamlockWave")
modules.HitboxExpansion = safeLoadModule("https://raw.githubusercontent.com/kdo91653-cpu/bloxkidPVP-/refs/heads/main/Hitbox", "HitboxExpansion")
modules.FlashAttack = safeLoadModule("https://raw.githubusercontent.com/kdo91653-cpu/bloxkidPVP-/refs/heads/main/Flash%20attack", "FlashAttack")
modules.RaceV4 = safeLoadModule("https://raw.githubusercontent.com/kdo91653-cpu/bloxkidPVP-/refs/heads/main/RaceV4", "RaceV4")
modules.AntiStun = safeLoadModule("https://raw.githubusercontent.com/kdo91653-cpu/bloxkidPVP-/refs/heads/main/Anti%20stun", "AntiStun")
modules.WalkOnWater = safeLoadModule("https://raw.githubusercontent.com/kdo91653-cpu/bloxkidPVP-/refs/heads/main/Walkwater", "WalkOnWater")

modules.Ken = safeLoadModule("https://raw.githubusercontent.com/kdo91653-cpu/bloxkidPVP-/refs/heads/main/Ken", "AutoObserve")
modules.Buso = safeLoadModule("https://raw.githubusercontent.com/kdo91653-cpu/bloxkidPVP-/refs/heads/main/Haki%20buso", "AutoBuso")
modules.InfiniteSoru = safeLoadModule("https://raw.githubusercontent.com/kdo91653-cpu/bloxkidPVP-/refs/heads/main/Soru", "InfiniteSoru")
modules.DodgeNoCD = safeLoadModule("https://raw.githubusercontent.com/kdo91653-cpu/bloxkidPVP-/refs/heads/main/No%20cd", "DodgeNoCD")
modules.ESPPro = safeLoadModule("https://raw.githubusercontent.com/kdo91653-cpu/bloxkidPVP-/refs/heads/main/Esp", "ESPPro")
modules.NoClip = safeLoadModule("https://raw.githubusercontent.com/kdo91653-cpu/bloxkidPVP-/refs/heads/main/Noclip", "NoClip")
modules.Speed = safeLoadModule("https://raw.githubusercontent.com/kdo91653-cpu/bloxkidPVP-/refs/heads/main/Speed", "Speed")
modules.JumpHack = safeLoadModule("https://raw.githubusercontent.com/kdo91653-cpu/bloxkidPVP-/refs/heads/main/Jump", "JumpHack")
modules.FPSBoost = safeLoadModule("https://raw.githubusercontent.com/kdo91653-cpu/bloxkidPVP-/refs/heads/main/Fps%20boss", "FPSBoost")
modules.FPSBoostMAX = safeLoadModule("https://raw.githubusercontent.com/kdo91653-cpu/bloxkidPVP-/refs/heads/main/Fps%20boost%20max", "FPSBoostMAX")
modules.FpsPing = safeLoadModule("https://raw.githubusercontent.com/kdo91653-cpu/bloxkidPVP-/refs/heads/main/Fps%20ping%20v2", "FpsPing")

local secMain = Tabs.Main:Section({ Title = "Auto PVP", Opened = true })
secMain:Toggle({
    Title = "AIMbot Player",
    Desc = "Bật/tắt aim",
    Default = false,
    Callback = function(state)
        local m = modules.Aimbot
        if m and type(m.SetPlayerSilentAim) == "function" then
            local ok, err = pcall(function() m:SetPlayerSilentAim(state) end)
            if not ok then warn("Aimbot:SetPlayerSilentAim error:", err) end
        else
            warn("Aimbot module not available or missing SetPlayerSilentAim")
        end
    end
})
secMain:Toggle({
    Title = "Wave Camlock",
    Desc = "Camlock T/Y để điều khiển",
    Default = false,
    Callback = function(state)
        local module = modules.CamlockWave
        if module and type(module.SetState) == "function" then
            pcall(function()
                module:SetState(state)
            end)
        else
            warn("Camlock module not available")
        end
    end
})
secMain:Toggle({
    Title = "Hitbox Expansion",
    Desc = "Mở rộng hitbox đối thủ",
    Default = false,
    Callback = function(state)
        local m = modules.HitboxExpansion
        if m and type(m.SetState) == "function" then
            local ok, err = pcall(function() m:SetState(state) end)
            if not ok then warn("Hitbox SetState error:", err) end
        else
            warn("Hitbox module not available or missing SetState")
        end
    end
})
secMain:Toggle({
    Title = "Flash Attack",
    Desc = "Attack",
    Default = false,
    Callback = function(state)
        local m = modules.FlashAttack
        if m and type(m.SetState) == "function" then
            pcall(function() m:SetState(state) end)
        else
            warn("FlashAttack module not available or missing SetState")
        end
    end
})
secMain:Toggle({
    Title = "Auto Race V4",
    Desc = "Auto race",
    Default = false,
    Callback = function(state)
        local m = modules.RaceV4
        if m and type(m.SetState) == "function" then
            pcall(function() m:SetState(state) end)
        else
            warn("RaceV4 module not available or missing SetState")
        end
    end
})
secMain:Toggle({
    Title = "Anti Stun",
    Desc = "Kháng hiệu ứng stun/knockback",
    Default = false,
    Callback = function(state)
        local m = modules.AntiStun
        if m and type(m.SetState) == "function" then
            pcall(function() m:SetState(state) end)
        else
            warn("AntiStun module not available or missing SetState")
        end
    end
})
secMain:Toggle({
    Title = "Walk Water",
    Desc = "Đi trên mặt nước",
    Default = false,
    Callback = function(state)
        local m = modules.WalkOnWater
        if m and type(m.SetState) == "function" then
            pcall(function() m:SetState(state) end)
        else
            warn("WalkOnWater module not available or missing SetState")
        end
    end
})
local secAuto = Tabs.Fus:Section({ Title = "Auto Skill", Icon = "sword", Opened = true })
local function makeSimpleToggle(tab, title, desc, moduleKey, methodName)
    tab:Toggle({
        Title = title,
        Desc = desc,
        Default = false,
        Callback = function(state)
            local m = modules[moduleKey]
            if m and type(m[methodName]) == "function" then
                local ok, err = pcall(function() m[methodName](m, state) end)
                if not ok then warn(moduleKey .. " " .. methodName .. " error:", err) end
            else
                warn(moduleKey, "not available or missing method", methodName)
            end
        end
    })
end

makeSimpleToggle(Tabs.Fus, "Auto observe", "obs Haki", "Ken", "SetState")
makeSimpleToggle(Tabs.Fus, "Auto Haki vũ trang", "Buso Haki", "Buso", "SetState")
makeSimpleToggle(Tabs.Fus, "Infinite Soru", "cooldown Soru", "InfiniteSoru", "SetState")
makeSimpleToggle(Tabs.Fus, "Dodge No Cooldown", "Dodge skill", "DodgeNoCD", "SetState")

local secFunc = Tabs.Fus:Section({ Title = "Function", Opened = true })
makeSimpleToggle(Tabs.Fus, "ESP Player", "esp avatar", "ESPPro", "SetState")
makeSimpleToggle(Tabs.Fus, "NoClip", "Xuyên", "NoClip", "SetState")
makeSimpleToggle(Tabs.Fus, "Speed", "ON / OFF", "Speed", "SetState")

Tabs.Fus:Slider({
    Title = "speed walk",
    Desc = "Điều chỉnh tốc độ di chuyển",
    Step = 1,
    Value = {
        Min = 16,
        Max = 3000,
        Default = 16,
    },
    Callback = function(value)
        local m = modules.Speed
        if m and type(m.SetSpeed) == "function" then
            local ok, err = pcall(function() m:SetSpeed(value) end)
            if not ok then warn("Speed:SetSpeed error:", err) end
        else
            warn("Speed module not available or missing SetSpeed")
        end
    end
})
makeSimpleToggle(Tabs.Fus, "Jump", "ON / OFF", "JumpHack", "SetState")
Tabs.Fus:Slider({
    Title = "Jump Power",
    Desc = "Điều chỉnh sức nhảy",
    Step = 10,
    Value = {
        Min = 50,
        Max = 3000,
        Default = 1000,
    },
    Callback = function(value)
        local m = modules.JumpHack
        if m and type(m.SetJumpPower) == "function" then
            local ok, err = pcall(function() m:SetJumpPower(value) end)
            if not ok then warn("JumpHack:SetJumpPower error:", err) end
        else
            warn("JumpHack module not available or missing SetJumpPower")
        end
    end
})
local secSettings = Tabs.Seg:Section({ Title = "Settings", Opened = true })
makeSimpleToggle(Tabs.Seg, "FPS Boost", "Tối ưu hóa FPS", "FPSBoost", "SetState")
makeSimpleToggle(Tabs.Seg, "FPS Boost MAX", "Tối ưu hóa FPS", "FPSBoostMAX", "SetState")
makeSimpleToggle(Tabs.Seg, "FPS/Ping Display", "ping fps", "FpsPing", "SetDisplayState")

local antiAfkConnection
local notifyLoop
Tabs.Seg:Toggle({
    Title = "Anti AFK",
    Desc = "Tự động tránh kick AFK",
    Default = false,
    Callback = function(Value)
        if Value then
            if not antiAfkConnection then
                antiAfkConnection = player.Idled:Connect(function()
                    VirtualUser:CaptureController()
                    VirtualUser:ClickButton2(Vector2.new(0,0))
                end)
            end
            WindUI:Notify({ Title = "Anti AFK", Content = "Đã bật", Duration = 4, Type = "success" })
            notifyLoop = task.spawn(function()
                while task.wait(600) do
                    WindUI:Notify({ Title = "Anti AFK", Content = "Vẫn đang hoạt động!", Duration = 4, Type = "info" })
                end
            end)
        else
            if antiAfkConnection then
                antiAfkConnection:Disconnect()
                antiAfkConnection = nil
            end
            if notifyLoop then
                task.cancel(notifyLoop)
                notifyLoop = nil
            end
            WindUI:Notify({ Title = "Anti AFK", Content = "Đã tắt!", Duration = 4, Type = "error" })
        end
    end,
})
local function getServersPage(gameId, cursor)
    local url = ("https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=Asc&limit=100"):format(gameId)
    if cursor then url = url .. "&cursor=" .. tostring(cursor) end
    local ok, res = pcall(function() return game:HttpGet(url) end)
    if not ok then return nil, res end
    local ok2, data = pcall(function() return HttpService:JSONDecode(res) end)
    if not ok2 then return nil, data end
    return data
end
local function serverHop()
    local gameId = game.PlaceId
    local currentJobId = game.JobId
    local data, err = getServersPage(gameId)
    if not data then
        WindUI:Notify({ Title = "Server Hop", Content = "⚠️ Không lấy được danh sách server.", Duration = 4, Type = "error" })
        return
    end
    local servers = {}
    for _, server in pairs(data.data or {}) do
        if server.id ~= currentJobId and server.playing < (server.maxPlayers or 0) then
            table.insert(servers, server.id)
        end
    end
    if #servers > 0 then
        local randomServer = servers[math.random(1, #servers)]
        WindUI:Notify({ Title = "Server Hop", Content = "🔁 Đang chuyển sang server mới...", Duration = 3, Type = "info" })
        task.wait(1)
        TeleportService:TeleportToPlaceInstance(gameId, randomServer, Players.LocalPlayer)
    else
        WindUI:Notify({ Title = "Server Hop", Content = "❌ Không tìm thấy server phù hợp.", Duration = 4, Type = "warning" })
    end
end
Tabs.Seg:Button({
    Title = "Server Hop",
    Desc = "Chuyển sang server ngẫu nhiên khác",
    Callback = serverHop,
})
local function randomServer()
    local gameId = game.PlaceId
    local currentJobId = game.JobId
    local data = getServersPage(gameId)
    if not data then
        WindUI:Notify({ Title = "Random Server", Content = "⚠️ Không lấy được danh sách server.", Duration = 4, Type = "error" })
        return
    end
    local allServers = {}
    for _, server in pairs(data.data or {}) do
        if server.playing < (server.maxPlayers or 0) and server.id ~= currentJobId then
            table.insert(allServers, server.id)
        end
    end
    if #allServers > 0 then
        local pick = allServers[math.random(1, #allServers)]
        WindUI:Notify({ Title = "Random Server", Content = "🎲 Đang chuyển sang server ngẫu nhiên...", Duration = 3, Type = "info" })
        task.wait(1)
        TeleportService:TeleportToPlaceInstance(gameId, pick, Players.LocalPlayer)
    else
        WindUI:Notify({ Title = "Random Server", Content = "❌ Không tìm thấy server phù hợp.", Duration = 4, Type = "warning" })
    end
end
Tabs.Seg:Button({
    Title = "Random Server",
    Desc = "Vào server ngẫu nhiên bất kỳ",
    Callback = randomServer,
})

WindUI:Notify({ Title = "khanhly Hub", Content = "Loaded (safe mode).", Duration = 3, Type = "success" })
