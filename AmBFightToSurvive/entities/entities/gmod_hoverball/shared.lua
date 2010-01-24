

ENT.Type = "anim"
ENT.Base = "base_gmodentity"

ENT.PrintName		= "Hover Ball"
ENT.Author			= ""
ENT.Contact			= ""
ENT.Purpose			= ""
ENT.Instructions	= ""

ENT.Spawnable			= false
ENT.AdminSpawnable		= false

function ENT:SetupDataTables()

	self:DTVar( "Float", 0, "TargetZ" );
	self:DTVar( "Float", 1, "Speed" );

end


function ENT:GetSpeed()

	// Sensible limits in SP
	if ( !SinglePlayer() ) then return math.Clamp( self.dt.Speed, 0, 10 ) end
	
	return self.dt.Speed
	
end

function ENT:SetSpeed( s )
	
	self.dt.Speed = s
	self:UpdateLabel()
	
end

function ENT:UpdateLabel()

	self:SetOverlayText( string.format( "Speed: %i\nResistance: %.2f", self:GetSpeed(), self:GetAirResistance() ) )

end
