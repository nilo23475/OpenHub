local Players      = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local player  = Players.LocalPlayer
local spawner = workspace:WaitForChild("CollectibleSpawner")

local DELAY      = 0.35
local TWEEN_TIME = 2.5
local ORIGIN     = Vector3.new(-337, 16, -1700)
local SWEEP_DIST = 3000

local DIRECTIONS = {
	Vector3.new( 1, 0,  0),
	Vector3.new(-1, 0,  0),
	Vector3.new( 0, 0,  1),
	Vector3.new( 0, 0, -1),
}

local enabled = false
local killed  = false

local gui = Instance.new("ScreenGui")
gui.Name         = "TeleportControl"
gui.ResetOnSpawn = false
gui.Parent       = player:WaitForChild("PlayerGui")

local button = Instance.new("TextButton")
button.Size     = UDim2.new(0, 170, 0, 46)
button.Position = UDim2.new(0, 20, 0, 20)
button.Font     = Enum.Font.SourceSansBold
button.TextSize = 20
button.Parent   = gui

local killButton = Instance.new("TextButton")
killButton.Size             = UDim2.new(0, 170, 0, 30)
killButton.Position         = UDim2.new(0, 20, 0, 74)
killButton.Font             = Enum.Font.SourceSansBold
killButton.TextSize         = 16
killButton.Text             = "Kill Script"
killButton.BackgroundColor3 = Color3.fromRGB(120, 30, 30)
killButton.TextColor3       = Color3.new(1, 1, 1)
killButton.Parent           = gui

local function updateButton()
	button.Text             = "Teleport: " .. (enabled and "ON" or "OFF")
	button.BackgroundColor3 = enabled and Color3.fromRGB(50, 170, 70) or Color3.fromRGB(170, 50, 50)
	button.TextColor3       = Color3.new(1, 1, 1)
end
updateButton()

button.MouseButton1Click:Connect(function()
	if killed then return end
	enabled = not enabled
	updateButton()
	if not enabled then
		local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
		if root then root.Anchored = false end
	end
end)

killButton.MouseButton1Click:Connect(function()
	if killed then return end
	killed  = true
	enabled = false
	local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
	if root then root.Anchored = false end
	gui:Destroy()
end)

local function getRoot()
	local char = player.Character
	return char and char:FindFirstChild("HumanoidRootPart")
end

local function setFrozen(state)
	local root = getRoot()
	if root then root.Anchored = state end
end

local function getMeshes()
	local meshes = {}
	for _, obj in ipairs(spawner:GetDescendants()) do
		if obj:IsA("MeshPart") then
			table.insert(meshes, obj)
		elseif obj:IsA("BasePart")
			and (obj:FindFirstChildOfClass("SpecialMesh") or obj:FindFirstChildOfClass("Mesh")) then
			table.insert(meshes, obj)
		end
	end
	return meshes
end

local function teleport(cf)
	local root = getRoot()
	if root then root.CFrame = cf end
end

local function sweepDirection(dir)
	local root = getRoot()
	if not root then return false end

	setFrozen(true)
	root.CFrame = CFrame.new(ORIGIN)

	local goal  = CFrame.new(ORIGIN + dir * SWEEP_DIST)
	local tween = TweenService:Create(
		root,
		TweenInfo.new(TWEEN_TIME, Enum.EasingStyle.Linear),
		{ CFrame = goal }
	)
	tween:Play()

	local start = os.clock()
	while os.clock() - start < TWEEN_TIME do
		if killed then
			tween:Cancel()
			return false
		end
		if not enabled then
			tween:Cancel()
			return false
		end
		if #getMeshes() > 0 then
			tween:Cancel()
			return true
		end
		task.wait()
	end

	return false
end

task.spawn(function()
	while true do
		if killed then break end
		if not enabled then
			task.wait(DELAY)
			continue
		end

		local meshes = getMeshes()

		if #meshes > 0 then
			setFrozen(false)
			for _, m in ipairs(meshes) do
				if killed then break end
				if not enabled then break end
				if m.Parent and m:IsDescendantOf(spawner) then
					teleport(m.CFrame * CFrame.new(0, 5, 0))
					task.wait(DELAY)
				end
			end
		else
			local aborted = false
			for _, dir in ipairs(DIRECTIONS) do
				if killed then break end
				if not enabled then break end
				if sweepDirection(dir) then
					aborted = true
					break
				end
				local root = getRoot()
				if root then root.CFrame = CFrame.new(ORIGIN) end
				task.wait(DELAY)
			end

			if killed then break end
			if aborted then
				setFrozen(false)
			else
				task.wait(DELAY)
			end
		end
	end
end)

player.CharacterAdded:Connect(function()
	task.wait(0.1)
	if not killed and not enabled then setFrozen(false) end
end)