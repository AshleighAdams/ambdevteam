
include('shared.lua')

ENT.RenderGroup 	= RENDERGROUP_OPAQUE

local matLight 		= Material( "sprites/light_ignorez" )
local matBeam		= Material( "effects/lamp_beam" )

function ENT:Initialize()

	self:SetOn( false )
	
end

/*---------------------------------------------------------
   Name: Draw
---------------------------------------------------------*/
function ENT:Draw()

	// Don't draw if we
	local ply = LocalPlayer()
	local wep = ply:GetActiveWeapon()
	if ( wep:IsValid() ) then 
		local weapon_name = wep:GetClass()
		if ( weapon_name == "gmod_camera" ) then return end
	end
	
	self.BaseClass.Draw( self )
	
end

/*---------------------------------------------------------
   Name: Think
---------------------------------------------------------*/
function ENT:Think()

	if ( !self:GetOn() ) then return end

	self.Delay = self.Delay or 0
	
	if ( self.Delay > CurTime() ) then return end
	self.Delay = CurTime() + self:GetDelay()

	local Effect = self:GetEffect()
	
	// Missing effect... :/
	if ( !self.Effects[ Effect ] ) then return end
	
	local Angle = self:GetAngles()
	//Angle:RotateAroundAxis( Angle:Right(), 90 )
	
	local b, e = pcall( self.Effects[ Effect ], self:GetPos() + Angle:Forward() * 12, Angle )
	
	// If there are errors..
	if (!b) then
	
		// Report the error
		Msg("Error in Emitter "..tostring(Effect).."\n -> "..tostring(e).."\n")
		
		// Remove the naughty function
		self.Effects[ Effect ] = nil
	
	end
	
	
end

/*---------------------------------------------------------
   Overridden because I want to show the name of the 
   player that spawned it..
---------------------------------------------------------*/
function ENT:GetOverlayText()

	return self:GetPlayerName()	
	
end
