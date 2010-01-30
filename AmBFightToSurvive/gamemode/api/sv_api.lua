TeamRes = TeamRes or {}

function Init( t )
	TeamRes[t] = {}
	TeamRes[t].ResP = 500
	TeamRes[t].SciPoints = 0
	UpdateTeamInfo()
	hook.Call( "TeamSetUp", t )
end

function UpdateTeamInfo( pl )

end

function GetResP( t )

end

function SetResP( t )

end

function GiveResP( t, ammount )

end

function TakeResP( t, ammount )

end

function CreateResource( pos )

end

function CreateResourceDrop( pos, team )
	hook.Call( "ResourceCaptured", team )
end

