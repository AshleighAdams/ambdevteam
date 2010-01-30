include( 'api/sv_api.lua' )

concommand.Add( "dev_giveresp", function(pl, cmd, args) 
	ammount = args[1] or 0
	GiveResP( pl:Team(), ammount )
end)

concommand.Add( "dev_takeresp", function(pl, cmd, args) 
	ammount = args[1] or 0
	TakeResP( pl:Team(), ammount )
end)