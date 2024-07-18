-- Settings and key binds
getgenv().Target = true
getgenv().Key = Enum.KeyCode.Q
getgenv().Prediction = 0.178
getgenv().ChatMode = false
getgenv().NotifMode = true
getgenv().PartMode = true
getgenv().AirshotFunccc = true
getgenv().Partz = "HumanoidRootPart"
getgenv().AutoPrediction = false
getgenv().Fov = 100
getgenv().Circle = true
getgenv().keytoclick = "Q"

-- Key bind tool creation
local tool = Instance.new("Tool")
tool.RequiresHandle = false
tool.Name = getgenv().keytoclick
tool.Activated:Connect(function()
    local vim = game:GetService("VirtualInputManager")
    vim:SendKeyEvent(true, getgenv().keytoclick, false, game)
end)
tool.Parent = game.Players.LocalPlayer.Backpack

-- Notification about the tool
game.StarterGui:SetCore("SendNotification", {
    Title = "Senselight",
    Text = "Thanks to saiko for let me borrow q tool locks",
})

-- Character connection functions
local player = game.Players.LocalPlayer
local function onCharacterAdded()
    -- Additional character added logic can be added here if needed
end

player.CharacterAdded:Connect(onCharacterAdded)

player.CharacterRemoving:Connect(function()
    tool.Parent = game.Players.LocalPlayer.Backpack
end)

-- Part types enumeration
_G.Types = {
    Ball = Enum.PartType.Ball,
    Block = Enum.PartType.Block,
    Cylinder = Enum.PartType.Cylinder
}

-- Aimlock visuals setup
local Tracer = Instance.new("Part", game.Workspace)
Tracer.Name = "Aimlock"
Tracer.Anchored = true
Tracer.CanCollide = false
Tracer.Transparency = 0.5
Tracer.Shape = _G.Types.Ball
Tracer.Size = Vector3.new(8, 8, 8)
Tracer.Color = Color3.fromRGB(255, 255, 255)

-- Mouse and drawing setup
local plr = game.Players.LocalPlayer
local mouse = plr:GetMouse()
local RunServ = game:GetService("RunService")

local circle = Drawing.new("Circle")
circle.Color = Color3.fromRGB(255, 255, 255)
circle.Thickness = 0
circle.NumSides = 100
circle.Radius = getgenv().Fov
circle.Transparency = 0
circle.Visible = getgenv().Circle
circle.Filled = false

local espBox = Drawing.new("Quad")
espBox.Thickness = 1
espBox.Transparency = 1
espBox.Visible = false

RunServ.RenderStepped:Connect(function()
    circle.Position = Vector2.new(mouse.X, mouse.Y + 35)

    if getgenv().AirshotFunccc then
        local Plr = game.Players.LocalPlayer
        if Plr.Character then
            if Plr.Character.Humanoid:GetState() == Enum.HumanoidStateType.Jumping and Plr.Character.Humanoid.FloorMaterial == Enum.Material.Air then
                getgenv().Partz = "RightFoot"
            else
                Plr.Character.Humanoid.StateChanged:Connect(function(old, new)
                    if new == Enum.HumanoidStateType.Freefall then
                        getgenv().Partz = "RightFoot"
                    else
                        getgenv().Partz = "HumanoidRootPart"
                    end
                end)
            end
        end
    end
end)

-- Main GUI folder
local guimain = Instance.new("Folder", game.CoreGui)

-- Notification if already loaded
if getgenv().valiansh == true then
    game.StarterGui:SetCore("SendNotification", {
        Title = "Senselight",
        Text = "Already loaded",
        Duration = 5
    })
    return
end

getgenv().valiansh = true

-- User input handling
local UserInputService = game:GetService("UserInputService")
UserInputService.InputBegan:Connect(function(input, isProcessed)
    if not isProcessed and input.KeyCode == getgenv().Key then
        if getgenv().Target then
            Locking = not Locking

            if Locking then
                local Plr = getClosestPlayerToCursor()
                if Plr then
                    if getgenv().ChatMode then
                        local A_1 = "Target: " .. tostring(Plr.Name)
                        local A_2 = "All"
                        local Event = game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents.SayMessageRequest
                        Event:FireServer(A_1, A_2)
                    end
                    if getgenv().NotifMode then
                        game.StarterGui:SetCore("SendNotification", {
                            Title = "Senselight",
                            Text = "Target: " .. tostring(Plr.Name),
                        })
                    end

                    espBox.Visible = true
                    espBox.Color = Color3.fromRGB(255, 0, 0)
                end
            else
                espBox.Visible = false
                if getgenv().ChatMode then
                    local A_1 = "Unlocked!"
                    local A_2 = "All"
                    local Event = game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents.SayMessageRequest
                    Event:FireServer(A_1, A_2)
                end
                if getgenv().NotifMode then
                    game.StarterGui:SetCore("SendNotification", {
                        Title = "Senselight",
                        Text = "Unlocked",
                        Duration = 5
                    })
                elseif not getgenv().Target then
                    game.StarterGui:SetCore("SendNotification", {
                        Title = "Senselight",
                        Text = "Target Left or Died",
                        Duration = 5
                    })
                end
            end
        end
    end
end)

-- Function to find closest player to cursor
function getClosestPlayerToCursor()
    local closestPlayer
    local shortestDistance = circle.Radius

    for i, v in pairs(game.Players:GetPlayers()) do
        if v ~= game.Players.LocalPlayer and v.Character and v.Character:FindFirstChild("Humanoid") and v.Character.Humanoid.Health > 0 then
            local pos, onScreen = game:GetService("Workspace").CurrentCamera:WorldToScreenPoint(v.Character.PrimaryPart.Position)
            if onScreen then
                local magnitude = (Vector2.new(pos.X, pos.Y) - Vector2.new(mouse.X, mouse.Y)).magnitude
                if magnitude < shortestDistance then
                    closestPlayer = v
                    shortestDistance = magnitude
                end
            end
        end
    end

    if closestPlayer then
        local pos, onScreen = game:GetService("Workspace").CurrentCamera:WorldToViewportPoint(closestPlayer.Character.PrimaryPart.Position)
        if onScreen then
            espBox.PointA = Vector2.new(pos.X - 50, pos.Y - 50)
            espBox.PointB = Vector2.new(pos.X + 50, pos.Y - 50)
            espBox.PointC = Vector2.new(pos.X + 50, pos.Y + 50)
            espBox.PointD = Vector2.new(pos.X - 50, pos.Y + 50)
        end
    end

    return closestPlayer
end

-- Part mode execution
if getgenv().PartMode then
    RunServ.Stepped:Connect(function()
        if Locking then
            local Plr = getClosestPlayerToCursor()
            if Plr and Plr.Character and Plr.Character:FindFirstChild(getgenv().Partz) then
                Tracer.CFrame = CFrame.new(Plr.Character[getgenv().Partz].Position + (Plr.Character[getgenv().Partz].Velocity * getgenv().Prediction))
            else
                Tracer.CFrame = CFrame.new(0, 9999, 0)
            end
       
                end
            end
        end
    end)
end

-- Remote event interception for predictive aiming
local rawmetatable = getrawmetatable(game)
local old = rawmetatable.__namecall
setreadonly(rawmetatable, false)
rawmetatable.__namecall = newcclosure(function(...)
    local args = {...}
    if Locking and getnamecallmethod() == "FireServer" and args[2] == "UpdateMousePos" then
        local Plr = getClosestPlayerToCursor()  -- Update Plr here to ensure it's the closest player
        if Plr and Plr.Character and Plr.Character:FindFirstChild(getgenv().Partz) then
            args[3] = Plr.Character[getgenv().Partz].Position + (Plr.Character[getgenv().Partz].Velocity * getgenv().Prediction)
        else
            args[3] = Vector3.new(0, 0, 0)  -- Default position if Plr is nil or doesn't have the specified part
        end
        return old(unpack(args))
    end
    return old(...)
end)

-- Auto prediction based on ping
while wait() do
    if getgenv().AutoPrediction then
        local pingvalue = game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValueString()
        local split = string.split(pingvalue, '(')
        local ping = tonumber(split[1])
        if ping < 130 then
            getgenv().Prediction = 0.151
        elseif ping < 125 then
            getgenv().Prediction = 0.149
        elseif ping < 110 then
            getgenv().Prediction = 0.140
        elseif ping < 105 then
            getgenv().Prediction = 0.133
        elseif ping < 90 then
            getgenv().Prediction = 0.130
        elseif ping < 80 then
            getgenv().Prediction = 0.128
        elseif ping < 70 then
            getgenv().Prediction = 0.123
        elseif ping < 60 then
            getgenv().Prediction = 0.1229
        elseif ping < 50 then
            getgenv().Prediction = 0.1225
        elseif ping < 40 then
            getgenv().Prediction = 0.1256
        end
    end
end
