// All the game logic (most)


if (SERVER) then

	AddCSLuaFile( "shared.lua" )
	SWEP.Weight				= 5
	SWEP.AutoSwitchTo		= false
	SWEP.AutoSwitchFrom		= false
	
	SWEP.HitE = { 
		Sound( "weapons/knife/knife_hitwall1.wav" )
	}
	SWEP.FleshHit = {
		Sound( "weapons/knife/knife_hit1.wav" ),
		Sound( "weapons/knife/knife_hit2.wav" ),
		Sound( "weapons/knife/knife_hit3.wav" ),
		Sound( "weapons/knife/knife_hit4.wav" )
	}
	SWEP.Slash = {
		Sound("weapons/knife/knife_slash1.wav"),
		Sound("weapons/knife/knife_slash2.wav")
	}
end

if ( CLIENT ) then

	SWEP.DrawAmmo			= true
	SWEP.DrawCrosshair		= false
	SWEP.ViewModelFOV		= 82
	SWEP.ViewModelFlip		= true
	SWEP.CSMuzzleFlashes	= true
	
	// This is the font that's used to draw the death icons
	surface.CreateFont( "csd", ScreenScale( 30 ), 500, true, true, "CSKillIcons" )
	surface.CreateFont( "csd", ScreenScale( 60 ), 500, true, true, "CSSelectIcons" )

end

SWEP.Author			= "Counter-Strike (Edit: C0BRA)"
SWEP.Contact		= ""
SWEP.Purpose		= ""
SWEP.Instructions	= ""

// Note: This is how it should have worked. The base weapon would set the category
// then all of the children would have inherited that.
// But a lot of SWEPS have based themselves on this base (probably not on purpose)
// So the category name is now defined in all of the child SWEPS.
//SWEP.Category			= "Counter-Strike"

SWEP.Spawnable			= false
SWEP.AdminSpawnable		= false

SWEP.Primary.Sound			= Sound( "Weapon_AK47.Single" )
SWEP.Primary.Recoil			= 1.5
SWEP.CoolOff 				= 1
SWEP.RecoilMulti 			= 0
SWEP.LastShot				= 0
SWEP.NextReduceTime			= 0
SWEP.Primary.Damage			= 40
SWEP.Primary.NumShots		= 1
SWEP.Primary.Cone			= 0.02
SWEP.Primary.Delay			= 0.15

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo			= "none"

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "none"




/*---------------------------------------------------------
---------------------------------------------------------*/
function SWEP:Initialize()

	if ( SERVER ) then
		self:SetNPCMinBurst( 30 )
		self:SetNPCMaxBurst( 30 )
		self:SetNPCFireRate( 0.01 )
	end
	
	self:SetWeaponHoldType( self.HoldType )
	self.Weapon:SetNetworkedBool( "Ironsights", false )
	
end


/*---------------------------------------------------------
	Reload does nothing
---------------------------------------------------------*/
function SWEP:Reload()
	self.Weapon:DefaultReload( ACT_VM_RELOAD );
	self:SetIronsights( false )
end


/*---------------------------------------------------------
   Think does nothing
---------------------------------------------------------*/
function SWEP:Think() // forumular to set the recoil on the gun dynamicly
	if SERVER and self.LastShot + self.CoolOff < CurTime() then
		if(CurTime()>self.NextReduceTime) then
			self.RecoilMulti = math.max(0,  self.RecoilMulti - (self.CoolOff/10)  )
			self.NextReduceTime = CurTime() + self.Primary.Delay
			self:SetNWFloat( "RecoilMulti", self.RecoilMulti )
			if(CurTime()>self.LastShot+5) then
				self.Weapon:SendWeaponAnim(ACT_VM_IDLE)
			end
		end
	end
	if SERVER then
		//self.Owner:ChatPrint(tostring( self:GetRecoilModi() ))
	end
end

function SWEP:GetRecoilModi()
	local ret = 0
	if CLIENT then
		ret = self:GetNWFloat( "RecoilMulti" )
	else
		ret = self.RecoilMulti
	end
	
	if (self.Owner:Crouching()) then
		ret = ret - 0.3
	end
	if not self.Owner:IsOnGround() then
		ret = ret + 2
	end
	if self.Owner:GetVelocity():Length() > 150 then
		local vel_over = self.Owner:GetVelocity():Length() - 150
		ret = ret + (vel_over/200)
	end
	
	// Returns for shotgun
	if self.Primary.Ammo == "buckshot" then
		return 0.2
	end
	
	return math.max( 0, ret )
end

/*---------------------------------------------------------
	PrimaryAttack
---------------------------------------------------------*/
function SWEP:PrimaryAttack()

	self.Weapon:SetNextSecondaryFire( CurTime() + self.Primary.Delay )
	self.Weapon:SetNextPrimaryFire( CurTime() + self.Primary.Delay )
	
	if self.Primary.Ammo == "knife" then
		
	else
		if ( !self:CanPrimaryAttack() ) then return end
		// Play shoot sound
		self.Weapon:EmitSound( self.Primary.Sound )
	end
	
	// Shoot the bullet
	self:CSShootBullet( self.Primary.Damage, self.Primary.Recoil, self.Primary.NumShots, self.Primary.Cone )
	
	// Remove 1 bullet from our clip
	self:TakePrimaryAmmo( 1 )
	
	if ( self.Owner:IsNPC() ) then return end
	
	// Punch the player's view
	self.Owner:ViewPunch( Angle(-0.1,0,0) )
	
	// In singleplayer this function doesn't get called on the client, so we use a networked float
	// to send the last shoot time. In multiplayer this is predicted clientside so we don't need to 
	// send the float.
	self.RecoilMulti = math.min(1,  self.RecoilMulti + (self.CoolOff/10)  )
	self:SetNWFloat( "RecoilMulti", self.RecoilMulti )
	self.LastShot = CurTime()
	if ( (SinglePlayer() && SERVER) || CLIENT ) then
		self.Weapon:SetNetworkedFloat( "LastShootTime", CurTime() )
		self.Weapon:SendWeaponAnim(ACT_VM_IDEL)
	end
	
end

/*---------------------------------------------------------
   Name: SWEP:PrimaryAttack( )
   Desc: +attack1 has been pressed
---------------------------------------------------------*/
function SWEP:CSShootBullet( dmg, recoil, numbul, cone )

	numbul 	= numbul 	or 1
	cone 	= cone 		or 0.01

	local bullet = {}
	bullet.Num 		= numbul
	bullet.Src 		= self.Owner:GetShootPos()			// Source
	bullet.Dir 		= self.Owner:GetAimVector() + Vector(0,0,self:GetRecoilModi()/50)			// Dir of bullet
	bullet.Spread 	= Vector( cone, cone, 0 )*(self:GetRecoilModi()*2)			// Aim Cone
	bullet.Tracer	= 0									// Show a tracer on every x bullets 
	bullet.Force	= 5									// Amount of force to give to phys objects
	bullet.Damage	= dmg
	
	if self.Primary.Ammo == "knife" then
		local trace_hitpos = self.Owner:GetEyeTrace().HitPos
		local distance = ( trace_hitpos - self.Owner:GetShootPos() ):Length()
		bullet.Spread = Vector(0,0,0)
		if distance < 75 then
			self.Weapon:SendWeaponAnim( ACT_VM_HITCENTER )    	// knife anims
			self.Owner:FireBullets( bullet )
			if SERVER then
				local hit_ent  = self.Owner:GetEyeTrace().Entity
				if( hit_ent:IsPlayer() or hit_ent:IsNPC() or hit_ent:GetClass()=="prop_ragdoll" ) then // ripped a bit from http://www.garrysmod.org/downloads/?a=view&id=25357 (cba todo myself)
					self.Owner:EmitSound( self.FleshHit[math.random(1,#self.FleshHit)] )
				else
					self.Owner:EmitSound( self.HitE[math.random(1,#self.HitE)] )
				end
					self.Weapon:EmitSound( self.Slash[ math.random(1,#self.Slash)] )
			end
		else
			self.Weapon:SendWeaponAnim( ACT_VM_MISSCENTER )   	// knife anims
		end
	else
		self.Owner:FireBullets( bullet )
	end
	
	self.Weapon:SendWeaponAnim( ACT_VM_PRIMARYATTACK ) 		// View model animation
	self.Owner:MuzzleFlash()								// Crappy muzzle light
	self.Owner:SetAnimation( PLAYER_ATTACK1 )				// 3rd Person Animation
	
	if ( self.Owner:IsNPC() ) then return end
	
	// CUSTOM RECOIL !
	if ( (SinglePlayer() && SERVER) || ( !SinglePlayer() && CLIENT && IsFirstTimePredicted() ) ) then
	
		//local eyeang = self.Owner:EyeAngles()
		//eyeang.pitch = eyeang.pitch - recoil
		//self.Owner:SetEyeAngles( eyeang )
	
	end

end


/*---------------------------------------------------------
	Checks the objects before any action is taken
	This is to make sure that the entities haven't been removed
---------------------------------------------------------*/
function SWEP:DrawWeaponSelection( x, y, wide, tall, alpha )
	
	draw.SimpleText( self.IconLetter, "CSSelectIcons", x + wide/2, y + tall*0.2, Color( 255, 210, 0, 255 ), TEXT_ALIGN_CENTER )
	
	// try to fool them into thinking they're playing a Tony Hawks game
	draw.SimpleText( self.IconLetter, "CSSelectIcons", x + wide/2 + math.Rand(-4, 4), y + tall*0.2+ math.Rand(-14, 14), Color( 255, 210, 0, math.Rand(10, 120) ), TEXT_ALIGN_CENTER )
	draw.SimpleText( self.IconLetter, "CSSelectIcons", x + wide/2 + math.Rand(-4, 4), y + tall*0.2+ math.Rand(-9, 9), Color( 255, 210, 0, math.Rand(10, 120) ), TEXT_ALIGN_CENTER )
	
end

local IRONSIGHT_TIME = 0.25

/*---------------------------------------------------------
   Name: GetViewModelPosition
   Desc: Allows you to re-position the view model
---------------------------------------------------------*/
function SWEP:GetViewModelPosition( pos, ang )

	return pos, ang
end


/*---------------------------------------------------------
	SetIronsights
---------------------------------------------------------*/
function SWEP:SetIronsights( b )

	self.Weapon:SetNetworkedBool( "Ironsights", false )

end


SWEP.NextSecondaryAttack = 0
/*---------------------------------------------------------
	SecondaryAttack
---------------------------------------------------------*/
function SWEP:SecondaryAttack()

	
end

/*---------------------------------------------------------
	DrawHUD
	
	Just a rough mock up showing how to draw your own crosshair.
	
---------------------------------------------------------*/
function SWEP:DrawHUD()

	// No crosshair when ironsights is on
	if ( self.Weapon:GetNetworkedBool( "Ironsights" ) ) then return end

	local x, y

	// If we're drawing the local player, draw the crosshair where they're aiming,
	// instead of in the center of the screen.
	if ( self.Owner == LocalPlayer() && self.Owner:ShouldDrawLocalPlayer() ) then

		local tr = util.GetPlayerTrace( self.Owner )
		tr.mask = ( CONTENTS_SOLID|CONTENTS_MOVEABLE|CONTENTS_MONSTER|CONTENTS_WINDOW|CONTENTS_DEBRIS|CONTENTS_GRATE|CONTENTS_AUX )
		local trace = util.TraceLine( tr )
		
		local coords = trace.HitPos:ToScreen()
		x, y = coords.x, coords.y

	else
		x, y = ScrW() / 2.0, ScrH() / 2.0
	end
	
	local scale = 10 * self.Primary.Cone
	
	// Scale the size of the crosshair according to how long ago we fired our weapon
	local LastShootTime = self.Weapon:GetNetworkedFloat( "LastShootTime", 0 )
	scale = scale * (2 - math.Clamp( (CurTime() - LastShootTime) * 5, 0.0, 1.0 ))
	
	surface.SetDrawColor( 0, 255, 0, 255 )
	
	// Draw an awesome crosshair
	local gap = 40 * scale
	local length = gap + 20 * scale
	surface.DrawLine( x - length, y, x - gap, y )
	surface.DrawLine( x + length, y, x + gap, y )
	surface.DrawLine( x, y - length, x, y - gap )
	surface.DrawLine( x, y + length, x, y + gap )

end

/*---------------------------------------------------------
	onRestore
	Loaded a saved game (or changelevel)
---------------------------------------------------------*/
function SWEP:OnRestore()
	self.RecoilModi = 0
	self.LastShot = CurTime()
	self.NextSecondaryAttack = 0
	self:SetIronsights( false )
end
