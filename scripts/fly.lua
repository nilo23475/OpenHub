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

    bodyVel = Instance.new("BodyVelocity")
    bodyVel.MaxForce = Vector3.new(1e5, 1e5, 1e5)
    bodyVel.Velocity = Vector3.zero
    bodyVel.Parent = hrp

    connection = RunService.Heartbeat:Connect(function()
        if not running then return end
        local c = player.Character
        local r = c and c:FindFirstChild("HumanoidRootPart")
        if not r then return end

        local cam = workspace.CurrentCamera
        local dir = Vector3.zero

        if UIS:IsKeyDown(Enum.KeyCode.W) then dir += cam.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.S) then dir -= cam.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.A) then dir -= cam.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.D) then dir += cam.CFrame.RightVector end

        local up = Vector3.zero
        if UIS:IsKeyDown(Enum.KeyCode.Space)    then up = Vector3.new(0,  1, 0) end
        if UIS:IsKeyDown(Enum.KeyCode.LeftCtrl) then up = Vector3.new(0, -1, 0) end

        bodyVel.Velocity = dir.Unit * 50 + up * 50
    end)
end

function FlyScript.Stop()
    if not running then return end
    running = false
    if connection then connection:Disconnect(); connection = nil end
    if bodyVel then bodyVel:Destroy(); bodyVel = nil end
end