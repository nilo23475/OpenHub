local Players           = game:GetService("Players")
local UserInputService  = game:GetService("UserInputService")

local player    = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local UI_NAME = "EmoteUI_CustomLibrary"

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

local CATEGORIES = {
    ["Dances"] = {
        { label="Michael Myers Shake", id="rbxassetid://118229457793841", looped=true },
        { label="Sturdy Dance",        id="rbxassetid://132967433846099", looped=true },
        { label="Get Sturdy",          id="rbxassetid://122884053950359", looped=true },
        { label="STURDY",              id="rbxassetid://128968764985212", looped=true },
        { label="Belly Dance",         id="rbxassetid://85312683743028",  looped=true },
        { label="Moshing",             id="rbxassetid://96147994216119",  looped=true },
        { label="Hit Every Beat",      id="rbxassetid://136095999219650", looped=true },
        { label="Gangnam Style",       id="rbxassetid://129764254213842", looped=true },
        { label="TV Time Dance",       id="rbxassetid://104748118296461", looped=true },
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
    }
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
main.Size                 = UDim2.fromOffset(320, 460)
main.Position             = UDim2.new(0.5, -160, 0.5, -230)
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
title.Text                   = "Custom Emotes (R15)"
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
scrollFrame.Size                    = UDim2.new(1, -24, 1, -150)
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

local stopButton = Instance.new("TextButton")
stopButton.Name              = "Stop"
stopButton.Size              = UDim2.new(1, -24, 0, 42)
stopButton.Position          = UDim2.new(0, 12, 1, -54)
stopButton.BackgroundColor3  = Color3.fromRGB(120, 45, 55)
stopButton.BorderSizePixel   = 0
stopButton.Font              = Enum.Font.GothamBold
stopButton.TextSize          = 15
stopButton.TextColor3        = Color3.fromRGB(255, 255, 255)
stopButton.Text              = "Stop Animation"
stopButton.Parent            = main

Instance.new("UICorner", stopButton).CornerRadius = UDim.new(0, 7)

local currentTrack = nil
local activeTabButton = nil

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

local function renderCategory(categoryName)
    for _, child in ipairs(scrollFrame:GetChildren()) do
        if child:IsA("TextButton") then
            child:Destroy()
        end
    end

    local emotes = CATEGORIES[categoryName]
    if not emotes then return end

    for i, emote in ipairs(emotes) do
        local button = Instance.new("TextButton")
        button.Name        = "EmoteBtn"
        button.Text        = emote.label
        button.LayoutOrder = i
        button.BackgroundColor3 = Color3.fromRGB(55, 55, 68)
        button.BorderSizePixel  = 0
        button.AutoButtonColor  = true
        button.Font             = Enum.Font.GothamBold
        button.TextSize         = 15
        button.TextColor3       = Color3.fromRGB(255, 255, 255)
        button.Size             = UDim2.new(1, 0, 0, 42)
        button.Parent           = scrollFrame

        Instance.new("UICorner", button).CornerRadius = UDim.new(0, 7)
        
        local stroke = Instance.new("UIStroke")
        stroke.Thickness    = 1
        stroke.Color        = Color3.fromRGB(100, 100, 118)
        stroke.Transparency = 0.45
        stroke.Parent       = button

        button.Activated:Connect(function()
            playEmote(emote)
        end)
    end
    
    scrollFrame.CanvasPosition = Vector2.new(0, 0)
end

for catName, _ in pairs(CATEGORIES) do
    local tabBtn = Instance.new("TextButton")
    tabBtn.Name = catName
    tabBtn.Text = catName
    tabBtn.Size = UDim2.new(0, 85, 1, 0)
    tabBtn.BackgroundColor3 = Color3.fromRGB(55, 55, 68)
    tabBtn.BorderSizePixel = 0
    tabBtn.Font = Enum.Font.GothamBold
    tabBtn.TextSize = 14
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

print("[EmoteUI] Loaded (R15 Only, Categorized).")