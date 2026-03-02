do
	ply = game.Players;
	plr = ply.LocalPlayer;
end;

getInfinity_Ability = function(I, e)
	if not plr.Character then return end
	if I == "Soru" and e then
		for i, k in next, getgc() do
			if plr.Character.Soru then
				if typeof(k) == "function" and (getfenv(k)).script == plr.Character.Soru then
					for j, upval in next, getupvalues(k) do
						if typeof(upval) == "table" then
							repeat
								wait(.1);
								upval.LastUse = 0;
							until not e or plr.Character.Humanoid.Health <= 0;
						end;
					end;
				end;
			end;
		end;
	end;
end;

local GUI = Instance.new("ScreenGui")
local Button = Instance.new("TextButton")

GUI.Name = "InfSoruGUI"
GUI.Parent = plr.PlayerGui
GUI.ResetOnSpawn = false

Button.Size = UDim2.new(0, 120, 0, 40)
Button.Position = UDim2.new(0, 20, 0, 50)
Button.Text = "INF SORU: OFF"
Button.TextColor3 = Color3.new(1, 0, 0)
Button.BackgroundColor3 = Color3.new(0, 0, 0)
Button.BackgroundTransparency = 0.3
Button.Parent = GUI
Button.Draggable = true

local enabled = false

Button.MouseButton1Click:Connect(function()
	enabled = not enabled
	if enabled then
		Button.Text = "INF SORU: ON"
		Button.TextColor3 = Color3.new(0, 1, 0)
		getInfinity_Ability("Soru", true)
	else
		Button.Text = "INF SORU: OFF"
		Button.TextColor3 = Color3.new(1, 0, 0)
		getInfinity_Ability("Soru", false)
	end
end)
