ENT.Type = "anim"

ENT.PrintName		= "Combine Thumper"
ENT.Author			= "C0BRA"
ENT.Contact			= ""
ENT.Purpose			= "Keep away"
ENT.Spawnable		= true
ENT.AdminSpawnable	= true
ENT.AutomaticFrameAdvance = true
ENT.IsOn = false
ENT.Rad = 3000


function ENT:Use(Activator)
	if !Activator:IsPlayer() then return end
	self.IsOn = not self.IsOn
	if self.IsOn then
		self.Entity:SetPlaybackRate(1.0)
		local sequence = self.Entity:LookupSequence("idle")
		self.Entity:SetSequence(sequence)
		self.SeqTime = self.Entity:SequenceDuration()
		timer.Simple( self.SeqTime, BoomAndRise, self.Entity)
	else
		self.Entity:SetPlaybackRate(0.0)
	end
end

function BoomAndRise(ent)
	if ValidEntity(ent) and ent.IsOn then
		timer.Simple( ent.SeqTime, BoomAndRise, ent )
		local vPoint = ent:GetPos()
		local effectdata = EffectData()
			effectdata:SetStart( vPoint )
			effectdata:SetOrigin( vPoint )
			effectdata:SetScale( 512 )
		util.Effect( "ThumperDust", effectdata )
		
		local sequence = ent:LookupSequence("idle")
		ent:ResetSequence(sequence)		
		//ent:SetCycle(1)
		ent:SetPlaybackRate(1.0)
		
		props = ents.FindInSphere( ent:GetPos(), ent.Rad )
		for k,v in pairs( props ) do
			local dir = Vector()-(ent:GetPos() - v:GetPos()):Normalize()
			if v:IsPlayer() then
				if v:Team() ~= ent.Team and v:IsOnGround() then -- player shouldent be here, shake screen + push
					if CLIENT then
						if v == LocalPlayer() then
							ShakeScreen()
						end
					else
						v:SetVelocity(Vector(0,0,500))
						v:SetVelocity(dir*500)
					end
				end
			elseif v.Team ~= ent.Team then -- this shouldent be here, push it away
				local phys = v:GetPhysicsObject()
				if phys and ValidEntity(phys) then
					phys:SetVelocity(Vector(0,0,500))
					phys:SetVelocity(dir*500)
				end
			end
		end
	end
end

function ShakeScreen()
	if SERVER then return end
	local curang = LocalPlayer():GetAimVector():Angle()
	curang:RotateAroundAxis(Vector(0, 1, 1), (math.random() - 0.5) * 50 )
	LocalPlayer():SetEyeAngles(curang)
end

function ENT:Think()
	self:NextThink(CurTime())
	return true 
end