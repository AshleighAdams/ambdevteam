MapMetrics = nil
Refineries = Refineries or { }

--------------------------------------------
-- Creates map metrics, which is information
-- about the map's size
--------------------------------------------
function GetMapMetrics()
	if MapMetrics == nil then
		-- Trace up from all entities to get sky.
		local mm = { }
		mm.MaxUnit = 65536
		local max = mm.MaxUnit
		local skyboxpoint = Vector(0, 0, -(1.0 / 2.0) * max)
		for i, e in pairs(ents.GetAll()) do
			local tracedata = { }
			tracedata.start = e:GetPos()
			tracedata.endpos = e:GetPos() + Vector(0, 0, max)
			local trace = util.TraceLine(tracedata)
			if trace.Hit then
				local hitpos = trace.HitPos
				if hitpos.z > skyboxpoint.z then
					skyboxpoint = hitpos
				end
			end
		end
		mm.Height = skyboxpoint.z
		
		-- Find skybox size in every direction
		local skymax = Vector(0, 0, 0)
		local skymin = Vector(0, 0, 0)
		mm.MaxX = util.TraceLine({start = skyboxpoint, endpos = skyboxpoint + Vector(max, 0, 0)}).HitPos.x
		mm.MaxY = util.TraceLine({start = skyboxpoint, endpos = skyboxpoint + Vector(0, max, 0)}).HitPos.y
		mm.MinX = util.TraceLine({start = skyboxpoint, endpos = skyboxpoint + Vector(-max, 0, 0)}).HitPos.x
		mm.MinY = util.TraceLine({start = skyboxpoint, endpos = skyboxpoint + Vector(0, -max, 0)}).HitPos.y
		MapMetrics = mm
		return mm
	else
		return MapMetrics
	end
end

--------------------------------------------
-- Places an amount of refineries along the
-- map.
--------------------------------------------
function PlaceRefineries(Amount)
	for i = 1, Amount do
		PlaceRefinery(50)
	end
end

--------------------------------------------
-- Places a refinery with a quality
-- specified. The higher quality is, the
-- better the placement of the refinery
-- is. Quality should be around 50 by
-- default.
--------------------------------------------
function PlaceRefinery(Quality)
	local qual = Quality or 50
	
	-- Create candidate points, which can
	-- possible have a refinery
	local best = {score = 0.0, point = nil}
	local mm = GetMapMetrics()
	for i = 1, qual do
		-- Pick a random point on the skybox
		local point = Vector(
			math.random() * (mm.MaxX - mm.MinX) + mm.MinX,
			math.random() * (mm.MaxY - mm.MinY) + mm.MinY,
			mm.Height)
		
		-- Trace around point to find its flatness
		local traces = 6
		local tracedis = 300
		local traceheights = { }
		for i = 1, traces do
			local ang = ((i - 1) / traces) * math.pi * 2.0
			local npoint = Vector(
				math.sin(ang) * tracedis, 
				math.cos(ang) * tracedis, 
				-mm.MaxUnit) + point
			local tracedata = { }
			tracedata.start = point
			tracedata.endpos = npoint
			local traceres = util.TraceLine(tracedata)
			if traceres.Hit then
				local val = traceres.HitPos.z
				table.insert(traceheights, val)
			end
		end
		
		-- Score the flatness of the point
		local flatscore = 0.0
		local lastheight = nil
		local totalheight = 0.0
		for i = 1, #traceheights + 1 do
			t = math.fmod((i - 1), #traceheights) + 1
			local val = traceheights[t]
			if lastheight then
				totalheight = totalheight + val
				local diff = math.abs(lastheight - val)
				flatscore = flatscore + (100.0 - diff)
			end
			lastheight = val
		end
		local averageheight = totalheight / #traceheights
		flatscore = math.Clamp(flatscore / #traceheights, 0.0, 100.0)
		local actualpoint = Vector(point.x, point.y, averageheight)
		
		-- Initialize water score, which is 500 when the
		-- point is on ground or 0 when its on water
		local waterscore = 500
		if util.PointContents(actualpoint - Vector(0, 0, 64)) == CONTENTS_WATER then
			waterscore = 0
		end
		
		-- Find distance from map edge
		local edgescore = 0.0
		local edgesize = 10000.0
		edgescore = math.min(math.min(actualpoint.x - mm.MinX, mm.MaxX - actualpoint.x),
			math.min(actualpoint.y - mm.MinY, mm.MaxY - actualpoint.y))
		edgescore = edgescore / edgesize * 100
		edgescore = math.Clamp(edgescore, 0.0, 100.0)
		
		-- Find distance from other refineries
		local refineryradius = 50000.0
		local crowdscore = refineryradius
		for i, r in pairs(Refineries) do
			local refpos = r:GetPos()
			local dis = (actualpoint - refpos):Length()
			if crowdscore > dis then
				crowdscore = dis
			end
		end
		crowdscore = crowdscore / refineryradius * 100.0
		
		-- Total score and submit if highest and tweaks
		crowdscore = crowdscore * 10
		flatscore = flatscore * 5
		
		local score = flatscore + waterscore + edgescore + crowdscore
		if score > best.score then
			best.point = actualpoint
			best.score = score
		end
	end
	
	-- Create refinery on best score
	if best.point ~= nil then
		local point = best.point
		local ref = ents.Create("refinery")
		ref:SetPos(point)
		ref:Spawn()
	end
end