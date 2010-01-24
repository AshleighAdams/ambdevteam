
TOOL.Category		= "Constraints"
TOOL.Name			= "#Elastic"
TOOL.Command		= nil
TOOL.ConfigName		= nil


TOOL.ClientConVar[ "constant" ] = "250"
TOOL.ClientConVar[ "damping" ] = "3"
TOOL.ClientConVar[ "rdamping" ] = "0.01"
TOOL.ClientConVar[ "material" ] = "cable/cable"
TOOL.ClientConVar[ "width" ] = "2"
TOOL.ClientConVar[ "stretch_only" ] = "0"

function TOOL:LeftClick( trace )

	if ( trace.Entity:IsValid() && trace.Entity:IsPlayer() ) then return end
	
	// If there's no physics object then we can't constraint it!
	if ( SERVER && !util.IsValidPhysicsObject( trace.Entity, trace.PhysicsBone ) ) then return false end
	
	local iNum = self:NumObjects()

	local Phys = trace.Entity:GetPhysicsObjectNum( trace.PhysicsBone )
	self:SetObject( iNum + 1, trace.Entity, trace.HitPos, Phys, trace.PhysicsBone, trace.HitNormal )
	
	if ( iNum > 0 ) then
	
		if ( CLIENT ) then
		
			self:ClearObjects()
			return true
			
		end
		
		// Get client's CVars
		local constant		= self:GetClientNumber( "constant" )
		local damping		= self:GetClientNumber( "damping" )
		local rdamping		= self:GetClientNumber( "rdamping" )
		local material 		= self:GetClientInfo( "material" )
		local width 		= self:GetClientNumber( "width" )
		local stretchonly	= self:GetClientNumber( "stretch_only" )
		
		// Get information we're about to use
		local Ent1,  Ent2  = self:GetEnt(1),	 	self:GetEnt(2)
		local Bone1, Bone2 = self:GetBone(1),	 	self:GetBone(2)
		local LPos1, LPos2 = self:GetLocalPos(1),	self:GetLocalPos(2)
		local constraint, rope = constraint.Elastic( Ent1, Ent2, Bone1, Bone2, LPos1, LPos2, constant, damping, rdamping, material, width, stretchonly )

		// Add The constraint to the players undo table

		undo.Create("Elastic")
		undo.AddEntity( constraint )
		if rope then undo.AddEntity( rope ) end
		undo.SetPlayer( self:GetOwner() )
		undo.Finish()
		
		self:GetOwner():AddCleanup( "ropeconstraints", constraint )
		if rope then self:GetOwner():AddCleanup( "ropeconstraints", rope ) end

		// Clear the objects so we're ready to go again
		self:ClearObjects()
	
	else
	
		self:SetStage( iNum+1 )
	
	end
	
	return true

end

function TOOL:Reload( trace )

	if (!trace.Entity:IsValid() || trace.Entity:IsPlayer() ) then return false end
	if ( CLIENT ) then return true end
	
	local  bool = constraint.RemoveConstraints( trace.Entity, "Elastic" )
	return bool
	
end
