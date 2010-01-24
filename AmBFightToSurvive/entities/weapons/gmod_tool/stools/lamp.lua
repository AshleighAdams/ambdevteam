
TOOL.Category		= "Construction"
TOOL.Name			= "#Lamps"
TOOL.Command		= nil
TOOL.ConfigName		= ""

TOOL.ClientConVar[ "ropelength" ] = "64"
TOOL.ClientConVar[ "ropematerial" ] = "cable/rope"
TOOL.ClientConVar[ "r" ] = "255"
TOOL.ClientConVar[ "g" ] = "255"
TOOL.ClientConVar[ "b" ] = "255"
TOOL.ClientConVar[ "key" ] = "-1"
TOOL.ClientConVar[ "texture" ] = "effects/flashlight001"

cleanup.Register( "lamps" )

function TOOL:LeftClick( trace, attach )

	if ( trace.Entity && trace.Entity:IsPlayer() ) then return false end
	if ( CLIENT ) then return true end
	if ( attach == nil ) then attach = true end
	
	// If there's no physics object then we can't constraint it!
	if ( SERVER && attach && !util.IsValidPhysicsObject( trace.Entity, trace.PhysicsBone ) ) then return false end
	
	local ply = self:GetOwner()
	
	local pos, ang = trace.HitPos + trace.HitNormal * 10, trace.HitNormal:Angle() - Angle( 90, 0, 0 )

	local r 	= math.Clamp( self:GetClientNumber( "r" ), 0, 255 )
	local g 	= math.Clamp( self:GetClientNumber( "g" ), 0, 255 )
	local b 	= math.Clamp( self:GetClientNumber( "b" ), 0, 255 )
	local key 		= self:GetClientNumber( "key" )
	local texture 	= self:GetClientInfo( "texture" )
	
	if	trace.Entity:IsValid() && 
		trace.Entity:GetClass() == "gmod_lamp" &&
		trace.Entity:GetPlayer() == ply
	then
	
		trace.Entity:SetLightColor( r, g, b )
		trace.Entity.r = r
		trace.Entity.g = g
		trace.Entity.b = b
		trace.Entity:SetFlashlightTexture( texture )
		
		return true
		
	end
	

	
	if ( !self:GetSWEP():CheckLimit( "lamps" ) ) then return false end
	lamp = MakeLamp( ply, r, g, b, key, texture, { Pos = pos, Angle = ang } )
	
	if (!attach) then 
	
		undo.Create("Lamp")
			undo.AddEntity( lamp )
			undo.SetPlayer( self:GetOwner() )
		undo.Finish()
		
		return true
		
	end

	local length 	= self:GetClientNumber( "ropelength" )
	local material 	= self:GetClientInfo( "ropematerial" )
	
	local LPos1 = Vector( 0, 0, 5 )
	local LPos2 = trace.Entity:WorldToLocal( trace.HitPos )
	
	if (trace.Entity:IsValid()) then
		
		local phys = trace.Entity:GetPhysicsObjectNum( trace.PhysicsBone )
		if (phys:IsValid()) then
			LPos2 = phys:WorldToLocal( trace.HitPos )
		end
	
	end
	
	local constraint, rope = constraint.Rope( lamp, trace.Entity, 
											  0, trace.PhysicsBone, 
											  LPos1, LPos2, 
											  0, length,
											  0, 
											  1.5, 
											  material, 
											  nil )
	
	undo.Create("Lamp")
		undo.AddEntity( lamp )
		undo.AddEntity( rope )
		undo.AddEntity( constraint )
		undo.SetPlayer( ply )
	undo.Finish()

	return true

end

function TOOL:RightClick( trace )

	return self:LeftClick( trace, false )

end

if ( SERVER ) then

	function MakeLamp( pl, r, g, b, KeyDown, Texture, Data )
	
		if ( !pl:CheckLimit( "lamps" ) ) then return false end
	
		local lamp = ents.Create( "gmod_lamp" )
		
			if (!lamp:IsValid()) then return end
		
			lamp:SetFlashlightTexture( Texture )
			duplicator.DoGeneric( lamp, Data )
			lamp:SetLightColor( r, g, b )
			
		lamp:Spawn()
		
		duplicator.DoGenericPhysics( lamp, pl, Data )
		
		lamp:SetPlayer( pl )
	
		pl:AddCount( "lamps", lamp )
		pl:AddCleanup( "lamps", lamp )
		
		lamp.Texture = Texture
		lamp.KeyDown = KeyDown
		lamp.KeyBind = numpad.OnDown( pl, KeyDown, "LampToggle", lamp )
		
		return lamp
	end
	
	duplicator.RegisterEntityClass( "gmod_lamp", MakeLamp, "lightr", "lightg", "lightb", "KeyDown", "Texture", "Data" )


	local function Toggle( pl, ent, onoff )
	
		if ( !ValidEntity( ent ) ) then return false end
		
		return ent:Toggle()
		
	end
	
	numpad.Register( "LampToggle", Toggle )
	
end


function TOOL.BuildCPanel( CPanel )

	// HEADER
	CPanel:AddControl( "Header", { Text = "#Tool_lamp_name", Description = "#Tool_lamp_desc" }  )

	// Presets
	local params = { Label = "#Presets", MenuButton = 1, Folder = "lamp", Options = {}, CVars = {} }
		
		params.Options.default = {
			lamp_ropelength		= 		64,
			lamp_ropematerial	=		"cable/rope",
			lamp_texture		=		"effects/flashlight001",
			lamp_r				=		255,
			lamp_g				=		255,
			lamp_b				=		255,
			lamp_key			=		-1
		}
			
		table.insert( params.CVars, "lamp_ropelength" )
		table.insert( params.CVars, "lamp_ropematerial" )
		table.insert( params.CVars, "lamp_texture" )
		table.insert( params.CVars, "lamp_r" )
		table.insert( params.CVars, "lamp_g" )
		table.insert( params.CVars, "lamp_b" )
		table.insert( params.CVars, "lamp_key" )
		
	CPanel:AddControl( "ComboBox", params )

	CPanel:NumSlider( "#Rope Length", "lamp_ropelength", 0, 256, 2 )
									
	CPanel:AddControl( "Color",  { Label	= "#Color",
									Red			= "lamp_r",
									Green		= "lamp_g",
									Blue		= "lamp_b",
									ShowAlpha	= 0,
									ShowHSV		= 1,
									ShowRGB 	= 1,
									Multiplier	= 255 } )	
	
	CPanel:AddControl( "Numpad", { Label = "#Toggle", Command = "lamp_key", ButtonSize = 22 } )
	
	local MatSelect = CPanel:MatSelect( "lamp_texture", nil, true, 0.33, 0.33 )
	
	for k, v in pairs( list.Get( "LampTextures" ) ) do
		MatSelect:AddMaterial( v.Name or k, k )
	end
										
end

list.Set( "LampTextures", "effects/flashlight001", { Name = "Default" } )
list.Set( "LampTextures", "effects/flashlight/slit", { Name = "Slit" } )
list.Set( "LampTextures", "effects/flashlight/circles", { Name = "Circles" } )
list.Set( "LampTextures", "effects/flashlight/window", { Name = "Window" } )
list.Set( "LampTextures", "effects/flashlight/logo", { Name = "Logo" } )
list.Set( "LampTextures", "effects/flashlight/gradient", { Name = "Gradient" } )
list.Set( "LampTextures", "effects/flashlight/bars", { Name = "Bars" } )
list.Set( "LampTextures", "effects/flashlight/tech", { Name = "Techdemo" } )