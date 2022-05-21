local Debris = game:GetService('Debris')
local Tween = game:GetService('TweenService')

local SlipObjects = game.Workspace.SlipObjects
local Debounce = false
local Active = false

local IgnoreTable = {
    game.Workspace.SlipObjects;
    game.Workspace.Interactions;
    game.Workspace.IgnoreRayObjects;
    game.Workspace.EventTriggers;
}

for _, Object in pairs(SlipObjects:GetChildren()) do
    Object.Touched:Connect(function(hit)
        local player = game:GetService("Players"):GetPlayerFromCharacter(hit.Parent)
        if player == nil then return end
        
        shared.CanMove = false
        local hitPart = workspace:FindPartOnRayWithIgnoreList(Ray.new(player.Character:FindFirstChild("HumanoidRootPart").Position, player.Character:FindFirstChild("HumanoidRootPart").CFrame.LookVector * 5), IgnoreTable)
        
        if not hitPart then
            local T = Tween:Create(player.Character.HumanoidRootPart, TweenInfo.new(1), {CFrame = player.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, -7)})
            T:Play()
            Active = true
            
            spawn(function()
                while Active do
                    wait()
                    local Pos = player.Character:FindFirstChild("HumanoidRootPart").Position

                    local hitPart = workspace:FindPartOnRayWithIgnoreList(Ray.new(player.Character:FindFirstChild("HumanoidRootPart").Position, player.Character:FindFirstChild("HumanoidRootPart").CFrame.LookVector * 3), IgnoreTable)

                    if hitPart or player.Character.HumanoidRootPart.Anchored == true then
                        T:Cancel()
                        player.Character:FindFirstChild("HumanoidRootPart").Position = Pos
                    end
                end
            end)
            
            task.wait(1)
            Active = false
        end
        
        shared.CanMove = true
        task.wait(.1)
    end)
end
