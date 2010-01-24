
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include('shared.lua')

function ENT:Initialize()

	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	self:SetUseType( ONOFF_USE )
	
	self:SetOn( false )
	
end


function ENT:Use( activator, caller )

	if ( !activator:IsPlayer() ) then return end
	
	// Someone is already using this button
	if ( self.LastUser && self.LastUser:IsValid() ) then return end

	if ( self:IsOn() ) then 
	
		self:Toggle( false, activator )
		
	return end

	self:Toggle( true, activator )
	self:NextThink( CurTime() )
	
	self.LastUser = activator
	
end

function ENT:Think()

	// If the player looks away while holding down use it will stay on
	// Lets fix that..
	if ( self:IsOn() ) then 
	
		if ( !self.LastUser || 
			 !self.LastUser:IsValid() || 
			 !self.LastUser:KeyDown( IN_USE ) ) then
			
			self:Toggle( false, self.LastUser )
			self.LastUser = nil
			
		end	
		
		self:NextThink( CurTime() )
	
	end
	
	
	
end

function ENT:Toggle( bool, ply )

	local plyindex 	= self:GetPlayerIndex()
	local key 		= self:GetKey()
	
	if (bool) then
	
		numpad.Activate( ply, _, {key}, plyindex )
		self:SetOn( true )
		
	else
	
		numpad.Deactivate( ply, _, {key}, plyindex )
		self:SetOn( false )
		
	end
	
end

