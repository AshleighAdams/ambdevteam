TeamsRes = TeamsRes or {}

function ResInit( t )
	if t == 1 then
		TeamsRes[t] = {}
		TeamsRes[t].ResP = 0
		TeamsRes[t].SciP = 0
	else
		TeamsRes[t] = {}
		TeamsRes[t].ResP = 750
		TeamsRes[t].SciP = 0
	end
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

function GetSciP( t )
	if TeamsRes[t] == nil then return 0 end
	return TeamsRes[t].SciP or 0
end

function SetResP( t, ammount )
	if TeamsRes[t] == nil then return 0 end
	TeamsRes[t].ResP = ammount
end

function SetSciP( t, ammount )
	if TeamsRes[t] == nil then return 0 end
	TeamsRes[t].SciP = ammount
end

function GiveResP( t, ammount )
	SetResP( t, GetResP(t) + ammount )
end

function GiveSciP( t, ammount )
	SetSciP( t, GetSciP(t) + ammount )
end

function TakeResP( t, ammount )
	if GetResP(t) >= ammount then
		SetResP( t, GetResP(t) - ammount )
		return true
	else
		return false
	end
end

function TakeSciP( t, ammount )
	if GetSciP(t) >= ammount then
		SetSciP( t, GetSciP(t) - ammount )
		return true
	else
		return false
	end
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
		cost = math.ceil( (size/20) + (mass/20) )
		return cost
	end
end

local PayDayAmount = 25
local function PayDay()
	for teamid,Team in pairs( Teams ) do
		if teamid > 1 then
			GiveResP( teamid, PayDayAmount )
		end
	end
end
timer.Create( "f2s.Res.PayDayTimer", 60, 0, PayDay ) -- disabled for now