
TOOL.Category		= "Constraints"
TOOL.Name			= "#Weld - Easy"
TOOL.Command		= nil
TOOL.ConfigName		= nil


TOOL.ClientConVar[ "forcelimit" ]	= "0"
TOOL.ClientConVar[ "nocollide" ]	= "0"

local axis = 0

function TOOL:LeftClick( trace )

	// Make sure the object we're about to use is valid
	local iNum = self:NumObjects()
	local Phys = trace.Entity:GetPhysicsObjectNum( trace.PhysicsBone )
	
	// You can click anywhere on the 3rd pass
	if ( iNum < 2 ) then
	
		// If there's no physics object then we can't constraint it!
		if (  SERVER && !util.IsValidPhysicsObject( trace.Entity, trace.PhysicsBone ) ) then return false end
		
		// Don't weld players, or to players
		if ( trace.Entity:IsPlayer() ) then return false end
	
		// Don't do anything with stuff without any physics..
		if ( SERVER && !Phys:IsValid() ) then return false end
		
	end

	if (iNum == 0) then
	
		if ( !trace.Entity:IsValid() ) then return false end
		if ( trace.Entity:GetClass() == "prop_vehicle_jeep" ) then return false end
		
	end

	self:SetObject( iNum + 1, trace.Entity, trace.HitPos, Phys, trace.PhysicsBone, trace.HitNormal )
	
	if ( iNum > 1 ) then
	
		if ( CLIENT ) then
		
			self:ClearObjects()
			return true
			
		end
		
		// Get client's CVars
		local forcelimit = self:GetClientNumber( "forcelimit" )
		local nocollide  = ( self:GetClientNumber( "nocollide" ) == 1 )
	
		// Get information we're about to use
		local Ent1,  Ent2  = self:GetEnt(1),    self:GetEnt(2)
		local Bone1, Bone2 = self:GetBone(1),   self:GetBone(2)
		local Phys1 = self:GetPhys(1)

		// Something happened, the entity became invalid half way through
		// Finish it.
		if ( !Ent1:IsValid() ) then
		
			self:ClearObjects()
			return false
		
		end
	
		local constraint = constraint.Weld( Ent1, Ent2, Bone1, Bone2, forcelimit, nocollide )
		if (!constraint) then return false end
		
		Phys1:EnableMotion( true )
		
		undo.Create("Weld")
		undo.AddEntity( constraint )
		undo.SetPlayer( self:GetOwner() )
		undo.Finish()
		
		self:GetOwner():AddCleanup( "constraints", constraint )
		
		// Clear the objects so we're ready to go again
		self:ClearObjects()
		
	elseif ( iNum == 1 ) then
	
		if ( CLIENT ) then
		
			self:ReleaseGhostEntity()
			return true
			
		end
		
		// Get information we're about to use
		local Ent1,  Ent2  = self:GetEnt(1),      self:GetEnt(2)
		local Bone1, Bone2 = self:GetBone(1),     self:GetBone(2)
		local WPos1, WPos2 = self:GetPos(1),      self:GetPos(2)
		local LPos1, LPos2 = self:GetLocalPos(1), self:GetLocalPos(2)
		local Norm1, Norm2 = self:GetNormal(1),   self:GetNormal(2)
		local Phys1, Phys2 = self:GetPhys(1),     self:GetPhys(2)
		
		// Note: To keep stuff ragdoll friendly try to treat things as physics objects rather than entities
		local Ang1, Ang2 = Norm1:Angle(), (Norm2 * -1):Angle()
		local TargetAngle = Phys1:AlignAngles( Ang1, Ang2 )
		
		Phys1:SetAngle( TargetAngle )
		
		// Move the object so that the hitpos on our object is at the second hitpos
		local TargetPos = WPos2 + (Phys1:GetPos() - self:GetPos(1)) + (Norm2)
		
		// Set the position
		Phys1:SetPos( TargetPos )
		Phys1:EnableMotion( false )
		
		// Wake up the physics object so that the entity updates
		Phys1:Wake()
			
		axis = Norm2

		self:ReleaseGhostEntity()

		self:SetStage( iNum+1 )
		
	else
	
		self:StartGhostEntity( trace.Entity )
	
		self:SetStage( iNum+1 )
		
	end

	return true

end

function TOOL:Think()

	if (self:NumObjects() < 1) then return end
	
	if ( SERVER ) then
		
		local Ent1 = self:GetEnt(1)
		
		if ( !Ent1:IsValid() ) then
		
			self:ClearObjects()
			return
		
		end
		
	end
	
	if (self:NumObjects() == 1) then	
	
		self:UpdateGhostEntity()
		
	else
	
		if ( SERVER ) then
			
			local Phys1 = self:GetPhys(1)
			local LPos1, LPos2 = self:GetLocalPos(1), self:GetLocalPos(2)
			local WPos1, WPos2 = self:GetPos(1), self:GetPos(2)
			
			local cmd = self:GetOwner():GetCurrentCommand()
			
			local degrees = cmd:GetMouseX() * 0.05
			
			local angle = Phys1:RotateAroundAxis( axis , degrees )
			
			Phys1:SetAngle( angle )
			
			// Move so spots join up
			local Norm2 = self:GetNormal(2)
			local TargetPos = WPos2 + (Phys1:GetPos() - self:GetPos(1)) + (Norm2)
			Phys1:SetPos( TargetPos )
			Phys1:Wake()
			
		end
		
	end
	
end

function TOOL:Reload( trace )

	if (!trace.Entity:IsValid() || trace.Entity:IsPlayer() ) then return false end
	if ( CLIENT ) then return true end
	
	local  bool = constraint.RemoveConstraints( trace.Entity, "Weld" )
	return bool
	
end

if ( CLIENT ) then

function TOOL:FreezeMovement()

	local iNum = self:GetStage()
	
	if ( iNum > 1 ) then
		return true
	end
	
	return false
	
end

end

function TOOL:Holster()

	self:ClearObjects()
	
end
