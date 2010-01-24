
TOOL.Category		= "Render"
TOOL.Name			= "#Paint"
TOOL.Command		= nil
TOOL.ConfigName		= ""


TOOL.LeftClickAutomatic = true
TOOL.RightClickAutomatic = true
TOOL.RequiresTraceHit = true

TOOL.ClientConVar[ "decal" ] = "Blood"

local function PlaceDecal( Ent, Pos1, Pos2, decal )

	util.Decal( decal, Pos1, Pos2 )
	
	if ( CLIENT) then return end
	if ( Ent == NULL ) then return end
	if ( Ent:IsWorld() ) then return end
	if ( Ent:GetClass() != "prop_ragdoll" ) then return end

	local decal = 
		{ 
			decal, 
			Ent:WorldToLocal(Pos1), 
			Ent:WorldToLocal(Pos2) 
		}

	if not	Ent.decals then Ent.decals = {} end

	table.insert( Ent.decals, 1, decal )

	//Trim decal table so only 50 decals are saved
	if #Ent.decals > 50 then
		Ent.decals[51] = nil
	end

end


function TOOL:LeftClick( trace )

	self:GetOwner():EmitSound("SprayCan.Paint")
	local decal	= self:GetClientInfo( "decal" )
	
	local Pos1 = trace.HitPos + trace.HitNormal
	local Pos2 = trace.HitPos - trace.HitNormal

	PlaceDecal( trace.Entity, Pos1, Pos2, decal )
	
	self:GetWeapon():SetNextPrimaryFire( CurTime() + 0.03 )
	
	return false
	
end

function TOOL:RightClick( trace )

	self:GetOwner():EmitSound("SprayCan.Paint")
	local decal	= self:GetClientInfo( "decal" )
	
	local Pos1 = trace.HitPos + trace.HitNormal
	local Pos2 = trace.HitPos - trace.HitNormal

	PlaceDecal( trace.Entity, Pos1, Pos2, decal )

	self:GetWeapon():SetNextSecondaryFire( CurTime() + 0.2 )

	return false
	
end

list.Add( "PaintMaterials", "Eye" )
list.Add( "PaintMaterials", "Smile" )
list.Add( "PaintMaterials", "Light" )
list.Add( "PaintMaterials", "Dark" )
list.Add( "PaintMaterials", "Blood" )
list.Add( "PaintMaterials", "YellowBlood" )
list.Add( "PaintMaterials", "Impact.Metal" )
list.Add( "PaintMaterials", "Scorch" )
list.Add( "PaintMaterials", "BeerSplash" )
list.Add( "PaintMaterials", "ExplosiveGunshot" )
list.Add( "PaintMaterials", "BirdPoop" )
list.Add( "PaintMaterials", "PaintSplatPink" )
list.Add( "PaintMaterials", "PaintSplatGreen" )
list.Add( "PaintMaterials", "PaintSplatBlue" )
list.Add( "PaintMaterials", "ManhackCut" )
list.Add( "PaintMaterials", "FadingScorch" )
list.Add( "PaintMaterials", "Antlion.Splat" )
list.Add( "PaintMaterials", "Splash.Large" )
list.Add( "PaintMaterials", "BulletProof" )
list.Add( "PaintMaterials", "GlassBreak" )
list.Add( "PaintMaterials", "Impact.Sand" )
list.Add( "PaintMaterials", "Impact.BloodyFlesh" )
list.Add( "PaintMaterials", "Impact.Antlion" )
list.Add( "PaintMaterials", "Impact.Glass" )
list.Add( "PaintMaterials", "Impact.Wood" )
list.Add( "PaintMaterials", "Impact.Concrete" )
list.Add( "PaintMaterials", "Noughtsncrosses" )
list.Add( "PaintMaterials", "Nought" )
list.Add( "PaintMaterials", "Cross" )

function TOOL.BuildCPanel( CPanel )

	// HEADER
	CPanel:AddControl( "Header", { Text = "#Tool_paint_name", Description	= "#Tool_paint_desc" }  )
	
	local Options = list.Get( "PaintMaterials" )
	table.sort( Options )
	
	local RealOptions = {}

	for k, decal in pairs( Options ) do
	
		//local MatName = util.DecalMaterial( decal )	
		RealOptions[ decal ] = { paint_decal = decal }
	
	end
		
	CPanel:AddControl( "ListBox", { Label = "#Tool_paint_choose", Height = "300", Options = RealOptions } )
	
	
									
end
