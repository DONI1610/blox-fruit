--[[
    Script chỉ lấy phần HOP SERVER từ doni (1).lua
    Bao gồm: Rejoin, Hop Random, Hop to Lowest Players, Hop to Lowest Ping, Teleport via JobID
--]]

-- Khởi tạo các service cần thiết
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local Stats = game:GetService("Stats")

local LocalPlayer = Players.LocalPlayer

-- Biến cho JobID
getgenv().JobId = ""

-- === HOP SERVER (Giữ nguyên từ file gốc) ===

-- Nút: Rejoin Server
local function rejoinServer()
    TeleportService:Teleport(game.PlaceId, LocalPlayer)
end

-- Nút: Hop Server (Ngẫu nhiên)
local function hopServer()
    pcall(function()
        for i = math.random(1, math.random(40, 75)), 100, 1 do
            local servers = ReplicatedStorage.__ServerBrowser:InvokeServer(i)
            for id, info in next, servers do
                if tonumber(info.Count) < 12 then
                    TeleportService:TeleportToPlaceInstance(game.PlaceId, id)
                end
            end
        end
    end)
end

-- Nút: Hop to Lowest Players
local function hopToLowestPlayers()
    local apiUrl = "https://games.roblox.com/v1/games/"
    local placeId = game.PlaceId
    local url = apiUrl .. placeId .. "/servers/Public?sortOrder=Asc&limit=100"
    
    local function listServers(cursor)
        local fullUrl = url .. (cursor and "&cursor=" .. cursor or "")
        local success, response = pcall(function()
            return HttpService:JSONDecode(game:HttpGet(fullUrl))
        end)
        if success then
            return response
        end
        return nil
    end

    local cursor, bestServer
    repeat
        local data = listServers(cursor)
        if data and data.data then
            for _, server in ipairs(data.data) do
                if not bestServer or server.playing < bestServer.playing then
                    bestServer = server
                end
            end
            cursor = data.nextPageCursor
        else
            break
        end
    until not cursor or bestServer

    if bestServer then
        TeleportService:TeleportToPlaceInstance(placeId, bestServer.id, LocalPlayer)
    end
end

-- Nút: Hop to Lowest Ping
local function hopToLowestPing()
    local function fetchServers(placeId, limit)
        local url = string.format("https://games.roblox.com/v1/games/%d/servers/Public?limit=%d", placeId, limit)
        local success, response = pcall(function()
            return HttpService:JSONDecode(game:HttpGet(url))
        end)
        if success and response and response.data then
            return response.data
        end
        return nil
    end

    local servers = fetchServers(game.PlaceId, 100)
    if not servers then return end

    local bestServer = servers[1]
    for _, server in ipairs(servers) do
        if server.ping < bestServer.ping and server.playing < server.maxPlayers then
            bestServer = server
        end
    end

    local currentPing = Stats.Network.ServerStatsItem["Data Ping"]:GetValueString()
    local pingValue = tonumber(currentPing:match("(%d+)"))
    if pingValue and pingValue >= 100 then
        TeleportService:TeleportToPlaceInstance(game.PlaceId, bestServer.id, LocalPlayer)
    else
        warn("Ping is good, no need to hop.")
    end
end

-- Nút: Teleport theo JobID
local function teleportByJobId()
    if getgenv().JobId and getgenv().JobId ~= "" then
        ReplicatedStorage.__ServerBrowser:InvokeServer("teleport", getgenv().JobId)
    else
        warn("Please enter a Job ID first.")
    end
end

-- Nút: Copy JobID
local function copyJobId()
    setclipboard(tostring(game.JobId))
end

-- === TẠO GUI ĐƠN GIẢN ===
local library = loadstring(game:HttpGet("https://raw.githubusercontent.com/bloodball/-backups-/main/uilibrary.lua"))()

local Window = library:CreateWindow("Server Hop Only")
local Main = Window:AddTab("Main")

Main:AddButton("Rejoin Server", function()
    rejoinServer()
end)

Main:AddButton("Hop Random Server", function()
    hopServer()
end)

Main:AddButton("Hop to Lowest Players", function()
    hopToLowestPlayers()
end)

Main:AddButton("Hop to Lowest Ping", function()
    hopToLowestPing()
end)

Main:AddTextBox("Job ID", "Enter Job ID here...", function(value)
    getgenv().JobId = value
end)

Main:AddButton("Teleport via Job ID", function()
    teleportByJobId()
end)

Main:AddButton("Copy Current Job ID", function()
    copyJobId()
end)
