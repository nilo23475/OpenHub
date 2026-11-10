local TeleportService = game:GetService("TeleportService")
local player = game.Players.LocalPlayer

local LOADER = "https://raw.githubusercontent.com/nilo23475/OpenHub/main/loader.lua"

local function queueLoader()
    local queue = queue_on_teleport
        or (syn and syn.queue_on_teleport)
        or (fluxus and fluxus.queue_on_teleport)
    if type(queue) == "function" then
        pcall(queue, 'loadstring(game:HttpGet("' .. LOADER .. '"))()')
    end
end

queueLoader()

local ok, err = pcall(function()
    TeleportService:Teleport(game.PlaceId, player)
end)

if not ok then
    warn("[OpenHub] Rejoin failed: " .. tostring(err))
end
