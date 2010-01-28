


function GM:PlayerLoadout( ply ) --Weapon/ammo/item function
	ply.SpeedMulti = 1
	GAMEMODE:SetPlayerSpeed( ply, 250, 400 )
end
function GM:ScalePlayerDamage( ply, hitgroup, dmginfo )
	if !ply:IsPlayer() || !ply:IsNPC() then return end
	
Msg(0)
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
	Msg(1)
	if (hitgroup == HITGROUP_LEFTLEG || hitgroup == HITGROUP_RIGHTLEG) then
		Msg(2)
		if ply.SpeedMulti == nil then ply.SpeedMulti = 1 end
		ply.SpeedMulti = math.max( 0.3, ply.SpeedMulti() - 0.05 )
		GAMEMODE:SetPlayerSpeed( ply, 250*ply.SpeedMulti, 400*ply.SpeedMulti )
	end
	Msg(3)
	if ( (hitgroup == HITGROUP_LEFTARM || hitgroup == HITGROUP_RIGHTARM) && ply:Health() < 50 ) then
		Msg(4)
		if !table.HasValue( DontDrop, ply:GetActiveWeapon():GetClass() ) then
			ply:DropWeapon( ply:GetActiveWeapon() )
		end
	end
	

	
	dmginfo:ScaleDamage( 1 )
	
end

