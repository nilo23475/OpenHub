local Players           = game:GetService("Players")
local UserInputService  = game:GetService("UserInputService")

local player    = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local UI_NAME = "EmoteUI_CustomLibrary"
local SAVE_FILE = "EmoteUI_SavedAnims.txt"

local function getUIParent()
    if type(gethui) == "function" then
        local ok, hui = pcall(gethui)
        if ok and hui then return hui end
    end
    return playerGui
end

local uiParent = getUIParent()
for _, parent in ipairs({ playerGui, uiParent }) do
    local old = parent:FindFirstChild(UI_NAME)
    if old then old:Destroy() end
end

local hasFileAPI = (writefile and readfile and isfile)

local CATEGORIES

local function loadSavedAnims()
    local saved = {}
    if not hasFileAPI then return saved end
    if isfile(SAVE_FILE) then
        local success, data = pcall(function() return readfile(SAVE_FILE) end)
        if success and data then
            for line in data:gmatch("[^\r\n]+") do
                local id, label, looped = line:match("([^|]+)|([^|]+)|([^|]+)")
                if id and label then
                    table.insert(saved, {
                        id = id,
                        label = label,
                        looped = (looped == "true")
                    })
                end
            end
        end
    end
    return saved
end

local function saveSavedAnims()
    if not hasFileAPI then return end
    if not CATEGORIES or not CATEGORIES["Saved"] then return end
    
    local data = ""
    for _, item in ipairs(CATEGORIES["Saved"]) do
        local safeLabel = string.gsub(item.label, "|", "/")
        data = data .. item.id .. "|" .. safeLabel .. "|" .. tostring(item.looped) .. "\n"
    end
    
    local success, err = pcall(function() writefile(SAVE_FILE, data) end)
    if not success then
        warn("[EmoteUI] Failed to save file: " .. tostring(err))
    end
end

CATEGORIES = {
    ["Dances"] = {
        { label="Sturdy Dance",        id="rbxassetid://132967433846099", looped=true },
        { label="Get Sturdy",          id="rbxassetid://122884053950359", looped=true },
        { label="STURDY",              id="rbxassetid://128968764985212", looped=true },
        { label="Belly Dance",         id="rbxassetid://85312683743028",  looped=true },
        { label="Moshing",             id="rbxassetid://96147994216119",  looped=true },
        { label="Hit Every Beat",      id="rbxassetid://136095999219650", looped=true },
        { label="Gangnam Style",       id="rbxassetid://129764254213842", looped=true },
        { label="Snoop's Walk",        id="rbxassetid://110204898807330", looped=true },
        { label="Sturdy NYC Dance",    id="rbxassetid://140333103929828", looped=true },
        { label="Dougie",              id="rbxassetid://93650537970037",  looped=true },
        { label="rollie",              id="rbxassetid://138097548542741", looped=true },
        { label="ACELERADA",           id="rbxassetid://103360497719320", looped=true },
        { label="Electro Swing",       id="rbxassetid://138785676658772", looped=true },
        { label="Tyla Dance",          id="rbxassetid://111754856931573", looped=true },
        { label="PhutHon",             id="rbxassetid://88038962894440",  looped=true },
        { label="Shake it",            id="rbxassetid://115318724645140", looped=true },
        { label="Shake That",          id="rbxassetid://138296642082362", looped=true },
    },
    ["Anims"] = {
        { label="Stylish Floating",    id="rbxassetid://112089880074848", looped=true },
        { label="I WANNA RUN AWAY",    id="rbxassetid://104428851742579", looped=true },
        { label="Hug",                 id="rbxassetid://118478639008343", looped=true },
        { label="Cute Kawaii",         id="rbxassetid://129100070542534", looped=true },
        { label="Kawaii Plushie Hug",  id="rbxassetid://105824857171709", looped=true },
    },
    ["Poses"] = {
        { label="Car Pose",            id="rbxassetid://132760747409859", looped=true },
        { label="Aura Pose (Centang)", id="rbxassetid://133418516499878", looped=true },
        { label="Bored Face",          id="rbxassetid://10713992055",     looped=true },
        { label="Aura Idle",           id="rbxassetid://122746752555782", looped=true },
        { label="YN Wall Lean",        id="rbxassetid://114388371896974", looped=true },
        { label="AFK",                 id="rbxassetid://106319474028876", looped=true },
        { label="Floating",            id="rbxassetid://73980801925168",  looped=true },
        { label="Wall Lean",           id="rbxassetid://128744696457318", looped=true },
        { label="Gojo Floating",       id="rbxassetid://109030594660124", looped=true },
        { label="Levitation Idle",     id="rbxassetid://113087712986783", looped=true },
        { label="Levitate",            id="rbxassetid://131063357988754", looped=true },
        { label="SpiderMan Hanging",   id="rbxassetid://123955307291627", looped=true },
        { label="Floating Goddess",    id="rbxassetid://100681208320300", looped=true },
    },
    ["Saved"] = loadSavedAnims()
}

local screenGui = Instance.new("ScreenGui")
screenGui.Name            = UI_NAME
screenGui.ResetOnSpawn    = false
screenGui.IgnoreGuiInset  = true
screenGui.DisplayOrder    = 999
screenGui.ZIndexBehavior  = Enum.ZIndexBehavior.Sibling
screenGui.Parent          = uiParent

local main = Instance.new("Frame")
main.Name                 = "Main"
main.Size                 = UDim2.fromOffset(320, 520)
main.Position             = UDim2.new(0.5, -160, 0.5, -260)
main.BackgroundColor3     = Color3.fromRGB(30, 30, 36)
main.BorderSizePixel      = 0
main.ClipsDescendants     = true
main.Parent               = screenGui

Instance.new("UICorner", main).CornerRadius = UDim.new(0, 12)

local mainStroke = Instance.new("UIStroke")
mainStroke.Thickness     = 1
mainStroke.Color         = Color3.fromRGB(80, 80, 95)
mainStroke.Transparency  = 0.35
mainStroke.Parent        = main

local titleBar = Instance.new("Frame")
titleBar.Name               = "TitleBar"
titleBar.Size               = UDim2.new(1, 0, 0, 50)
titleBar.BackgroundTransparency = 1
titleBar.Parent             = main

local title = Instance.new("TextLabel")
title.Size                   = UDim2.new(1, -70, 0, 24)
title.Position               = UDim2.new(0, 12, 0, 14)
title.BackgroundTransparency = 1
title.Font                   = Enum.Font.GothamBold
title.TextSize               = 18
title.TextColor3             = Color3.fromRGB(255, 255, 255)
title.TextXAlignment         = Enum.TextXAlignment.Left
title.Text                   = "Custom Emotes"
title.Parent                 = titleBar

local closeButton = Instance.new("TextButton")
closeButton.Name              = "Close"
closeButton.Size              = UDim2.fromOffset(26, 26)
closeButton.Position          = UDim2.new(1, -36, 0, 12)
closeButton.BackgroundColor3  = Color3.fromRGB(120, 45, 55)
closeButton.BorderSizePixel   = 0
closeButton.Font              = Enum.Font.GothamBold
closeButton.TextSize          = 16
closeButton.TextColor3        = Color3.fromRGB(255, 255, 255)
closeButton.Text              = "×"
closeButton.Parent            = main

Instance.new("UICorner", closeButton).CornerRadius = UDim.new(0, 6)
closeButton.Activated:Connect(function() screenGui:Destroy() end)

local tabBar = Instance.new("Frame")
tabBar.Name = "TabBar"
tabBar.Size = UDim2.new(1, -24, 0, 32)
tabBar.Position = UDim2.new(0, 12, 0, 52)
tabBar.BackgroundTransparency = 1
tabBar.Parent = main

local tabLayout = Instance.new("UIListLayout")
tabLayout.FillDirection = Enum.FillDirection.Horizontal
tabLayout.Padding = UDim.new(0, 6)
tabLayout.Parent = tabBar

local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Name                    = "ScrollFrame"
scrollFrame.Size                    = UDim2.new(1, -24, 1, -242)
scrollFrame.Position                = UDim2.new(0, 12, 0, 92)
scrollFrame.BackgroundTransparency  = 1
scrollFrame.BorderSizePixel         = 0
scrollFrame.ScrollBarThickness      = 6
scrollFrame.ScrollBarImageColor3    = Color3.fromRGB(120, 120, 140)
scrollFrame.ScrollBarImageTransparency = 0.2
scrollFrame.CanvasSize              = UDim2.new()
scrollFrame.AutomaticCanvasSize     = Enum.AutomaticSize.Y
scrollFrame.ScrollingDirection      = Enum.ScrollingDirection.Y
scrollFrame.Active                  = true
scrollFrame.ClipsDescendants        = true
scrollFrame.Parent                  = main

local listLayout = Instance.new("UIListLayout")
listLayout.Padding      = UDim.new(0, 7)
listLayout.SortOrder    = Enum.SortOrder.LayoutOrder
listLayout.Parent       = scrollFrame

local listPadding = Instance.new("UIPadding")
listPadding.PaddingRight = UDim.new(0, 6)
listPadding.Parent       = scrollFrame

local inputFrame = Instance.new("Frame")
inputFrame.Name = "InputFrame"
inputFrame.Size = UDim2.new(1, -24, 0, 38)
inputFrame.Position = UDim2.new(0, 12, 1, -136)
inputFrame.BackgroundColor3 = Color3.fromRGB(55, 55, 68)
inputFrame.BorderSizePixel = 0
inputFrame.Parent = main

Instance.new("UICorner", inputFrame).CornerRadius = UDim.new(0, 7)

local idInput = Instance.new("TextBox")
idInput.Name = "IDInput"
idInput.Size = UDim2.new(1, -70, 1, 0)
idInput.Position = UDim2.new(0, 8, 0, 0)
idInput.BackgroundTransparency = 1
idInput.Font = Enum.Font.Gotham
idInput.TextSize = 14
idInput.TextColor3 = Color3.fromRGB(255, 255, 255)
idInput.PlaceholderColor3 = Color3.fromRGB(150, 150, 160)
idInput.PlaceholderText = "Paste Market/Anim ID here..."
idInput.TextXAlignment = Enum.TextXAlignment.Left
idInput.Text = ""
idInput.ClearTextOnFocus = false
idInput.Parent = inputFrame

local saveBtn = Instance.new("TextButton")
saveBtn.Name = "SaveBtn"
saveBtn.Size = UDim2.new(0, 24, 0, 24)
saveBtn.Position = UDim2.new(1, -32, 0.5, -12)
saveBtn.BackgroundColor3 = Color3.fromRGB(45, 120, 60)
saveBtn.BorderSizePixel = 0
saveBtn.Font = Enum.Font.GothamBold
saveBtn.TextSize = 14
saveBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
saveBtn.Text = "+"
saveBtn.Parent = inputFrame

Instance.new("UICorner", saveBtn).CornerRadius = UDim.new(0, 6)

local playCustomBtn = Instance.new("TextButton")
playCustomBtn.Name = "PlayBtn"
playCustomBtn.Size = UDim2.new(1, -24, 0, 36)
playCustomBtn.Position = UDim2.new(0, 12, 1, -92)
playCustomBtn.BackgroundColor3 = Color3.fromRGB(55, 100, 150)
playCustomBtn.BorderSizePixel = 0
playCustomBtn.Font = Enum.Font.GothamBold
playCustomBtn.TextSize = 14
playCustomBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
playCustomBtn.Text = "Play Custom ID"
playCustomBtn.Parent = main

Instance.new("UICorner", playCustomBtn).CornerRadius = UDim.new(0, 7)

local stopButton = Instance.new("TextButton")
stopButton.Name              = "Stop"
stopButton.Size              = UDim2.new(1, -24, 0, 36)
stopButton.Position          = UDim2.new(0, 12, 1, -50)
stopButton.BackgroundColor3  = Color3.fromRGB(120, 45, 55)
stopButton.BorderSizePixel   = 0
stopButton.Font              = Enum.Font.GothamBold
stopButton.TextSize          = 14
stopButton.TextColor3        = Color3.fromRGB(255, 255, 255)
stopButton.Text              = "Stop Animation"
stopButton.Parent            = main

Instance.new("UICorner", stopButton).CornerRadius = UDim.new(0, 7)

local promptGui = Instance.new("Frame")
promptGui.Name = "PromptGui"
promptGui.Size = UDim2.new(1, -24, 0, 80)
promptGui.Position = UDim2.new(0, 12, 0.5, -40)
promptGui.BackgroundColor3 = Color3.fromRGB(40, 40, 48)
promptGui.BorderSizePixel = 0
promptGui.Visible = false
promptGui.ZIndex = 10
promptGui.Parent = main

local promptStroke = Instance.new("UIStroke")
promptStroke.Color = Color3.fromRGB(100, 100, 120)
promptStroke.Parent = promptGui
Instance.new("UICorner", promptGui).CornerRadius = UDim.new(0, 8)

local promptBox = Instance.new("TextBox")
promptBox.Size = UDim2.new(1, -16, 0, 32)
promptBox.Position = UDim2.new(0, 8, 0, 8)
promptBox.BackgroundColor3 = Color3.fromRGB(55, 55, 68)
promptBox.Font = Enum.Font.Gotham
promptBox.TextSize = 14
promptBox.TextColor3 = Color3.fromRGB(255, 255, 255)
promptBox.TextTruncate = Enum.TextTruncate.AtEnd
promptBox.ZIndex = 11
promptBox.Parent = promptGui

local promptOk = Instance.new("TextButton")
promptOk.Size = UDim2.new(1, -16, 0, 28)
promptOk.Position = UDim2.new(0, 8, 0, 44)
promptOk.BackgroundColor3 = Color3.fromRGB(55, 100, 150)
promptOk.Font = Enum.Font.GothamBold
promptOk.TextSize = 14
promptOk.TextColor3 = Color3.fromRGB(255, 255, 255)
promptOk.Text = "Save Name"
promptOk.ZIndex = 11
promptOk.Parent = promptGui
Instance.new("UICorner", promptOk).CornerRadius = UDim.new(0, 6)

local promptCancel = Instance.new("TextButton")
promptCancel.Size = UDim2.new(0, 24, 0, 24)
promptCancel.Position = UDim2.new(1, -28, 0, 4)
promptCancel.BackgroundTransparency = 1
promptCancel.Text = "×"
promptCancel.TextColor3 = Color3.fromRGB(200, 200, 200)
promptCancel.Font = Enum.Font.GothamBold
promptCancel.TextSize = 18
promptCancel.ZIndex = 12
promptCancel.Parent = promptGui

local currentTrack = nil
local activeTabButton = nil
local renamingEmote = nil

local function stopAnimation(fadeTime)
    if currentTrack then
        pcall(function() currentTrack:Stop(fadeTime or 0.15) end)
        currentTrack = nil
    end
end

local function playEmote(emote)
    local humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
    if not humanoid or humanoid.Health <= 0 then return end

    local animator = humanoid:FindFirstChildOfClass("Animator")
    if not animator then
        animator = Instance.new("Animator")
        animator.Parent = humanoid
    end

    stopAnimation(0.1)

    local animation = Instance.new("Animation")
    animation.AnimationId = emote.id

    local ok, track = pcall(function()
        return animator:LoadAnimation(animation)
    end)

    if ok and track then
        track.Looped   = emote.looped
        track.Priority = Enum.AnimationPriority.Action
        track:Play(0.1)
        currentTrack   = track
    else
        warn("[EmoteUI] Failed to load: " .. emote.id)
    end
end

local function resolveAnimationId(input)
    local numericId = string.match(tostring(input), "%d+")
    if not numericId then return input end

    local s, objs = pcall(function() return game:GetObjects("rbxassetid://"..numericId) end)
    if s and objs then
        for _, obj in ipairs(objs) do
            if obj:IsA("Animation") then
                local id = obj.AnimationId
                for _, o in ipairs(objs) do o:Destroy() end
                return id
            end
            local ca = obj:FindFirstChildWhichIsA("Animation", true)
            if ca then
                local id = ca.AnimationId
                for _, o in ipairs(objs) do o:Destroy() end
                return id
            end
            obj:Destroy()
        end
    end

    local s2, model = pcall(function() return game:GetService("AssetService"):LoadAssetAsync(tonumber(numericId)) end)
    if s2 and model then
        local ca = model:FindFirstChildWhichIsA("Animation", true)
        if ca then
            local id = ca.AnimationId
            model:Destroy()
            return id
        end
        model:Destroy()
    end
    
    return input
end

local function renderCategory(categoryName)
    for _, child in ipairs(scrollFrame:GetChildren()) do
        if child:IsA("TextButton") then
            child:Destroy()
        end
    end

    local emotes = CATEGORIES[categoryName]
    if not emotes or #emotes == 0 then return end

    for i, emote in ipairs(emotes) do
        local button = Instance.new("TextButton")
        button.Name        = "EmoteBtn"
        button.Text        = "" -- Handled by textLabel below for perfect spacing
        button.LayoutOrder = i
        button.BackgroundColor3 = Color3.fromRGB(55, 55, 68)
        button.BorderSizePixel  = 0
        button.AutoButtonColor  = true
        button.Size             = UDim2.new(1, 0, 0, 40)
        button.Parent           = scrollFrame

        Instance.new("UICorner", button).CornerRadius = UDim.new(0, 7)
        
        local stroke = Instance.new("UIStroke")
        stroke.Thickness    = 1
        stroke.Color        = Color3.fromRGB(100, 100, 118)
        stroke.Transparency = 0.45
        stroke.Parent       = button

        -- TextLabel ensures text truncates cleanly before overlapping the buttons
        local textLabel = Instance.new("TextLabel")
        textLabel.Size = UDim2.new(1, -75, 1, 0) -- Leaves 75px for R and X buttons
        textLabel.Position = UDim2.new(0, 10, 0, 0)
        textLabel.BackgroundTransparency = 1
        textLabel.Font = Enum.Font.GothamBold
        textLabel.TextSize = 14
        textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        textLabel.TextXAlignment = Enum.TextXAlignment.Left
        textLabel.TextTruncate = Enum.TextTruncate.AtEnd
        textLabel.Text = emote.label
        textLabel.Parent = button

        button.Activated:Connect(function()
            playEmote(emote)
        end)
        
        if categoryName == "Saved" then
            local delBtn = Instance.new("TextButton")
            delBtn.AnchorPoint = Vector2.new(1, 0.5)
            delBtn.Position = UDim2.new(1, -6, 0.5, 0) -- 6 pixels from the right edge
            delBtn.Size = UDim2.new(0, 26, 0, 26)
            delBtn.BackgroundColor3 = Color3.fromRGB(120, 45, 55)
            delBtn.Text = "X"
            delBtn.Font = Enum.Font.GothamBold
            delBtn.TextSize = 14
            delBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            delBtn.Parent = button
            Instance.new("UICorner", delBtn).CornerRadius = UDim.new(0, 6)
            
            delBtn.Activated:Connect(function()
                local idx = table.find(CATEGORIES["Saved"], emote)
                if idx then
                    table.remove(CATEGORIES["Saved"], idx)
                    saveSavedAnims()
                    renderCategory("Saved")
                end
            end)

            local renameBtn = Instance.new("TextButton")
            renameBtn.AnchorPoint = Vector2.new(1, 0.5)
            renameBtn.Position = UDim2.new(1, -36, 0.5, 0) -- 36 pixels from the right edge
            renameBtn.Size = UDim2.new(0, 26, 0, 26)
            renameBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 100)
            renameBtn.Text = "R"
            renameBtn.Font = Enum.Font.GothamBold
            renameBtn.TextSize = 14
            renameBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            renameBtn.Parent = button
            Instance.new("UICorner", renameBtn).CornerRadius = UDim.new(0, 6)

            renameBtn.Activated:Connect(function()
                renamingEmote = emote
                promptBox.Text = emote.label
                promptGui.Visible = true
            end)
        end
    end
    scrollFrame.CanvasPosition = Vector2.new(0, 0)
end

for catName, _ in pairs(CATEGORIES) do
    local tabBtn = Instance.new("TextButton")
    tabBtn.Name = catName
    tabBtn.Text = catName
    tabBtn.Size = UDim2.new(0.25, -5, 1, 0)
    tabBtn.BackgroundColor3 = Color3.fromRGB(55, 55, 68)
    tabBtn.BorderSizePixel = 0
    tabBtn.Font = Enum.Font.GothamBold
    tabBtn.TextSize = 13
    tabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    tabBtn.Parent = tabBar
    
    Instance.new("UICorner", tabBtn).CornerRadius = UDim.new(0, 6)
    
    tabBtn.Activated:Connect(function()
        if activeTabButton then
            activeTabButton.BackgroundColor3 = Color3.fromRGB(55, 55, 68)
        end
        tabBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 100)
        activeTabButton = tabBtn
        
        renderCategory(catName)
    end)
    
    if not activeTabButton then
        activeTabButton = tabBtn
        tabBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 100)
        renderCategory(catName)
    end
end

promptOk.Activated:Connect(function()
    if renamingEmote and promptBox.Text ~= "" then
        renamingEmote.label = promptBox.Text
        saveSavedAnims()
        renderCategory("Saved")
    end
    promptGui.Visible = false
    renamingEmote = nil
end)

promptCancel.Activated:Connect(function()
    promptGui.Visible = false
    renamingEmote = nil
end)

playCustomBtn.Activated:Connect(function()
    local inputText = idInput.Text
    if inputText == "" then return end

    playCustomBtn.Text = "Resolving..."
    playCustomBtn.Active = false
    task.spawn(function()
        local cleanID = resolveAnimationId(inputText)
        playCustomBtn.Text = "Play Custom ID"
        playCustomBtn.Active = true
        
        if type(cleanID) == "string" and not string.match(cleanID, "^rbxassetid://") then
            cleanID = "rbxassetid://" .. string.match(cleanID, "%d+")
        end
        
        idInput.Text = cleanID
        playEmote({ id = cleanID, looped = true })
    end)
end)

saveBtn.Activated:Connect(function()
    local inputText = idInput.Text
    if inputText == "" then return end

    saveBtn.Active = false
    task.spawn(function()
        local cleanID = resolveAnimationId(inputText)
        saveBtn.Active = true
        
        if type(cleanID) == "string" and not string.match(cleanID, "^rbxassetid://") then
            cleanID = "rbxassetid://" .. string.match(cleanID, "%d+")
        end

        idInput.Text = cleanID
        local newEmote = { label = "Custom: " .. string.match(cleanID, "%d+"), id = cleanID, looped = true }
        
        table.insert(CATEGORIES["Saved"], newEmote)
        saveSavedAnims()
        
        if activeTabButton and activeTabButton.Name == "Saved" then
            renderCategory("Saved")
        end
        
        idInput.Text = ""
    end)
end)

local dragging = false
local dragStart, startPos

titleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging  = true
        dragStart = input.Position
        startPos  = main.Position
    end
end)

titleBar.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        main.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

stopButton.Activated:Connect(function()
    stopAnimation(0.15)
end)

local function bindCharacter(character)
    local humanoid = character:WaitForChild("Humanoid", 5)
    if humanoid then
        humanoid.Died:Connect(function()
            stopAnimation(0)
        end)
    end
end

player.CharacterAdded:Connect(function(character)
    currentTrack = nil
    bindCharacter(character)
end)

if player.Character then
    bindCharacter(player.Character)
end