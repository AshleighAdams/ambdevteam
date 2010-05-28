

include( 'shared.lua' )
include( 'cl_scoreboard.lua' )
include( 'cl_targetid.lua' )
include( 'cl_hudpickup.lua' )
include( 'cl_deathnotice.lua' )
include( 'cl_pickteam.lua' )
include( 'cl_voice.lua' )
include( 'game_shd.lua' )

gmod_vehicle_viewmode = CreateClientConVar( "gmod_vehicle_viewmode", "1", true, true )

/*---------------------------------------------------------
   Name: gamemode:Initialize( )
   Desc: Called immediately after starting the gamemode 
---------------------------------------------------------*/
function GM:Initialize( )

	GAMEMODE.ShowScoreboard = false
	
	surface.CreateFont( "coolvetica", 48, 500, true, false, "ScoreboardHead" )
	surface.CreateFont( "coolvetica", 24, 500, true, false, "ScoreboardSub" )
	surface.CreateFont( "Tahoma", 16, 1000, true, false, "ScoreboardText" )
	
end

/*---------------------------------------------------------
   Name: gamemode:InitPostEntity( )
   Desc: Called as soon as all map entities have been spawned
---------------------------------------------------------*/
function GM:InitPostEntity( )	
end


/*---------------------------------------------------------
   Name: gamemode:Think( )
   Desc: Called every frame
---------------------------------------------------------*/
function GM:Think( )
end

/*---------------------------------------------------------
   Name: gamemode:PlayerDeath( )
   Desc: Called when a player dies. If the attacker was
		  a player then attacker will become a Player instead
		  of an Entity. 		 
---------------------------------------------------------*/
function GM:PlayerDeath( ply, attacker )
end

/*---------------------------------------------------------
   Name: gamemode:PlayerBindPress( )
   Desc: A player pressed a bound key - return true to override action		 
---------------------------------------------------------*/
function GM:PlayerBindPress( pl, bind, down )

	// If we're driving, toggle third person view using duck
	if ( down && bind == "+duck" && ValidEntity( pl:GetVehicle() ) ) then
	
		local iVal = gmod_vehicle_viewmode:GetInt()
		if ( iVal == 0 ) then iVal = 1 else iVal = 0 end
		RunConsoleCommand( "gmod_vehicle_viewmode", iVal )
		return true
		
	end

	return false	
	
end

/*---------------------------------------------------------
   Name: gamemode:HUDShouldDraw( name )
   Desc: return true if we should draw the named element
---------------------------------------------------------*/
function GM:HUDShouldDraw( name )

	// Allow the weapon to override this
	local ply = LocalPlayer()
	if (ply && ply:IsValid()) then
	
		local wep = ply:GetActiveWeapon()
		
		if (wep && wep:IsValid() && wep.HUDShouldDraw != nil) then
		
			return wep.HUDShouldDraw( wep, name )
			
		end
		
	end

	return true;
end

/*---------------------------------------------------------
   Name: gamemode:HUDPaint( )
   Desc: Use this section to paint your HUD
---------------------------------------------------------*/
function GM:HUDPaint()
	GAMEMODE:HUDDrawTargetID()
	GAMEMODE:HUDDrawPickupHistory()
	GAMEMODE:DrawDeathNotice( 0.85, 0.04 )
end

/*---------------------------------------------------------
   Name: gamemode:HUDPaintBackground( )
   Desc: Same as HUDPaint except drawn before
---------------------------------------------------------*/
function GM:HUDPaintBackground()
end

/*---------------------------------------------------------
   Name: gamemode:CreateMove( command )
   Desc: Allows the client to change the move commands 
			before it's send to the server
---------------------------------------------------------*/
function GM:CreateMove( cmd )
end

/*---------------------------------------------------------
   Name: gamemode:CallScreenClickHook( bDown, mousecode, AimVector )
   Desc: Called when clicked on the screen, 
---------------------------------------------------------*/
function GM:CallScreenClickHook( bDown, mousecode, AimVector )

	local i = 0
	if ( bDown ) then i = 1 end
	
	// Tell the server that we clicked on the screen so it can actually do stuff.
	RunConsoleCommand( "cnc", i, mousecode, AimVector.x, AimVector.y, AimVector.z )
	
	// And let us predict it clientside
	hook.Call( "ContextScreenClick", GAMEMODE, AimVector, mousecode, bDown, LocalPlayer() )

end

/*---------------------------------------------------------
   Name: gamemode:GUIMousePressed( mousecode )
   Desc: The mouse has been pressed on the game screen
---------------------------------------------------------*/
function GM:GUIMousePressed( mousecode, AimVector )

	hook.Call( "CallScreenClickHook", GAMEMODE, true, mousecode, AimVector )

end

/*---------------------------------------------------------
   Name: gamemode:GUIMouseReleased( mousecode )
   Desc: The mouse has been released on the game screen
---------------------------------------------------------*/
function GM:GUIMouseReleased( mousecode, AimVector )

	hook.Call( "CallScreenClickHook", GAMEMODE, false, mousecode, AimVector )

end

/*---------------------------------------------------------
   Name: gamemode:GUIMouseReleased( mousecode )
   Desc: The mouse was double clicked
---------------------------------------------------------*/
function GM:GUIMouseDoublePressed( mousecode, AimVector )
	// We don't capture double clicks by default, 
	// We just treat them as regular presses
	GAMEMODE:GUIMousePressed( mousecode, AimVector )
end

/*---------------------------------------------------------
   Name: gamemode:ShutDown( )
   Desc: Called when the Lua system is about to shut down
---------------------------------------------------------*/
function GM:ShutDown( )
end


/*---------------------------------------------------------
   Name: gamemode:RenderScreenspaceEffects( )
   Desc: Bloom etc should be drawn here (or using this hook)
---------------------------------------------------------*/
function GM:RenderScreenspaceEffects()
end

/*---------------------------------------------------------
   Name: gamemode:GetTeamColor( ent )
   Desc: Return the color for this ent's team
		This is for chat and deathnotice text
---------------------------------------------------------*/
function GM:GetTeamColor( ent )

	local team = TEAM_UNASSIGNED
	if (ent.Team) then team = ent:Team() end
	return GAMEMODE:GetTeamNumColor( team )

end


/*---------------------------------------------------------
   Name: gamemode:GetTeamNumColor( num )
   Desc: returns the colour for this team num
---------------------------------------------------------*/
function GM:GetTeamNumColor( num )

	return team.GetColor( num )

end

/*---------------------------------------------------------
   Name: gamemode:OnChatTab( str )
   Desc: Tab is pressed when typing (Auto-complete names, IRC style)
---------------------------------------------------------*/
function GM:OnChatTab( str )

	local LastWord
	for word in string.gmatch( str, "%a+" ) do
	     LastWord = word;
	end
	
	if (LastWord == nil) then return str end
	
	playerlist = player.GetAll()
	
	for k, v in pairs( playerlist ) do
		
		local nickname = v:Nick()
		
		if ( string.len(LastWord) < string.len(nickname) &&
			 string.find( string.lower(nickname), string.lower(LastWord) ) == 1 ) then
				
			str = string.sub( str, 1, (string.len(LastWord) * -1) - 1)
			str = str .. nickname
			return str
			
		end		
		
	end
		
	return str;

end

/*---------------------------------------------------------
   Name: gamemode:StartChat( teamsay )
   Desc: Start Chat.
   
		 If you want to display your chat shit different here's what you'd do:
			In StartChat show your text box and return true to hide the default
			Update the text in your box with the text passed to ChatTextChanged
			Close and clear your text box when FinishChat is called.
			Return true in ChatText to not show the default chat text
			
---------------------------------------------------------*/
function GM:StartChat( teamsay )
	return false
end

/*---------------------------------------------------------
   Name: gamemode:FinishChat()
---------------------------------------------------------*/
function GM:FinishChat()
end

/*---------------------------------------------------------
   Name: gamemode:ChatTextChanged( text)
---------------------------------------------------------*/
function GM:ChatTextChanged( text )
end


/*---------------------------------------------------------
   Name: ChatText
   Allows override of the chat text
---------------------------------------------------------*/
function GM:ChatText( playerindex, playername, text, filter )

	if ( filter == "chat" ) then
		Msg( playername, ": ", text, "\n" )
	else
		Msg( text, "\n" )
	end
	
	return false

end

/*---------------------------------------------------------
   Name: 
---------------------------------------------------------*/
function GM:GetSWEPMenu()

	local columns = {}
	columns[ 1 ] = "#Name"
	columns[ 2 ] = "#Author"
	columns[ 3 ] = "#Admin"
	
	local ret = {}
	
	table.insert( ret, columns )

	local weaponlist = weapons.GetList()
	
	for k,v in pairs( weaponlist ) do
	
		if ( v.Spawnable || v.AdminSpawnable ) then
		
			local entry = {}
			entry[ 1 ] 	= v.PrintName
			entry[ 2 ] 	= v.Author
			if ( v.AdminSpawnable && !v.Spawnable ) then entry[ 3 ]  = "ADMIN ONLY" else entry[ 3 ]  = "" end
			entry[ "command" ]  = "gm_giveswep "..v.Classname
			
			table.insert( ret, entry )		
		
		end
	
	end

	return ret

end

/*---------------------------------------------------------
   Name: 
---------------------------------------------------------*/
function GM:GetSENTMenu()

	local columns = {}
	columns[ 1 ] = "#Name"
	columns[ 2 ] = "#Author"
	columns[ 3 ] = "#Admin"
	
	local ret = {}
	
	table.insert( ret, columns )

	local entlist = scripted_ents.GetList()
	
	for k,v in pairs( entlist ) do
	
		if ( v.t.Spawnable || v.t.AdminSpawnable ) then
		
			local entry = {}
			entry[ 1 ] 	= v.t.PrintName
			entry[ 2 ] 	= v.t.Author
			if ( v.t.AdminSpawnable && !v.t.Spawnable ) then entry[ 3 ]  = "ADMIN ONLY" else entry[ 3 ]  = "" end
			entry[ "command" ]  = "gm_spawnsent "..v.t.Classname
			
			table.insert( ret, entry )		
		
		end
	
	end

	return ret

end

/*---------------------------------------------------------
   Name: gamemode:PostProcessPermitted( str )
   Desc: return true/false depending on whether this post process should be allowed
---------------------------------------------------------*/
function GM:PostProcessPermitted( str )

	return true

end


/*---------------------------------------------------------
   Name: gamemode:PostRenderVGUI( )
   Desc: Called after VGUI has been rendered
---------------------------------------------------------*/
function GM:PostRenderVGUI()
end


/*---------------------------------------------------------
   Name: gamemode:GetVehicles( )
   Desc: Gets the vehicles table..
---------------------------------------------------------*/
function GM:GetVehicles()

	return vehicles.GetTable()
	
end

/*---------------------------------------------------------
   Name: gamemode:RenderScene( )
   Desc: Render the scene
---------------------------------------------------------*/
function GM:RenderScene()
end

/*---------------------------------------------------------
   Name: CalcVehicleThirdPersonView
---------------------------------------------------------*/
function GM:CalcVehicleThirdPersonView( Vehicle, ply, origin, angles, fov )

	local view = {}
	view.angles		= angles
	view.fov 		= fov
	
	if ( !Vehicle.CalcView ) then
	
		Vehicle.CalcView = {}
		
		// Try to work out the size
		local min, max = Vehicle:WorldSpaceAABB()
		local size = max - min
		
		Vehicle.CalcView.OffsetUp = size.z
		Vehicle.CalcView.OffsetOut = (size.x + size.y + size.z) * 0.33
	
	end
	
	// Offset the origin
	local Up = view.angles:Up() * Vehicle.CalcView.OffsetUp * 0.66
	local Offset = view.angles:Forward() * -Vehicle.CalcView.OffsetOut
	
	// Trace back from the original eye position, so we don't clip through walls/objects
	local TargetOrigin = Vehicle:GetPos() + Up + Offset
	local distance = origin - TargetOrigin
	
	local trace = {
					start = origin,
					endpos = TargetOrigin,
					filter = Vehicle
				  }
				  
				  
	local tr = util.TraceLine( trace ) 
	
	view.origin = origin + tr.Normal * (distance:Length() - 10) * tr.Fraction
		
	return view

end

/*---------------------------------------------------------
   Name: CalcView
   Allows override of the default view
---------------------------------------------------------*/
function GM:CalcView( ply, origin, angles, fov )
	
	local Vehicle = ply:GetVehicle()
	local wep = ply:GetActiveWeapon()

	
	if ( ValidEntity( Vehicle ) && 
		 gmod_vehicle_viewmode:GetInt() == 1 
		 /*&& ( !ValidEntity(wep) || !wep:IsWeaponVisible() )*/
		) then
		
		return GAMEMODE:CalcVehicleThirdPersonView( Vehicle, ply, origin*1, angles*1, fov )
		
	end

	local ScriptedVehicle = ply:GetScriptedVehicle()
	if ( ValidEntity( ScriptedVehicle ) ) then
	
		// This code fucking sucks.
		local view = ScriptedVehicle.CalcView( ScriptedVehicle:GetTable(), ply, origin, angles, fov )
		if ( view ) then return view end

	end

	local view = {}
	view.origin 	= origin
	view.angles		= angles
	view.fov 		= fov
	
	// Give the active weapon a go at changing the viewmodel position
	
	if ( ValidEntity( wep ) ) then
	
		local func = wep.GetViewModelPosition
		if ( func ) then
			view.vm_origin,  view.vm_angles = func( wep, origin*1, angles*1 ) // Note: *1 to copy the object so the child function can't edit it.
		end
		
		local func = wep.CalcView
		if ( func ) then
			view.origin, view.angles, view.fov = func( wep, ply, origin*1, angles*1, fov ) // Note: *1 to copy the object so the child function can't edit it.
		end
	
	end
	
	return view
	
end

/*---------------------------------------------------------
   Name: gamemode:AdjustMouseSensitivity()
   Desc: Allows you to adjust the mouse sensitivity.
		 The return is a fraction of the normal sensitivity (0.5 would be half as sensitive)
		 Return -1 to not override.
---------------------------------------------------------*/
function GM:AdjustMouseSensitivity( fDefault )

	local ply = LocalPlayer()
	if (!ply || !ply:IsValid()) then return -1 end

	local wep = ply:GetActiveWeapon()
	if ( wep && wep.AdjustMouseSensitivity ) then
		return wep:AdjustMouseSensitivity()
	end

	return -1
	
end

/*---------------------------------------------------------
   Name: gamemode:ForceDermaSkin()
   Desc: Return the name of skin this gamemode should use.
		 If nil is returned the skin will use default
---------------------------------------------------------*/
function GM:ForceDermaSkin()

	//return "example"
	return nil
	
end

/*---------------------------------------------------------
   Name: gamemode:PostPlayerDraw()
   Desc: The player has just been drawn.
---------------------------------------------------------*/
function GM:PostPlayerDraw( ply )

	
end

/*---------------------------------------------------------
   Name: gamemode:PrePlayerDraw()
   Desc: The player is just about to be drawn.
---------------------------------------------------------*/
function GM:PrePlayerDraw( ply )

	
end

/*---------------------------------------------------------
   Name: gamemode:GetMotionBlurSettings()
   Desc: Allows you to edit the motion blur values
---------------------------------------------------------*/
function GM:GetMotionBlurValues( x, y, fwd, spin )

	// fwd = 0.5 + math.sin( CurTime() * 5 ) * 0.5

	return x, y, fwd, spin
	
end


/*---------------------------------------------------------
   Name: gamemode:InputMouseApply()
   Desc: Allows you to control how moving the mouse affects the view angles
---------------------------------------------------------*/
function GM:InputMouseApply( cmd, x, y, angle )
	
	//angle.roll = angle.roll + 1	
	//cmd:SetViewAngles( Ang )
	//return true
	
end


/*---------------------------------------------------------
   Name: gamemode:OnAchievementAchieved()
---------------------------------------------------------*/
function GM:OnAchievementAchieved( ply, achid )
	
	chat.AddText( ply, Color( 230, 230, 230 ), " earned the achievement ", Color( 255, 200, 0 ), achievements.GetName( achid ) );
	
end

/*---------------------------------------------------------
   Name: gamemode:PreDrawSkyBox()
   Desc: Called before drawing the skybox. Return true to not draw the skybox.
---------------------------------------------------------*/
function GM:PreDrawSkyBox()
	
	//return true;
	
end

/*---------------------------------------------------------
   Name: gamemode:PostDrawSkyBox()
   Desc: Called after drawing the skybox
---------------------------------------------------------*/
function GM:PostDrawSkyBox()
	
end

/*---------------------------------------------------------
   Name: gamemode:PreDrawOpaqueRenderables()
   Desc: Called before drawing opaque entities
---------------------------------------------------------*/
function GM:PreDrawOpaqueRenderables( bDrawingDepth, bDrawingSkybox )
	
	//	return true;
	
end

/*---------------------------------------------------------
   Name: gamemode:PreDrawOpaqueRenderables()
   Desc: Called before drawing opaque entities
---------------------------------------------------------*/
function GM:PostDrawOpaqueRenderables( bDrawingDepth, bDrawingSkybox )
		
end

/*---------------------------------------------------------
   Name: gamemode:PreDrawOpaqueRenderables()
   Desc: Called before drawing opaque entities
---------------------------------------------------------*/
function GM:PreDrawTranslucentRenderables( bDrawingDepth, bDrawingSkybox )
	
	// return true
	
end

/*---------------------------------------------------------
   Name: gamemode:PreDrawOpaqueRenderables()
   Desc: Called before drawing opaque entities
---------------------------------------------------------*/
function GM:PostDrawTranslucentRenderables( bDrawingDepth, bDrawingSkybox )
		
end

