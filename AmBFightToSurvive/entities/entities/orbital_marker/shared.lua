ENT.Type = "anim"

ENT.PrintName		= "Orbital Marker"
ENT.Author			= "DrSchnz"
ENT.Contact			= ""
ENT.Purpose			= ""
ENT.Instructions	= ""

LaserPeak = 30.0
FluxPeak = 10.0

-----------------------------------------
-- Creates a gaussian curve.
-----------------------------------------
function Gauss(Center, Steep, Height, X)
	local x = (X - Center) * Steep
	local gauss = math.exp(-(1.0 / 2.0) * x ^ 2.0) * Height
	return gauss
end

-----------------------------------------
-- Initializes shared functionality.
-----------------------------------------
function ENT:InitializeShared()
	self.LaserStartTime = 0.0
end

-----------------------------------------
-- Gets the size of the laser by the
-- current time.
-----------------------------------------
function ENT:GetLaserSize(Time)
	if self.LaserStartTime == 0.0 then
		return 0.0
	else
		local x = Time - self.LaserStartTime
		local gauss = Gauss(LaserPeak, 0.2, 3000.0, x)
		local fluxamount = Gauss(FluxPeak, 0.3, 500.0, x)
		return gauss + fluxamount
	end
end

-----------------------------------------
-- Gets the amount of fairies at the
-- specified time.
-----------------------------------------
function ENT:GetFairyAmount(Time)
	if self.LaserStartTime == 0.0 then
		return 0.0
	else
		local x = Time - self.LaserStartTime
		return Gauss((FluxPeak + LaserPeak) / 2.0, 0.1, 150.0, x)
	end
end

-----------------------------------------
-- Gets the intensity of the fairies at
-- the specified time.
-----------------------------------------
function ENT:GetFairyIntensity(Time)
	if self.LaserStartTime == 0.0 then
		return 0.0
	else
		local x = Time - self.LaserStartTime
		return Gauss(FluxPeak, 0.3, 2.0, x) + 0.5
	end
end

-----------------------------------------
-- Gets the fairy radius at the specified
-- time
-----------------------------------------
function ENT:GetFairyRadius(Time)
	if self.LaserStartTime == 0.0 then
		return 0.0
	else
		local x = Time - self.LaserStartTime
		return 250 + Gauss(LaserPeak, 0.2, 150.0, x)
	end
end

-----------------------------------------
-- Gets the fairy rotation at the specified
-- time
-----------------------------------------
function ENT:GetFairyRotation(Time)
	if self.LaserStartTime == 0.0 then
		return 0.0
	else
		local x = Time - self.LaserStartTime
		return Gauss(FluxPeak, 0.1, 2.5, x) + 0.5
	end
end

-----------------------------------------
-- Gets the amount to color the screen
-- by between 0.0 and 1.0
-----------------------------------------
function ENT:GetScreenGamma(Time)
	if self.LaserStartTime == 0.0 then
		return 0.0
	else
		local x = Time - self.LaserStartTime
		return Gauss(LaserPeak, 0.3, 1.0, x)
	end
end