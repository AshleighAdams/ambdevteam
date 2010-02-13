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
	trace.start = trstart
	trace.endpos = trend
	trace.filter = filter
	local traceres = util.TraceLine(trace)
	return not traceres.Hit
end