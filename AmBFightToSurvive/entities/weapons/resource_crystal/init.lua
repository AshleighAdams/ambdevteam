
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include('shared.lua')


SWEP.Weight				= 1
SWEP.AutoSwitchTo		= true
SWEP.AutoSwitchFrom		= false

-----------------------------------------
---- Initialize
-----------------------------------------
function SWEP:Initialize()
	self:SetWeaponHoldType("melee");
	self.ResourcesPresent = 400
	local trail = util.SpriteTrail(self.Weapon, 0, Color(255,0,255), false, 15, 1, 4, 1/(15+1)*0.5, "trails/plasma.vmt")
end

-----------------------------------------
---- Think
-----------------------------------------
function SWEP:Think()
	self.Weapon:SetClip1(self.ResourcesPresent)
	self.Weapon:SetNWFloat("ResourcesPresent", self.ResourcesPresent)
	self.Weapon:SetNWEntity("Refinery", self.Refinery)
end

-----------------------------------------
-- Tries taking an amount of resources
-- and returns the amount taken.
-----------------------------------------
function SWEP:TakeResources(Amount)
	local resamount = self.ResourcesPresent
	if resamount < Amount then
		if self.RefineSound ~= nil then
			self.RefineSound:Stop()
		end
		self.Weapon:Remove()
		return resamount
	else
		self.ResourcesPresent = resamount - Amount
		return Amount
	end
end

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