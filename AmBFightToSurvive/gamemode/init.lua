
GAMEMODE = GAMEMODE or { }
TeamPassword = TeamPassword or { }
TeamOwner = TeamOwner or { }

// These files get sent to the client
AddCSLuaFile( "shared.lua" )
AddCSLuaFile( "cl_gui.lua" )


AddCSLuaFile( "cl_init.lua" )

include( 'shared.lua' )
include( 'player.lua' )



function GM:Initialize()
	GAMEMODE.NumTeams = 1
	team.SetUp( 1, "Lone Wolves", Color(100,100,100,255) )
end

function GM:PlayerInitialSpawn( pl )
	pl:SetTeam(1)
end

function JoinTeam( pl, cmd, args )
	id = tonumber( args[1] )
	if id > GAMEMODE.NumTeams then return end
	password = tostring( args[2] or "" )
	teampassword = TeamPassword[ id ]
	if password == teampassword then
		pl:SetTeam( id )
	end
end
concommand.Add( "jointeam", JoinTeam )

function MakeTeam( pl, cmd, args )
	if table.Count( args ) == 5 then
		name = args[1]
		pass = args[2]
		r = args[3]
		g = args[4]
		b = args[5]
		pl:SetTeam( SetUpTeam( name, pass, r,g,b, pl ) )
	end

end
concommand.Add( "maketeam", MakeTeam )

function SetUpTeam( name, password, r,g,b, owner )
	GAMEMODE.NumTeams = GAMEMODE.NumTeams + 1
	TeamPassword[GAMEMODE.NumTeams] = password
	
	team.SetUp( GAMEMODE.NumTeams, name, Color(r,g,b,255) )
	TeamOwner[GAMEMODE.NumTeams] = owner
	return GAMEMODE.NumTeams
end

function IsLeader( pl )
	t = pl:Team()
	if pl != nil && TeamOwner[t] != nil && pl:IsValid() && pl:IsPlayer() then
		return TeamOwner[t] == pl
	end
	return false
end

/*---------------------------------------------------------
   Name: gamemode:PlayerSpawn( )
   Desc: Called when a player spawns
---------------------------------------------------------*/
function GM:PlayerSpawn( pl )


    self.BaseClass:PlayerSpawn( pl )
    ply:SetGravity( 0.75 )  
    ply:SetMaxHealth( 100, true )  
 
    ply:SetWalkSpeed( 250 )  
	ply:SetRunSpeed( 400 ) 
 

	//self.BaseClass.PlayerSpawn( self, pl )
	
	// Set the player's speed
	//GAMEMODE:SetPlayerSpeed( pl, 250, 400 )

end


function GM:PlayerLoadout( pl )

	// Remove any old ammo
	pl:RemoveAllAmmo()

	if ( server_settings.Bool( "sbox_weapons", true ) ) then
	
	/*

		
		
		pl:Give( "weapon_crowbar" )
		pl:Give( "weapon_pistol" )
		pl:Give( "weapon_smg1" )
		pl:Give( "weapon_frag" )
		pl:Give( "weapon_physcannon" )
		pl:Give( "weapon_crossbow" )
		pl:Give( "weapon_shotgun" )
		pl:Give( "weapon_357" )
		//pl:Give( "weapon_rpg" )
		pl:Give( "weapon_ar2" )
		// The only reason I'm leaving this out is because
		// I don't want to add too many weapons to the first
		// row because that's where the gravgun is.
		*/
		

		
		pl:GiveAmmo( 256,	"Pistol", 		true )
		pl:GiveAmmo( 256,	"SMG1", 		true )
		pl:GiveAmmo( 2,		"grenade", 		true )
		pl:GiveAmmo( 64,	"Buckshot", 	true )
		pl:GiveAmmo( 16,	"357", 			true )
		pl:GiveAmmo( 32,	"XBowBolt", 	true )
		pl:GiveAmmo( 2,		"AR2AltFire", 	true )
		pl:GiveAmmo( 100,	"AR2", 			true )
		
		local w1, w2, w3 = pl.w1, pl.w2, pl.w3
		if w1 == nil || w2==nil || w3==nil then
			pl:Give( "weapon_ar2" )
			pl:Give( "weapon_grenade" )
			pl:Give( "weapon_shotgun" )
		else
			pl:Give( w1 )
			pl:Give( w2 )
			pl:Give( w3 )
		end
		pl:Give( "weapon_stunstick" )
	end
	
	pl:Give( "gmod_tool" )
	pl:Give( "gmod_camera" )
	pl:Give( "weapon_physgun" )
	pl:Give( "tactical_insertion" )	

	local cl_defaultweapon = pl:GetInfo( "cl_defaultweapon" )

	if ( pl:HasWeapon( cl_defaultweapon )  ) then
		pl:SelectWeapon( cl_defaultweapon ) 
	end

end


function GM:PlayerShouldTakeDamage( ply, attacker )

	// The player should always take damage in single player..
	if ( SinglePlayer() ) then return true end

	// Global godmode, players can't be damaged in any way
	if ( server_settings.Bool( "sbox_godmode", false ) ) then return false end

	// No player vs player damage
	if ( attacker:IsValid() && attacker:IsPlayer() ) then
		if !server_settings.Bool( "sbox_plpldamage", false ) then
			if ply:Team() == 1 && attacker:Team() == 1 then return true end
			return ply:Team() != attacker:Team()
		end
	end
	
	// Default, let the player be hurt
	return true

end


/*---------------------------------------------------------
   Show the school window when F1 is pressed..
---------------------------------------------------------*/
function GM:ShowHelp( ply )

	ply:ConCommand( "setspawnclass" )
	
end


/*---------------------------------------------------------
   Called once on the player's first spawn
---------------------------------------------------------*/
function GM:PlayerInitialSpawn( ply )

	self.BaseClass:PlayerInitialSpawn( ply )
	
	PlayerDataUpdate( ply )
	
end



function GM:GetFallDamage( ply, vel )
	if GetConVarNumber("mp_falldamage") == 0 then
		if math.Rand(1,20) == 1 and vel > 999 then
			return ply:Health() - 1
		end
		return (vel-200) / 8
	end
end


function SetWeapons( pl, cmd, args )
	
	weapon = table.concat(args," ")
	weps = string.Explode(",",weapon)
	pl.w1 = weps[1]
	pl.w2 = weps[2]
	pl.w3 = weps[3]
end
concommand.Add("sv_cl_setw", SetWeapons)