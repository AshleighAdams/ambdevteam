
// Variables that are used on both client and server

ENT = _R["Entity"]

SWEP.Author			= "C0BRA"
SWEP.Contact		= ""
SWEP.Purpose		= ""
SWEP.Instructions	= "Please note that constructed props cannot be moved with the physgun!"

SWEP.Spawnable			= true
SWEP.AdminSpawnable		= true

SWEP.ViewModel	= "models/weapons/v_Pistol.mdl"
SWEP.WorldModel = "models/weapons/w_Pistol.mdl"

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo			= "none"

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "none"

SWEP.Range = 750

function SWEP:Initialize()
	if( SERVER ) then
			self:SetWeaponHoldType("normal");
	end
end

/*---------------------------------------------------------
	Reload does nothing
---------------------------------------------------------*/
function SWEP:Reload()
end

/*---------------------------------------------------------
   Think
---------------------------------------------------------*/
function SWEP:Think()
	if SERVER then
		self:SetNWInt("BuildQueueSize", self.BuildQueueSize)
	else
		self.BuildQueueSize = self:GetNWInt("BuildQueueSize", 0)
	end
end

/*---------------------------------------------------------
	Gets the entity that is being aimed at.
---------------------------------------------------------*/
function SWEP:Trace()
	local owner = self.Owner
	local trace = owner:GetEyeTraceNoCursor()
	local diff = trace.HitPos - trace.StartPos
	local ent = trace.Entity
	if ent then
		if CLIENT then
			UpdateProp(ent)
		end
		if not ent.Registered then
			ent = nil
		end
	end
	if diff:Length() < self.Range then
		return {Entity = ent, Hit = true, Pos = trace.HitPos, Norm = trace.HitNormal}
	else
		return {Entity = nil, Hit = false, Pos = (diff / diff:Length()) * self.Range + trace.StartPos}
	end
end

/*---------------------------------------------------------
	PrimaryAttack
---------------------------------------------------------*/
function SWEP:PrimaryAttack()
	self.Weapon:SetNextPrimaryFire(CurTime() + 1)
	if SERVER then
		local trace = self:Trace()
		if self.CurBuildItem then
			if trace.Hit then
				self:Build(trace.Pos, trace.Norm)
			end
		else
			local ent = trace.Entity
			if ent then
				ent:Construct(self.Owner:Team())
			end
		end
	end
end


/*---------------------------------------------------------
	Positions the build entity with the specified hit pos
	and normal.
---------------------------------------------------------*/
function SWEP:PositionBuildEnt(Pos, Norm, Ent)
	if CLIENT then
		self.BuildAng = self:GetNWFloat("BuildAng", 0.0)
	end
	local heightoffset = Ent:OBBMins().z
	local dir = self.Owner:GetAimVector()
	dir.z = 0.0
	dir:Rotate(Angle(0, self.BuildAng or 0, 0))
	Ent:SetPos(Pos - heightoffset * Norm)
	Ent:SetAngles(dir:Angle())
end

/*---------------------------------------------------------
	Reload
---------------------------------------------------------*/
function SWEP:Reload()
	local rotateamount = 45
	local rotatedelay = 0.5
	if SERVER then
		if self.CurBuildItem then
			-- Rotate build
			if (self.LastRotate or 0.0) + rotatedelay < CurTime() then
				self.BuildAng = math.NormalizeAngle((self.BuildAng or 0.0) + rotateamount)
				self.LastRotate = CurTime()
				self:SetNWFloat("BuildAng", self.BuildAng)
			end
		else
			-- Build structure
			local ent = self:Trace().Entity
			if ent then
				local struct = ent:GetStructureProps()
				for k, e in pairs(struct) do
					local delay = k/10
					e:ConstructDelay(self.Owner:Team(),delay)
				end
			end
		end
	end
end

/*---------------------------------------------------------
	SecondaryAttack
---------------------------------------------------------*/
function SWEP:SecondaryAttack()
	self.Weapon:SetNextSecondaryFire(CurTime() + 1)
	if SERVER then
		if self.CurBuildItem then
			self:Cancel()
		else
			local ent = self:Trace().Entity
			if ent and ent.Registered and ent.Team and ent.Team == self.Owner:Team() then
				ent:Deconstruct()
			end
		end
	end
end

function ENT:ConstructDelay(team,time)
	timer.Simple( time,
	function(team,self)
		self:Construct(team)
	end,
	team,self)
end