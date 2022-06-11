local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)

local TweenService = game:GetService('TweenService')
local SoundService = game:GetService('SoundService')

local DoorFolder = game.Workspace.Doors
local Events = game.ReplicatedStorage.Events
local Remotes = Events.Remotes
local Functions = Events.Functions

local Player = game.Players.LocalPlayer
local Debounce = false

function CheckDoorStatus(DoorModel)
    if DoorModel:FindFirstChild("Data") and DoorModel.Data:FindFirstChild("Keycard") then
        local Has = Functions.GetData:InvokeServer("Keycards", "Level-0")
        
        if Has then return true end
    elseif DoorModel:FindFirstChild("AssociatedInteraction") then
        if DoorModel.AssociatedInteraction.Value:GetAttribute("Solved") then return true else return false end
    else
        return true
    end
end

for _, DoorModel in pairs(DoorFolder:GetChildren()) do
    for _, Door in pairs(DoorModel:GetChildren()) do
        if Door:IsA('BasePart') then
            Door.Touched:Connect(function(hit)
                local player = game:GetService("Players"):GetPlayerFromCharacter(hit.Parent)

                if player then
                    if Debounce == false then        
                        Debounce = true
                        
                        local Check = CheckDoorStatus(DoorModel)
                        if Check == false or Check == nil then task.wait(.5) Debounce = false return end                    
                        
                        Player.Character.Humanoid.WalkSpeed = 0

                        TweenService:Create(Player.PlayerGui.InteractionScreen.Fade, TweenInfo.new(0.25), {BackgroundTransparency = 0}):Play()
                        task.wait(.2)
                        SoundService.Sounds[Door.Parent.Name]:Play()
                        task.wait(.5)

                        if Door.Name == 'Entrance1' then
                            player.Character:SetPrimaryPartCFrame(Door.Parent.Entrance2.CFrame * CFrame.new(0, 0, -3))
                        else
                            player.Character:SetPrimaryPartCFrame(Door.Parent.Entrance1.CFrame * CFrame.new(0, 0, -3))
                        end

                        task.wait(1)
                        TweenService:Create(Player.PlayerGui.InteractionScreen.Fade, TweenInfo.new(0.25), {BackgroundTransparency = 1}):Play()
                        Player.Character.Humanoid.WalkSpeed = 10

                        wait(0.5)
                        Debounce = false
                    end
                end
            end)
        end
    end
end
