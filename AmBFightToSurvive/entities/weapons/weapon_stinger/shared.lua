if SERVER then AddCSLuaFile( "shared.lua" ) end

local Targets =	{
					"env_flare",
					"wire_thruster",
					"gmod_thruster",
					"prop_vehicle_jeep_old",
					"prop_vehicle_jeep",
					"prop_vehicle_airboat_old",
					"prop_vehicle_airboat",
					"sent_sakariashelicopter",
					"prop_vehicle_prisoner_pod"
				}
SWEP.Author			= "C0BRA"
SWEP.Contact		= ""
SWEP.Purpose		= "Take down transport"
SWEP.Instructions	= "Aim. Fire. Forget."

SWEP.Spawnable			= true
SWEP.AdminSpawnable		= true

SWEP.ViewModel			= "models/weapons/v_rpg.mdl"
SWEP.WorldModel			= "models/weapons/w_rpg.mdl"

SWEP.Primary.ClipSize		= 1
SWEP.Primary.DefaultClip	= 1
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo			= "rpg"

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "none"

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
				-- play a blip or something
		--- ambient/levels/labs/teleport_alarm_loop1.wav
		--ambient/levels/labs/machine_ring_resonance_loop1.wav
		self.Beep = CreateSound(self, "ambient/levels/labs/teleport_alarm_loop1.wav")
	end
end

function SWEP:Reload()
end

function SWEP:Think()	
end

function SWEP:PrimaryAttack()
	self.Weapon:SetNextPrimaryFire(CurTime() + 2)
	if CLIENT then return end
	//local ent = self.Owner:GetEyeTrace().Entity
	//if !ent || !ValidEntity(ent) || self.Owner:GetEyeTrace().HitWorld then return end
	
	local ent = self.Targ
	
	if !ent || !ValidEntity(ent) then return end
	self:FireMissile(nil, ent, 1, self.Owner )
	self:TakePrimaryAmmo( 1 )
end

function SWEP:SecondaryAttack()
	if CLIENT then return end
	timer.Simple( 2, Targ,self)
end

function Targ(self)
	if CLIENT then return end
	if self.Owner:KeyDown(IN_ATTACK2) then
		timer.Simple( 0.5, Targ,self)
		
		targs = ents.GetAll()
		
		self.Targ = nil
		local record_dot = 0.5 ----- the furthest away from the crosshair allowed
		for _,targ in pairs( targs ) do
			local dot = self.Owner:GetAimVector():DotProduct( ( targ:GetPos() - self.Owner:GetPos() ):Normalize() )
			if dot > record_dot && Visible(self,targ) then -- closer than others   -----    1 == smak on!
				
				if table.HasValue( Targets, targ:GetClass() ) then
					
					record_dot = dot
					self.Targ = targ
					-- flares have piority and make a higher records that is rare for a prop to break
					local match_start,match_end = string.find(self.Targ:GetClass(),"flare")
					if match_start && match_end then
						record_dot = record_dot + 0.5
					end
				end
			end
		end
		
		if self.Targ then
			EmitSound( self, "ambient/levels/labs/teleport_alarm_loop1.wav", 0.5 )
			//self.Beep:Play()
		else
			//self.Beep:Stop()
		end
		
	else
		self.Targ = nil
		self.Beep:Stop()
	end
	
end

function SWEP:FireMissile( pos, targent, aimspeed, pl )
	local missile = ents.Create( "missile_rpg" )
		missile:SetAngles( pl:EyeAngles() )
		if pos then
			missile:SetPos( pos )
		else
			local wep = pl:GetActiveWeapon()
			local pos = wep:LocalToWorld(Vector(-0.04,-11.20,23.35))
			missile:SetPos( pos ) //+ (pl:GetAimVector() * 10 )  
		end
		missile:SetOwner(pl)
		missile:Activate()
		//missile:GetPhysicsObject():EnableGravity(false)
		//missile:Input("settimer",self.Owner,self.Owner,"4")
		//missile:SetVelocity(pl:GetAimVector()*700)
	missile:Spawn()
	missile:SetOwner(self.Owner)
	missile:GetPhysicsObject():EnableGravity(false)
	
	self.Weapon:SendWeaponAnim( ACT_VM_RECOIL1 )
	self.Owner:ViewPunch( Angle( -1, 0, 0 ) )
	
	local tname = "rpgaim+" .. tostring( CurTime() )
	
	timer.Create( tname, 0.01, 0, function(as,m,t,tmr) -- aimspeed missile target timername
		if !m || !ValidEntity(m) then timer.Destroy( tmr ) return end
		if ValidEntity(m) then
			
			dot = m:GetForward():DotProduct( ( t:GetPos() - m:GetPos() ):Normalize() )
			//print(dot) less than 0.5 is off target
			if dot < 0.2 || !Visible(self,t) then t = NULL end
			
			if !t || !ValidEntity(t) then return end
			
			local mpos = m:GetPos()
			local tpos = t:GetPos()
			
			local mang = m:GetAngles()
			local ang = Angle()
			
			-- we want to limit the aim speed   --- mod 360 is for math errors, when the dir goes above 360 it does not loop around. now it does
			//ang.p = math.Clamp( tang.p, mang.p-as, mang.p+as ) //% 360
			//ang.y = math.Clamp( tang.y, mang.y-as, mang.y+as ) % 360
			
			ang.p = m:GetElv( tpos )
			ang.y = m:GetBar( tpos )
			ang.r = 0 
			
			ang.p = math.Clamp( mang.p + ang.p , mang.p+as,mang.p-as ) % 360
			ang.y = math.Clamp( mang.y + ang.y , mang.y+as,mang.y-as ) % 360
			
			local vel = m:GetVelocity()
			m:SetAngles( ang )
			m:GetPhysicsObject():SetVelocity( vel )
		end
	end, aimspeed, missile, targent, tname)
	
	return missile
end

function EmitSound(  ent, sound, time )
	if !ent || !ValidEntity(ent) then return end
	local sound = CreateSound(ent, sound)
	sound:Play()
	timer.Simple( time, function(sound)
		sound:Stop()
	end,sound)
end