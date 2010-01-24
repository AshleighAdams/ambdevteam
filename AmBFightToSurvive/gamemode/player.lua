local lastdamage = lastdamage or {}
local healthregentime = 8  // in seconds before you regen health



function GM:PlayerLoadout( ply ) --Weapon/ammo/item function
	ply.hitgroups = {}
	for group = 0,10 do
		if group ~= HITGROUP_GENERIC and group ~= HITGROUP_GEAR then
			ply.hitgroups[group] = 50
		end
	end
end

/*---------------------------------------------------------
   Name: gamemode:ScalePlayerDamage( ply, hitgroup, dmginfo )
   Desc: Scale the damage based on being shot in a hitbox
---------------------------------------------------------*/
groupNames = {"head","chest","stomach","left arm","right arm","left leg","right leg"}
function GM:ScalePlayerDamage( ply, hitgroup, dmginfo )
	
	lastdamage[ply:SteamID()] = CurTime()

	// More damage if we're shot in the head
	 if ( hitgroup == HITGROUP_HEAD ) then
	 
		dmginfo:ScaleDamage( 18 )
	 
	end
	 
	// Less damage if we're shot in the arms or legs
	if ( hitgroup == HITGROUP_LEFTARM ||
		 hitgroup == HITGROUP_RIGHTARM || 
		 hitgroup == HITGROUP_LEFTLEG ||
		 hitgroup == HITGROUP_LEFTLEG ||
		 hitgroup == HITGROUP_GEAR ) then
	 
		dmginfo:ScaleDamage( 0.5 )
	 
	end
	
	if ( hitgroup == HITGROUP_LEFTARM || hitgroup == HITGROUP_RIGHTARM && ply:Health() > 50 ) then
		if ply:GetActiveWeapon():GetClass() == "" then return end -- gmod_camera  tactical_insertion  gmod_tool  weapon_physgun
		ply:DropWeapon( ply:GetActiveWeapon() )
	end
	
	dmginfo:ScaleDamage( 1 )
	
		if (ply.hitgroups and ply.hitgroups[hitgroup]) then
		local groupName = groupNames[hitgroup]
 
		--ply:PrintMessage( HUD_PRINTTALK, "Your "..groupName.." is down to "..ply.hitgroups[hitgroup])
		ply.hitgroups[hitgroup] = ply.hitgroups[hitgroup] - dmginfo:GetBaseDamage()
 
 
		--Now set the player's speed dependant on the state of his/her legs.
		local speed = 20
		if ply.hitgroups[HITGROUP_RIGHTLEG] > 0 then
			speed = speed + 90
		end
		if ply.hitgroups[HITGROUP_LEFTLEG] > 0 then
			speed = speed + 90
		end
 
		GAMEMODE:SetPlayerSpeed( ply, speed, speed*1.75 )
	end
	
end



function GM.HealthRegen()
	for _,ply in pairs( player.GetAll() ) do
		local lastdmg = lastdamage[ply:SteamID()] or 0
		if ply:Alive() and ( lastdmg + healthregentime) < CurTime() then
			if ply:Health() > 19 then
				local hp = ply:Health()
				ply:SetHealth( math.Clamp( hp + 1, 0, 100 ) )
			end
		end
	end
end
timer.Create( "HPRegen", 0.05, 0, GM.HealthRegen )



