
TOOL.Category		= "Construction"
TOOL.Name			= "#Dynamite"
TOOL.Command		= nil
TOOL.ConfigName		= nil

TOOL.ClientConVar[ "group" ] = 1		// Current group
TOOL.ClientConVar[ "damage" ] = 200		// Damage to inflict
TOOL.ClientConVar[ "delay" ] = 0		// Delay before explosions start
TOOL.ClientConVar[ "delay_add" ] = 0.1	// Delay beween each dynamite

TOOL.Model = "models/dav0r/tnt/tnt.mdl"

cleanup.Register( "dynamite" )

function TOOL:LeftClick( trace )

	if (!trace.HitPos) then return false end
	if (trace.Entity:IsPlayer()) then return false end
	if ( CLIENT ) then return true end
	
	local ply = self:GetOwner()
	

	// Get client's CVars
	local _group		= self:GetClientNumber( "group" ) 
	local _damage 		= math.Clamp( self:GetClientNumber( "damage" ), 0, 1500 )

	// If we shot a button change its keygroup
	if	trace.Entity:IsValid() && 
		trace.Entity:GetClass() == "gmod_dynamite" && 
		trace.Entity:GetPlayer() == ply
	then
		trace.Entity:Setup( _damage )
		return true
		
	end
	

	if ( !self:GetSWEP():CheckLimit( "dynamite" ) ) then return false end

	local dynamite = MakeDynamite( ply, trace.HitPos, Angle( 90, 0, 0 ), _group, _damage )
	
	local min = dynamite:OBBMins()
	dynamite:SetPos( trace.HitPos - trace.HitNormal * min.z )

	undo.Create("Dynamite")
		undo.AddEntity( dynamite )
		undo.SetPlayer( ply )
	undo.Finish()
	
	
	ply:AddCleanup( "dynamite", dynamite )
	
	return true
	
end

function TOOL:RightClick( trace )

	return self:LeftClick( trace )
	
end

if SERVER then

	local Dynamites = {}
	
	local function Save( save )
	
		saverestore.WriteTable( Dynamites, save )
		
	end
	
	local function Restore( restore )
	
		Dynamites = saverestore.ReadTable( restore )
		
	end
	
	saverestore.AddSaveHook( "Dynamites", Save )
	saverestore.AddRestoreHook( "Dynamites", Restore )
	

	function MakeDynamite(pl, Pos, Ang, key, Damage, Vel, aVel, frozen )
	
		if ( !pl:CheckLimit( "dynamite" ) ) then return nil end

		local dynamite = ents.Create( "gmod_dynamite" )
			dynamite:SetPos( Pos )	
			dynamite:SetAngles( Ang )
		dynamite:Spawn()
		dynamite:Activate()
		
		dynamite:Setup( Damage )
		dynamite:SetPlayer( pl )
		
		local index = pl:UniqueID()
		Dynamites[ index ] 			= Dynamites[ index ] or {}
		Dynamites[ index ][ key ] 	= Dynamites[ index ][ key ] or {}
		table.insert( Dynamites[ index ][ key ], dynamite )
		
		local ttable = 
		{
			key	= key,
			pl	= pl,
			nocollide = nocollide,
			description = description,
			Damage = Damage
		}
		
		table.Merge( dynamite:GetTable(), ttable )
		
		pl.DynamiteKeys = pl.DynamiteKeys or {}
		
		// We only want to add this once per player..
		if ( !pl.DynamiteKeys[ key ] ) then
			pl.DynamiteKeys[ key ] = numpad.OnDown( pl, key, "DynamiteBlow", key )
		end
		
		pl:AddCount( "dynamite", dynamite )
		
		DoPropSpawnedEffect( dynamite )
		
		return dynamite
		
	end
	
	duplicator.RegisterEntityClass( "gmod_dynamite", MakeDynamite, "Pos", "Ang", "key", "Damage", "Vel", "aVel", "frozen" )
	
	local function BlowDynamite( pl, key, idx )

		if ( !Dynamites[ idx ] ) then return end
		if ( !Dynamites[ idx ][ key ] ) then return end
		
		local delay = 0
		local delay_add = 0.1
		
		if ( pl && pl:IsValid() ) then 
			delay 		= pl:GetInfo( "dynamite_delay" ) 
			delay_add 	= pl:GetInfo( "dynamite_delay_add" ) 
		end
		
		for k, v in pairs( Dynamites[ idx ][ key ] ) do
				
			if ( !v || v == NULL ) then
			
				Dynamites[ idx ][ key ][ k ] = nil
			
			else
			
				v:Explode( delay, pl )
				delay = delay + delay_add
			
			end
		
		end
	
	end
	
	numpad.Register( "DynamiteBlow", BlowDynamite )
	
end

function TOOL:UpdateGhostDynamite( ent, player )

	if ( !ent || !ent:IsValid() ) then return end

	local tr 	= utilx.GetPlayerTrace( player, player:GetCursorAimVector() )
	local trace 	= util.TraceLine( tr )
	
	if (!trace.Hit || trace.Entity:IsPlayer() || trace.Entity:GetClass() == "gmod_dynamite" ) then
		ent:SetNoDraw( true )
		return
	end
	
	local Ang = Angle( 90, 0, 0 )
	ent:SetAngles( Ang )	

	local min = ent:OBBMins()
	ent:SetPos( trace.HitPos - trace.HitNormal * min.z )
	
	ent:SetNoDraw( false )

end

function TOOL:Think()

	if (!self.GhostEntity || !self.GhostEntity:IsValid() || self.GhostEntity:GetModel() != self.Model ) then
		self:MakeGhostEntity( self.Model, Vector(0,0,0), Angle(0,0,0) )
	end
	
	self:UpdateGhostDynamite( self.GhostEntity, self:GetOwner() )
	
end
