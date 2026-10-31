local FullbrightScript = {}
_G.FullbrightScript = FullbrightScript

local Lighting = game:GetService("Lighting")

local saved = {
    Brightness = Lighting.Brightness,
    Ambient = Lighting.Ambient,
    OutdoorAmbient = Lighting.OutdoorAmbient,
    FogEnd = Lighting.FogEnd,
    GlobalShadows = Lighting.GlobalShadows,
}

local running = false

function FullbrightScript.Start()
    if running then return end
    running = true
    Lighting.Brightness = 2
    Lighting.Ambient = Color3.fromRGB(255, 255, 255)
    Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
    Lighting.FogEnd = 1e6
    Lighting.GlobalShadows = false
end

function FullbrightScript.Stop()
    if not running then return end
    running = false
    Lighting.Brightness = saved.Brightness
    Lighting.Ambient = saved.Ambient
    Lighting.OutdoorAmbient = saved.OutdoorAmbient
    Lighting.FogEnd = saved.FogEnd
    Lighting.GlobalShadows = saved.GlobalShadows
end