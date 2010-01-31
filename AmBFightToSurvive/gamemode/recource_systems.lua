include( 'api/sv_api.lua' )

concommand.Add( "dev_giveresp", function(pl, cmd, args) 
	ammount = args[1] or 0
	GiveResP( pl:Team(), ammount )
end)

concommand.Add( "dev_takeresp", function(pl, cmd, args) 
	ammount = args[1] or 0
	TakeResP( pl:Team(), ammount )
end)

local AllowActiveTools = { "remover","material","colour" }
local DissallowInactiveTools = { "material","colour" }
function GM:CanTool( pl, tr, toolmode )
	if tr.HitNonWorld then
		ent = tr.Entity
		if ent.CanTool then -- the entity is being constructed so we only allow inactive tools
			if table.HasValue( DissallowInactiveTools, toolmode ) then
				Msg("CanTool - false\n")
				return false
			else
				Msg("CanTool - true\n")
				return true
			end
		else
			if table.HasValue( ActiveTools, toolmode ) then
				Msg("CanNotTool - true\n")
				return true
			else
				Msg("CanNotTool - false\n")
				return false
			end
		end
	end
	return true
end

function GM:PlayerSpawnedProp( pl, mdl, ent )
	if !ent then return end
	ent:SetCollisionGroup( COLLISION_GROUP_WORLD )--COLLISION_GROUP_DEBRIS_TRIGGER)
	ent:SetMaterial( "models/wireframe" )
	ent.ResNeeded = GetEntCost( ent )
	ent.CanTool = true
	ent.CanHold = true
	ent.Constructed = false
end

function GM:PlayerSpawnedVehicle( pl, veh )

end
