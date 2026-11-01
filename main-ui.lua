local BASE = "https://raw.githubusercontent.com/nilo23475/OpenHub/main"

local player = game.Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local UIS = game:GetService("UserInputService")

local gui = Instance.new("ScreenGui")
gui.Name = "OpenHub"
gui.ResetOnSpawn = false
gui.Parent = playerGui

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 440, 0, 480)
frame.Position = UDim2.new(0.5, -220, 0.5, -240)
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

local sidebar = Instance.new("Frame")
sidebar.Size = UDim2.new(0, 100, 1, -36)
sidebar.Position = UDim2.new(0, 0, 0, 36)
sidebar.BackgroundColor3 = Color3.fromRGB(22, 22, 26)
sidebar.BorderSizePixel = 0
sidebar.Parent = frame

local sidebarPad = Instance.new("UIPadding")
sidebarPad.PaddingTop = UDim.new(0, 6)
sidebarPad.PaddingLeft = UDim.new(0, 6)
sidebarPad.PaddingRight = UDim.new(0, 6)
sidebarPad.Parent = sidebar

local sidebarLayout = Instance.new("UIListLayout")
sidebarLayout.Padding = UDim.new(0, 4)
sidebarLayout.SortOrder = Enum.SortOrder.LayoutOrder
sidebarLayout.Parent = sidebar

local content = Instance.new("Frame")
content.Size = UDim2.new(1, -100, 1, -36)
content.Position = UDim2.new(0, 100, 0, 36)
content.BackgroundTransparency = 1
content.Parent = frame

local list = Instance.new("ScrollingFrame")
list.Size = UDim2.new(1, -20, 1, -10)
list.Position = UDim2.new(0, 10, 0, 5)
list.BackgroundTransparency = 1
list.BorderSizePixel = 0
list.ScrollBarThickness = 4
list.CanvasSize = UDim2.new(0, 0, 0, 0)
list.AutomaticCanvasSize = Enum.AutomaticSize.Y
list.Parent = content

local listLayout = Instance.new("UIListLayout")
listLayout.Padding = UDim.new(0, 6)
listLayout.SortOrder = Enum.SortOrder.LayoutOrder
listLayout.Parent = list

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

local function clearList()
    for _, child in ipairs(list:GetChildren()) do
        if not child:IsA("UIListLayout") then
            child:Destroy()
        end
    end
end

local Hub = {}
Hub.sidebarButtons = {}
Hub.toggleState = {}

local function addToggle(item)
    local key = (item.global or item.name) .. "|" .. (item.file or "")
    local state = Hub.toggleState[key]
    if not state then
        state = { loaded = false, enabled = false }
        Hub.toggleState[key] = state
    end

    local hasConfig = item.config ~= nil
    if hasConfig then
        _G[item.config] = _G[item.config] or item.default or 50
    end

    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 36)
    row.BackgroundTransparency = 1
    row.Parent = list

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, hasConfig and -78 or 0, 1, 0)
    btn.BackgroundColor3 = state.enabled and Color3.fromRGB(30, 130, 70) or Color3.fromRGB(60, 60, 66)
    btn.BorderSizePixel = 0
    btn.Text = item.name .. (state.enabled and "  [ON]" or "  [OFF]")
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 13
    btn.Active = true
    btn.Parent = row

    if hasConfig then
        local box = Instance.new("TextBox")
        box.Size = UDim2.new(0, 72, 1, 0)
        box.Position = UDim2.new(1, -74, 0, 0)
        box.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
        box.BorderSizePixel = 0
        box.Text = tostring(_G[item.config])
        box.TextColor3 = Color3.new(1, 1, 1)
        box.Font = Enum.Font.Gotham
        box.TextSize = 13
        box.ClearTextOnFocus = false
        box.Parent = row
        box.FocusLost:Connect(function()
            local n = tonumber(box.Text)
            if n then _G[item.config] = n end
            box.Text = tostring(_G[item.config])
        end)
    end

    btn.MouseButton1Click:Connect(function()
        state.enabled = not state.enabled
        if state.enabled then
            if not state.loaded then
                local ok, err = pcall(function()
                    loadstring(game:HttpGet(BASE .. "/scripts/" .. item.file))()
                end)
                if not ok then
                    warn("[OpenHub] " .. item.file .. ": " .. tostring(err))
                    state.enabled = false
                    btn.Text = item.name .. "  [OFF]"
                    btn.BackgroundColor3 = Color3.fromRGB(60, 60, 66)
                    return
                end
                state.loaded = true
            end
            local api = _G[item.global]
            if api and api.Start then
                local ok, err = pcall(api.Start)
                if not ok then
                    warn("[OpenHub] " .. item.global .. ".Start: " .. tostring(err))
                    state.enabled = false
                    btn.Text = item.name .. "  [OFF]"
                    btn.BackgroundColor3 = Color3.fromRGB(60, 60, 66)
                    return
                end
            end
            btn.Text = item.name .. "  [ON]"
            btn.BackgroundColor3 = Color3.fromRGB(30, 130, 70)
        else
            local api = _G[item.global]
            if api and api.Stop then
                local ok, err = pcall(api.Stop)
                if not ok then
                    warn("[OpenHub] " .. item.global .. ".Stop: " .. tostring(err))
                end
            end
            btn.Text = item.name .. "  [OFF]"
            btn.BackgroundColor3 = Color3.fromRGB(60, 60, 66)
        end
    end)
end

local function addButton(item)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 36)
    btn.BackgroundColor3 = Color3.fromRGB(60, 60, 66)
    btn.BorderSizePixel = 0
    btn.Text = item.name
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 13
    btn.Active = true
    btn.Parent = list
    btn.MouseButton1Click:Connect(function()
        local ok, err = pcall(function()
            loadstring(game:HttpGet(BASE .. "/scripts/" .. item.file))()
        end)
        if not ok then
            warn("[OpenHub] " .. item.file .. ": " .. tostring(err))
        end
    end)
end

local function addFolder(item, onOpen)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 36)
    btn.BackgroundColor3 = Color3.fromRGB(50, 55, 75)
    btn.BorderSizePixel = 0
    btn.Text = item.name .. "  >"
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 13
    btn.Active = true
    btn.Parent = list
    btn.MouseButton1Click:Connect(onOpen)
end

Hub.renderView = function(items, backCallback)
    clearList()
    if backCallback then
        local back = Instance.new("TextButton")
        back.Size = UDim2.new(1, 0, 0, 30)
        back.BackgroundColor3 = Color3.fromRGB(40, 40, 46)
        back.BorderSizePixel = 0
        back.Text = "< Back"
        back.TextColor3 = Color3.fromRGB(120, 180, 255)
        back.Font = Enum.Font.GothamBold
        back.TextSize = 13
        back.Active = true
        back.Parent = list
        back.MouseButton1Click:Connect(backCallback)
    end

    for _, item in ipairs(items) do
        if item.type == "toggle" then
            addToggle(item)
        elseif item.type == "button" then
            addButton(item)
        elseif item.type == "folder" then
            local thisBack = backCallback
            local folderItems = item.items
            local parentItems = items
            addFolder(item, function()
                Hub.renderView(folderItems, function()
                    Hub.renderView(parentItems, thisBack)
                end)
            end)
        end
    end
end

Hub.setActiveCategory = function(name)
    for catName, btn in pairs(Hub.sidebarButtons) do
        if catName == name then
            btn.BackgroundColor3 = Color3.fromRGB(50, 80, 130)
        else
            btn.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
        end
    end
end

local CATEGORIES = {
    {
        name = "Main",
        items = {
            { type = "toggle", name = "Fullbright", file = "fullbright.lua", global = "FullbrightScript" },
            { type = "toggle", name = "Teleport to Mouse", file = "tpmouse.lua", global = "TPMouseScript" },
            { type = "toggle", name = "Fly", file = "fly.lua", global = "FlyScript", config = "FlySpeed", default = 50 },
            { type = "toggle", name = "Speed", file = "speed.lua", global = "SpeedScript", config = "SpeedValue", default = 50 },
            { type = "toggle", name = "Infinite Jump", file = "infinitejump.lua", global = "InfiniteJumpScript" },
        }
    },
    {
        name = "Games",
        items = {
            { type = "folder", name = "Driving Empire", items = {
                { type = "button", name = "Halloween Event", file = "driving-empire/halloween-event.lua" },
                { type = "button", name = "Index Hub", file = "driving-empire/index-hub.lua" },
            }},
        }
    },
    {
        name = "Tools",
        items = {
            { type = "button", name = "SimpleSpy", file = "simple-spy.lua" },
            { type = "button", name = "Cobalt Spy", file = "cobalt-spy.lua" },
            { type = "button", name = "Copy job ID to clipboard", file = "copy-jobID.lua" },
        }
    },
    {
        name = "Universal",
        items = {
            { type = "button", name = "Infinite Yield", file = "infinite-yield.lua" },
            { type = "button", name = "Dex++", file = "dex++.lua" },
        }
    }
}

Hub.renderCategory = function(name)
    Hub.setActiveCategory(name)
    for _, cat in ipairs(CATEGORIES) do
        if cat.name == name then
            Hub.renderView(cat.items, nil)
            return
        end
    end
end

for _, cat in ipairs(CATEGORIES) do
    local categoryName = cat.name
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 32)
    btn.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
    btn.BorderSizePixel = 0
    btn.Text = categoryName
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 13
    btn.Active = true
    btn.Parent = sidebar
    Hub.sidebarButtons[categoryName] = btn
    btn.MouseButton1Click:Connect(function()
        Hub.renderCategory(categoryName)
    end)
end

Hub.renderCategory("Main")