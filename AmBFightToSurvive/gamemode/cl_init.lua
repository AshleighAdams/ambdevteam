
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