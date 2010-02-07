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

--------------------------------------------
-- Updates a prop with data from the server.
--------------------------------------------
function UpdateProp(Prop)
	Prop.Registered = Prop:GetNWBool("Registered", false)
	if Prop.Registered then
		Prop.Constructed = Prop:GetNWBool("Constructed", false)
		Prop.State = Prop:GetNWInt("State", 0)
		Prop.Team = Prop:GetNWInt("Team", 0)
		Prop.ResNeeded = Prop:GetNWFloat("ResNeeded", 0.0)
		Prop.Cost = Prop:GetNWFloat("Cost", 0.0)
	end
end