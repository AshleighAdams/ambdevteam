

TOOL.Category		= "Render"
TOOL.Name			= "#Cameras"
TOOL.Command		= nil
TOOL.ConfigName		= nil

TOOL.ClientConVar[ "locked" ] 	= "0"
TOOL.ClientConVar[ "key" ] 	= "0"
TOOL.ClientConVar[ "toggle" ] 	= "1"

cleanup.Register( "cameras" )

GAMEMODE.CameraList = GAMEMODE.CameraList or {}

function TOOL:LeftClick( trace )

	local key	= self:GetClientNumber( "key" )
	if (key == -1) then return false end

	if (CLIENT) then return true end

	local ply 	= self:GetOwner()
	local locked	= self:GetClientNumber( "locked" )
	local toggle	= self:GetClientNumber( "toggle" )
	local pid	= ply:UniqueID()

	GAMEMODE.CameraList[ pid ] 	= GAMEMODE.CameraList[ pid ] or {}
	local CameraList = GAMEMODE.CameraList[ pid ]

	local Pos = trace.StartPos// + trace.Normal * 16

	// If the camera already exists then remove it
	if (CameraList[ key ] && CameraList[ key ] != NULL ) then

		local ent = CameraList[ key ]
		ent:Remove()
	end

	local camera = ents.Create( "gmod_cameraprop" )
	if (!camera:IsValid()) then return false end

		camera:SetAngles( ply:EyeAngles() )
		camera:SetPos( Pos )
		camera:Spawn()
		
		camera:SetKey( key )
		camera:SetPlayer( ply )
		camera:SetLocked( locked )
		camera.toggle = toggle

		camera:SetTracking( NULL, Vector(0) )
		
		if toggle == 1 then
			numpad.OnDown(	ply, key, "Camera_Toggle",  camera )
		else
			numpad.OnDown(	ply, key, "Camera_On",  camera )
			numpad.OnUp(	ply, key, "Camera_Off", camera )
		end

	undo.Create("Camera")
		undo.AddEntity( camera )
		undo.SetPlayer( ply )
	undo.Finish()

	ply:AddCleanup( "cameras", camera )

	
	CameraList[ key ] = camera
	
	return true, camera

end

function TOOL:RightClick( trace )

	_, camera = self:LeftClick( trace, true )
	
	if (CLIENT) then return true end

	if ( !camera || !camera:IsValid() ) then return end
	
	if ( trace.Entity:IsWorld() ) then
	
		trace.Entity = self:GetOwner()
		trace.HitPos = self:GetOwner():GetPos()
	
	end

	camera:SetTracking( trace.Entity, trace.Entity:WorldToLocal( trace.HitPos ))
	
	return true
	
end
