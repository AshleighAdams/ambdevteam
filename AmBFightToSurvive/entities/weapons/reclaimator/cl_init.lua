include('shared.lua')

SWEP.PrintName			= "Reclaimator"			
SWEP.Slot				= 1
SWEP.SlotPos			= 1
SWEP.DrawAmmo			= false


local OnSound = "ambient/energy/force_field_loop1.wav"
local ChangeSound = "buttons/button16.wav"

--------------------------------------------
-- Think
--------------------------------------------
function SWEP:Think()
	self.On = self:GetNWBool("On", false)
	if self.On then
		if not self.OnSound then
			self.OnSound = CreateSound(self.Weapon, OnSound)
			self.OnSound:Play()
			self:EmitSound(ChangeSound, 100, 100)
		end
	else
		if self.OnSound then
			self.OnSound:Stop()
			self.OnSound = nil
			self:EmitSound(ChangeSound, 100, 100)
		end
	end
end


--------------------------------------------
-- DrawWorldModel
--------------------------------------------
function SWEP:DrawWorldModel()
	self.Weapon:DrawModel()
	if self.On then
		self:ViewModelDrawn()
	end
end

--------------------------------------------
-- DrawLaser
--------------------------------------------
function SWEP:DrawLaser(Start, End, Entity)
	render.SetMaterial(self.LaserMat)
	local lasercolor = Color(255, 0, 0)
	local lasersize = self.LaserSize
	if self.On then
		lasersize = lasersize * 10.0
	end
	render.DrawBeam(Start, End, lasersize, 0, 12.5, lasercolor)
end

--------------------------------------------
-- OnRemove
--------------------------------------------
function SWEP:OnRemove()
	if self.OnSound then
		self.OnSound:Stop()
	end
end