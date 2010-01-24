
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')

local MODEL = Model( "models/props_c17/light_cagelight02_on.mdl" )

/*---------------------------------------------------------
   Name: Initialize
---------------------------------------------------------*/
function ENT:Initialize()

	self:SetModel( MODEL )
	self:PhysicsInitSphere( 4, "metal" )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	self:DrawShadow( false )
	
	local phys = self:GetPhysicsObject()
	
	if (phys:IsValid()) then
		phys:Wake()
	end
	
end


/*---------------------------------------------------------
   Name: Sets the color of the light
---------------------------------------------------------*/
function ENT:SetLightColor( r, g, b )

	self:SetVar( "lightr", r )
	self:SetVar( "lightg", g )
	self:SetVar( "lightb", b )
	
	self:SetColor( r, g, b, 255 )

end

/*---------------------------------------------------------
   Name: OnTakeDamage
---------------------------------------------------------*/
function ENT:OnTakeDamage( dmginfo )
	self:TakePhysicsDamage( dmginfo )
end


/*---------------------------------------------------------
   Name: Toggle
---------------------------------------------------------*/
function ENT:Toggle()
	
	self:SetOn( !self:GetOn() )
	
end
