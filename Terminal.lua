--// Services
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

--// Constants
local ZOOM_MAG = 12

--// Globals
local Player = game:GetService("Players").LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

local CurrentTerminal

--// Content
for _, Terminal in ipairs(CollectionService:GetTagged("Terminal")) do
	local GUI = script.SurfaceGui:Clone()
	GUI.Adornee = Terminal.Screen
	GUI.Parent = PlayerGui
	ReplicatedStorage.GUI.Terminal:Clone().Parent = GUI.ClickDetector
	
	GUI.ClickDetector.MouseButton2Click:Connect(function ()
		if (Terminal.Screen.Position - Player.Character.PrimaryPart.Position).Magnitude <= ZOOM_MAG then
			workspace.CurrentCamera.CameraType = Enum.CameraType.Scriptable
			workspace.CurrentCamera.CFrame = Terminal.Screen.CFrame * CFrame.new(0, 0, 1.5)
			CurrentTerminal = Terminal
		end
	end)
	
	GUI.ClickDetector.MouseLeave:Connect(function ()
		workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
		CurrentTerminal = nil
	end)
end

RunService.RenderStepped:Connect(function ()
	if CurrentTerminal and Player.Character and Player.Character.PrimaryPart and (CurrentTerminal.Screen.Position - Player.Character.PrimaryPart.Position).Magnitude > ZOOM_MAG then
		workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
		CurrentTerminal = nil
	end
end)
