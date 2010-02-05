include('shared.lua')

local BeatDelay = 0.25

-----------------------------------------
---- Initialize
-----------------------------------------
function ENT:Initialize()
	local ent = self.Entity
	ent:SetModel("models/props_lab/citizenradio.mdl")
	
	self.LastSong = ""
	self.Sound = nil
	self.SoundStart = nil
	self.SoundLength = nil
	self.LastBeat = 0.0
end

-----------------------------------------
---- Think
-----------------------------------------
function ENT:Think()
	local p = LocalPlayer()
	local dis = (self:GetPos() - p:GetPos()):Length()
	self.CurrentSong = self:GetNWString("CurrentSong", "")
	self.SoundRadius = self:GetNWFloat("SoundRadius", 3000)
	
	if self.LastSong ~= self.CurrentSong then
		if self.Sound then
			self.LastSong = ""
			self.Sound:Stop()
			self.Sound = nil
		end
		if self.CurrentSong ~= "" and dis < self.SoundRadius then
			self.LastSong = self.CurrentSong
			self.Sound = CreateSound(self, self.CurrentSong)
			self.SoundStart = CurTime()
			self.SoundLength = SoundDuration(self.CurrentSong)
			self.Sound:Play()
		end
	end
	if self.Sound then
		if CurTime() > self.LastBeat + BeatDelay then
			self.LastBeat = CurTime()
			self:SetColor(math.random(128, 255), math.random(128, 255), math.random(128, 255), 255)
		end
		if dis > self.SoundRadius or CurTime() > self.SoundStart + self.SoundLength then
			self.LastSong = ""
			self.Sound:Stop()
			self.Sound = nil
		end
	else
		self:SetColor(255, 255, 255, 255)
	end
end