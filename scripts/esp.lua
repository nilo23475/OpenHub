local ESPScript = {}
_G.ESPScript = ESPScript

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

local DEFAULTS = {
    Boxes = true,
    BoxFill = false,
    BoxColor = Color3.fromRGB(255, 255, 255),
    Name = true,
    Health = true,
    Distance = true,
    Tracer = false,
    Skeleton = false,
    Chams = false,
    ChamsColor = Color3.fromRGB(255, 60, 60),
    TeamCheck = true,
    VisibleCheck = false,
    IncludeNPCs = false,
    MaxDistance = 1000,
    TextSize = 14,
    TargetMode = "Everyone",
}

local running = false
local renderConn
local playerRemovingConn
local drawings = {}
local npcDrawings = {}
local lastNpcScan = 0

local function getCfg()
    local cfg = _G.ESPConfig
    if type(cfg) ~= "table" then
        cfg = {}
        _G.ESPConfig = cfg
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

local FONT = 2
if hasDrawing then
    local ok, fonts = pcall(function()
        return Drawing.Fonts
    end)
    if ok and fonts then
        FONT = fonts.Plex or fonts.UI or 2
    end
end

local function setProp(object, prop, value)
    if not object then return end
    pcall(function()
        object[prop] = value
    end)
end

local function newDrawing(kind)
    if not hasDrawing then return nil end
    local ok, object = pcall(function()
        return Drawing.new(kind)
    end)
    if ok then return object end
    return nil
end

local function createDrawings()
    local d = { highlight = nil, highlightChar = nil }
    if not hasDrawing then
        return d
    end

    d.box = newDrawing("Square")
    d.fill = newDrawing("Square")
    d.name = newDrawing("Text")
    d.dist = newDrawing("Text")
    d.healthBg = newDrawing("Square")
    d.healthFill = newDrawing("Square")
    d.tracer = newDrawing("Line")
    d.lines = {}
    for _ = 1, 24 do
        local line = newDrawing("Line")
        if line then
            table.insert(d.lines, line)
        end
    end

    setProp(d.box, "Thickness", 1)
    setProp(d.box, "Filled", false)
    setProp(d.box, "Transparency", 0)
    setProp(d.fill, "Thickness", 1)
    setProp(d.fill, "Filled", true)
    setProp(d.fill, "Transparency", 0.7)
    setProp(d.name, "Size", 14)
    setProp(d.name, "Center", true)
    setProp(d.name, "Outline", true)
    setProp(d.name, "OutlineColor", Color3.new(0, 0, 0))
    setProp(d.name, "Font", FONT)
    setProp(d.dist, "Size", 12)
    setProp(d.dist, "Center", true)
    setProp(d.dist, "Outline", true)
    setProp(d.dist, "OutlineColor", Color3.new(0, 0, 0))
    setProp(d.dist, "Font", FONT)
    setProp(d.healthBg, "Filled", true)
    setProp(d.healthBg, "Transparency", 0.4)
    setProp(d.healthBg, "Color", Color3.new(0, 0, 0))
    setProp(d.healthFill, "Filled", true)
    setProp(d.healthFill, "Transparency", 0)
    setProp(d.tracer, "Thickness", 1)
    setProp(d.tracer, "Transparency", 0.4)
    for _, line in ipairs(d.lines) do
        setProp(line, "Thickness", 1)
        setProp(line, "Transparency", 0.35)
    end

    return d
end

local function removeDrawing(object)
    if not object then return end
    local ok = pcall(function() object:Remove() end)
    if not ok then
        pcall(function() object:Destroy() end)
    end
end

local function destroyDrawings(d)
    if not d then return end
    for key, object in pairs(d) do
        if key == "highlightChar" then
            -- not a drawing
        elseif key == "lines" then
            for _, line in ipairs(object) do
                removeDrawing(line)
            end
        elseif key == "highlight" then
            if object then
                pcall(function() object:Destroy() end)
            end
        else
            removeDrawing(object)
        end
    end
end

local function hide(d)
    for _, key in ipairs({ "box", "fill", "name", "dist", "healthBg", "healthFill", "tracer" }) do
        setProp(d[key], "Visible", false)
    end
    if d.lines then
        for _, line in ipairs(d.lines) do
            setProp(line, "Visible", false)
        end
    end
    if d.highlight then
        pcall(function()
            d.highlight.Enabled = false
        end)
    end
end

local R15_PAIRS = {
    { "Head", "UpperTorso" },
    { "UpperTorso", "LowerTorso" },
    { "UpperTorso", "LeftUpperArm" },
    { "LeftUpperArm", "LeftLowerArm" },
    { "LeftLowerArm", "LeftHand" },
    { "UpperTorso", "RightUpperArm" },
    { "RightUpperArm", "RightLowerArm" },
    { "RightLowerArm", "RightHand" },
    { "LowerTorso", "LeftUpperLeg" },
    { "LeftUpperLeg", "LeftLowerLeg" },
    { "LeftLowerLeg", "LeftFoot" },
    { "LowerTorso", "RightUpperLeg" },
    { "RightUpperLeg", "RightLowerLeg" },
    { "RightLowerLeg", "RightFoot" },
}

local R6_PAIRS = {
    { "Head", "Torso" },
    { "Torso", "Left Arm" },
    { "Torso", "Right Arm" },
    { "Torso", "Left Leg" },
    { "Torso", "Right Leg" },
}

local function getSkeletonPairs(char)
    if char:FindFirstChild("UpperTorso") or char:FindFirstChild("LowerTorso") then
        return R15_PAIRS
    end
    return R6_PAIRS
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

local function getBox(char, cam)
    local ok, cf, size = pcall(function()
        return char:GetBoundingBox()
    end)
    if not ok or not cf or not size then return nil end

    local halfX, halfY, halfZ = size.X / 2, size.Y / 2, size.Z / 2
    local minX, minY = math.huge, math.huge
    local maxX, maxY = -math.huge, -math.huge
    local count = 0

    for _, x in ipairs({ -1, 1 }) do
        for _, y in ipairs({ -1, 1 }) do
            for _, z in ipairs({ -1, 1 }) do
                local world = (cf * CFrame.new(x * halfX, y * halfY, z * halfZ)).Position
                local screen, onScreen = cam:WorldToViewportPoint(world)
                if onScreen and screen.Z > 0 then
                    count = count + 1
                    minX = math.min(minX, screen.X)
                    maxX = math.max(maxX, screen.X)
                    minY = math.min(minY, screen.Y)
                    maxY = math.max(maxY, screen.Y)
                end
            end
        end
    end

    if count < 2 then return nil end
    return Vector2.new(minX, minY), Vector2.new(maxX, maxY)
end

local function updateCharacter(char, hum, hrp, head, d, label)
    local cfg = getCfg()
    local cam = workspace.CurrentCamera
    if not cam or not char or not hum or not hrp or hum.Health <= 0 then
        hide(d)
        return
    end

    local myChar = player.Character
    local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
    local distance = 0
    if myHRP then
        distance = (hrp.Position - myHRP.Position).Magnitude
    end
    if distance > (cfg.MaxDistance or 1000) then
        hide(d)
        return
    end

    if cfg.VisibleCheck and not isVisible(char, head or hrp) then
        hide(d)
        return
    end

    local topLeft, bottomRight = getBox(char, cam)
    if not topLeft then
        hide(d)
        return
    end

    local width = bottomRight.X - topLeft.X
    local height = bottomRight.Y - topLeft.Y
    if width < 1 or height < 1 then
        hide(d)
        return
    end

    local centerX = topLeft.X + width / 2
    local textSize = cfg.TextSize or 14
    local color = cfg.BoxColor or Color3.new(1, 1, 1)

    setProp(d.box, "Visible", cfg.Boxes == true)
    if cfg.Boxes then
        setProp(d.box, "Position", topLeft)
        setProp(d.box, "Size", Vector2.new(width, height))
        setProp(d.box, "Color", color)
    end

    setProp(d.fill, "Visible", cfg.Boxes == true and cfg.BoxFill == true)
    if cfg.Boxes and cfg.BoxFill then
        setProp(d.fill, "Position", topLeft)
        setProp(d.fill, "Size", Vector2.new(width, height))
        setProp(d.fill, "Color", color)
    end

    setProp(d.name, "Visible", cfg.Name == true)
    if cfg.Name then
        setProp(d.name, "Text", label)
        setProp(d.name, "Size", textSize)
        setProp(d.name, "Position", Vector2.new(centerX, topLeft.Y - textSize - 2))
        setProp(d.name, "Color", color)
    end

    setProp(d.dist, "Visible", cfg.Distance == true)
    if cfg.Distance then
        setProp(d.dist, "Text", tostring(math.floor(distance + 0.5)) .. " studs")
        setProp(d.dist, "Size", math.max(10, textSize - 2))
        setProp(d.dist, "Position", Vector2.new(centerX, bottomRight.Y + 2))
        setProp(d.dist, "Color", color)
    end

    local showHealth = cfg.Health == true
    setProp(d.healthBg, "Visible", showHealth)
    setProp(d.healthFill, "Visible", showHealth)
    if showHealth then
        local fraction = 0
        if hum.MaxHealth > 0 then
            fraction = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
        end
        local barX = bottomRight.X + 4
        setProp(d.healthBg, "Position", Vector2.new(barX, topLeft.Y))
        setProp(d.healthBg, "Size", Vector2.new(3, height))
        setProp(d.healthFill, "Position", Vector2.new(barX, topLeft.Y + height * (1 - fraction)))
        setProp(d.healthFill, "Size", Vector2.new(3, height * fraction))
        setProp(d.healthFill, "Color", Color3.fromHSV(fraction * 0.33, 1, 1))
    end

    setProp(d.tracer, "Visible", cfg.Tracer == true)
    if cfg.Tracer then
        local viewport = cam.ViewportSize
        setProp(d.tracer, "From", Vector2.new(viewport.X / 2, viewport.Y))
        setProp(d.tracer, "To", Vector2.new(centerX, bottomRight.Y))
        setProp(d.tracer, "Color", color)
    end

    if d.lines then
        if not cfg.Skeleton then
            for _, line in ipairs(d.lines) do
                setProp(line, "Visible", false)
            end
        else
            local pairsList = getSkeletonPairs(char)
            local index = 1
            for _, pair in ipairs(pairsList) do
                local a = char:FindFirstChild(pair[1])
                local b = char:FindFirstChild(pair[2])
                if a and b and index <= #d.lines then
                    local screenA, onA = cam:WorldToViewportPoint(a.Position)
                    local screenB, onB = cam:WorldToViewportPoint(b.Position)
                    local line = d.lines[index]
                    if onA and onB and screenA.Z > 0 and screenB.Z > 0 then
                        setProp(line, "Visible", true)
                        setProp(line, "From", Vector2.new(screenA.X, screenA.Y))
                        setProp(line, "To", Vector2.new(screenB.X, screenB.Y))
                        setProp(line, "Color", color)
                    else
                        setProp(line, "Visible", false)
                    end
                    index = index + 1
                end
            end
            for i = index, #d.lines do
                setProp(d.lines[i], "Visible", false)
            end
        end
    end

    if cfg.Chams then
        if d.highlightChar ~= char then
            if d.highlight then
                pcall(function() d.highlight:Destroy() end)
            end
            d.highlight = nil
            d.highlightChar = nil

            local ok, highlight = pcall(function()
                local h = Instance.new("Highlight")
                h.FillTransparency = 0.5
                h.OutlineTransparency = 0
                pcall(function()
                    h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                end)
                return h
            end)
            if ok and highlight then
                highlight.Parent = char
                d.highlight = highlight
                d.highlightChar = char
            end
        end
        if d.highlight then
            local chamsColor = cfg.ChamsColor or Color3.fromRGB(255, 60, 60)
            local ok = pcall(function()
                d.highlight.Enabled = true
                d.highlight.FillColor = chamsColor
                d.highlight.OutlineColor = chamsColor
            end)
            if not ok then
                pcall(function() d.highlight:Destroy() end)
                d.highlight = nil
                d.highlightChar = nil
            end
        end
    elseif d.highlight then
        pcall(function() d.highlight:Destroy() end)
        d.highlight = nil
        d.highlightChar = nil
    end
end

local function updatePlayer(p, d)
    local cfg = getCfg()
    if p == player then
        hide(d)
        return
    end
    if cfg.TargetMode == "Selected" and _G.OpenHubTarget ~= p then
        hide(d)
        return
    end
    if cfg.TeamCheck and p.Team and player.Team and p.Team == player.Team then
        hide(d)
        return
    end

    local char = p.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local head = char and char:FindFirstChild("Head")
    local label = p.DisplayName
    if label == nil or label == "" then
        label = p.Name
    end
    updateCharacter(char, hum, hrp, head, d, label)
end

local function updateNPC(model, d)
    local cfg = getCfg()
    if cfg.TargetMode == "Selected" then
        hide(d)
        return
    end
    local hum = model:FindFirstChildOfClass("Humanoid")
    local hrp = model:FindFirstChild("HumanoidRootPart")
    local head = model:FindFirstChild("Head")
    updateCharacter(model, hum, hrp, head, d, model.Name)
end

local function scanNPCs()
    local now = os.clock()
    if now - lastNpcScan < 2 then return end
    lastNpcScan = now

    local found = {}
    for _, object in ipairs(workspace:GetDescendants()) do
        if object:IsA("Humanoid") then
            local model = object.Parent
            if model and model:IsA("Model") and not Players:GetPlayerFromCharacter(model) then
                found[model] = true
            end
        end
    end

    local stale = {}
    for model in pairs(npcDrawings) do
        if not found[model] then
            table.insert(stale, model)
        end
    end
    for _, model in ipairs(stale) do
        destroyDrawings(npcDrawings[model])
        npcDrawings[model] = nil
    end

    for model in pairs(found) do
        if not npcDrawings[model] then
            npcDrawings[model] = createDrawings()
        end
    end
end

function ESPScript.Start()
    if running then return end
    running = true
    getCfg()

    renderConn = RunService.RenderStepped:Connect(function()
        if not running then return end
        local cfg = getCfg()

        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= player then
                local d = drawings[p]
                if not d then
                    d = createDrawings()
                    drawings[p] = d
                end
                local ok = pcall(updatePlayer, p, d)
                if not ok then
                    pcall(hide, d)
                end
            end
        end

        local stale = {}
        for p in pairs(drawings) do
            if not p.Parent or p == player then
                table.insert(stale, p)
            end
        end
        for _, p in ipairs(stale) do
            destroyDrawings(drawings[p])
            drawings[p] = nil
        end

        if cfg.IncludeNPCs then
            scanNPCs()
            local npcStale = {}
            for model in pairs(npcDrawings) do
                if not model.Parent then
                    table.insert(npcStale, model)
                else
                    pcall(updateNPC, model, npcDrawings[model])
                end
            end
            for _, model in ipairs(npcStale) do
                destroyDrawings(npcDrawings[model])
                npcDrawings[model] = nil
            end
        else
            local npcStale = {}
            for model in pairs(npcDrawings) do
                table.insert(npcStale, model)
            end
            for _, model in ipairs(npcStale) do
                destroyDrawings(npcDrawings[model])
                npcDrawings[model] = nil
            end
        end
    end)

    playerRemovingConn = Players.PlayerRemoving:Connect(function(p)
        local d = drawings[p]
        if d then
            destroyDrawings(d)
            drawings[p] = nil
        end
    end)
end

function ESPScript.Stop()
    if not running then return end
    running = false

    if renderConn then
        renderConn:Disconnect()
        renderConn = nil
    end
    if playerRemovingConn then
        playerRemovingConn:Disconnect()
        playerRemovingConn = nil
    end

    for _, d in pairs(drawings) do
        destroyDrawings(d)
    end
    drawings = {}

    for _, d in pairs(npcDrawings) do
        destroyDrawings(d)
    end
    npcDrawings = {}
end
