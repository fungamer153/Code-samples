local Delta = require(game:GetService('ReplicatedStorage'):WaitForChild('Delta'):WaitForChild('DeltaFramework'))
local PartFracture = Delta:Get("PartFractureModule")

local Destructables = {}
Destructables.__index = Destructables

function Destructables.new(Item)
	local Destructable = {}
	setmetatable(Destructable, Destructables)
	
	Destructable.Transparency = Item.Glass.Transparency
	Destructable.Model = Item
	Destructable.Data = Destructable.Model.Data
	
	return Destructable
end

function Destructables:DestroyItem()
	if self.Data.Type.Value == "Glass" and self.Data.Destroyed.Value == false then
		
		local Glass = self.Model:FindFirstChild("Glass")
		
		PartFracture.FracturePart(Glass)
		
		self.Data.Destroyed.Value = true
		Glass.Transparency = 1
		Glass.CanCollide = false
		
		delay(self.Data.RespawnTime.Value, function()
			for i,v in pairs(self.Model:GetChildren()) do
				if v.Name == "Shard" then
					v:Destroy()
				end
			end
			
			Glass.Transparency = self.Transparency
			Glass.BreakingPoint.Position = Vector3.new(0,0,0)
			self.Data.Destroyed.Value = false
			Glass.CanCollide = true
		end)
	end
end

return Destructables
