--// Services
local Delta = require(game:GetService("ReplicatedStorage"):WaitForChild("Delta"):WaitForChild("DeltaFramework"))
local Tween = Delta.TweenService
local UIS = Delta.UIS

--// Directories
local Effects = game.Workspace.Sounds.Effects

local Maid = Delta:Get('Maid').new()
local Button = Delta:Get("Button")

--// Systems
local TestSystem = Delta:Get("TestingSystem")

--// Variables
local Cam = game.Workspace.CurrentCamera

--// Initiation

local System = {}
System.__index = System

local TestHandler = nil

--// Functions

function StartCamLock(Tablet)
	spawn(function()
		game:GetService("RunService"):BindToRenderStep("Cam", Enum.RenderPriority.Camera.Value + 1, function()
			local TabletScreen = game.Workspace.BulletStorage:FindFirstChild("Screen")
			
			if TabletScreen == nil then
				
			else
				Cam.CFrame = TabletScreen.CFrame * CFrame.new(0, 0, 1)
			end			
		end)
	end)
end

--// Methods

function System.new(plr)
	local Locals = {}
	setmetatable(Locals, System)

	Locals.plr = plr
	Locals.SystemUI = nil

	return Locals
end

function System:Start(Tablet)
	StartCamLock(Tablet)
	self.plr.PlayerGui.CoreGameplayUI.Enabled = false
	self.plr.PlayerGui.FadeHandle.Enabled = false
	
	if not self.SystemUI then
		local SystemUI = script.TabletUI:Clone()
		self.SystemUI = SystemUI
		self.SystemUI .Parent = self.plr.PlayerGui
	end
	
	self.SystemUI.Adornee = Tablet.Screen
	Tablet.Screen.Parent = game.Workspace.BulletStorage

	for _, Buttons in pairs(self.SystemUI.Frame.MainMenu:GetChildren()) do
		if Buttons:IsA("ImageButton") then

			if Buttons.Name == "Testing" then
				if Delta.Player.Team.Name == "Innovation Department" or Delta.Player.Team.Name == "Site Overwatch" then
					Buttons.Visible = true
				else
					Buttons.Visible = false
				end
			end
			
			Maid:GiveTask(Buttons.Activated:Connect(function()
				self.SystemUI .Frame.MainMenu.Visible = false
				
				if Buttons.Name == "Testing" and Delta.Player.Team.Name == "Innovation Department" or Delta.Player.Team.Name == "Site Overwatch" then
					self.SystemUI.Frame.TestingMenu.Visible = true

					TestHandler = TestSystem.new(self.plr, self.SystemUI)
					
					TestHandler:StartLastFrame()
					TestHandler:StartStage1()
				end
			end))
			
		end
	end
end

function System:Stop(Tablet)
	game:GetService("RunService"):UnbindFromRenderStep('Cam')
	
	if Tablet then
		game.Workspace.BulletStorage:FindFirstChild("Screen").Parent = Tablet
	else
		if game.Workspace.BulletStorage:FindFirstChild("Screen") then
			game.Workspace.BulletStorage:FindFirstChild("Screen"):Destroy()
			self.SystemUI:Destroy()
		end
		
		self.SystemUI = nil
	end
	
	Maid:DoCleaning()

	if self.SystemUI and self.SystemUI.Frame.TestingMenu.Visible == false then
		self.SystemUI:Destroy()
		self.SystemUI = nil
	elseif self.SystemUI then
		self.SystemUI.Adornee = nil
	end
	
	self.plr.PlayerGui.CoreGameplayUI.Enabled = true
	self.plr.PlayerGui.FadeHandle.Enabled = true
end

return System
