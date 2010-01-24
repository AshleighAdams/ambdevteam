
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')

/*---------------------------------------------------------
   Name: Initialize
   Desc: First function called. Use to set up your entity
---------------------------------------------------------*/
function ENT:Initialize()

	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	self:SetUseType( SIMPLE_USE )
	
	self:SetToggle( false )
	
	self.ToggleState = false
	self.BaseTorque = 1
	self.TorqueScale = 1
	
end

/*---------------------------------------------------------
   Sets the base torque
---------------------------------------------------------*/
function ENT:SetBaseTorque( base )

	self.BaseTorque = base
	if ( self.BaseTorque == 0 ) then self.BaseTorque = 1 end
	self:UpdateOverlayText()

end

/*---------------------------------------------------------
   Sets the base torque
---------------------------------------------------------*/
function ENT:UpdateOverlayText()
	
	self:SetOverlayText( "Torque: " .. math.floor( self.BaseTorque ) )

end

/*---------------------------------------------------------
   Sets the axis (world space)
---------------------------------------------------------*/
function ENT:SetAxis( vec )

	self.Axis = self:GetPos() + vec * 512
	self.Axis = self:NearestPoint( self.Axis )
	self.Axis = self:WorldToLocal( self.Axis )

end


/*---------------------------------------------------------
   Name: PhysicsCollide
   Desc: Called when physics collides. The table contains 
			data on the collision
---------------------------------------------------------*/
function ENT:PhysicsCollide( data, physobj )
end


/*---------------------------------------------------------
   Name: PhysicsUpdate
   Desc: Called to update the physics .. or something.
---------------------------------------------------------*/
function ENT:PhysicsUpdate( physobj )
end


/*---------------------------------------------------------
   Name: KeyValue
   Desc: Called when a keyvalue is added to us (usually from the map)
---------------------------------------------------------*/
function ENT:KeyValue( key, value )
end


/*---------------------------------------------------------
   Name: Think
   Desc: Entity's think function. 
---------------------------------------------------------*/
function ENT:Think()
end


/*---------------------------------------------------------
   Name: OnTakeDamage
   Desc: Entity takes damage
---------------------------------------------------------*/
function ENT:OnTakeDamage( dmginfo )

	self:TakePhysicsDamage( dmginfo )

end


function ENT:SetMotor( Motor )
	self.Motor = Motor
end

function ENT:GetMotor()

	if (!self.Motor) then
		self.Motor = constraint.FindConstraintEntity( self.Entity, "Motor" )
	end

	return self.Motor
end


function ENT:SetDirection( dir )
	self:SetNetworkedInt( 1, dir )
	self.Direction = dir
end

function ENT:SetToggle( bool )
	self.Toggle = bool
end

function ENT:GetToggle()
	return self.Toggle
end

/*---------------------------------------------------------
   Forward key is pressed/released
---------------------------------------------------------*/
function ENT:Forward( onoff, mul )

	// Is this key invalid now? If so return false to remove it
	if ( !self:IsValid() ) then return false end
	local Motor = self:GetMotor()
	if ( !Motor:IsValid() ) then
		Msg("Wheel doesn't have a motor!\n"); 
		return false
	end
	
	local toggle = self:GetToggle()	
	
	// Don't remove the key bind.. (return true)
	if (toggle && !onoff) then return true end
	
	mul = mul or 1
	local Speed = Motor.direction * mul * self.TorqueScale

	if (!onoff) then Speed = 0 end
	
	if (toggle && onoff) then
	
		self.ToggleState = !self.ToggleState
		
		if (!self.ToggleState) then
			Speed = 0
		end
	
	end
	

	Motor:Fire( "Scale", Speed, 0 )
	Motor.forcescale = Speed
	Motor:Fire( "Activate", "" , 0 )
	
	return true
	
end

/*---------------------------------------------------------
   Reverse key is pressed/released
---------------------------------------------------------*/
function ENT:Reverse( onoff )
	return self:Forward( onoff, -1 )
end




/*---------------------------------------------------------
   Numpad control functions
   These are layed out like this so it'll all get saved properly
---------------------------------------------------------*/
local function Fwd( pl, ent, onoff )
	if (!ent:IsValid()) then return false end
	return ent:Forward( onoff )
end

local function Rev( pl, ent, onoff )
	if (!ent:IsValid()) then return false end
	return ent:Reverse( onoff )
end

// register numpad functions
numpad.Register( "WheelForward", Fwd )
numpad.Register( "WheelReverse", Rev )


/*---------------------------------------------------------
   Todo? Scale Motor.direction?
---------------------------------------------------------*/
function ENT:SetTorque( torque )

	if ( self.BaseTorque == 0 ) then self.BaseTorque = 1 end
	
	self.TorqueScale = torque / self.BaseTorque
	
	local Motor = self:GetMotor()
	if (!Motor || !Motor:IsValid()) then return end
	Motor:Fire( "Scale", Motor.direction * Motor.forcescale * self.TorqueScale , 0 )
	
	self:SetOverlayText( "Torque: " .. math.floor( torque ) )

end

/*---------------------------------------------------------
   Creates the direction arrows on the wheel
---------------------------------------------------------*/
function ENT:DoDirectionEffect()

	local Motor = self:GetMotor()
	if (!Motor || !Motor:IsValid()) then return end

	local effectdata = EffectData()
		effectdata:SetOrigin( self.Axis )
		effectdata:SetEntity( self.Entity )
		effectdata:SetScale( Motor.direction )
	util.Effect( "wheel_indicator", effectdata, true, true )	
	
end

/*---------------------------------------------------------
   Reverse the wheel direction when a player uses the wheel
---------------------------------------------------------*/
function ENT:Use( activator, caller, type, value )
		
	local Motor = self:GetMotor()
	local Owner = self:GetPlayer()
	
	if (Motor and (Owner == nil or Owner == activator)) then

		if (Motor.direction == 1) then
			Motor.direction = -1
		else
			Motor.direction = 1
		end

		Motor:Fire( "Scale", Motor.direction * Motor.forcescale * self.TorqueScale, 0 )
		self:SetDirection( Motor.direction )
	
		self:DoDirectionEffect()
		
	end
	
end

