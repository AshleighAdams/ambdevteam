local DamageTexture = surface.GetTextureID( "amb/damageoverlay" )

function GM:HUDPaintBackground() -- thanks to DrSchnz
	Me = LocalPlayer()
	local alpha = 255 - math.Round( ( Me:Health() / 75 ) * 255 )
	if Me:Health() > 74 then alpha = 0 end
	surface.SetDrawColor( 255, 255, 255, alpha )
	surface.SetTexture( DamageTexture )
	surface.DrawTexturedRect( 0, 0, ScrW(), ScrH() )
end