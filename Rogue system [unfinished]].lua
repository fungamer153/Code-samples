local module = {}
module.__index = module

function module:AddStrike(Player)
	local SS = game:GetService('ServerScriptService')
	local RogueStrikes = SS.CoreServices.RogueSystem.RogueStrikes

	if not RogueStrikes:FindFirstChild(Player.Name) then
		local Folder = Instance.new('NumberValue')
		Folder.Name = Player.Name
		Folder.Parent = RogueStrikes
	end

	local StrikeFolder = RogueStrikes:FindFirstChild(Player.Name)

	if StrikeFolder.Value ~= 3 then
		StrikeFolder.Value = StrikeFolder.Value + 1
		StrikeFolder:SetAttribute('ExpireTime', os.time() + 600)
	end
end

return module
