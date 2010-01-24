
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')

/*---------------------------------------------------------
   Name: Initialize
---------------------------------------------------------*/
function ENT:Initialize()

	self:SetModel( "models/props_lab/tpplug.mdl" )
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	
	self:DrawShadow( false )
	self:SetCollisionGroup( COLLISION_GROUP_WEAPON )
	
	local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
	end
	
end

/*---------------------------------------------------------
   Name: OnTakeDamage
---------------------------------------------------------*/
function ENT:OnTakeDamage( dmginfo )
	self:TakePhysicsDamage( dmginfo )
end


/*---------------------------------------------------------
   Numpad control functions
   These are layed out like this so it'll all get saved properly
---------------------------------------------------------*/
local function On( pl, ent )

	if ( !ent || ent == NULL ) then return false end

	pl:SetViewEntity( ent )
	pl.UsingCamera = ent
	ent.UsingPlayer = pl

end


local function On( pl, ent )

	if ( !ent || ent == NULL ) then return end
	
	if ( ent:GetToggle() ) then
		ent:SetOn( !ent:GetOn() )
	return end

	ent:SetOn( true )

end

local function Off( pl, ent )

	if ( !ent || ent == NULL ) then return end
	
	if ( ent:GetToggle() ) then return end
	
	ent:SetOn( false )

end


numpad.Register( "Emitter_On", 	On )
numpad.Register( "Emitter_Off", Off )