next_map_in_x_rounds = 10
round_start = 0
round_end = false
PLY = _R.Entity

function NewRound()
	round_end = false
	round_start = CurTime()
	
	next_map_in_x_rounds = next_map_in_x_rounds -1
	//  We need to clean up and reset the map
	game.CleanUpMap()
	if SERVER then
		for i,pl in pairs( player.GetAll() ) do
			pl:SetTeam( TEAM_HUMAN )
			pl:Spawn()
			pl:Lock()
			timer.Simple( 3, function(pl) pl:UnLock() end,pl)
		end
	end
	
	timer.Simple( 10, GetZombie )
	
	timer.Create( "round_timer", 600, 1, RoundEnd)
end

function GetZombie()
	if CLIENT then return end
	local plys = {}									// the valid players
	for k,ply in pairs( player.GetAll() ) do	// loop through
		if ply:Team() == TEAM_HUMAN then		// add only ones who are humans
			table.Add( plys, ply )				// add them in
		end
	end
	
	// now select one randomly and remove his weapons then give him a knife
	local rnd = math.Round( math.Rand( 1, #plys ) )
	local pl = plys[rnd]
	if #plys < 2 then
		timer.Create( "wfmp", 5,0, WaitForMorePeople )
		return false
	end
	pl:SetZombie()
end

function PLY:SetZombie()
	if !ValidEntity(self) or !self:IsPlayer() then return end	// make sure there players
	if self:Team() == TEAM_HUMAN then							// only humands can be changed
		
		weps = self:GetWeapons()
		for v,wep in pairs( weps ) do							// drop all there weapons
			self:DropWeapon( wep )
		end
		self:Give("weapon_knife_ze")							// give them a knife
		
		self:DoEffects()										// Drap the explodion effect
		self:SetTeam( TEAM_ZOMBIE )								// yup
		self:SetWalkSpeed(275)									// make them walk faster than humans
	end
end

function PLY:DoEffects()
	local pos = self:GetShootPos()
	local effectdata = EffectData()
	effectdata:SetStart( pos )
	effectdata:SetOrigin( pos )
	effectdata:SetScale( 2 )
	util.Effect( "HelicopterBomb", effectdata )	
 
end

function RoundEnd(winner)
	if CLIENT then return end
	if winner == TEAM_HUMAN or winner == nil then
		//humans win
		umsg.Start("winner")
			umsg.String("ze/humans_win")
			umsg.String("")
		umsg.End()
	else
		//zombies win
		umsg.Start("winner")
			umsg.String("ze/zombies_win")
			umsg.String("")
		umsg.End()
	end
	
	timer.Remove("round_timer")
	timer.Simple( 3, NewRound )
end

timer.Simple( 10, NewRound )

function WaitForMorePeople()
	local plys = {}								// the valid players
	for k,ply in pairs( player.GetAll() ) do	// loop through
		if ply:Team() == TEAM_HUMAN then		// add only ones who are humans
			table.Add( plys, ply )				// add them in
		end
	end 
	if #plys > 1 then			//if we got enugh players then restart the round + remove timer
		timer.Remove("wfnp")
		RoundEnd()
	end
end

local function PlayerDeath(pl, wep, killer)
	local players = player.GetAll()
	local z,h = 0,0
	
	for k,v in pairs( players ) do
		if v:Team() == TEAM_HUMAN then
			h = h + 1
		elseif v:Team() == TEAM_ZOMBIE then
			z = z + 1
		end
	end
	
	if z == 0 then
		RoundEnd(TEAM_HUMAN)
	elseif h == 0 then
		RoundEnd(TEAM_ZOMBIE)
	end
end
hook.Add( "PlayerDeath", "shouldroundend", PlayerDeath )

function CheckZombiePickup(ply, wep)
   return ply:Team() == TEAM_HUMAN
end
hook.Add("PlayerCanPickupWeapon", "stopzombiespickingup", CheckZombiePickup)

usermessage.Hook( "winner", function(um)
	texture = um:ReadString()
	local sound = Sound( um:ReadString() )
	round_end=true
end)
// We can't hook so easy in a function so i done this :P (yes, i know its weird)
hook.Add("HUDPaintBackground", "winner", function()
	if not round_end then return end
	local mat = Material( texture )
	surface.SetTexture( mat )
	surface.DrawRect( ScrW() - (512/2), ScrH() - (512/2), 512, 512 )
end)

