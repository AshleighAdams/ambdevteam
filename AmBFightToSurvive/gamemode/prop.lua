local MetaProp = { }
--------------------------------------------
-- Sets the state of the prop in terms of
-- its construction progress. States are
-- cyclical.
--------------------------------------------
STATE_CONSTRUCTED, STATE_UNCONSTRUCTED, STATE_CONSTRUCTING, STATE_UNCONSTRUCTING = 1, 2, 3, 4
function MetaProp:SetState(state)
	if state == STATE_UNCONSTRUCTED then
		self.Team = nil
		self:SetCollisionGroup( COLLISION_GROUP_WORLD)
		self:SetMaterial( "models/wireframe" )
		self.State = state
		self.Constructed = false
		return
	end
	if state == STATE_CONSTRUCTED then
		self:SetCollisionGroup(COLLISION_GROUP_NONE)
		self:SetMaterial( "" )
		self.State = state
		self.Constructed = true
		return
	end
	if state == STATE_UNCONSTRUCTING then
		self:SetCollisionGroup(COLLISION_GROUP_NONE)
		self:SetMaterial( "models/wireframe" )
		self.State = state
		self.Constructed = false
		return
	end
	if state == STATE_CONSTRUCTING then
		self.State = state
		self.Constructed = false
		return
	end
end
	
--------------------------------------------
-- Gets the state of a prop.
--------------------------------------------
function MetaProp:GetState()
	if self.State then
		return self.State
	end
	return 0
end

--------------------------------------------
-- Begins the construction of this prop to
-- the specified team.
--------------------------------------------
function MetaProp:Construct(Team)
	if self:GetState() == STATE_UNCONSTRUCTED then
		self.Team = Team
		self:SetState(STATE_CONSTRUCTING)
		
		-- Time between ContinueConstructing calls
		local ConstructDelay = 0.1
		
		-- Function to continue construction of an entity
		function ContinueConstructing(Ent)
			if Ent:IsValid() and Ent:GetState() == STATE_CONSTRUCTING then
				local t = Ent.Team
				Ent.ResNeeded = Ent.ResNeeded - (VoidTakeResP(t, 1))
				if Ent.ResNeeded <= 0 then
					-- Constructed
					Ent:SetState(STATE_CONSTRUCTED)
				else
					-- Recall this function at delay
					timer.Simple(ConstructDelay, ContinueConstructing, Ent)
				end
			end
		end
		
		-- Begin
		ContinueConstructing(self)
	end
end

--------------------------------------------
-- Begins the deconstruction of this prop.
--------------------------------------------
function MetaProp:Deconstruct()
	if self:GetState() == STATE_CONSTRUCTED then
		self:SetState(STATE_UNCONSTRUCTING)
		
		-- Time between ContinueDeconstructing calls
		local DeconstructDelay = 0.01
		
		-- Function to continue the deconstruction of an entity
		function ContinueDeconstructing(Ent)
			if Ent:IsValid() and Ent:GetState() == STATE_UNCONSTRUCTING then
				local t = Ent.Team
				Ent.ResNeeded = Ent.ResNeeded + 1
				if t then
					GiveResP(t, 0.75)
				end
				if Ent.ResNeeded > Ent.Cost then
					-- Deconstructed
					Ent:SetState(STATE_UNCONSTRUCTED)
				else
					timer.Simple(DeconstructDelay, ContinueDeconstructing, Ent)
				end
			end
		end
		
		-- Begin
		ContinueDeconstructing(self)
	end
end

--------------------------------------------
-- Damages the prop with the specified
-- damage info.
--------------------------------------------
function MetaProp:Damage(DamageInfo)
	local damage = DamageInfo:GetDamage() / 20.0
	if DamageInfo:IsExplosionDamage() then
		damage = damage * 2.0
	end
	self.ResNeeded = self.ResNeeded + damage
	if self.Constructed then
		if self.ResNeeded > self.Cost then
			self:Destroy()
		else
			self:Flicker()
		end
	else
		if self.ResNeeded > self.Cost + 4 then
			self:Destroy()
		else
			self:Flicker()
		end
	end
end

--------------------------------------------
-- Destroys the prop.
--------------------------------------------
function MetaProp:Destroy()
	self:Remove()
end

--------------------------------------------
-- Small visual effect that causes the
-- wireframe texture and normal texture to
-- flicker on the prop.
--------------------------------------------
function MetaProp:Flicker()
	local curtex = "models/wireframe"
	local ntex = ""
	if self.Constructed then
		local temp = curtex
		curtex = ntex
		ntex = temp
	end
	
	umsg.Start("flicker_prop")
	umsg.Entity(self)
	umsg.String(ntex)
	umsg.String(curtex)
	umsg.Float(0.05)
	umsg.End()
end

--------------------------------------------
-- Registers a prop into the construction
-- system.
--------------------------------------------
function RegisterProp(ent)
	setmetatable(ent:GetTable(), {__index = MetaProp}) 
	ent.ResNeeded = GetEntCost(ent)
	ent.Cost = ent.ResNeeded
	ent.Registered = true
	ent:SetState(STATE_UNCONSTRUCTED)
end

local UnconstructedTools = { "colour", "material", } -- Blacklist
local ConstructedTools = { "material", "colour", "remover" } -- Whitelist

local function CanTool( pl, tr, toolmode )
	if tr.HitNonWorld then
		ent = tr.Entity
		if ent:GetClass() == "prop_physics" then
			if not ent.Registered then
				RegisterProp(ent)
			end
			if ent.Constructed then
				if table.HasValue(ConstructedTools, toolmode) or string.find(toolmode, "wire") then
					return true
				else
					return false
				end
			else
				if not table.HasValue(UnconstructedTools, toolmode) then
					return true
				else
					return false
				end
			end
		end
	end
end
hook.Add( "CanTool", "f2s.CanTool", CanTool) -- DO NOT OVERRIDE THIS WITH GM:CanTool AS IT BREAKS PROP PROTECTIONS!

local function PhysgunPickup(pl, ent)
	if ent:GetClass() == "prop_physics" then
		if not ent.Registered then
			RegisterProp(ent)
		end
		if ent:GetState() == STATE_UNCONSTRUCTED then
			return true
		else
			return false
		end
	end
end
hook.Add( "PhysgunPickup", "f2s.PhysPickup", PhysgunPickup ) -- DO NOT OVERRIDE THIS WITH GM:CanTool AS IT BREAKS PROP PROTECTIONS!

local function PlayerSpawnedProp(pl, mdl, ent)
	RegisterProp(ent)
end
hook.Add( "PlayerSpawnedProp","f2s.Res.PlySpawnedProp", PlayerSpawnedProp )

local function EntityTakeDamage( ent, inflictor, attacker, amount, dmginfo )
	if ent:GetClass() == "prop_physics" then
		if not ent.Registered then
			RegisterProp(ent)
		end
		ent:Damage(dmginfo)
	end
	
	-- Sneak in a hook to allow normal entites to know when they are damaged
	if ent.OnTakeNormalDamage then
		ent:OnTakeNormalDamage(dmginfo)
	end
end
hook.Add("EntityTakeDamage", "f2s.enttakedmg", EntityTakeDamage)

function CheckForNewProps()
	for k,ent in pairs(ents.FindByClass("prop_physics")) do
		if not ent.Registered then
			RegisterProp(ent)
		end
	end
end
timer.Create("f2s.NewPropsCheck", 5, 0, CheckForNewProps)