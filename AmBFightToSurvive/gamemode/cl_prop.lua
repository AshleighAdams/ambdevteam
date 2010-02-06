--------------------------------------------
-- Flickers a prop.
--------------------------------------------
local function ReceiveFlicker(UM)
	local ent = UM:ReadEntity()
	local tex = UM:ReadString()
	local back = UM:ReadString()
	local time = UM:ReadFloat()
	
	if ent:IsValid() then
		ent:SetMaterial(tex)
		timer.Simple(time, function(ent, back)
				if ent:IsValid() then
					ent:SetMaterial(back)
				end
			end, ent, back)
	end
end
usermessage.Hook("flicker_prop", ReceiveFlicker)