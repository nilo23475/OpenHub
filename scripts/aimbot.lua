local AimbotScript = {}
_G.AimbotScript = AimbotScript

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local player = Players.LocalPlayer

local DEFAULTS = {
    AimKey = Enum.UserInputType.MouseButton2,
    AimMode = "Hold",
    FOV = 120,
    ShowFOV = true,
    FOVColor = Color3.fromRGB(255, 255, 255),
    Smoothing = 25,
    TargetPart = "Head",
    TargetMode = "Everyone",
    TeamCheck = true,
    WallCheck = true,
    IgnoreForcefield = true,
    IgnoreInvisible = true,
    MaxDistance = 1000,
    Prediction = 0,
    AutoShoot = false,
    AutoShootDelay = 0.1,
}

local running = false
local connections = {}
local circle
local held = false
local toggled = false
local pressLatch = false
local lastShot = 0
local warnedAutoShoot = false
local warnedUpdate = false

local function getCfg()
    local cfg = _G.AimbotConfig
    if type(cfg) ~= "table" then
        cfg = {}
        _G.AimbotConfig = cfg
    end
    for key, value in pairs(DEFAULTS) do
        if cfg[key] == nil then
            cfg[key] = value
        end
    end
    return cfg
end

local hasDrawing = false
do
    local ok, result = pcall(function()
        return Drawing.new ~= nil
    end)
    hasDrawing = ok and result == true
end

local function setProp(object, prop, value)
    if not object then return end
    pcall(function()
        object[prop] = value
    end)
end

local function ensureCircle()
    if not hasDrawing then return nil end
    if circle then return circle end
    local ok, created = pcall(function()
        return Drawing.new("Circle")
    end)
    if not ok or not created then return nil end
    setProp(created, "Thickness", 1)
    setProp(created, "NumSides", 64)
    setProp(created, "Sides", 64)
    setProp(created, "Transparency", 0.5)
    setProp(created, "Filled", false)
    circle = created
    return circle
end

local function keyMatches(input, key)
    if typeof(key) ~= "EnumItem" then return false end
    if key.EnumType == Enum.KeyCode then
        return input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == key
    end
    return input.UserInputType == key
end

local function onInputBegan(input, processed)
    -- Keyboard input can be swallowed by chat, but mouse buttons still need to work.
    if processed and input.UserInputType == Enum.UserInputType.Keyboard then return end
    local cfg = getCfg()
    if not keyMatches(input, cfg.AimKey) then return end
    if cfg.AimMode == "Hold" then
        held = true
    elseif not pressLatch then
        toggled = not toggled
        pressLatch = true
    end
end

local function onInputEnded(input)
    local cfg = getCfg()
    if not keyMatches(input, cfg.AimKey) then return end
    if cfg.AimMode == "Hold" then
        held = false
    end
    pressLatch = false
end

local rayParams = RaycastParams.new()
pcall(function()
    rayParams.FilterType = Enum.RaycastFilterType.Exclude
end)

local function isVisible(char, part)
    if not part then return false end
    local cam = workspace.CurrentCamera
    if not cam then return false end
    rayParams.FilterDescendantsInstances = { player.Character }
    local origin = cam.CFrame.Position
    local result = workspace:Raycast(origin, part.Position - origin, rayParams)
    return result ~= nil
        and result.Instance ~= nil
        and result.Instance:IsDescendantOf(char)
end

local function getParts(char)
    local parts = {}
    local head = char:FindFirstChild("Head")
    if head then table.insert(parts, head) end
    local torso = char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso")
    if torso then table.insert(parts, torso) end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if hrp then table.insert(parts, hrp) end
    return parts
end

local function candidate(p, cfg, myHRP)
    local char = p.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not char or not hum or not hrp or hum.Health <= 0 then
        return false
    end

    if cfg.TargetMode == "Selected" and _G.OpenHubTarget ~= p then
        return false
    end

    if cfg.TeamCheck and p.Team and player.Team and p.Team == player.Team then
        return false
    end

    if myHRP and (hrp.Position - myHRP.Position).Magnitude > (cfg.MaxDistance or 1000) then
        return false
    end

    if cfg.IgnoreForcefield and char:FindFirstChildOfClass("ForceField") then
        return false
    end

    if cfg.IgnoreInvisible then
        local head = char:FindFirstChild("Head")
        if hrp.Transparency >= 0.95 or (head and head.Transparency >= 0.95) then
            return false
        end
    end

    return true, char, hum, hrp
end

local function findTarget(cam, center, cfg)
    local myChar = player.Character
    local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
    local best = nil
    local bestDistance = math.huge

    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= player then
            local ok, char, hum, hrp = candidate(p, cfg, myHRP)
            if ok then
                local chosen
                local chosenDistance

                if cfg.TargetPart == "Head" then
                    chosen = char:FindFirstChild("Head") or hrp
                elseif cfg.TargetPart == "Torso" then
                    chosen = char:FindFirstChild("UpperTorso")
                        or char:FindFirstChild("Torso")
                        or hrp
                else
                    for _, part in ipairs(getParts(char)) do
                        local screen, onScreen = cam:WorldToViewportPoint(part.Position)
                        if onScreen and screen.Z > 0 then
                            local distance = (Vector2.new(screen.X, screen.Y) - center).Magnitude
                            if not chosenDistance or distance < chosenDistance then
                                chosen = part
                                chosenDistance = distance
                            end
                        end
                    end
                end

                if chosen then
                    local screen, onScreen = cam:WorldToViewportPoint(chosen.Position)
                    if onScreen and screen.Z > 0 then
                        local distance = (Vector2.new(screen.X, screen.Y) - center).Magnitude
                        if distance <= (cfg.FOV or 120) and distance < bestDistance then
                            if not cfg.WallCheck or isVisible(char, chosen) then
                                best = { player = p, char = char, part = chosen }
                                bestDistance = distance
                            end
                        end
                    end
                end
            end
        end
    end

    return best
end

local function update(deltaTime)
    if not running then return end
    local cfg = getCfg()
    local cam = workspace.CurrentCamera
    if not cam then return end

    local center = Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y / 2)
    local fovCircle = ensureCircle()
    if fovCircle then
        setProp(fovCircle, "Visible", cfg.ShowFOV == true)
        if cfg.ShowFOV then
            setProp(fovCircle, "Position", center)
            setProp(fovCircle, "Radius", cfg.FOV or 120)
            setProp(fovCircle, "Color", cfg.FOVColor or Color3.new(1, 1, 1))
        end
    end

    local active = (cfg.AimMode == "Hold" and held) or (cfg.AimMode == "Toggle" and toggled)
    if not active then return end

    local target = findTarget(cam, center, cfg)
    if not target then return end

    local part = target.part
    local position = part.Position

    if (cfg.Prediction or 0) > 0 then
        local velocity = part.AssemblyLinearVelocity
        if velocity == nil then velocity = part.Velocity end
        if velocity then
            position = position + velocity * (cfg.Prediction / 100)
        end
    end

    local goal = CFrame.lookAt(cam.CFrame.Position, position)
    local alpha = 1
    if (cfg.Smoothing or 0) > 0 then
        local base = math.clamp(1 - (cfg.Smoothing / 100), 0.01, 1)
        alpha = 1 - (1 - base) ^ (deltaTime * 60)
    end
    cam.CFrame = cam.CFrame:Lerp(goal, alpha)

    if cfg.AutoShoot and os.clock() - lastShot >= (cfg.AutoShootDelay or 0.1) then
        lastShot = os.clock()
        local click = rawget(_G, "mouse1click")
        if type(click) == "function" then
            pcall(click)
        elseif not warnedAutoShoot then
            warnedAutoShoot = true
            warn("[OpenHub] Aimbot: mouse1click is not available in this executor.")
        end
    end
end

function AimbotScript.Start()
    if running then return end
    running = true
    getCfg()
    held = false
    toggled = false
    pressLatch = false
    lastShot = 0
    warnedAutoShoot = false
    warnedUpdate = false
    ensureCircle()

    table.insert(connections, UIS.InputBegan:Connect(onInputBegan))
    table.insert(connections, UIS.InputEnded:Connect(onInputEnded))
    table.insert(connections, RunService.RenderStepped:Connect(function(deltaTime)
        local ok, err = pcall(update, deltaTime)
        if not ok and not warnedUpdate then
            warnedUpdate = true
            warn("[OpenHub] Aimbot: " .. tostring(err))
        end
    end))
end

function AimbotScript.Stop()
    if not running then return end
    running = false

    for _, conn in ipairs(connections) do
        pcall(function() conn:Disconnect() end)
    end
    connections = {}

    if circle then
        local ok = pcall(function() circle:Remove() end)
        if not ok then
            pcall(function() circle:Destroy() end)
        end
        circle = nil
    end

    held = false
    toggled = false
    pressLatch = false
end
