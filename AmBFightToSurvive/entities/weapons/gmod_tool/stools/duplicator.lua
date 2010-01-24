
AddCSLuaFile( "vgui/duplicator_gui.lua" )
AddCSLuaFile( "vgui/duplicator_gui_button.lua" )

TOOL.Category		= "Construction"
TOOL.Name			= "#Duplicator"
TOOL.Command		= nil
TOOL.ConfigName		= ""
TOOL.Stored			= true

TOOL.ClientConVar[ "simple" ] = 0

cleanup.Register( "duplicates" )

//
// Converts to world so that the entities will be spawned in the correct positions
//
local function ConvertEntityPositionsToWorld( EntTable, Offset, HoldAngle )

	for k, Ent in pairs( EntTable ) do

		local NewPos, NewAngle = LocalToWorld( Ent.LocalPos, Ent.LocalAngle, Offset, HoldAngle )
		
		Ent.Pos = NewPos
		Ent.Angle = NewAngle
		
		// And for physics objects
		if ( Ent.PhysicsObjects ) then
			for Num, Object in pairs( Ent.PhysicsObjects ) do
	
				local NewPos, NewAngle = LocalToWorld( Object.LocalPos, Object.LocalAngle, Offset, HoldAngle )
			
				Object.Pos = NewPos
				Object.Angle = NewAngle
	
			end
		end
		
		
	end

end

//
// Move the world positions
//
local function ConvertConstraintPositionsToWorld( Constraints, Offset, HoldAngle )

	for k, Constraint in pairs( Constraints ) do
	
		if ( Constraint.Entity ) then
		
			for k, Entity in pairs( Constraint.Entity ) do
			
				if (Entity.World && Entity.LPos) then
				
					local NewPos, NewAngle = LocalToWorld( Entity.LPos, Angle(0,0,0), Offset, HoldAngle )
				
					Entity.LPosOld = Entity.LPos
					Entity.LPos = NewPos
				
				end
			
			end
		
		end
	
	end

end


//
// Resets the positions of all the entities in the table
//
local function ResetPositions( EntTable, Constraints )

	for k, Ent in pairs( EntTable ) do
	
		Ent.Pos = Ent.LocalPos * 1
		Ent.Angle = Ent.LocalAngle * 1
		
		// And for physics objects
		if ( Ent.PhysicsObjects ) then		
			for Num, Object in pairs( Ent.PhysicsObjects ) do
	
				Object.Pos = Object.LocalPos * 1
				Object.Angle = Object.LocalAngle * 1
	
			end
		end
		
	end
	
	for k, Constraint in pairs( Constraints ) do
	
		if ( Constraint.Entity ) then
		
			for k, Entity in pairs( Constraint.Entity ) do
			
				if (Entity.LPosOld) then
					Entity.LPos = Entity.LPosOld
					Entity.LPosOld = nil
				end
			
			end
		
		end
	
	end

end

//
// Converts the positions from world positions to positions local to Offset
//
local function ConvertPositionsToLocal( EntTable, Constraints, Offset, HoldAngle )

	for k, Ent in pairs( EntTable ) do
	
		Ent.Pos = Ent.Pos - Offset
		Ent.LocalPos = Ent.Pos * 1
		Ent.LocalAngle = Ent.Angle * 1
		
		if ( Ent.PhysicsObjects ) then
			for Num, Object in pairs(Ent.PhysicsObjects) do
			
				Object.Pos = Object.Pos - Offset
				Object.LocalPos = Object.Pos * 1
				Object.LocalAngle = Object.Angle * 1
				
			end
		end

	end
	
	// If the entity is constrained to the world we want to move the points to be
	// relative to where we're clicking
	for k, Constraint in pairs( Constraints ) do
	
		if ( Constraint.Entity ) then
		
			for k, Entity in pairs( Constraint.Entity ) do
			
				if (Entity.World && Entity.LPos) then
					Entity.LPos = Entity.LPos - Offset
				end
			
			end
		
		end
	
	end

end

//
// PASTE
//
function TOOL:LeftClick( trace )

	if ( CLIENT ) then	return true	end
	
	local DupeTable = self:GetOwner():UniqueIDTable( "Duplicator" )
	if (!DupeTable.Entities) then return false end
	
	local angle  = self:GetOwner():GetAngles()
	angle.pitch = 0
	angle.roll = 0	
	
	// Create the entities at the clicked position at the angle we're facing right now	
	ConvertEntityPositionsToWorld( DupeTable.Entities, trace.HitPos, angle - DupeTable.HoldAngle )
	ConvertConstraintPositionsToWorld( DupeTable.Constraints, trace.HitPos, angle - DupeTable.HoldAngle )
	
		local Ents, Constraints = duplicator.Paste( self:GetOwner(), DupeTable.Entities, DupeTable.Constraints )
	
	ResetPositions( DupeTable.Entities, DupeTable.Constraints )
		

	// Add all of the created entities
	//  to the undo system under one undo.
	undo.Create( "Duplicator" )
	
		for k, ent in pairs( Ents ) do
			undo.AddEntity( ent )
		end
		
		for k, ent in pairs( Ents )	do 
			self:GetOwner():AddCleanup( "duplicates", ent ) 
		end
		
		undo.SetPlayer( self:GetOwner() )
		
	undo.Finish()

	return true
	
end

//
// Copy
//
function TOOL:RightClick( trace )

	if (!trace.Entity ||
		!trace.Entity:IsValid() ||
		trace.Entity:IsPlayer() )
	then
	
		self:ReleaseGhostEntity()
	
		local DupeTable = self:GetOwner():UniqueIDTable( "Duplicator" )
		
		DupeTable.HeadEntityIdx	= nil
		DupeTable.HoldAngle 	= nil
		DupeTable.HoldPos 		= nil
		DupeTable.Entities		= nil
		DupeTable.Constraints	= nil
		self.Stored 			= true
		
		return true
	
	end

	local StartPos = trace.HitPos

	self:ReleaseGhostEntity()

	if ( CLIENT ) then return true end
	
	// Get the distance from the floor
	local tr = {}
	tr.start = StartPos
	tr.endpos = StartPos + Vector(0,0,-1024)
	tr.mask = MASK_NPCSOLID_BRUSHONLY
	local tr_floor = util.TraceLine( tr )
	if (tr_floor.Hit) then 

		StartPos = StartPos  + Vector(0,0,-1) * tr_floor.Fraction * 1024
	
	end
	
	// Copy the entities
	local Entities, Constraints = duplicator.Copy( trace.Entity )
	
	local angle  = self:GetOwner():GetAngles()
	angle.pitch = 0
	angle.roll = 0
	
	// Convert the positions to local
	ConvertPositionsToLocal( Entities, Constraints, StartPos, angle )

	
	// Store stuff for pasting/ghosting
	// Save to a UniqueID table so the object will exist after the player dies/leaves the server
	local DupeTable = self:GetOwner():UniqueIDTable( "Duplicator" )
	
	DupeTable.HeadEntityIdx	= trace.Entity:EntIndex()
	DupeTable.HoldAngle 	= angle
	DupeTable.HoldPos 		= trace.Entity:WorldToLocal( StartPos )
	DupeTable.Entities		= Entities
	DupeTable.Constraints	= Constraints
	
	self:StartGhostEntities( DupeTable.Entities, DupeTable.HeadEntityIdx, DupeTable.HoldPos, DupeTable.HoldAngle )
	
	self.Stored = false
	
	return true
	
end

//
// Think
//
function TOOL:Think()

	self:UpdateGhostEntities()
	
end

//
// Make the ghost entities
//
function TOOL:MakeGhostFromTable( EntTable, pParent, HoldPos, HoldAngle )

	local GhostEntity = nil
	
	if ( EntTable.Model:sub( 1, 1 ) == "*" ) then
		GhostEntity = ents.Create( "func_physbox" )
	else
		GhostEntity = ents.Create( "gmod_ghost" )
	end
	
	// If there are too many entities we might not spawn..
	if ( !GhostEntity || GhostEntity == NULL ) then return end
	
	duplicator.DoGeneric( GhostEntity, EntTable )
	
	GhostEntity:Spawn()
	
	GhostEntity:DrawShadow( false )
	GhostEntity:SetMoveType( MOVETYPE_NONE )
	GhostEntity:SetSolid( SOLID_VPHYSICS );
	GhostEntity:SetNotSolid( true )
	GhostEntity:SetRenderMode( RENDERMODE_TRANSALPHA )
	GhostEntity:SetColor( 255, 255, 255, 150 )
	
	GhostEntity.Pos 	= EntTable.Pos
	GhostEntity.Angle 	= EntTable.Angle - HoldAngle
	
	if ( pParent ) then
		GhostEntity:SetParent( pParent )
	end
	
	// If we're a ragdoll send our bone positions
	if ( EntTable.Class == "prop_ragdoll" ) then

		for k, v in pairs( EntTable.PhysicsObjects ) do
			
			local lPos = v.Pos
			
			// The physics object positions are stored relative to the head entity
			if ( pParent ) then
				lPos = pParent:LocalToWorld( v.LocalPos )
				lPos = GhostEntity:WorldToLocal( v.Pos )
			else
				lPos = lPos + HoldPos
			end
			
			GhostEntity:SetNetworkedBonePosition( k, lPos, v.LocalAngle )
		end	
	
	end
	
	return GhostEntity
	
end


/*---------------------------------------------------------
   Starts up the ghost entities
---------------------------------------------------------*/
function TOOL:Deploy()

	if ( CLIENT ) then return end
	
	local DupeTable = self:GetOwner():UniqueIDTable( "Duplicator" )
	
	if ( DupeTable.Entities ) then
		self:StartGhostEntities( DupeTable.Entities, DupeTable.HeadEntityIdx, DupeTable.HoldPos, DupeTable.HoldAngle )
	end

end


/*---------------------------------------------------------
   Starts up the ghost entities
---------------------------------------------------------*/
function TOOL:StartGhostEntities( EntityTable, Head, HoldPos, HoldAngle )

	self:ReleaseGhostEntity()
	self.GhostEntities = {}
	
	// Make the head entity first
	self.GhostEntities[ Head ] = self:MakeGhostFromTable( EntityTable[ Head ], self.GhostEntities[ Head ], HoldPos, HoldAngle )
	
	// Set NW vars for clientside
	self.Weapon:SetNetworkedEntity( "GhostEntity", self.GhostEntities[ Head ] )
	self.Weapon:SetNetworkedVector( "HeadPos", self.GhostEntities[ Head ].Pos )
	self.Weapon:SetNetworkedAngle( 	"HeadAngle", self.GhostEntities[ Head ].Angle )	
	self.Weapon:SetNetworkedVector( "HoldPos", HoldPos )
	
	if ( !self.GhostEntities[ Head ] || !self.GhostEntities[ Head ]:IsValid() ) then
	
		self.GhostEntities = nil
		return
	
	end
	
	for k, entTable in pairs( EntityTable ) do
		
		if ( !self.GhostEntities[ k ] ) then
			self.GhostEntities[ k ] = self:MakeGhostFromTable( entTable, self.GhostEntities[ Head ], HoldPos, HoldAngle )
		end
	
	end

end

/*---------------------------------------------------------
   Update the ghost entity positions
---------------------------------------------------------*/
function TOOL:UpdateGhostEntities()

	if (SERVER && !self.GhostEntities) then return end
	if ( CLIENT && SinglePlayer() ) then return end
	
	local Owner = self:GetOwner()

	local tr = utilx.GetPlayerTrace( Owner, Owner:GetCursorAimVector() )
	local trace = util.TraceLine( tr )
	if (!trace.Hit) then return end

	local GhostEnt = nil
	local HoldPos = nil
	
	if ( SERVER ) then
		local DupeTable = Owner:UniqueIDTable( "Duplicator" )
		GhostEnt = self.GhostEntities[ DupeTable.HeadEntityIdx ]
		HoldPos = DupeTable.HoldPos
	else
		GhostEnt = self.Weapon:GetNetworkedEntity( "GhostEntity", nil )
		GhostEnt.Pos = self.Weapon:GetNetworkedVector( "HeadPos", Vector(0,0,0) )
		GhostEnt.Angle = self.Weapon:GetNetworkedAngle( "HeadAngle", Angle(0,0,0) )		
		HoldPos = self.Weapon:GetNetworkedVector( "HoldPos", Vector(0,0,0) )
	end
	
	if (!GhostEnt || !GhostEnt:IsValid()) then 
		self.GhostEntities = nil
	return end

	GhostEnt:SetMoveType( MOVETYPE_VPHYSICS )
	GhostEnt:SetNotSolid( true )
	
	local angle  = self:GetOwner():GetAngles()
	angle.pitch = 0
	angle.roll = 0
	
	local TargetPos = GhostEnt:GetPos() - GhostEnt:LocalToWorld( HoldPos )

	local PhysObj = GhostEnt:GetPhysicsObject()
	if ( PhysObj && PhysObj:IsValid() ) then
	
		PhysObj:EnableMotion( false )
		PhysObj:SetPos( TargetPos + trace.HitPos )
		PhysObj:SetAngle( GhostEnt.Angle + angle )
		PhysObj:Wake()
		
	else
	
		// Give the head ghost entity a physics object
		// This way the movement will be predicted on the client
		if ( CLIENT ) then
			GhostEnt:PhysicsInit( SOLID_VPHYSICS )
		end
	
	end
		
end



if (SERVER) then

	local function CC_Store( pl, command, arguments )
	
		local tool = pl:GetTool( "duplicator" )
		if (!tool) then Msg("No Tool!\n") return end
		tool:StoreCurrent( arguments[1] )
	
	end
	concommand.Add( "tool_duplicator_store", CC_Store )
	
	local function CC_Select( pl, command, arguments )
	
		local tool = pl:GetTool( "duplicator" )
		if (!tool) then return end
		
		tool:Select( math.Clamp( tonumber(arguments[1]), 0, 1000 ) )
	
	end
	concommand.Add( "tool_duplicator_select", CC_Select )
	
	
	local function CC_Remove( pl, command, arguments )
	
		local tool = pl:GetTool( "duplicator" )
		if (!tool) then return end
		
		tool:Remove( math.Clamp( tonumber(arguments[1]), 0, 1000 ) )
	
	end
	concommand.Add( "tool_duplicator_remove", CC_Remove )
	
	
	/*---------------------------------------------------------
	   Store the current duplication under name 
	---------------------------------------------------------*/
	function TOOL:StoreCurrent( name )
	
		// Don't store the same copy more than once
		if ( self.Stored ) then return end
		self.Stored = true
	
		local Owner = self:GetOwner()
		local DupeTable = Owner:UniqueIDTable( "Duplicator" )
		
		if ( name == nil || name == "" ) then
			name = "Rubbish #" .. ( #Owner:UniqueIDTable( "StoredDuplications" ) + 1 )
		end
			
		local SaveTab = {}
		SaveTab.Name 			= name
		SaveTab.Entities 		= DupeTable.Entities
		SaveTab.Constraints 	= DupeTable.Constraints
		SaveTab.HeadEntityIdx 	= DupeTable.HeadEntityIdx
		SaveTab.HoldAngle	 	= DupeTable.HoldAngle * 1
		SaveTab.HoldPos		 	= DupeTable.HoldPos * 1
		
		table.insert( Owner:UniqueIDTable( "StoredDuplications" ), SaveTab )
		
		self:RebuildStoredDuplications()
	
	end
	
	/*---------------------------------------------------------
		Select stored duplication
	---------------------------------------------------------*/
	function TOOL:Select( id )
	
		local Owner = self:GetOwner()
		local DupeTable = Owner:UniqueIDTable( "Duplicator" )
		local Dupe = Owner:UniqueIDTable( "StoredDuplications" )[ id ]
		if (!Dupe) then return end
		
		// Release the old entities
		self:ReleaseGhostEntity()
	
		// Store stuff for pasting/ghosting
		DupeTable.HeadEntityIdx	= Dupe.HeadEntityIdx
		DupeTable.HoldAngle 		= Dupe.HoldAngle * 1
		DupeTable.HoldPos 		= Dupe.HoldPos * 1
		DupeTable.Entities		= Dupe.Entities
		DupeTable.Constraints	= Dupe.Constraints
		
		// Start the entities!
		self:StartGhostEntities( DupeTable.Entities, DupeTable.HeadEntityIdx, DupeTable.HoldPos, DupeTable.HoldAngle )
	
	end
	
	/*---------------------------------------------------------
		Select stored duplication
	---------------------------------------------------------*/
	function TOOL:Remove( id )
	
		local Owner = self:GetOwner()
		if ( Owner:UniqueIDTable( "StoredDuplications" )[ id ] == nil ) then return end
		
		Owner:UniqueIDTable( "StoredDuplications" )[ id ] = nil
		self:RebuildStoredDuplications()
	
	end

	/*---------------------------------------------------------
	   Send the stored duplication to user
	---------------------------------------------------------*/
	function TOOL:RebuildStoredDuplications()
	
		local Owner = self:GetOwner()
		local Saved = Owner:UniqueIDTable( "StoredDuplications" )
		if (!Saved) then return end
		
		// Clear the list
		umsg.Start( "Duplications", Owner )
			umsg.Short( 0 )		
		umsg.End()
		
		// Send each item to the client
		for k, v in pairs( Saved ) do
			umsg.Start( "Duplications", Owner )
				umsg.Short( k )
				umsg.String( v.Name )			
			umsg.End()
		end
		
		umsg.Start( "Duplications", Owner )
			umsg.Short( 1000 )		
		umsg.End()
	
	end



end



if (CLIENT) then

	
	local DuplicatorControl = nil
	local pnldef_Duplicator = vgui.RegisterFile( "vgui/duplicator_gui.lua" )
	
	/*---------------------------------------------------------
		Builds the context menu
	---------------------------------------------------------*/
	function TOOL.BuildCPanel( CPanel )
	
		CPanel:AddControl( "Header", { Text = "#Tool_duplicator_name", Description	= "#Tool_duplicator_desc" }  )
		
		DuplicatorControl = vgui.CreateFromTable( pnldef_Duplicator )
		CPanel:AddPanel( DuplicatorControl )
	
	end
	

	/*---------------------------------------------------------
		Receives the usermessages
	---------------------------------------------------------*/
	local function RecvFunc( m )
	
		local id = m:ReadShort()
		
		if ( id == 0 ) then
			DuplicatorControl:Clear()
			return
		end
		
		if ( id == 1000 ) then
			DuplicatorControl:Populate()
			return
		end
		
		DuplicatorControl:Add( id, m:ReadString() )
		
	end
	
	usermessage.Hook( "Duplications", RecvFunc )


end
