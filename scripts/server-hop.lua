local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local player = game.Players.LocalPlayer

local LOADER = "https://raw.githubusercontent.com/nilo23475/OpenHub/main/loader.lua"

local function httpGet(url)
    local request = rawget(_G, "request")
        or (syn and syn.request)
        or (http and http.request)
        or rawget(_G, "http_request")

    if type(request) == "function" then
        local ok, response = pcall(request, { Url = url, Method = "GET" })
        if ok and response then
            if type(response) == "table" then
                return response.Body or response.body
            end
            if type(response) == "string" then
                return response
            end
        end
    end

    local ok, body = pcall(function()
        return game:HttpGet(url)
    end)
    if ok and type(body) == "string" then
        return body
    end

    return nil
end

local function queueLoader()
    local queue = queue_on_teleport
        or (syn and syn.queue_on_teleport)
        or (fluxus and fluxus.queue_on_teleport)
    if type(queue) == "function" then
        pcall(queue, 'loadstring(game:HttpGet("' .. LOADER .. '"))()')
    end
end

local url = string.format(
    "https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=Asc&limit=100",
    game.PlaceId
)

local body = httpGet(url)
if not body then
    warn("[OpenHub] Server hop: no HTTP function available in this executor.")
    return
end

local ok, data = pcall(function()
    return HttpService:JSONDecode(body)
end)

if not ok or type(data) ~= "table" or type(data.data) ~= "table" then
    warn("[OpenHub] Server hop: unexpected response from Roblox.")
    return
end

local candidates = {}
for _, server in ipairs(data.data) do
    if server.id
        and server.id ~= game.JobId
        and (server.playing or 0) < (server.maxPlayers or 100) then
        table.insert(candidates, server)
    end
end

if #candidates == 0 then
    warn("[OpenHub] Server hop: no open servers found.")
    return
end

table.sort(candidates, function(a, b)
    return (a.playing or 0) < (b.playing or 0)
end)

local limit = math.min(10, #candidates)
local pick = candidates[math.random(1, limit)]

queueLoader()

local teleportOk, err = pcall(function()
    TeleportService:TeleportToPlaceInstance(game.PlaceId, pick.id, player)
end)

if not teleportOk then
    warn("[OpenHub] Server hop failed: " .. tostring(err))
end
