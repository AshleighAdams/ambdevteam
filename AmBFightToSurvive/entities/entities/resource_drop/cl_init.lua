include('shared.lua')

-----------------------------------------
---- Initialize
-----------------------------------------
function ENT:Initialize()
	local ent = self.Entity
	ent:SetModel("models/Items/item_item_crate.mdl")
	
	-- Add point on map
	self.MapPoint = AddMapPoint()
	if self.MapPoint then
		local pointsize = 6
		local pointthick = 2
	
		self.MapPoint:SetDisplaySize(pointsize, pointsize)
		self.MapPoint:SetVisible(true)
		self.MapPoint.ResourceDrop = self
		self.MapPoint.OnThink = function(point)
			if point.ResourceDrop:IsValid() then
				point:SetPos(point.ResourceDrop:GetPos())
			end
		end
		self.MapPoint.OnDraw = function(point, x, y)
			if point.ResourceDrop:IsValid() then
				surface.SetDrawColor(Color(255, 255, 255, 255))
				surface.DrawRect(x + (pointsize / 2.0) - (pointthick / 2.0), y, pointthick, pointsize)
				surface.DrawRect(x, y + (pointsize / 2.0) - (pointthick / 2.0), pointsize, pointthick)
			end
		end
		self.MapPoint.ShouldRemove = function(point)
			return not point.ResourceDrop:IsValid()
		end
	end
end