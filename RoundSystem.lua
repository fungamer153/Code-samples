local Nexus = require(game:GetService("ReplicatedStorage").Nexus.NexusInit):Init()

local roundSystem = {}
roundSystem.__index = roundSystem

shared.Survivors = {}
shared.Zombies = {}

local runService = game:GetService("RunService")

function roundSystem.new()
	local self = {}
	setmetatable(self, roundSystem)
	
	self._roundTime = 0 -- In minutes
	self._secondsRemaining = 0
	self._currentTime = 0 -- In seconds
	
	self._roundResult = "Intermission"
	self._winningTeam = nil
	self._stop = false
	
	self._function = nil
	
	return self
end

function roundSystem:Play(funcToPlay, funcParameters)
	local Module = nil
	
	self._function = function() -- functionsToPlay = {_function, _parameters}
		Module = Nexus:Require(funcToPlay)
		
		local lastTick = tick()
		local matchOver = false
		
		self._winningTeam = nil
		self._stop = false	
		self._roundTime = Module['_roundTime']
		
		if funcToPlay ~= "Intermission" then
			self._roundResult = "On-going"
			self._currentTime = 0
			
			while true do		
				task.wait(1)

				if self._stop then
					self._stop = false
					break 
				end

				if self._roundResult == "Round over" and self._winningTeam then
					break
				end

				local deltaTime = tick() - lastTick	
				local finalTime = self._roundTime * 60

				self._currentTime += 1
				self._secondsRemaining = math.round(finalTime - self._currentTime)
				
				if self._roundResult ~= "Intermission" then
					if self._currentTime > finalTime then
						matchOver = true
						self._winningTeam = "Survivors"
						self._roundResult = "Round over"		
						break
					elseif #shared.Survivors <= 0 then
						matchOver = true
						self._winningTeam = "Zombies"
						self._roundResult = "Round over"					
						break
					end
				end

				lastTick = tick()
			end
		end
	end	
	
	task.spawn(self._function)
	
	--if funcToPlay ~= "Intermission" then
	--	repeat wait() until Module		
	--end
	if Module['CustomFunction'] then
		Module._function()
	end
end

function roundSystem:Pause()
	self._stop = true
end

function roundSystem:Destroy()
	self:Pause()
	for index, value in next, self do
		self[index] = nil
	end
	setmetatable(self, nil)
	self = nil
end

return roundSystem
