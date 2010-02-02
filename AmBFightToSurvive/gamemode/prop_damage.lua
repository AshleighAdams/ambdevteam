function f2sEntityTakeDamage( ent, inflictor, attacker, amount )
	owner = ent:GetNetworkedEntity("OwnerObj", false)
	if owner && ValidEntity( owner ) && owner:Team() != ent.Team then
		if ent.State then
			state = ent:GetState()
			if state == STATE_UNCONSTRUCTED || state == STATE_CONSTRUCTING || state == STATE_UNCONSTRUCTING then
				ent.ResNeeded = ent.ResNeeded + ( amount / 10 )
				if ent.ResNeeded - 10 > ent.Cost then
					ent:Remove()				
				end
			end
			if state == STATE_CONSTRUCTED  then
				ent.ResNeeded = ent.ResNeeded + ( amount / 10 )
				damage = ent.Cost - ent.ResNeeded
				if damage < 0 then
					ent:Remove()
				end
			end
		end
	end
end
hook.Add( "EntityTakeDamage", "f2s.enttakedmg", f2sEntityTakeDamage )