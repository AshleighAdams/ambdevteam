DeriveGamemode( "sandbox" )

GM.Name 	= "Fight To Survive"
GM.Author 	= "AmB"
GM.Email 	= ""
GM.Website 	= "www.AmB-Clan.com"


GM.IsSandboxDerived = true

function GM:ShouldCollide( Ent1, Ent2 )
	if(Ent1:IsPlayer() && Ent2:IsPlayer()) then
		if Ent1:Team() == 1 then return true end
		return Ent1:Team() != Ent2:Team()
	end
	return true
end