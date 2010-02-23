
// Variables that are used on both client and server

ENT = _R["Entity"]

SWEP.Author			= "C0BRA"
SWEP.Contact		= ""
SWEP.Purpose		= "Mortar Strike - Combine Style"
SWEP.Instructions	= "Kill"

SWEP.Spawnable			= true
SWEP.AdminSpawnable		= true

SWEP.ViewModel	= "models/weapons/v_Pistol.mdl"
SWEP.WorldModel = "models/weapons/w_Pistol.mdl"

SWEP.Primary.ClipSize		= 1
SWEP.Primary.DefaultClip	= 1
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo			= "rpg"

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "none"

function SWEP:Initialize()
	self.Power = 0
	if SERVER  then
		self:SetWeaponHoldType("normal")
		
		local function UpdatePower(pl,cmd,args)
			self.Power = args[1]
		end
		concommand.Add("swep_sup_updatepower",UpdatePower)
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
	if CLIENT and self.CntlPower then
		if LocalPlayer():KeyDown(IN_ATTACK2) then
			local ychanged = gui.MouseY() - (ScrH()/2)
			self.Power = self.Power - ychanged
			gui.SetMousePos(ScrW(),ScrH()/2)
		else
			self.CntlPower = false
			gui.EnableScreenClicker(false)
			RunConsoleCommand("swep_sup_updatepower",self.Power)
		end
	end
end


/*---------------------------------------------------------
	PrimaryAttack
---------------------------------------------------------*/
function SWEP:PrimaryAttack()
	self.Weapon:SetNextPrimaryFire(CurTime() + 5)
	
	if SERVER then
		local pos = self.Owner:GetShootPos()
		local ang = self.Owner:GetAimVector()
		local tracedata = {}
		tracedata.start = pos
		tracedata.endpos = pos+Vector(0,0,5000)
		tracedata.filter = self.Owner
		local trace = util.TraceLine(tracedata)
		if trace.Hit then
			self:CreateBoom( trace.HitPos, trace.HitNormal:Angle() )
			return false
		end
		ang.z = 0
		local power = self.Power
		
		pos = (pos+Vector(0,0,5000))+(ang*power)
		tracedata = {}
		tracedata.start = pos
		tracedata.endpos = pos - Vector(0,0,500000)
		tracedata.filter = self.Owner
		trace = util.TraceLine(tracedata)
		if trace.Hit then
			self:CreateBoom( trace.HitPos, trace.HitNormal:Angle() )
		end
	end
end

function SWEP:CreateBoom(pos,ang)

	timer.Simple( 0.01, function(pos) -- wtf, wtf!?!?!?!?!?!? is worng with this fucking shit
	
		local effectdata = EffectData()
		effectdata:SetStart( pos )
		effectdata:SetOrigin( pos )
		effectdata:SetMagnitude( 160 )
		effectdata:SetScale( 20 )
		effectdata:SetRadius( 60 )
		effectdata:SetAngle( ang )
		util.Effect( "AR2Explosion", effectdata )	//cball_bounce
		
	end,pos)
	
	
	
	local damage = 200
	local radius = 500
	local attacker = self.Owner
	local inflictor = self.Weapon
	util.BlastDamage(inflictor, attacker, pos, radius, damage)
	
end

/*---------------------------------------------------------
	Reload
---------------------------------------------------------*/
function SWEP:Reload()
	if SERVER then
		
	end
end

/*---------------------------------------------------------
	SecondaryAttack
---------------------------------------------------------*/
function SWEP:SecondaryAttack()
	self.Weapon:SetNextSecondaryFire(CurTime())
	if CLIENT then
		self.CntlPower = true //not self.CntlPower
		if self.CntlPower then
			gui.EnableScreenClicker(true)
			gui.SetMousePos(ScrW(),ScrH()/2)
		//else
			//gui.EnableScreenClicker(false)
		end
	end
end