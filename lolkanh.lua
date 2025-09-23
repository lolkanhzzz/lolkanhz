--// Player và GUI
local player = game.Players.LocalPlayer
local mouse = player:GetMouse()
local screenGui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
screenGui.Name = "lolkanhzMenu"

--// Menu chính
local menuFrame = Instance.new("Frame")
menuFrame.Size = UDim2.new(0, 220, 0, 150)
menuFrame.Position = UDim2.new(0.5, -110, 0.5, -75)
menuFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
menuFrame.Visible = false
menuFrame.Parent = screenGui

-- Tiêu đề
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1,0,0,30)
title.Position = UDim2.new(0,0,0,0)
title.BackgroundColor3 = Color3.fromRGB(60,60,60)
title.TextColor3 = Color3.fromRGB(255,255,255)
title.Text = "lolkanhz-v1 AIMBOT"
title.Parent = menuFrame

-- Nút bật/tắt AIMBOT
local aimbotButton = Instance.new("TextButton")
aimbotButton.Size = UDim2.new(0.8,0,0,30)
aimbotButton.Position = UDim2.new(0.1,0,0,40)
aimbotButton.Text = "AIMBOT OFF"
aimbotButton.BackgroundColor3 = Color3.fromRGB(80,80,80)
aimbotButton.TextColor3 = Color3.fromRGB(255,255,255)
aimbotButton.Parent = menuFrame

-- Slider vòng tròn AIMBOT
local sliderFrame = Instance.new("Frame")
sliderFrame.Size = UDim2.new(0.8,0,0,20)
sliderFrame.Position = UDim2.new(0.1,0,0,80)
sliderFrame.BackgroundColor3 = Color3.fromRGB(70,70,70)
sliderFrame.Parent = menuFrame

local slider = Instance.new("TextButton")
slider.Size = UDim2.new(0.5,0,1,0)
slider.Position = UDim2.new(0,0,0,0)
slider.BackgroundColor3 = Color3.fromRGB(200,200,200)
slider.Text = ""
slider.Parent = sliderFrame

local sliderValue = 100 -- bán kính vòng tròn
local dragging = false

slider.MouseButton1Down:Connect(function()
    dragging = true
end)
game:GetService("UserInputService").InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)
game:GetService("UserInputService").InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local pos = math.clamp(input.Position.X - sliderFrame.AbsolutePosition.X,0,sliderFrame.AbsoluteSize.X)
        slider.Size = UDim2.new(0, pos, 1, 0)
        sliderValue = (pos / sliderFrame.AbsoluteSize.X) * 200
    end
end)

-- Nút bật/tắt menu
local toggleMenu = Instance.new("TextButton")
toggleMenu.Size = UDim2.new(0,40,0,40)
toggleMenu.Position = UDim2.new(0,10,0,10)
toggleMenu.Text = "M"
toggleMenu.Parent = screenGui

toggleMenu.MouseButton1Click:Connect(function()
    menuFrame.Visible = not menuFrame.Visible
end)

--// Vòng tròn AIMBOT
local circle = Drawing.new("Circle")
circle.Radius = sliderValue
circle.Color = Color3.fromRGB(255,255,255)
circle.Thickness = 2
circle.Filled = false
circle.Visible = true

--// AIMBOT
local AimbotEnabled = false
aimbotButton.MouseButton1Click:Connect(function()
    AimbotEnabled = not AimbotEnabled
    aimbotButton.Text = AimbotEnabled and "AIMBOT ON" or "AIMBOT OFF"
end)

game:GetService("RunService").RenderStepped:Connect(function()
    circle.Position = Vector2.new(workspace.CurrentCamera.ViewportSize.X/2, workspace.CurrentCamera.ViewportSize.Y/2)
    circle.Radius = sliderValue

    if AimbotEnabled then
        local closestDist = math.huge
        local target = nil
        for i, plr in pairs(game.Players:GetPlayers()) do
            if plr ~= player and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") and plr.Character:FindFirstChild("Humanoid") and plr.Character.Humanoid.Health>0 then
                local pos, onScreen = workspace.CurrentCamera:WorldToViewportPoint(plr.Character.HumanoidRootPart.Position)
                if onScreen then
                    local mousePos = Vector2.new(workspace.CurrentCamera.ViewportSize.X/2, workspace.CurrentCamera.ViewportSize.Y/2)
                    local dist = (Vector2.new(pos.X,pos.Y) - mousePos).Magnitude
                    if dist < circle.Radius and dist < closestDist then
                        closestDist = dist
                        target = plr.Character.HumanoidRootPart
                    end
                end
            end
        end
        if target then
            workspace.CurrentCamera.CFrame = CFrame.lookAt(workspace.CurrentCamera.CFrame.Position, target.Position)
        end
    end
end)

--// ESP cơ bản
local Players = game:GetService("Players")
local ESPBoxes = {}

local function getTeamColor(plr)
    if plr.Team then
        return plr.TeamColor.Color
    else
        return Color3.fromRGB(255,255,255)
    end
end

local function addESP(player)
    if player.Character and not ESPBoxes[player] then
        local box = Instance.new("BoxHandleAdornment")
        box.Adornee = player.Character:FindFirstChild("HumanoidRootPart")
        box.AlwaysOnTop = true
        box.ZIndex = 10
        box.Size = Vector3.new(4,6,2)
        box.Color3 = getTeamColor(player)
        box.Transparency = 0.5
        box.Parent = game:GetService("CoreGui")
        ESPBoxes[player] = box
    end
end

local function removeESP(player)
    if ESPBoxes[player] then
        ESPBoxes[player]:Destroy()
        ESPBoxes[player] = nil
    end
end

local function updateESP()
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= player and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") and plr.Character:FindFirstChild("Humanoid") then
            if plr.Character.Humanoid.Health>0 then
                addESP(plr)
            else
                removeESP(plr)
            end
        else
            removeESP(plr)
        end
    end
end

Players.PlayerAdded:Connect(function(plr)
    plr.CharacterAdded:Connect(function()
        updateESP()
    end)
end)
Players.PlayerRemoving:Connect(function(plr)
    removeESP(plr)
end)
game:GetService("RunService").RenderStepped:Connect(updateESP)
