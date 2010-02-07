AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include('shared.lua')

SWEP.Weight				= 5
SWEP.AutoSwitchTo		= false
SWEP.AutoSwitchFrom		= false

local ReclaimRate = 1.0

--------------------------------------------
-- Think
--------------------------------------------
function SWEP:Think()
	local curtime = CurTime()
	local lastthink = self.LastThinkTime or curtime
	local updatetime = curtime - lastthink
	self.LastThinkTime = curtime
	
	-- Check if on
	if self.On then
		if self.Owner:KeyDown(IN_ATTACK) then
			-- Check if valid
			local ent = self:Valid()
			if ent == self.Target and ent and self:Trace().Entity == ent and ent:IsValid() then
				-- Steal resps
				local transfer = ReclaimRate * updatetime
				ent.ResNeeded = ent.ResNeeded + transfer
				GiveResP(self.Owner:Team(), transfer)
				if ent.ResNeeded + 1.0 > ent.Cost then
					-- GONE!
					self.On = false
					ent:Deconstruct()
				end
			else
				self.On = false
			end
		else
			self.On = false
		end
	end

	self:SetNWBool("On", self.On)
end