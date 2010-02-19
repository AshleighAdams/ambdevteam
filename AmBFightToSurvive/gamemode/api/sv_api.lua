TeamsRes = TeamsRes or {}
ENT = ENT or _R.Entity
PLY = PLY or _R.Player
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
		local sizevec = ent:OBBMaxs() - ent:OBBMins()
		local size = (sizevec.x * sizevec.x + sizevec.y * sizevec.y + sizevec.z * sizevec.z) ^ 0.5
		local phys = ent:GetPhysicsObject()
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

function ENT:GetPPOwner()
	local owner = NullEntity()
	owner = self:GetNWEntity("OwnerObj")
	return owner
end

function PLY:Message( msg, title, hint )
	if self and ValidEntity(self) then -- make sure were valid
		title = title or "Message"
		
		msg = string.gsub( msg, "\"", "\\\"" ) -- Replace " with \" so on the client it is seen as " in a string and not the end of the quotes
		title = string.gsub( title, "\"", "\\\"" )
		
		msg = string.gsub( msg, "\n", "\\\n" )
		title = string.gsub( title, "\n", "\\\n" )
		
		//msg = string.gsub( msg, "\\", "\\\\" )
		//title = string.gsub( title, "\\", "\\\\" )
		local lua = ""
		if hint then
			lua = [[GAMEMODE:AddNotify("%s",%s,10)]]
			lua = string.format(lua,msg,hint)
		else
			lua = [[Derma_Message("%s","%s")]]
			lua = string.format(lua,msg,title)
		end
		self:SendLua(lua)
	end
end