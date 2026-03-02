-- decom at discord.gg/jwWnP8qJPw

local SilentAimModule = {}

local Players = game:GetService("Players")
local player = Players.LocalPlayer
local Character = player.Character or player.CharacterAdded:Wait()
local UserInputService = game:GetService("UserInputService")  
local RunService = game:GetService("RunService")
local camera = workspace.CurrentCamera
local RS = game:GetService("ReplicatedStorage")
local commE = RS:WaitForChild("Remotes"):WaitForChild("CommE")
local MouseModule = RS:FindFirstChild("Mouse")

local Services = setmetatable({}, {
    __index = function(self, serviceName)
        local good, service = pcall(game.GetService, game, serviceName);
        if (good) then
            self[serviceName] = service
            return service;
        end
    end
});

-- Biến trạng thái CHÍNH
local SilentAimPlayersEnabled = false
local UserWantsplayerAim = false
local PredictionEnabled = false
local HighlightEnabled = false 
local AutoKen = false
local ZSkillorM1 = false
local autoKenRunning = false

local renderConnection = nil
local currentTool = nil
local playersaimbot = nil
local PlayersPosition = nil
local currentHighlight = nil
local Selectedplayer = nil
local MiniPlayerState = nil
local MiniPlayerCreated = false
local MiniPlayerGui = nil

local characterConnections = {}
local Skills = {"X"}
local Booms = {"TAP"}

local PredictionAmount = 0.1
local maxRange = 1000

-- ================= VSkillModule Integration =================
local lastTool = nil
local sharkZActive, vActive, cursedZActive = false, false, false
local dmgConn = nil
local rightTouchActive = false

local function clearVSkillConnections()
	if dmgConn then
		pcall(function() dmgConn:Disconnect() end)
		dmgConn = nil
	end
end

local function DisableSilentAimbot()
    SilentAimPlayersEnabled = false
end

local function EnableSilentAimbot()
    SilentAimPlayersEnabled = UserWantsplayerAim
end

local function hookTool(tool)
    currentTool = tool
    lastTool = tool.Name
    table.insert(characterConnections, tool.AncestryChanged:Connect(function(_, parent)
        if not parent then
            currentTool = nil
            lastTool = nil
            sharkZActive, vActive, cursedZActive = false, false, false
            rightTouchActive = false
            EnableSilentAimbot()
        end
    end))
end

local function isValidStopCondition()
    return (currentTool and currentTool.Name == "Shark Anchor" and sharkZActive)
        or (lastTool == "Dough-Dough" and vActive)
        or (currentTool and currentTool.Name == "Cursed Dual Katana" and cursedZActive)
end

-- Touch Control (Mobile)
UserInputService.TouchStarted:Connect(function(touch)
    local camera = workspace.CurrentCamera
    if not camera then return end
    
    if touch.Position.X > camera.ViewportSize.X / 2 then
        rightTouchActive = true

        if isValidStopCondition() then
            DisableSilentAimbot()
        end
    end
end)

UserInputService.TouchEnded:Connect(function(touch)
    local camera = workspace.CurrentCamera
    if not camera then return end
    
    if touch.Position.X > camera.ViewportSize.X / 2 then
        rightTouchActive = false

        EnableSilentAimbot()
        sharkZActive, vActive, cursedZActive = false, false, false
    end
end)

-- Damage Counter Watch
local function watchDamageCounter()
	clearVSkillConnections()

	task.spawn(function()
		while true do
			local gui = player:FindFirstChild("PlayerGui")
			if not gui then
				task.wait(1)
				continue
			end

			gui = gui:FindFirstChild("Main")
			if not gui then
				task.wait(1)
				continue
			end

			local dmgCounter = gui:FindFirstChild("DmgCounter")
			if not dmgCounter then
				task.wait(1)
				continue
			end

			local dmgTextLabel = dmgCounter:FindFirstChild("Text")
			if not dmgTextLabel then
				task.wait(1)
				continue
			end

			dmgConn = dmgTextLabel:GetPropertyChangedSignal("Text"):Connect(function()
				local dmgText = tonumber(dmgTextLabel.Text) or 0
				if dmgText > 0 and isValidStopCondition() and rightTouchActive then
					DisableSilentAimbot()
				elseif not rightTouchActive then
					EnableSilentAimbot()
				end
			end)
			table.insert(characterConnections, dmgConn)			
			break
		end
	end)
end

-- Skill Detection
if not getgenv().VSkillHooked then
    getgenv().VSkillHooked = true
    local old
	old = hookmetamethod(game, "__namecall", function(self, ...)
	    local method = getnamecallmethod()
	    local args = {...}
    
	    if (method == "InvokeServer" or method == "FireServer") then
	        local a1 = args[1]

	        if typeof(a1) == "string" and a1:upper() == "Z" then
	            if currentTool and currentTool.Name == "Shark Anchor" then
	                sharkZActive = true
	            end
	        end
        
	        if typeof(a1) == "string" and a1:upper() == "V" then
	            if lastTool == "Dough-Dough" then
	                vActive = true
	            end
	        end
        
	        if typeof(a1) == "string" and a1:upper() == "Z" then
	            if currentTool and currentTool.Name == "Cursed Dual Katana" then
	                cursedZActive = true
	            end
			end
	    end
	    return old(self, ...)
	end)
end
-- ================= END VSkillModule =================

-- Lấy HumanoidRootPart
local function getHRP(model)
	if not model or not model:FindFirstChild("HumanoidRootPart") then return nil end
	return model.HumanoidRootPart
end

-- Xóa connections cũ
local function clearConnections()
	for _, conn in ipairs(characterConnections) do
		pcall(function() conn:Disconnect() end)
	end
	characterConnections = {}
	clearVSkillConnections()
end

-- Tính toán vị trí dự đoán
local function getPredictedPosition(hrp)
	if not hrp then return nil end

	local humanoid = hrp.Parent:FindFirstChildOfClass("Humanoid")
	if not humanoid then
		return hrp.Position
	end

	if not PredictionEnabled or humanoid.WalkSpeed < 5 then
		return hrp.Position
	end

	return hrp.Position + (hrp.Velocity * PredictionAmount)
end

-- Kiểm tra đồng đội
local function isAllyWithMe(targetplayer)
	local myGui = player:FindFirstChild("PlayerGui")
	if not myGui then return false end

	local scrolling = myGui:FindFirstChild("Main")
		and myGui.Main:FindFirstChild("Allies")
		and myGui.Main.Allies:FindFirstChild("Container")
		and myGui.Main.Allies.Container.Allies:FindFirstChild("ScrollingFrame")

	if scrolling then
		for _, frame in pairs(scrolling:GetDescendants()) do
			if frame:IsA("ImageButton") and frame.Name == targetplayer.Name then
				return true
			end
		end
	end

	return false
end

-- Kiểm tra kẻ thù
local function isEnemy(targetplayer)
	if not targetplayer or targetplayer == player then
		return false
	end

	local myTeam = player.Team
	local targetTeam = targetplayer.Team

	if myTeam and targetTeam then
		if myTeam.Name == "Pirates" and targetTeam.Name == "Marines" then
			return true
		elseif myTeam.Name == "Marines" and targetTeam.Name == "Pirates" then
			return true
		end

		if myTeam.Name == "Pirates" and targetTeam.Name == "Pirates" then
			if isAllyWithMe(targetplayer) then
				return false -- ally, not enemy
			end
			return true
		end

		if myTeam.Name == "Marines" and targetTeam.Name == "Marines" then
			return false
		end
	end

	return true
end

-- Tìm player gần nhất
local function getClosestplayer(lpHRP)
	if not lpHRP then return nil end
	
	local closest = nil
	local closestDist = math.huge
	for _, pl in ipairs(Players:GetPlayers()) do
		if pl ~= player and isEnemy(pl) and pl.Character and pl.Character.Parent ~= nil then
			local hum = pl.Character:FindFirstChildWhichIsA("Humanoid")
			local hrp = getHRP(pl.Character)
			if hum and hum.Health > 0 and hrp then
				local dist = (hrp.Position - lpHRP.Position).Magnitude
				if dist <= maxRange and dist < closestDist then
					closestDist = dist
					closest = pl
				end
			end
		end
	end
	return closest
end

-- Kiểm tra skill ready
local function isSkillReadyForTool(toolName)
    if not toolName then return false end
    local playerGui = player:FindFirstChild("PlayerGui")
    if not playerGui then return false end
    local skillsFolder = playerGui:FindFirstChild("Main") and playerGui.Main:FindFirstChild("Skills")
    if not skillsFolder then return false end
    local toolFrame = skillsFolder:FindFirstChild(toolName)
    if not toolFrame then return false end

    for _, skillKey in ipairs({"Z","X","C","V"}) do
        local skill = toolFrame:FindFirstChild(skillKey)
        if skill and skill:FindFirstChild("Cooldown") and skill.Cooldown:IsA("Frame") then
            local cooldownSize = skill.Cooldown.Size.X.Scale
            if cooldownSize == 1.0 then
                return true
            end
        end
    end
    return false
end

local function isNotDoughValidCondition()
    return (currentTool and currentTool.Name == "Dough-Dough")
end

local function isNotValidCondition()
    return (currentTool and currentTool.Name == "Lightning-Lightning")
    or (currentTool and currentTool.Name == "Portal-Portal")
end

-- Main render loop cho aimbot player
local function startRenderLoop()
    if renderConnection then return end

    renderConnection = RunService.RenderStepped:Connect(function()
        local lpChar = player.Character
        if not lpChar then return end
        local lpHRP = lpChar:FindFirstChild("HumanoidRootPart")
        if not lpHRP then return end

        if not SilentAimPlayersEnabled then
            return
        end

        local lookTargetPos = nil

        if SilentAimPlayersEnabled then
            local targetplayer = Selectedplayer or getClosestplayer(lpHRP)
            if targetplayer and targetplayer ~= player and targetplayer.Character then
                playersaimbot = targetplayer.Name
                local hrp = getHRP(targetplayer.Character)
                PlayersPosition = getPredictedPosition(hrp)
                lookTargetPos = PlayersPosition
            else
                playersaimbot, PlayersPosition = nil, nil
            end
        end

        -- Tự động xoay character về hướng mục tiêu
        if currentTool and lookTargetPos and isSkillReadyForTool(currentTool.Name) and not isNotDoughValidCondition() then
	        local lookVector = (Vector3.new(lookTargetPos.X, lpHRP.Position.Y, lookTargetPos.Z) - lpHRP.Position).Unit
	            lpHRP.CFrame = CFrame.new(lpHRP.Position, lpHRP.Position + lookVector)
	    end
    end)
end

local function stopRenderLoop()
    if renderConnection then
        renderConnection:Disconnect()
        renderConnection = nil
    end
end

local function isValidCondition()
    return (currentTool and currentTool.Name == "Buddy Sword")
end

-- Hook metatable để thay đổi vị trí nhắm
spawn(function()
    local ok, hookMeta = pcall(getrawmetatable, game)
    if ok and hookMeta then
        setreadonly(hookMeta, false)
        local OldHook
        OldHook = hookmetamethod(game, "__namecall", function(self, V1, V2, ...)
            local Method = (getnamecallmethod and getnamecallmethod():lower()) or ""

            if tostring(self) == "RemoteEvent" and Method == "fireserver" then
                if typeof(V1) == "Vector3" then
                    if SilentAimPlayersEnabled and PlayersPosition then
                        return OldHook(self, PlayersPosition, V2, ...)
                    end
				end				
				if type(V1) == "string" and table.find(Booms, V1) then
					if ZSkillorM1 then 
	                    if SilentAimPlayersEnabled and PlayersPosition then
	                        return OldHook(self, V1, PlayersPosition, nil, ...)
	                    end
					end
				end   
            elseif Method == "invokeserver" then  
	            if isValidCondition() then
	                if type(V1) == "string" and table.find(Skills, V1) then  
	                    if SilentAimPlayersEnabled and PlayersPosition then  
	                        return OldHook(self, V1, PlayersPosition, nil, ...)
	                    end  
	                end    
				end				
			end
            
            return OldHook(self, V1, V2, ...)
        end)
        setreadonly(hookMeta, true)
    end
end)

-- Mouse hook (nếu cần)
if not isNotValidCondition() then
	if MouseModule and typeof(MouseModule) == "Instance" then
        local ok2, okResult = pcall(function()
            return require(MouseModule)
        end)

        if ok2 and okResult then  
            if type(okResult) == "table" then  
                Mouse = okResult  
            else  
                Mouse = nil  
            end  
        else  
            Mouse = nil  
        end  

        RunService.Heartbeat:Connect(function()  	        
		    if not ZSkillorM1 or (not SilentAimPlayersEnabled) then
		        return
		    end
		
            if Mouse and ZSkillorM1 and SilentAimPlayersEnabled then  
                local targetCFrame = nil  

                if PlayersPosition then  
                    targetCFrame = CFrame.new(PlayersPosition)  
                end  

                if targetCFrame then  
                    pcall(function()  
                        if type(Mouse) == "table" then  
                            Mouse.Hit = targetCFrame  
                            Mouse.Target = nil  
                        end  
                    end)  

                    if MouseModule then  
                        local ok, MouseData = pcall(require, MouseModule)  
                        if ok and type(MouseData) == "table" then  
                            MouseData.Hit = targetCFrame  
                            MouseData.Target = nil  
                        end  
                    end  
                end  
            end  
        end)
    end
end

-- Auto Ken function
local HasTag = function(tagName)
  local char = player.Character
  if (not char) then return false; end
  return Services.CollectionService:HasTag(char, tagName);
end

local function startAutoKenLoop()
    if autoKenRunning then return end
    autoKenRunning = true

    task.spawn(function()
        while AutoKen do
            task.wait(0.1)

            if HasTag("Ken") then
                local playerGui = player:FindFirstChild("PlayerGui")
                if playerGui then
                    local kenButton = playerGui:FindFirstChild("MobileContextButtons")
                    and playerGui.MobileContextButtons.ContextButtonFrame:FindFirstChild("BoundActionKen")

                    if kenButton and kenButton:GetAttribute("Selected") ~= true then
                        kenButton:SetAttribute("Selected", true)
                    end
                end

                local observationManager = getrenv()._G.OM
                if observationManager and not observationManager.active then
                    observationManager.radius = 0
                    observationManager:setActive(true)
                    commE:FireServer("Ken", true)
                end
            end
        end
        autoKenRunning = false
    end)
end

-- Character management
local function onCharacterAdded(char)
    clearConnections()

    for _, child in ipairs(char:GetChildren()) do
        if child:IsA("Tool") then
            hookTool(child)
        end
    end

    table.insert(characterConnections, char.ChildAdded:Connect(function(child)
        if child:IsA("Tool") then hookTool(child) end
    end))

    table.insert(characterConnections, char.ChildRemoved:Connect(function(child)
        if child == currentTool then
            currentTool = nil
        end
    end))

    watchDamageCounter()
end

player.CharacterAdded:Connect(onCharacterAdded)
if player.Character then onCharacterAdded(player.Character) end

-- ================= PUBLIC API CHO WINDUI =================
function SilentAimModule:SetAutoKen(state)
    AutoKen = state

    if state then
        startAutoKenLoop()
    end
end

function SilentAimModule:SetZSkillorM1(state)
    ZSkillorM1 = state
end

function SilentAimModule:Pause()
	SilentAimPlayersEnabled = false
    stopRenderLoop()
end

function SilentAimModule:Restore()
	SilentAimPlayersEnabled = UserWantsplayerAim
    if UserWantsplayerAim then
        startRenderLoop()
    end
end

function SilentAimModule:IsplayerAimEnabled()
    return SilentAimPlayersEnabled
end

function SilentAimModule:SetDistanceLimit(num)
	if typeof(num) == "number" then
		maxRange = num
	end
end

function SilentAimModule:SetSelectedPlayer(playerName)
	if not playerName or playerName == "" then
		Selectedplayer = nil
		return
	end

	local found = Players:FindFirstChild(playerName)
	if found then
		Selectedplayer = found
	end
end

function SilentAimModule:GetSelectedPlayer()
	return Selectedplayer and Selectedplayer.Name or "None"
end

function SilentAimModule:SetPrediction(state)
	PredictionEnabled = state
end

function SilentAimModule:SetPredictionAmount(num)
	if typeof(num) == "number" then
		PredictionAmount = num
	end
end

-- QUAN TRỌNG: Function chính để tích hợp với WindUI Toggle
function SilentAimModule:SetPlayerSilentAim(state)
    UserWantsplayerAim = state
    SilentAimPlayersEnabled = state

    if state then
        startRenderLoop()
        print("[Aimbot] Đã bật Auto Farm")
    else
        stopRenderLoop()
        print("[Aimbot] Đã tắt Auto Farm")
    end
end

return SilentAimModule
