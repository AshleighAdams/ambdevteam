
include('shared.lua')

SWEP.PrintName			= "Resource Crystal"			
SWEP.Slot				= 0
SWEP.SlotPos			= 3
SWEP.DrawAmmo			= true
SWEP.DrawCrosshair		= false

local BeamMat = Material("tripmine_laser")
local BeamSize = 100

-----------------------------------------
---- Think
-----------------------------------------
function SWEP:Think()
	self.ResourcesPresent = self.Weapon:GetNWFloat("ResourcesPresent", 0.0)
	self.Refinery = self.Weapon:GetNWEntity("Refinery", nil)
end