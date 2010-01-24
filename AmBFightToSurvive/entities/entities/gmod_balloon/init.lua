
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include('shared.lua')

local MODEL = Model( "models/dav0r/balloon/balloon.mdl" )

/*---------------------------------------------------------
   Name: Initialize
---------------------------------------------------------*/
function ENT:Initialize()

	// Use the helibomb model just for the shadow (because it's about the same size)
	self:SetModel( MODEL )
	self:PhysicsInit( SOLID_VPHYSICS )
	
	// Set up our physics object here
	local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
	
		phys:SetMass( 100 )
		phys:Wake()
		phys:EnableGravity( false )
		
	end
	
	self:SetForce( 1 )
	self:StartMotionController()
	
end

/*---------------------------------------------------------
   Name: SetForce
---------------------------------------------------------*/
function ENT:SetForce( force )

	self.Force = force * 5000
	self:SetOverlayText( "Force: " .. math.floor( force ) )

end


/*---------------------------------------------------------
   Name: OnTakeDamage
---------------------------------------------------------*/
function ENT:OnTakeDamage( dmginfo )

	if (self.Indestructible) then 
		return 
	end
	
	local r, g, b = self:GetColor()
	
	local effectdata = EffectData()
		effectdata:SetOrigin( self:GetPos() )
		effectdata:SetStart( Vector( r, g, b ) )
	util.Effect( "balloon_pop", effectdata )
	
	
	if ( self.Explosive ) then
	
		local effectdata = EffectData()
			effectdata:SetOrigin( self:GetPos() )
			effectdata:SetScale( 1 )
			effectdata:SetMagnitude( 25 )
		util.Effect( "Explosion", effectdata, true, true )
	
	end
	
	local attacker = dmginfo:GetAttacker()
	if ( IsValid(attacker) && attacker:IsPlayer() ) then
		attacker:SendLua( "achievements.BalloonPopped()" );
	end
	
	self:Remove()
	
end


/*---------------------------------------------------------
   Name: Simulate
---------------------------------------------------------*/
function ENT:PhysicsSimulate( phys, deltatime )

	local vLinear = Vector( 0, 0, self.Force ) * deltatime
	local vAngular = Vector( 0, 0, 0 )

	return vAngular, vLinear, SIM_GLOBAL_FORCE
	
end