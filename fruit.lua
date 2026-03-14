-- Script chỉ chứa 2 đoạn code của bạn
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer

-- Đợi game load
repeat wait(1) until game:IsLoaded() and LocalPlayer

-- ========================================
-- ĐOẠN CODE 1: AUTO TEAM CỦA BẠN
-- ========================================
local desiredTeam = "Marines"

if not LocalPlayer.Team or LocalPlayer.Team.Name ~= desiredTeam then
    pcall(function()
        ReplicatedStorage.Remotes.CommF_:InvokeServer("SetTeam", desiredTeam)
    end)
end

-- ========================================
-- ĐOẠN CODE 2: AUTO STORE FRUIT CỦA BẠN (UpdStFruit)
-- ========================================
local function UpdStFruit()
    for I, e in next, LocalPlayer.Backpack:GetChildren() do
        local StoreFruit = e:FindFirstChild("EatRemote", true)
        if StoreFruit then
            ReplicatedStorage.Remotes.CommF_:InvokeServer(
                "StoreFruit", 
                StoreFruit.Parent:GetAttribute("OriginalName"), 
                LocalPlayer.Backpack:FindFirstChild(e.Name)
            )
        end
    end
end

-- Gọi hàm lưu trữ
UpdStFruit()
