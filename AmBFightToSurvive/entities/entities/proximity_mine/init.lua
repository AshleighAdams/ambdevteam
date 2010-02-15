AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

local ActivateDelay = 2.5
local ActivationRadius = 10
local TriggerRadius = 100
local BlastRadius = 300
local BlastDamage = 600

local ArmSound = "items/battery_pickup.wav"

list.Set("BuildData", "proximity_mine", {
	MinNormalZ = 0.80,
	Model = "models/props_combine/combine_mine01.mdl" })

-----------------------------------------
---- Initialize
-----------------------------------------
function ENT:Initialize()
	self:SetModel("models/props_combine/combine_mine01.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:GetPhysicsObject():SetMass(10)
	self:PhysWake()
	self:Activate()
	
	self.Activated = false
end

-----------------------------------------
---- Think
-----------------------------------------
function ENT:Think()
	local curtime = CurTime()

	-- Handles activation
	self.ActivationArea = (self.ActivationArea or self:GetPos())
	self.ActivationStart = (self.ActivationStart or curtime)
	local dis = (self:GetPos() - self.ActivationArea):Length()
	if not self.Activated then
		if dis > ActivationRadius then
			self.ActivationArea = self:GetPos()
			self.ActivationStart = curtime
		end
		if curtime > self.ActivationStart + ActivateDelay then
			self.Activated = true
			self:EmitSound(ArmSound, 100, 100)
		end
	else
		if dis > ActivationRadius then
			self.Activated = false
			self:EmitSound(ArmSound, 100, 100)
		end
	end
	
	-- Explosionating
	if self.Activated then
		local near = ents.FindInSphere(self:GetPos(), TriggerRadius)
		for _, e in pairs(near) do
			if e:IsPlayer() and e:Team() ~= self.Team then
				self:Boom()
				return
			end
		end
	end
	
	self:SetNWBool("Activated", self.Activated)
	self:SetNWInt("Team", self.Team)
end

-----------------------------------------
-- Explodes the mine.
-----------------------------------------
function ENT:Boom()
	if not self.Boomed then
		self.Boomed = true
		local effectdata = EffectData()
		effectdata:SetStart(self:GetPos())
		effectdata:SetOrigin(self:GetPos())
		effectdata:SetScale(1)
		util.Effect("Explosion", effectdata)
		util.BlastDamage(self, self.Owner, self:GetPos(), BlastRadius, BlastDamage)
		self:Remove()
	end
end
ENT.OnTakeDamage = ENT.Boom
ENT.OnTakeNormalDamage = ENT.Boom