local Delta = require(game:GetService('ReplicatedStorage'):WaitForChild('Delta'):WaitForChild('DeltaFramework'))

local Announce = {}
Announce.__index = Announce
local AnnounceQueue = {}

local TypeWriter = Delta:Get("TypeWriter")
local Color3Utils = Delta:Get("Color3Utils")
local RGBText = Delta:Get("RichTextUtils")

local Events = game.ReplicatedStorage.Events
local Functions = Events.Functions
local Remotes = Events.Remotes

local IsDisplayingAnnouncement = false

function write(Label, NewText)
	TypeWriter.typeWrite(Label, NewText, 0.01)
end

function Announce:AppendsAnnouncement(Announcer, Text, Keywords, color, Mod)
	while (IsDisplayingAnnouncement) do wait() end
	IsDisplayingAnnouncement = true
		
	local AnnouncementFrame = Delta.PlayerGui.CoreGameplayUI.Announcement
	local MainFrame = AnnouncementFrame.Main
	local NewText = nil
	local Keys = {}

	MainFrame.Text.TextColor3 = Color3.fromRGB(255,255,255)

	local Table = Text:split(" ")
	local NewKeywords = Keywords:split(" ")

	MainFrame.Text.Text = ""

	for Index,Value in pairs(NewKeywords) do
		table.insert(Keys, Value)
	end

	for i,v in pairs(Table) do
		if not table.find(Keys, v) then
			if Mod then
				NewText = RGBText:SetSpecificText(MainFrame.Text,
					{v, 255, 43, 43}
				)
			else
				NewText = RGBText:SetSpecificText(MainFrame.Text,
					{v, 255,255,255}
				)
			end

			Table[i] = NewText
		end
	end	

	for i,v in pairs(Table) do
		MainFrame.Text.Text = MainFrame.Text.Text.." "..v
	end	

	table.clear(Keys)

	Delta.TweenService:Create(AnnouncementFrame, TweenInfo.new(0.3), { Position = UDim2.new(0.5, 0,0.026, 0) }):Play()
	
	if Mod then
		NewText = RGBText:SetSpecificText(MainFrame.Title,
			{"[Announcement by: ", 255, 255, 255},
			{"[MOD] "..Announcer, 255, 43, 43},
			{"]", 255, 255, 255}
		)
	else
		NewText = RGBText:SetSpecificText(MainFrame.Title,
			{"[Announcement by: ", 255, 255, 255},
			{Announcer, 255, 68, 30},
			{"]", 255, 255, 255}
		)
	end

	MainFrame.Text.TextColor3 = color

	write(MainFrame.Title, NewText)

	delay(math.max(3, string.len(MainFrame.Text.Text) / 50), function()
		Delta.TweenService:Create(AnnouncementFrame, TweenInfo.new(0.3), { Position = UDim2.new(0.5, 0, -0.3, 0) }):Play()
		task.wait(0.4)
		IsDisplayingAnnouncement = false
	end)	
end


return Announce 
