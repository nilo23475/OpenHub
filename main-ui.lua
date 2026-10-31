local BASE = "https://raw.githubusercontent.com/nilo23475/OpenHub/main"

local player = game.Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local UIS = game:GetService("UserInputService")

local gui = Instance.new("ScreenGui")
gui.Name = "OpenHub"
gui.ResetOnSpawn = false
gui.Parent = playerGui

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 320, 0, 460)
frame.Position = UDim2.new(0.5, -160, 0.5, -230)
frame.BackgroundColor3 = Color3.fromRGB(28, 28, 32)
frame.BorderSizePixel = 0
frame.Parent = gui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -40, 0, 36)
title.BackgroundColor3 = Color3.fromRGB(20, 20, 24)
title.BorderSizePixel = 0
title.Text = "  OpenHub"
title.TextColor3 = Color3.new(1, 1, 1)
title.TextXAlignment = Enum.TextXAlignment.Left
title.Font = Enum.Font.GothamBold
title.TextSize = 15
title.Parent = frame

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 30, 0, 30)
closeBtn.Position = UDim2.new(1, -34, 0, 3)
closeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
closeBtn.BorderSizePixel = 0
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.new(1, 1, 1)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.Parent = frame
closeBtn.MouseButton1Click:Connect(function() gui:Destroy() end)

local list = Instance.new("ScrollingFrame")
list.Size = UDim2.new(1, -20, 1, -50)
list.Position = UDim2.new(0, 10, 0, 42)
list.BackgroundTransparency = 1
list.BorderSizePixel = 0
list.ScrollBarThickness = 4
list.CanvasSize = UDim2.new(0, 0, 0, 0)
list.AutomaticCanvasSize = Enum.AutomaticSize.Y
list.Parent = frame

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 6)
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Parent = list

local dragging, dragStart, startPos
title.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = frame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)
UIS.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local d = input.Position - dragStart
        frame.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + d.X,
            startPos.Y.Scale, startPos.Y.Offset + d.Y
        )
    end
end)

local function addCategory(name)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 26)
    label.BackgroundColor3 = Color3.fromRGB(38, 38, 44)
    label.BorderSizePixel = 0
    label.Text = "   " .. name
    label.TextColor3 = Color3.fromRGB(120, 180, 255)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Font = Enum.Font.GothamBold
    label.TextSize = 13
    label.Parent = list
end

local function addToggle(name, file, globalName, configKey, defaultValue)
    local hasConfig = configKey ~= nil
    if hasConfig then
        _G[configKey] = _G[configKey] or defaultValue or 50
    end

    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 36)
    row.BackgroundColor3 = Color3.fromRGB(60, 60, 66)
    row.BorderSizePixel = 0
    row.Active = false
    row.ZIndex = 1
    row.Parent = list

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, hasConfig and -78 or 0, 1, 0)
    btn.Position = UDim2.new(0, 0, 0, 0)
    btn.BackgroundColor3 = Color3.fromRGB(60, 60, 66)
    btn.BorderSizePixel = 0
    btn.Text = name .. "  [OFF]"
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 13
    btn.Active = true
    btn.ZIndex = 2
    btn.Parent = row

    if hasConfig then
        local box = Instance.new("TextBox")
        box.Size = UDim2.new(0, 72, 1, 0)
        box.Position = UDim2.new(1, -74, 0, 0)
        box.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
        box.BorderSizePixel = 0
        box.Text = tostring(_G[configKey])
        box.TextColor3 = Color3.new(1, 1, 1)
        box.Font = Enum.Font.Gotham
        box.TextSize = 13
        box.ClearTextOnFocus = false
        box.Active = true
        box.ZIndex = 2
        box.Parent = row
        box.FocusLost:Connect(function()
            local n = tonumber(box.Text)
            if n then _G[configKey] = n end
            box.Text = tostring(_G[configKey])
        end)
    end

    local loaded, enabled = false, false

    btn.MouseButton1Click:Connect(function()
        enabled = not enabled

        if enabled then
            if not loaded then
                local ok, err = pcall(function()
                    loadstring(game:HttpGet(BASE .. "/scripts/" .. file))()
                end)
                if not ok then
                    warn("[OpenHub] " .. file .. ": " .. tostring(err))
                    enabled = false
                    btn.Text = name .. "  [OFF]"
                    btn.BackgroundColor3 = Color3.fromRGB(60, 60, 66)
                    return
                end
                loaded = true
            end
            local api = _G[globalName]
            if api and api.Start then
                local ok, err = pcall(api.Start)
                if not ok then
                    warn("[OpenHub] " .. globalName .. ".Start: " .. tostring(err))
                    enabled = false
                    btn.Text = name .. "  [OFF]"
                    btn.BackgroundColor3 = Color3.fromRGB(60, 60, 66)
                    return
                end
            end
            btn.Text = name .. "  [ON]"
            btn.BackgroundColor3 = Color3.fromRGB(30, 130, 70)
        else
            local api = _G[globalName]
            if api and api.Stop then
                local ok, err = pcall(api.Stop)
                if not ok then
                    warn("[OpenHub] " .. globalName .. ".Stop: " .. tostring(err))
                end
            end
            btn.Text = name .. "  [OFF]"
            btn.BackgroundColor3 = Color3.fromRGB(60, 60, 66)
        end
    end)
end

addCategory("Universal")
addToggle("Fullbright",        "fullbright.lua",   "FullbrightScript")
addToggle("Teleport to Mouse", "tpmouse.lua",      "TPMouseScript")
addToggle("Fly",               "fly.lua",          "FlyScript",         "FlySpeed",   50)
addToggle("Speed",             "speed.lua",        "SpeedScript",       "SpeedValue", 50)
addToggle("Infinite Jump",     "infinitejump.lua", "InfiniteJumpScript")