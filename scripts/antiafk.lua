local AntiAFKScript = {}
_G.AntiAFKScript = AntiAFKScript

local Players = game:GetService("Players")
local VirtualUser = game:GetService("VirtualUser")
local player = Players.LocalPlayer

local running = false
local idleConn
local warned = false
local generation = 0

local function poke()
    local ok = pcall(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new(0, 0))
    end)
    if not ok and not warned then
        warned = true
        warn("[OpenHub] Anti-AFK: VirtualUser is restricted by this executor.")
    end
end

function AntiAFKScript.Start()
    if running then return end
    running = true
    warned = false
    generation = generation + 1
    local current = generation

    idleConn = player.Idled:Connect(poke)

    task.spawn(function()
        while running and generation == current do
            task.wait(60)
            if running and generation == current then
                poke()
            end
        end
    end)
end

function AntiAFKScript.Stop()
    if not running then return end
    running = false
    generation = generation + 1

    if idleConn then
        idleConn:Disconnect()
        idleConn = nil
    end
end
