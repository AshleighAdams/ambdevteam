local lastdamage = lastdamage or {}
local healthregentime = 8  // in seconds before you regen health

function fsPlayerLoadout( ply )
	ply.SpeedMulti = 1
	GAMEMODE:SetPlayerSpeed( ply, 250, 400 )
	SendTeamInfo( ply )
end
hook.Add( "PlayerLoadout", "fs.Player.Loadout", fsPlayerLoadout )

function GM:ScalePlayerDamage( ply, hitgroup, dmginfo ) --   Hook for this not being called, dont know why
	if !ply:IsPlayer() && !ply:IsNPC() then return end
	lastdamage[ply:SteamID()] = CurTime() -- for health regen stuff ect...
	local attacker = dmginfo:GetAttacker()
	if attacker:IsNPC() || attacker:IsPlayer() then
		ply.LastAttacker = attacker
		ply.LastAttackerWeapon = attacker:GetActiveWeapon()
	end
	
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
		if not ply.MegaLegs then
			if ply.SpeedMulti == nil then ply.SpeedMulti = 1 end
			ply.SpeedMulti = math.max( 0.3, ply.SpeedMulti - 0.1 )
			GAMEMODE:SetPlayerSpeed( ply, 250*ply.SpeedMulti, 400*ply.SpeedMulti )
		end
	end
	
	if ( (hitgroup == HITGROUP_LEFTARM || hitgroup == HITGROUP_RIGHTARM) && ply:Health() < 50 ) then
		if !table.HasValue( DontDrop, ply:GetActiveWeapon():GetClass() ) then
			ply:DropWeapon( ply:GetActiveWeapon() )
		end
	end

	
	dmginfo:ScaleDamage( 1 )
	
end
//hook.Add( "ScalePlayerDamage", "fs.Player.ScaleDamage", fsScalePlayerDamage )



function GM:GetFallDamage( ply, vel )
	if GetConVarNumber("mp_falldamage") == 0 then
		if math.Rand(1,20) == 1 and vel > 999 then
			return ply:Health() - 1
		end
		if not ply.MegaLegs then
			ply.SpeedMulti = math.max( 0.3, ply.SpeedMulti - 0.2 )
			GAMEMODE:SetPlayerSpeed( ply, 250*ply.SpeedMulti, 400*ply.SpeedMulti )
		end
		dmg = (vel-200) / 8
		if ply.LastAttacker && (ply.LastAttacker:IsPlayer() || ply.LastAttacker:IsNPC()) then
			Damage( ply,dmg )
			punch = dmg / ply:GetMaxHealth() *-5
			ply:ViewPunch( Angle(punch,0,0) )
			return 0
		else
			return dmg
		end
	end
end
//hook.Add( "GetFallDamage", "fs.GetFallDmg", GetFallDamage)

function GM.HealthRegen()
	for _,ply in pairs( player.GetAll() ) do
		local lastdmg = lastdamage[ply:SteamID()] or 0
		if ply:Alive() and ( lastdmg + healthregentime) < CurTime() then
			if ply:Health() > 20 then
				local hp = ply:Health()
				ply:SetHealth( math.Clamp( hp + 1, 0, ply:GetMaxHealth() ) )
			end
			if ply:Health() == ply:GetMaxHealth() then
				ply.LastAttacker = nil
			end
		end
	end
end
timer.Create( "HPRegen", 0.1, 0, GM.HealthRegen )


function PlayerShouldTakeDamage( victim, pl )
	if pl == nil || !pl:IsValid()  then return true end
	if pl:IsNPC() || victim:IsNPC() then return true end
	if victim:Team() == 1 then return true end
	if( pl:Team() == victim:Team() && GetConVarNumber( "mp_friendlyfire" ) == 0 ) then
		return false -- do not damage the player
	end
	return true -- damage the player
end
hook.Add("PlayerShouldTakeDamage","Asdasd",PlayerShouldTakeDamage)

timer.Create( "fs.LowHealth.ViewPunch", 5, 0, function()
	for k,v in pairs( player.GetAll() ) do
		if v:Health() <= 20 then
			local P = math.Rand( -1,1 ) * ( ( 20-v:Health() ) * 5 )
			local Y = math.Rand( -1,1 ) * ( ( 20-v:Health() ) * 5 )
			local R = math.Rand( -1,1 ) * ( ( 20-v:Health() ) * 5 )
			Ang = Angle( P,Y,R )
			v:ViewPunch( Ang )
		end
		if( v:Health() <= 10 && v:Alive() ) then
			Damage( v,1 )
			if v:Health() < 1 then
				if v:Alive() then v:Kill() end
			end
		end
	end
end)

function Damage( pl, ammount )
	if pl.LastAttacker == nil || !pl:IsPlayer() && pl:Alive() then
		pl:SetHealth( pl:Health() - ammount )
		if pl:Health() <= 0 then
			pl:Kill()
		end
	elseif pl.LastAttacker then
		local dmg = DamageInfo()
		dmg:SetDamage( ammount ) 
		dmg:SetDamageType( DMG_BULLET )
		dmg:SetAttacker( pl.LastAttacker )
		dmg:SetInflictor( pl.LastAttackerWeapon or pl.LastAttacker )
		dmg:SetDamageForce( Vector( 0, 0, -1 ) )
		pl:TakeDamageInfo( dmg )
	end
end