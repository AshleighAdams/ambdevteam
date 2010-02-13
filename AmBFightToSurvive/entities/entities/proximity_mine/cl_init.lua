include('shared.lua')

ENT.RenderGroup = RENDERGROUP_BOTH

-----------------------------------------
---- Initialize
-----------------------------------------
function ENT:Initialize()
	local ent = self.Entity
	ent:SetModel("models/props_combine/combine_mine01.mdl")
	
	self.Activated = false
	self.LastActivated = false
end

-----------------------------------------
---- Think
-----------------------------------------
function ENT:Think()
	self.Activated = self:GetNWBool("Activated", false)
	self.Team = self:GetNWInt("Team", 0)
	
	self:SetNoDraw(self.Activated and (LocalPlayer():Team() ~= self.Team))
	if self.Activated ~= self.LastActivated then
		self.LastActivated = self.Activated
		local ed = EffectData()
		ed:SetEntity(self)
		util.Effect("propspawn", ed, true, true)
	end
end


-----------------------------------------
---- Draw
-----------------------------------------
function ENT:Draw()
	if not self.Activated then
		self:DrawModel()
	end
end

-----------------------------------------
---- DrawTranslucent
-----------------------------------------
function ENT:DrawTranslucent()
	if self.Activated and LocalPlayer():Team() == self.Team then
		render.SuppressEngineLighting(true)
		render.SetColorModulation(1, 0, 0)
		render.SetBlend(0.5)
		self:DrawModel()
		render.SuppressEngineLighting(false)
		render.SetColorModulation(1, 1, 1)
		render.SetBlend(1.0)
	end
end