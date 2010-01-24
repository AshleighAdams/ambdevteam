
TOOL.Category		= "Construction"
TOOL.Name			= "#Magnetise"
TOOL.Command		= nil
TOOL.ConfigName		= nil


TOOL.ClientConVar[ "strength" ] 	= "25000"
TOOL.ClientConVar[ "nopull" ] 		= "0"
TOOL.ClientConVar[ "allowrot" ] 	= "0"
TOOL.ClientConVar[ "maxobjects" ] 	= "0"
TOOL.ClientConVar[ "group" ] 		= "0"
TOOL.ClientConVar[ "alwayson" ] 	= "0"
TOOL.ClientConVar[ "toggleon" ] 	= "1"

cleanup.Register( "magnet" )

if ( CLIENT ) then

	language.Add( "Cleanup_magnet", "Magnets" )
	
end

function TOOL:LeftClick( trace )

	if (!trace.Entity) then return false end
	if (!trace.Entity:IsValid()) then return false end
	if (trace.Entity:IsPlayer()) then return false end
	
	// If there's no physics object then we PROBABLY can't make it a magnet
	if ( SERVER && !util.IsValidPhysicsObject( trace.Entity, trace.PhysicsBone ) ) then return false end
	
	if (trace.Entity:GetClass() == "phys_magnet") then return false end
	if (trace.Entity:GetClass() == "prop_ragdoll") then return false end
	
	// Client can bail out now.
	if ( CLIENT ) then return true end

	local magnet = ents.Create("phys_magnet")
	if (magnet && magnet:IsValid())	then

		local _maxobjects 		= self:GetClientNumber( "maxobjects" )
		local _nopull 			= self:GetClientNumber( "nopull" )
		local _allowrot 		= self:GetClientNumber( "allowrot" )
		local _strength 		= self:GetClientNumber( "strength" )
		local _key 				= self:GetClientNumber( "group" )
		local _alwayson 		= self:GetClientNumber( "alwayson" )
		local _toggleon 		= self:GetClientNumber( "toggleon" )

		if (_alwayson > 1) then _key = -1 end

		local magnet = construct.Magnet(
					self:GetOwner(), 
					trace.Entity:GetPos(), 
					trace.Entity:GetAngles(), 
					trace.Entity:GetModel(), 
					trace.Entity:GetMaterial(), 

					_key, _maxobjects, _strength, _nopull, _allowrot, _alwayson, _toggleon)

		local isAsleep = false
		
		if (trace.Entity:GetPhysicsObject():IsValid()) then
		
			isAsleep = trace.Entity:GetPhysicsObject():IsAsleep()
			
		end
		
		if (trace.Entity.colour) then
			
			local col = trace.Entity.colour		
			SetColour(self:GetOwner(), magnet, col.r, col.g, col.b, col.a, col.mode, col.fx)
			
		end
		
		if (trace.Entity.material) then
		
			local mat = trace.Entity.material.mat
			SetMaterial(self:GetOwner(), magnet, mat)
			
		end

		-- TODO: Need to store all the constraints, and re-create them...
		trace.Entity:Remove()
		
		DoPropSpawnedEffect( magnet )
		
		// Thanks Chaussette
		undo.Create("Magnet")
            undo.AddEntity( magnet )
            undo.SetPlayer( self:GetOwner() )
        undo.Finish()
        
        self:GetOwner():AddCleanup( "magnet", magnet )

		if (isAsleep) then
			magnet:GetPhysicsObject():Sleep()
		end
	end
	
	return true

end

function TOOL:RightClick( trace )

	// Sorry whoever made this, it was a good idea but didn't work so great.

	return false	
	
end
