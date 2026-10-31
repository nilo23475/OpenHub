local TPMouseScript = {}
_G.TPMouseScript = TPMouseScript

local UIS = game:GetService("UserInputService")
local connection

function TPMouseScript.Start()
    if connection then return end
    connection = UIS.InputBegan:Connect(function(input, processed)
        if processed then return end
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            local player = game.Players.LocalPlayer
            local char = player.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if hrp then
                local mouse = player:GetMouse()
                hrp.CFrame = CFrame.new(mouse.Hit.Position + Vector3.new(0, 4, 0))
            end
        end
    end)
end

function TPMouseScript.Stop()
    if connection then
        connection:Disconnect()
        connection = nil
    end
end