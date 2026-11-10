local BASE = "https://raw.githubusercontent.com/nilo23475/OpenHub/main"
local CONFIG_FILE = "OpenHubConfig.json"

local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local UIS = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local hasFileAPI = type(writefile) == "function"
    and type(readfile) == "function"
    and type(isfile) == "function"

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

local searchBox = Instance.new("TextBox")
searchBox.Size = UDim2.new(1, -20, 0, 28)
searchBox.Position = UDim2.new(0, 10, 0, 6)
searchBox.BackgroundColor3 = Color3.fromRGB(40, 40, 46)
searchBox.BorderSizePixel = 0
searchBox.PlaceholderText = "Search..."
searchBox.PlaceholderColor3 = Color3.fromRGB(130, 130, 140)
searchBox.Text = ""
searchBox.TextColor3 = Color3.new(1, 1, 1)
searchBox.Font = Enum.Font.Gotham
searchBox.TextSize = 13
searchBox.TextXAlignment = Enum.TextXAlignment.Left
searchBox.ClearTextOnFocus = false
searchBox.Parent = content

local searchPad = Instance.new("UIPadding")
searchPad.PaddingLeft = UDim.new(0, 8)
searchPad.PaddingRight = UDim.new(0, 8)
searchPad.Parent = searchBox

local list = Instance.new("ScrollingFrame")
list.Size = UDim2.new(1, -20, 1, -48)
list.Position = UDim2.new(0, 10, 0, 40)
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

local Hub = {
    sidebarButtons = {},
    toggleState = {},
    connections = {},
    registry = {},
    currentCategory = nil,
}

gui.Destroying:Connect(function()
    for _, conn in ipairs(Hub.connections) do
        pcall(function() conn:Disconnect() end)
    end
    Hub.connections = {}
end)

local CATEGORIES
local setSearch

local function clearList()
    for _, conn in ipairs(Hub.connections) do
        pcall(function() conn:Disconnect() end)
    end
    Hub.connections = {}
    for _, child in ipairs(list:GetChildren()) do
        if not child:IsA("UIListLayout") and not child:IsA("UIPadding") then
            child:Destroy()
        end
    end
end

local function getVal(store, key)
    if store then
        local t = _G[store]
        return t and t[key]
    end
    return _G[key]
end

local function setRaw(store, key, value)
    if store then
        _G[store] = _G[store] or {}
        _G[store][key] = value
    else
        _G[key] = value
    end
end

local saveQueued = false

function Hub.queueSave()
    if not hasFileAPI or saveQueued then return end
    saveQueued = true
    task.delay(0.4, function()
        saveQueued = false
        Hub.saveConfig()
    end)
end

local function setVal(store, key, value)
    setRaw(store, key, value)
    Hub.queueSave()
end

local function register(store, key, default)
    for _, entry in ipairs(Hub.registry) do
        if entry.store == store and entry.key == key then return entry end
    end
    local entry = { store = store, key = key, default = default }
    table.insert(Hub.registry, entry)
    return entry
end

local function encodeValue(value)
    if typeof(value) == "Color3" then
        return { __t = "Color3", r = value.R, g = value.G, b = value.B }
    end
    if typeof(value) == "EnumItem" then
        local enumName = tostring(value.EnumType)
        enumName = enumName:gsub("^Enum%.", "")
        return { __t = "Enum", enum = enumName, name = value.Name }
    end
    return value
end

local function decodeValue(value)
    if type(value) == "table" then
        if value.__t == "Color3" then
            return Color3.new(value.r or 0, value.g or 0, value.b or 0)
        end
        if value.__t == "Enum" then
            local ok, enumType = pcall(function() return Enum[value.enum] end)
            if ok and enumType then
                local ok2, item = pcall(function() return enumType[value.name] end)
                if ok2 then return item end
            end
        end
    end
    return value
end

function Hub.saveConfig()
    if not hasFileAPI then return end
    local out = { version = 1, stores = {}, globals = {} }
    for _, entry in ipairs(Hub.registry) do
        local value = getVal(entry.store, entry.key)
        if value ~= nil then
            if entry.store then
                out.stores[entry.store] = out.stores[entry.store] or {}
                out.stores[entry.store][entry.key] = encodeValue(value)
            else
                out.globals[entry.key] = encodeValue(value)
            end
        end
    end
    local ok, encoded = pcall(function() return HttpService:JSONEncode(out) end)
    if ok and encoded then
        pcall(writefile, CONFIG_FILE, encoded)
    end
end

function Hub.loadConfig()
    if not hasFileAPI then return end
    local fileOk, exists = pcall(isfile, CONFIG_FILE)
    if not fileOk or not exists then return end
    local ok, raw = pcall(readfile, CONFIG_FILE)
    if not ok or type(raw) ~= "string" or raw == "" then return end
    local ok2, data = pcall(function() return HttpService:JSONDecode(raw) end)
    if not ok2 or type(data) ~= "table" then return end

    for _, entry in ipairs(Hub.registry) do
        local rawValue
        if entry.store then
            local storeData = data.stores and data.stores[entry.store]
            if type(storeData) == "table" then
                rawValue = storeData[entry.key]
            end
        else
            if type(data.globals) == "table" then
                rawValue = data.globals[entry.key]
            end
        end
        if rawValue ~= nil then
            local value = decodeValue(rawValue)
            if value ~= nil then
                setRaw(entry.store, entry.key, value)
            end
        end
    end
end

local function initItemSettings(item)
    if item.settings then
        item.store = item.store or ((item.global or item.name) .. "Config")
        _G[item.store] = _G[item.store] or {}
        for _, entry in ipairs(item.settings) do
            if _G[item.store][entry.key] == nil then
                _G[item.store][entry.key] = entry.default
            end
            register(item.store, entry.key, entry.default)
        end
    end
    if item.config then
        if _G[item.config] == nil then
            _G[item.config] = item.default or 50
        end
        register(nil, item.config, item.default or 50)
    end
end

local function makeRow(height)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, height or 36)
    row.BackgroundTransparency = 1
    row.Parent = list
    return row
end

local function addBackButton(backCallback)
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
    back.MouseButton1Click:Connect(backCallback or function() end)
end

local function addTitle(text)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 24)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(190, 190, 200)
    label.Font = Enum.Font.GothamBold
    label.TextSize = 13
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = list
end

local function prettyKey(value)
    if typeof(value) == "EnumItem" then
        if value.EnumType == Enum.KeyCode then
            return value.Name
        end
        local text = tostring(value)
        return text:match("([^%.]+)$") or text
    end
    return tostring(value)
end

local function formatNumber(value, step)
    if step and step < 1 then
        local text = tostring(step)
        local dot = text:find("%.")
        local decimals = dot and (#text - dot) or 0
        return string.format("%." .. decimals .. "f", value)
    end
    return tostring(math.floor(value + 0.5))
end

local function addSliderRow(label, min, max, step, getValue, setValue)
    local row = makeRow(50)

    local text = Instance.new("TextLabel")
    text.Size = UDim2.new(1, -72, 0, 20)
    text.BackgroundTransparency = 1
    text.Text = label
    text.TextColor3 = Color3.fromRGB(225, 225, 230)
    text.Font = Enum.Font.Gotham
    text.TextSize = 13
    text.TextXAlignment = Enum.TextXAlignment.Left
    text.Parent = row

    local valueBox = Instance.new("TextBox")
    valueBox.Size = UDim2.new(0, 64, 0, 20)
    valueBox.Position = UDim2.new(1, -64, 0, 0)
    valueBox.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
    valueBox.BorderSizePixel = 0
    valueBox.TextColor3 = Color3.new(1, 1, 1)
    valueBox.Font = Enum.Font.Gotham
    valueBox.TextSize = 12
    valueBox.ClearTextOnFocus = false
    valueBox.Parent = row

    local track = Instance.new("Frame")
    track.Size = UDim2.new(1, -8, 0, 8)
    track.Position = UDim2.new(0, 4, 0, 30)
    track.BackgroundColor3 = Color3.fromRGB(50, 50, 58)
    track.BorderSizePixel = 0
    track.Active = true
    track.Parent = row

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new(0, 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(70, 130, 210)
    fill.BorderSizePixel = 0
    fill.Parent = track

    local function quantize(value)
        value = math.clamp(value, min, max)
        if step and step > 0 then
            value = min + math.floor((value - min) / step + 0.5) * step
            value = math.clamp(value, min, max)
        end
        return value
    end

    local function refresh()
        local value = getValue()
        if value == nil then value = min end
        local fraction = 0
        if max > min then
            fraction = (value - min) / (max - min)
        end
        fill.Size = UDim2.new(math.clamp(fraction, 0, 1), 0, 1, 0)
        valueBox.Text = formatNumber(value, step)
    end

    local draggingSlider = false

    local function applyFromX(x)
        local width = track.AbsoluteSize.X
        if width <= 0 then return end
        local fraction = math.clamp((x - track.AbsolutePosition.X) / width, 0, 1)
        setValue(quantize(min + fraction * (max - min)))
        refresh()
    end

    track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            draggingSlider = true
            applyFromX(input.Position.X)
        end
    end)

    table.insert(Hub.connections, UIS.InputChanged:Connect(function(input)
        if draggingSlider and (input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch) then
            applyFromX(input.Position.X)
        end
    end))

    table.insert(Hub.connections, UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            draggingSlider = false
        end
    end))

    valueBox.FocusLost:Connect(function()
        local number = tonumber(valueBox.Text)
        if number then
            setValue(quantize(number))
        end
        refresh()
    end)

    refresh()
end

local function addSettingToggle(store, entry)
    local row = makeRow(36)

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 1, 0)
    btn.BorderSizePixel = 0
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 13
    btn.Active = true
    btn.Parent = row

    local function refresh()
        local value = getVal(store, entry.key)
        btn.Text = entry.label .. (value and "  [ON]" or "  [OFF]")
        btn.BackgroundColor3 = value
            and Color3.fromRGB(30, 130, 70)
            or Color3.fromRGB(60, 60, 66)
    end

    btn.MouseButton1Click:Connect(function()
        setVal(store, entry.key, not getVal(store, entry.key))
        refresh()
    end)

    refresh()
end

local function addSettingSlider(store, entry)
    addSliderRow(
        entry.label,
        entry.min or 0,
        entry.max or 100,
        entry.step or 1,
        function() return getVal(store, entry.key) or entry.default end,
        function(value) setVal(store, entry.key, value) end
    )
end

local function addSettingSelect(store, entry)
    local row = makeRow(36)

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 1, 0)
    btn.BackgroundColor3 = Color3.fromRGB(60, 60, 66)
    btn.BorderSizePixel = 0
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 13
    btn.Active = true
    btn.Parent = row

    local function refresh()
        btn.Text = entry.label .. ": " .. tostring(getVal(store, entry.key))
    end

    btn.MouseButton1Click:Connect(function()
        local options = entry.options or {}
        if #options == 0 then return end
        local current = getVal(store, entry.key)
        local index = 1
        for i, option in ipairs(options) do
            if option == current then
                index = i
                break
            end
        end
        index = index % #options + 1
        setVal(store, entry.key, options[index])
        refresh()
    end)

    refresh()
end

local function addSettingColor(store, entry, onEdit)
    local row = makeRow(36)

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -48, 1, 0)
    btn.BackgroundColor3 = Color3.fromRGB(60, 60, 66)
    btn.BorderSizePixel = 0
    btn.Text = entry.label
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 13
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.Active = true
    btn.Parent = row

    local swatch = Instance.new("Frame")
    swatch.Size = UDim2.new(0, 40, 0, 28)
    swatch.Position = UDim2.new(1, -42, 0, 4)
    swatch.BorderSizePixel = 0
    swatch.BackgroundColor3 = getVal(store, entry.key) or entry.default or Color3.new(1, 1, 1)
    swatch.Parent = row

    btn.MouseButton1Click:Connect(onEdit)
end

local function addSettingKeybind(store, entry)
    local row = makeRow(36)

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 1, 0)
    btn.BorderSizePixel = 0
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 13
    btn.Active = true
    btn.Parent = row

    local listening = false
    local conn

    local function refresh()
        if listening then
            btn.Text = entry.label .. ": press a key..."
        else
            local value = getVal(store, entry.key) or entry.default
            btn.Text = entry.label .. ": " .. prettyKey(value)
        end
        btn.BackgroundColor3 = listening
            and Color3.fromRGB(80, 80, 120)
            or Color3.fromRGB(60, 60, 66)
    end

    btn.MouseButton1Click:Connect(function()
        if listening then return end
        listening = true
        refresh()

        conn = UIS.InputBegan:Connect(function(input)
            local value
            if input.UserInputType == Enum.UserInputType.Keyboard then
                if input.KeyCode == Enum.KeyCode.Escape then
                    listening = false
                    if conn then conn:Disconnect(); conn = nil end
                    refresh()
                    return
                end
                value = input.KeyCode
            elseif input.UserInputType == Enum.UserInputType.MouseButton1
                or input.UserInputType == Enum.UserInputType.MouseButton2
                or input.UserInputType == Enum.UserInputType.MouseButton3 then
                value = input.UserInputType
            end

            if value then
                setVal(store, entry.key, value)
                listening = false
                if conn then conn:Disconnect(); conn = nil end
                refresh()
            end
        end)
        table.insert(Hub.connections, conn)
    end)

    refresh()
end

local function addSettingNumber(store, entry)
    local row = makeRow(36)

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -78, 1, 0)
    btn.BackgroundColor3 = Color3.fromRGB(60, 60, 66)
    btn.BorderSizePixel = 0
    btn.Text = entry.label
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 13
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.Active = true
    btn.Parent = row

    local box = Instance.new("TextBox")
    box.Size = UDim2.new(0, 72, 1, 0)
    box.Position = UDim2.new(1, -74, 0, 0)
    box.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
    box.BorderSizePixel = 0
    box.Text = tostring(getVal(store, entry.key) or entry.default or 0)
    box.TextColor3 = Color3.new(1, 1, 1)
    box.Font = Enum.Font.Gotham
    box.TextSize = 13
    box.ClearTextOnFocus = false
    box.Parent = row

    box.FocusLost:Connect(function()
        local number = tonumber(box.Text)
        if number then
            if entry.min then number = math.max(entry.min, number) end
            if entry.max then number = math.min(entry.max, number) end
            setVal(store, entry.key, number)
        end
        box.Text = tostring(getVal(store, entry.key))
    end)
end

local function addSettingsButton(row, item, refresh)
    local gear = Instance.new("TextButton")
    gear.Size = UDim2.new(0, 26, 0, 30)
    gear.Position = UDim2.new(1, -26, 0, 3)
    gear.BackgroundColor3 = Color3.fromRGB(45, 45, 52)
    gear.BorderSizePixel = 0
    gear.Text = "..."
    gear.TextColor3 = Color3.fromRGB(180, 180, 190)
    gear.Font = Enum.Font.GothamBold
    gear.TextSize = 14
    gear.Active = true
    gear.Parent = row
    gear.MouseButton1Click:Connect(function()
        Hub.renderSettings(item, refresh)
    end)
end

local function addToggle(item, refresh)
    local key = (item.global or item.name) .. "|" .. (item.file or "")
    local state = Hub.toggleState[key]
    if not state then
        state = { loaded = false, enabled = false }
        Hub.toggleState[key] = state
    end

    local hasSettings = item.settings ~= nil and #item.settings > 0
    local hasConfig = item.config ~= nil
    local gearWidth = hasSettings and 28 or 0
    local boxWidth = hasConfig and 76 or 0

    local row = makeRow(36)

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -(gearWidth + boxWidth), 1, 0)
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
        box.Position = UDim2.new(1, -(72 + gearWidth + 2), 0, 0)
        box.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
        box.BorderSizePixel = 0
        box.Text = tostring(_G[item.config])
        box.TextColor3 = Color3.new(1, 1, 1)
        box.Font = Enum.Font.Gotham
        box.TextSize = 13
        box.ClearTextOnFocus = false
        box.Parent = row
        box.FocusLost:Connect(function()
            local number = tonumber(box.Text)
            if number then _G[item.config] = number end
            box.Text = tostring(_G[item.config])
            Hub.queueSave()
        end)
    end

    if hasSettings then
        addSettingsButton(row, item, refresh or function() end)
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
        if item.onClick then
            local ok, err = pcall(item.onClick)
            if not ok then
                warn("[OpenHub] " .. item.name .. ": " .. tostring(err))
            end
            return
        end
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
        addBackButton(backCallback)
    end

    local function refresh()
        Hub.renderView(items, backCallback)
    end

    for _, item in ipairs(items) do
        if item.type == "toggle" then
            addToggle(item, refresh)
        elseif item.type == "button" then
            addButton(item)
        elseif item.type == "folder" then
            local folderItems = item.items
            local parentItems = items
            addFolder(item, function()
                Hub.renderView(folderItems, function()
                    Hub.renderView(parentItems, backCallback)
                end)
            end)
        end
    end
end

function Hub.renderSettings(item, backCallback)
    clearList()
    addBackButton(backCallback or function() end)
    addTitle(item.name .. " settings")

    for _, entry in ipairs(item.settings or {}) do
        if entry.kind == "toggle" then
            addSettingToggle(item.store, entry)
        elseif entry.kind == "slider" then
            addSettingSlider(item.store, entry)
        elseif entry.kind == "select" then
            addSettingSelect(item.store, entry)
        elseif entry.kind == "color" then
            addSettingColor(item.store, entry, function()
                Hub.renderColorEditor(item, entry, function()
                    Hub.renderSettings(item, backCallback)
                end)
            end)
        elseif entry.kind == "keybind" then
            addSettingKeybind(item.store, entry)
        elseif entry.kind == "number" then
            addSettingNumber(item.store, entry)
        end
    end

    local reset = Instance.new("TextButton")
    reset.Size = UDim2.new(1, 0, 0, 34)
    reset.BackgroundColor3 = Color3.fromRGB(90, 45, 45)
    reset.BorderSizePixel = 0
    reset.Text = "Reset to defaults"
    reset.TextColor3 = Color3.new(1, 1, 1)
    reset.Font = Enum.Font.Gotham
    reset.TextSize = 13
    reset.Active = true
    reset.Parent = list
    reset.MouseButton1Click:Connect(function()
        for _, entry in ipairs(item.settings or {}) do
            setVal(item.store, entry.key, entry.default)
        end
        Hub.renderSettings(item, backCallback)
    end)
end

function Hub.renderColorEditor(item, entry, backCallback)
    clearList()
    addBackButton(backCallback or function() end)
    addTitle(entry.label)

    local previewRow = makeRow(52)
    local preview = Instance.new("Frame")
    preview.Size = UDim2.new(0, 64, 0, 40)
    preview.Position = UDim2.new(0, 0, 0, 4)
    preview.BorderSizePixel = 0
    preview.Parent = previewRow

    local previewLabel = Instance.new("TextLabel")
    previewLabel.Size = UDim2.new(1, -76, 0, 40)
    previewLabel.Position = UDim2.new(0, 76, 0, 4)
    previewLabel.BackgroundTransparency = 1
    previewLabel.Text = "Preview"
    previewLabel.TextColor3 = Color3.fromRGB(180, 180, 190)
    previewLabel.Font = Enum.Font.Gotham
    previewLabel.TextSize = 13
    previewLabel.TextXAlignment = Enum.TextXAlignment.Left
    previewLabel.Parent = previewRow

    local function currentColor()
        return getVal(item.store, entry.key) or entry.default or Color3.new(1, 1, 1)
    end

    local function updatePreview()
        preview.BackgroundColor3 = currentColor()
    end

    local function component(index)
        local color = currentColor()
        if index == 1 then return math.floor(color.R * 255 + 0.5) end
        if index == 2 then return math.floor(color.G * 255 + 0.5) end
        return math.floor(color.B * 255 + 0.5)
    end

    local function setComponent(index, value)
        local color = currentColor()
        local r = math.floor(color.R * 255 + 0.5)
        local g = math.floor(color.G * 255 + 0.5)
        local b = math.floor(color.B * 255 + 0.5)
        value = math.floor(value + 0.5)
        if index == 1 then
            r = value
        elseif index == 2 then
            g = value
        else
            b = value
        end
        setVal(item.store, entry.key, Color3.fromRGB(r, g, b))
        updatePreview()
    end

    addSliderRow("Red", 0, 255, 1, function() return component(1) end, function(value) setComponent(1, value) end)
    addSliderRow("Green", 0, 255, 1, function() return component(2) end, function(value) setComponent(2, value) end)
    addSliderRow("Blue", 0, 255, 1, function() return component(3) end, function(value) setComponent(3, value) end)

    updatePreview()
end

local function addPlayerRow(targetPlayer, backCallback)
    local row = makeRow(36)

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -64, 1, 0)
    btn.BackgroundColor3 = (_G.OpenHubTarget == targetPlayer)
        and Color3.fromRGB(30, 130, 70)
        or Color3.fromRGB(60, 60, 66)
    btn.BorderSizePixel = 0
    btn.Text = targetPlayer.DisplayName
    if targetPlayer.DisplayName ~= targetPlayer.Name then
        btn.Text = btn.Text .. " (@" .. targetPlayer.Name .. ")"
    end
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 13
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.Active = true
    btn.Parent = row
    btn.MouseButton1Click:Connect(function()
        if not targetPlayer.Parent then
            Hub.renderPlayerList(backCallback)
            return
        end
        _G.OpenHubTarget = targetPlayer
        if _G.ESPConfig then _G.ESPConfig.TargetMode = "Selected" end
        if _G.AimbotConfig then _G.AimbotConfig.TargetMode = "Selected" end
        Hub.queueSave()
        Hub.renderPlayerList(backCallback)
    end)

    local tp = Instance.new("TextButton")
    tp.Size = UDim2.new(0, 58, 1, 0)
    tp.Position = UDim2.new(1, -58, 0, 0)
    tp.BackgroundColor3 = Color3.fromRGB(50, 80, 130)
    tp.BorderSizePixel = 0
    tp.Text = "TP"
    tp.TextColor3 = Color3.new(1, 1, 1)
    tp.Font = Enum.Font.GothamBold
    tp.TextSize = 13
    tp.Active = true
    tp.Parent = row
    tp.MouseButton1Click:Connect(function()
        local myChar = player.Character
        local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
        local theirChar = targetPlayer.Character
        local theirHRP = theirChar and theirChar:FindFirstChild("HumanoidRootPart")
        if myHRP and theirHRP then
            pcall(function()
                myHRP.CFrame = theirHRP.CFrame + Vector3.new(0, 4, 0)
            end)
        end
    end)
end

function Hub.renderPlayerList(backCallback)
    clearList()
    if backCallback then
        addBackButton(backCallback)
    end
    addTitle("Players")

    local controls = makeRow(32)

    local refreshBtn = Instance.new("TextButton")
    refreshBtn.Size = UDim2.new(0.5, -2, 1, 0)
    refreshBtn.BackgroundColor3 = Color3.fromRGB(50, 55, 75)
    refreshBtn.BorderSizePixel = 0
    refreshBtn.Text = "Refresh"
    refreshBtn.TextColor3 = Color3.new(1, 1, 1)
    refreshBtn.Font = Enum.Font.Gotham
    refreshBtn.TextSize = 13
    refreshBtn.Active = true
    refreshBtn.Parent = controls
    refreshBtn.MouseButton1Click:Connect(function()
        Hub.renderPlayerList(backCallback)
    end)

    local clearBtn = Instance.new("TextButton")
    clearBtn.Size = UDim2.new(0.5, -2, 1, 0)
    clearBtn.Position = UDim2.new(0.5, 2, 0, 0)
    clearBtn.BackgroundColor3 = Color3.fromRGB(90, 45, 45)
    clearBtn.BorderSizePixel = 0
    clearBtn.Text = "Clear target"
    clearBtn.TextColor3 = Color3.new(1, 1, 1)
    clearBtn.Font = Enum.Font.Gotham
    clearBtn.TextSize = 13
    clearBtn.Active = true
    clearBtn.Parent = controls
    clearBtn.MouseButton1Click:Connect(function()
        _G.OpenHubTarget = nil
        if _G.ESPConfig then _G.ESPConfig.TargetMode = "Everyone" end
        if _G.AimbotConfig then _G.AimbotConfig.TargetMode = "Everyone" end
        Hub.queueSave()
        Hub.renderPlayerList(backCallback)
    end)

    local target = _G.OpenHubTarget
    local targetLabel = Instance.new("TextLabel")
    targetLabel.Size = UDim2.new(1, 0, 0, 22)
    targetLabel.BackgroundTransparency = 1
    targetLabel.Text = "Target: " .. (target and target.DisplayName or "none")
    targetLabel.TextColor3 = Color3.fromRGB(160, 200, 255)
    targetLabel.Font = Enum.Font.Gotham
    targetLabel.TextSize = 12
    targetLabel.TextXAlignment = Enum.TextXAlignment.Left
    targetLabel.Parent = list

    local others = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= player then
            table.insert(others, p)
        end
    end
    table.sort(others, function(a, b)
        return a.Name:lower() < b.Name:lower()
    end)

    for _, p in ipairs(others) do
        addPlayerRow(p, backCallback)
    end

    if #others == 0 then
        local empty = Instance.new("TextLabel")
        empty.Size = UDim2.new(1, 0, 0, 30)
        empty.BackgroundTransparency = 1
        empty.Text = "Nobody else is here."
        empty.TextColor3 = Color3.fromRGB(150, 150, 160)
        empty.Font = Enum.Font.Gotham
        empty.TextSize = 13
        empty.TextXAlignment = Enum.TextXAlignment.Left
        empty.Parent = list
    end

    table.insert(Hub.connections, Players.PlayerAdded:Connect(function()
        Hub.renderPlayerList(backCallback)
    end))
    table.insert(Hub.connections, Players.PlayerRemoving:Connect(function(leaving)
        if _G.OpenHubTarget == leaving then
            _G.OpenHubTarget = nil
            if _G.ESPConfig then _G.ESPConfig.TargetMode = "Everyone" end
            if _G.AimbotConfig then _G.AimbotConfig.TargetMode = "Everyone" end
            Hub.queueSave()
        end
        Hub.renderPlayerList(backCallback)
    end))
end

local function flattenItems(items, path, out)
    for _, item in ipairs(items or {}) do
        if item.type == "folder" then
            flattenItems(item.items, path .. " / " .. item.name, out)
        else
            table.insert(out, { item = item, path = path })
        end
    end
end

function Hub.renderSearch(query)
    local needle = query:lower()
    local flat = {}
    for _, category in ipairs(CATEGORIES or {}) do
        if category.items then
            flattenItems(category.items, category.name, flat)
        end
    end

    local matches = {}
    for _, entry in ipairs(flat) do
        if entry.item.name:lower():find(needle, 1, true) then
            table.insert(matches, entry.item)
        end
    end

    local function goBack()
        setSearch("")
        Hub.renderCategory(Hub.currentCategory or "Main")
    end

    if #matches == 0 then
        clearList()
        addBackButton(goBack)
        addTitle("No results")
        return
    end

    Hub.renderView(matches, goBack)
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

Hub.renderCategory = function(name)
    Hub.currentCategory = name
    Hub.setActiveCategory(name)
    for _, category in ipairs(CATEGORIES or {}) do
        if category.name == name then
            if category.render then
                category.render(nil)
            else
                Hub.renderView(category.items or {}, nil)
            end
            return
        end
    end
end

CATEGORIES = {
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
        name = "Combat",
        items = {
            {
                type = "toggle",
                name = "Aimbot",
                file = "aimbot.lua",
                global = "AimbotScript",
                store = "AimbotConfig",
                settings = {
                    { key = "AimKey", kind = "keybind", label = "Aim key", default = Enum.UserInputType.MouseButton2 },
                    { key = "AimMode", kind = "select", label = "Mode", options = { "Hold", "Toggle" }, default = "Hold" },
                    { key = "FOV", kind = "slider", label = "FOV", min = 10, max = 800, step = 5, default = 120 },
                    { key = "ShowFOV", kind = "toggle", label = "Show FOV circle", default = true },
                    { key = "FOVColor", kind = "color", label = "FOV color", default = Color3.fromRGB(255, 255, 255) },
                    { key = "Smoothing", kind = "slider", label = "Smoothing", min = 0, max = 100, step = 1, default = 25 },
                    { key = "TargetPart", kind = "select", label = "Target part", options = { "Head", "Torso", "Closest" }, default = "Head" },
                    { key = "TargetMode", kind = "select", label = "Target", options = { "Everyone", "Selected" }, default = "Everyone" },
                    { key = "TeamCheck", kind = "toggle", label = "Team check", default = true },
                    { key = "WallCheck", kind = "toggle", label = "Wall check", default = true },
                    { key = "IgnoreForcefield", kind = "toggle", label = "Ignore forcefield", default = true },
                    { key = "IgnoreInvisible", kind = "toggle", label = "Ignore invisible", default = true },
                    { key = "MaxDistance", kind = "slider", label = "Max distance", min = 50, max = 5000, step = 50, default = 1000 },
                    { key = "Prediction", kind = "slider", label = "Prediction", min = 0, max = 100, step = 1, default = 0 },
                    { key = "AutoShoot", kind = "toggle", label = "Auto shoot", default = false },
                    { key = "AutoShootDelay", kind = "slider", label = "Shoot delay", min = 0.05, max = 1, step = 0.05, default = 0.1 },
                },
            },
        }
    },
    {
        name = "Visuals",
        items = {
            {
                type = "toggle",
                name = "ESP",
                file = "esp.lua",
                global = "ESPScript",
                store = "ESPConfig",
                settings = {
                    { key = "Boxes", kind = "toggle", label = "Boxes", default = true },
                    { key = "BoxFill", kind = "toggle", label = "Box fill", default = false },
                    { key = "BoxColor", kind = "color", label = "Box color", default = Color3.fromRGB(255, 255, 255) },
                    { key = "Name", kind = "toggle", label = "Name", default = true },
                    { key = "Health", kind = "toggle", label = "Health bar", default = true },
                    { key = "Distance", kind = "toggle", label = "Distance", default = true },
                    { key = "Tracer", kind = "toggle", label = "Tracer", default = false },
                    { key = "Skeleton", kind = "toggle", label = "Skeleton", default = false },
                    { key = "Chams", kind = "toggle", label = "Chams", default = false },
                    { key = "ChamsColor", kind = "color", label = "Chams color", default = Color3.fromRGB(255, 60, 60) },
                    { key = "TeamCheck", kind = "toggle", label = "Team check", default = true },
                    { key = "VisibleCheck", kind = "toggle", label = "Visible check", default = false },
                    { key = "IncludeNPCs", kind = "toggle", label = "Include NPCs", default = false },
                    { key = "MaxDistance", kind = "slider", label = "Max distance", min = 50, max = 5000, step = 50, default = 1000 },
                    { key = "TextSize", kind = "slider", label = "Text size", min = 8, max = 24, step = 1, default = 14 },
                    { key = "TargetMode", kind = "select", label = "Target", options = { "Everyone", "Selected" }, default = "Everyone" },
                },
            },
        }
    },
    {
        name = "Players",
        render = function(backCallback)
            Hub.renderPlayerList(backCallback)
        end,
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
            { type = "button", name = "Dex++", file = "dex++.lua" },
            { type = "button", name = "Copy job ID to clipboard", file = "copy-jobID.lua" },
        }
    },
    {
        name = "Universal",
        items = {
            { type = "button", name = "Infinite Yield", file = "infinite-yield.lua" },
            { type = "button", name = "R15 Animations", file = "r15-anims.lua" },
            { type = "toggle", name = "Noclip", file = "noclip.lua", global = "NoclipScript" },
            { type = "toggle", name = "Anti-AFK", file = "antiafk.lua", global = "AntiAFKScript" },
        }
    },
    {
        name = "Server",
        items = {
            { type = "button", name = "Rejoin", file = "rejoin.lua" },
            { type = "button", name = "Server Hop", file = "server-hop.lua" },
        }
    },
}

local function walkItems(items)
    for _, item in ipairs(items or {}) do
        if item.type == "folder" then
            walkItems(item.items)
        else
            initItemSettings(item)
        end
    end
end

for _, category in ipairs(CATEGORIES) do
    walkItems(category.items)
end

Hub.loadConfig()

if _G.OpenHubTarget == nil then
    if _G.ESPConfig and _G.ESPConfig.TargetMode == "Selected" then
        _G.ESPConfig.TargetMode = "Everyone"
    end
    if _G.AimbotConfig and _G.AimbotConfig.TargetMode == "Selected" then
        _G.AimbotConfig.TargetMode = "Everyone"
    end
end

for _, category in ipairs(CATEGORIES) do
    local categoryName = category.name
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
        setSearch("")
        Hub.renderCategory(categoryName)
    end)
end

local suppressSearch = false

setSearch = function(text)
    suppressSearch = true
    searchBox.Text = text
    suppressSearch = false
end

searchBox:GetPropertyChangedSignal("Text"):Connect(function()
    if suppressSearch then return end
    local text = searchBox.Text
    if text == "" then
        Hub.renderCategory(Hub.currentCategory or "Main")
    else
        Hub.renderSearch(text)
    end
end)

Hub.renderCategory("Main")
