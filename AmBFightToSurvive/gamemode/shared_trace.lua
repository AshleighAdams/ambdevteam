--------------------------------------------
-- Gets if entity B is visible by entity A
-- in a way that doesnt suck.
--------------------------------------------
function Visible(A, B)
	local trace = { }
	trace.start = A:GetPos()
	trace.endpos = B:GetPos()
	trace.filter = {A, B}
	local traceres = util.TraceLine(trace)
	return not traceres.Hit
end