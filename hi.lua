local gui = Instance.new("ScreenGui", game.CoreGui)
local lbl = Instance.new("TextLabel", gui)
lbl.Size = UDim2.new(0, 400, 0, 200)
lbl.Position = UDim2.new(0, 10, 0.7, 0)
lbl.BackgroundColor3 = Color3.fromRGB(20,20,20)
lbl.TextColor3 = Color3.new(1,1,1)
lbl.TextWrapped = true
lbl.TextXAlignment = Left
lbl.TextYAlignment = Top
lbl.Text = "LOG:\n"

local function log(t)
    lbl.Text ..= tostring(t).."\n"
end

log("Script started")
log("JobId: "..game.JobId)
