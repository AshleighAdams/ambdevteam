SWEP.Base			= "f2s_constructer"

SWEP.Author			= "DrSchnz"
SWEP.Contact		= ""
SWEP.Purpose		= "Takes resources from props"
SWEP.Instructions	= ""

SWEP.Spawnable			= false
SWEP.AdminSpawnable		= true

--------------------------------------------
-- Initialize
--------------------------------------------
function SWEP:Initialize()
	if(SERVER) then
			self:SetWeaponHoldType("normal")
	end
	self.On = false
end

--------------------------------------------
-- PrimaryAttack
--------------------------------------------
function SWEP:PrimaryAttack()
	local target = self:Valid()
	if target then
		self.On = true
		self.Target = target
	end
end

--------------------------------------------
-- Checks for valid target and returns it if
-- valid.
--------------------------------------------
function SWEP:Valid()
	local trace = self:Trace()
	local ent = trace.Entity
	if ent and ent.Registered and ent.Constructed then
		return ent
	else
		return nil
	end
end

--------------------------------------------
-- Reload
--------------------------------------------
function SWEP:Reload()

end

--------------------------------------------
-- SecondaryAttack
--------------------------------------------
function SWEP:SecondaryAttack()

end