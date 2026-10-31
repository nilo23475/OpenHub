local FlyScript = {}
_G.FlyScript = FlyScript

local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local running = false
local connection
local bodyVel

function FlyScript.Start()
    if running then return end
    running = true

    local player = game.Players.LocalPlayer
    local char = player.Character or player.CharacterAdded:Wait()
    local hrp = char:WaitForChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.PlatformStand = true
        hum:ChangeState(Enum.HumanoidStateType.Physics)
    end

    bodyVel = Instance.new("BodyVelocity")
    bodyVel.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    bodyVel.Velocity = Vector3.zero
    bodyVel.Parent = hrp

    connection = RunService.Heartbeat:Connect(function()
        if not running then return end
        local c = player.Character
        local r = c and c:FindFirstChild("HumanoidRootPart")
        if not r then return end
        if bodyVel.Parent ~= r then bodyVel.Parent = r end

        local cam = workspace.CurrentCamera
        if not cam then return end

        local look = cam.CFrame.LookVector
        local right = cam.CFrame.RightVector
        local flatLook = Vector3.new(look.X, 0, look.Z)
        local flatRight = Vector3.new(right.X, 0, right.Z)
        if flatLook.Magnitude > 0 then flatLook = flatLook.Unit end
        if flatRight.Magnitude > 0 then flatRight = flatRight.Unit end

        local dir = Vector3.zero
        if UIS:IsKeyDown(Enum.KeyCode.W) then dir += flatLook end
        if UIS:IsKeyDown(Enum.KeyCode.S) then dir -= flatLook end
        if UIS:IsKeyDown(Enum.KeyCode.A) then dir -= flatRight end
        if UIS:IsKeyDown(Enum.KeyCode.D) then dir += flatRight end
        if dir.Magnitude > 0 then dir = dir.Unit end

        local v = 0
        if UIS:IsKeyDown(Enum.KeyCode.Space)       then v += 1 end
        if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then v -= 1 end

        local speed = _G.FlySpeed or 50
        bodyVel.Velocity = dir * speed + Vector3.new(0, v * speed, 0)
    end)
end

function FlyScript.Stop()
    if not running then return end
    running = false
    if connection then connection:Disconnect(); connection = nil end
    if bodyVel then bodyVel:Destroy(); bodyVel = nil end

    local char = game.Players.LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then hum.PlatformStand = false end
end