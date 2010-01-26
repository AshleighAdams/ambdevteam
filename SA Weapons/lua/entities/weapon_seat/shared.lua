ENT.Type = "anim"
ENT.Base = "base_anim"

ENT.PrintName = "Weapon Seat Base"
ENT.Author = "CapsAdmin"
ENT.Contact = "sboyto@gmail.com"

local translated_sit = {
	default = {
		weapon_crowbar = "sit_melee",
		weapon_pistol = "sit_pistol",
		weapon_smg1 = "sit_smg1",
		weapon_frag = "sit_grenade",
		weapon_physcannon = "sit_gravgun",
		weapon_physgun = "sit_gravgun",
		weapon_crossbow = "sit_crossbow",
		weapon_shotgun = "sit_shotgun",
		weapon_357 = "sit_pistol",
		gmod_tool = "sit_pistol",
		gmod_camera = "sit_pistol",
		weapon_rpg = "sit_rpg",
		weapon_ar2 = "sit_ar2",
		weapon_slam = "sit_slam",
	},
	sweps = {
		pistol = "sit_pistol",
		smg = "sit_smg1",
		grenade = "sit_grenade",
		ar2 = "sit_ar2",
		shotgun = "sit_shotgun",
		rpg = "sit_rpg",
		physgun = "sit_gravgun",
		crossbow = "sit_crossbow",
		melee = "sit_melee",
		slam = "sit_slam",
		normal = "sit_rollercoaster",
	},
}

local function TranslateStandToSit(weapon)
	if not ValidEntity(weapon) then return "sit_rollercoaster" end
	return translated_sit.sweps[weapon.HoldType] or translated_sit.default[weapon:GetClass()] or "sit_rollercoaster"
end

hook.Add( "Move", "Weapon Seat", function( ply, data )
	if not ValidEntity(ply) then return end
	local seat = ply:GetNWEntity("weapon seat")
	if ply:GetNWBool("is in weapon seat") and ValidEntity(seat) then
		local posang = seat:GetAttachment(seat:LookupAttachment("vehicle_feet_passenger0"))
		data:SetVelocity(seat:GetVelocity())
		ply:SetAngles(seat:GetAngles())
		return true
	end
end)

hook.Add("SetupMove", "Weapon Seat", function(ply, data)
	if not ValidEntity(ply) then return end
	local seat = ply:GetNWEntity("weapon seat")
	if ply:GetNWBool("is in weapon seat") and ValidEntity(seat) then
		local posang = seat:GetAttachment(seat:LookupAttachment("vehicle_feet_passenger0"))
		data:SetVelocity(seat:GetVelocity())
		data:SetOrigin(posang.Pos+posang.Ang:Up()*25-Vector(0,0,64))
		return true
	end
end)

if CLIENT then

	hook.Add("ShouldDrawLocalPlayer", "Weapon Seat", function()
		if GetConVar("gmod_vehicle_viewmode"):GetBool() and LocalPlayer():GetNWBool("is in weapon seat") then return true end
	end)

	local function DrawPlayerInSeat()
		for key, ply in pairs(player.GetAll()) do
			local seat = ply:GetNWEntity("weapon seat")
			if ValidEntity(seat) and ValidEntity(ply) then
				local posang = seat:GetAttachment(seat:LookupAttachment("vehicle_feet_passenger0"))
				local angles = seat:GetAngles()
				angles:RotateAroundAxis(seat:GetUp(), 90)
				ply:SetAngles(angles)
				ply:SetPos(posang.Pos)
				local angle = math.NormalizeAngle(ply:EyeAngles().y-90)/180
				ply:SetPoseParameter("body_yaw", angle*29.7)
				ply:SetPoseParameter("spine_yaw", angle*30.7)
				ply:SetPoseParameter("aim_yaw", angle*52.5)
				ply:SetPoseParameter("head_yaw", angle*30.7)
			end
		end
	end
	
	hook.Add("RenderScene", "Weapon Seat", function()
		DrawPlayerInSeat() -- Calcview isn't realiable enough, it sometimes stops executing fast, and when it does, this takes over with some bugs such as when you shoot the position flickers.
	end)
	
	hook.Add("CalcView", "Weapon Seat", function(ply,origin,angles,fov)
		DrawPlayerInSeat()
		local seat = ply:GetNWEntity("weapon seat")
		if ply:GetNWBool("is in weapon seat") and ValidEntity(seat) and not ply.weapon_seat_visible then
			local posang = seat:GetAttachment(seat:LookupAttachment("vehicle_feet_passenger0"))
			local new_origin = posang.Pos + posang.Ang:Up() * 25
			return GAMEMODE:CalcView(ply,new_origin,angles,fov)
		end
	end)

	hook.Add("PostPlayerDraw", "Weapon Seat", function(ply)
		if ValidEntity(ply) and ply == LocalPlayer() then
			ply.weapon_seat_visible = true
			timer.Create("Callback Hack Weapon Seat", 0.1, 1, function()
				ply.weapon_seat_visible = false
			end)
		end
	end)

	if SinglePlayer() then
		local x = 0
		local y = 0
		hook.Add("CreateMove", "Weapon Seat", function(ucmd)
			if not LocalPlayer():GetNWBool("is in weapon seat") then return end
			if LocalPlayer():KeyDown(IN_USE) and LocalPlayer():KeyDown(IN_ATTACK) and (ValidEntity(LocalPlayer():GetActiveWeapon()) and LocalPlayer():GetActiveWeapon():GetClass() == "weapon_physgun") then return end
			local sensitivity = 50
			x = x + (ucmd:GetMouseX() / (LocalPlayer():GetInfo("sensitivity") * LocalPlayer():GetInfo("m_yaw") < 0 and -sensitivity or sensitivity))
			y = y + (ucmd:GetMouseY() / (LocalPlayer():GetInfo("sensitivity") * LocalPlayer():GetInfo("m_pitch") < 0 and -sensitivity or sensitivity))
			y = math.Clamp(y,-89,89)
			ucmd:SetViewAngles(Angle(y,-x,0))
			return true
		end)
	end

	usermessage.Hook("Weapon Seats Entered Vehicle", function(umr)
		local ply = umr:ReadEntity()
		local vehicle = umr:ReadEntity()
		hook.Call("PlayerEnteredVehicle", gmod.GetGamemode(), ply, vehicle, 1) -- I have no idea what role is so I'll just pass 1.
	end)
	
end


if SERVER then

	hook.Add("UpdateAnimation", "Weapon Seat", function(ply)
		if not ValidEntity(ply) then return end
		local seat = ply:GetNWEntity("weapon seat")
		if ValidEntity(seat) then
			ply:SetSequence(TranslateStandToSit(ply:GetActiveWeapon()))
			return true
		end
	end)

	hook.Add("SetPlayerAnimation", "Weapon Seat", function(ply)
		if not ValidEntity(ply) then return end
		if ply:GetNWBool("is in weapon seat") then
			ply:SetSequence(TranslateStandToSit(ply:GetActiveWeapon()))
			return true
		end
	end)

end

local entity_meta = FindMetaTable("Entity")

WSOldIsVehicle = WSOldIsVehicle or entity_meta.IsVehicle

function entity_meta:IsVehicle()
	if self.is_weapon_seat then
		return true 
	else
		return WSOldIsVehicle( self )
	end
end

if SERVER then

    WSOldGetDriver = WSOldGetDriver or entity_meta.GetDriver

	function entity_meta:GetDriver()
		if self.is_weapon_seat then
			return self.ply
		else
			return WSOldGetDriver( self )
		end
	end

    WSOldGetPassenger = WSOldGetPassenger or entity_meta.GetPassenger

	function entity_meta:GetPassenger()
		if self.is_weapon_seat then
			return self.ply
		else
			return WSOldGetPassenger( self )
		end
	end

end

local player_meta = FindMetaTable( "Player" )

WSOldInVehicle = WSOldInVehicle or player_meta.InVehicle

function player_meta:InVehicle()
	if self:GetNWBool("is in weapon seat") and ValidEntity(self:GetNWEntity("weapon seat")) then
		return true
	else
		return WSOldInVehicle( self )
	end
end

WSOldGetVehicle = WSOldGetVehicle or player_meta.GetVehicle

function player_meta:GetVehicle()
	local seat = self:GetNWEntity("weapon seat")
	if self:GetNWBool("is in weapon seat") then
		if ValidEntity(seat) then
			return seat 
		end
	else
		return WSOldGetVehicle( self )
	end
end

if SERVER then

    WSOldEnterVehicle = WSOldEnterVehicle or player_meta.EnterVehicle

	function player_meta:EnterVehicle(entity)
		if entity.is_weapon_seat then
			entity:Enter(self)
		else
			return WSOldEnterVehicle( self, entity )
		end
	end

    WSOldExitVehicle = WSOldExitVehicle or player_meta.ExitVehicle

	function player_meta:ExitVehicle()
		local seat = self:GetNWEntity("weapon seat")
		if self:GetNWBool("is in weapon seat") and ValidEntity(seat) then
			if gamemode.Call("CanExitVehicle", seat, self) then 
				seat:Drop(self)
			end
		else
			return WSOldExitVehicle( self )
		end
	end

end