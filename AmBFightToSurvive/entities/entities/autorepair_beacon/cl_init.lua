include('shared.lua')

ENT.RenderGroup = RENDERGROUP_BOTH

local LaserMat = Material("tripmine_laser")
local LaserSize = 50.0
local LaserColor = Color(255, 0, 0, 255)
local LaserOffset = Vector(0, 0, 38)
local Drone = "ambient/energy/electric_loop.wav"
local DroneRadius = 1500

-----------------------------------------
---- Initialize
-----------------------------------------
function ENT:Initialize()
	local ent = self.Entity
	ent:SetModel("models/props_combine/combine_light001a.mdl")
end

-----------------------------------------
---- Think
-----------------------------------------
function ENT:Think()
	self.Target = self:GetNWEntity("Target", nil)
	self.On = self:GetNWBool("On", false)
	
	-- Drone when on
	if (LocalPlayer():GetPos() - self:GetPos()):Length() < DroneRadius and self.On then
		if not self.Drone then
			self.Drone = CreateSound(self, Drone)
			self.Drone:Play()
		end
	else
		if self.Drone then
			self.Drone:Stop()
			self.Drone = nil
		end
	end
end

-----------------------------------------
---- OnRemove
-----------------------------------------
function ENT:OnRemove()
	if self.Drone then
		self.Drone:Stop()
	end
end

-----------------------------------------
---- Draw
-----------------------------------------
function ENT:Draw()
	self:DrawModel()

	-- Draw laser if needed
	if self.On and self.Target and self.Target:IsValid() then
		render.SetMaterial(LaserMat)
		render.DrawBeam(self:LocalToWorld(LaserOffset), self.Target:GetPos(), LaserSize, 0, 0, LaserColor)
	end
end