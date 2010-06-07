--------------------------------------------
-- Gets if entity B is visible by entity A
-- in a way that doesnt suck.
--------------------------------------------
function Visible(A, B)
	local trace = { }
	local trstart,trend = A:GetPos(),B:GetPos()
	local filter = {A,B}
	if A:IsPlayer() then
		trstart = A:GetShootPos()
		local veh = A:GetVehicle()
		if ValidEntity(veh) then
			table.insert(filter, veh)
		end
	end
	if B:IsPlayer() then 
		trend = B:GetShootPos() 
		local veh = B:GetVehicle()
		if ValidEntity(veh) then
			table.insert(filter, veh)
		end
	end
	if A:GetClass() == "refinery" then // fix spawner spawning in the floor
		trstart = trstart + Vector(0,0,50)
	end if B:GetClass() == "refinery" then
		trend = trend + Vector(0,0,50)
	end
	trace.start = trstart
	trace.endpos = trend
	trace.filter = filter
	local traceres = util.TraceLine(trace)
	return not traceres.Hit
end