local SpeedScript = {}
_G.SpeedScript = SpeedScript

local running = false
local savedSpeed = 16

function SpeedScript.Start()
    if running then return end
    local char = game.Players.LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    savedSpeed = hum.WalkSpeed
    hum.WalkSpeed = 50
    running = true
end

function SpeedScript.Stop()
    if not running then return end
    running = false
    local char = game.Players.LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.WalkSpeed = savedSpeed
    end
end