
TOOL.Category		= "Construction"
TOOL.Name			= "#Emitter"
TOOL.Command		= nil
TOOL.ConfigName		= ""

TOOL.ClientConVar[ "key" ] 			= "10"
TOOL.ClientConVar[ "delay" ] 		= "1"
TOOL.ClientConVar[ "toggle" ] 		= "1"
TOOL.ClientConVar[ "starton" ] 		= "0"
TOOL.ClientConVar[ "effect" ] 		= "sparks"

cleanup.Register( "emitter" )

// Add Default Language translation (saves adding it to the txt files)
if ( CLIENT ) then

	language.Add( "Tool_emitter_name", "Emitter" )
	language.Add( "Tool_emitter_desc", "Emitter Emits effects eh?" )
	language.Add( "Tool_emitter_0", "Click somewhere to spawn an emitter. Click on an existing emitter to change it." )

	language.Add( "Undone_emitter", "Undone Emitter" )
	language.Add( "Cleanup_emitter", "Emitter" )
	language.Add( "Cleaned_emitter", "Cleaned up all Emitters" )

end


function TOOL:LeftClick( trace, worldweld )

	worldweld = worldweld or false

	if ( trace.Entity && trace.Entity:IsPlayer() ) then return false end
	
	// If there's no physics object then we can't constraint it!
	if ( SERVER && !util.IsValidPhysicsObject( trace.Entity, trace.PhysicsBone ) ) then return false end
	
	if (CLIENT) then return true end
	
	local ply = self:GetOwner()
	
	local key	 		= self:GetClientNumber( "key" ) 
	local delay 		= self:GetClientNumber( "delay" ) 
	local toggle 		= self:GetClientNumber( "toggle" ) == 1
	local starton 		= self:GetClientNumber( "starton" ) == 1
	local effect	 	= self:GetClientInfo( "effect" ) 
	
	// Safe(ish) limits
	delay 	= math.Clamp( delay, 0.05, 20 )
	
	// We shot an existing emitter - just change its values
	if ( trace.Entity:IsValid() && trace.Entity:GetClass() == "gmod_emitter" && trace.Entity.pl == ply ) then

		trace.Entity:SetEffect( effect )
		trace.Entity:SetDelay( delay )
		trace.Entity:SetToggle( toggle )
	
		return true
		
	end
	
	if ( !self:GetSWEP():CheckLimit( "emitters" ) ) then return false end
	
	if ( trace.Entity != NULL && (!trace.Entity:IsWorld() || worldweld) ) then
	
		trace.HitPos = trace.HitPos + trace.HitNormal * -5
	
	else
	
		trace.HitPos = trace.HitPos + trace.HitNormal * 2
	
	end
	
	

	local emitter = MakeEmitter( ply, trace.HitPos, key, delay, toggle, effect, starton )
	
	local Angle = trace.HitNormal:Angle()
	Angle:RotateAroundAxis( Angle:Forward(), 90 )
	emitter:SetAngles( Angle )
	
	local weld
	
	// Don't weld to world
	if ( trace.Entity != NULL && (!trace.Entity:IsWorld() || worldweld) ) then
	
		weld = constraint.Weld( emitter, trace.Entity, 0, trace.PhysicsBone, 0, true, true )
		
		// >:(
		emitter:GetPhysicsObject():EnableCollisions( false )
		emitter.nocollide = true
		
	end
	
	undo.Create("Emitter")
		undo.AddEntity( emitter )
		undo.AddEntity( weld )
		undo.SetPlayer( ply )
	undo.Finish()
	
	return true

end

function TOOL:RightClick( trace )
	return self:LeftClick( trace, true )
end

if (SERVER) then

	function MakeEmitter( ply, Pos, key, delay, toggle, effect, starton, Vel, aVel, frozen, nocollide )
	
		if ( !ply:CheckLimit( "emitters" ) ) then return nil end
	
		local emitter = ents.Create( "gmod_emitter" )
		if (!emitter:IsValid()) then return false end

		emitter:SetPos( Pos )
		emitter:Spawn()
		
		DoPropSpawnedEffect( emitter )
		
		emitter:SetEffect( effect )
		emitter:SetPlayer( ply )
		
		emitter:SetDelay( delay )
		emitter:SetToggle( toggle )
		emitter:SetOn( starton )

		numpad.OnDown( 	 ply, 	key, 	"Emitter_On", 	emitter )
		numpad.OnUp( 	 ply, 	key, 	"Emitter_Off", 	emitter )

		if ( nocollide == true ) then emitter:GetPhysicsObject():EnableCollisions( false ) end

		local ttable = 
		{
			key			= key,
			delay 		= delay,
			toggle 		= toggle,
			effect 		= effect,
			pl			= ply,
			nocollide 	= nocollide,
			starton		= starton
		}

		table.Merge( emitter:GetTable(), ttable )
		
		ply:AddCount( "emitters", emitter )
		ply:AddCleanup( "emitter", emitter )

		return emitter
		
	end
	
	duplicator.RegisterEntityClass( "gmod_emitter", MakeEmitter, "Pos", "key", "delay", "toggle", "effect", "starton", "Vel", "aVel", "frozen", "nocollide" )

end


// NOTE!! The . instead of : here - there is no 'self' argument!!
// This is just a function on the table - not a member function!

function TOOL.BuildCPanel( CPanel )

	// HEADER
	CPanel:AddControl( "Header", { Text = "#Tool_emitter_name", Description	= "#Tool_emitter_desc" }  )
	
	// PRESETS
	local params = { Label = "#Presets", MenuButton = 1, Folder = "emitter", Options = {}, CVars = {} }
			
		params.Options.default = {
			emitter_key			= 		3,
			emitter_delay		=		0.1,
			emitter_toggle		=		1,
			emitter_starton		=		1,
			emitter_effect		=		"sparks" }
			
		table.insert( params.CVars, "emitter_key" )
		table.insert( params.CVars, "emitter_delay" )
		table.insert( params.CVars, "emitter_toggle" )
		table.insert( params.CVars, "emitter_starton" )
		table.insert( params.CVars, "emitter_effect" )
		
	CPanel:AddControl( "ComboBox", params )
	
	
	// KEY
	CPanel:AddControl( "Numpad", { Label = "#Emitter Key", Command = "emitter_key", ButtonSize = 22 } )
	
	
	// EMITTERS
	local params = { Label = "#Effect", Height = 200, Options = {} }
		
		for k, v in pairs( ComboBox_Emitter_Options ) do
			params.Options[ "#emitter_" .. k ] = { emitter_effect = k }
		end

	CPanel:AddControl( "ListBox", params )
	
	
	
	// DELAY
	CPanel:AddControl( "Slider",  { Label	= "#Delay",
									Type	= "Float",
									Min		= 0.01,
									Max		= 0.5,
									Command = "emitter_delay" }	 )
	
	// TOGGLE
	CPanel:AddControl( "Checkbox", { Label = "#Toggle", Command = "emitter_toggle" } )
	
	// START ON
	CPanel:AddControl( "Checkbox", { Label = "#Start On", Command = "emitter_starton" } )

end
