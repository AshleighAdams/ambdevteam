
function GM:PlayerDeathThink( pl )

	if (  pl.NextSpawnTime && pl.NextSpawnTime > CurTime() ) then return end

	if ( pl:KeyPressed( IN_ATTACK ) || pl:KeyPressed( IN_ATTACK2 ) || pl:KeyPressed( IN_JUMP ) ) then
		
		pl:SetTeam(TEAM_SPECTATOR)
		pl:Spawn()
		
	end
	
end

/*---------------------------------------------------------
	Name: gamemode:PlayerUse( player, entity )
	Desc: A player has attempted to use a specific entity
		Return true if the player can use it
//--------------------------------------------------------*/
function GM:PlayerUse( pl, entity )
	return true
end

/*---------------------------------------------------------
   Name: gamemode:PlayerSilentDeath( )
   Desc: Called when a player dies silently
---------------------------------------------------------*/
function GM:PlayerSilentDeath( Victim )

	Victim.NextSpawnTime = CurTime() + 2
	Victim.DeathTime = CurTime()

end

/*---------------------------------------------------------
   Name: gamemode:PlayerDeath( )
   Desc: Called when a player dies.
---------------------------------------------------------*/
function GM:PlayerDeath( Victim, Inflictor, Attacker )

	// Don't spawn for at least 2 seconds
	Victim.NextSpawnTime = CurTime() + 2
	Victim.DeathTime = CurTime()

	// Convert the inflictor to the weapon that they're holding if we can.
	// This can be right or wrong with NPCs since combine can be holding a 
	// pistol but kill you by hitting you with their arm.
	if ( Inflictor && Inflictor == Attacker && (Inflictor:IsPlayer() || Inflictor:IsNPC()) ) then
	
		Inflictor = Inflictor:GetActiveWeapon()
		if ( !Inflictor || Inflictor == NULL ) then Inflictor = Attacker end
	
	end
	
	if (Attacker == Victim) then
	
		umsg.Start( "PlayerKilledSelf" )
			umsg.Entity( Victim )
		umsg.End()
		
		MsgAll( Attacker:Nick() .. " suicided!\n" )
		
	return end

	if ( Attacker:IsPlayer() ) then
	
		umsg.Start( "PlayerKilledByPlayer" )
		
			umsg.Entity( Victim )
			umsg.String( Inflictor:GetClass() )
			umsg.Entity( Attacker )
		
		umsg.End()
		
		MsgAll( Attacker:Nick() .. " killed " .. Victim:Nick() .. " using " .. Inflictor:GetClass() .. "\n" )
		
	return end
	
	umsg.Start( "PlayerKilled" )
	
		umsg.Entity( Victim )
		umsg.String( Inflictor:GetClass() )
		umsg.String( Attacker:GetClass() )

	umsg.End()
	
	MsgAll( Victim:Nick() .. " was killed by " .. Attacker:GetClass() .. "\n" )
	
end

/*---------------------------------------------------------
   Name: gamemode:PlayerInitialSpawn( )
   Desc: Called just before the player's first spawn
---------------------------------------------------------*/
function GM:PlayerInitialSpawn( pl )

	pl:SetTeam( TEAM_SPECTATOR )
	
end

/*---------------------------------------------------------
   Name: gamemode:PlayerSpawnAsSpectator( )
   Desc: Player spawns as a spectator
---------------------------------------------------------*/
function GM:PlayerSpawnAsSpectator( pl )

	pl:StripWeapons();
	
	if ( pl:Team() == TEAM_UNASSIGNED ) then
	
		pl:Spectate( OBS_MODE_FIXED )
		return
		
	end

	pl:SetTeam( TEAM_SPECTATOR )
	pl:Spectate( OBS_MODE_ROAMING )

end

/*---------------------------------------------------------
   Name: gamemode:PlayerSpawn( )
   Desc: Called when a player spawns
---------------------------------------------------------*/
function GM:PlayerSpawn( pl )

	//
	// If the player doesn't have a team in a TeamBased game
	// then spawn him as a spectator
	//
	if ( GAMEMODE.TeamBased && ( pl:Team() == TEAM_SPECTATOR || pl:Team() == TEAM_UNASSIGNED ) ) then

		GAMEMODE:PlayerSpawnAsSpectator( pl )
		return
	
	end

	// Stop observer mode
	pl:UnSpectate()

	// Call item loadout function
	hook.Call( "PlayerLoadout", GAMEMODE, pl )
	
	// Set player model
	hook.Call( "PlayerSetModel", GAMEMODE, pl )
	
	pl:SetCrouchedWalkSpeed(0.5)
	pl:SetRunSpeed(100)
	pl:SetWalkSpeed(250)
	
end

/*---------------------------------------------------------
   Name: gamemode:PlayerSetModel( )
   Desc: Set the player's model
---------------------------------------------------------*/
function GM:PlayerSetModel( pl )

	local cl_playermodel = pl:GetInfo( "cl_playermodel" )
	local modelname = player_manager.TranslatePlayerModel( cl_playermodel )
	util.PrecacheModel( modelname )
	pl:SetModel( modelname )
	
end

/*---------------------------------------------------------
   Name: gamemode:PlayerLoadout( )
   Desc: Give the player the default spawning weapons/ammo
---------------------------------------------------------*/
function GM:PlayerLoadout( pl )

	pl:Give("weapon_knife_ze")
	pl:Give("weapon_deagle_ze")
	pl:Give("weapon_ak47_ze")
	
	// Switch to prefered weapon if they have it
	local cl_defaultweapon = pl:GetInfo( "cl_defaultweapon" )
	
	if ( pl:HasWeapon( cl_defaultweapon )  ) then
		pl:SelectWeapon( cl_defaultweapon ) 
	end
	
end

/*---------------------------------------------------------
   Name: gamemode:PlayerSelectTeamSpawn( player )
   Desc: Find a spawn point entity for this player's team
---------------------------------------------------------*/
function GM:PlayerSelectTeamSpawn( TeamID, pl )

	local SpawnPoints = team.GetSpawnPoints( TeamID )
	if ( !SpawnPoints || table.Count( SpawnPoints ) == 0 ) then return end
	
	local ChosenSpawnPoint = nil
	
	for i=0, 6 do
	
		local ChosenSpawnPoint = table.Random( SpawnPoints )
		if ( GAMEMODE:IsSpawnpointSuitable( pl, ChosenSpawnPoint, i==6 ) ) then
			return ChosenSpawnPoint
		end
	
	end
	
	return ChosenSpawnPoint

end


/*---------------------------------------------------------
   Name: gamemode:PlayerSelectSpawn( player )
   Desc: Find a spawn point entity for this player
---------------------------------------------------------*/
function GM:IsSpawnpointSuitable( pl, spawnpointent, bMakeSuitable )

	local Pos = spawnpointent:GetPos()
	
	// Note that we're searching the default hull size here for a player in the way of our spawning.
	// This seems pretty rough, seeing as our player's hull could be different.. but it should do the job
	// (HL2DM kills everything within a 128 unit radius)
	local Ents = ents.FindInBox( Pos + Vector( -16, -16, 0 ), Pos + Vector( 16, 16, 64 ) )
	
	if ( pl:Team() == TEAM_SPECTATOR || pl:Team() == TEAM_UNASSIGNED ) then return true end
	
	local Blockers = 0
	
	for k, v in pairs( Ents ) do
		if ( IsValid( v ) && v:GetClass() == "player" && v:Alive() ) then
		
			Blockers = Blockers + 1
			
			if ( bMakeSuitable ) then
				v:Kill()
			end
			
		end
	end
	
	if ( bMakeSuitable ) then return true end
	if ( Blockers > 0 ) then return false end
	return true

end

/*---------------------------------------------------------
   Name: gamemode:PlayerSelectSpawn( player )
   Desc: Find a spawn point entity for this player
---------------------------------------------------------*/
function GM:PlayerSelectSpawn( pl )

	if ( GAMEMODE.TeamBased ) then
	
		local ent = GAMEMODE:PlayerSelectTeamSpawn( pl:Team(), pl )
		if ( IsValid(ent) ) then return ent end
	
	end

	// Save information about all of the spawn points
	// in a team based game you'd split up the spawns
	if ( !IsTableOfEntitiesValid( self.SpawnPoints ) ) then
	
		self.LastSpawnPoint = 0
		self.SpawnPoints = ents.FindByClass( "info_player_start" )
		self.SpawnPoints = table.Add( self.SpawnPoints, ents.FindByClass( "info_player_deathmatch" ) )
		self.SpawnPoints = table.Add( self.SpawnPoints, ents.FindByClass( "info_player_combine" ) )
		self.SpawnPoints = table.Add( self.SpawnPoints, ents.FindByClass( "info_player_rebel" ) )
		
		// CS Maps
		self.SpawnPoints = table.Add( self.SpawnPoints, ents.FindByClass( "info_player_counterterrorist" ) )
		self.SpawnPoints = table.Add( self.SpawnPoints, ents.FindByClass( "info_player_terrorist" ) )
		
		// DOD Maps
		self.SpawnPoints = table.Add( self.SpawnPoints, ents.FindByClass( "info_player_axis" ) )
		self.SpawnPoints = table.Add( self.SpawnPoints, ents.FindByClass( "info_player_allies" ) )

		// (Old) GMod Maps
		self.SpawnPoints = table.Add( self.SpawnPoints, ents.FindByClass( "gmod_player_start" ) )
		
		// TF Maps
		self.SpawnPoints = table.Add( self.SpawnPoints, ents.FindByClass( "info_player_teamspawn" ) )		
		
		// If any of the spawnpoints have a MASTER flag then only use that one.
		for k, v in pairs( self.SpawnPoints ) do
		
			if ( v:HasSpawnFlags( 1 ) ) then
			
				self.SpawnPoints = {}
				self.SpawnPoints[1] = v
			
			end
		
		end

	end
	
	local Count = table.Count( self.SpawnPoints )
	
	if ( Count == 0 ) then
		Msg("[PlayerSelectSpawn] Error! No spawn points!\n")
		return nil 
	end
	
	local ChosenSpawnPoint = nil
	
	// Try to work out the best, random spawnpoint (in 6 goes)
	for i=0, 6 do
	
		ChosenSpawnPoint = table.Random( self.SpawnPoints )

		if ( ChosenSpawnPoint &&
			ChosenSpawnPoint:IsValid() &&
			ChosenSpawnPoint:IsInWorld() &&
			ChosenSpawnPoint != pl:GetVar( "LastSpawnpoint" ) &&
			ChosenSpawnPoint != self.LastSpawnPoint ) then
			
			if ( GAMEMODE:IsSpawnpointSuitable( pl, ChosenSpawnPoint, i==6 ) ) then
			
				self.LastSpawnPoint = ChosenSpawnPoint
				pl:SetVar( "LastSpawnpoint", ChosenSpawnPoint )
				return ChosenSpawnPoint
			
			end
			
		end
			
	end
	
	return ChosenSpawnPoint
	
end

/*---------------------------------------------------------
   Name: gamemode:WeaponEquip( weapon )
   Desc: Player just picked up (or was given) weapon
---------------------------------------------------------*/
function GM:WeaponEquip( weapon )

end

/*---------------------------------------------------------
   Name: gamemode:ScalePlayerDamage( ply, hitgroup, dmginfo )
   Desc: Scale the damage based on being shot in a hitbox
		 Return true to not take damage
---------------------------------------------------------*/
function GM:ScalePlayerDamage( ply, hitgroup, dmginfo )
	local force = 1
	local attacker = dmginfo:GetAttacker()
	// More damage if we're shot in the head
	 if ( hitgroup == HITGROUP_HEAD ) then
		force = 2
		dmginfo:ScaleDamage( 2 )
	 
	 end
	 
	// Less damage if we're shot in the arms or legs
	if ( hitgroup == HITGROUP_LEFTARM ||
		 hitgroup == HITGROUP_RIGHTARM || 
		 hitgroup == HITGROUP_LEFTLEG ||
		 hitgroup == HITGROUP_LEFTLEG ||
		 hitgroup == HITGROUP_GEAR ) then
	 
		dmginfo:ScaleDamage( 0.25 )
	 
	 end
	if attacker:Team() == TEAM_HUMAN then
		local vec = ( ply:GetShootPos() - attacker:GetShootPos() ):Normalize() * (force*200)
		ply:SetVelocity(vec)
	elseif attacker:Team() == TEAM_ZOMBIE then
		ply:SetZombie()
	end
end

/*---------------------------------------------------------
   Name: gamemode:PlayerDeathSound()
   Desc: Return true to not play the default sounds
---------------------------------------------------------*/
function GM:PlayerDeathSound()
	return false
end

/*---------------------------------------------------------
   Name: gamemode:SetupPlayerVisibility()
   Desc: Add extra positions to the player's PVS
---------------------------------------------------------*/
function GM:SetupPlayerVisibility( pPlayer, pViewEntity )
	//AddOriginToPVS( vector_position_here )
end

/*---------------------------------------------------------
   Name: gamemode:OnDamagedByExplosion( ply, dmginfo)
   Desc: Player has been hurt by an explosion
---------------------------------------------------------*/
function GM:OnDamagedByExplosion( ply, dmginfo )
	ply:SetDSP( 35, false )
end

/*---------------------------------------------------------
   Name: gamemode:CanPlayerSuicide( ply )
   Desc: Player typed KILL in the console. Can they kill themselves?
---------------------------------------------------------*/
function GM:CanPlayerSuicide( ply )
	ply:ChatPrint("Don't be an asshole")
	return false
end

/*---------------------------------------------------------
   Name: gamemode:PlayerLeaveVehicle()
---------------------------------------------------------*/
function GM:PlayerLeaveVehicle( ply, veichle )
end

/*---------------------------------------------------------
   Name: gamemode:CanExitVehicle()
			If the player is allowed to leave the vehicle, return true
---------------------------------------------------------*/
function GM:CanExitVehicle( veichle, passenger )
	return true
end

/*---------------------------------------------------------
   Name: gamemode:PlayerSwitchFlashlight()
		Return true to allow action
---------------------------------------------------------*/
function GM:PlayerSwitchFlashlight( ply, SwitchOn )
	return true
end

/*---------------------------------------------------------
   Name: gamemode:PlayerCanJoinTeam( ply, teamid )
		Allow mods/addons to easily determine whether a player 
			can join a team or not
---------------------------------------------------------*/
function GM:PlayerCanJoinTeam( ply, teamid )
	
	local TimeBetweenSwitches = GAMEMODE.SecondsBetweenTeamSwitches or 10
	if ( ply.LastTeamSwitch && RealTime()-ply.LastTeamSwitch < TimeBetweenSwitches ) then
		ply.LastTeamSwitch = ply.LastTeamSwitch + 1;
		ply:ChatPrint( Format( "Please wait %i more seconds before trying to change team again", (TimeBetweenSwitches - (RealTime()-ply.LastTeamSwitch)) + 1 ) )
		return false
	end
	
	// Already on this team!
	if ( ply:Team() == teamid ) then 
		ply:ChatPrint( "You're already on that team" )
		return false
	end
	
	return teamid == TEAM_SPECTATOR
	
end

/*---------------------------------------------------------
   Name: gamemode:PlayerRequestTeam()
		Player wants to change team
---------------------------------------------------------*/
function GM:PlayerRequestTeam( ply, teamid )
	
	// No changing teams if not teambased!
	if ( !GAMEMODE.TeamBased ) then return end
	
	// This team isn't joinable
	if ( !team.Joinable( teamid ) ) then 
		ply:ChatPrint( "You can't join that team" )
	return end
	
	// This team isn't joinable
	if ( !GAMEMODE:PlayerCanJoinTeam( ply, teamid ) ) then 
		// Messages here should be outputted by this function
	return end
	
	GAMEMODE:PlayerJoinTeam( ply, teamid )
	
end

/*---------------------------------------------------------
   Name: gamemode:PlayerJoinTeam()
		Make player join this team
---------------------------------------------------------*/
function GM:PlayerJoinTeam( ply, teamid )
	
	local iOldTeam = ply:Team()
	
	if ( ply:Alive() ) then
		if (iOldTeam == TEAM_SPECTATOR || iOldTeam == TEAM_UNASSIGNED) then
			ply:KillSilent()
		else
			return
		end
	end
	
	
	GAMEMODE:OnPlayerChangedTeam( ply, iOldTeam, teamid )
	
end

/*---------------------------------------------------------
   Name: gamemode:OnPlayerChangedTeam( ply, oldteam, newteam )
---------------------------------------------------------*/
function GM:OnPlayerChangedTeam( ply, oldteam, newteam )

	// Here's an immediate respawn thing by default. If you want to 
	// re-create something more like CS or some shit you could probably
	// change to a spectator or something while dead.
	if ( newteam == TEAM_SPECTATOR ) then
	
		// If we changed to spectator mode, respawn where we are
		local Pos = ply:EyePos()
		ply:Spawn()
		ply:SetPos( Pos )
		
	elseif ( oldteam == TEAM_SPECTATOR ) then
	
		// If we're changing from spectator, join the game
		ply:Spawn()
	
	else
	
		// If we're straight up changing teams just hang
		//  around until we're ready to respawn onto the 
		//  team that we chose
		
	end
	
	PrintMessage( HUD_PRINTTALK, Format( "%s joined '%s'", ply:Nick(), team.GetName( newteam ) ) )
	
end

/*---------------------------------------------------------
   Name: gamemode:PlayerSpray()
		Return true to prevent player spraying
---------------------------------------------------------*/
function GM:PlayerSpray( ply )
	
	return false
	
end

/*---------------------------------------------------------
   Name: gamemode:OnPlayerHitGround()
		Return true to disable default action
---------------------------------------------------------*/
function GM:OnPlayerHitGround( ply, bInWater, bOnFloater, flFallSpeed )
	
	if bInWater then return true end
	
	local max_safe_fall_speed = 488.5
	local fatal_fall_speed = 988.5
	local dmg = flFallSpeed / (fatal_fall_speed - max_safe_fall_speed)
	
	dmg = math.floor(dmg*10)
	
	if flFallSpeed <= max_safe_fall_speed then return true end
 /*
  // not exact, but pretty darn close
 #define PLAYER_MAX_SAFE_FALL_SPEED 488.5
 #define PLAYER_FATAL_FALL_SPEED    988.5
 #define DAMAGE_FOR_FALL_SPEED    100.0 / (PLAYER_FATAL_FALL_SPEED - PLAYER_MAX_SAFE_FALL_SPEED)
 */
	
	
	local dmginfo = DamageInfo()
	dmginfo:SetDamage( dmg )
	dmginfo:SetDamageType( DMG_FALL )
	dmginfo:SetAttacker( ply )
	
	ply:TakeDamageInfo(dmginfo)
	
	return true
	
end

/*---------------------------------------------------------
   Name: gamemode:GetFallDamage()
		return amount of damage to do due to fall
---------------------------------------------------------*/
function GM:GetFallDamage( ply, flFallSpeed )
	
end

/*---------------------------------------------------------
   Name: gamemode:PlayerCanSeePlayersChat()
		Can this player see the other player's chat?
---------------------------------------------------------*/
function GM:PlayerCanSeePlayersChat( strText, bTeamOnly, pListener, pSpeaker )
	
	if ( bTeamOnly ) then
		if ( !IsValid( pSpeaker ) || !IsValid( pListener ) ) then return false end
		if ( pListener:Team() != pSpeaker:Team() ) then return false end
	end
	
	return true
	
end

hook.Add( "OnPlayerHitGround", "slow them down", function(ply)
	
end)