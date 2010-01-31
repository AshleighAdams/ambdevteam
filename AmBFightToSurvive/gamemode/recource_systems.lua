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

function Construct( pl )
	local ent = pl:GetEyeTrace().Entity
	if !ent || ent.Team != pl:Team() then return end
	
	local tmrname = "construct" .. tostring( math.Rand(1,1000) )
	timer.Create( tmrname, 0.1, ent.ResNeeded, function( ent,tmrname )
		if ValidEntity(ent) then
			ent.ResNeeded = ent.ResNeeded - ( VoidTakeResP( ent.Team, 1 ) )
			if ent.ResNeeded <= 0 then
				timer.Destroy( tmrname )
				ent:SetCollisionGroup( COLLISION_GROUP_NONE )
				ent:SetMaterial( "" )
				ent.Constructed = true
			end
		else
			timer.Destroy( tmrname )
		end
	end,ent,tmrname )
end

function Deconstruct( pl )
	local ent = pl:GetEyeTrace().Entity
	if !ent || ent.Team != pl:Team() then return end
	
	ent:SetMaterial( "models/wireframe" )
	ent.Constructed = false
	
	local tmrname = "construct" .. tostring( math.Rand(1,1000) )
	timer.Create( tmrname, 0.01, ent.Cost, function( ent,tmrname )
		if ValidEntity(ent) then
			ent.ResNeeded = ent.ResNeeded + 1
			GiveResP( ent.Team, 0.75 )
			if ent.ResNeeded >= ent.Cost then
				timer.Destroy( tmrname )
				ent:Remove()
				ent:SetCollisionGroup( COLLISION_GROUP_DEBRIS )
				SetResP( ent.Team, math.floor( GetResP(ent.Team) ) )
			end
		else
			timer.Destroy( tmrname )
		end
	end,ent,tmrname )
end

function GM:CanTool( pl, tr, toolmode )
	if tr.HitNonWorld then
		ent = tr.Entity
		if ent.Constructed then -- the entity is being constructed so we only allow inactive tools
			return !table.HasValue( DissallowInactiveTools, toolmode )
		else
			return table.HasValue( ActiveTools, toolmode )
		end
	end
	return true
end

function GM:PhysgunPickup( pl, ent )
	if ent.Constructed then
		return false
	else
		return true
	end
end


function GM:PlayerSpawnedProp( pl, mdl, ent )
	if !ent then return end
	ent:SetCollisionGroup( COLLISION_GROUP_WORLD )--COLLISION_GROUP_DEBRIS_TRIGGER)
	ent:SetMaterial( "models/wireframe" )
	ent.ResNeeded = GetEntCost( ent )
	ent.Constructed = false
	ent.Team = pl:Team()
	ent.Cost = ent.ResNeeded
end

function GM:PlayerSpawnedVehicle( pl, veh )

end
