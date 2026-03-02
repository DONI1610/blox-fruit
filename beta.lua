local function getClosestPlayer()
    local localPlayer = game.Players.LocalPlayer
    local closestPlayer = nil
    local shortestDistance = math.huge
    
    for _, player in pairs(game.Players:GetPlayers()) do
        if player ~= localPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local distance = (player.Character.HumanoidRootPart.Position - localPlayer.Character.HumanoidRootPart.Position).magnitude
            if distance < shortestDistance then
                shortestDistance = distance
                closestPlayer = player
            end
        end
    end
    return closestPlayer
end

local function highlightPlayers()
    for _, player in pairs(game.Players:GetPlayers()) do
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local highlight = Instance.new("Highlight")
            highlight.Adornee = player.Character
            highlight.FillColor = Color3.fromRGB(255, 0, 0)
            highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
            highlight.Parent = player.Character
            
            -- Hiển thị tên người chơi to hơn
            local billboard = Instance.new("BillboardGui")
            billboard.Size = UDim2.new(0, 200, 0, 50)
            billboard.StudsOffset = Vector3.new(0, 3, 0)
            billboard.AlwaysOnTop = true
            billboard.Parent = player.Character.HumanoidRootPart
            
            local textLabel = Instance.new("TextLabel")
            textLabel.Size = UDim2.new(1, 0, 1, 0)
            textLabel.BackgroundTransparency = 1
            textLabel.Text = player.Name
            textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            textLabel.TextScaled = true
            textLabel.Font = Enum.Font.SourceSansBold
            textLabel.Parent = billboard
        end
    end
end

spawn(function()
    highlightPlayers()
    local gg = getrawmetatable(game)
    local old = gg.__namecall
    setreadonly(gg, false)
    gg.__namecall = newcclosure(function(self, ...)
        local method = getnamecallmethod()
        local args = {...}
        if method == "FireServer" and tostring(args[1]) == "RemoteEvent" then
            if AimbotSkillPlayer and args[2] and type(args[2]) ~= "boolean" then
                if type(args[2]) == "Vector3" then
                    args[2] = Player_Position
                else
                    args[2] = CFrame.new(Player_Position)
                end
                return old(self, unpack(args))
            end
        end
        return old(self, ...)
    end)
end)

spawn(function()
    while task.wait() do
        if AimbotSkillPlayer then 
            pcall(function()
                local localPlayer = game:GetService("Players").LocalPlayer
                local character = localPlayer.Character
                if character and character:FindFirstChild("Humanoid") then
                    local health = character.Humanoid.Health
                    if health < 5000 then
                        Player_Position = character.HumanoidRootPart.Position + Vector3.new(0, 0, 50) -- Lùi xa khi máu thấp
                    elseif health > 8000 then
                        local targetPlayer = getClosestPlayer()
                        if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
                            Player_Position = targetPlayer.Character.HumanoidRootPart.Position
                            
                            -- Xoay hướng cơ thể về phía người chơi gần nhất
                            character:SetPrimaryPartCFrame(CFrame.new(character.PrimaryPart.Position, Player_Position))
                        end
                    end
                end
                
                if character and character:FindFirstChild(SelectWeaponPvp) then
                    local weapon = character:FindFirstChild(SelectWeaponPvp)
                    weapon.MousePos.Value = Player_Position
                    
                    local function pressKey(key)
                        game:GetService("VirtualInputManager"):SendKeyEvent(true, key, false, game)
                        task.wait(0.1)
                        game:GetService("VirtualInputManager"):SendKeyEvent(false, key, false, game)
                    end
                    
                    if PvpSkillZ then pressKey("Z") end
                    if PvpSkillX then pressKey("X") end
                    if PvpSkillC then pressKey("C") end
                    if PvpSkillV then pressKey("V") end
                    
                    -- Thay đổi vị trí trỏ chuột để nhắm vào mục tiêu
                    local mouse = game:GetService("Players").LocalPlayer:GetMouse()
                    mouse.Hit = CFrame.new(Player_Position)
                end
            end)
        end
    end
end)
