local UserInputService = game:GetService("UserInputService")
local Module = {}

Module.ziplining = false
local localPlayer = game.Players.LocalPlayer

local rootpart
local ziplinefolder = workspace.Ziplines
local sphere

local ZipKey = Enum.KeyCode.E

function Module:Zipline(line)
	self.ziplining = true
	local trueline = line.Parent
	local length = line.Size.X/2
	local bodyv = Instance.new("BodyVelocity")
	local frame = trueline.CFrame:ToObjectSpace(rootpart.CFrame)
	local frameC = CFrame.new(Vector3.new(frame.Position.X,-5,0))
	local velo = trueline.CFrame:vectorToObjectSpace(rootpart.Velocity)

	local function is_lining()
		frame = trueline.CFrame:ToObjectSpace(rootpart.CFrame)
		if math.abs(frame.Position.X) > length then
			return false
		else
			return true
		end
	end

	local PlayerAngleXZ = math.atan2(velo.Z, velo.X)
	bodyv.P = 500

	rootpart.Velocity = Vector3.new(0,0,0)

	if PlayerAngleXZ <= math.pi/2 and PlayerAngleXZ >= -math.pi/2 then
		bodyv.Velocity = trueline.CFrame:vectorToWorldSpace(Vector3.new(45,0,0))
	else
		bodyv.Velocity = trueline.CFrame:vectorToWorldSpace(Vector3.new(-45,0,0))
	end

	local otherbv = rootpart:FindFirstChildWhichIsA("BodyVelocity")
	if otherbv then
		print(otherbv,otherbv)
		otherbv:Destroy()
	end

	rootpart.CFrame = trueline.CFrame:ToWorldSpace(frameC)
	bodyv.Parent = rootpart
	bodyv.Name = "Zip"

	coroutine.wrap(function()
		while true do
			if not is_lining() then
				self:UnZipline()
				break
			end
			wait()
		end
	end)()
end

function Module:UnZipline()
	self.ziplining = false
	local thing = rootpart:FindFirstChild("Zip")

	if thing then
		thing:Destroy()
	end
end

function getNearestZiplinePoint()
	for i,v in pairs(sphere:GetTouchingParts()) do
		local IsZipline = v:GetAttribute("zipline")
		if IsZipline then
			return v
		end
	end
end

function Module:Start()
	rootpart = localPlayer.Character.HumanoidRootPart
	sphere = self.Services.ObjectTouch.sphere

	localPlayer.CharacterAdded:Connect(function()
		rootpart = localPlayer.Character:WaitForChild("HumanoidRootPart")
		repeat wait() until self.Services.ObjectTouch.sphere ~= nil
		sphere = self.Services.ObjectTouch.sphere
	end)

	UserInputService.InputBegan:Connect(function(t)
		if t.KeyCode == ZipKey then
			if not self.ziplining then
				if rootpart.Velocity == Vector3.new(0,0,0)then return print("Not moving")end
				local nearest = getNearestZiplinePoint()
				if nearest then
					self:Zipline(nearest)
				end
			else
				self:UnZipline()
			end
      
		elseif t.KeyCode == Enum.KeyCode.Space and Module.ziplining == true then
			self:UnZipline()
		end
	end)

	local gui = localPlayer.PlayerGui.Overlays.Ziplineable

	coroutine.wrap(function()
		while true do
			wait(0.1)
			if getNearestZiplinePoint() then
				gui.Visible = true
			else
				gui.Visible = false
			end
		end
	end)()
end



return Module
