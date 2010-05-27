
/*---------------------------------------------------------
   Name: gamemode:OnNPCKilled( entity, attacker, inflictor )
   Desc: The NPC has died
---------------------------------------------------------*/
function GM:OnNPCKilled( ent, attacker, inflictor )

	// Convert the inflictor to the weapon that they're holding if we can.
	if ( inflictor && inflictor != NULL && attacker == inflictor && (inflictor:IsPlayer() || inflictor:IsNPC()) ) then
	
		inflictor = inflictor:GetActiveWeapon()
		if ( attacker == NULL ) then inflictor = attacker end
	
	end
	
	local InflictorClass = "World"
	local AttackerClass = "World"
	
	if ( inflictor && inflictor != NULL ) then InflictorClass = inflictor:GetClass() end
	if ( attacker  && attacker != NULL ) then AttackerClass = attacker:GetClass() end

	if ( attacker && attacker != NULL && attacker:IsPlayer() ) then
	
		umsg.Start( "PlayerKilledNPC" )
		
			umsg.String( ent:GetClass() )
			umsg.String( InflictorClass )
			umsg.Entity( attacker )
		
		umsg.End()
		
	return end
	
	umsg.Start( "NPCKilledNPC" )
	
		umsg.String( ent:GetClass() )
		umsg.String( InflictorClass )
		umsg.String( AttackerClass )
	
	umsg.End()

end


/*---------------------------------------------------------
   Name: gamemode:ScaleNPCDamage( ply, hitgroup, dmginfo )
   Desc: Scale the damage based on being shot in a hitbox
---------------------------------------------------------*/
function GM:ScaleNPCDamage( npc, hitgroup, dmginfo )

	// More damage if we're shot in the head
	 if ( hitgroup == HITGROUP_HEAD ) then
	 
		dmginfo:ScaleDamage( 10 )
	 
	 end
	 
	// Less damage if we're shot in the arms or legs
	if ( hitgroup == HITGROUP_LEFTARM ||
		 hitgroup == HITGROUP_RIGHTARM || 
		 hitgroup == HITGROUP_LEFTLEG ||
		 hitgroup == HITGROUP_RIGHTLEG ||
		 hitgroup == HITGROUP_GEAR ) then
	 
		dmginfo:ScaleDamage( 0.25 )
	 
	 end

end

