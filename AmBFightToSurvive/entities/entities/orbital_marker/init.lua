AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

-----------------------------------------
---- Initialize
-----------------------------------------
function ENT:Initialize()
	local ent = self.Entity
	ent:SetModel("models/Items/AR2_Grenade.mdl")
	self.Valid = self:FindTarget()
	
	ent:SetNWVector("Source", self.Source)
	ent:SetNWVector("Target", self.Target)
	ent:SetNWBool("Valid", self.Valid)
	
	-- Set up an action at a time to show
	-- if valid.
	self.Time = CurTime()
	if self.Valid then
		self.Action = self.NowValid
	else
		self.Action = self.NowInvalid
	end
	
	self:InitializeShared()
end

-----------------------------------------
-- Finds the place directly above and
-- below the marker to find the source
-- and the target and to determine if
-- this marker is valid.
-----------------------------------------
function ENT:FindTarget()
	local pos = self:GetPos()
	local bounds = 10000;
	local norm = Vector(0, 0, bounds)
	local hightrace = util.QuickTrace(pos, norm, self.Entity)
	local lowtrace = util.QuickTrace(pos, Vector(0, 0, 0) - norm, self.Entity)
	self.Target = lowtrace.HitPos
	self.Source = hightrace.HitPos
	if lowtrace.Hit then
		if hightrace.Hit then
			if hightrace.HitSky then
				return true
			end
		else
			return true
		end
	end
	-- Not valid if not hit
	return false
end

-----------------------------------------
---- Think
-----------------------------------------
function ENT:Think()
	local ent = self.Entity

	-- Timed actions
	local curtime = CurTime()
	local lastupdate = self.LastUpdate or curtime
	self.LastUpdate = curtime
	local updatetime = curtime - lastupdate
	if curtime > self.Time and self.Action ~= nil then
		self:Action()
	end
	
	-- Laser start time
	ent:SetNWFloat("LaserStartTime", self.LaserStartTime)
	
	-- Sounds
	if self.Drone then
		self.Drone:ChangePitch(self:GetDronePitch(curtime))
	end
	
	-- Damage
	if self.LaserDamage != nil then
		self.LaserDamage = self:GetLaserDamage(curtime)
		self.LaserSize = self:GetLaserSize(curtime)
		local entlist = ents.FindInSphere(self.Target, self.LaserSize)
		for i, ent in pairs(entlist) do
			if ent ~= self.Entity then
				local pos = ent:GetPos()
				local diff = pos - self.Target
				local dis = diff:Length()
				local affect = ((self.LaserSize - dis) / self.LaserSize) ^ 0.5
				local damage = self.LaserDamage * updatetime * affect
			
				-- Hurt
				local damageinfo = DamageInfo()
				damageinfo:SetDamage(damage)
				damageinfo:SetDamageType(DMG_GENERIC)
				if self.FromPlayer ~= nil and self.FromPlayer:IsValid() then
					damageinfo:SetAttacker(self.FromPlayer)
				else
					damageinfo:SetAttacker(self)
				end
				damageinfo:SetInflictor(self)
				ent:TakeDamageInfo(damageinfo)
				
				-- Throw
				local power = (self.LaserSize ^ 0.3) / 50.0
				local rotdiff = diff
				rotdiff:Rotate(Angle(0, 90, 0))
				local force = (Vector(0, 0, 800) + rotdiff) * affect * power
				local phys = ent:GetPhysicsObject()
				if phys:IsValid() then
					phys:Wake()
					phys:ApplyForceCenter(force * phys:GetMass())
				else
					ent:SetVelocity(force)
				end
			end
		end
	end
end

-----------------------------------------
-- Called when the entity is determined
-- to be valid.
-----------------------------------------
function ENT:NowValid()
	WorldSound("buttons/button14.wav", self.Entity:GetPos(), 100, 100)
	self.Action = self.NowWarn
	self.Time = self.Time + 2.0
end

-----------------------------------------
-- Called when the entity is determined
-- to be invalid.
-----------------------------------------
function ENT:NowInvalid()
	WorldSound("buttons/button19.wav", self.Entity:GetPos(), 100, 100)
	self.Action = nil
	self.Entity:Remove()
end

-----------------------------------------
-- Creates a siren that warns against
-- the oncoming laser.
-----------------------------------------
function ENT:NowWarn()
	self.Siren = CreateSound(self.Entity, "ambient/alarms/siren.wav")
	self.Siren:Play()
	self.Siren:FadeOut(15)
	self.Action = self.NowFire
	self.Time = self.Time + 5.0
end

-----------------------------------------
-- Fires the gun by setting the start
-- time
-----------------------------------------
function ENT:NowFire()
	self.Drone = CreateSound(self.Entity, "ambient/machines/combine_shield_touch_loop1.wav")
	self.Drone:Play()
	
	self.LaserDamage = 0.0
	
	self.LaserStartTime = CurTime()
	self.Action = self.NowPeakFire
	self.Time = self.Time + LaserPeak
end

-----------------------------------------
-- The peak of the gun's laser.
-----------------------------------------
function ENT:NowPeakFire()
	self.Drone:FadeOut(15)
	self.Explosion = CreateSound(self.Entity, "ambient/explosions/citadel_end_explosion2.wav")
	self.Explosion:Play()

	-- Sphagetti
	local near = ents.FindInSphere(self.Target, self.LaserSize)
	for _, e in pairs(near)	do
		if e.Registered then
			e:BreakConstraints()
		end
	end
	
	-- Scorches
	for i = 1, 50 do
		local ang = math.random() * math.pi * 2.0
		local dis = math.random() * 1000
		local vec = Vector(math.sin(ang) * dis, math.cos(ang) * dis, 0.0)
		util.Decal("Scorch", self.Target + Vector(0, 0, 1) + vec, self.Target - Vector(0, 0, 1) + vec)
	end
	
	-- Shake
	util.ScreenShake(self.Target, 5, 5, 5, 10000)
	
	self.Action = self.NowEndFire
	self.Time = self.Time + LaserPeak
end

-----------------------------------------
-- When the laser dissapates.
-----------------------------------------
function ENT:NowEndFire()
	self.Entity:Remove()
	self.Action = nil
end

-----------------------------------------
-- Gets the pitch of the drone sound
-- effect.
-----------------------------------------
function ENT:GetDronePitch(Time)
	if self.LaserStartTime == 0.0 then
		return 0.0
	else
		local x = Time - self.LaserStartTime
		return math.min(255.0 / (2.0 - (x / LaserPeak)), 255)
	end
end

-----------------------------------------
-- Gets the damage entities will feel per
-- second in the laser radius.
-----------------------------------------
function ENT:GetLaserDamage(Time)
	if self.LaserStartTime == 0.0 then
		return 0.0
	else
		local x = Time - self.LaserStartTime
		return Gauss(LaserPeak, 0.1, 25.0, x) + 25.0
	end
end