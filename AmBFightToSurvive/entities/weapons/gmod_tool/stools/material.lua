
TOOL.Category		= "Render"
TOOL.Name			= "#Material"
TOOL.Command		= nil
TOOL.ConfigName		= ""


TOOL.ClientConVar[ "override" ] = "debug/env_cubemap_model"

local function SetMaterial( Player, Entity, Data )

	Entity:SetMaterial( Data.MaterialOverride )
	
	if ( SERVER ) then
		duplicator.StoreEntityModifier( Entity, "material", Data )
	end

	return true

end
duplicator.RegisterEntityModifier( "material", SetMaterial )

function TOOL:LeftClick( trace )

	if !( trace.Entity &&			// Hit an entity
	      trace.Entity:IsValid() && 	// And the entity is valid
	      trace.Entity:EntIndex() != 0	// And isn't worldspawn
	    ) then return end

	local mat = self:GetClientInfo( "override" )
	SetMaterial( self:GetOwner(), trace.Entity, { MaterialOverride = mat } )
	return true

end



function TOOL:RightClick( trace )

	if !( trace.Entity &&			// Hit an entity
	      trace.Entity:IsValid() && 	// And the entity is valid
	      trace.Entity:EntIndex() != 0	// And isn't worldspawn
	    ) then return end

	SetMaterial( self:GetOwner(), trace.Entity, { MaterialOverride = "" } )
	return true

end

list.Add( "OverrideMaterials", "models/wireframe" )
list.Add( "OverrideMaterials", "debug/env_cubemap_model" )
list.Add( "OverrideMaterials", "models/shadertest/shader3" )
list.Add( "OverrideMaterials", "models/shadertest/shader4" )
list.Add( "OverrideMaterials", "models/shadertest/shader5" )
list.Add( "OverrideMaterials", "models/shiny" )
list.Add( "OverrideMaterials", "models/debug/debugwhite" )
list.Add( "OverrideMaterials", "Models/effects/comball_sphere" )
list.Add( "OverrideMaterials", "Models/effects/comball_tape" )
list.Add( "OverrideMaterials", "Models/effects/splodearc_sheet" )
list.Add( "OverrideMaterials", "Models/effects/vol_light001" )
list.Add( "OverrideMaterials", "models/props_combine/stasisshield_sheet" )
list.Add( "OverrideMaterials", "models/props_combine/portalball001_sheet" )
list.Add( "OverrideMaterials", "models/props_combine/com_shield001a" )
list.Add( "OverrideMaterials", "models/props_c17/frostedglass_01a" )
list.Add( "OverrideMaterials", "models/props_lab/Tank_Glass001" )
list.Add( "OverrideMaterials", "models/props_combine/tprings_globe" )
list.Add( "OverrideMaterials", "models/rendertarget" )
list.Add( "OverrideMaterials", "models/screenspace" )
list.Add( "OverrideMaterials", "brick/brick_model" )
list.Add( "OverrideMaterials", "models/props_pipes/GutterMetal01a" )
list.Add( "OverrideMaterials", "models/props_pipes/Pipesystem01a_skin3" )
list.Add( "OverrideMaterials", "models/props_wasteland/wood_fence01a" )
list.Add( "OverrideMaterials", "models/props_foliage/tree_deciduous_01a_trunk" )
list.Add( "OverrideMaterials", "models/props_c17/FurnitureFabric003a" )
list.Add( "OverrideMaterials", "models/props_c17/FurnitureMetal001a" )
list.Add( "OverrideMaterials", "models/props_c17/paper01" )
list.Add( "OverrideMaterials", "models/flesh" )



function TOOL.BuildCPanel( CPanel )

	// HEADER
	CPanel:SetTooltip( "#Tool_material_desc" )
	
	CPanel:MatSelect( "material_override", list.Get( "OverrideMaterials" ), true, 0.33, 0.33 )
									
end


