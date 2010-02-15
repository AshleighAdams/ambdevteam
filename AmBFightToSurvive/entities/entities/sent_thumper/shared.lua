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
ENT.Force = 500
ENT.NextUseTime = CurTime()


function ENT:Use(Activator)
	if !Activator:IsPlayer() then return end
	if self.NextUseTime > CurTime() then return end
	self.NextUseTime = CurTime()+ 5

	self.IsOn = not self.IsOn
	
	if self.IsOn then
		self.Entity:SetPlaybackRate(1.0)
		local sequence = self.Entity:LookupSequence("idle")
		self.Entity:SetSequence(sequence)
		self.SeqTime = self.Entity:SequenceDuration()
		timer.Simple( self.SeqTime, BoomAndRise, self.Entity)
		self.Entity:EmitSound("ambient/machines/thumper_startup1.wav")
	else
		//self.Entity:SetPlaybackRate(0.0)
		self.Entity:EmitSound("ambient/machines/thumper_shutdown1.wav")
	end
end

function BoomAndRise(ent)
	if ValidEntity(ent) and ent.IsOn then
		
		ent:Boom()
		
		local sequence = ent:LookupSequence("idle")
		ent:ResetSequence(sequence)
		ent:SetCycle(1)
		ent.SeqTime = ent:SequenceDuration()
		
		//ent:EmitSound("ambient/machines/thumper_amb.wav")
		timer.Simple( ent.SeqTime, BoomAndRise, ent ) -- restart
	else
		local sequence = ent:LookupSequence("idle")
		ent:ResetSequence(sequence)
		ent:SetPlaybackRate(0.0)
		ent:SetCycle(1)
		//ent:StopSound("ambient/machines/thumper_amb.wav")
		ent:Boom()
	end
end

function ShakeScreen()
	if SERVER then return end
	local curang = LocalPlayer():GetAimVector():Angle()
	curang:RotateAroundAxis(Vector(0, 1, 0), (math.random() - 0.5) * 50 )
	curang:RotateAroundAxis(Vector(1, 0, 0), (math.random() - 0.5) * 50 )
	LocalPlayer():SetEyeAngles(curang)
end

function ENT:Think()
	self:NextThink(CurTime())
	return true 
end

function ENT:Boom()
	local ent = self
	local vPoint = ent:GetPos()
	local effectdata = EffectData()
		effectdata:SetStart( vPoint )
		effectdata:SetOrigin( vPoint )
		effectdata:SetScale( 512 )
	util.Effect( "ThumperDust", effectdata )
	
	util.ScreenShake( ent:GetPos(), 20, 10, 0.5, ent.Rad )
		
	//ent:SetCycle(1)   ambient/machines/thumper_amb.wav
	//ent:SetPlaybackRate(1.0)
	
	ent:EmitSound("ambient/machines/thumper_hit.wav")
	
	props = ents.FindInSphere( ent:GetPos(), ent.Rad )
	for k,v in pairs( props ) do
		local dir = (ent:GetPos() - v:GetPos()):Normalize()*-1
		local force = ent.Force - ( ( (v:GetPos()-ent:GetPos()):Length() / ent.Rad ) * ent.Force )
		if v:IsPlayer() then
			if v:Team() ~= ent.Team and v:IsOnGround() then -- player shouldent be here, shake screen + push
				if CLIENT then
					if v == LocalPlayer() then
						ShakeScreen()
					end
				else
					v:SetVelocity(dir*force+Vector(0,0,force))
				end
			end
		elseif v.Team ~= ent.Team then -- this shouldent be here, push it away
			local phys = v:GetPhysicsObject()
			if phys and ValidEntity(phys) then
				phys:SetVelocity(dir*force+Vector(0,0,force) + phys:GetVelocity()/10)
			end
		end
	end
	
end