
local matLight 		= Material( "sprites/light_ignorez" )
local matBeam		= Material( "effects/lamp_beam" )

ENT.RenderGroup 	= RENDERGROUP_TRANSLUCENT

include('shared.lua')

function ENT:Initialize()

	self.PixVis = util.GetPixelVisibleHandle()
	
end

/*---------------------------------------------------------
   Name: Draw
---------------------------------------------------------*/
function ENT:Draw()

	self.BaseClass.Draw( self, true )
	
end

/*---------------------------------------------------------
   Name: Think
---------------------------------------------------------*/
function ENT:Think()

	if ( !self:GetOn() ) then return end

	local dlight = DynamicLight( self:EntIndex() )
	if ( dlight ) then
		local r, g, b, a = self:GetColor()
		dlight.Pos = self:GetPos()
		dlight.r = r
		dlight.g = g
		dlight.b = b
		dlight.Brightness = self:GetBrightness()
		dlight.Decay = self:GetLightSize() * 5
		dlight.Size = self:GetLightSize()
		dlight.DieTime = CurTime() + 1
	end
	
end

/*---------------------------------------------------------
   Name: DrawTranslucent
   Desc: Draw translucent
---------------------------------------------------------*/
function ENT:DrawTranslucent()
	
	self.BaseClass.DrawTranslucent( self, true )
	
	local LightPos = self:GetPos()
	render.SetMaterial( matLight )
	
	local ViewNormal = self:GetPos() - EyePos()
	local Distance = ViewNormal:Length()
	ViewNormal:Normalize()

	local r, g, b, a = self:GetColor()
		
	local Visibile	= util.PixelVisible( LightPos, 4, self.PixVis )	
	
	if (!Visibile) then return end
	
	if ( !self:GetOn() ) then 
	
		render.DrawSprite( LightPos, 16, 16, Color(40, 40, 40, 255 * Visibile) )
	
	return end
	
	local Alpha = 255
	
	render.DrawSprite( LightPos, 8, 8, Color(255, 255, 255, Alpha), Visibile )
	render.DrawSprite( LightPos, 8, 8, Color(255, 255, 255, Alpha), Visibile )
	render.DrawSprite( LightPos, 8, 8, Color(255, 255, 255, Alpha), Visibile )
	render.DrawSprite( LightPos, 32, 32, Color( r, g, b, 64 ), Visibile )

	
end

/*---------------------------------------------------------
   Overridden because I want to show the name of the 
   player that spawned it..
---------------------------------------------------------*/
function ENT:GetOverlayText()

	return self:GetPlayerName()	
	
end
