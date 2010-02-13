
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

function SWEP:DrawHUD()
	pl = LocalPlayer()
	ent = self:Trace().Entity
	if !ValidEntity(ent) then return end

	UpdateProp(ent)

	local Constructed = ent:GetNWBool("Constructed", false)
	local State = ent:GetNWInt("State", 0) or 0
	local Team = ent:GetNWInt("Team", 0) or 1
	local ResNeeded = ent:GetNWFloat("ResNeeded", 0.0) or 0
	local Cost = ent:GetNWFloat("Cost", 0.0) or 0
	local Registered = ent:GetNWBool("Registered", false) or 0

	if !Registered then return end

	local y = 0
	
	local dy = (ScrH()/4)+y
	local text = "Prop Status: " .. tostring( (math.Round(((Cost-ResNeeded)/Cost)*1000)/1000)*100  ) .. "%"
	draw.WordBox( 8,0,dy,text,"Default",Color(50,50,50,100),Color(255,255,255,255) )
	
	y = 30
	local text = "Resources Left: " .. tostring( math.Round(ResNeeded) ) 
	draw.WordBox( 8,0,ScrH()/4+y,text,"Default",Color(50,50,50,100),Color(255,255,255,255) )

	y = 60
	local text = "Cost: " .. tostring( math.Round(Cost) )
	draw.WordBox( 8,0,ScrH()/4+y,text,"Default",Color(50,50,50,100),Color(255,255,255,255) )
end
