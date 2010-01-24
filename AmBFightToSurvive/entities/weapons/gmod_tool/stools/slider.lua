
TOOL.Category		= "Constraints"
TOOL.Name			= "#Slider"
TOOL.Command		= nil
TOOL.ConfigName		= nil


TOOL.ClientConVar[ "width" ] = "1.5"
TOOL.ClientConVar[ "forcelimit" ] = "0"

function TOOL:LeftClick( trace )

	if ( trace.Entity:IsValid() && trace.Entity:IsPlayer() ) then return end
	
	// If there's no physics object then we can't constraint it!
	if ( SERVER && !util.IsValidPhysicsObject( trace.Entity, trace.PhysicsBone ) ) then return false end
	
	local iNum = self:NumObjects()

	local Phys = trace.Entity:GetPhysicsObjectNum( trace.PhysicsBone )
	self:SetObject( iNum + 1, trace.Entity, trace.HitPos, Phys, trace.PhysicsBone, trace.HitNormal )
	
	if ( iNum > 0 ) then
	
		if ( !self:GetEnt(1):IsValid() && !self:GetEnt(2):IsValid() ) then return end
		
		if ( CLIENT ) then
			self:ClearObjects()
			return true
		end
		
		// Get client's CVars
		local width		= self:GetClientNumber( "width" ) or 1.5
		
		// Get information we're about to use
		local Ent1,  Ent2  = self:GetEnt(1),	 self:GetEnt(2)
		local Bone1, Bone2 = self:GetBone(1),	 self:GetBone(2)
		local LPos1, LPos2 = self:GetLocalPos(1),self:GetLocalPos(2)

		local constraint,rope = constraint.Slider( Ent1, Ent2, Bone1, Bone2, LPos1, LPos2, width )

		undo.Create("Slider")
		undo.AddEntity( constraint )
		if rope then undo.AddEntity( rope ) end
		undo.SetPlayer( self:GetOwner() )
		undo.Finish()
		
		self:GetOwner():AddCleanup( "ropeconstraints", constraint )
		self:GetOwner():AddCleanup( "ropeconstraints", rope )

		// Clear the objects so we're ready to go again
		self:ClearObjects()
		
	else
	
		self:SetStage( iNum+1 )
		
	end
	
	return true

end

function TOOL:RightClick( trace )

	local iNum = self:NumObjects()

	local Phys = trace.Entity:GetPhysicsObjectNum( trace.PhysicsBone )
	self:SetObject( 1, trace.Entity, trace.HitPos, Phys, trace.PhysicsBone, trace.HitNormal )
	
	local tr = {}
	tr.start = trace.HitPos
	tr.endpos = tr.start + (trace.HitNormal * 16384)
	tr.filter = {} 
	tr.filter[1] = self:GetOwner()
	if (trace.Entity:IsValid()) then
		tr.filter[2] = trace.Entity
	end
	
	local tr = util.TraceLine( tr )
		
	if ( !tr.Hit ) then
		self:ClearObjects()
		return
	end
	
	// Don't try to constrain world to world
	if ( trace.HitWorld && tr.HitWorld ) then
		self:ClearObjects()
		return 
	end
	
	if ( trace.Entity:IsValid() && trace.Entity:IsPlayer() ) then
		self:ClearObjects()
		return
	end
	if ( tr.Entity:IsValid() && tr.Entity:IsPlayer() ) then
		self:ClearObjects()
		return
	end

	local Phys2 = tr.Entity:GetPhysicsObjectNum( tr.PhysicsBone )
	self:SetObject( 2, tr.Entity, tr.HitPos, Phys2, tr.PhysicsBone, trace.HitNormal )
	
	if ( CLIENT ) then
		self:ClearObjects()
		return true
	end
	
	local width		= self:GetClientNumber( "width" ) or 1.5
		
	// Get information we're about to use
	local Ent1,  Ent2  = self:GetEnt(1),	 self:GetEnt(2)
	local Bone1, Bone2 = self:GetBone(1),	 self:GetBone(2)
	local LPos1, LPos2 = self:GetLocalPos(1),self:GetLocalPos(2)

	local constraint,rope = constraint.Slider( Ent1, Ent2, Bone1, Bone2, LPos1, LPos2, width )

	undo.Create("Slider")
	undo.AddEntity( constraint )
	if rope then undo.AddEntity( rope ) end
	undo.SetPlayer( self:GetOwner() )
	undo.Finish()
	
	self:GetOwner():AddCleanup( "ropeconstraints", constraint )
	self:GetOwner():AddCleanup( "ropeconstraints", rope )

	// Clear the objects so we're ready to go again
	self:ClearObjects()
	
	return true

end

function TOOL:Reload( trace )

	if (!trace.Entity:IsValid() || trace.Entity:IsPlayer() ) then return false end
	if ( CLIENT ) then return true end
	
	local  bool = constraint.RemoveConstraints( trace.Entity, "Slider" )
	return bool
	
end
