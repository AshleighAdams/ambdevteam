votes = {}
rtv_passed = false

function GM:PlayerTraceAttack( ply, dmginfo, dir, trace )

	if ( SERVER ) then
		GAMEMODE:ScalePlayerDamage( ply, trace.HitGroup, dmginfo )
	end

	return false
end


/*---------------------------------------------------------
   Name: gamemode:SetPlayerSpeed( )
   Desc: Sets the player's run/walk speed
---------------------------------------------------------*/
function GM:SetPlayerSpeed( ply, walk, run )

	ply:SetWalkSpeed( walk )
	ply:SetRunSpeed( run )
	
end



/*---------------------------------------------------------
   Name: gamemode:CanPlayerEnterVehicle( player, vehicle, role )
   Desc: Return true if player can enter vehicle
---------------------------------------------------------*/
function GM:CanPlayerEnterVehicle( player, vehicle, role )
	return true
end

/*---------------------------------------------------------
   Name: gamemode:PlayerEnteredVehicle( player, vehicle, role )
   Desc: Player entered the vehicle fine
---------------------------------------------------------*/
function GM:PlayerEnteredVehicle( player, vehicle, role )
end


/*---------------------------------------------------------
   Name: gamemode:PlayerFootstep( ply, vPos, iFoot, strSoundName, fVolume, pFilter )
   Desc: Called when a player steps
		pFilter is the recipient filter to use for effects/sounds 
			and is only valid SERVERSIDE. Clientside needs no filter!
		Return true to not play normal sound
---------------------------------------------------------*/
function GM:PlayerFootstep( ply, vPos, iFoot, strSoundName, fVolume, pFilter )
	
	if ply:GetVelocity():Length() < 150 then return true end
	return false
	/*
	// Draw effect on footdown
	local effectdata = EffectData()
		effectdata:SetOrigin( vPos )
	util.Effect( "phys_unfreeze", effectdata, true, pFilter )
	*/
	
	/*
	// Don't play left foot
	if ( iFoot == 0 ) then return true end
	*/
	
end

/*---------------------------------------------------------
   Name: gamemode:PlayerStepSoundTime( ply, iType, bWalking )
   Desc: Return the time between footsteps
---------------------------------------------------------*/
function GM:PlayerStepSoundTime( ply, iType, bWalking )
	
	local fStepTime = 350
	local fMaxSpeed = ply:GetMaxSpeed()
	
	if ( iType == STEPSOUNDTIME_NORMAL || iType == STEPSOUNDTIME_WATER_FOOT ) then
		
		if ( fMaxSpeed <= 100 ) then 
			fStepTime = 400
		elseif ( fMaxSpeed <= 300 ) then 
			fStepTime = 350
		else 
			fStepTime = 250 
		end
	
	elseif ( iType == STEPSOUNDTIME_ON_LADDER ) then
	
		fStepTime = 450 
	
	elseif ( iType == STEPSOUNDTIME_WATER_KNEE ) then
	
		fStepTime = 600 
	
	end
	
	// Step slower if crouching
	if ( ply:Crouching() ) then
		fStepTime = fStepTime + 50
	end
	
	return fStepTime
	
end

hook.Add( "PlayerSay", "rtv", function(ply,text) 
	if SERVER then // you never know :S
		if text == "rtv" || text == "!rtv" || text == "/rtv" then
			ply:RockTheVote()
		end
	end
end)

function GM:OnPlayerChat( player, strText, bTeamOnly, bPlayerIsDead )	
	//
	// I've made this all look more complicated than it is. Here's the easy version
	//
	// chat.AddText( player, Color( 255, 255, 255 ), ": ", strText )
	//
	
	local tab = {}
	
	if ( bPlayerIsDead ) then
		table.insert( tab, Color( 255, 30, 40 ) )
		table.insert( tab, "*DEAD* " )
	end
	
	if ( bTeamOnly ) then
		table.insert( tab, Color( 30, 160, 40 ) )
		table.insert( tab, "(TEAM) " )
	end
	local con = false
	if ( IsValid( player ) ) then
		table.insert( tab, player )
	else
		con = true // this is for the yellow instructions as it apears in CSS without "Console:"
	end
	if con then
		table.insert( tab, Color( 255, 200, 0 ) )
		table.insert( tab, strText )
	else
		table.insert( tab, Color( 255, 255, 255 ) )
		table.insert( tab, ": "..strText )
	end
	chat.AddText( unpack(tab) )

	return true
	
end

function GM:PlayerNoClip( pl, on )
	
	
	return pl:IsAdmin()
	
end

PLY = _R["Entity"]

function PLY:RockTheVote()
	if !ValidEntity(self) then return end
	if !self:IsPlayer() then return end
	
	// stop people spamming...
	if table.HasValue( votes, self ) then
		self:ChatPrint("You have already Rocked The Vote")
		return
	end
	if rtv_passed then
		self:ChatPrint("Rock The Vote Passed, Voting in progress")
		return
	end
	
	local votes_needed = math.ceil( MaxPlayers() / 2 )
	// Recalculate stuff to compensate for people who have left
	local new_votes = {self}
	for k,v in pairs( votes ) do
		if ValidEntity(v) and v:IsPlayer() then
			table.Add( new_votes, v )
		end
	end
	votes=new_votes
	
	//  Tell evryone
	for i,ply in pairs( player.GetAll() ) do
		ply:ChatPrint( self:Name() .. " has Rocked The Vote. Votes Needed: " .. tostring(#votes) .. " out of " .. tostring(votes_needed) )
		if #votes >= votes_needed then
			DoMapChange()
			ply:ChatPrint("Rock The Vote passed! Please vote for the next map")
		end
	end
end

function DoMapChange()
	rtv_passed = true
end