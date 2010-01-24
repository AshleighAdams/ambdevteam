
TOOL.Category		= "Construction"
TOOL.Name			= "#Hoverball"
TOOL.Command		= nil
TOOL.ConfigName		= nil


TOOL.ClientConVar[ "keyup" ] = "9"
TOOL.ClientConVar[ "keydn" ] = "6"
TOOL.ClientConVar[ "speed" ] = "1"
TOOL.ClientConVar[ "resistance" ] = "0"
TOOL.ClientConVar[ "strength" ] = "1"

cleanup.Register( "hoverballs" )

function TOOL:LeftClick( trace )

	if ( trace.Entity && trace.Entity:IsPlayer() ) then return false end
	
	// If there's no physics object then we can't constraint it!
	if ( SERVER && !util.IsValidPhysicsObject( trace.Entity, trace.PhysicsBone ) ) then return false end
	
	if (CLIENT) then return true end
	
	local ply = self:GetOwner()
	
	local key_d 		= self:GetClientNumber( "keydn" ) 
	local key_u 		= self:GetClientNumber( "keyup" ) 
	local speed 		= self:GetClientNumber( "speed" ) 
	local resistance 	= self:GetClientNumber( "resistance" ) 
	local strength	 	= self:GetClientNumber( "strength" ) 
	
	resistance 	= math.Clamp( resistance, 0, 20 )
	strength	= math.Clamp( strength, 0.1, 20 )
	
	// We shot an existing hoverball - just change its values
	if ( trace.Entity:IsValid() && trace.Entity:GetClass() == "gmod_hoverball" && trace.Entity.pl == ply ) then
	
		trace.Entity:SetSpeed( speed )
		trace.Entity:SetAirResistance( resistance )
		trace.Entity:SetStrength( strength )

		trace.Entity.speed		= speed
		trace.Entity.strength	= strength
		trace.Entity.resistance	= resistance
	
		return true
	
	end
	
	if ( !self:GetSWEP():CheckLimit( "hoverballs" ) ) then return false end
	
	// If we hit the world then offset the spawn position
	if ( trace.Entity:IsWorld() ) then
		trace.HitPos = trace.HitPos + trace.HitNormal * 8
	end

	local ball = MakeHoverBall( ply, trace.HitPos, key_d, key_u, speed, resistance, strength )
	
	local const, nocollide
	
	// Don't weld to world
	if ( trace.Entity != NULL && !trace.Entity:IsWorld() ) then
	
					  // Ent1, Ent2, Bone1, Bone2, forcelimit, nocollide, deleteonbreak
		const 		= constraint.Weld( ball, trace.Entity, 0, trace.PhysicsBone, 0, 0, true )
		
		ball:GetPhysicsObject():EnableCollisions( false )
		ball.nocollide = true
		
	end
	
	undo.Create("HoverBall")
		undo.AddEntity( ball )
		undo.AddEntity( const )
		undo.SetPlayer( ply )
	undo.Finish()
	
	ply:AddCleanup( "hoverballs", ball )
	ply:AddCleanup( "hoverballs", const )
	ply:AddCleanup( "hoverballs", nocollide )
	
	return true

end

function TOOL:RightClick( trace )

	return self:LeftClick( trace )
	
end

if (SERVER) then

	function MakeHoverBall( ply, Pos, key_d, key_u, speed, resistance, strength, Vel, aVel, frozen, nocollide )
	
		if ( !ply:CheckLimit( "hoverballs" ) ) then return nil end
	
		local ball = ents.Create( "gmod_hoverball" )
		if (!ball:IsValid()) then return false end

		ball:SetPos( Pos )
		ball:Spawn()
		ball:SetSpeed( speed )
		ball:SetPlayer( ply )
		ball:SetAirResistance( resistance )
		ball:SetStrength( strength )

		numpad.OnDown( 	 ply, 	key_u, 	"Hoverball_Up", 	ball, true )
		numpad.OnUp( 	 ply, 	key_u, 	"Hoverball_Up", 	ball, false )

		numpad.OnDown( 	 ply, 	key_d, 	"Hoverball_Down", 	ball, true )
		numpad.OnUp( 	 ply, 	key_d, 	"Hoverball_Down", 	ball, false )

		if ( nocollide == true ) then ball:GetPhysicsObject():EnableCollisions( false ) end

		local ttable = 
		{
			key_d	= key_d,
			key_u 	= key_u,
			pl	= ply,
			nocollide = nocollide,
			speed = speed,
			strength = strength,
			resistance = resistance
		}

		table.Merge( ball:GetTable(), ttable )
		
		ply:AddCount( "hoverballs", ball )
		
		DoPropSpawnedEffect( ball )

		return ball
		
	end
	
	duplicator.RegisterEntityClass( "gmod_hoverball", MakeHoverBall, "Pos", "key_d", "key_u", "speed", "resistance", "strength", "Vel", "aVel", "frozen", "nocollide" )

end
