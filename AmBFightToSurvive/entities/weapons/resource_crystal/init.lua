
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include('shared.lua')


SWEP.Weight				= 1
SWEP.AutoSwitchTo		= true
SWEP.AutoSwitchFrom		= false

-----------------------------------------
-- Called when this resource is starting
-- to be refined by the specified
-- refinery.
-----------------------------------------
function SWEP:BeginRefine(Refinery)
	self.RefineSound = CreateSound(self, "weapons/gauss/chargeloop.wav")
	self.RefineSound:Play()
end

-----------------------------------------
-- Called when the resource is no longer
-- being refined.
-----------------------------------------
function SWEP:EndRefine()
	self.RefineSound:Stop()
end