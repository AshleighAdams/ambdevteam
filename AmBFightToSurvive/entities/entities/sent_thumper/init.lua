AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

-----------------------------------------
---- Initialize
-----------------------------------------
function ENT:Initialize()
	self:SetModel("models/props_combine/CombineThumper002.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:PhysWake()
	self:Activate()
	self:SetUseType(SIMPLE_USE)
	EnableDamage(self, 10000)
end

-----------------------------------------
---- Think
-----------------------------------------
function ENT:Think()
	
end