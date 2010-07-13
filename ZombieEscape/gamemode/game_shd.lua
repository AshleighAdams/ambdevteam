next_map_in_x_rounds = 10
round_start = 0
round_end = false
local PLY = _R.Entity

local SpawnPoints = {}

local texture = ""

PRI_SLOT = 1
SEC_SLOT = 2
VIP_SLOT = 3

ZOMBIE_SCREAM = "npc/fast_zombie/fz_scream1.wav"

WIN_SOUND = {}
WIN_SOUND[1] = "radio/ctwin"
WIN_SOUND[2] = "radio/twin"

local pri_slots = {
		"weapon_ak47",
		"weapon_m4a1",
		"weapon_mp5",
		"weapon_tmp",
		"weapon_para7",
		"weapon_mac10",
		"weapon_pumpshotgun"
	}
local sec_slots = {
		"weapon_glock",
		"weapon_deagle",
		"weapon_fiveseven",
		"weapon_flashbang",
		"weapon_hegrenade"
	}
local vip_slot = {
	"",
	"",
	"",
	""
	}

function NewRound()
	round_end = false
	round_start = CurTime()
	
	next_map_in_x_rounds = next_map_in_x_rounds -1
	//  We need to clean up and reset the map
	game.CleanUpMap()
	
	if SERVER then
		hook.Call( "InitPostEntity", GAMEMODE )
		for i,pl in pairs( player.GetAll() ) do
			pl:SetTeam( TEAM_HUMAN )
			pl:Spawn()
			
			local Spawn = GetSpawn(pl)
			pl:SetPos(Spawn:GetPos())
			
			pl:Lock()
			timer.Simple( 3, function(pl) pl:UnLock() end,pl)
		end
	end
	
	timer.Simple( 10, GetZombie )
	
	timer.Create( "round_timer", 600, 1, RoundEnd)
end
function GetZombie()
	if CLIENT then return end
	local plys = {}								// the valid players
	for k,ply in pairs( player.GetAll() ) do	// loop through
		if ply:Team() == TEAM_HUMAN then		// add only ones who are humans
			plys[k] = ply
			//table.Add( plys, ply )		bug?				// add them in
		end
	end
	PrintTable(plys)
	
	// now select one randomly and remove his weapons then give him a knife
	local rnd = math.Round( math.Rand( 1, #plys ) )
	print(rnd)
	local pl = plys[rnd]
	if #plys < 2 then
		timer.Create( "wfmp", 5,0, WaitForMorePeople )
		return false
	end
	pl:SetZombie()
end
function PLY:SetZombie()
	if !ValidEntity(self) or !self:IsPlayer() then return end	// make sure there players
	if self:Team() == TEAM_HUMAN then							// only humands can be changed
		
		weps = self:GetWeapons()
		for v,wep in pairs( weps ) do							// drop all there weapons excluding knife
			if wep:GetClass() != "weapon_knife" then
				self:DropWeapon( wep )
			end
		end
		self:EmitSound(ZOMBIE_SCREAM)
		self:DoEffects()										// Drap the explodion effect
		self:SetTeam( TEAM_ZOMBIE )								// yup
		self:SetHealth(2500)
		self:SetWalkSpeed(275)									// make them walk faster than humans
		CheckForWinner()
	end
end
function PLY:DoEffects()
	local pos = self:GetShootPos()
	local effectdata = EffectData()
	effectdata:SetStart( pos )
	effectdata:SetOrigin( pos )
	effectdata:SetScale( 2 )
	util.Effect( "HelicopterMegaBomb", effectdata )	
	
	util.ScreenShake(self:GetPos(), 5, 1, 10)
	self:EmitSound("", 200, 100)
end
function RoundEnd(winner)
	if CLIENT then return end
	if winner == TEAM_HUMAN or winner == nil then
		//humans win
		umsg.Start("winner")
			umsg.String("ze/humans_win")
			umsg.String("")
		umsg.End()
	else
		//zombies win
		umsg.Start("winner")
			umsg.String("ze/zombies_win")
			umsg.String("")
		umsg.End()
				umsg.Start("winner") umsg.String("ze/zombies_win") umsg.String("") umsg.End()
	end
	
	timer.Remove("round_timer")
	timer.Simple( 3, NewRound )
end

function WaitForMorePeople()
	local plys = {}								// the valid players
	for k,ply in pairs( player.GetAll() ) do	// loop through
		if ply:Team() == TEAM_HUMAN then		// add only ones who are humans
			table.Add( plys, ply )				// add them in
		end
	end 
	if #plys > 1 then			//if we got enugh players then restart the round + remove timer
		timer.Remove("wfnp")
		RoundEnd()
	end
end
function CheckForWinner()

	local players = player.GetAll()
	local z,h = 0,0
	
	for k,v in pairs( players ) do
		if v:Team() == TEAM_HUMAN && v:Alive() then
			h = h + 1
		elseif v:Team() == TEAM_ZOMBIE && v:Alive() then
			z = z + 1
		end
	end
	
	if z == 0 then
		RoundEnd(TEAM_HUMAN)
	elseif h == 0 then
		RoundEnd(TEAM_ZOMBIE)
	end
end
local function PlayerDeath(pl, wep, killer)
	CheckForWinner()
end
hook.Add( "PlayerDeath", "shouldroundend", PlayerDeath )

function CheckZombiePickup(ply, wep)
   return ply:Team() == TEAM_HUMAN
end
hook.Add("PlayerCanPickupWeapon", "stopzombiespickingup", CheckZombiePickup)

usermessage.Hook( "winner", function(um)
	texture = um:ReadString()
	local sound = Sound( um:ReadString() )
	round_end=true
end)
// We can't hook so easy in a function so i done this :P (yes, i know its weird)
hook.Add("HUDPaintBackground", "winner", function()
	if not round_end then return end
	local mat = Material( texture )
	surface.SetTexture( mat )
	surface.DrawRect( ScrW() - (512/2), ScrH() - (512/2), 512, 512 )
end)

function PLY:SetSlot(slot,id) // Sets spawn weapons in varibles to be used in spawn hook
	if slot == SLOT_PRI then
		self.PriSlot = pri_slots[id] or ""
	elseif slot == SLOT_SEC then
		self.SecSlot = sec_slots[id] or ""
	elseif slot == SLOT_VIP then
		self.VIPSlot = vip_slots[id] or ""
	end
end
concommand.Add( "ze_setslot", function(ply,cmd,args)	
		local slot = args[1] 	or 0
		local id = args[2]		or 0
		if id==0 or slot==0 then return end
		PLY:SetSlot(slot, id)
	end)


	
local function MapChanges()
	if SERVER then
		for _, ent in ipairs( ents.FindByName( "logic_map_start" ) ) do
			if ( ent:GetClass() == "logic_relay" ) then
				ent:Fire( "trigger", 0, 0 )
			end
		end
		for k,v in pairs(ents.FindByClass("point_servercommand")) do
			local nm = v.targetname  
			local ent = ents.Create("point_servercommand_new")  
			ent:SetPos(v:GetPos())  
			v:Remove()  
			ent:SetKeyValue("targetname", nm)  
			ent:Spawn()  
		end  
	end
	
end
hook.Add( "InitPostEntity", "MapStartTrigger", MapChanges )

if SERVER then
	hook.Add("EntityKeyValue", "fix_pc", function(e, k, v)  
		if e:GetClass() == "point_servercommand" then
			if k == "targetname" then
				e.targetname = v
			end
		end
	end)
end

function GetSpawn( pl ) // YUP INO

	if ( GAMEMODE.TeamBased ) then
	
		local ent = GAMEMODE:PlayerSelectTeamSpawn( pl:Team(), pl )
		if ( IsValid(ent) ) then return ent end
	
	end

	
	// Save information about all of the spawn points
	// in a team based game you'd split up the spawns
	if ( !IsTableOfEntitiesValid( SpawnPoints ) ) then
	
		LastSpawnPoint = 0
		SpawnPoints = ents.FindByClass( "info_player_start" )
		SpawnPoints = table.Add( SpawnPoints, ents.FindByClass( "info_player_deathmatch" ) )
		SpawnPoints = table.Add( SpawnPoints, ents.FindByClass( "info_player_combine" ) )
		SpawnPoints = table.Add( SpawnPoints, ents.FindByClass( "info_player_rebel" ) )
		
		// CS Maps
		SpawnPoints = table.Add( SpawnPoints, ents.FindByClass( "info_player_counterterrorist" ) )
		SpawnPoints = table.Add( SpawnPoints, ents.FindByClass( "info_player_terrorist" ) )
		
		// DOD Maps
		SpawnPoints = table.Add( SpawnPoints, ents.FindByClass( "info_player_axis" ) )
		SpawnPoints = table.Add( SpawnPoints, ents.FindByClass( "info_player_allies" ) )

		// (Old) GMod Maps
		SpawnPoints = table.Add( SpawnPoints, ents.FindByClass( "gmod_player_start" ) )
		
		// TF Maps
		SpawnPoints = table.Add( SpawnPoints, ents.FindByClass( "info_player_teamspawn" ) )		
		
		// If any of the spawnpoints have a MASTER flag then only use that one.
		for k, v in pairs( SpawnPoints ) do
		
			if ( v:HasSpawnFlags( 1 ) ) then
			
				SpawnPoints = {}
				SpawnPoints[1] = v
			
			end
		
		end

	end
	
	local Count = table.Count( SpawnPoints )
	
	if ( Count == 0 ) then
		Msg("[PlayerSelectSpawn] Error! No spawn points!\n")
		return nil 
	end
	
	local ChosenSpawnPoint = nil
	
	// Try to work out the best, random spawnpoint (in 6 goes)
	for i=0, 6 do
	
		ChosenSpawnPoint = table.Random( SpawnPoints )

		if ( ChosenSpawnPoint &&
			ChosenSpawnPoint:IsValid() &&
			ChosenSpawnPoint:IsInWorld() &&
			ChosenSpawnPoint != pl:GetVar( "LastSpawnpoint" ) &&
			ChosenSpawnPoint != self.LastSpawnPoint ) then
			
			if ( GAMEMODE:IsSpawnpointSuitable( pl, ChosenSpawnPoint, i==6 ) ) then
			
				self.LastSpawnPoint = ChosenSpawnPoint
				pl:SetVar( "LastSpawnpoint", ChosenSpawnPoint )
				return ChosenSpawnPoint
			
			end
			
		end
			
	end
	
	return ChosenSpawnPoint
	
end

timer.Simple( 20, NewRound )