
// Variables that are used on both client and server

SWEP.Author			= "C0BRA"
SWEP.Contact		= ""
SWEP.Purpose		= ""
SWEP.Instructions	= "Place a Tactical Insertion to decide you're next spawn point"

SWEP.Spawnable			= true
SWEP.AdminSpawnable		= true

SWEP.ViewModel			= "models/weapons/v_grenade.mdl"
SWEP.WorldModel			= "models/weapons/w_grenade.mdl"

SWEP.Primary.ClipSize		= 1
SWEP.Primary.DefaultClip	= 1
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

	self:TakePrimaryAmmo( 1 )
	Owner = self.Owner
	if SERVER then Owner.SWEP = self end
	self:EmitSound( ShootSound )
	Owner:ConCommand("setspawnpoint")
	self.Owner:SetAnimation( PLAYER_ATTACK1 );
end

/*---------------------------------------------------------
	SecondaryAttack
---------------------------------------------------------*/
function SWEP:SecondaryAttack()
	
end


/*---------------------------------------------------------
   Name: ShouldDropOnDie
   Desc: Should this weapon be dropped when its owner dies?
---------------------------------------------------------*/
function SWEP:ShouldDropOnDie()
	return false
end

if SERVER then
	function PlayerSpawn( pl )
		if pl.SpawnEnt != nil then
			if pl.SpawnEnt:IsValid() then 
				pl:SetPos(pl.SpawnEnt:GetPos() + Vector(0,0,16)) 
				pl.SpawnEnt:Remove()
				pl.SpawnEnt = nil
			else
				pl.SpawnEnt = nil
			end
		end
	end
	hook.Add("PlayerSpawn", "psti", PlayerSpawn)

	function SetSpawnpoint(pl, command, args)
		if pl:IsOnGround() then
			if pl.SpawnEnt != nil then
				if pl.SpawnEnt:IsValid() then
					return false
				end
			end
			// Make a prop to show the spawn
			
			local ent = ents.Create("prop_physics")
				ent:SetModel("models/weapons/w_grenade.mdl")
				ent:SetPos( pl:GetPos() )
				//ent:SetOwner(pl)
				ent:Spawn()
				ent:Activate()
				ent:SetCollisionGroup(COLLISION_GROUP_WORLD)
			ParticleEffectAttach("selection_ring",PATTACH_ABSORIGIN_FOLLOW,ent,0)
			local phys = ent:GetPhysicsObject()
			if phys:IsValid() then phys:EnableMotion(false) end
			
			pl.SpawnEnt = ent
			ent.IsTI = true
			
			--particles/smokey
			/*
			local effectdata = EffectData()
			effectdata:SetStart( pl:GetPos() )
			effectdata:SetOrigin( pl:GetPos() )
			effectdata:SetScale( 1 )
			util.Effect( "SMOKE", effectdata )
			*/
			
			--ACT_ITEM_DROP
			--ACT_HL2MP_GESTURE_RANGE_ATTACK_GRENADE
			
			return true 
		else
				return false
		end
	end 
	concommand.Add("setspawnpoint", SetSpawnpoint)
	
	function DamageDetector( ent, inflictor, attacker, amount, dmginfo )
		if ent.IsTI == !nil then
			if dmginfo:GetDamageType() == "DMG_BULLET" || dmginfo:GetDamageType() == "DMG_BLAST" || dmginfo:GetDamageType() == "DMG_SLASH" then
				ent:Remove()
			end
		end
	end
	hook.Add( "EntityTakeDamage", "CHECKTI", DamageDetector )
	
end

function SWEP:AttackAnim()
	self.Weapon:SendWeaponAnim( ACT_VM_HITCENTER )
end 