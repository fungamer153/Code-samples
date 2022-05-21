--// Initation
local module = {}
module.__index = module

--// Services
local RunService = game:GetService('RunService')
local Debris = game:GetService('Debris')
local Tween = game:GetService('TweenService')

--// Directories
local Shared = game.ReplicatedStorage.Shared
local Events = game.ReplicatedStorage.Events
local Assets = game.ReplicatedStorage.Assets
local Remotes = Events.Remotes
local GunSettings = game.ReplicatedStorage.WeaponSettings
local FastCast = require(Shared["Gun system"].FastCastRedux)
local Spring = require(Shared.spring)
local Maid = require(Shared.Maid).new()

--// Tables
Springs = {}

--// Initiation
local caster = FastCast.new()
Springs.fire = Spring.create()

local castParamsLocal = RaycastParams.new()
castParamsLocal.FilterType = Enum.RaycastFilterType.Blacklist
castParamsLocal.IgnoreWater = true

local castBehaviorLocal = FastCast.newBehavior()
castBehaviorLocal.RaycastParams = castParamsLocal
castBehaviorLocal.Acceleration = Vector3.new(0, 0, 0)
castBehaviorLocal.AutoIgnoreContainer = false
castBehaviorLocal.CosmeticBulletContainer = workspace.Ignore
castBehaviorLocal.CosmeticBulletTemplate = game.ReplicatedStorage.Bullets['RifleBullet']
castBehaviorLocal.FilterDescendantsInstances = game.Workspace.Ignore

--// Functions

function CastRay(Origin, Target, Length, Ignore, IgnoreWater)
	local RayParams = RaycastParams.new()

	if typeof(Origin) == "Ray" then
		if type(Target) == "table" then
			RayParams.FilterDescendantsInstances = Target
			RayParams.IgnoreWater = Length
		else
			RayParams.IgnoreWater = Target
		end

		return workspace:Raycast(Origin.Origin, Origin.Direction, RayParams)
	else
		if type(Ignore) == "table" then
			RayParams.FilterDescendantsInstances = Ignore
			RayParams.IgnoreWater = IgnoreWater
		else
			RayParams.IgnoreWater = Ignore
		end

		return workspace:Raycast(Origin, Length == false and Target or (Target - Origin).Unit * Length, RayParams)
	end
end

local function LengthChanged(cast, lastPoint, direction, length, velocity, bullet)
	spawn(function()
		game:GetService("Debris"):AddItem(bullet, 10)
	end)

	if bullet then
		bullet.CFrame = CFrame.new(lastPoint, lastPoint + direction) * CFrame.new(0, 0, -length)
	end	
end

local function onRayHit(cast, result, velocity, bullet)
	if not result then return end

	local hit = result.Instance
	local LastHit = nil
	local character = hit:FindFirstAncestorWhichIsA("Model")

	if character and character:FindFirstChild("Humanoid") then
		if character.Parent == workspace.Ignore then return end

		if cast['UserData'] then

			local Marker = game.ReplicatedStorage.WeaponAssets.Blood:Clone()
			Marker.Parent = hit
			Marker:Emit(3)

			local Sound = game.ReplicatedStorage.WeaponAssets.BodyHit:Clone()
			Sound.Parent = hit
			Sound:Play()

			game:GetService('Debris'):AddItem(Marker, 2)
			game:GetService('Debris'):AddItem(Sound, 2)

			Remotes.GunSystem.SendbackHit:FireServer(hit)

			cast['UserData'] = nil
		end	
	else
		if cast['UserData'] then
			local Sound = nil
			
			if cast['NormalData'] then				
				local Marker = game.ReplicatedStorage.WeaponAssets.Hit:Clone()
				Marker.Smoke.Color = ColorSequence.new{ColorSequenceKeypoint.new(0, hit.Color), ColorSequenceKeypoint.new(1, hit.Color)}
				Marker.Metal.Color = ColorSequence.new{ColorSequenceKeypoint.new(0, hit.Color), ColorSequenceKeypoint.new(1, hit.Color)}
				Marker.Parent = game.Workspace.Ignore
				Marker.CFrame = CFrame.new(bullet.Position, bullet.Position + cast['NormalData'])
				
				if hit.Material == Enum.Material.Metal then
					Marker.Metal.Enabled = true
					Sound = game.ReplicatedStorage.WeaponAssets.MetalHit:Clone()
				else
					Marker.Smoke.Enabled = true
					Sound = game.ReplicatedStorage.WeaponAssets.BulletHit:Clone()
				end
				
				delay(.25, function()
					Marker.Metal.Enabled = false
					Marker.Smoke.Enabled = false
				end)

				Sound.Parent = Marker
				Sound:Play()

				--game:GetService('Debris'):AddItem(Marker, 2)
				game:GetService('Debris'):AddItem(Sound, 2)
			end

			cast['UserData'] = nil
		end	
	end

	bullet:Destroy()
end

--// Methods
function module.new(plr, WeaponName, WeaponModel)
	local Methods = {}
	setmetatable(Methods, module)
	
	Maid:DoCleaning()
	
	Methods.Bullets = {}
	Methods.plr = plr
	Methods.LastShot = 0
	Methods.WeaponSettings = require(GunSettings[WeaponName])
	Methods.WeaponModel = WeaponModel
	
	Maid:GiveTask(Remotes.Shoot.OnClientEvent:Connect(function(CameraRay, Tool, Position, Normal)
		local Cast = nil
		
		local Sound = Instance.new('Sound')
		Sound.SoundId = 'rbxassetid://'..Methods.WeaponSettings.FireSound
		Sound.RollOffMaxDistance = 100
		Sound.Parent = Tool.Muzzle
		Sound:Play()
				
		for _, Particle in pairs(Methods.WeaponModel.Muzzle.Attachment:GetChildren()) do
			if Particle:IsA('ParticleEmitter') then
				Particle:Emit(1)
			end
		end
		Methods.WeaponModel.Muzzle.Attachment.PointLight.Enabled = true

		delay(0.15, function()
			Methods.WeaponModel.Muzzle.Attachment.PointLight.Enabled = false
		end)
		
		game:GetService('Debris'):AddItem(Sound, 5)

		local S,E = pcall(function()
			Cast = caster:Fire(Tool.Barrel.Position, (CameraRay.Origin + Position) - Tool.Barrel.Position, 500, castBehaviorLocal)
		end)
				
		if S and Cast then
			Cast.UserData.Shot = true
			Cast.Weapon = Tool
			Cast.NormalData = Normal
		end
	end))

	caster.RayHit:Connect(onRayHit)
	caster.LengthChanged:Connect(LengthChanged)
	
	return Methods
end

function module:CreateBullet()
	if tick() - self.LastShot >= self.WeaponSettings['FireRate'] then
		self.LastShot = tick()
	else
		return -- Fooling anyone who has a good auto clicker or so
	end
	
	Springs.fire:shove(Vector3.new(0.065, 0, 0))
	local Reverb = Assets.SoundEffects.Reverb:Clone()

	delay(.1, function()
		Springs.fire:shove(Vector3.new(-0.065, 0, 0))
	end)
	
	local Sound = Instance.new('Sound')
	Sound.SoundId = 'rbxassetid://'..self.WeaponSettings.FireSound
	Sound.RollOffMaxDistance = 100
	Sound.Parent = self.plr.Character.HumanoidRootPart
	Reverb.Parent = Sound
	Sound:Play()
	
	Debris:AddItem(Sound, 2)
	
	for _, Particle in pairs(self.WeaponModel.Muzzle.Attachment:GetChildren()) do
		if Particle:IsA('ParticleEmitter') then
			Particle:Emit(1)
		end
	end
  
	self.WeaponModel.Muzzle.Attachment.PointLight.Enabled = true
	
	delay(0.15, function()
		self.WeaponModel.Muzzle.Attachment.PointLight.Enabled = false
	end)
	
	local ViewportPoint = workspace.CurrentCamera.ViewportSize / 2
	local CameraRay = workspace.CurrentCamera:ViewportPointToRay(ViewportPoint.X, ViewportPoint.Y, 5)
	local Position = nil
	
	castParamsLocal.FilterDescendantsInstances = {game.Workspace.Ignore, self.plr.Character}
	local Hit = CastRay(CameraRay.Origin, CameraRay.Direction * 8000, false, game.Workspace.Ignore, game.Workspace.CurrentCamera)
	local Normal

	if Hit == nil then
		Normal = nil
	else
		Normal = Hit.Normal
	end
	
	if Hit then
		Position = Hit.Position - CameraRay.Origin
	end
	
	local Cast = nil
	Cast = caster:Fire(self.WeaponModel.Muzzle.Position, (CameraRay.Origin + Position) - self.WeaponModel.Muzzle.Position, 1000, castBehaviorLocal)
	
	Cast.UserData.Shot = true
	Cast.Weapon = self.WeaponModel
	Cast.NormalData = Normal
	
	Remotes.Shoot:FireServer(self.WeaponModel)
	
	return true
end

return module
