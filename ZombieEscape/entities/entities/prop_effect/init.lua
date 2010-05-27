
include('shared.lua')
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

/*---------------------------------------------------------
   Name: Initialize
---------------------------------------------------------*/
function ENT:Initialize()

	self.AttachedEntity = ents.Create( "prop_dynamic" )
		self.AttachedEntity:SetModel( self:GetModel() )
		self.AttachedEntity:SetAngles( self:GetAngles() )
		self.AttachedEntity:SetPos( self:GetPos() )
		self.AttachedEntity:SetSkin( self:GetSkin() )
	self.AttachedEntity:Spawn()
	self.AttachedEntity:SetParent( self.Entity )
	self.AttachedEntity:DrawShadow( false )
	
	self.Entity:DeleteOnRemove( self.AttachedEntity )

	self.Entity:SetModel( "models/props_junk/watermelon01.mdl" )

	local min = Vector() * -2
	local max = Vector() * 2
	
	// Don't use the model's physics - create a sphere instead
	self.Entity:PhysicsInitBox( min, max )
	
	// Set up our physics object here
	local phys = self.Entity:GetPhysicsObject()
	if (phys:IsValid()) then
	
		phys:Wake()
		phys:EnableGravity( false )
		phys:EnableDrag( false )
		
	end
	
	// Set collision bounds exactly
	self.Entity:SetCollisionBounds( min, max )
	self.Entity:DrawShadow( false )
	self.Entity:SetCollisionGroup( COLLISION_GROUP_WEAPON )
	
end


/*---------------------------------------------------------
   Name: PhysicsUpdate
---------------------------------------------------------*/
function ENT:PhysicsUpdate( physobj )

	// Don't do anything if the player isn't holding us
	if ( !self.Entity:IsPlayerHolding() && !self.Entity:IsConstrained() ) then
		
		physobj:SetVelocity( Vector(0,0,0) )
		physobj:Sleep()
		
	end

end


/*---------------------------------------------------------
   Name: Called after entity 'copy'
---------------------------------------------------------*/
function ENT:OnEntityCopyTableFinish( tab )

	// We need to store the model of the attached entity
	// Not the one we have here.
	tab.Model = self.AttachedEntity:GetModel()

end

