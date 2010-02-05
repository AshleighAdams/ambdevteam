-- Gets if the specified player is an admin
local function Admin(Player)
	if Player:IsAdmin() then
		Player:ChatPrint("Performed Admin Action")
		return true
	else
		return false
	end
end

-- Disable sents from the spawn menu
if SERVER then
	local function NonPropSpawn(Player)
		if Admin(Player) then
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
		return Admin(Player)
	end
end
hook.Add("PhysgunPickup", "DisablePhysgunPickup", PhysgunPickup)