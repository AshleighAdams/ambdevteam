include( 'api/cl_api.lua' )

concommand.Add( "dev_showresp", function(pl, cmd, args) 
	LocalPlayer():ChatPrint( GetResP( pl:Team() ) )
end)