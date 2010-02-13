include('shared.lua')

ENT.RenderGroup = RENDERGROUP_BOTH

local LaserMat = Material("tripmine_laser")
local LaserSize = 25.0
local LaserColor = Color(128, 0, 128, 255)
local LaserOffset = Vector(5, 0, 17)
local LaserStartMat = Material("sprites/gmdm_pickups/light")
local LaserStartSize = 40.0
local PulseTime = 1.0

local DistortionGrowFactor = 1.0
local DistortionDissipateFactor = 0.5
local MotionBlurLevel = 0.02

local DroneSound = "ambient/levels/citadel/zapper_ambient_loop1.wav"
local DronePitch = 140

-----------------------------------------
---- Initialize
-----------------------------------------
function ENT:Initialize()
	local ent = self.Entity
	ent:SetModel("models/props_combine/combine_emitter01.mdl")
end

local HooksExist = false
local EffectState = { }
-----------------------------------------
-- Draws screenspace effects for the
-- neural disruptor.
-----------------------------------------
local function DrawScreenSpaceEffects()
	-- Returns the value between start and stop that
	-- corresponds to amount away from start.
	local function Smooth(Start, Stop, Amount)
		local diff = Stop - Start
		return Start + diff * Amount
	end
	
	-- Effects
	if EffectState.Strength or 0.0 > 0.0 then
		-- Motion blur effect
		DrawMotionBlur(Smooth(1.0, EffectState.PulseLevel ^ 5, EffectState.Strength), 1.0, 0.0)
	end
end

-----------------------------------------
-- Think hook for the neural disruptor.
-----------------------------------------
local function Think()
	-- Get time updates
	local disruptor = EffectState.Disruptor
	local targeted = (disruptor and disruptor:IsValid() and disruptor.Target == LocalPlayer() and disruptor.On)
	local curtime = CurTime()
	local lastupdate = EffectState.LastUpdate or curtime
	local updatetime = curtime - lastupdate
	EffectState.LastUpdate = curtime
	EffectState.Targeted = targeted
	
	-- Strength of distortion effects
	local pulselevel = 0.0
	local strength = EffectState.Strength or 0.0
	if targeted then
		strength = math.min(1.0, strength + DistortionGrowFactor * updatetime)
		pulselevel = EffectState.Disruptor.PulseLevel
	else
		strength = math.max(0.0, strength - DistortionDissipateFactor * updatetime)
	end
	EffectState.Strength = strength
	EffectState.PulseLevel = pulselevel
	
	-- Droning sound
	if strength > 0.0 then
		if EffectState.Drone == nil then
			EffectState.Drone = CreateSound(LocalPlayer(), DroneSound)
			EffectState.Drone:Play()
		end
		EffectState.Drone:ChangePitch(math.Clamp(DronePitch * (EffectState.PulseLevel / 5.0 + 0.8), 0, 255))
		EffectState.Drone:ChangeVolume(strength)
	else
		if EffectState.Drone then
			EffectState.Drone:Stop()
			EffectState.Drone = nil
		end
	end
	
	-- Jitter
	if strength == 1 then
		if EffectState.PulseLevel < 0.5 then
			local curang = LocalPlayer():GetAimVector():Angle()
			curang:RotateAroundAxis(Vector(0, 0, 1), (math.random() - 0.5) * 1000.0 * updatetime)
			LocalPlayer():SetEyeAngles(curang)
		end
	end
	
	-- Remove hooks
	if strength == 0 and not targeted then
		HooksExist = false
		hook.Remove("RenderScreenspaceEffects", "NeuralDisruptorScreenSpaceEffects")
		hook.Remove("Think", "NeuralDisruptorThink")
		return
	end
end

local function SetEffectDisruptor(Ent)
	EffectState.Disruptor = Ent
	if Ent then
		if not HooksExist then
			hook.Add("Think", "NeuralDisruptorThink", Think)	
			hook.Add("RenderScreenspaceEffects", "NeuralDisruptorScreenSpaceEffects", DrawScreenSpaceEffects)
			HooksExist = true
		end
	end
end

-----------------------------------------
---- Think
-----------------------------------------
function ENT:Think()
	self.On = self:GetNWBool("On", false)
	self.Target = self:GetNWEntity("Target", nil)
	self.TargetStart = self:GetNWFloat("TargetStart", 0.0)
	
	if self.On then
		self.PulseLevel = math.fmod((CurTime() - self.TargetStart) / PulseTime, 1.0) ^ 2
	end
	
	if self.Target == LocalPlayer() then
		SetEffectDisruptor(self)
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
	local laserstartsize = LaserStartSize
	local laserstartpos = self:LocalToWorld(LaserOffset)
	if self.On then
		laserstartsize = laserstartsize * 2 * self.PulseLevel
		if self.Target ~= LocalPlayer() then
			render.SetMaterial(LaserMat)
			render.DrawBeam(laserstartpos, self.Target:GetShootPos(), LaserSize, 0, 0, LaserColor)
		else
			laserstartsize = laserstartsize * 10
		end
	end
	render.SetMaterial(LaserStartMat)
	render.DrawSprite(laserstartpos, laserstartsize, laserstartsize, LaserColor)
end