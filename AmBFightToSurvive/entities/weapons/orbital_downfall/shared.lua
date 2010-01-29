-- Variables that are used on both client and server
SWEP.Author			= "DrSchnz"
SWEP.Contact		= ""
SWEP.Purpose		= ""
SWEP.Instructions	= "Pwnage on any point you choose."

SWEP.Spawnable = false
SWEP.AdminSpawnable = true

SWEP.ViewModel = "models/weapons/v_pistol.mdl"
SWEP.WorldModel = "models/weapons/v_pistol.mdl"

SWEP.Category				= "SA Sweps"

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "none"

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"

local StartMarkSound = "buttons/button17.wav"
local EndMarkSound = "buttons/button18.wav"

----------------------------------------
-- Initialize 
----------------------------------------
function SWEP:Initialize()
	if(SERVER) then
		self:SetWeaponHoldType("pistol");
	end
end

----------------------------------------
-- Reload
----------------------------------------
function SWEP:Reload()

end

----------------------------------------
-- Think
----------------------------------------
function SWEP:Think()

end


----------------------------------------
-- Primary attack
----------------------------------------
function SWEP:PrimaryAttack()
	if not self:HasMark() then
		self:StartMark(self.Owner:GetEyeTrace())
	end
end

--------------------------------------------
-- Creates a marker for the orbital gun.
--------------------------------------------
function SWEP:CreateMarker(Position)
	local marker = ents.Create("orbital_marker")
	marker:SetPos(Position)
	marker:SetAngles(Angle(0, 0, 0))
	marker.FromPlayer = self.Owner
	marker.FromWeapon = self.Weapon
	marker:Spawn()
	return marker
end

--------------------------------------------
-- Called when a point begins to be marked
-- as a target. Returns true if the marking
-- was sucsessful or false otherwise.
-- Supplied with a trace of the mark to
-- start.
--------------------------------------------
function SWEP:StartMark(Trace)
	if Trace.Hit and Trace.HitWorld then
		local weap = self.Weapon
		weap:EmitSound(StartMarkSound)
		if SERVER then
			local marker = self:CreateMarker(Trace.HitPos + Vector(0, 0, 100))
		end
		return true
	end
	return false
end

--------------------------------------------
-- Gets if the weapon is already marking a
-- point.
--------------------------------------------
function SWEP:HasMark()
	return false
end

----------------------------------------
-- Secondary attack
----------------------------------------
function SWEP:SecondaryAttack()
	
end


----------------------------------------
-- Should drop on die?
----------------------------------------
function SWEP:ShouldDropOnDie()
	return false
end