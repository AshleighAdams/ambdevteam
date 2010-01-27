
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
	
	
	surface.SetFont( "ChatFont" )
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
	
end
