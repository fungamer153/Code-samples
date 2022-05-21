local Delta = require(game:GetService("ReplicatedStorage"):WaitForChild("Delta"):WaitForChild("DeltaFramework"))

local DataStoreService = game:GetService('DataStoreService')
local PolicyService = Delta.PolicyService

local Codes = Delta:Get("Codes")

local TwitterCodes = DataStoreService:GetDataStore("TwitterCodes")

local Color3Utils = Delta:Get("Color3Utils")
local RGBText = Delta:Get("RichTextUtils")

local Events = game.ReplicatedStorage.Events
local Functions = Events.Functions
local Remotes = Events.Remotes

local Code = {}
Code.__index = Code

local result, policyInfo = pcall(function()
	return PolicyService:GetPolicyInfoForPlayerAsync(Delta.Player)
end)

function SuccessfulRedeem(Label)
	Label.Text = "Successfully redeemed!"
	Label.TextColor3 = Color3.fromRGB(92, 230, 138)
	Label.TextEditable = false

	delay(1, function()
		Label.TextEditable = true

		Label.Text = ""
		Label.TextColor3 = Color3.fromRGB(255, 255, 255)
	end)		
end

function Code:Redeem(plr, RedeemCode)
	
	local RedeemedCodes = {}
	--local CurrentData = os.date("!*t")
	
	local success, Folder = pcall(function()
		return TwitterCodes:GetAsync(plr.UserId)
	end)

	if success then
		if Folder == nil then
			RedeemedCodes = {}
		else
			RedeemedCodes = Folder
		end
	end
	
	local CodeLabel = plr.PlayerGui.MainMenuUI.Hub.Slides.Menu.RightSide.Twitter.EnterCode.Type
	
	if policyInfo.AllowedExternalLinkReferences then
		CodeLabel.Text = "Policy restriction!"
		CodeLabel.TextColor3 = Color3.fromRGB(220, 32, 32)
		CodeLabel.TextEditable = false

		delay(1, function()
			CodeLabel.TextEditable = true
			CodeLabel.Text = ""
			CodeLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
		end)	
		
		return
	end
	
	if not table.find(RedeemedCodes, RedeemCode) then
		for i,v in pairs(Codes) do
			if v.Code == RedeemCode then
				if ((os.time() >= Codes[i].StartTime) and os.time() <= Codes[i].EndTime) then
					if v.Reward == "Credits" then
						plr.TeamData.Credits.Value = plr.TeamData.Credits.Value + v.Amount

						local Notific = RGBText:SetSpecificText(CodeLabel,
							{v.Message, 244, 208, 63}
						)

						SuccessfulRedeem(CodeLabel)
						table.insert(RedeemedCodes, RedeemCode)
						game.ReplicatedStorage.Events.Remotes.UI.SendNotification:FireClient(plr, Notific)
					end
					if v.Reward == "Skin" then
						local Notific = RGBText:SetSpecificText(CodeLabel,
							{v.Message, 244, 208, 63}
						)

						SuccessfulRedeem(CodeLabel)
						table.insert(RedeemedCodes, RedeemCode)

						local Skins = shared['Data'][plr]['PlayerData']['OwnedSkins']

						if not table.find(Skins, v["Item"]) then
							table.insert(Skins, v["Item"])
						end

						Remotes.Events.GetData:FireClient(plr, Skins)

						game.ReplicatedStorage.Events.Remotes.UI.SendNotification:FireClient(plr, Notific)
					end

					local success, err = pcall(function()
						TwitterCodes:SetAsync(plr.UserId, RedeemedCodes)
					end)
					

					if success then
						print("Code successfully redeemed")
					else
						plr:Kick("Nubooster x8")
					end
				else
					CodeLabel.Text = "Code expired!"
					CodeLabel.TextColor3 = Color3.fromRGB(220, 32, 32)
					CodeLabel.TextEditable = false

					delay(1, function()
						CodeLabel.TextEditable = true
						CodeLabel.Text = ""
						CodeLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
					end)	
				end
			else
				CodeLabel.Text = "Code invalid"
				CodeLabel.TextColor3 = Color3.fromRGB(220, 32, 32)
				CodeLabel.TextEditable = false

				delay(1, function()
					CodeLabel.TextEditable = true
					CodeLabel.Text = ""
					CodeLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
				end)	
			end
		end
	else
		CodeLabel.Text = "Already redeemed!"
		CodeLabel.TextColor3 = Color3.fromRGB(220, 32, 32)
		CodeLabel.TextEditable = false

		delay(1, function()
			CodeLabel.TextEditable = true
			CodeLabel.Text = ""
			CodeLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
		end)	
	end
end

return Code
