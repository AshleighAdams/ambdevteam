local lastdamage = lastdamage or {}
local healthregentime = 8  // in seconds before you regen health


function GM:PlayerLoadout( ply ) --Weapon/ammo/item function
	ply.SpeedMulti = 1
	GAMEMODE:SetPlayerSpeed( ply, 250, 400 )
end
function GM:ScalePlayerDamage( ply, hitgroup, dmginfo )
	if !ply:IsPlayer() || !ply:IsNPC() then return end
	lastdamage[ply:SteamID()] = CurTime()

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
	
	if ( (hitgroup == HITGROUP_LEFTARM || hitgroup == HITGROUP_RIGHTARM) && ply:Health() > 35 ) then
		if ply:GetActiveWeapon():GetClass() == "" then return end -- gmod_camera  tactical_insertion  gmod_tool  weapon_physgun
		ply:DropWeapon( ply:GetActiveWeapon() )
	end
	
	if (hitgroup == HITGROUP_LEFTLEG || hitgroup == HITGROUP_RIGHTLEG) then
		if ply.SpeedMulti == nil then ply.SpeedMulti = 1 end
		ply.SpeedMulti = math.max( 0.3, ply.SpeedMulti() - 0.05 )
		GAMEMODE:SetPlayerSpeed( ply, 250*ply.SpeedMulti, 400*ply.SpeedMulti )
	end
	
	dmginfo:ScaleDamage( 1 )
	end
	
end



function GM.HealthRegen()
	for _,ply in pairs( player.GetAll() ) do
		local lastdmg = lastdamage[ply:SteamID()] or 0
		if ply:Alive() and ( lastdmg + healthregentime) < CurTime() then
			if ply:Health() > 20 then
				local hp = ply:Health()
				ply:SetHealth( math.Clamp( hp + 1, 0, 100 ) )
			end
		end
	end
end
timer.Create( "HPRegen", 0.1, 0, GM.HealthRegen )



