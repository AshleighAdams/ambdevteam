
TOOL.Category		= "Constraints"
TOOL.Name			= "#Ball Socket - Easy"
TOOL.Command		= nil
TOOL.ConfigName		= nil


TOOL.ClientConVar[ "forcelimit" ] = "0"
TOOL.ClientConVar[ "torquelimit" ] = "0"
TOOL.ClientConVar[ "nocollide" ] = "0"

function TOOL:LeftClick( trace )

	if ( trace.Entity:IsValid() && trace.Entity:IsPlayer() ) then return end
	
	// If there's no physics object then we can't constraint it!
	if ( SERVER && !util.IsValidPhysicsObject( trace.Entity, trace.PhysicsBone ) ) then return false end

	local iNum = self:NumObjects()
	
	local Phys = trace.Entity:GetPhysicsObjectNum( trace.PhysicsBone )
	
	// Don't allow us to choose the world as the first object
	if (iNum == 0 && !trace.Entity:IsValid()) then return end
	
	// Don't allow us to choose the same object
	if (iNum == 1 && trace.Entity == self:GetEnt(1) ) then return end
	
	self:SetObject( iNum + 1, trace.Entity, trace.HitPos, Phys, trace.PhysicsBone, trace.HitNormal )
	
	if ( iNum > 0 ) then
	
		if ( CLIENT ) then
		
			self:ClearObjects()
			self:ReleaseGhostEntity()
			
			return true
			
		end
		
		// Get client's CVars
		local forcelimit = self:GetClientNumber( "forcelimit" )
		local torquelimit = self:GetClientNumber( "torquelimit" )
		local nocollide = self:GetClientNumber( "nocollide" )
		
		local Ent1,  Ent2  = self:GetEnt(1),	 self:GetEnt(2)
		local Bone1, Bone2 = self:GetBone(1),	 self:GetBone(2)
		local Norm1, Norm2 = self:GetNormal(1),	 self:GetNormal(2)
		local WPos	   = self:GetPos(2)
		local LPos	   = self:GetLocalPos(2)
		local Phys	   = self:GetPhys(1)

		// Note: To keep stuff ragdoll friendly try to treat things as physics objects rather than entities
		local Ang1, Ang2 = Norm1:Angle(), (Norm2 * -1):Angle()
		local TargetAngle = Phys:AlignAngles( Ang1, Ang2 )

		Phys:SetAngle( TargetAngle )

		// Move the object so that the hitpos on our object is at the second hitpos
		local TargetPos = WPos + (Phys:GetPos() - self:GetPos(1)) + (Norm2)

		// Offset slightly so it can rotate
		TargetPos = TargetPos + Norm2

		// Set the position
		Phys:SetPos( TargetPos )

		// Wake up the physics object so that the entity updates
		Phys:Wake()

		// Create a constraint axis
		local constraint = constraint.Ballsocket( Ent1, Ent2, Bone1, Bone2, LPos, forcelimit, torquelimit, nocollide )

		undo.Create("BallSocket")
		undo.AddEntity( constraint )
		undo.SetPlayer( self:GetOwner() )
		undo.Finish()
		
		self:GetOwner():AddCleanup( "constraints", constraint )
		
		// Clear the objects so we're ready to go again
		self:ClearObjects()
		self:ReleaseGhostEntity()
		
	else
	
		self:StartGhostEntity( trace.Entity )
		self:SetStage( iNum+1 )
		
	end
	
	return true

end

function TOOL:Think()

	if (self:NumObjects() != 1) then return end
	
	self:UpdateGhostEntity()
	
end

function TOOL:Reload( trace )

	if (!trace.Entity:IsValid() || trace.Entity:IsPlayer() ) then return false end
	if ( CLIENT ) then return true end
	
	local  bool = constraint.RemoveConstraints( trace.Entity, "BallSocket" )
	return bool

end
