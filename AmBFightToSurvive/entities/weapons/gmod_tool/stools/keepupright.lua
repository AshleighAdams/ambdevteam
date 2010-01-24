
TOOL.Category		= "Construction"
TOOL.Name			= "#KeepUpright"
TOOL.Command		= nil
TOOL.ConfigName		= nil


TOOL.ClientConVar[ "angularlimit" ] = 100000

function TOOL:LeftClick( trace )

	if (!trace.Entity:IsValid() || trace.Entity:IsPlayer() ) then return false end

	// If there's no physics object then we can't constraint it!
	if ( SERVER && !util.IsValidPhysicsObject( trace.Entity, trace.PhysicsBone ) ) then return false end
	
	if ( CLIENT ) then return true end

	local Phys = trace.Entity:GetPhysicsObjectNum( trace.PhysicsBone )
	
	// Get client's CVars
	local angularlimit	= self:GetClientNumber( "angularlimit" )
	
	// Get information we're about to use
	local Ent  = trace.Entity
	local Bone = trace.PhysicsBone
	local Ang  = Phys:GetAngle()

	local constr = constraint.Keepupright( Ent, Ang, Bone, angularlimit )
	
		if (constr) then
		undo.Create("KeepUpright")
		undo.AddEntity( constr )
		undo.SetPlayer( self:GetOwner() )
		undo.Finish()
	
		self:GetOwner():AddCleanup( "constraints", constr )
	
	end
	
	return true
	
end

function TOOL:Reload( trace )

	if (!trace.Entity:IsValid() || trace.Entity:IsPlayer() ) then return false end
	if ( CLIENT ) then return true end
	
	local  bool = constraint.RemoveConstraints( trace.Entity, "Keepupright" )
	return bool
	
end
