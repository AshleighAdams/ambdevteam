
TOOL.Category		= "Construction"
TOOL.Name			= "#Buttons"
TOOL.Command		= nil
TOOL.ConfigName		= ""

TOOL.ClientConVar[ "model" ] = "models/props_c17/clock01.mdl"
TOOL.ClientConVar[ "keygroup" ] = "1"
TOOL.ClientConVar[ "description" ] = ""

cleanup.Register( "buttons" )

function TOOL:RightClick( trace )

	if trace.Entity && trace.Entity:IsPlayer() then return false end
	if (CLIENT) then return true end
	
	local ply = self:GetOwner()
	
	local model				= self:GetClientInfo( "model" )
	local key 				= self:GetClientNumber( "keygroup" )
	local description		= self:GetClientInfo( "description" )

	// If we shot a button change its keygroup
	if ( trace.Entity:IsValid() && 
		 trace.Entity:GetClass() == "gmod_button" && 
		 trace.Entity:GetPlayer() == ply ) then

		trace.Entity:SetKey( key )
		trace.Entity:SetLabel( description )
		
		return true, NULL, true
		
	end
	
	if ( !self:GetSWEP():CheckLimit( "buttons" ) ) then return false end

	if (not util.IsValidModel(model)) then return false end
	if (not util.IsValidProp(model)) then return false end		// Allow ragdolls to be used?

	local Ang = trace.HitNormal:Angle()
	Ang.pitch = Ang.pitch + 90

	button = MakeButton( ply, model, Ang, trace.HitPos, key, description )
	
	local min = button:OBBMins()
	button:SetPos( trace.HitPos - trace.HitNormal * min.z )
	
	local const
	
	undo.Create("Button")
		undo.AddEntity( button )
		undo.SetPlayer( ply )
	undo.Finish()

	ply:AddCleanup( "buttons", button )
	
	return true, button

end

function TOOL:LeftClick( trace )

	local bool, button, set_key = self:RightClick( trace, true )
	if (CLIENT) then return bool end

	if ( set_key ) then return true end
	if ( !button || !button:IsValid() ) then return false end
	if ( !trace.Entity:IsValid() && !trace.Entity:IsWorld() ) then return false end

	local weld = constraint.Weld( button, trace.Entity, 0, trace.PhysicsBone, 0, 0, true )
	trace.Entity:DeleteOnRemove( weld )
	button:DeleteOnRemove( weld )

	button:GetPhysicsObject():EnableCollisions( false )
	button.nocollide = true
	
	return true

end

if (SERVER) then

	function MakeButton( pl, Model, Ang, Pos, key, description, nocollide, Vel, aVel, frozen )
	
		if ( !pl:CheckLimit( "buttons" ) ) then return false end
	
		local button = ents.Create( "gmod_button" )
		if (!button:IsValid()) then return false end
		button:SetModel( Model )

		button:SetAngles( Ang )
		button:SetPos( Pos )
		button:Spawn()
		
		button:SetPlayer( pl )
		button:SetKey( key )
		button:SetLabel( description )

		if nocollide then button:GetPhysicsObject():EnableCollisions( false ) end

		local ttable = 
			{
				key	= key,
				pl	= pl,
				nocollide = nocollide,
				description = description
			}

		table.Merge(button:GetTable(), ttable )
		
		pl:AddCount( "buttons", button )
		
		DoPropSpawnedEffect( button )

		return button
		
	end
	
	duplicator.RegisterEntityClass( "gmod_button", MakeButton, "Model", "Ang", "Pos", "key", "description", "nocollide", "Vel", "aVel", "frozen" )

end

function TOOL:UpdateGhostButton( ent, player )

	if ( !ent ) then return end
	if ( !ent:IsValid() ) then return end

	local tr 	= utilx.GetPlayerTrace( player, player:GetCursorAimVector() )
	local trace 	= util.TraceLine( tr )
	if (!trace.Hit) then return end
	
	if (trace.Entity && trace.Entity:GetClass() == "gmod_button" || trace.Entity:IsPlayer()) then
	
		ent:SetNoDraw( true )
		return
		
	end
	
	local Ang = trace.HitNormal:Angle()
	Ang.pitch = Ang.pitch + 90
	
	local min = ent:OBBMins()
	 ent:SetPos( trace.HitPos - trace.HitNormal * min.z )
	ent:SetAngles( Ang )
	
	ent:SetNoDraw( false )
	
end


function TOOL:Think()

	if (!self.GhostEntity || !self.GhostEntity:IsValid() || self.GhostEntity:GetModel() != self:GetClientInfo( "model" )) then
		self:MakeGhostEntity( self:GetClientInfo( "model" ), Vector(0,0,0), Angle(0,0,0) )
	end
	
	self:UpdateGhostButton( self.GhostEntity, self:GetOwner() )
	
end



function TOOL.BuildCPanel( CPanel )

	// HEADER
	CPanel:AddControl( "Header", { Text = "#Tool_Button_name", Description	= "#Tool_Button_desc" }  )
	
	local Options = { Default = { button_model = "models/dav0r/buttons/button.mdl" } }
									
	local CVars = { "button_model", "button_keygroup", "button_description" }
	
	CPanel:AddControl( "ComboBox", { Label = "#Presets",
									 MenuButton = 1,
									 Folder = "button",
									 Options = Options,
									 CVars = CVars } )

	CPanel:AddControl( "PropSelect", { Label = "#Button_Model",
									 ConVar = "button_model",
									 Category = "Buttons",
									 Models = list.Get( "ButtonModels" ) } )
									 							 								 
	CPanel:AddControl( "Numpad", { 	Label = "#Button_group",
									 Command = "button_keygroup",
									 ButtonSize = "22" } )
									 
	CPanel:AddControl( "TextBox", { Label = "#Description",
									 MaxLenth = "20",
									 Command = "button_description" } )
									
end

list.Set( "ButtonModels", "models/dav0r/buttons/button.mdl", {} )
list.Set( "ButtonModels", "models/dav0r/buttons/switch.mdl", {} )
list.Set( "ButtonModels", "models/props_c17/clock01.mdl", {} )
list.Set( "ButtonModels", "models/props_junk/garbage_coffeemug001a.mdl", {} )
list.Set( "ButtonModels", "models/props_junk/garbage_newspaper001a.mdl", {} )
list.Set( "ButtonModels", "models/props_lab/huladoll.mdl", {} )
list.Set( "ButtonModels", "models/props_c17/playgroundTick-tack-toe_block01a.mdl", {} )
list.Set( "ButtonModels", "models/props_c17/computer01_keyboard.mdl", {} )
list.Set( "ButtonModels", "models/props_c17/cashregister01a.mdl", {} )
list.Set( "ButtonModels", "models/props_lab/powerbox02d.mdl", {} )
list.Set( "ButtonModels", "models/props_lab/reciever01d.mdl", {} )