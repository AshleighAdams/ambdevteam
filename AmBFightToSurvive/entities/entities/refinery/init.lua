AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')
Refineries = Refineries or { }

-----------------------------------------
---- Initialize
-----------------------------------------
function ENT:Initialize()
	local ent = self.Entity
	ent:SetModel("models/props_c17/FurnitureBoiler001a.mdl")
	table.insert(Refineries, ent)
	self.Team = nil
end

-----------------------------------------
---- OnRemove
-----------------------------------------
function ENT:OnRemove()
	for i = 1, #Refineries do
		if Refineries[i] == self.Entity then
			table.remove(Refineries, i)
		end
	end
end

-----------------------------------------
---- Think
-----------------------------------------
function ENT:Think()
	local ent = self.Entity

end