include("shared_store.lua")

--------------------------------------------
-- Message to player when to autobuy stuff.
--------------------------------------------
function StorePlayerSpawn(Player)
	if Player then
		umsg.Start("store_autobuy", Player)
		umsg.End()
	end
end
hook.Add("PlayerSpawn", "StorePlayerSpawn", StorePlayerSpawn)