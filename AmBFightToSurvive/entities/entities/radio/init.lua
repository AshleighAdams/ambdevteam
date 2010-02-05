AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

local SoundRadius = 3000
local Music = {
	"music/HL1_song10.mp3",
	"music/HL1_song11.mp3",
	"music/HL1_song14.mp3",
	"music/HL1_song15.mp3",
	"music/HL1_song17.mp3",
	"music/HL1_song19.mp3",
	"music/HL1_song20.mp3",
	"music/HL1_song21.mp3",
	"music/HL1_song24.mp3",
	"music/HL1_song25_REMIX3.mp3",
	"music/HL1_song26.mp3",
	"music/HL1_song3.mp3",
	"music/HL1_song5.mp3",
	"music/HL1_song6.mp3",
	"music/HL1_song9.mp3",
	"music/HL2_intro.mp3",
	"music/HL2_song0.mp3",
	"music/HL2_song1.mp3",
	"music/HL2_song10.mp3",
	"music/HL2_song11.mp3",
	"music/HL2_song12_long.mp3",
	"music/HL2_song13.mp3",
	"music/HL2_song14.mp3",
	"music/HL2_song15.mp3",
	"music/HL2_song16.mp3",
	"music/HL2_song17.mp3",
	"music/HL2_song19.mp3",
	"music/HL2_song2.mp3",
	"music/HL2_song20_submix0.mp3",
	"music/HL2_song20_submix4.mp3",
	"music/HL2_song23_SuitSong3.mp3",
	"music/HL2_song25_Teleporter.mp3",
	"music/HL2_song26.mp3",
	"music/HL2_song26_trainstation1.mp3",
	"music/HL2_song27_trainstation2.mp3",
	"music/HL2_song28.mp3",
	"music/HL2_song29.mp3",
	"music/HL2_song3.mp3",
	"music/HL2_song30.mp3",
	"music/HL2_song31.mp3",
	"music/HL2_song32.mp3",
	"music/HL2_song33.mp3",
	"music/HL2_song4.mp3",
	"music/HL2_song6.mp3",
	"music/HL2_song7.mp3",
	"music/HL2_song8.mp3"
}

-----------------------------------------
---- Initialize
-----------------------------------------
function ENT:Initialize()
	self:SetModel("models/props_lab/citizenradio.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:PhysWake()
	self:Activate()
	self:SetUseType(SIMPLE_USE)
	
	self.LastSong = nil
	self.CurrentSong = nil
	self.SoundRadius = SoundRadius
end

-----------------------------------------
---- Think
-----------------------------------------
function ENT:Think()
	if self.CurrentSong then
		self:SetNWString("CurrentSong", Music[self.CurrentSong])
	else
		self:SetNWString("CurrentSong", "")
	end
	self:SetNWFloat("SoundRadius", self.SoundRadius)
end

-----------------------------------------
---- Use
-----------------------------------------
function ENT:Use(Activator)
	if self.CurrentSong then
		self.CurrentSong = self.CurrentSong + 1
	else
		if self.LastSong then
			self.CurrentSong = self.LastSong + 1
		else
			self.CurrentSong = 1
		end
	end
	if self.CurrentSong > #Music then
		self.CurrentSong = 1
	end
	if Activator:IsPlayer() then
		if self.CurrentSong then
			Activator:ChatPrint("Now playing " .. Music[self.CurrentSong])
		else
		end
	end
end

-----------------------------------------
---- OnTakeNormalDamage
-----------------------------------------
function ENT:OnTakeNormalDamage(Info)
	-- Turn off
	self.LastSong = self.CurrentSong
	self.CurrentSong = nil
end