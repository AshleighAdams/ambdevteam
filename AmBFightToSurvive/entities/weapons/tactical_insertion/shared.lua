
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

local ShootSound = Sound( "weapons/357/357_reload1.wav" )

function SWEP:Initialize()
	if( SERVER ) then
			self:SetWeaponHoldType("grenade")
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
	local timername = "kill" .. tostring( CurTime() )
	timer.Create(timername,800,0,function(wep) wep:Fire("kill","1") end, self.Weapon)
	Owner = self.Owner
	if SERVER then Owner.SWEP = self end
	self:EmitSound( ShootSound )
	Owner:ConCommand("setspawnpoint")
	self.Weapon:SetNextPrimaryFire( CurTime() + 2 )
	
	self.Weapon:SendWeaponAnim( ACT_VM_SECONDARYATTACK )
 	self.Owner:MuzzleFlash()
 	self.Owner:SetAnimation( PLAYER_ATTACK1 )
	
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
	function taPlayerSpawn( pl )
		/*if pl.SpawnEnt != nil then
			if pl.SpawnEnt:IsValid() then 
				pl:SetPos(pl.SpawnEnt:GetPos() + Vector(0,0,16)) 
				pl.SpawnEnt:Fire("kill", "2")
				pl.SpawnEnt = nil
				//pl.Flare:Fire("Die",0.1)
			else
				pl.SpawnEnt = nil
			end
		end*/
	end
	--hook.Add("PlayerSpawn", "psti", PlayerSpawn)

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
				ent:Spawn()
				ent:Activate()
				ent:SetCollisionGroup(COLLISION_GROUP_WORLD)
				ent.Constructed = true
				local phys = ent:GetPhysicsObject()
				if phys:IsValid() then phys:EnableMotion(false) end // phys:Remove() end
			
			Flare = ents.Create("env_flare")
				Flare:SetPos( pl:GetPos() )
				Flare:SetKeyValue( "scale", "1" )
				Flare:SetKeyValue( "duration", "99999999999999" )
				Flare:SetKeyValue( "Infinite", "1" ) --Infinite
				//Flare:SetParent(ent)
				Flare:Spawn()
			Flare:Activate()
			pl.Flare = Flare

			pl.SpawnEnt = ent
			ent.IsTI = true
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