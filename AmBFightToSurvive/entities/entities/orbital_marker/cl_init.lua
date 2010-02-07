include('shared.lua')

ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

local LaserMat = Material("tripmine_laser")
local LaserHitMat = Material("sprites/gmdm_pickups/light")
local LaserHitRatio = 1.0
local LaserMultiplier = 5.0
local FairyMat = Material("sprites/gmdm_pickups/light")
local FairySize = 25.0
local FairyRot = 20.0

-----------------------------------------
---- Initialize
-----------------------------------------
function ENT:Initialize()
	local ent = self.Entity
	local bounds = 65536
	ent:SetModel("models/Items/AR2_Grenade.mdl")
	ent:SetRenderBoundsWS(Vector(-bounds, -bounds, -bounds), Vector(bounds, bounds, bounds))
	
	self.HasInitialData = false
	self.FairyAmount = 0
	self.FairyIntensity = 0.0
	self.FairyRotation = 0.0
	self.FairyRadius = 0.0
	self.LaserSize = 0.0
	self.ScreenGamma = 0.0
	
	self:InitializeShared()
end

-----------------------------------------
---- Draw
-----------------------------------------
function ENT:Draw()
	if self.HasInitialData then
		self:DrawLaser()
		self:DrawFairies()
		
		if self.ScreenGamma ~= 0.0 then
			cam.Start2D()
			surface.SetDrawColor(255, 255, 255, self.ScreenGamma * 255.0)
			surface.DrawRect(0, 0, ScrW() - 1, ScrH() - 1)
			cam.End2D()
		end
	end
end

-----------------------------------------
---- Think
-----------------------------------------
function ENT:Think()
	local ent = self.Entity
	local curtime = CurTime()
	
	-- Get initial data if needed
	self.Source = ent:GetNWVector("Source", nil)
	self.Target = ent:GetNWVector("Target", nil)
	self.Valid = ent:GetNWBool("Valid", nil)
	if self.Source ~= nil and self.Target ~= nil and self.Valid ~= nil then
		self.HasInitialData = true
	end
	
	-- Laser data
	self.LaserStartTime = ent:GetNWFloat("LaserStartTime", 0.0)
	self.FairyAmount = self:GetFairyAmount(curtime)
	self.FairyRadius = self:GetFairyRadius(curtime)
	self.FairyIntensity = self:GetFairyIntensity(curtime)
	self.LaserSize = self:GetLaserSize(curtime)
	self.FairyRotation = self:GetFairyRotation(curtime)
	self.ScreenGamma = self:GetScreenGamma(curtime)
	
	self:HandleFairies()
end

-----------------------------------------
-- Manages the fairies around this
-- marker. Fairies are small specs of
-- light that appear around the site of
-- the orbital gun's target, just as its
-- about fire.
-----------------------------------------
function ENT:HandleFairies()
	self.Fairies = self.Fairies or { }
	self.LastFairyUpdate = self.LastFairyUpdate or CurTime()
	-- Function to initialize a new fairy
	function InitFairy(Fairy)
		local ang = math.random() * math.pi * 2.0
		local dis = math.random() * self.FairyRadius
		local int = (math.random() + 1.2 - ((dis / self.FairyRadius) / 2.0)) * self.FairyIntensity
		local rot = (math.random() - 0.5) * 2.0 / (dis / self.FairyRadius + 0.5)
		Fairy.Age = 0.0
		Fairy.Intensity = int
		Fairy.Position = Vector(math.sin(ang) * dis, math.cos(ang) * dis, 0.0)
		Fairy.Rotation = rot
		Fairy.Size = 0
	end
	
	-- Create or destroy fairies as needed.
	local diff = math.ceil(self.FairyAmount) - #(self.Fairies)
	while diff > 0 do
		-- Add a fairy
		local f = {}
		InitFairy(f)
		table.insert(self.Fairies, f)
		diff = diff - 1
	end
	while diff < 0 do
		-- Remove a fairy
		table.remove(self.Fairies, 1)
		diff = diff + 1
	end
	
	-- Update fairies
	local curtime = CurTime()
	local updatetime = curtime - self.LastFairyUpdate
	self.LastFairyUpdate = curtime
	for i, fairy in pairs(self.Fairies) do
		-- Raising and dialating
		fairy.Size = fairy.Size + ((fairy.Intensity - fairy.Age) * updatetime)
		fairy.Age = fairy.Age + updatetime
		fairy.Position = fairy.Position + Vector(0, 0, math.sqrt(fairy.Intensity) * updatetime * 50.0)
		
		-- Rotating
		local rotamount = self.FairyRotation * fairy.Rotation * (fairy.Position.z / 100.0) * FairyRot * updatetime
		fairy.Position:Rotate(Angle(0, rotamount, 0))
		
		if fairy.Size < 0 then
			InitFairy(fairy)
		end
	end
end

-----------------------------------------
-- Draws all current fairies as sprites
-----------------------------------------
function ENT:DrawFairies()
	render.SetMaterial(FairyMat)
	for i, fairy in pairs(self.Fairies) do
		local alpha = Gauss(fairy.Intensity, 1.0, 1.0, fairy.Age)
		render.DrawSprite(fairy.Position + self.Target, fairy.Size * FairySize, fairy.Size * FairySize, Color(255, 255, 255, alpha * 255))
	end
end

-----------------------------------------
-- Draws the actual laser coming from the
-- source to the target.
-----------------------------------------
function ENT:DrawLaser()
	local lasersize = self.LaserSize * LaserMultiplier
	render.SetMaterial(LaserMat)
	render.StartBeam(2)
	render.AddBeam(self.Target, lasersize, 0, Color(255, 255, 255, 255))
	render.AddBeam(self.Source, lasersize, 1, Color(255, 255, 255, 0))
	render.EndBeam()
	render.SetMaterial(LaserHitMat)
	render.DrawSprite(self.Target, lasersize * LaserHitRatio, lasersize * LaserHitRatio, Color(255, 255, 255, 255))
end