-- Concommand for control admin rights
-- 0 = disabled
-- 1 = notified
-- 2 = enabled
local AdminRights = CreateConVar( "sv_adminrights", "1", {FCVAR_ARCHIVE, FCVAR_REPLICATED, FCVAR_NOTIFY} )

-- Gets if the specified player is an admin
function Admin(Player, Message)
	local adminrights = AdminRights:GetInt()
	if Player:IsAdmin() then
		if adminrights == 0 then
			Player:ChatPrint("Can not comply, admin rights is disabled")
			return false
		end
		if adminrights == 1 then
			for _, p in pairs(player.GetAll()) do
				if Message then
					p:ChatPrint(Player:Nick() .. " preformed admin action(" .. Message .. ")")
				else
					p:ChatPrint(Player:Nick() .. " preformed admin action")
				end
			end
			return true
		end
		if adminrights == 2 then
			return true
		end
	end
	return false
end

-- Disable sents from the spawn menu
if SERVER then
	local function NonPropSpawn(Player, Thing)
		if Admin(Player, "spawned nonprop " .. Thing or "<unknown>") then
			return true
		else
			Player:ChatPrint("Spawn disallowed, only props may be spawned from the spawn menu" ..
				". You may use the store(F4) to purchase this instead.")
			return false
		end
	end
	hook.Add("PlayerSpawnSENT", "NonPropSpawn", NonPropSpawn)
	hook.Add("PlayerSpawnSWEP", "NonPropSpawn", NonPropSpawn)
	hook.Add("PlayerSpawnVehicle", "NonPropSpawn", NonPropSpawn)
	hook.Add("PlayerSpawnEffect", "NonPropSpawn", NonPropSpawn)
	hook.Add("PlayerSpawnRagdoll", "NonPropSpawn", NonPropSpawn)
	
	-- Safely spawns an entity of the specified class 
	-- in front of the player. returns the spawned
	-- entity.
	function Spawn(Player, Class, Model, Keys, Offset)
		local eye = Player:GetEyeTrace()
		local dif = eye.HitPos - Player:GetPos()
		local ent = ents.Create(Class)
		local height = ent:OBBMins().z
		if Model then
			ent:SetModel(Model)
		end
		if ent:IsNPC() then
			ent:SetKeyValue("spawnflags", SF_NPC_FADE_CORPSE | SF_NPC_ALWAYSTHINK)
		end
		if Keys then
			for k, v in pairs(Keys) do
				ent:SetKeyValue(k, v)
			end
		end
		ent:SetPos(eye.HitPos - Vector(0, 0, height) + (Offset or Vector(0.0, 0.0, 0.0)))
		ent.Team = Player:Team()
		ent.Legal = true
		ent:Spawn()
		ent:Activate()
		return ent
	end
	
	-- Vehicles spawn differently
	function SpawnVehicle(Player, Name)
		local vehicle = list.Get("Vehicles")[Name]
		if vehicle then
			return Spawn(Player, vehicle.Class, vehicle.Model, vehicle.KeyValues)
		else
			return nil
		end
	end
end

-- Only props may be picked up with the physgun
local function PhysgunPickup(Player, Entity)
	if Entity:GetClass() ~= "prop_physics" then
		return Admin(Player, "picked up " .. Entity:GetClass() .. " with physgun")
	end
end
hook.Add("PhysgunPickup", "DisablePhysgunPickup", PhysgunPickup)