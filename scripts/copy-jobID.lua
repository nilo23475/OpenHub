local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local function copyToClipboard(text)
    if setclipboard then
        setclipboard(text)
    end
end

local jobId = game.JobId

copyToClipboard(jobId)