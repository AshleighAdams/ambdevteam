include('shared.lua')
ENT.RenderGroup 		= RENDERGROUP_BOTH
-----------------------------------------
---- Initialize
-----------------------------------------
function ENT:Initialize()
	local ent = self.Entity
	self:SetModel("models/weapons/W_missile_launch.mdl")
	//self.EM = ParticleEmitter(self:GetPos())
	
	// Make the render bounds a bigger so the effect doesn't get snipped off
	local mx, mn = self:GetRenderBounds()
	self:SetRenderBounds( mn + Vector(0,0,128), mx, 0 )
	
	timer.Simple( 0.25, function(self)
		if !ValidEntity(self) then return end
		self:SetModel("models/weapons/W_missile.mdl")
		self.Ignited = true
	end,self)
end


function ENT:Think()
	if !self.Ignited then return end
	self.SmokeTimer = self.SmokeTimer or 0
	if ( self.SmokeTimer > CurTime() ) then return end
	
	self.SmokeTimer = CurTime() //+ 0.005

	local vOffset = self:LocalToWorld( Vector(0,0,0) ) + Vector( math.Rand( -3, 3 ), math.Rand( -3, 3 ), math.Rand( -3, 3 ) )
	local vNormal = (vOffset - self:GetPos()):GetNormalized()

	local emitter = self:GetEmitter( vOffset, false )
	
		local particle = emitter:Add( "particles/smokey", vOffset )
			particle:SetVelocity( vNormal * math.Rand( 10, 30 ) )
			particle:SetDieTime( 10.0 )
			particle:SetStartAlpha( math.Rand( 50, 150 ) )
			particle:SetStartSize( math.Rand( 2, 16 ) )
			particle:SetEndSize( math.Rand( 64, 128 ) )
			particle:SetRoll( math.Rand( -0.2, 0.2 ) )
			particle:SetColor( 200, 200, 210 )


	/*local emitter = self.EM
	emitter:SetPos( self:GetPos )
	local particle = emitter:Add( "particles/smokey", Vector(0,0,0) )
			particle:SetVelocity( self:GetForward() * -10 )
			particle:SetDieTime( 2.0 )
			particle:SetStartAlpha( math.Rand( 50, 150 ) )
			particle:SetStartSize( math.Rand( 16, 32 ) )
			particle:SetEndSize( math.Rand( 64, 128 ) )
			particle:SetRoll( math.Rand( -0.2, 0.2 ) )
			particle:SetColor( 200, 200, 210 )*/
end

function ENT:GetEmitter( Pos, b3D )

	if ( self.Emitter ) then	
		if ( self.EmitterIs3D == b3D && self.EmitterTime > CurTime() ) then
			return self.Emitter
		end
	end
	
	self.Emitter = ParticleEmitter( Pos, b3D )
	self.EmitterIs3D = b3D
	self.EmitterTime = CurTime() + 2
	return self.Emitter

end
