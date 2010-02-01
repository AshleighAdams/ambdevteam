include( 'api/cl_api.lua' )
refinery = NULL
--resource_drop

concommand.Add( "dev_showresp", function(pl, cmd, args) 
	LocalPlayer():ChatPrint( GetResP( pl:Team() ) )
end)

function DrawBox( x, y, text, isgood )
	local colbg,colfg = Color(100,50,0),Color(255,100,0)
	if isgood then
		colbg,colfg = Color(0,50,0,100), Color(50,255,50,255)
	else
		colbg,colfg = Color(50,0,0,100), Color(255,50,50,255)
	end
	
	-- Make it stay on screen always
	BoxSize = Vector( ScrW()/16, ScrH()/16, 0 )
	local Scrw = ScrW() - BoxSize.x
	local Scrh = ScrH() - BoxSize.y
	
	x = math.Clamp( x, 25, Scrw )
	y = math.Clamp( y, 25, Scrh )
	
	draw.WordBox( 8, x, y, text,"Default", colbg, colfg )
end

function f2sHUDPaintBackground()
	local pl = LocalPlayer()
	local count = 0
	local good = false
	-- resource drops
	for k,v in pairs( ents.FindByClass("resource_drop") ) do
		local pos = v:GetPos():ToScreen()
		DrawBox(pos.x, pos.y, "Capture", false)
		count = k
	end
	-- crystal carriers
	for k,v in pairs( ents.FindByClass("resource_crystal") ) do
		local pos = v:GetPos():ToScreen()
		local BoxCol = Color(50,0,0,100)
		local TextCol = Color(255,50,50,255)
		local Text = "Capture"
		local owner = v.Owner
		pl.HasCrystal = false
		
		if ValidEntity(owner) && (pl:Team() == owner:Team()) then
			for l,r in pairs( ents.FindByClass("refinery") ) do
				if r.Team == pl:Team() then
						good = true
						refinery = r
						if owner == pl then                            ---- were holding the refinery
							if ValidEntity( refinery ) then
								pl.HasCrystal = true
								pos = refinery:GetPos():ToScreen()
								Text = "Refine"
								DrawBox( pos.x, pos.y, Text, good )
							end
						else
							if ValidEntity( refinery ) then
							pos = refinery:GetPos():ToScreen()
							Text = "Escort To"
							DrawBox( pos.x, pos.y, Text, good )
						end
						if !pl.HasCrystal then
							pos = owner:GetPos():ToScreen()
							Text = "Escort"
							DrawBox( pos.x, pos.y, Text, good )
						end
					end
				end
			end
			
		elseif ValidEntity( owner ) then
			good = false
			pos = owner:GetPos():ToScreen()
			Text = "Kill"
			DrawBox( pos.x, pos.y, Text, good )
		end
		DrawBox( pos.x, pos.y, Text, good )
		count = count + k
	end
	if count == 0 then
		for k,r in pairs( ents.FindByClass("refinery") ) do
			local pos = r:GetPos():ToScreen()
			local Text = "Attack"
			good = false
			if r.Team == pl:Team() then
				pos = r:GetPos():ToScreen()
				good = true
				Text = "Defend"
			end
			DrawBox( pos.x, pos.y, Text, good )
		end
		
	end
	--draw.WordBox( 8, ScrW() / 2, ScrH() / 2, "THIS IS A BOX!", "Default", Color(50,50,75,100), Color(255,255,255,255) )
	
end
hook.Add( "HUDPaintBackground", "f2s.HUD.Paint", f2sHUDPaintBackground )