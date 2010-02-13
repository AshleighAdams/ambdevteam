DeriveGamemode( "sandbox" )

GM.Name 	= "Fight To Survive"
GM.Author 	= "C0BRA and DrSchnz"
GM.Email 	= ""
GM.Website 	= "www.AmB-Clan.com"

MapMaterials = { }
MapMaterials["freespace06_v2-1"] = "amb/freespace06"
MapMaterials["freespace09"] = "amb/freespace09"

if SERVER then
	local map = game.GetMap()
	resource.AddFile( "materials/" .. MapMaterials[map] .. ".vmt" )
end

GM.IsSandboxDerived = true

function GM:ShouldCollide( Ent1, Ent2 )
	if(Ent1:IsPlayer() && Ent2:IsPlayer()) then
		if Ent1:Team() == 1 then return true end
		return Ent1:Team() != Ent2:Team()
	end
	return true
end