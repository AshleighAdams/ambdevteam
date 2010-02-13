STATE_CONSTRUCTED, STATE_UNCONSTRUCTED, STATE_CONSTRUCTING, STATE_UNCONSTRUCTING = 1, 2, 3, 4

--------------------------------------------
-- Flickers a prop.
--------------------------------------------
local function ReceiveFlicker(UM)
	local ent = UM:ReadEntity()
	local tex = UM:ReadString()
	local back = UM:ReadString()
	local time = UM:ReadFloat()
	
	--- Currently not being used becuase people could peer though them when they got shot
	/*
	if ent:IsValid() then
		ent:SetMaterial(tex)
		timer.Simple(time, function(ent, back)
				if ent:IsValid() then
					ent:SetMaterial(back)
				end
			end, ent, back)
	end
	*/
	
	--- make an eddect to the entity -- propspawn for spawning
	-- this is a lot more suibible for out needs, simple and effective.
	
	local ed = EffectData()
		ed:SetEntity( ent )
	util.Effect( "entity_remove", ed, true, true )
	
end
usermessage.Hook("flicker_prop", ReceiveFlicker)

-------------------------------------------
-----  These are to show when a prop is constructing or deconstucting
-------------------------------------------
function DrawEffects(ent)
	if ent and ValidEntity(ent) then
		if ent.State != STATE_CONSTRUCTING and ent.State != STATE_UNCONSTRUCTING then return end
		local ed = EffectData()
			ed:SetEntity( ent )
		util.Effect( "propspawn", ed, true, true )
		timer.Simple(1,DrawEffects,ent)
	end
end
function StateChangeEffect(um)
	local state = um:ReadShort()
	local ent = um:ReadEntity()
	ent.State = state
	if state == STATE_CONSTRUCTING || state == STATE_UNCONSTRUCTING then
		DrawEffects(ent)
	end
end
usermessage.Hook("state_change", StateChangeEffect)

--------------------------------------------
-- Updates a prop with data from the server.
--------------------------------------------
function UpdateProp(Prop)
	Prop.Registered = Prop:GetNWBool("Registered", false)
	if Prop.Registered then
		Prop.Constructed = Prop:GetNWBool("Constructed", false)
		Prop.State = Prop:GetNWInt("State", 0)
		Prop.Team = Prop:GetNWInt("Team", 0)
		Prop.ResNeeded = Prop:GetNWFloat("ResNeeded", 0.0)
		Prop.Cost = Prop:GetNWFloat("Cost", 0.0)
	end
end

function PropKilled(um)
	local ent = um:ReadEntity()
	if !ValidEntity(ent) then return end
	local ed = EffectData()
		ed:SetEntity( ent )
	util.Effect( "entity_remove", ed, true, true )
end
usermessage.Hook("propdeadeffect",PropKilled)