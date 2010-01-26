
GAMEMODE = GAMEMODE or { }

Teams = Teams or {}

// These files get sent to the client
AddCSLuaFile( "shared.lua" )
AddCSLuaFile( "cl_gui.lua" )
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "cl_scoreboard.lua" )
resource.AddFile( "amb/scoreboard.vmt" )

include( 'shared.lua' )
include( 'player.lua' )

function SendTeamInfo(pl)
	for i=1, #Teams do
		umsg.Start("teamstats", pl)
			umsg.Long( i )
			umsg.String( Teams[i].Name )
			umsg.Vector( Teams[i].Color )
			umsg.Entity( Teams[i].Owner )
		umsg.End()
	end
end

function SendAllTeamInfo()
	for i=1, #Teams do
		local rp = RecipientFilter()
		rp:AddAllPlayers()
		umsg.Start("teamstats", rp)
			umsg.Long( i )
			umsg.String( Teams[i].Name )
			umsg.Vector( Teams[i].Color )
			umsg.Entity( Teams[i].Owner )
		umsg.End()
	end
end

function GM:Initialize()
	GAMEMODE.NumTeams = 1
	Index = GAMEMODE.NumTeams
	Teams[Index] = {}
	Teams[Index].Name = "Lone Wolves"
	Teams[Index].Color = Vector(100,100,100)
	Teams[Index].Owner = nil
	Teams[Index].Password = ""
	Col = Color(Teams[Index].Color.x,Teams[Index].Color.y,Teams[Index].Color.z,255)
	team.SetUp( Index, Teams[Index].Name, Col )
end

function GM:PlayerAuthed( pl, SteamID, UniqueID )
	SendTeamInfo(pl)
	pl:SetTeam(1)
end

function JoinTeam( pl, cmd, args )
	id = tonumber( args[1] )
	if id > GAMEMODE.NumTeams then return end
	password = tostring( args[2] or "" )
	teampassword = Teams[id].Password
	if password == teampassword then
		pl:SetTeam( id )
	end
end
concommand.Add( "jointeam", JoinTeam )

function MakeTeam( pl, cmd, args )
	if table.Count( args ) == 5 then
		name = args[1] or "Failures"
		pass = args[2] or ""
		r = args[3] or 100
		g = args[4] or 100
		b = args[5] or 100
		pl:SetTeam( SetUpTeam( name, pass, r,g,b, pl ) )
		SendAllTeamInfo()
	end

end
concommand.Add( "maketeam", MakeTeam )

function SetUpTeam( name, password, r,g,b, owner )
	GAMEMODE.NumTeams = GAMEMODE.NumTeams + 1
	local Index = GAMEMODE.NumTeams
	--TeamPassword[GAMEMODE.NumTeams] = password
	
	--team.SetUp( GAMEMODE.NumTeams, name, Color(r,g,b,255) )
	
	Teams[Index] = {}
	Teams[Index].Name = name
	Teams[Index].Color = Vector(r,g,b)
	Teams[Index].Owner = owner
	Teams[Index].Password = password
	
	Col = Color(Teams[Index].Color.x,Teams[Index].Color.y,Teams[Index].Color.z,255)
	team.SetUp( Index, Teams[Index].Name, Col )
	
	return GAMEMODE.NumTeams
end

function IsLeader( pl )
	t = pl:Team()
	if pl != nil && Teams[t].Owner != nil && pl:IsValid() && pl:IsPlayer() then
		return Teams[t].Owner == pl
	end
	return false
end

/*---------------------------------------------------------
   Name: gamemode:PlayerSpawn( )
   Desc: Called when a player spawns
---------------------------------------------------------*/
function GM:PlayerSpawn( pl )

	if( pl:Team() ==1001 ) then
		pl:SetTeam(1)
	end
    self.BaseClass:PlayerSpawn( pl )
    pl:SetGravity( 1 )  
    pl:SetMaxHealth( 100, true )  
 
    pl:SetWalkSpeed( 250 )  
	pl:SetRunSpeed( 400 ) 
 

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
	pl:Give( "weapon_flaregun" )	

	local cl_defaultweapon = pl:GetInfo( "cl_defaultweapon" )

	if ( pl:HasWeapon( cl_defaultweapon )  ) then
		pl:SelectWeapon( cl_defaultweapon ) 
	end

end


function GM:PlayerShouldTakeDamage( victim, pl )
	if !pl:IsValid() || pl == nil then return true end
	if( pl:Team() != 1 && pl:Team() == victim:Team() && GetConVarNumber( "mp_friendlyfire" ) == 0 ) then
		return false -- do not damage the player
	end
 
	return true -- damage the player
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