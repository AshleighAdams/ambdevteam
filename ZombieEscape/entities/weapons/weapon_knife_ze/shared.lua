
if ( SERVER ) then

	AddCSLuaFile( "shared.lua" )

end

if ( CLIENT ) then

	SWEP.PrintName			= "Knife"			
	SWEP.Author				= "Counter-Strike"

	SWEP.Slot				= 1
	SWEP.SlotPos			= 1
	SWEP.IconLetter			= "1"
	
	killicon.AddFont( "weapon_knife", "CSKillIcons", SWEP.IconLetter, Color( 255, 80, 0, 255 ) )

end

SWEP.HoldType			= "melee"
SWEP.Base				= "weapon_cs_base_ze"
SWEP.Category			= "Counter-Strike - Zombie Escape"
SWEP.CoolOff			= 0
SWEP.Spawnable			= true
SWEP.AdminSpawnable		= true
SWEP.ViewModelFlip		= false
SWEP.CSMuzzleFlashes	= false

SWEP.ViewModel			= "models/weapons/v_knife_t.mdl"
SWEP.WorldModel			= "models/weapons/w_knife_t.mdl"

SWEP.Weight				= 1
SWEP.AutoSwitchTo		= false
SWEP.AutoSwitchFrom		= false

SWEP.Primary.Sound			= Sound( "Weapon_Knife.Single" )
SWEP.Primary.Recoil			= 0
SWEP.Primary.Damage			= 55
SWEP.Primary.NumShots		= -1
SWEP.Primary.Cone			= 0
SWEP.Primary.ClipSize		= -1
SWEP.Primary.Delay			= 0.5
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "knife"

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "none"

SWEP.IronSightsPos 		= Vector( 5.15, -2, 2.6 )

function SWEP:Deploy()
	self:EmitSound("weapons/knife/knife_deploy1.wav")
end
