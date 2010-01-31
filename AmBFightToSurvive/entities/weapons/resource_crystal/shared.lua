
// Variables that are used on both client and server

SWEP.Author			= "C0BRA"
SWEP.Contact		= ""
SWEP.Purpose		= ""
SWEP.Instructions	= "Bring to a refinery to get this harvested and turned into ResPs"
SWEP.DrawAmmo			= true

SWEP.Spawnable			= false
SWEP.AdminSpawnable		= true

SWEP.ViewModel			= "models/weapons/v_grenade.mdl"
SWEP.WorldModel			= "models/weapons/w_grenade.mdl"

SWEP.Primary.ClipSize		= 200
SWEP.Primary.DefaultClip	= 200
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo			= "none"

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "none"

local ShootSound = Sound( "" )


/*---------------------------------------------------------
	Reload does nothing
---------------------------------------------------------*/
function SWEP:Reload()
end


/*---------------------------------------------------------
	PrimaryAttack
---------------------------------------------------------*/
function SWEP:PrimaryAttack()
	self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
	self.Owner:SetAnimation( PLAYER_ATTACK1 )
	self.Weapon:SendWeaponAnim( ACT_VM_HITCENTER )
	if SERVER then
		self.Owner:DropWeapon( self.Weapon )
		self.Weapon:SetNextPrimaryFire( CurTime() + 2 )
	end
end

/*---------------------------------------------------------
	SecondaryAttack
---------------------------------------------------------*/
function SWEP:SecondaryAttack()
	self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
	self.Owner:SetAnimation( PLAYER_ATTACK1 )
	self.Weapon:SendWeaponAnim( ACT_VM_HITCENTER )
	if SERVER then
		local owner = self.Owner
		self.Owner:DropWeapon( self.Weapon )
		local phys = self.Weapon:GetPhysicsObject()  
		phys:SetVelocity( owner:GetAimVector() * 2000 )
	end
end

/*---------------------------------------------------------
   Name: ShouldDropOnDie
   Desc: Should this weapon be dropped when its owner dies?
---------------------------------------------------------*/
function SWEP:ShouldDropOnDie()
	return true
end

function SWEP:HasResources(ammount)
	return ammount < self.ResourcesPresent
end