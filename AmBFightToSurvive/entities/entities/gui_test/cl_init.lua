include('shared.lua')

ENT.RenderGroup = RENDERGROUP_TRANSLUCENT
-----------------------------------------
---- Initialize
-----------------------------------------
function ENT:Initialize()
	local ent = self.Entity
	ent:SetModel("models/Items/AR2_Grenade.mdl")
end

-----------------------------------------
---- Draw
-----------------------------------------
function ENT:Draw()
	-- Create contents
	if not self.Frame then
		self.Frame = vgui.Create("DFrame")
		self.Frame:SetPos(-250, -250)
		self.Frame:SetSize(500, 500)
		self.Frame:SetTitle("PWNED")
		self.Frame:SetVisible(false)
		self.Frame:SetDraggable(true)
		self.Frame:ShowCloseButton(true)
	end
	-- Draw
	cam.Start3D2D(self:GetPos(), Angle(0, 0, 0), 0.1)
	self:DrawControl(-250, -250, 500, 500)
	
	cam.End3D2D()
end

-----------------------------------------
-- Draws a gui control.
-----------------------------------------
function ENT:DrawControl(X, Y, Width, Height)
	if self.Frame.Paint then
		self.Frame:Paint()
	end
	
	if self.Frame.PaintOver then
		self.Frame:PaintOver()
	end
end