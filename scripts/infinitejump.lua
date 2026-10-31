local InfiniteJumpScript = {}
_G.InfiniteJumpScript = InfiniteJumpScript

local UIS = game:GetService("UserInputService")
local connection

function InfiniteJumpScript.Start()
    if connection then return end
    connection = UIS.JumpRequest:Connect(function()
        local char = game.Players.LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end)
end

function InfiniteJumpScript.Stop()
    if connection then
        connection:Disconnect()
        connection = nil
    end
end