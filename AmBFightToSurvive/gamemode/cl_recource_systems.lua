include( 'api/cl_api.lua' )
refinery = NULL
--resource_drop

concommand.Add( "dev_showresp", function(pl, cmd, args) 
	LocalPlayer():ChatPrint( GetResP( pl:Team() ) )
end)

function GM:HUDPaint()
	local pl = LocalPlayer()
	local count = 0
	-- resource drops
	for k,v in pairs( ents.FindByClass("resource_drop") ) do
		local pos = v:GetPos():ToScreen()
		draw.WordBox( 8, pos.x, pos.y, "Capture","Default", Color(50,0,0,100), Color(255,50,50,255) )
		count = k
	end
	-- crystal carriers
	for k,v in pairs( ents.FindByClass("resource_crystal") ) do
		local pos = v:GetPos():ToScreen()
		local BoxCol = Color(50,0,0,100)
		local TextCol = Color(255,50,50,255)
		local Text = "Capture"
		
		local owner = v.Owner
		
		if ValidEntity(owner) && (pl:Team() == owner:Team()) then
			BoxCol = Color(0,50,0,100)
			TextCol = Color(50,255,50,255)
			Text = "Escort"
			for l,r in pairs( ents.FindByClass("refinery") ) do
				if r.Team == pl:Team() then
					refinery = r
				end
			end
			
			if owner == pl then
				if ValidEntity( refinery ) then
					pos = refinery:GetPos():ToScreen()
					BoxCol = Color(0,50,0,100)
					TextCol = Color(50,255,50,255)
					Text = "Refine"
					draw.WordBox( 8, pos.x, pos.y, Text,"Default", BoxCol, TextCol )
				end
				
			else
				if ValidEntity( refinery ) then
					pos = refinery:GetPos():ToScreen()
					BoxCol = Color(0,50,0,100)
					TextCol = Color(50,255,50,255)
					Text = "Refine"
					draw.WordBox( 8, pos.x, pos.y, Text,"Default", BoxCol, TextCol )
				end
				pos = owner:GetPos():ToScreen()
				BoxCol = Color(0,50,0,100)
				TextCol = Color(50,255,50,255)
				Text = "Escort"
				draw.WordBox( 8, pos.x, pos.y, Text,"Default", BoxCol, TextCol )
			end
		elseif ValidEntity( owner ) then
			pos = owner:GetPos():ToScreen()
			BoxCol = Color(0,50,0,100)
			TextCol = Color(50,255,50,255)
			Text = "Kill"
			draw.WordBox( 8, pos.x, pos.y, Text,"Default", BoxCol, TextCol )
		end
		draw.WordBox( 8, pos.x, pos.y, Text,"Default", BoxCol, TextCol )
		count = count + k
	end
	if count == 0 then
		for k,r in pairs( ents.FindByClass("refinery") ) do
			local pos = r:GetPos():ToScreen()
			local BoxCol = Color(50,0,0,100)
			local TextCol = Color(255,50,50,255)
			local Text = "Attack"
			if r.Team == pl:Team() then
				pos = r:GetPos():ToScreen()
				BoxCol = Color(0,50,0,100)
				TextCol = Color(50,255,50,255)
				Text = "Defend"
			end
			draw.WordBox( 8, pos.x, pos.y, Text,"Default", BoxCol, TextCol )
		end
		
	end
	--draw.WordBox( 8, ScrW() / 2, ScrH() / 2, "THIS IS A BOX!", "Default", Color(50,50,75,100), Color(255,255,255,255) )
	
end