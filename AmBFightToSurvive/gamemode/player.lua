local lastdamage = lastdamage or {}
local healthregentime = 8  // in seconds before you regen health

function fsPlayerLoadout( ply )
	ply.SpeedMulti = 1
	GAMEMODE:SetPlayerSpeed( ply, 250, 400 )
end
hook.Add( "PlayerLoadout", "fs.Player.Loadout", fsPlayerLoadout )

function GM:ScalePlayerDamage( ply, hitgroup, dmginfo ) --   Hook for this not being called, dont know why
	if !ply:IsPlayer() && !ply:IsNPC() then return end
	// More damage if we're shot in the head
	 if ( hitgroup == HITGROUP_HEAD ) then
	 
		dmginfo:ScaleDamage( 18 )
	 
	end
	
	// Less damage if we're shot in the arms or legs
	if ( hitgroup == HITGROUP_LEFTARM ||
		 hitgroup == HITGROUP_RIGHTARM || 
		 hitgroup == HITGROUP_LEFTLEG ||
		 hitgroup == HITGROUP_RIGHTLEG ||
		 hitgroup == HITGROUP_GEAR ) then
	 
		dmginfo:ScaleDamage( 0.5 )
	 
	end
	
	local DontDrop ={ 	
						"gmod_camera",
						"tactical_insertion",
						"gmod_tool",
						"weapon_physgun"
					}
	
	if (hitgroup == HITGROUP_LEFTLEG || hitgroup == HITGROUP_RIGHTLEG) then
		if ply.SpeedMulti == nil then ply.SpeedMulti = 1 end
		ply.SpeedMulti = math.max( 0.3, ply.SpeedMulti - 0.1 )
		GAMEMODE:SetPlayerSpeed( ply, 250*ply.SpeedMulti, 400*ply.SpeedMulti )
	end
	
	if ( (hitgroup == HITGROUP_LEFTARM || hitgroup == HITGROUP_RIGHTARM) && ply:Health() < 50 ) then
		if !table.HasValue( DontDrop, ply:GetActiveWeapon():GetClass() ) then
			ply:DropWeapon( ply:GetActiveWeapon() )
		end
	end

	
	dmginfo:ScaleDamage( 1 )
	
end
--hook.Add( "ScalePlayerDamage", "fs.Player.ScaleDamage", fsScalePlayerDamage )



function GM:GetFallDamage( ply, vel )
	if GetConVarNumber("mp_falldamage") == 0 then
		if math.Rand(1,20) == 1 and vel > 999 then
			return ply:Health() - 1
		end
		return (vel-200) / 8
		ply.SpeedMulti = math.max( 0.3, ply.SpeedMulti - 0.2 )
		GAMEMODE:SetPlayerSpeed( ply, 250*ply.SpeedMulti, 400*ply.SpeedMulti )
	end
end
hook.Add( "GetFallDamage", "fs.GetFallDmg", GetFallDamage)

function GM.HealthRegen()
	for _,ply in pairs( player.GetAll() ) do
		local lastdmg = lastdamage[ply:SteamID()] or 0
		if ply:Alive() and ( lastdmg + healthregentime) < CurTime() then
			if ply:Health() > 20 then
				local hp = ply:Health()
				ply:SetHealth( math.Clamp( hp + 1, 0, ply:GetMaxHealth() ) )
			end
		end
	end
end
timer.Create( "HPRegen", 0.1, 0, GM.HealthRegen )


function PlayerShouldTakeDamage( victim, pl )
	if !pl:IsValid() || pl == nil then return true end
	if( pl:Team() != 1 && pl:Team() == victim:Team() && GetConVarNumber( "mp_friendlyfire" ) == 0 ) then
		return false -- do not damage the player
	end
	lastdamage[pl:SteamID()] = CurTime()
	return true -- damage the player
end
hook.Add("PlayerShouldTakeDamage","Asdasd",PlayerShouldTakeDamage)