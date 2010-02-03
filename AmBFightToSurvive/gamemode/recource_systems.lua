include( 'api/sv_api.lua' )
STATE_CONSTRUCTED,STATE_UNCONSTRUCTED,STATE_CONSTRUCTING,STATE_UNCONSTRUCTING = 1,2,3,4
metafuncs = 
{ 
	SetState = function(self, state)
		if state == STATE_UNCONSTRUCTED then
			self:SetCollisionGroup( COLLISION_GROUP_WORLD )
			self:SetMaterial( "models/wireframe" )
			self.State = state
			self.Constructed = false
			return
		end
		if state == STATE_CONSTRUCTED then
			self:SetCollisionGroup( COLLISION_GROUP_NONE )
			self:SetMaterial( "" )
			self.State = state
			self.Constructed = true
			return
		end
		if state == STATE_UNCONSTRUCTING then
			self:SetCollisionGroup( COLLISION_GROUP_NONE )
			self:SetMaterial( "models/wireframe" )
			self.State = state
			self.Constructed = false
			return
		end
		if state == STATE_CONSTRUCTING then
			self.State = state
			return
		end
	end,
	GetState = function(self)
		if !self && !ValidEntity( self ) then return 0 end
		if self.State then
			return self.State
		end
		return 0
	end
} 

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
				ent:SetState( STATE_CONSTRUCTED )
			end
		else
			timer.Destroy( tmrname )
		end
	end,ent,tmrname )
end

function Deconstruct( pl )
	local ent = pl:GetEyeTrace().Entity
	if !ent || ent.Team != pl:Team() then return end
	
	ent:SetState( STATE_UNCONSTRUCTING )
	
	local tmrname = "construct" .. tostring( math.Rand(1,1000) )
	timer.Create( tmrname, 0.01, ent.Cost, function( ent,tmrname )
		if ValidEntity(ent) then
			ent.ResNeeded = ent.ResNeeded + 1
			GiveResP( ent.Team, 0.75 )
			if ent.ResNeeded >= ent.Cost then
				timer.Destroy( tmrname )
				//ent:Remove()
				ent:SetState( STATE_UNCONSTRUCTED )
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
	if ent.Constructed || string.find( ent:GetClass(), "resource" ) || string.find( ent:GetClass(), "refine" ) then
		return false
	else
		//hook.Call( "PhysgunPickup", pl, ent )
		return true
	end
end
hook.Add( "PhysgunPickup", "f2s.PhysPickup", PhysgunPickup ) -- DO NOT OVERRIDE THIS WITH GM:CanTool AS IT BREAKS PROP PROTECTIONS!

function SetUpEnt( t,ent )
	if !ent then return end
	setmetatable(ent:GetTable(), {__index = metafuncs}) 
	ent.ResNeeded = GetEntCost( ent )
	ent.Team = t
	ent.Cost = ent.ResNeeded
	ent:SetState( STATE_UNCONSTRUCTED )
end

function f2sPlayerSpawnedProp( pl, mdl, ent )
	SetUpEnt( pl:Team(), ent )
end
hook.Add( "PlayerSpawnedProp","f2s.Res.PlySpawnedProp", f2sPlayerSpawnedProp )

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
	PlaceResourceDrops( math.max(0,f2s_crystallimit:GetInt() - Crystals) )
end
timer.Create( "f2s.Resources.CreateCrystals", 60*8, 0, CreateCrystals ) -- 8 mins

include( 'prop_damage.lua' )