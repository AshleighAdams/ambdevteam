if SERVER then AddCSLuaFile( "shared.lua" ) end

function SWEP:Initialize()
	self:SetWeaponHoldType("rpg")
end

function SWEP:Reload()
end

function SWEP:Think()	
end

function SWEP:PrimaryAttack()
end

function SWEP:FireMisile( pos, targent, aimspeed, pl )
	local missile = ents.Create( "rpg_missile" )
		misile:SetAngle( pl:EyeAngles() )
		if pos then
			misile:SetPos( pos )
		else
			misile:SetPos( pl:GetShootPos() + (pl:GetAimVector() * 10 )  )
		end
		misile:SetOwner(pl)
		misile:Activate()
	misile:Spawn()
	local tname = "rpgaim+" .. tostring( CurTime() )
	timer.Create( tname, 0.01, 0, function(as,m,t,tmr) -- aimspeed missile target timername
		if !m || !ValidEntity(m) then timer.Destroy( tmr ) end
		
		local mpos = m:GetPos()
		local tpos = t:GetPos()
		
		local mang = m:GetAngles()
		local tang = (mpos - tpos):Angle() -- cur - targ to angle
		
		local ang = Angle()
		
		-- we want to limit the aim speed
		ang.p = math.Clamp( tang.p, mang.p-as, mang.p+as )
		ang.y = math.Clamp( tang.y, mang.y-as, mang.y+as )
		ang.r = math.Clamp( tang.r, mang.r-as, mang.r+as )
		
		m:SetAngle( ang )
		
	end, aimspeed, misile, targent, tname)
	return misile
end

--self:TakePrimarymmo( 1 )
-- self.Weapon:SendWeaponAnim( ACT_VM_RECOIL )
--self.Owner:ViewPunch( Angle( -1, 0, 0 ) 