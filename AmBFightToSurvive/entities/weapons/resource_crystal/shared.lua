
// Variables that are used on both client and server

SWEP.Author			= "C0BRA"
SWEP.Contact		= ""
SWEP.Purpose		= ""
SWEP.Instructions	= "Place a Tactical Insertion to decide you're next spawn point"
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

function SWEP:Initialize()
	if( SERVER ) then
			self:SetWeaponHoldType("melee");
	end
	self.ResourcesPresent = 200
	local trail = util.SpriteTrail(self.Weapon, 0, Color(255,0,255), false, 15, 1, 4, 1/(15+1)*0.5, "trails/plasma.vmt")
end

/*---------------------------------------------------------
	Reload does nothing
---------------------------------------------------------*/
function SWEP:Reload()
end

function SWEP:Think()
	self.Weapon:SetClip1( self.ResourcesPresent )
	if self.ResourcesPresent < 0 then
	self.Weapon:Fire("kill", "1")
	end
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

function SWEP:TakeResources(ammount)
	
end