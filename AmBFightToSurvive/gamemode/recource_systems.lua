include( 'api/sv_api.lua' )

concommand.Add( "dev_giveresp", function(pl, cmd, args) 
	ammount = args[1] or 0
	GiveResP( pl:Team(), ammount )
end)

concommand.Add( "dev_takeresp", function(pl, cmd, args) 
	ammount = args[1] or 0
	TakeResP( pl:Team(), ammount )
end)

local UnconstructedTools = { "colour","material", }
local ConstructedTools = { "material","colour","remover" }

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
				//ent:Remove()
				ent:SetCollisionGroup( COLLISION_GROUP_WORLD )
				SetResP( ent.Team, math.floor( GetResP(ent.Team) ) )
			end
		else
			timer.Destroy( tmrname )
		end
	end,ent,tmrname )
end

function CanTool( pl, tr, toolmode )
	if tr.HitNonWorld then
		ent = tr.Entity
		if string.find( ent:GetClass(), "resource" ) then return false end
		owner = ent:GetNetworkedEntity("OwnerObj", false)
		if ent.Constructed then -- the entity is constructed
			if table.HasValue( ConstructedTools, toolmode ) || string.find(toolmode,"wire") then
				//return hook.Call( "CanTool", pl, tr, toolmode )
				return true
			else
				return false
			end
		elseif ent.Team then
			if !table.HasValue( UnconstructedTools, toolmode ) then
				//return hook.Call( "CanTool", pl, tr, toolmode )
				return true
			else
				return false
			end
		end
	end
	return true //hook.Call( "CanTool", pl, tr, toolmode )
end
hook.Add( "CanTool", "f2s.CanTool", CanTool) -- DO NOT OVERRIDE THIS WITH GM:CanTool AS IT BREAKS PROP PROTECTIONS!

function PhysgunPickup( pl, ent )
	if ent.Constructed || string.find( ent:GetClass(), "resource" ) then
		return false
	else
		//hook.Call( "PhysgunPickup", pl, ent )
		return true
	end
end
hook.Add( "PhysgunPickup", "f2s.PhysPickup", PhysgunPickup ) -- DO NOT OVERRIDE THIS WITH GM:CanTool AS IT BREAKS PROP PROTECTIONS!

function SetUpEnt( t,ent )
	if !ent then return end
	ent:SetCollisionGroup( COLLISION_GROUP_WORLD )--COLLISION_GROUP_DEBRIS_TRIGGER)
	ent:SetMaterial( "models/wireframe" )
	ent.ResNeeded = GetEntCost( ent )
	ent.Constructed = false
	ent.Team = t
	ent.Cost = ent.ResNeeded
end

function GM:PlayerSpawnedProp( pl, mdl, ent )
	SetUpEnt( pl:Team(), ent )
end

function CheckForNewProps()
	for k,ent in pairs( ents.FindByClass( "prop_physics" ) ) do
		if ent.Team == nil then
			owner = ent:GetNetworkedEntity("OwnerObj", false)
			if IsValid(owner) && owner:IsPlayer() then
				t = owner:Team() or -1
				SetUpEnt( t,ent )
			end
		end
	end
end
timer.Create( "f2s.NewPropsCheck", 5, 0, CheckForNewProps )

local f2s_crystallimit = CreateConVar( "f2s_crystallimit", 2, {FCVAR_ARCHIVE,FCVAR_NOTIFY} )
function CreateCrystals()
	crystals_wep = ents.FindByClass("resource_crystal")
	crystals_box = ents.FindByClass("resource_drop")
	Crystals = #crystals_wep + #crystals_box
	PlaceResourceDrops( f2s_crystallimit:GetInt() - Crystals )
end
timer.Create( "f2s.Resources.CreateCrystals", 120*2, 0, CreateCrystals ) -- 4 mins

function GM:PlayerSpawnedVehicle( pl, veh )
	veh:SetPos( veh:GetPos() + Vector(0,0,2000) )
end
