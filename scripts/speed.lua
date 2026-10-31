local SpeedScript = {}
_G.SpeedScript = SpeedScript

local RunService = game:GetService("RunService")

local running = false
local connection
local savedSpeed = 16

function SpeedScript.Start()
    if running then return end
    running = true

    local player = game.Players.LocalPlayer
    local char = player.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then savedSpeed = hum.WalkSpeed end

    connection = RunService.Heartbeat:Connect(function()
        local c = player.Character
        local h = c and c:FindFirstChildOfClass("Humanoid")
        if h then
            h.WalkSpeed = _G.SpeedValue or 50
        end
    end)
end

function SpeedScript.Stop()
    if not running then return end
    running = false
    if connection then connection:Disconnect(); connection = nil end

    local char = game.Players.LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.WalkSpeed = savedSpeed
    end
end