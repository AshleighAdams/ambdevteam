MapMetrics = nil
local MapMaterials = MapMaterials or { }
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
-- PlayerInitalSpawn hook to send map
-- metrics to the client.
--------------------------------------------
local function SendMapMetrics(Player, Handler, ID, Encoded, Decoded)
	local mm = GetMapMetrics()
	umsg.Start("map_metrics", Player)
	umsg.Float(mm.Height)
	umsg.Float(mm.MinX)
	umsg.Float(mm.MinY)
	umsg.Float(mm.MaxX)
	umsg.Float(mm.MaxY)
	umsg.End()
end
datastream.Hook("MapMetrics_Pls", SendMapMetrics)

--------------------------------------------
-- This curious concommand will take many
-- measurements of the map and output them
-- to a text file for use of creating a 
-- minimap. This command will take a very
-- long time. Parameters are width and
-- height in pixels and output file name
-- with the no extenstion.
--------------------------------------------
local function RenderMap(Player, Command, Args)
	local width = tonumber(Args[1])
	local height = tonumber(Args[2])
	local filename = Args[3]
	print("Begining rendering")
	print("This will take a very long time")
	print("Grab something to drink and sit back")
	
	local curnum = 1
	function append(number)
		filex.Append(filename .. tostring(curnum) .. ".txt", tostring(number) .. "\n")
	end
	
	-- Write width and height to file
	file.Write(filename .. "1.txt", "")
	append(width)
	append(height)
	
	-- Begin tracing
	local mm = GetMapMetrics()
	local xres = (mm.MaxX - mm.MinX) / width
	local yres = (mm.MaxY - mm.MinY) / height
	local batchamount = 500
	local batchdelay = 0.5
	local function trace(curx, cury)
		for i = 1, batchamount do
			local trace = { }
			trace.start = Vector(xres * (curx + 0.5) + mm.MinX, yres * (cury + 0.5) + mm.MinY, mm.Height)
			trace.endpos = trace.start - Vector(0, 0, 65536)
			local gres = util.TraceLine(trace).HitPos.z
			trace.mask = -1
			local wres = util.TraceLine(trace).HitPos.z
			append(gres) -- Ground height
			append(wres) -- Water height
			curx = curx + 1
			if curx >= width then
				cury = cury + 1
				curx = 0
			end
			if cury >= height then
				print("DONE!!!")
				return
			end
		end
		print(tostring(curx + cury * width) .. " of " .. tostring(width * height) .. " complete")
		
		-- Append next file
		filex.Append(filename .. tostring(curnum) .. ".txt", filename .. tostring(curnum + 1) .. ".txt")
		curnum = curnum + 1
		
		timer.Simple(batchdelay, trace, curx, cury)
	end
	trace(0, 0)
end
concommand.Add("rendermap", RenderMap)