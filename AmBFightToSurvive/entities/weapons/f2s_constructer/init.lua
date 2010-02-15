
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include('shared.lua')


SWEP.Weight				= 5
SWEP.AutoSwitchTo		= false
SWEP.AutoSwitchFrom		= false

/*---------------------------------------------------------
	Adds an item to the build queue of a player.
---------------------------------------------------------*/
function _R.Player:AddToBuildQueue(BuildData)
	local weap = self:GetWeapon("f2s_constructer")
	if weap and weap:IsValid() then
		weap:AddToBuildQueue(BuildData)
		self:SelectWeapon("f2s_constructer")
	end
end

/*---------------------------------------------------------
	Adds an item to the build queue of the constructor. The
	build queue is used to place things that need
	construction. The following parameters can be supplied
	in builddata:
		
		Class			-		Optionally specifies the class of
								entity to create.
		OnCreate 	- 		Called when ready to create entity
								setup.  The only param for this
								callback is a function which will
								rotate and position the entity as
								needed.
		OnCancel		-		Called when the player cancels the
								build.
		Model			-		The model of the entity.
		MinNormalZ	-		The minumum height of the normal
								of the ground this can be placed
								on.
---------------------------------------------------------*/
function SWEP:AddToBuildQueue(BuildData)
	BuildData.ID = math.random(0, 100000)
	if not self.CurBuildItem then
		self.CurBuildItem = BuildData
		self.LastBuildItem = BuildData
		self.BuildQueueSize = 1
		self:BeginBuild()
	else
		self.LastBuildItem.NextBuild = BuildData
		self.LastBuildItem = BuildData
		self.BuildQueueSize = self.BuildQueueSize + 1
	end
end

/*---------------------------------------------------------
	Begins building the item at the begining of the build 
	queue. This will have the effect of allowing the 
	player to place the item.
---------------------------------------------------------*/
function SWEP:BeginBuild()
	local cbi = self.CurBuildItem
	self:SetNWInt("BuildID", cbi.ID)
	self:SetNWString("BuildClass", cbi.Class)
	self:SetNWString("BuildModel", cbi.Model)
	self:SetNWFloat("BuildMinNormalZ", cbi.MinNormalZ)
	self:SetNWBool("Building", true)
end

/*---------------------------------------------------------
	Tries building the current build item with the specified
	params. Returns true on sucsess or false on failure.
---------------------------------------------------------*/
function SWEP:Build(Pos, Norm)
	local cbi = self.CurBuildItem
	if Norm.z < cbi.MinNormalZ then
		return false
	end
	
	if cbi.OnCreate then
		cbi.OnCreate(function(ent)
			self:PositionBuildEnt(Pos, Norm, ent)
		end)
	else
		local ent = ents.Create(cbi.Class)
		ent:SetModel(cbi.Model)
		self:PositionBuildEnt(Pos, Norm, ent)
		ent:Spawn()
	end
	
	-- Remove cur build item
	self.CurBuildItem = cbi.NextBuild
	self.BuildQueueSize = self.BuildQueueSize - 1
	if self.CurBuildItem then
		self:BeginBuild()
	else
		self:SetNWBool("Building", false)
	end
	
	return true
end

/*---------------------------------------------------------
	Cancels the current build item.
---------------------------------------------------------*/
function SWEP:Cancel()
	if self.CurBuildItem.OnCancel then
		self.CurBuildItem.OnCancel()
	end
	self.BuildQueueSize = self.BuildQueueSize - 1
	self.CurBuildItem = self.CurBuildItem.NextBuild
	if self.CurBuildItem then
		self:BeginBuild()
	else
		self:SetNWBool("Building", false)
	end
end