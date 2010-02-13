ENT.Type = "anim"

ENT.PrintName		= "Weapons Crate"
ENT.Author			= "C0BRA"
ENT.Contact			= ""
ENT.Purpose			= ""
ENT.Spawnable		= true
ENT.AdminSpawnable	= true
ENT.AutomaticFrameAdvance = true
ENT.IsOpen			= false


function ENT:Use(Activator)
	if !Activator:IsPlayer() or self.IsOpen == true then return end
	self.IsOpen = true
	self.Entity:SetPlaybackRate(1.0)
	local sequence = self.Entity:LookupSequence("Open")
	self.Entity:SetSequence(sequence)
	self.Entity:EmitSound("items/ammocrate_open.wav")
	
	timer.Simple( 1.5, function(ply,ent)
		if !ent and !IsValid(ent) then return end
		local sequence = ent:LookupSequence("Close")
		ent:SetSequence(sequence)
		if CLIENT then return end
		ply:Give( ent.Weapon or "weapon_stunstick" )
		self.Entity:EmitSound("items/ammocrate_close.wav")
	end,Activator,self.Entity)
	
	timer.Simple( 2.0, function(ply,ent)
		if !ent and !IsValid(ent) then return end
		local sequence = ent:LookupSequence("idle")
		ent:SetSequence(sequence)
		ent.IsOpen = false
	end,Activator,self.Entity)
	
end

function ENT:Think()
	self:NextThink(CurTime())
	return true 
end