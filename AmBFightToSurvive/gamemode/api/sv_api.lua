TeamsRes = TeamsRes or {}

function ResInit( t )
	TeamsRes[t] = {}
	TeamsRes[t].ResP = 500
	TeamsRes[t].SciPoints = 0
	UpdateTeamInfo()
end
//hook.Add( "ResInitTeam", "f2s.Res.InitTeam", Init )

function UpdateTeamInfo( pl )
	//TeamRes = TeamsRes[t]

end

function GetResP( t )
	return TeamsRes[t].ResP or 0
end

function SetResP( t, ammount )
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
	hook.Call( "ResourceCaptured", t )
end

function PayDay()
	for teamid,Team in pairs( Teams ) do
		if teamid == 1 then continue end
		GiveResP( teamid, 200 )
	end
end
timer.Create( "f2s.Res.PayDayTimer", 60, 0, PayDay )