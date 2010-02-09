local DamageTexture = surface.GetTextureID( "amb/damageoverlay" )

function GM:HUDPaintBackground() -- thanks to DrSchnz
	Me = LocalPlayer()
	if !Me:Alive() then return end
	local alpha = 255 - math.Round( ( Me:Health() / 75 ) * 255 )
	if Me:Health() > 74 then alpha = 0 end
	surface.SetDrawColor( 255, 255, 255, alpha )
	surface.SetTexture( DamageTexture )
	surface.DrawTexturedRect( 0, 0, ScrW(), ScrH() )
end

function GM:RenderScreenspaceEffects()
	local effect = {}  
	effect[ "$pp_colour_addr" ]			= 0  
	effect[ "$pp_colour_addg" ]			= 0  
	effect[ "$pp_colour_addb" ]			= 0  
	effect[ "$pp_colour_brightness" ]	= 0 //-0.5+ math.Clamp( LocalPlayer():Health() / 50, 0, 1 )
	effect[ "$pp_colour_contrast" ]		= LocalPlayer():Alive()  
	effect[ "$pp_colour_colour" ]		= math.Clamp( LocalPlayer():Health() / 75, 0, 1 )
	effect[ "$pp_colour_mulr" ]			= 0  
	effect[ "$pp_colour_mulg" ]			= 0  
	effect[ "$pp_colour_mulb" ]			= 0  
	//DrawColorModify( effect )
	if !LocalPlayer():Alive() then
		DrawMotionBlur( 0.1, 0.79, 0.05 )
	end
	
end