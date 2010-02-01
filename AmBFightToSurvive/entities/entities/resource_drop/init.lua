AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

local BreakRadius = 500
local BreakDelay = 10

-----------------------------------------
---- Initialize
-----------------------------------------
function ENT:Initialize()
	self:SetModel("models/Items/item_item_crate.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetHealth(60)
	self:PhysWake()
	self:Activate()
end

-----------------------------------------
---- Think
-----------------------------------------
function ENT:Think()
	local curtime = CurTime()
	if not self.Breaking then
		local near = ents.FindInSphere(self:GetPos(), BreakRadius)
		for i, e in pairs(near) do
			if e:IsPlayer() then
				-- Start breaking
				self.Breaking = true
				self.BreakStart = curtime
				self.BreakSound = CreateSound(self, "ambient/alarms/combine_bank_alarm_loop4.wav")
				self.BreakSound:Play()
			end
		end
	else
		if not self.Broken then
			-- Break on break delay
			if curtime > self.BreakStart + BreakDelay then
				self.BreakSound:Stop()
				WorldSound("ambient/energy/whiteflash.wav", self:GetPos(), 160, 140)
			
				local crys = ents.Create("resource_crystal")
				crys:SetPos(self:GetPos() + Vector(0, 0, 30))
				crys:Spawn()
				local crysphys = crys:GetPhysicsObject()
				if crysphys then
					crysphys:SetVelocity(Vector(0, 0, 200))
				end
				self:Remove()
				self.Broken = true
			else
				-- Change sound pitch to indicate when breaking
				local done = (curtime - self.BreakStart) / BreakDelay
				self.BreakSound:ChangePitch(math.Clamp(done * 255, 0, 255))
			end
		end
	end
end