AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

local FireRadius = 1000
local TargetSelectSound = "buttons/combine_button5.wav"

-----------------------------------------
---- Initialize
-----------------------------------------
function ENT:Initialize()
	self:SetModel("models/props_combine/combine_emitter01.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:GetPhysicsObject():SetMass(10)
	self:PhysWake()
	self:Activate()
	self:SetUseType(SIMPLE_USE)
	
	EnableDamage(self, 150)
	
	self.Target = nil
	self.TargetStart = 0.0
	self.On = false
end

-----------------------------------------
-- Gets if the specified entity can be
-- targeted
-----------------------------------------
function ENT:CanTarget(Ent)
	if Ent:IsValid() and Ent:IsPlayer() and Ent:Alive() then
		if  and (Ent.NeuralDisruptor == nil or Ent.NeuralDisruptor == self or Ent.NeuralDisruptor.Target ~= Ent) then
			if Ent:Team() ~= self.Team then
				if (Ent:GetPos() - self:GetPos()):Length() <= FireRadius then
					if Visible(self, Ent) then
						return true 
					end
				end
			end
		end
	end
	return false
end

-----------------------------------------
---- Think
-----------------------------------------
function ENT:Think()
	-- Choose target
	if self.Target then
		if not self:CanTarget(self.Target) then
			self.Target = nil
		end
	end
	if not self.Target then
		local es = ents.FindInSphere(self:GetPos(), FireRadius)
		for _, e in pairs(es) do
			if self:CanTarget(e) then
				self.TargetState = CurTime()
				self.Target = e
				e.NeuralDisruptor = self
				self:EmitSound(TargetSelectSound, 100, 100)
				break
			end
		end
	end
	
	-- Turn on/off
	if self.Target then
		self.On = true
	else
		self.On = false
	end

	self:SetNWBool("On", self.On)
	self:SetNWFloat("TargetStart", self.TargetStart)
	self:SetNWEntity("Target", self.Target)
end