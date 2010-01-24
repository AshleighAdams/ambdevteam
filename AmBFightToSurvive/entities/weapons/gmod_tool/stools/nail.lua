
TOOL.Category		= "Constraints"
TOOL.Name			= "#Nail"
TOOL.Command		= nil
TOOL.ConfigName		= nil


TOOL.ClientConVar["forcelimit"] = "0"

TOOL.RightClickAutomatic = true

cleanup.Register( "nails" )

function TOOL:LeftClick( trace )

	// Bail if we hit world or a player
	if (  !trace.Entity:IsValid() || trace.Entity:IsPlayer() ) then return false end
	
	// If there's no physics object then we can't constraint it!
	if ( SERVER && !util.IsValidPhysicsObject( trace.Entity, trace.PhysicsBone ) ) then return false end
	
	local tr = {}
		tr.start = trace.HitPos
		tr.endpos = trace.HitPos + (self:GetOwner():GetAimVector() * 16.0)
		tr.filter = { self:GetOwner(), trace.Entity }
	local trTwo = util.TraceLine( tr )
	
	if ( trTwo.Hit && !trTwo.Entity:IsPlayer() ) then

		// Get client's CVars
		local forcelimit = self:GetClientNumber( "forcelimit" )

		// Client can bail now
		if ( CLIENT ) then return true end

		local vOrigin = trace.HitPos - (self:GetOwner():GetAimVector() * 8.0)
		local vDirection = self:GetOwner():GetAimVector():Angle()

		vOrigin = trace.Entity:WorldToLocal( vOrigin )

		// Weld them!
		local constraint, nail = MakeNail( trace.Entity, trTwo.Entity, trace.PhysicsBone, trTwo.PhysicsBone, forcelimit, vOrigin, vDirection )
		if !constraint:IsValid() then return end

		undo.Create("Nail")
		undo.AddEntity( constraint )
		undo.AddEntity( nail )
		undo.SetPlayer( self:GetOwner() )
		undo.Finish()

		self:GetOwner():AddCleanup( "nails", constraint )		
		self:GetOwner():AddCleanup( "nails", nail )

		return true

	end

end

function MakeNail( Ent1, Ent2, Bone1, Bone2, forcelimit, Pos, Ang )

	local constraint = constraint.Weld( Ent1, Ent2, Bone1, Bone2, forcelimit, false )
	
	constraint.Type = "Nail"
	constraint.Pos = Pos
	constraint.Ang = Ang

	Pos = Ent1:LocalToWorld( Pos )

	local nail = ents.Create( "gmod_nail" )
		nail:SetPos( Pos )
		nail:SetAngles( Ang )
		nail:SetParentPhysNum( Bone1 )
		nail:SetParent( Ent1 )

	nail:Spawn()
	nail:Activate()

	constraint:DeleteOnRemove( nail )

	return constraint, nail
end

duplicator.RegisterConstraint( "Nail", MakeNail, "Ent1", "Ent2", "Bone1", "Bone2", "forcelimit", "Pos", "Ang" )

function TOOL:RightClick( trace )

	self:GetWeapon():SetNextSecondaryFire( CurTime() + 0.2 )
	return self:LeftClick( trace )
	
end

function TOOL:Reload( trace )

	if (!trace.Entity:IsValid() || trace.Entity:IsPlayer() ) then return false end
	if ( CLIENT ) then return true end
	
	local  bool = constraint.RemoveConstraints( trace.Entity, "Nail" )
	return bool
	
end
