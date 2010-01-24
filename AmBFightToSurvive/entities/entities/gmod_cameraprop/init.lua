
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')

local CAMERA_MODEL = Model( "models/dav0r/camera.mdl" )

/*---------------------------------------------------------
   Name: Initialize
---------------------------------------------------------*/
function ENT:Initialize()

	self:SetModel( CAMERA_MODEL )
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	self:DrawShadow( false )
	
	// Don't collide with the player
	self:SetCollisionGroup( COLLISION_GROUP_WEAPON )
	
	local phys = self:GetPhysicsObject()
	
	if ( phys:IsValid() ) then
		phys:Sleep()
	end
	
end

function ENT:SetTracking( Ent, LPos )

	if ( Ent:IsValid() ) then
	
		self:SetMoveType( MOVETYPE_NONE )
		self:SetSolid( SOLID_BBOX )
	
	else
	
		self:SetMoveType( MOVETYPE_VPHYSICS )
		self:SetSolid( SOLID_VPHYSICS )
	
	end
	
	self:NextThink( CurTime() )
	
	self.dt.entTrack = Ent
	self.dt.vecTrack = LPos

end

function ENT:Think()

	self:TrackEntity( self.dt.entTrack, self.dt.vecTrack )
	self:NextThink( CurTime() )
	
end


function ENT:SetLocked( locked )

	if ( locked == 1 ) then
	
		self.PhysgunDisabled = true
		
		local phys = self:GetPhysicsObject()
		if ( phys:IsValid() ) then
			phys:EnableMotion( false )
		end
	
	else
	
		self.PhysgunDisabled = false
	
	end
	
	self.locked = locked

end

/*---------------------------------------------------------
   Name: OnTakeDamage
---------------------------------------------------------*/
function ENT:OnTakeDamage( dmginfo )
	self:TakePhysicsDamage( dmginfo )
end

local function Toggle( player )

	local toggle = self:GetToggle()
	
	if ( player.UsingCamera && player.UsingCamera == self.Entity ) then
	
		player:SetViewEntity( player )
		player.UsingCamera = nil
		self.UsingPlayer = nil
		
	else
	
		player:SetViewEntity( self.Entity )
		player.UsingCamera = self.Entity
		self.UsingPlayer = player
		
	end
	
end

function ENT:OnRemove()

	if (self.UsingPlayer && self.UsingPlayer != NULL) then
	
		self.UsingPlayer:SetViewEntity( self.UsingPlayer )
	
	end

end


/*---------------------------------------------------------
   Numpad control functions
   These are layed out like this so it'll all get saved properly
---------------------------------------------------------*/
local function On( pl, ent )

	if (!ent || ent == NULL ) then return false end

	pl:SetViewEntity( ent )
	pl.UsingCamera = ent
	ent.UsingPlayer = pl

end

local function Off( pl, ent )

	if (!ent || ent == NULL ) then return false end

	if ( pl.UsingCamera && pl.UsingCamera == ent ) then
		pl:SetViewEntity( pl )
		pl.UsingCamera = nil
		ent.UsingPlayer = nil
	end

end

local function Toggle( pl, ent, idx, buttoned )

	// The camera was deleted or something - return false to remove this entry
	if (!ent || ent == NULL ) then return false end
	
	if ( pl.UsingCamera && pl.UsingCamera == ent ) then
		Off( pl, ent )
	else
		On( pl, ent )		
	end
	
end

// register numpad functions
numpad.Register( "Camera_On", On )
numpad.Register( "Camera_Toggle", Toggle )
numpad.Register( "Camera_Off", Off )
