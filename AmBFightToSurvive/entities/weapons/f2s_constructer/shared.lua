
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
	Gets the entity that is being aimed at.
---------------------------------------------------------*/
function SWEP:TraceEntity()
	local owner = self.Owner
	local trace = owner:GetEyeTrace()
	return trace.Entity
end

/*---------------------------------------------------------
	PrimaryAttack
---------------------------------------------------------*/
function SWEP:PrimaryAttack()
	self.Weapon:SetNextPrimaryFire(CurTime() + 2)
	if SERVER then
		local ent = self:TraceEntity()
		if ent and ent.Registered then
			ent:Construct(self.Owner:Team())
		end
	end
end

/*---------------------------------------------------------
	Reload
---------------------------------------------------------*/
function SWEP:Reload()
	-- Build Structure
	if SERVER then
		local ent = self:TraceEntity()
		if ent and ent.Registered then
			local struct = ent:GetStructureProps()
			for _, e in pairs(struct) do
				e:Construct(self.Owner:Team())
			end
		end
	end
end

/*---------------------------------------------------------
	SecondaryAttack
---------------------------------------------------------*/
function SWEP:SecondaryAttack()
	self.Weapon:SetNextSecondaryFire( CurTime() + 2 )
	if SERVER then
		local ent = self:TraceEntity()
		if ent and ent.Registered and ent.Team and ent.Team == self.Owner:Team() then
			ent:Deconstruct()
		end
	end
end