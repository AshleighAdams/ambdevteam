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

local f2s_crystallimit = CreateConVar( "f2s_crystallimitpercent", 200, {FCVAR_ARCHIVE,FCVAR_NOTIFY} )
function CreateCrystals()
	local crystals_wep = ents.FindByClass("resource_crystal")
	local crystals_box = ents.FindByClass("resource_drop")
	local Crystals = #crystals_wep + #crystals_box
	local max = 2 //math.Round( NumTeamsWithPlayers() * ( f2s_crystallimit:GetValue() / 100 ) )
	PlaceResourceDrops( math.max(0,max - Crystals) )
	UpdateResSWEP()
end
timer.Create( "f2s.Resources.CreateCrystals", 60*4, 0, CreateCrystals ) -- 4 mins

function crystalCalcRes(self)
	return 400 + (100*#player.GetAll())
end
hook.Add( "CalculatePresentResources", "f2s.crystalcalc", crystalCalcRes )

function NumTeamsWithPlayers()
	local teams = {}
	for _,ply in pairs( player.GetAll() ) do
		if !table.HasValue( teams,ply:Team() ) then
			table.insert( teams,ply:Team() )
		end
	end
	return ret
end