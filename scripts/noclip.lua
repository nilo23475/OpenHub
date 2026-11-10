local NoclipScript = {}
_G.NoclipScript = NoclipScript

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

local running = false
local stepConn
local spawnConn
local saved = setmetatable({}, { __mode = "k" })

local function apply(char)
    if not char then return end
    for _, object in ipairs(char:GetDescendants()) do
        if object:IsA("BasePart") and object.CanCollide then
            saved[object] = true
            object.CanCollide = false
        end
    end
end

local function restore()
    for part in pairs(saved) do
        if part.Parent then
            pcall(function()
                part.CanCollide = true
            end)
        end
        saved[part] = nil
    end
end

function NoclipScript.Start()
    if running then return end
    running = true

    apply(player.Character)

    stepConn = RunService.Stepped:Connect(function()
        if running then
            apply(player.Character)
        end
    end)

    spawnConn = player.CharacterAdded:Connect(function(char)
        restore()
        task.wait(0.1)
        if running then
            apply(char)
        end
    end)
end

function NoclipScript.Stop()
    if not running then return end
    running = false

    if stepConn then
        stepConn:Disconnect()
        stepConn = nil
    end
    if spawnConn then
        spawnConn:Disconnect()
        spawnConn = nil
    end

    restore()
end
