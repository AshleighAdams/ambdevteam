
GAMEMODE = GAMEMODE or { }



Teams = Teams or {}

// These files get sent to the client
AddCSLuaFile( "shared.lua" )
AddCSLuaFile( "shared_store.lua" )
AddCSLuaFile( "shared_store_items.lua" )
AddCSLuaFile( "shared_disable.lua" )
AddCSLuaFile( "cl_gui.lua" )
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "cl_scoreboard.lua" )
AddCSLuaFile( "cl_damageoverlay.lua" )
AddCSLuaFile( "api/cl_api.lua" )
AddCSLuaFile( "cl_recource_systems.lua" )
AddCSLuaFile( "cl_store.lua" )
AddCSLuaFile( "cl_map.lua" )

resource.AddFile( "materials/amb/scoreboard.vmt" )
resource.AddFile( "materials/amb/damageoverlay.vmt" )
resource.AddFile( "materials/amb/mapamb.vmt" )
resource.AddFile( "materials/amb/freespace06.vmt" )


include( 'shared.lua' )
include( 'npc_controller.lua' )
include( 'store.lua' )
include( 'shared_store_items.lua' )
include( 'shared_disable.lua' )
include( 'player.lua' )
include( 'recource_systems.lua' )
include( 'map.lua' )
include( 'placement.lua' )


function SendTeamInfo(pl)
	for i,Team in pairs( Teams ) do
		umsg.Start("teamstats", pl)
			umsg.Long( i )
			umsg.String( Team.Name )
			umsg.Vector( Team.Color )
			umsg.Entity( Team.Owner )
			umsg.Long( Team.Open )
		umsg.End()
	end
end

function SendAllTeamInfo()
	for i,Team in pairs( Teams ) do
		local rp = RecipientFilter()
		rp:AddAllPlayers()
		umsg.Start("teamstats", rp)
			umsg.Long( i )
			umsg.String( Team.Name )
			umsg.Vector( Team.Color )
			umsg.Entity( Team.Owner )
			umsg.Long( Team.Open )
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
	ResInit( Index )
end

function f2sPlayerAuthed( pl, SteamID, UniqueID )
	pl:SetTeam(1)
	SendTeamInfo(pl)
end
hook.Add("PlayerAuthed", "f2s.auth", f2sPlayerAuthed)

function JoinTeam( pl, cmd, args )
	id = tonumber( args[1] )
	if id > GAMEMODE.NumTeams then return end
	password = tostring( args[2] or "" )
	teampassword = Teams[id].Password
	if password == teampassword || Teams[id].Open then
		pl:SetTeam( id )
	end
end
concommand.Add( "jointeam", JoinTeam )

function MakeTeam( pl, cmd, args )
	if #args >= 6 then
		teamid = tonumber( args[1] )
		name = args[2] or "NAMEERROR"
		name = string.Left(name,18)
		pass = args[3] or ""
		r = args[4] or 100
		g = args[5] or 100
		b = args[6] or 100
		open = args[7] or 0
		print(open)
		PrintTable(args)
		if teamid < 2 then
			for k,Team in pairs( Teams ) do
				if IsLeader( pl,k ) then return 1 end
			end
			pl:SetTeam( SetUpTeam( name, pass, r,g,b, open, pl ) )
			ResInit( pl:Team() )
			PlaceRefineries(1)
		else
			pl:SetTeam( UpdateTeam( teamid, name, pass, r,g,b, open, pl ) )
		end
		SendAllTeamInfo()
		
	end

end
concommand.Add( "makeeditteam", MakeTeam )

function SetUpTeam( name, password, r,g,b, open, owner )
	GAMEMODE.NumTeams = GAMEMODE.NumTeams + 1
	local Index = GAMEMODE.NumTeams
	--TeamPassword[GAMEMODE.NumTeams] = password
	
	--team.SetUp( GAMEMODE.NumTeams, name, Color(r,g,b,255) )
	
	Teams[Index] = {}
	Teams[Index].Name = name
	Teams[Index].Color = Vector(r,g,b)
	Teams[Index].Owner = owner
	Teams[Index].Open = open
	Teams[Index].Password = password
	
	Col = Color(Teams[Index].Color.x,Teams[Index].Color.y,Teams[Index].Color.z,255)
	team.SetUp( Index, Teams[Index].Name, Col )
	return GAMEMODE.NumTeams
end

function UpdateTeam( id,name, password, r,g,b, open, owner )
	local Index = id
	
	if !IsLeader(owner,id) then return 1 end
	//Teams[Index] = {}
	Teams[Index].Name = name
	Teams[Index].Color = Vector(r,g,b)
	//Teams[Index].Owner = owner
	Teams[Index].Open = open
	Teams[Index].Password = password
	
	Col = Color(Teams[Index].Color.x,Teams[Index].Color.y,Teams[Index].Color.z,255)
	team.SetUp( Index, Teams[Index].Name, Col )
	return id
end

function IsLeader( pl,t )
	if ( pl && ValidEntity(pl) ) && ( Teams[t].Owner && ValidEntity(Teams[t].Owner) ) then
		return Teams[t].Owner == pl
	end
	return false
end

concommand.Add("selected_spawn_point", function(pl,cmd,args)
	Selection = args[1]
	if pl.ExpectingSpawnCommand then
		pl.ExpectingSpawnCommand = false
		if Selection == "def" then
			return true
		elseif Selection == "ti" then
			if pl.SpawnEnt != nil then
				if pl.SpawnEnt:IsValid() then 
					pl:SetPos(pl.SpawnEnt:GetPos() + Vector(0,0,16)) 
					pl.SpawnEnt:Fire("kill", "2")
					pl.SpawnEnt = nil
					//pl.Flare:Fire("Die",0.1)
				else
					pl.SpawnEnt = nil
				end
			end
			return true
		else
			local dontspawn_enemydist = 3000
			ref = ents.FindByClass("refinery")[tonumber(Selection)]
			if ValidEntity( ref ) && ref.Team == pl:Team() then
				for i,ply in pairs( ents.FindInSphere( ref:GetPos(), dontspawn_enemydist ) ) do
					if ply:IsPlayer() then
						if ply:Team() != ref.Team then return false end
					end
				end
				pl:SetPos( ref:GetPos() + Vector(0,0,16) )
			end
		end
	end
end)

function GM:PlayerSpawn( pl )

	if( pl:Team() ==1001 ) then
		pl:SetTeam(1)
		SendTeamInfo(pl)
	end
	
	t = pl:Team()
	
    self.BaseClass:PlayerSpawn( pl )
    pl:SetGravity( 1 )  
    pl:SetMaxHealth( 100, true )  
 
    pl:SetWalkSpeed( 250 ) 
	pl:SetRunSpeed( 400 )
	
	pl.ExpectingSpawnCommand = true
	umsg.Start( "show_spawn_menu", pl )
	umsg.End()
	pl:SetJumpPower( 200 )
	pl.MegaLegs = false
	pl:SetNWBool("HasRadar", false)
end


function GM:PlayerLoadout( pl )
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
			pl:Give( "weapon_pistol" )
			pl:Give( "weapon_shotgun" )
		else
			pl:Give( w1 )
			pl:Give( w2 )
			pl:Give( w3 )
		end
		pl:Give( "weapon_crowbar" )
	end
	
	pl:Give( "gmod_tool" )
	pl:Give( "gmod_camera" )
	pl:Give( "weapon_physgun" )
	pl:Give( "sa_flaregun" )	
	pl:Give( "f2s_constructer" )
	
	local cl_defaultweapon = pl:GetInfo( "cl_defaultweapon" )

	if ( pl:HasWeapon( cl_defaultweapon )  ) then
		pl:SelectWeapon( cl_defaultweapon ) 
	end

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
	
	SendTeamInfo( ply )
	
end



concommand.Add("yap", function() PrintTable() end)


function SetWeapons( pl, cmd, args )
	
	weapon = table.concat(args," ")
	weps = string.Explode(",",weapon)
	pl.w1 = weps[1]
	pl.w2 = weps[2]
	pl.w3 = weps[3]
end
concommand.Add("sv_cl_setw", SetWeapons)

concommand.Add("f2s_reqteaminfo",function(pl) SendTeamInfo(pl) end)
