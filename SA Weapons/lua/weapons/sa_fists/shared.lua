if( SERVER ) then
	AddCSLuaFile( "shared.lua" )
	resource.AddFile( "models/weapons/v_punch.mdl" )
	resource.AddFile( "models/weapons/w_fists_t.mdl" )

	SWEP.HoldType			= "fist"

	local ActIndex = {}
		ActIndex[ "fist" ]		= ACT_HL2MP_IDLE_FIST

	function SWEP:SetWeaponHoldType( t )

		local index 								= ActIndex[ t ]
			
		if (index == nil) then
			return
		end

		self.ActivityTranslate 							= {}
		self.ActivityTranslate [ ACT_HL2MP_IDLE ] 			= index
		self.ActivityTranslate [ ACT_HL2MP_WALK ] 			= index + 1
		self.ActivityTranslate [ ACT_HL2MP_RUN ] 				= index + 2
		self.ActivityTranslate [ ACT_HL2MP_IDLE_CROUCH ] 		= index + 3
		self.ActivityTranslate [ ACT_HL2MP_WALK_CROUCH ] 		= index + 4
		self.ActivityTranslate [ ACT_HL2MP_GESTURE_RANGE_ATTACK ] 	= index + 5
		self.ActivityTranslate [ ACT_HL2MP_GESTURE_RELOAD ] 		= index + 6
		self.ActivityTranslate [ ACT_HL2MP_JUMP ] 			= index + 7
		self.ActivityTranslate [ ACT_RANGE_ATTACK1 ] 			= index + 8
	
		self:SetupWeaponHoldTypeForAI( t )
	end
end

if( CLIENT ) then
	SWEP.PrintName = "Fists"
	SWEP.Slot = 3
	SWEP.SlotPos = 3
	SWEP.DrawAmmo = false
	SWEP.DrawCrosshair = false
end

SWEP.Category				= "SA Sweps"
SWEP.Author			= ".:AmB:. Nick"
SWEP.Instructions	= "Left click for a left-hand swing \nRight click for a right-hand swing."
SWEP.Contact		= ""
SWEP.Purpose		= ""

SWEP.ViewModelFOV	= 47 -- Low FOV so we can't see the un-done hand models thanks to Valve.
SWEP.ViewModelFlip	= false

SWEP.Spawnable			= true
SWEP.AdminSpawnable		= true


SWEP.ViewModel      = "models/weapons/v_punch.mdl"
SWEP.WorldModel   = "models/weapons/w_fists_t.mdl"
  
-- Primary Fire Attributes --
SWEP.Primary.Recoil			= 0
SWEP.Primary.Damage			= 0
SWEP.Primary.NumShots		= 1
SWEP.Primary.Cone			= 0
SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic   	= false	
SWEP.Primary.Ammo         	= "none"
 
-- Secondary Fire Attributes --
SWEP.Secondary.Recoil		= 0
SWEP.Secondary.Damage		= 0
SWEP.Secondary.NumShots		= 1
SWEP.Secondary.Cone			= 0
SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic   	= false
SWEP.Secondary.Ammo         = "none"

-- Various configs --
SWEP.ComboActivated			= false 
SWEP.Delay					= 0.35
SWEP.Delay2					= 0.25

function SWEP:Initialize()
	if( SERVER ) then
		self:SetWeaponHoldType( self.HoldType )
	end
	self.ComboHit = {
	Sound("physics/body/body_medium_break2.wav"),
	Sound("physics/body/body_medium_break3.wav")   }
	self.HitHuman = {
	Sound("physics/body/body_medium_impact_hard1.wav"),
	Sound("physics/body/body_medium_impact_hard3.wav"),
	Sound("physics/body/body_medium_impact_hard5.wav")	}
	
	self.HitElse = {
	Sound("physics/flesh/flesh_impact_bullet2.wav"),
	Sound("physics/flesh/flesh_impact_bullet4.wav"),
	Sound("physics/flesh/flesh_impact_bullet5.wav")   }
	
	self.Swing = {
	Sound("weapons/fists/hl2_slash1.wav"),
	Sound("weapons/fists/hl2_slash2.wav")   }
	
	self.PushElse = {
	Sound("physics/body/body_medium_impact_hard1.wav"),
	Sound("physics/body/body_medium_impact_hard2.wav"),
	Sound("physics/body/body_medium_impact_hard3.wav"),
	Sound("physics/body/body_medium_impact_hard4.wav"),
	Sound("physics/body/body_medium_impact_hard5.wav"),
	Sound("physics/body/body_medium_impact_hard6.wav")   }
	
	self.Provoke = {} -- For now, IN HL2 Version, nothing.
	
	self.QuickHittingTime		= 0
	self.ProvokeTime			= 0
end

function SWEP:Precache()
end

function SWEP:Think()

	
	if (CurTime() < self.QuickHittingTime) then -- If we can keep up the left-right hand swinging/hitting pace, then
		self.Delay 	= 0.2 -- Let us swing abit faster!
		self.Delay2	= 0.2 -- Let us swing abit faster!
	else -- Otherwise
		self.Delay	= 0.35 -- Make us swing with default speed
		self.Delay2	= 0.25 -- Make us swing with default speed
	end
	
end 

function SWEP:Deploy()
	self.Weapon:SendWeaponAnim( ACT_VM_DRAW )
	self:SetNextPrimaryFire(CurTime() + 0.7)
	self:SetNextSecondaryFire(CurTime() + 0.7)
	return true
end

function SWEP:Holster()
	return true
end

function SWEP:Reload()
	if (CurTime() < self.ProvokeTime) then return end
	self.ProvokeTime = (CurTime() + 2)
	--self.Weapon:EmitSound(self.Provoke[math.random(#self.Provoke)])
end

function SWEP:PrimaryAttack()
	local extradamage = 6 * (self:GetNWInt("Left") + self:GetNWInt("Right"))
	local trace = self.Owner:GetEyeTrace()
	local phys = trace.Entity:GetPhysicsObject()
	if trace.HitPos:Distance(self.Owner:GetShootPos()) <= 70 then -- If we're in range
		if self.ComboActivated == true then -- If we activate a Combo
			if trace.Entity:IsPlayer() or trace.Entity:IsNPC() then -- And if we hit a player or an NPC
				self.Weapon:EmitSound(self.HitHuman[math.random(#self.HitHuman)])
			else
				self.Weapon:EmitSound(self.HitElse[math.random(#self.HitElse)])
				if phys:IsValid() then
					phys:ApplyForceOffset(self.Owner:GetAimVector():GetNormalized() * math.random(5000, 7000), trace.HitPos)
				else
					if SERVER then
						trace.Entity:SetVelocity(self.Owner:GetAimVector():GetNormalized() * math.random(5000, 7000))
					end
				end
			end
			if SERVER then
				trace.Entity:TakeDamage(math.random(15, 30) + extradamage, self.Owner, self.Owner) -- Do more damage
			end
			self.Weapon:SendWeaponAnim( ACT_VM_SECONDARYATTACK ) -- Display a different animation
			timer.Simple(0.07, function() self.Owner:ViewPunch(Angle(-20, 0, 0)) end)
			self.Weapon:EmitSound(self.ComboHit[math.random(#self.ComboHit)]) -- Emit a Combo sound
			self:SetNWInt("Left", 0)
			self:SetNWInt("Right", 0)
			self.ComboActivated = false
		else -- Otherwise
			if trace.Entity:IsPlayer() or trace.Entity:IsNPC() then -- And if we hit a player or an NPC
				self.Weapon:EmitSound(self.HitHuman[math.random(#self.HitHuman)])
				self:SetNWInt("Left", self:GetNWInt("Left") + 1) -- Add 1 point to left-hand hitting combo
			else
				self.Weapon:EmitSound(self.HitElse[math.random(#self.HitElse)])
				if phys:IsValid() then
					phys:ApplyForceOffset(self.Owner:GetAimVector():GetNormalized() * math.random(5000, 7000), trace.HitPos)
				else
					if SERVER then
						trace.Entity:SetVelocity(self.Owner:GetAimVector():GetNormalized() * math.random(5000, 7000))
					end
				end
			end
			if SERVER then
				trace.Entity:TakeDamage(math.random(7, 14), self.Owner, self.Owner) -- Do less damage
			end
			self.Weapon:SendWeaponAnim( ACT_VM_PRIMARYATTACK ) -- Display a normal animation
			self.Owner:ViewPunch(Angle(-1.5, -2.0, 0))
		end
	else
		self.Weapon:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
		self.Weapon:EmitSound(self.Swing[math.random(#self.Swing)], 100, math.random(95, 105))
		self.Owner:ViewPunch(Angle(-1, -1.5, 0))
	end
	self:SetNextPrimaryFire(CurTime() + self.Delay)
	self:SetNextSecondaryFire(CurTime() + self.Delay2)
	self.QuickHittingTime = (CurTime() + 0.3)
	self.Owner:SetAnimation( PLAYER_ATTACK1 )
end 

function SWEP:SecondaryAttack()
	local extradamage = 6 * (self:GetNWInt("Left") + self:GetNWInt("Right"))
	local trace = self.Owner:GetEyeTrace()
	local phys = trace.Entity:GetPhysicsObject()
	if trace.HitPos:Distance(self.Owner:GetShootPos()) <= 70 then -- If we're in range
		if self.ComboActivated == true then -- If we activate a Combo
			if trace.Entity:IsPlayer() or trace.Entity:IsNPC() then -- And if we hit a player or an NPC
				self.Weapon:EmitSound(self.HitHuman[math.random(#self.HitHuman)])
			else
				self.Weapon:EmitSound(self.HitElse[math.random(#self.HitElse)])
				if phys:IsValid() then
					phys:ApplyForceOffset(self.Owner:GetAimVector():GetNormalized() * math.random(5000, 7000), trace.HitPos)
				else
					if SERVER then
						trace.Entity:SetVelocity(self.Owner:GetAimVector():GetNormalized() * math.random(5000, 7000))
					end
				end
				
			end
			if SERVER then
				trace.Entity:TakeDamage(math.random(15, 30) + extradamage, self.Owner, self.Owner) -- Do more damage
			end
			self.Weapon:SendWeaponAnim( ACT_VM_SECONDARYATTACK ) -- Display a different animation
			timer.Simple(0.07, function() self.Owner:ViewPunch(Angle(-20, 15, 0)) end)
			self.Weapon:EmitSound(self.ComboHit[math.random(#self.ComboHit)]) -- Emit a Combo sound
			self:SetNWInt("Left", 0)
			self:SetNWInt("Right", 0)
			self.ComboActivated = false
		else -- Otherwise
			if trace.Entity:IsPlayer() or trace.Entity:IsNPC() then -- And if we hit a player or an NPC
				self.Weapon:EmitSound(self.HitHuman[math.random(#self.HitHuman)])
				self:SetNWInt("Right", self:GetNWInt("Right") + 1) -- Add 1 point to left-hand hitting combo
			else
				self.Weapon:EmitSound(self.HitElse[math.random(#self.HitElse)])
				
				if phys:IsValid() then
					phys:ApplyForceOffset(self.Owner:GetAimVector():GetNormalized() * math.random(5000, 7000), trace.HitPos)
				else
					if SERVER then
						trace.Entity:SetVelocity(self.Owner:GetAimVector():GetNormalized() * math.random(5000, 7000))
					end
				end
			end
			if SERVER then
				trace.Entity:TakeDamage(math.random(7, 14), self.Owner, self.Owner) -- Do less damage
			end
			self.Owner:ViewPunch(Angle(-1.5, 2.0, 0))
			self.Weapon:SendWeaponAnim( ACT_VM_SECONDARYATTACK ) -- Display a normal animation
		end
	else
		self.Weapon:SendWeaponAnim( ACT_VM_SECONDARYATTACK )
		self.Weapon:EmitSound(self.Swing[math.random(#self.Swing)], 100, math.random(95, 105))
		self.Owner:ViewPunch(Angle(-1, 1.5, 0))
	end
	self:SetNextPrimaryFire(CurTime() + self.Delay2)
	self:SetNextSecondaryFire(CurTime() + self.Delay)
	self.QuickHittingTime = (CurTime() + 0.3)
	self.Owner:SetAnimation( PLAYER_ATTACK1 )
end 