include('shared.lua')

ENT.RenderGroup = RENDERGROUP_BOTH

local BeamMat = Material("tripmine_laser")
local BeamHeight = 2000
local BeamSize = 500
local BeamFade = 6000
local Bounds = 100

-----------------------------------------
---- Initialize
-----------------------------------------
function ENT:Initialize()
	local ent = self.Entity
	local pos = ent:GetPos()
	ent:SetModel("models/props_c17/FurnitureBoiler001a.mdl")
	ent:SetRenderBoundsWS(Vector(-Bounds, -Bounds, -Bounds) + pos, Vector(Bounds, Bounds, BeamHeight) + pos)
	self.Team = 0
end

-----------------------------------------
---- Draw
-----------------------------------------
function ENT:Draw()
	local ent = self.Entity
	local pos = ent:GetPos()
	ent:DrawModel()
	
	-- Draw beam to identify refinery and owner.
	local alpha = 1.0
	if LocalPlayer() then
		local ppos = LocalPlayer():GetPos()
		local dis = (ppos - pos):Length()
		alpha = math.min(dis / BeamFade, 1.0)
	end
	local color = Color(255, 255, 255, 255)
	if self.Team ~= 0 then
		color = team.GetColor(self.Team)
		color.r =  127 + (color.r / 2.0)
		color.g =  127 + (color.g / 2.0)
		color.b =  127 + (color.b / 2.0)
	end
	color.a = alpha * 255
	render.SetMaterial(BeamMat)
	render.StartBeam(2)
	render.AddBeam(ent:GetPos(), BeamSize, 0, color)
	render.AddBeam(ent:GetPos() + Vector(0, 0, BeamHeight), BeamSize, 1, Color(color.r, color.g, color.b, 0))
	render.EndBeam()
	
	-- Add map point for the refinery
	if not self.MapPoint then
		self.MapPoint = AddMapPoint()
		if self.MapPoint then
			local pointsize = 8
			local pointthick = 2
		
			self.MapPoint:SetDisplaySize(pointsize, pointsize)
			self.MapPoint:SetVisible(true)
			self.MapPoint:SetPos(pos)
			self.MapPoint.Refinery = self
			self.MapPoint.OnDraw = function(point, x, y)
				if point.Refinery:IsValid() then
					local color = Color(255, 255, 255, 255)
					if point.Refinery.Team ~= 0 then
						color = team.GetColor(point.Refinery.Team)
					end
					surface.SetDrawColor(color)
					for i = 0, pointthick - 1 do
						surface.DrawOutlinedRect(x + i, y + i, pointsize - 2 * i, pointsize - 2 * i)
					end
				end
			end
			self.MapPoint.ShouldRemove = function(point)
				return not point.Refinery:IsValid()
			end
		end
	end
end

-----------------------------------------
---- Think
-----------------------------------------
function ENT:Think()
	local ent = self.Entity
	
	-- Teams
	self.Team = self:GetNWInt("Owner", 0)
end