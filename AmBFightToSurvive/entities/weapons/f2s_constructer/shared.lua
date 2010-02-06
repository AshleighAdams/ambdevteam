
// Variables that are used on both client and server

SWEP.Author			= "C0BRA"
SWEP.Contact		= ""
SWEP.Purpose		= ""
SWEP.Instructions	= "Please note that constructed props cannot be moved with the physgun!"

SWEP.Spawnable			= true
SWEP.AdminSpawnable		= true

SWEP.ViewModel	= ""
SWEP.WorldModel = ""

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo			= "none"

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "none"

local ShootSound = Sound( "" )

function SWEP:Initialize()
	if( SERVER ) then
			self:SetWeaponHoldType("normal");
	end
end

/*---------------------------------------------------------
	Reload does nothing
---------------------------------------------------------*/
function SWEP:Reload()
end

/*---------------------------------------------------------
   Think does nothing
---------------------------------------------------------*/
function SWEP:Think()	
end


/*---------------------------------------------------------
	PrimaryAttack
---------------------------------------------------------*/
function SWEP:PrimaryAttack()
	self.Weapon:SetNextPrimaryFire(CurTime() + 2)
	if SERVER then
		local owner = self.Owner
		local trace = owner:GetEyeTrace()
		local ent = trace.Entity
		if ent and ent:IsValid() and ent:GetClass() == "prop_physics" then
			if not ent.Registered then
				RegisterProp(ent)
			end
			ent:Construct(owner:Team())
		end
	end
end

/*---------------------------------------------------------
	SecondaryAttack
---------------------------------------------------------*/
function SWEP:SecondaryAttack()
	self.Weapon:SetNextSecondaryFire( CurTime() + 2 )
	if SERVER then
		local owner = self.Owner
		local trace = owner:GetEyeTrace()
		local ent = trace.Entity
		if ent and ent:IsValid() and ent:GetClass() == "prop_physics" then
			if not ent.Registered then
				RegisterProp(ent)
			end
			if ent.Team and ent.Team == owner:Team() then
				ent:Deconstruct()
			end
		end
	end
end