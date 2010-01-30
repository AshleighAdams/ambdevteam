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

function CreateResource( pos )

end

function CreateResourceDrop( pos, t )
	//hook.Call( "ResourceCaptured", t )
end

function PayDay()
	for teamid,Team in pairs( Teams ) do
		if teamid != 1 then
			GiveResP( teamid, 200 )
		end
	end
end
timer.Create( "f2s.Res.PayDayTimer", 60, 0, PayDay )