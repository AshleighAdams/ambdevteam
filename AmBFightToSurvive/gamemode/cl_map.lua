require("datastream")

local MapKey = KEY_F3
local MapMaterials = { }
MapMaterials["freespace06_v2-1"] = "amb/freespace06"

MapMetrics = nil
MapPanel = nil
--------------------------------------------
-- Opens the map, making it available for
-- the player.
--------------------------------------------
function OpenMap(Popup, Title)
	if MapMetrics then
		-- If the map is not yet created, create it.
		if not MapPanel then
			MapPanel = vgui.Create("MapPanel")
		end
		
		-- Check status
		if not MapPanel.Valid then
			MapPanel:Remove()
			MapPanel = nil
			return false
		end
		
		-- Open
		MapPanel:SetVisible(true)
		MapPanel:SetTitle(Title or "The Map")
		if Popup then
			MapPanel.Popup = true
			MapPanel:ShowCloseButton(true)
			MapPanel:SetDeleteOnClose(false)
			MapPanel:MakePopup()
			MapPanel:SetKeyBoardInputEnabled()
		else
			MapPanel:SetKeyBoardInputEnabled()
			MapPanel:SetMouseInputEnabled()
		end
		return true
	else
		-- Ask server for map metrics
		datastream.StreamToServer("MapMetrics_Pls", { })
		return false
	end
end

--------------------------------------------
-- Closes the map without destroying it.
-- Causes all hooks to be reset.
--------------------------------------------
function CloseMap()
	if MapPanel then
		MapPanel.Popup = false
		MapPanel:SetVisible(false)
		MapPanel:ShowCloseButton(false)
		for p, a in pairs(MapPanel.Points) do
			if a then
				p.ClickHooks = nil
			end
		end
	end
end


--------------------------------------------
-- The following methods can be applied to
-- points:
---- SetPos(Vector)
---- GetPos()
---- SetDisplaySize(Width, Height)
---- SetVisible(Visible)
---- AttachClickHook(Callback)
---- OnDraw(Point, X, Y) - Callback
---- OnThink(Point) - Callback
---- ShouldRemove(Point) - Callback
--------------------------------------------
local MetaPoint = { }

--------------------------------------------
-- Sets the world position of the point.
--------------------------------------------
function MetaPoint:SetPos(Position)
	self.Pos = Position
end

--------------------------------------------
-- Gets the world position of the point.
--------------------------------------------
function MetaPoint:GetPos()
	return self.Pos
end

--------------------------------------------
-- Sets the size in pixels the point will be
-- displayed as.
--------------------------------------------
function MetaPoint:SetDisplaySize(Width, Height)
	self.Width = Width
	self.Height = Height
end

--------------------------------------------
-- Sets if the point is visible.
--------------------------------------------
function MetaPoint:SetVisible(Visible)
	self.Visible = Visible
end

--------------------------------------------
-- Attaches a hook to this point that will
-- be called when it's clicked. If the hook
-- returns true, it will be removed and no
-- longer called.
--------------------------------------------
function MetaPoint:AttachClickHook(Callback)
	if not self.ClickHooks then
		self.ClickHooks = { }
	end
	self.ClickHooks[Callback] = true
end

--------------------------------------------
-- Adds a point to the map and returns the
-- handle to it.
--------------------------------------------
function AddMapPoint()
	if MapPanel then
		local point = { }
		point.Width = 0
		point.Height = 0
		point.Visible = false
		setmetatable(point, {__index = MetaPoint})
		MapPanel.Points[point] = true
		return point
	else
		return nil
	end
end

--------------------------------------------
-- The panel used for maps.
--------------------------------------------
vgui.Register("MapPanel", { 
	Init = function(self)
		self.MapMaterial = MapMaterials[game.GetMap()]
		self.MapMetrics = MapMetrics
		self.TitleSize = 24
		self.Padding = 10
		if self.MapMaterial and self.MapMetrics then
			self.MapTexture = surface.GetTextureID(self.MapMaterial)
			self.MapWidth, self.MapHeight = surface.GetTextureSize(self.MapTexture)
			
			-- Position map
			self:SetSize(self.MapWidth + (self.Padding * 2.0),  self.MapHeight + self.TitleSize + (self.Padding * 2.0))
			self:SetTitle("The Map")
			self:SetDraggable(true)
			self:ShowCloseButton(false)
			self:Center()
			self.Valid = true
			
			-- Points
			self.Points = { }
		else
			self.Valid = false
		end
	end,
	
	Think = function(self)
		local toremove = { }
		for p, a in pairs(self.Points) do
			if a then
				if p.OnThink then
					p.OnThink(p)
				end
				if p.ShouldRemove then
					if p.ShouldRemove(p) then
						self.Points[p] = nil
					end
				end
			end
		end
	end,
	
	PaintOver = function(self)
		local w, h = self:GetSize()
		local mw, mh = surface.GetTextureSize(self.MapTexture)
		local mx, my = self.Padding, self.Padding + self.TitleSize
		surface.SetTexture(self.MapTexture)
		surface.SetDrawColor(255,255,255,255)
		surface.DrawTexturedRect(mx, my, mw, mh)
		
		-- Draw points
		for p, a in pairs(self.Points) do
			if a then
				local pos = p:GetPos()
				if pos and p.Visible then
					local x, y = self:PixelPointPos(pos)
					local w, h = p.Width, p.Height
					if p.OnDraw then
						p.OnDraw(p, x + mx - (w / 2.0), y + my - (h / 2.0))
					end
				end
			end
		end
	end,
	
	PixelPointPos = function(self, Position)
		-- Returns the pixel in relation to
		-- the topleft corner of the map this
		-- world position is.
		
		local mm = self.MapMetrics
		local xv = (Position.x - mm.MinX) / (mm.MaxX - mm.MinX)
		local yv = (mm.MaxY - Position.y) / (mm.MaxY - mm.MinY)
		xv = xv * self.MapWidth
		yv = yv * self.MapHeight
		return xv, yv
	end,
	
	UpdateCursor = function(self, X, Y)
		local mx, my = self.Padding, self.Padding + self.TitleSize
		X = X - mx
		Y = Y - my
		for p, a in pairs(self.Points) do
			if a then
				local pos = p:GetPos()
				if pos and p.Visible then
					local x, y = self:PixelPointPos(pos)
					local w, h = p.Width, p.Height
					if X >= x - (w / 2.0) and Y >= y - (h / 2.0) and X <= x + (w / 2.0) and Y <= y + (w / 2.0) then
						self.CursorPoint = p
						return
					end
				end
			end
		end
		self.CursorPoint = nil
	end,
	
	OnCursorMoved = function(self, X, Y)
		self:UpdateCursor(X, Y)
	end,
	
	OnMousePressed = function(self, MC)
		if MC == MOUSE_LEFT then
			local point = self.CursorPoint
			if point then
				local hooks = point.ClickHooks
				if hooks then
					for h, a in pairs(hooks) do
						if a then
							local res = h(point)
							if res then
								hooks[h] = nil
							end
						end
					end
				end
			end
		end
	end
}, "DFrame")

--------------------------------------------
-- Hook to receive map metrics from the
-- server.
--------------------------------------------
local function ReceiveMapMetrics(UM)
	MapMetrics = {
		Height = UM:ReadFloat(),
		MinX = UM:ReadFloat(),
		MinY = UM:ReadFloat(),
		MaxX = UM:ReadFloat(),
		MaxY = UM:ReadFloat()
	}
end
usermessage.Hook("map_metrics", ReceiveMapMetrics)

--------------------------------------------
-- Gets if player a can see player b on the
-- map.
--------------------------------------------
local function CanSeePlayerOnMap(A, B)
	if A == B then
		return true
	end
	if A:GetNWBool("HasRadar", false) then
		return true
	end
	
	local ateam = A:Team()
	local bteam = B:Team()
	if ateam > 1 then
		if bteam > 1 then
			if ateam == bteam then
				return true
			else
				return false
			end
		else
			return true
		end
	else
		return false
	end
end

--------------------------------------------
-- Think hook for the map.
--------------------------------------------
local function MapThink()
	if input.IsKeyDown(MapKey) then
		if MapPanel then
			if not MapPanel:IsVisible() then
				OpenMap(nil)
			end
		else
			OpenMap(nil)
		end
	else
		if MapPanel then
			if MapPanel:IsVisible() and not MapPanel.Popup then
				CloseMap()
			end
			if not MapPanel:IsVisible() and MapPanel.Popup then
				CloseMap()
			end
		end
	end
	
	-- Add players to map
	if MapPanel then
		for _, p in pairs(player.GetAll()) do
			if CanSeePlayerOnMap(LocalPlayer(), p) then
				local tb = p:GetTable()
				if not tb then
					tb = { }
					p:SetTable(tb)
				end
				
				if not tb.MapPoint then
					local point = AddMapPoint()
					local pointsize = 4
					if p == LocalPlayer() then
						pointsize = 6
					end
					point:SetDisplaySize(pointsize, pointsize)
					point:SetVisible(true)
					point.Player = p
					point.OnThink = function(point)
						if point.Player:IsValid() then
							point:SetPos(point.Player:GetPos())
						end
						point:SetVisible(CanSeePlayerOnMap(LocalPlayer(), point.Player))
					end
					point.OnDraw = function(point, x, y)
						if point.Player:IsValid() then
							local t = point.Player:Team()
							local col = Color(255, 255, 255, 255)
							if t > 1 then
								col = team.GetColor(t)
							end
							surface.SetDrawColor(col)
							surface.DrawRect(x, y, pointsize, pointsize)
						end
					end
					point.ShouldRemove = function(point)
						return not point.Player:IsValid()
					end
					tb.MapPoint = point
				end
			end
		end
	end
end
hook.Add("Think", "MapThink", MapThink)