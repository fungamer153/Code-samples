--// Directories

local Module = {}
Module.__index = Module

local InfectedClasses = {}

--// Methods

function Module:Attack(Player)
	if Player.Team.Name ~= "Zombies" then return end
	local InfectedType = Player:GetAttribute('ZombieType')
	
	if not InfectedClasses[InfectedType] then
		InfectedClasses[InfectedType] = require(script[InfectedType])
	end
	
	InfectedClasses[InfectedType]:Attack(Player, InfectedType)
end

--// Return
return Module
