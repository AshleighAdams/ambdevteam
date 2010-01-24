
TOOL.Category		= "Construction"
TOOL.Name			= "#Remover"
TOOL.Command		= nil
TOOL.ConfigName		= nil


local function RemoveEntity( ent )

	if (ent:IsValid()) then
		ent:Remove()
	end

end

local function DoRemoveEntity( Entity )

	if (!Entity) then return false end
	if (!Entity:IsValid()) then return false end
	if (Entity:IsPlayer()) then return false end

	// Nothing for the client to do here
	if ( CLIENT ) then return true end

	// Remove all constraints (this stops ropes from hanging around)
	constraint.RemoveAll( Entity )
	
	// Remove it properly in 1 second
	timer.Simple( 1, RemoveEntity, Entity )
	
	// Make it non solid
	Entity:SetNotSolid( true )
	Entity:SetMoveType( MOVETYPE_NONE )
	Entity:SetNoDraw( true )
	
	// Send Effect
	local ed = EffectData()
		ed:SetEntity( Entity )
	util.Effect( "entity_remove", ed, true, true )
	
	return true

end

/*---------------------------------------------------------
   Name:	LeftClick
   Desc:	Remove a single entity
---------------------------------------------------------*/  
function TOOL:LeftClick( trace )

	if ( DoRemoveEntity( trace.Entity ) ) then
	
		if ( !CLIENT ) then
			MsgAll( self:GetOwner():Nick(), " removed ", trace.Entity:GetClass(), "\n" )
			self:GetOwner():SendLua( "achievements.Remover()" );
		end
		
		return true
	
	end
	
	return false
		
end

/*---------------------------------------------------------
   Name:	RightClick
   Desc:	Remove this entity and everything constrained
---------------------------------------------------------*/  
function TOOL:RightClick( trace )

	if (!trace.Entity) then return false end
	if (!trace.Entity:IsValid()) then return false end
	if (trace.Entity:IsPlayer()) then return false end
	
	// Client can bail out now.
	if ( CLIENT ) then return true end
	
	local ConstrainedEntities = constraint.GetAllConstrainedEntities( trace.Entity )
	local Count = 0
	
	// Loop through all the entities in the system
	for _, Entity in pairs( ConstrainedEntities ) do
	
		if ( DoRemoveEntity( Entity ) ) then
			Count = Count + 1
		end

	end
	
	if ( Count > 0 ) then
		MsgAll( self:GetOwner():Nick(), " removed ", Count, " object(s)\n" )
	end
	
	return true
end

function TOOL:Reload( trace )
	if (!trace.Entity || !trace.Entity:IsValid() || trace.Entity:IsPlayer() ) then return false
	elseif ( CLIENT ) then return true
	end

	local  bool = constraint.RemoveAll( trace.Entity )
	return bool

end
