

ENT.Type 			= "anim"

ENT.Spawnable			= false
ENT.AdminSpawnable		= false

AddCSLuaFile( "shared.lua" )


/*---------------------------------------------------------

---------------------------------------------------------*/
function ENT:Initialize()

	if (SERVER) then
		self:PhysicsInitBox( Vector() * -4, Vector() * 4 )
	end
	
	if (CLIENT) then
		self:SetRagdollBones( true )
	end

end


/*---------------------------------------------------------
	Name: SetBonePosition (serverside)
---------------------------------------------------------*/
function ENT:SetNetworkedBonePosition( i, Pos, Angle )

	self:SetNetworkedVector( "Vector" .. i, Pos )
	self:SetNetworkedAngle( "Angle" .. i, Angle )

end


/*---------------------------------------------------------
	Name: Draw (clientside)
---------------------------------------------------------*/
function ENT:Draw()

	// Don't draw it if we're a ragdoll and haven't  
	// received all of the bone positions yet.
	local NumModelPhysBones = self:GetModelPhysBoneCount()
	if (NumModelPhysBones > 1) then
	
		if ( !self:GetNetworkedVector( "Vector0", false ) ) then
			return
		end
		
	end

	self.BaseClass.Draw( self )
	
end

/*---------------------------------------------------------
   Name: DoRagdollBone (clientside)
---------------------------------------------------------*/
function ENT:DoRagdollBone( PhysBoneNum, BoneNum )

	// Get the networked vars
	local Pos = self:GetNetworkedVector( "Vector" .. PhysBoneNum );
	local Angle = self:GetNetworkedAngle( "Angle" .. PhysBoneNum );

	// Convert them to worldspace
	Pos = self:LocalToWorld( Pos )
	Angle = self:LocalToWorldAngles( Angle )
	
	// Set us up the bone
	self:SetBonePosition( BoneNum, Pos, Angle )
	
end
