
TOOL.Category		= "Construction"
TOOL.Name			= "#Balloons"
TOOL.Command		= nil
TOOL.ConfigName		= nil


TOOL.ClientConVar[ "ropelength" ]	= "64"
TOOL.ClientConVar[ "force" ]		= "500"

TOOL.ClientConVar[ "r" ]		= "255"
TOOL.ClientConVar[ "g" ]		= "255"
TOOL.ClientConVar[ "b" ]		= "0"

TOOL.ClientConVar[ "skin" ]		= "models/balloon/balloon"

cleanup.Register( "balloons" )

function TOOL:LeftClick( trace, attach )

	if trace.Entity && trace.Entity:IsPlayer() then return false end
	if (CLIENT) then return true end
	if (attach == nil) then attach = true end
	
	// If there's no physics object then we can't constraint it!
	if ( SERVER && attach && !util.IsValidPhysicsObject( trace.Entity, trace.PhysicsBone ) ) then return false end
	
	local ply = self:GetOwner()
	local length 			= self:GetClientNumber( "ropelength", 64 )
	local material 			= "cable/rope"
	local force 			= self:GetClientNumber( "force", 500 )
	local r 				= self:GetClientNumber( "r", 255 )
	local g 				= self:GetClientNumber( "g", 0 )
	local b 				= self:GetClientNumber( "b", 0 )
	local skin 				= self:GetClientInfo( "skin" )
	
	if (skin != "models/balloon/balloon" &&
		skin != "models/balloon/balloon_hl2") then
		
		r = 255
		g = 255
		b = 255
		
	end

	if	trace.Entity:IsValid() && 
		trace.Entity:GetClass() == "gmod_balloon" &&
		trace.Entity.Player == ply
	then
		local force 	= self:GetClientNumber( "force", 500 )
		trace.Entity:SetForce( force )
		trace.Entity:GetPhysicsObject():Wake()
		trace.Entity:SetColor( r, g, b, 255 )
		trace.Entity:SetForce( force )
		trace.Entity:SetMaterial( skin )
		return true
	end

	if ( !self:GetSWEP():CheckLimit( "balloons" ) ) then return false end

	local Pos = trace.HitPos + trace.HitNormal * 10
	local balloon = MakeBalloon( ply, r, g, b, force, skin, { Pos = Pos } )

	undo.Create("Balloon")
	undo.AddEntity( balloon )

	if (attach) then
	
		// The real model should have an attachment!
		local attachpoint = Pos + Vector( 0, 0, -10 )
			
		local LPos1 = balloon:WorldToLocal( attachpoint )
		local LPos2 = trace.Entity:WorldToLocal( trace.HitPos )
		
		if (trace.Entity:IsValid()) then
			
			local phys = trace.Entity:GetPhysicsObjectNum( trace.PhysicsBone )
			if (phys:IsValid()) then
				LPos2 = phys:WorldToLocal( trace.HitPos )
			end
		
		end
		
		local constraint, rope = constraint.Rope( balloon, trace.Entity, 
												0, trace.PhysicsBone, 
												LPos1, LPos2, 
												0,length,
												0, 
												1.5, 
												material, 
												nil )

		undo.AddEntity( rope )
		undo.AddEntity( constraint )
		ply:AddCleanup( "balloons", rope )
		ply:AddCleanup( "balloons", constraint )
	end
	
	undo.SetPlayer( ply )
	undo.Finish()
	
	
	ply:AddCleanup( "balloons", balloon )

	return true

end

function TOOL:RightClick( trace )

	return self:LeftClick( trace, false )

end

function MakeBalloon( pl, r, g, b, force, skin, Data )

	if ( !pl:CheckLimit( "balloons" ) ) then return nil end

	local balloon = ents.Create( "gmod_balloon" )
	
		if (!balloon:IsValid()) then return end
		duplicator.DoGeneric( balloon, Data )
		
	balloon:Spawn()

	duplicator.DoGenericPhysics( balloon, pl, Data )

	balloon:SetRenderMode( RENDERMODE_TRANSALPHA )
	balloon:SetColor( r, g, b, 255 )
	balloon:SetForce( force )
	balloon:SetPlayer( pl )

	balloon:SetMaterial( skin )
	
	balloon.Player = pl
	balloon.r = r
	balloon.g = g
	balloon.b = b
	balloon.skin = skin
	balloon.force = force
	
	pl:AddCount( "balloons", balloon )
	
	return balloon

end

duplicator.RegisterEntityClass( "gmod_balloon", MakeBalloon, "r", "g", "b", "force", "skin", "Data" )
