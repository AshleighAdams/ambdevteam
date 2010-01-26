AddCSLuaFile( "shared.lua" )
 
include('shared.lua')

function ENT:KeyValue(key, value)
	if key == "model" then
		self.model = value
	end
end
 
function ENT:Initialize()
	self:SetModel( self.model or "models/Nova/airboat_seat.mdl" )
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	self:PhysWake()
	
	self:SetKeyValue("classname", "prop_vehicle_prisoner_pod")
	
	self.is_weapon_seat = true
	
	self.curtime = 0
end
 
function ENT:OnTakeDamage(dmginfo)
	self:TakePhysicsDamage(dmginfo)
	
	if ValidEntity(self.ply) then
		if dmginfo:GetAttacker() == self.ply then return end
		self.ply:TakeDamageInfo(dmginfo)		
	end
end 

function ENT:Use( activator, caller )
	if CurTime() > self.curtime and not self.busy then
		self:Enter(activator)
		self.curtime = CurTime() + 0.2
	end
end

function ENT:Enter(ply)
	if gamemode.Call("CanPlayerEnterVehicle", ply, self, 0) then
		if not self.busy then 
			local posang = self:GetAttachment(self:LookupAttachment("vehicle_feet_passenger0"))
			self.ply = ply
			self.ply:SetMoveType(MOVETYPE_NOCLIP)
			self.ply:SetPos(posang.Pos+posang.Ang:Up()*45-Vector(0,0,72))
			self.ply:SetAngles(posang.Ang)
			self.ply:SetNWBool("is in weapon seat", true)
			self.ply:SetNWEntity("weapon seat", self)
			self.ply:SetNotSolid(true)
			self.ply:SetParent(self)
			self.busy = true
		else
			self:Drop(ply)
		end
	end
end
  
function ENT:Drop()
	if not ValidEntity(self.ply) then self.busy = false return end
	self.ply:SetParent()
	self.ply:SetMoveType(MOVETYPE_WALK)
	self.ply:SetNWBool("is in weapon seat", false)
	self.ply:SetNWEntity("weapon seat", NULL)
	self.ply:SetNotSolid(false)
	self.ply:SetPos(self:GetPos() + Vector(0,0,80) + (self.ply:GetAimVector() * 70))
	self.ply:SetVelocity(self:GetVelocity())
	self.busy = false
	hook.Call("PlayerLeaveVehicle", gmod.GetGamemode(), self.ply, self)
	self.ply = nil
end

function ENT:OnRemove()
	if ValidEntity(self.ply) then
		self:Drop()
	end
end

function ENT:PreEntityCopy()
	duplicator.StoreEntityModifier(self, "Weapon Seat", {model = self.model})
end

hook.Add("KeyPress", "Weapon Seat", function(ply, key)
	if not ValidEntity(ply) then return end
	local seat = ply:GetNWEntity("weapon seat")
	if ply:GetNWBool("is in weapon seat") and key == IN_USE and ply:KeyDown(IN_WALK) and ValidEntity(seat) then
		seat:Drop(ply)
	end
end)

hook.Add("PlayerDeath", "Weapon Seat", function(ply)
	if not ValidEntity(ply) then return end
	local seat = ply:GetNWEntity("weapon seat")
	if ply:GetNWBool("is in weapon seat") and ValidEntity(seat) then
		seat:Drop(ply)
	end
end)

local function PostEntityPaste(ply, ent, data)
	ent:SetModel(data.model)
	ent:PhysicsInit( SOLID_VPHYSICS )
end

duplicator.RegisterEntityModifier( "Weapon Seat", PostEntityPaste )

local servertags = GetConVarString("sv_tags") --Thanks PHX!

if servertags == nil then
	RunConsoleCommand("sv_tags", "weaponseats")
elseif not string.find(servertags, "weaponseats") then
	RunConsoleCommand("sv_tags", "weaponseats," .. servertags)
end