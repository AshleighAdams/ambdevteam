local BuyRadius = 3000

--------------------------------------------
-- Sets the item given in a store purchase.
-- Action should be a callback that gives
-- the player the item. Returning true in
-- the action will undo the purchase.
--------------------------------------------
function SetItemAction(Item, Action)
	Item.OnPurchase = function(Item, Player, AutoBuy)
		local team = Player:Team()
		
		-- Check to make sure there are no other players around.
		local near = ents.FindInSphere(Player:GetPos(), BuyRadius)
		for i, e in pairs(near) do
			if e:IsPlayer() then
				local otherteam = e:Team()
				if otherteam > 1 and otherteam ~= team then
					if not AutoBuy then
						Player:ChatPrint("Enemy players too close")
					end
					return
				end
			end
		end
		
		local amount = Item:GetCost()
		if GetResP(team) < amount then
			if not AutoBuy then
				Player:ChatPrint("Not enough Resps")
			end
		else
			TakeResP(team, amount)
			if Action then
				if Action(Player) then
					GiveResP(team, has)
				else
					if not AutoBuy then
						Player:ChatPrint("Purchased: " .. Item:GetName())
					end
				end
			end
		end
	end
end

--------------------------------------------
-- Helper function to add an item.
--------------------------------------------
local OldAddItem = AddItem
local function AddItem(Name, Cost, Categories, Action)
	local item = OldAddItem(Name, Cost)
	for k, v in pairs(Categories) do
		AddItemToCategory(item, v)
	end
	SetItemAction(item, Action)
end

--------------------------------------------
-- Helper function to add an item that will
-- be purchased by using the constructor
-- to build it. BuildData is a function
-- that will create the build data needed
-- when supplied with the player.
--------------------------------------------
local function AddItemBuildData(Name, Cost, Categories, BuildData)
	AddItem(Name, Cost, Categories, function(Player)
		local bd = BuildData(Player)
		local oncancel = bd.OnCancel
		local giveresp = function()
			GiveResP(Player:Team(), Cost)
		end
		if oncancel then
			bd.OnCancel = function()
				giveresp()
				oncancel()
			end
		else
			bd.OnCancel = giveresp
		end
		Player:AddToBuildQueue(bd)
	end)
end
GetBuildDataFunction = GetBuildDataFunction or function() end
GetVehicleBuildDataFunction = GetVehicleBuildDataFunction or function() end

-- Categories
Categories = { }
local C = Categories
C.WarStuffs = AddCategory("War Stuffs")
C.Weapons = AddCategory("Weapons", C.WarStuffs)
C.WeaponCrates = AddCategory("Weapon Crates", C.WarStuffs)
C.Ammo = AddCategory("Ammunition", C.WarStuffs)
C.Supplies = AddCategory("Supplies and Improvements", C.WarStuffs)
C.AreaDefense = AddCategory("Area Defense", C.WarStuffs)
C.Misc = AddCategory("Misc", C.WarStuffs)
C.Special = AddCategory("Special", C.WarStuffs)
C.Transport = AddCategory("Transport")
C.Land = AddCategory("Land", C.Transport)
C.Air = AddCategory("Air", C.Transport)
C.Seat = AddCategory("Seats", C.Transport)
C.Useless = AddCategory("Useless")
C.Masochism = AddCategory("Masochism", C.Useless)

-- Weapons
AddItem("Submachine Gun", 100, {C.Weapons}, function(Player)
		Player:Give("weapon_smg1")
	end)
AddItem("Crossbow", 250, {C.Weapons}, function(Player)
		Player:Give("weapon_crossbow")
	end)
AddItem("Shotgun", 50, {C.Weapons}, function(Player)
		Player:Give("weapon_shotgun")
	end)
AddItem("RPG Launcher", 800, {C.Weapons}, function(Player)
		Player:Give("weapon_rpg")
	end)
AddItem("Pistol", 30, {C.Weapons}, function(Player)
		Player:Give("weapon_pistol")
	end)
AddItem("Crowbar", 25, {C.Weapons}, function(Player)
		Player:Give("weapon_crowbar")
	end)
AddItem("Frag Gernades", 200, {C.Weapons}, function(Player)
		Player:GiveAmmo(6, "grenade")
		Player:Give("weapon_frag")
	end)
AddItem("357 Magnum", 150, {C.Weapons}, function(Player)
		Player:Give("weapon_357")
	end)
AddItem("Pulse Rifle", 400, {C.Weapons}, function(Player)
		Player:Give("weapon_ar2")
	end)
AddItem("Stun Stick", 80, {C.Weapons}, function(Player)
		Player:Give("weapon_stunstick")
	end)
--Weapon Crates
AddItem("Submachine Gun Crate", 1000, {C.WeaponCrates}, function(Player)
		local crate = Spawn(Player, "weapon_crate",nil,nil,Vector(0,0,20))
		crate.Weapon = "weapon_smg1"
	end)
	
	
AddItem("AssultRifle 2 (Pulse Rifle) Crate", 2500, {C.WeaponCrates}, function(Player)
		local crate = Spawn(Player, "weapon_crate",nil,nil,Vector(0,0,20))
		crate.Weapon = "weapon_ar2"
	end)
AddItem("Grenades Crate", 4000, {C.WeaponCrates}, function(Player)
		local crate = Spawn(Player, "weapon_crate",nil,nil,Vector(0,0,20))
		crate.Weapon = "weapon_frag"
	end)
AddItem("Crossbow Crate", 2000, {C.WeaponCrates}, function(Player)
		local crate = Spawn(Player, "weapon_crate",nil,nil,Vector(0,0,20))
		crate.Weapon = "weapon_crossbow"
	end)
AddItem(".357 Crate", 2000, {C.WeaponCrates}, function(Player)
		local crate = Spawn(Player, "weapon_crate",nil,nil,Vector(0,0,20))
		crate.Weapon = "weapon_357"
	end)

-- Ammo
AddItem("Submachine Gun Ammo 256 Pack", 40, {C.Ammo}, function(Player)
		Player:GiveAmmo(256, "SMG1")
	end)
AddItem("Pistol Ammo 256 Pack", 30, {C.Ammo}, function(Player)
		Player:GiveAmmo(256, "Pistol")
	end)
AddItem("Crossbow Bolts 32 Pack", 40, {C.Ammo}, function(Player)
		Player:GiveAmmo(32, "XBowBolt")
	end)
AddItem("RPG Rounds 5 Pack", 150, {C.Ammo}, function(Player)
		Player:GiveAmmo(5, "RPG_Round")
	end)
AddItem("Shotgun Ammo 64 Pack", 40, {C.Ammo}, function(Player)
		Player:GiveAmmo(64, "Buckshot")
	end)
AddItem("357 Magnum Bullets 32 Pack", 60, {C.Ammo}, function(Player)
		Player:GiveAmmo(32, "357")
	end)
AddItem("Pulse Rifle Energy Sphere 6 Pack", 30, {C.Ammo}, function(Player)
		Player:GiveAmmo(6, "AR2AltFire")
	end)
AddItem("Pulse Rifle Bullets 100 Pack", 90, {C.Ammo}, function(Player)
		Player:GiveAmmo(100, "AR2")
	end)

-- Area Defense
AddItem("Autoturret", 500, {C.AreaDefense}, function(Player)
		local npc = SpawnNPC(Player, "npc_turret_floor")
		npc:GetPhysicsObject():SetMass(250)
		EnableDamage(npc, 300)		
	end)
AddItemBuildData("Autorepair Beacon", 240, {C.AreaDefense}, 
	GetBuildDataFunction("autorepair_beacon"))
AddItemBuildData("Neural Disruptor", 650, {C.AreaDefense}, 
	GetBuildDataFunction("neural_disruptor"))
AddItemBuildData("Proximity Mine", 90, {C.AreaDefense}, 
	GetBuildDataFunction("proximity_mine"))
AddItemBuildData("Combine Thumper", 1500, {C.AreaDefense}, 
	GetBuildDataFunction("sent_thumper"))
	
-- Misc
AddItem("Tactical Insertion", 100, {C.Misc}, function(Player)
		Player:Give("tactical_insertion")
	end)
AddItem("Reclaimator", 60, {C.Misc, C.Weapons}, function(Player)
		Player:Give("reclaimator")
	end)
AddItem("Gravity Gun", 50, {C.Misc, C.Weapons}, function(Player)
		Player:Give("weapon_physcannon")
	end)
	
-- Supplies
AddItem("Full Health Kit", 150, {C.Supplies}, function(Player)
		Player:SetHealth(Player:GetMaxHealth())
	end)
AddItem("Max Health +25", 150, {C.Supplies}, function(Player)
		Player:SetMaxHealth(Player:GetMaxHealth() + 25)
	end)
AddItem("Full Armor", 250, {C.Supplies}, function(Player)
		Player:SetArmor(100)
	end)
AddItem("Mega Legs (Running)", 300, {C.Supplies}, function(Player)
		Player:SetRunSpeed(700)
		Player:SetWalkSpeed(400)
		Player:SprintEnable()
		Player.MegaLegs = true
	end)
AddItem("Superior Legs (Running)", 650, {C.Supplies}, function(Player)
		Player:SetRunSpeed(1000)
		Player:SetWalkSpeed(500)
		Player:SprintEnable()
		Player.MegaLegs = true
	end)
AddItem("Mega Legs (Jumping)", 200, {C.Supplies}, function(Player)
		Player:SetJumpPower(500)
	end)
AddItem("Grav Buster", 300, {C.Supplies}, function(Player)
		Player:SetGravity(0.5)
	end)
AddItem("Radar", 500, {C.Supplies}, function(Player)
		Player:SetNWBool("HasRadar", true)
	end)

-- Special
AddItem("SciP (Sientific Credit)", 10000, {C.Special}, function(Player)
		GiveSciP(Player:Team(), 1)
	end)
AddItem("Orbital Downfall", 100, {C.Special}, function(Player)
		Player:Give("orbital_downfall")
	end)
AddItemBuildData("Refinery Point", 1500, {C.Special}, 
	GetBuildDataFunction("refinery"))
	
-- Transport
-- Land 
AddItemBuildData("Jeep", 300, {C.Land}, 
	GetVehicleBuildDataFunction("Jeep"))
	
AddItemBuildData("Air Boat", 300, {C.Land},
	GetVehicleBuildDataFunction("Airboat"))

--Air
AddItem("Helicopter", 1000, {C.Air}, function(Player)
		local vec = Spawn(Player, "sent_sakariashelicopter")
	end)
--Seats
AddItem("Airboat Seat", 50, {C.Seat}, function(Player)
		local vec = SpawnVehicle(Player, "Seat_Airboat")
	end)
	
AddItem("Jeep Seat", 50, {C.Seat}, function(Player)
		local vec = SpawnVehicle(Player, "Seat_Jeep")
	end)
	
AddItem("Wooden Chair", 50, {C.Seat}, function(Player)
		local vec = SpawnVehicle(Player, "Chair_Wood")
	end)
	
AddItem("HL2 Pod", 50, {C.Seat}, function(Player)
		local vec = SpawnVehicle(Player, "Pod")
	end)

-- Useless
AddItem("Radio", 150, {C.Useless}, function(Player)
		Spawn(Player, "radio")
	end)
AddItem("Camera", 0, {C.Useless}, function(Player)
		Player:Give( "gmod_camera" )
	end)
AddItem("100 ResPs", 200, {C.Useless}, function(Player)
		GiveResP(Player:Team(), 100)
	end)
AddItem("UBER FUCKIN LEGS", 600, {C.Useless}, function(Player)
		Player:SetJumpPower(4000)
		Player:SetGravity(3)
	end)
AddItem("Shout out", 1000, {C.Useless}, function(Player)
		for i, p in pairs(player.GetAll()) do
			p:PrintMessage(HUD_PRINTCENTER, "Hay guys, " .. Player:Nick() .. " is DA BOMB")
		end
	end)
AddItem("Kill Yourself", 500, {C.Masochism}, function(Player)
		Player:Kill()
	end)
AddItem("Kick Yourself", 1000, {C.Masochism}, function(Player)
		Player:Kick("Asked for it.")
	end)
	
function GiveTeamWeapon( t, cost, wep )
	local weps = Teams[t].Weapons or {}
	if table.HasValue( weps, wep ) then
		GiveResP(t,cost)
	else
		table.insert( weps, wep )
		Teams[t].Weapons = weps
	end
end