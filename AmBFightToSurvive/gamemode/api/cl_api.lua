TeamsRes = TeamsRes or {}

function GetResP( t )
	if TeamsRes[t] == nil then return 0 end
	return TeamsRes[t].ResP or 0
end

function TeamHasMembers( t )
	for v,ply in pairs( player.GetAll() ) do
		if ply:Team() == t then return true end
	end
	return false
end

function UpdateResources( um )
	local Index = um:ReadLong() or 0
	local ResP = um:ReadLong() or 0
	local SciP = um:ReadLong() or 0
	TeamsRes[Index] = {}
	TeamsRes[Index].ResP = ResP
	TeamsRes[Index].SciP = SciP
end

function GetEntCost( ent )
	if ent != nil then
		sizevec = ent:OBBMaxs() - ent:OBBMins()
		size = (sizevec.x * sizevec.x + sizevec.y * sizevec.y + sizevec.z * sizevec.z) ^ 0.5
		phys = ent:GetPhysicsObject()
		if phys then
			mass = phys:GetMass()
		else
			mass = 20
		end
		cost = math.ceil( (size/10) + (mass/10) )
		return cost
	end
end

usermessage.Hook( "resources_update", UpdateResources )