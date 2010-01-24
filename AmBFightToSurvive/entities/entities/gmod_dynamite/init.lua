
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')

local MODEL = Model( "models/dav0r/tnt/tnt.mdl" )

/*---------------------------------------------------------
   Name: Initialize
   Desc: First function called. Use to set up your entity
---------------------------------------------------------*/
function ENT:Initialize()

	self:SetModel( MODEL )	
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )

end

/*---------------------------------------------------------
   Name: KeyValue
   Desc: Called when a keyvalue is added to us
---------------------------------------------------------*/
function ENT:Setup( damage )

	self.Damage = damage 
	
	// Wot no translation :(
	self:SetOverlayText( "Damage: " .. math.floor( self.Damage ) )
	
end

/*---------------------------------------------------------
   Name: OnTakeDamage
   Desc: Entity takes damage
---------------------------------------------------------*/
function ENT:OnTakeDamage( dmginfo )

	if ( dmginfo:GetInflictor():GetClass() == "gmod_dynamite" ) then return end
	
	self:TakePhysicsDamage( dmginfo )
	
end

function ENT:Explode( delay, ply )

	if ( !self:IsValid() ) then return end
	
	ply = ply or self.Entity
	
	local _delay = delay or 0
	
	if ( _delay == 0 ) then
	
		local radius = 300
		
	 	util.BlastDamage( self.Entity, ply, self:GetPos(), radius, self.Damage )
		
		local effectdata = EffectData()
		 effectdata:SetOrigin( self:GetPos() )
 		util.Effect( "Explosion", effectdata, true, true )
		
		if ( self.Remove ) then
			self:Remove()
			return
		end
		if ( self:GetMaxHealth() > 0 && self:Health() <= 0 ) then self:SetHealth( self:GetMaxHealth() ) end
		
	else
	
		timer.Simple( delay, self.Explode, self, 0, ply )
		
	end
	
end


