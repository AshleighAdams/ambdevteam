--------------------------------------------
-- Gets if entity B is visible by entity A
-- in a way that doesnt suck.
--------------------------------------------
function Visible(A, B)
	local trace = { }
	local trstart,trend = A:GetPos(),B:GetPos()
	if A:IsPlayer() then trstart = A:GetShootPos() end
	if B:IsPlayer() then trend = B:GetShootPos() end
	trace.start = trstart
	trace.endpos = trend
	trace.filter = {A, B}
	local traceres = util.TraceLine(trace)
	return not traceres.Hit
end