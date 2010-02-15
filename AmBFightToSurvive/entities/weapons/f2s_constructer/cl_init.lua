
include('shared.lua')

SWEP.PrintName			= "Prop Constructor"			
SWEP.Slot				= 5
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
	-- Calculate beam
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
	
	-- Check for build items
	local builditem = self:GetCurrentBuildItem()
	if builditem then
		self:DrawLaser(beamstart, beamend, nil)
		if traceres.Hit then
			self:DrawDisplayEnt(traceres.Pos, traceres.Norm, true)
		else
			self:DrawDisplayEnt(traceres.Pos, Vector(0.0, 0.0, 1.0), false)
		end
	else
		self:DrawLaser(beamstart, beamend, traceres.Entity)
	end
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

/*---------------------------------------------------------
	Draws the ghosted display entity while selecting a
	build spot.
---------------------------------------------------------*/
function SWEP:DrawDisplayEnt(HitPos, HitNormal, Valid)
	local builditem = self:GetCurrentBuildItem()
	if HitNormal.z < builditem.MinNormalZ then
		Valid = false
	end
	local displayent = self:GetDisplayEnt(builditem)
	self:PositionBuildEnt(HitPos, HitNormal, displayent)
	local beamcolor = Color(255, 255, 255, 255)
	render.SetBlend(0.25)
	if Valid then
		render.SetColorModulation(1, 1, 1)
	else
		beamcolor = Color(255, 0, 0, 255)
		render.SetColorModulation(1, 0.5, 0.5)
	end
	displayent:DrawModel()
	render.SetColorModulation(1, 1, 1)
	render.SetBlend(1.0)
	
	-- Draw beams
	local beamsize = 20
	render.SetMaterial(self.LaserMat)
	local min = displayent:OBBMins()
	local max = displayent:OBBMaxs()
	local aaa = displayent:LocalToWorld(Vector(max.x, max.y, max.z))
	local aab = displayent:LocalToWorld(Vector(max.x, max.y, min.z))
	local aba = displayent:LocalToWorld(Vector(max.x, min.y, max.z))
	local abb = displayent:LocalToWorld(Vector(max.x, min.y, min.z))
	local baa = displayent:LocalToWorld(Vector(min.x, max.y, max.z))
	local bab = displayent:LocalToWorld(Vector(min.x, max.y, min.z))
	local bba = displayent:LocalToWorld(Vector(min.x, min.y, max.z))
	local bbb = displayent:LocalToWorld(Vector(min.x, min.y, min.z))
	render.DrawBeam(aab, abb, beamsize, 0, 12.5, beamcolor)
	render.DrawBeam(abb, bbb, beamsize, 0, 12.5, beamcolor)
	render.DrawBeam(bbb, bab, beamsize, 0, 12.5, beamcolor)
	render.DrawBeam(bab, aab, beamsize, 0, 12.5, beamcolor)
	
	render.DrawBeam(aaa, aba, beamsize, 0, 12.5, beamcolor)
	render.DrawBeam(aba, bba, beamsize, 0, 12.5, beamcolor)
	render.DrawBeam(bba, baa, beamsize, 0, 12.5, beamcolor)
	render.DrawBeam(baa, aaa, beamsize, 0, 12.5, beamcolor)
	
	render.DrawBeam(aba, abb, beamsize, 0, 12.5, beamcolor)
	render.DrawBeam(bba, bbb, beamsize, 0, 12.5, beamcolor)
	render.DrawBeam(baa, bab, beamsize, 0, 12.5, beamcolor)
	render.DrawBeam(aaa, aab, beamsize, 0, 12.5, beamcolor)
end

/*---------------------------------------------------------
	Gets the build data for the current item on the build
	queue.
---------------------------------------------------------*/
function SWEP:GetCurrentBuildItem()
	if self:GetNWBool("Building", false) then
		if not self.CurBuildItem or self.CurBuildItem.ID ~= self:GetNWInt("BuildID", 0) then
			self.CurBuildItem = {
				ID = self:GetNWInt("BuildID", 0),
				Class = self:GetNWString("BuildClass", ""),
				Model = self:GetNWString("BuildModel", ""),
				MinNormalZ = self:GetNWFloat("BuildMinNormalZ", 0.0)
			}
		end
		return self.CurBuildItem
	else
		if self.CurBuildItem then
			if self.CurBuildItem.DisplayEnt then
				self.CurBuildItem.DisplayEnt:Remove()
			end
			self.CurBuildItem = nil
		end
		return nil
	end
end

/*---------------------------------------------------------
	Gets the display entity for the specified build item.
	The display entity will show what will be spawned and
	where before it is actually spawned.
---------------------------------------------------------*/
function SWEP:GetDisplayEnt(BuildItem)
	if BuildItem.DisplayEnt and BuildItem.DisplayEnt:GetModel() == BuildItem.Model then
		return BuildItem.DisplayEnt
	else
		local e = ents.Create("prop_physics")
		e:SetNoDraw(true)
		e:SetNotSolid(true)
		e:SetModel(BuildItem.Model)
		e:Spawn()
		BuildItem.DisplayEnt = e
		return e
	end
end

function SWEP:DrawHUD()
	if self:GetCurrentBuildItem() then
		local x = ScrW() / 2.0
		local y = ScrH() * 0.6
		local xalign = TEXT_ALIGN_CENTER
		local yalign = TEXT_ALIGN_CENTER
		local font = "Default"
		local diff = 15
		local color = Color(255, 255, 255, 255)
		draw.SimpleText("Primary: Place", font, x, y + (diff * 0), color, xalign, yalign)
		draw.SimpleText("Secondary: Cancel", font, x, y + (diff * 1), color, xalign, yalign)
		draw.SimpleText("Reload: Rotate", font, x, y + (diff * 2), color, xalign, yalign)
		draw.SimpleText("Items Left: " .. tostring(self.BuildQueueSize), font, x, y + (diff * 3), color, xalign, yalign)
	else
		pl = LocalPlayer()
		ent = self:Trace().Entity
		if ValidEntity(ent) then
			UpdateProp(ent)
			if ent.Registered then
				local y = 0
				
				local dy = (ScrH()/4)+y
				local text = "Prop Status: " .. tostring( (math.Round(((ent.Cost-ent.ResNeeded)/ent.Cost)*1000)/1000)*100  ) .. "%"
				draw.WordBox( 8,0,dy,text,"Default",Color(50,50,50,100),Color(255,255,255,255) )
				
				y = 30
				local text = "Resources Left: " .. tostring( math.Round(ent.ResNeeded) ) 
				draw.WordBox( 8,0,ScrH()/4+y,text,"Default",Color(50,50,50,100),Color(255,255,255,255) )

				y = 60
				local text = "Cost: " .. tostring( math.Round(ent.Cost) )
				draw.WordBox( 8,0,ScrH()/4+y,text,"Default",Color(50,50,50,100),Color(255,255,255,255) )
			end
		end
	end
end
