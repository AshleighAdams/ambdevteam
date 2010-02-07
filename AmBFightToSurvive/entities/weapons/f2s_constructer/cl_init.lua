
include('shared.lua')

SWEP.PrintName			= "Prop Constructor"			
SWEP.Slot				= 0
SWEP.SlotPos			= 2
SWEP.DrawAmmo			= false
SWEP.DrawCrosshair		= false

SWEP.LaserMat = Material("tripmine_laser")
SWEP.LaserSize = 2
SWEP.MissLaserColor = Color(255, 255, 255, 255)
SWEP.HitLaserColor = Color(0, 255, 255, 255)

/*---------------------------------------------------------
	ViewModelDrawn
---------------------------------------------------------*/
function SWEP:ViewModelDrawn()
	local traceres = self:Trace()
	if self.Attach == nil then
		local vm = self.Owner:GetViewModel()
		self.Attach = vm:LookupAttachment("muzzle")
		if self.Attach == 0 then
			self.Attach = vm:LookupAttachment("1")
		end
	end
	local beamstart = self.Owner:GetViewModel():GetAttachment(self.Attach).Pos
	local beamend = traceres.Pos
	
	self:DrawLaser(beamstart, beamend, traceres.Entity)
end

/*---------------------------------------------------------
	Draws the laser seen by the player when selecting a 
	prop to construct.
---------------------------------------------------------*/
function SWEP:DrawLaser(Start, End, Entity)
	render.SetMaterial(self.LaserMat)
	local lasercolor = self.MissLaserColor
	if Entity then
		lasercolor = self.HitLaserColor
	end
	render.DrawBeam(Start, End, self.LaserSize, 0, 12.5, lasercolor)
end