if SERVER then AddCSLuaFile( "shared.lua" ) end

SWEP.Author			= "C0BRA"
SWEP.Contact		= ""
SWEP.Purpose		= "Take down transport"
SWEP.Instructions	= "Aim. Fire. Forget."

SWEP.Spawnable			= true
SWEP.AdminSpawnable		= true

SWEP.ViewModel			= "models/weapons/v_rpg.mdl"
SWEP.WorldModel			= "models/weapons/w_rpg.mdl"

if SERVER then
	SWEP.Weight				= 5
	SWEP.AutoSwitchTo		= false
	SWEP.AutoSwitchFrom		= false
else
	SWEP.PrintName			= "Stinger"			
	SWEP.Slot				= 4
	SWEP.SlotPos			= 0
	SWEP.DrawAmmo			= true
	SWEP.DrawCrosshair		= true
end

function SWEP:Initialize()
	if SERVER then
		self:SetWeaponHoldType("rpg")
	end
end

function SWEP:Reload()
end

function SWEP:Think()	
end

function SWEP:PrimaryAttack()
	if CLIENT then return end
	local ent = self.Owner:GetEyeTrace().Entity
	if !ent && !ValidEntity(ent) then return end
	self:FireMissile(nil, ent, 10, self.Owner )
end

function SWEP:FireMissile( pos, targent, aimspeed, pl )
	local missile = ents.Create( "rpg_missile" )
		missile:SetAngles( pl:EyeAngles() )
		if pos then
			missile:SetPos( pos )
		else
			missile:SetPos( pl:GetShootPos() + (pl:GetAimVector() * 10 )  )
		end
		missile:SetOwner(pl)
		missile:Activate()
		missile:Input("settimer",self.Owner,self.Owner,"4")
		missile:SetVelocity(pl:GetAimVector()*700)
	missile:Spawn()
	local tname = "rpgaim+" .. tostring( CurTime() )
	timer.Create( tname, 0.01, 0, function(as,m,t,tmr) -- aimspeed missile target timername
		if !m || !ValidEntity(m) then timer.Destroy( tmr ) return end
		
		local mpos = m:GetPos()
		local tpos = t:GetPos()
		
		local mang = m:GetAngles()
		local tang = (tpos - mpos):Angle() -- cur - targ to angle 
		
		local ang = Angle()
		
		-- we want to limit the aim speed   --- mod 360 is for math errors, when the dir goes above 360 it does not loop around. now it does
		ang.p = math.Clamp( tang.p, mang.p-as, mang.p+as ) //% 360
		ang.y = math.Clamp( tang.y, mang.y-as, mang.y+as ) % 360
		ang.r = math.Clamp( tang.r, mang.r-as, mang.r+as ) //% 360
		
		m:SetAngles( ang )
		
	end, aimspeed, missile, targent, tname)
	return missile
end

--self:TakePrimarymmo( 1 )
-- self.Weapon:SendWeaponAnim( ACT_VM_RECOIL )
--self.Owner:ViewPunch( Angle( -1, 0, 0 ) 