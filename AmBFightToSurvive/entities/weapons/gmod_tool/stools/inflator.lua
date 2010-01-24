
TOOL.Category		= "Poser"
TOOL.Name			= "#Inflator"
TOOL.Command		= nil
TOOL.ConfigName		= ""

TOOL.LeftClickAutomatic = true
TOOL.RightClickAutomatic = true
TOOL.RequiresTraceHit = true

if ( CLIENT ) then

	language.Add( "Tool_inflator_name", "Ragdoll Inflator" )
	language.Add( "Tool_inflator_desc", "Inflate and deflate ragdolls and NPCs" )
	language.Add( "Tool_inflator_0", "Left click to inflate, Right click to deflate, Reload to reset" )
	
	function TOOL.BuildCPanel( CPanel )

		CPanel:AddControl( "Header", { Text = "#Tool_inflator_name", Description	= "#Tool_inflator_desc" }  )
	
	end

end

/*------------------------------------------------------------

	Scale the specified bone by Scale
	
------------------------------------------------------------*/   
local function ScaleBone( Entity, Pos, Bone, Scale )

	//local Bone, BonePos = Entity:FindNearestBone( Pos )
	if ( !Bone ) then return false end

	if ( SERVER ) then
	
		// Change this specific bone's size
		local VarName = "InflateSize"..Bone
		local NewSize = Entity:GetNetworkedInt( VarName, 0 ) + Scale
		NewSize = math.Clamp( NewSize, -100, 500 )
		
		duplicator.StoreEntityModifier( Entity, "inflator", { [Bone] = NewSize } )
		Entity:SetNetworkedInt( VarName, NewSize )
		
	end
	
	// Send an effect to let the player know which bone we're scaling
	local effectdata = EffectData()
		effectdata:SetOrigin( Pos )
	util.Effect( "inflator_magic", effectdata )

end


/*------------------------------------------------------------

	Scale UP
	
------------------------------------------------------------*/ 
function TOOL:LeftClick( trace )

	if ( trace.Entity:IsValid() && trace.Entity:IsPlayer() ) then return false end
	if ( !trace.Entity:IsNPC() && trace.Entity:GetClass() != "prop_ragdoll" ) then return false end
	
	local Bone = trace.Entity:TranslatePhysBoneToBone( trace.PhysicsBone )
	ScaleBone( trace.Entity, trace.HitPos, Bone, 1 )	
	self:GetWeapon():SetNextPrimaryFire( CurTime() + 0.01 )
	
	return false

end


/*------------------------------------------------------------

	Scale DOWN
	
------------------------------------------------------------*/ 
function TOOL:RightClick( trace )

	if ( trace.Entity:IsValid() && trace.Entity:IsPlayer() ) then return false end
	if ( !trace.Entity:IsNPC() && trace.Entity:GetClass() != "prop_ragdoll" ) then return false end
	
	local Bone = trace.Entity:TranslatePhysBoneToBone( trace.PhysicsBone )
	ScaleBone( trace.Entity, trace.HitPos, Bone, -1 )	
	self:GetWeapon():SetNextSecondaryFire( CurTime() + 0.01 )
	
	return false
	
end


/*------------------------------------------------------------

	Remove Scaling
	
------------------------------------------------------------*/ 
function TOOL:Reload( trace )
	
	if ( trace.Entity:IsValid() && trace.Entity:IsPlayer() ) then return false end
	if ( !trace.Entity:IsNPC() && trace.Entity:GetClass() != "prop_ragdoll" ) then return false end
	if ( CLIENT ) then return false end
	
	for i=0, 128 do
	
		local VarName = "InflateSize"..i
		trace.Entity:SetNetworkedInt( VarName, 0 )
		duplicator.ClearEntityModifier( trace.Entity, "inflator" )
	
	end
	
end


if ( SERVER ) then 

	
	/*------------------------------------------------------------
	
		Copy scaling to ragdoll
		
	------------------------------------------------------------*/ 
	local function CopyRagdollBoneScales( Entity, Ragdoll )
	
		for i=0, 128 do
		
			local VarName = "InflateSize"..i
			local Var = Entity:GetNetworkedInt( VarName, 0 )
			if ( Var ) then
			
				Ragdoll:SetNetworkedBool( "InflateBonesDirect", true, true )
				Ragdoll:SetNetworkedInt( VarName, Var, true )
			
			end
		
		end
	
	end
	
	hook.Add( "CreateEntityRagdoll", "InflatorCopy", CopyRagdollBoneScales )
	
	/*------------------------------------------------------------
	
		Duplicate Scaling to duplicate
		
	------------------------------------------------------------*/ 
	local function InflatorCopy( Player, Entity, Data )
	
		for k, v in pairs( Data ) do
		
			local VarName = "InflateSize"..k
			
			Entity:SetNetworkedBool( "InflateBonesDirect", true, true )
			Entity:SetNetworkedInt( VarName, v, true )

		end
		
		duplicator.StoreEntityModifier( Entity, "inflator", Data )
		
	end
	
	duplicator.RegisterEntityModifier( "inflator", InflatorCopy )
	

return end // if (SERVER)

/////////////////////////////

/*
	This is what does all the work on the client to render the different
	sized bones. We can't really add this function to all entities by default
	so we do the best we can.. We add it when the entity becomes known to Lua.
*/


/*------------------------------------------------------------
	Sets the bone scales/translations up on this entity
------------------------------------------------------------*/ 
local function SetupBoneScales( self )

	// We want to MOVE some bones when they're scaled, like the head 
	// so it doesn't look like it's stuck in their chest
	if ( !self.BoneTranslations ) then
		
		self.BoneTranslations = {}
		
		local boneid = self:LookupBone( "ValveBiped.Bip01_Head1" )
		if ( boneid && boneid != -1 ) then self.BoneTranslations[ boneid ] = Vector( 0.5, 0, 0 ) end
	
	end
	
	// Some (most it seems now) things should only be scaled in certain directions
	if ( !self.TranslatedBoneScales ) then
		
		self.TranslatedBoneScales = {}
		
		local ScaleYZ = { "ValveBiped.Bip01_L_UpperArm", 
						  "ValveBiped.Bip01_L_Forearm", 
						  "ValveBiped.Bip01_L_Thigh",
						  "ValveBiped.Bip01_L_Calf",
						  "ValveBiped.Bip01_R_UpperArm",
						  "ValveBiped.Bip01_R_Forearm",
						  "ValveBiped.Bip01_R_Thigh",
						  "ValveBiped.Bip01_R_Calf",
						  "ValveBiped.Bip01_Spine2",
						  "ValveBiped.Bip01_Spine1",
						  "ValveBiped.Bip01_Spine",
						  "ValveBiped.Bip01_Spinebut" }
						  
		local ScaleXZ = { "ValveBiped.Bip01_pelvis" }
		
		for k, v in pairs( ScaleYZ ) do
		
			local boneid = self:LookupBone( v )
			if ( boneid ) then self.TranslatedBoneScales[ boneid ] = Vector( 0, 1, 1 ) end
		
		end
	
		

		for k, v in pairs( ScaleXZ ) do
		
			local boneid = self:LookupBone( v )
			if ( boneid ) then self.TranslatedBoneScales[ boneid ] = Vector( 1, 0, 1 ) end
		
		end
		
	end
	
	if ( !self.CopyBoneScales ) then
	
		self.CopyBoneScales = {}
		
		local FromID = self:LookupBone( "ValveBiped.Bip01_Pelvis" )
		local ToID = self:LookupBone( "ValveBiped.Bip01_Spine" )
		if ( FromID && ToID ) then self.CopyBoneScales[ FromID ] = ToID end
	
	end

end


/*------------------------------------------------------------
	Translates the scale, since in some bones we just want 
	to scale along x and y, and not z.
------------------------------------------------------------*/  
local function TranslateScale( self, bonenum, Size )

	local Scale = Vector( Size, Size, Size )
	
	local TranslateScale = self.TranslatedBoneScales[ bonenum ]
	
	if ( TranslateScale ) then
	
		Scale.x = Scale.x * TranslateScale.x
		Scale.y = Scale.y * TranslateScale.y
		Scale.z = Scale.z * TranslateScale.z
	
	end

	return Vector( 1, 1, 1 ) + Scale

end

/*------------------------------------------------------------
	The head is lifted up from the rest of the body, depending
	on the amount of scale it has.
------------------------------------------------------------*/  
local function AddOffset( self, bonenum, Size, matBone )

	local Scale = self.BoneTranslations[ bonenum ]
	if ( !Scale ) then return end
	
	matBone:Translate( Scale * Size )

end

/*------------------------------------------------------------
	Some bones are copied by other bones in NPCs to get it looking right.
------------------------------------------------------------*/  
local function GetCopyBone( self, bonenum )

	return self.CopyBoneScales[ bonenum ]

end

/*------------------------------------------------------------
	Does the actual bone scaling work. This function is made 
	to work with copied bones too (realboneid).
------------------------------------------------------------*/  
local function BoneScale( self, boneid, realboneid, Size )

	local matBone = self:GetBoneMatrix( realboneid )
	
	if ( Size == -1 ) then
	
		matBone:Scale( Vector( 0, 0, 0 ) )
	
	else
	
		matBone:Scale( TranslateScale( self, realboneid, Size ) )
		AddOffset( self, realboneid, Size, matBone )
	
	end
	
	self:SetBoneMatrix( realboneid, matBone )

end



/*------------------------------------------------------------

	Name: WorkOutBonesToInflate
	
------------------------------------------------------------*/ 
local function WorkOutBonesToInflate( self, numbones )

	// No bones yet
	self.InflatedBones = nil
	
	for i=0, numbones do
	
		local Name = "InflateSize"..i
		local Size = self:GetNetworkedInt( Name, 0 )
		
		// This bone isn't normal, add it to the table.
		if ( Size && Size != 0 ) then
		
			self.InflatedBones = self.InflatedBones or {}
			table.insert( self.InflatedBones, i )
			
		else
		
			self[ Name ] = nil
		
		end
	
	end

end


/*------------------------------------------------------------

	aka ENTITY:BuildBonePositions
	
------------------------------------------------------------*/  
function DoBoneInflators( self, numbones, numphysbones )

	// Which bones need scaling!
	WorkOutBonesToInflate( self, numbones )
	if ( !self.InflatedBones ) then return end
	
	// Bone Force makes it snap to the bone
	local BoneForce = self:GetNWBool( "InflateBonesDirect", false )
	
	for k, i in ipairs( self.InflatedBones ) do
	
		local Name = "InflateSize"..i
		local Size = self:GetNetworkedInt( Name, false )

		if ( Size && (Size != 0 || self[ Name ] != 0) ) then
		
			self[ Name ] = self[ Name ] or 0 
			
		//	if ( BoneForce ) then
				self[ Name ] = Size
		//	else
		//		self[ Name ] = math.Approach( self[ Name ], Size, FrameTime() * 10 )
		//	end
			
			Size = self[ Name ] * 0.01
			
			BoneScale( self, i, i, Size )
			
			if ( self:IsNPC() ) then
			
				local CopyBone = GetCopyBone( self, i )
				if ( CopyBone ) then
					BoneScale( self, i, CopyBone, Size )
				end
				
			end
			
			self.BonesScaled = true

		end
	
	end
	
end


/*------------------------------------------------------------
	OnNetworkBonesChanged	
------------------------------------------------------------*/   
local function OnNetworkBonesChanged( entity, name, oldval, newval )

	entity:InvalidateBoneCache()
	return newval

end


/*------------------------------------------------------------

	This simply adds the BuildBonePositions function to the  entity. 
	
	We also call SetupBoneScales on the entity to cache off
	the bone numbers so we don't have to continually call LookupBone
	
------------------------------------------------------------*/   
local function AddInflateHook( ent )

	if ( !ent || !ent:IsValid() || (!ent:IsNPC() && ent:GetClass() != "prop_ragdoll") ) then return end
	
	SetupBoneScales( ent )
	
	for i=0, 128 do
		ent:SetNetworkedVarProxy( "InflateSize"..i, OnNetworkBonesChanged )
	end
	
	local CurrentFunction = ent.BuildBonePositions
	
	if ( CurrentFunction ) then
	
		ent.BuildBonePositions = 	function( self, numbones, numphysbones ) 
		
										CurrentFunction( self, numbones, numphysbones )
										DoBoneInflators( self, numbones, numphysbones )
										
									end
	else
	
		ent.BuildBonePositions = DoBoneInflators
	
	end
	
end

hook.Add( "OnEntityCreated", "AddInflateHook", AddInflateHook )