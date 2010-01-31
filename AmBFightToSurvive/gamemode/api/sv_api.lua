TeamsRes = TeamsRes or {}

function ResInit( t )
	TeamsRes[t] = {}
	TeamsRes[t].ResP = 500
	TeamsRes[t].SciP = 0
	UpdateClients()
end
//hook.Add( "ResInitTeam", "f2s.Res.InitTeam", Init )

function UpdateClients( pl )
	if pl then
		local rp = pl
	else
		local rp = RecipientFilter()
		rp:AddAllPlayers()
	end
	for i,TeamRes in pairs( TeamsRes ) do
		umsg.Start( "resources_update", rp )
			umsg.Long( i )
			umsg.Long( TeamRes.ResP or 0 )
			umsg.Long( TeamRes.SciP or 0 )
		umsg.End()
	end
end
timer.Create( "f2s.Res.UpdateClients", 1, 0, UpdateClients )

function GetResP( t )
	if TeamsRes[t] == nil then return 0 end
	return TeamsRes[t].ResP or 0
end

function SetResP( t, ammount )
	if TeamsRes[t] == nil then return 0 end
	TeamsRes[t].ResP = ammount
end

function GiveResP( t, ammount )
	SetResP( t, GetResP(t) + ammount )
end

function TakeResP( t, ammount )
	SetResP( t, GetResP(t) - ammount )
end

function VoidTakeResP( t, ammount )
	if GetResP(t) < ammount then
		oldAmmount = GetResP(t)
		SetResP( t, math.max(0,oldAmmount - ammount) )
		local newAmmount = GetResP(t)
		local taken = oldAmmount - newAmmount
		TakeResP( t, taken )
		return taken
	else
		TakeResP( t, ammount )
		return ammount
	end
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

function PayDay()
	for teamid,Team in pairs( Teams ) do
		if teamid != 1 then
			GiveResP( teamid, 200 )
		end
	end
end
timer.Create( "f2s.Res.PayDayTimer", 60, 0, PayDay )