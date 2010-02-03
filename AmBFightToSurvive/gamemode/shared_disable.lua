-- Gets if the specified player is an admin
local function Admin(Player)
	return Player:IsAdmin()
end

-- Disable sents from the spawn menu
if SERVER then
	local OutstandingSpawns = { }
	local function NonPropSpawn(Player)
		if Admin(Player) then
			return true
		else
			if OutstandingSpawns[Player] > 0 then
				OutstandingSpawns[Player] = OutstandingSpawns[Player] - 1
				return true
			else
				Player:ChatPrint("Spawn disallowed, only props may be spawned from the spawn menu" ..
					". You may use the store(F4) to purchase this instead.")
				return false
			end
		end
	end
	hook.Add("PlayerSpawnSENT", "NonPropSpawn", NonPropSpawn)
	hook.Add("PlayerSpawnNPC", "NonPropSpawn", NonPropSpawn)
	hook.Add("PlayerSpawnSWEP", "NonPropSpawn", NonPropSpawn)
	hook.Add("PlayerSpawnVehicle", "NonPropSpawn", NonPropSpawn)
	hook.Add("PlayerSpawnEffect", "NonPropSpawn", NonPropSpawn)
	hook.Add("PlayerSpawnRagdoll", "NonPropSpawn", NonPropSpawn)
	
	-- Safely spawns an entity of the specified class 
	-- in front of the player. returns the spawned
	-- entity.
	function Spawn(Player, Class)
		local eye = Player:GetEyeTrace()
		local dif = eye.HitPos - Player:GetPos()
		local ent = ents.Create(Class)
		local height = ent:OBBMins().z
		ent:SetPos(eye.HitPos + Vector(0, 0, height))
		ent:Spawn()
		return ent
	end
	
	-- Vehicles spawn differently
	function SpawnVehicle(Player, Class)
		OutstandingSpawns[Player] = (OutstandingSpawns[Player] or 0) + 1
		Player:ConCommand("gm_spawnvehicle " .. Class)
	end
end

-- Only props may be picked up with the physgun
local function PhysgunPickup(Player, Entity)
	if not Admin(Player) then
		if Entity:GetClass() ~= "prop_physics" then
			return false
		end
	end
end
hook.Add("PhysgunPickup", "DisablePhysgunPickup", PhysgunPickup)