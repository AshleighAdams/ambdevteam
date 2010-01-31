surface.CreateFont("Tahoma", 16, 1000, true, false, "bScoreboardText") -- Taken front from sassilization

function GM:ScoreboardShow()
	GAMEMODE.ShowScoreboard = true
end

function GM:ScoreboardHide()
	GAMEMODE.ShowScoreboard = false
end

local Mat = surface.GetTextureID( "amb/scoreboard" )

function GM:HUDDrawScoreBoard()
	if (!GAMEMODE.ShowScoreboard) then return end
	
	--   This is the main background
	local BoxSize 	= 512
	local Offset 	= BoxSize / 2
	local StartX 	= ( ScrW() / 2 ) - Offset
	local StartY	= ( ScrH() / 2 ) - Offset
	
	local hostname = GetHostName()
	local gamename = GAMEMODE.Name .. " [" .. GAMEMODE.Author .. "]"
	
	surface.SetDrawColor( 255, 255, 255, 255 )
	surface.SetTexture( Mat )
	surface.DrawTexturedRect( StartX, StartY, BoxSize, BoxSize )
	
	local ServerNameTextPos = Vector( StartX + 10, StartY + 75, 0 )
	local GamemodeNameTextPos = Vector( StartX + 10, StartY + 30, 0 )
	
	local PlayersStartY = StartY + 140
	local PlayersStartName = StartX + 10
	local PlayersStartTeamName = StartX + 280
	local PlayersStartPing = StartX + 450
	local Spacing = 20
	
	surface.SetFont( "Trebuchet24" )
	surface.SetTextColor( 200, 200, 200, 255 )
	surface.SetTextPos( ServerNameTextPos.x, ServerNameTextPos.y ) 
	surface.DrawText( hostname )
	
	surface.SetFont( "HUDNumber" )
	surface.SetTextColor( 50, 50, 50, 255 )
	surface.SetTextPos( GamemodeNameTextPos.x, GamemodeNameTextPos.y ) 
	surface.DrawText( gamename )
	
	
	surface.SetFont( "bScoreboardText" ) -- ChatFont   DefaultLarge
	surface.SetTextColor( 100, 100, 100, 255 )
	for i,pl in pairs( player.GetAll() ) do
		if pl:IsPlayer() then
			surface.SetTextColor( team.GetColor( pl:Team() ) )
			local y = (PlayersStartY + (i*Spacing))
			
			surface.SetTextPos( PlayersStartName, y ) 
			surface.DrawText( pl:GetName() )
			
			surface.SetTextPos( PlayersStartTeamName, y ) 
			surface.DrawText( team.GetName( pl:Team() ) )
			
			surface.SetTextPos( PlayersStartPing, y ) 
			surface.DrawText( pl:Ping() )
		end
	end
	local TeamInfoHeight = 512
	local TeamInfoWidth = 256
	local YSpacing = 70
	local XStart = 10
	local XIndent = 20
	StartY = ScrH()/2 - TeamInfoHeight/2
	surface.SetDrawColor( 150, 150, 150, 255 )
	surface.DrawRect(0, StartY, TeamInfoWidth, TeamInfoHeight)
	
	surface.SetFont( "Trebuchet24" )
	surface.SetTextColor( 100, 100, 100, 255 )
	surface.SetTextPos( XStart + 10, StartY + 10 ) 
	surface.DrawText( "Team Info" )
	
	surface.SetFont( "bScoreboardText" ) -- ChatFont   DefaultLarge
	for i,Team in pairs( Teams ) do
		if i > 1 then
			surface.SetTextColor( Team.Color )
			local y = (StartY + ( (i-1) * YSpacing ))
			
			surface.SetTextPos( XStart, y ) 
			surface.DrawText( Team.Name )
			
			surface.SetTextPos( XIndent, y+(Spacing) ) 
			owner = Team.Owner:Name() or "Failers" 
			surface.DrawText( owner )
			
			surface.SetTextPos( XIndent, y+(Spacing*2) ) 
			surface.DrawText( "ResP: " .. TeamsRes[i].ResP )
		end
	end
end
