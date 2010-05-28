function NewRound()
	if CLIENT then return end
	game.CleanUpMap()
	for i,pl in pairs( player.GetAll() ) do
		pl:SetTeam( TEAM_HUMAN )
		pl:Spawn()
		pl:Lock()
		timer.Simple( 3, function(pl) pl:UnLock() end,pl)
	end
	
	timer.Create( "round_timer", 600, 1, RoundEnd)
end

function GetZombie()
	
end

function RoundEnd(winner)
	if CLIENT then return end
	if winner == TEAM_HUMAN or winner == nil then
		//humans win
	else
		//zombies win
	end
	
	timer.Remove("round_timer")
	timer.Simple( 3, NewRound )
end

timer.Simple( 10, NewRound )