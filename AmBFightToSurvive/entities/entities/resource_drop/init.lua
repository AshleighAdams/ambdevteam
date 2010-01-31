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
	if not self.Breaking then
		local near = ents.FindInSphere(self:GetPos(), BreakRadius)
		for i, e in pairs(near) do
			if e:IsPlayer() then
				-- Start breaking
				self.Breaking = true
				self.BreakStart = CurTime()
				
				self.BreakSound = CreateSound(self, "ambient/energy/whiteflash.wav")
				self.BreakSound:Play()
			end
		end
	else
		if not self.Broken then
			-- Break on break delay
			if CurTime() > self.BreakStart + BreakDelay then
				self.BreakSound:Stop()
			
				local crys = ents.Create("resource_crystal")
				crys:SetPos(self:GetPos() + Vector(0, 0, 30))
				crys:Spawn()
				local crysphys = crys:GetPhysicsObject()
				if crysphys then
					crysphys:SetVelocity(Vector(0, 0, 200))
				end
				self:Remove()
				self.Broken = true
			end
		end
	end
end