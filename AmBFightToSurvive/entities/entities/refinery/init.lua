AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')
Refineries = Refineries or { }

local CaptureRadius = 500
local CaptureNeed = 20.0
local CaptureDissapate = 0.3

-----------------------------------------
---- Initialize
-----------------------------------------
function ENT:Initialize()
	local ent = self.Entity
	ent:SetModel("models/props_c17/FurnitureBoiler001a.mdl")
	table.insert(Refineries, ent)
	
	self.Team = 0
	self.CapStatus = { } -- Teams capture status in seconds
end

-----------------------------------------
---- OnRemove
-----------------------------------------
function ENT:OnRemove()
	for i = 1, #Refineries do
		if Refineries[i] == self.Entity then
			table.remove(Refineries, i)
		end
	end
end

-----------------------------------------
---- Think
-----------------------------------------
function ENT:Think()
	local ent = self.Entity
	local curtime = CurTime()
	local lastupdate = self.LastUpdate or curtime
	local updatetime = curtime - lastupdate
	self.LastUpdate = curtime

	-- Look for nearby entites
	local capblock = false
	local capforce = { }
	local near = ents.FindInSphere(ent:GetPos(), CaptureRadius)
	for i, e in pairs(near) do
		
		-- Players can capture
		if e:IsPlayer() then
			local team = e:Team()
			if team == self.Team then
				capblock = true
			end
			if team > 1 then
				table.insert(capforce, e)
			end
		end
	end
	
	-- Add capture force
	if not capblock then
		for i, p in pairs(capforce) do
			if self:Visible( p ) && p:Alive() then
				local team = p:Team()
				self.CapStatus[team] = (self.CapStatus[team] or 0.0) + updatetime + CaptureDissapate
			end
		end
	end
	
	-- If any capture status exceeds an amount,
	-- its captured. Dissapate capture.
	capstatus = 0.0
	for t, s in pairs(self.CapStatus) do
		if s > capstatus then
			capstatus = s
		end
		if s > CaptureNeed then
			self:ChangeOwner(t)
			break
		else
			self.CapStatus[t] = s - CaptureDissapate * updatetime
		end
	end
	
	-- Sounds for capping
	if capstatus > 0.0 then
		if not self.WarningSound then
			self.WarningSound = CreateSound(ent, "ambient/alarms/siren.wav")
			self.WarningSound:Play()
		end
		self.WarningSound:ChangePitch(math.Clamp((capstatus / CaptureNeed) * 255, 0, 255))
	else
		if self.WarningSound then
			self.WarningSound:Stop()
			self.WarningSound = nil
		end
	end

	
	-- Send messages to client
	self:SetNWInt("Owner", self.Team)
end

-----------------------------------------
-- Changes ownership of the refinery.
-----------------------------------------
function ENT:ChangeOwner(Team)
	self.Entity:EmitSound("ambient/alarms/warningbell1.wav", 500, 100)
	self.Team = Team
	self.CapStatus = { }
end