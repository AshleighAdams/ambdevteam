
include( 'shared.lua' )
include( 'cl_gui.lua' )

function GM:CalcView(ply,pos,ang,fov)
	local rag = ply:GetRagdollEntity()
	if ValidEntity(rag) then
		local att = rag:GetAttachment(rag:LookupAttachment("eyes"))
		return self.BaseClass:CalcView(ply,att.Pos,att.Ang,fov)
	end
	return self.BaseClass:CalcView(ply,pos,ang,fov)
end

 
function UpdateTeamStats( um )
    /*
		umsg.Long( i )
		umsg.String( Teams[i].Name )
		umsg.Vector( Teams[i].Color )
		umsg.Entity( Teams[i].Owner )
	*/
	local Index = um:ReadLong()
	local Name = um:ReadString()
	local Col = um:ReadVector()
	local Owner = um:ReadEntity() -- not needed now but maybe later versions
	RealCol = Color(Col.x, Col.y, Col.z, 255)
	team.SetUp( Index, Name, RealCol )
end
usermessage.Hook("teamstats", UpdateTeamStats)