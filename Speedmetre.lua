local gui = game.Players.LocalPlayer.PlayerGui:WaitForChild("Speedometer") --Speed metre for your character

local Module = {}

local Player = game:GetService("Players").LocalPlayer

local Frame = gui:WaitForChild("Frame")

local Bar = Frame:WaitForChild("Bar")

local Text = Frame:WaitForChild("Text")

local MaxSpeed = 45

local SetTo = 0

local LerpSpeed = 50



function Module:MainLoop()

	game:GetService("RunService").RenderStepped:Connect(function(deltaTime)

		if Player.Character then

			local Vel = Player.Character.HumanoidRootPart.Velocity.Magnitude

			if self.Services.CharacterActions.WallRunning.isWallRunning then

				Vel = self.Services.CharacterActions.WallRunning.characterSpeed

			end

			if Vel < 0.1 then

				Vel = 0.1

			end

			SetTo = math.clamp(SetTo + math.abs((Vel - SetTo))/(Vel-SetTo) * LerpSpeed * deltaTime, 0, 200)

			local SetToClamped = math.clamp(SetTo, 0.01, MaxSpeed)

			local Color = Color3.fromRGB((1-(SetToClamped/MaxSpeed))*225, (SetToClamped/MaxSpeed)*255, (SetToClamped/MaxSpeed)*234)

			if SetTo >= self.Services.CharacterActions.WallRunning.topSpeed - 1 then

				Color = Color3.fromRGB(255, 210, 48)

			end

			Bar.Size = UDim2.new(0, 180 * (SetToClamped/MaxSpeed), 0, 5)

			Bar.BackgroundColor3 = Color

			Text.Text = math.floor(SetTo).." st/s"

			Text.TextColor3 = Color

		end

	end)

end



function Module:Start()

	self:MainLoop()

end



return Module
