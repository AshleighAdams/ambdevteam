-- Note that the damage system is independant
-- of the prop system. The damage system is
-- only to allow non-props which dont get
-- damage by default, to be destroyed.

local DamagableEntities = { }
--------------------------------------------
-- Enables damage for an entity. The entity
-- will start out with max health and lose
-- health until the damagin stops or the 
-- health drops to zero. Entities whose health
-- is at zero will be removed. If the last
-- time an entity was damaged was more then
-- a restoration time ago, its health will
-- be restored to maxhealth.
--------------------------------------------
function EnableDamage(Entity, MaxHealth, RestorationTime)
	local de = DamagableEntities
	Entity.MaxHealth = MaxHealth or 100
	Entity.RestorationTime = RestorationTime or 10.0
	Entity.CurrentHealth = de.MaxHealth
	Entity.OnTakeNormalDamage = function(ent, info)
		ent.CurrentHealth = ent.CurrentHealth - info:GetDamage()
		ent.LastDamageTime = CurTime()
		if ent.CurrentHealth < 0 then
			umsg.Start("propdeadeffect")
				umsg.Entity(ent)
			umsg.End()
			timer.Simple( 0.1, function(ent)
				ent:Remove()
			end,ent)
		end
	end
	Entity.RestoreHealth = function(ent)
		ent.CurrentHealth = ent.MaxHealth
	end
	de[Entity] = true
end

--------------------------------------------
-- Think hook for damage system.
--------------------------------------------
local function EntityCheckRestoration()
	local curtime = CurTime()
	for e, a in pairs(DamagableEntities) do
		if a and e:IsValid() then
			-- Check if restoration is needed.
			if (e.LastDamageTime or 0.0) + e.RestorationTime < curtime then
				-- Restore
				e:RestoreHealth()
			end
		else
			DamagableEntities[e] = nil
		end
	end
end
timer.Create("EntityCheckRestoration", 1.0, 0, EntityCheckRestoration)

--------------------------------------------
-- Hook for entity damage.
--------------------------------------------
function GM:EntityTakeDamage(Entity, Inflictor, Attacker, Amount, Info)
	if Entity.OnTakeNormalDamage then
		Entity:OnTakeNormalDamage(Info)
	end
end