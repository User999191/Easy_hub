local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local GuiService = game:GetService("GuiService")
local Mouse = LocalPlayer:GetMouse()
local UserInputService = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")

local Settings = {
    AimLock = {
        Enabled = false,
        Aimlockkey = "q",
        Prediction = 0.19284,
        Aimpart = 'HumanoidRootPart',
        Notifications = true,
        Resolver = true
    },
    Settings = {
        Thickness = 2.85,
        Transparency = 1,
        Color = Color3.fromRGB(0, 2, 185),
        FOV = false
    },
    CamLock = {
        Enabled = false,
        Key = "q",
        CamlockPrediction = 0
    },
    AirshotFunccc = {
        Enabled = true,
        AirShotPrediction = 0.1
    }
}

-- Create ScreenGui and Button
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "CamLockUI"
screenGui.Parent = PlayerGui

local button = Instance.new("TextButton")
button.Name = "ToggleCamLockButton"
button.Size = UDim2.new(0, 100, 0, 40)  -- Smaller size
button.Position = UDim2.new(0.5, -50, 0, 10)  -- Top middle position
button.Text = "CamLock: Off"
button.TextScaled = true
button.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
button.TextColor3 = Color3.fromRGB(255, 255, 255)
button.Parent = screenGui

-- Variables for dragging
local dragging = false
local dragInput, dragStart, startPos

-- Function to toggle CamLock
local function toggleCamLock()
    Settings.CamLock.Enabled = not Settings.CamLock.Enabled
    button.Text = "CamLock: " .. (Settings.CamLock.Enabled and "On" or "Off")
end

-- Connect the button click to the toggle function
button.MouseButton1Click:Connect(toggleCamLock)

-- Function to start dragging
local function onDragStart(input)
    dragging = true
    dragStart = input.Position
    startPos = button.Position
    input.Changed:Connect(function()
        if input.UserInputState == Enum.UserInputState.End then
            dragging = false
        end
    end)
end

-- Function to update button position while dragging
local function onDragMove(input)
    if dragging then
        local delta = input.Position - dragStart
        button.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end

-- Connect dragging events
button.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        onDragStart(input)
    end
end)

button.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        onDragMove(input)
    end
end)

-- Function to find the closest player
local function FindClosestPlayer()
    local ClosestDistance, ClosestPlayer = math.huge, nil
    for _, Player in pairs(Players:GetPlayers()) do
        if Player ~= LocalPlayer and Player.Character then
            local humanoidRootPart = Player.Character:FindFirstChild("HumanoidRootPart")
            local bodyEffects = Player.Character:FindFirstChild("BodyEffects")
            if Player.Character.Humanoid.Health > 1 and bodyEffects and bodyEffects["K.O"].Value ~= true and not Player.Character:FindFirstChild("GRABBING_CONSTRAINT") then
                if humanoidRootPart then
                    local Position, IsVisibleOnViewPort = Workspace.CurrentCamera:WorldToViewportPoint(humanoidRootPart.Position)
                    if IsVisibleOnViewPort then
                        local Distance = (Vector2.new(Mouse.X, Mouse.Y) - Vector2.new(Position.X, Position.Y)).Magnitude
                        if Distance < ClosestDistance then
                            ClosestPlayer = Player
                            ClosestDistance = Distance
                        end
                    end
                end
            end
        end
    end
    return ClosestPlayer, ClosestDistance
end

-- Create Drawing objects for aimlock
local aimlockDot = Drawing.new("Circle")
aimlockDot.Radius = 10
aimlockDot.Color = Color3.fromRGB(255, 255, 0)
aimlockDot.Thickness = 1
aimlockDot.Filled = true
aimlockDot.Visible = false

-- Handle Key Input
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed then
        if input.KeyCode == Enum.KeyCode[Settings.AimLock.Aimlockkey:upper()] then
            Settings.AimLock.Enabled = not Settings.AimLock.Enabled
            if Settings.AimLock.Enabled then
                local targetPlayer = FindClosestPlayer()
                if targetPlayer then
                    local targetName = targetPlayer.Name
                    StarterGui:SetCore("SendNotification", {
                        Title = "AimLock Activated",
                        Text = "Target: " .. targetName,
                        Duration = 2
                    })
                end
            end
        elseif input.KeyCode == Enum.KeyCode[Settings.CamLock.Key:upper()] then
            toggleCamLock() -- Toggle CamLock when the CamLock key is pressed
        end
    end
end)

-- Handle Touch Input
local touchStarted = false
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if input.UserInputType == Enum.UserInputType.Touch then
        touchStarted = true
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch then
        touchStarted = false
    end
end)

-- Update logic for AimLock and CamLock
RunService.Heartbeat:Connect(function()
    local Plr = Settings.AimLock.Enabled and FindClosestPlayer() or nil

    if Settings.AimLock.Enabled and Plr then
        local targetPart = Plr.Character:FindFirstChild(Settings.AimLock.Aimpart)
        if targetPart then
            -- Calculate the predicted position
            local predictedPosition = targetPart.Position + (targetPart.Velocity * Settings.AimLock.Prediction)

            if Settings.AirshotFunccc.Enabled and Plr.Character.Humanoid:GetState() == Enum.HumanoidStateType.Freefall then
                predictedPosition = targetPart.Position + (targetPart.Velocity * Settings.AirshotFunccc.AirShotPrediction)
            end

            -- Use resolver position or predicted position
            local aimPosition = Settings.AimLock.Resolver and targetPart.Position or predictedPosition

            -- Update aimlockDot position
            local Vector = Workspace.CurrentCamera:WorldToViewportPoint(aimPosition)
            aimlockDot.Position = Vector2.new(Vector.X, Vector.Y)
            aimlockDot.Visible = not touchStarted
        else
            aimlockDot.Visible = false
        end
    else
        aimlockDot.Visible = false
    end

    if Settings.CamLock.Enabled and Plr and Plr ~= LocalPlayer then
        local targetPart = Plr.Character:FindFirstChild(Settings.AimLock.Aimpart)
        if targetPart then
            local predictedPosition = targetPart.Position + (targetPart.Velocity * Settings.CamLock.CamlockPrediction)
            Workspace.CurrentCamera.CFrame = CFrame.new(Workspace.CurrentCamera.CFrame.Position, predictedPosition)
        end
    end
end)

-- Hook into metatable for AimLock prediction
local mt = getrawmetatable(game)
local old = mt.__namecall
setreadonly(mt, false)
mt.__namecall = newcclosure(function(...)
    local args = {...}
    if Settings.AimLock.Enabled and getnamecallmethod() == "FireServer" and args[2] == "UpdateMousePos" then
        local targetPart = FindClosestPlayer().Character:FindFirstChild(Settings.AimLock.Aimpart)
        local predictedPosition = targetPart.Position + (targetPart.Velocity * Settings.AimLock.Prediction)

        if Settings.AirshotFunccc.Enabled and targetPart.Parent.Humanoid:GetState() == Enum.HumanoidStateType.Freefall then
            predictedPosition = targetPart.Position + (targetPart.Velocity * Settings.AirshotFunccc.AirShotPrediction)
        end

        args[3] = predictedPosition
        return old(unpack(args))
    end
    return old(...)
end)
setreadonly(mt, true)
