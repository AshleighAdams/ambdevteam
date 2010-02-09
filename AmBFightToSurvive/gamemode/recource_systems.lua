include( 'api/sv_api.lua' )

concommand.Add( "dev_giveresp", function(pl, cmd, args) 
	ammount = args[1] or 0
	GiveResP( pl:Team(), -ammount )
	pl:ConCommand("say I tryed to cheat")
end)

concommand.Add( "dev_takeresp", function(pl, cmd, args) 
	ammount = args[1] or 0
	TakeResP( pl:Team(), ammount )
end)

local f2s_crystallimit = CreateConVar( "f2s_crystallimit", 2, {FCVAR_ARCHIVE,FCVAR_NOTIFY} )
function CreateCrystals()
	crystals_wep = ents.FindByClass("resource_crystal")
	crystals_box = ents.FindByClass("resource_drop")
	Crystals = #crystals_wep + #crystals_box
	PlaceResourceDrops( math.max(0,f2s_crystallimit:GetInt() - Crystals) )
end
timer.Create( "f2s.Resources.CreateCrystals", 60*8, 0, CreateCrystals ) -- 8 mins