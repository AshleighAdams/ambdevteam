AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

local RepairDelay = 5
local RepairRate = 1
local RepairRadius = 500
local SafeCheckDelay = 2
local SafeRadius = RepairRadius

local RestoreSound = "buttons/button14.wav"
local OnSound = "buttons/button17.wav"
local OffSound = OnSound

-----------------------------------------
---- Initialize
-----------------------------------------
function ENT:Initialize()
	self:SetModel("models/props_combine/combine_light001a.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:GetPhysicsObject():SetMass(10)
	self:PhysWake()
	self:Activate()
	self:SetUseType(SIMPLE_USE)
	self.On = false
	
	EnableDamage(self, 200)
end

-----------------------------------------
---- Think
-----------------------------------------
function ENT:Think()
	local curtime = CurTime()
	local lasttime = self.LastThinkTime or curtime
	local updatetime = curtime - lasttime
	self.LastThinkTime = curtime
	
	-- Check if its safe (no enemy players around)
	if self.Safe == nil or curtime > (self.LastSafeCheckTime or 0.0) + SafeCheckDelay then
		self.LastSafeCheckTime = curtime
		if self.Team then
			self.Safe = true
			local players = player.GetAll()
			for _, p in pairs(players) do
				if (p:GetPos() - self:GetPos()):Length() < SafeRadius then
					if p:Team() ~= self.Team then
						self.Safe = false
						break
					end
				end
			end
		else
			self.Safe = false
		end
	end
	
	if self.Safe then
		-- Repair target
		if self.On then
			local tar = self.Target
			if tar:IsValid() and tar.ResNeeded > 0 and tar.Constructed and Visible(self, tar) and (self:GetPos() - tar:GetPos()):Length() < RepairRadius then
				tar.ResNeeded = tar.ResNeeded - VoidTakeResP(self.Team, RepairRate * updatetime)
			else
				if tar:IsValid() then
					tar.Repairer = nil
				end
				self.Target = nil
			end
		end
	
		if self.Target == nil then
			-- Find a target if needed
			local props = ents.FindInSphere(self:GetPos(), RepairRadius)
			for _, e in pairs(props) do
				if e.Registered and e.Constructed and e.ResNeeded > 0 and e.Team == self.Team then
					if Visible(self, e) and curtime > (e.LastDamageTime or 0.0) + RepairDelay then
						if e.Repairer == nil or not e.Repairer:IsValid() or not e.Repairer.Target == e then
							self.Target = e
							e.Repairer = self
						end
					end
				end
			end
		end
	else
		self.Target = nil
	end
	
	-- Set on/off
	if self.Target and not self.On then
		self.On = true
		self:EmitSound(OnSound, 100, 100)
	end
	if self.Target == nil and self.On then
		self.On = false
		self:EmitSound(OffSound, 100, 100)
	end
	
	self:SetNWEntity("Target", self.Target)
	self:SetNWBool("On", self.On)
end