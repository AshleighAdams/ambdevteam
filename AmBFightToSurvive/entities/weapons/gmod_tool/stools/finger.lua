
TOOL.Category		= "Poser"
TOOL.Name			= "#Finger Poser"
TOOL.Command		= nil
TOOL.ConfigName		= ""

TOOL.RequiresTraceHit = true

local VarsOnHand = 5 * 3
local FingerVars = VarsOnHand * 2


/*------------------------------------------------------------
	Name: HasTF2Hands
	Desc: Returns true if it has TF2 hands
------------------------------------------------------------*/ 
local function HasTF2Hands( pEntity )
	return pEntity:LookupBone( "bip_hand_L" ) != nil
end

/*------------------------------------------------------------
	Name: HasZenoHands
	Desc: Returns true if it has Zeno Clash hands
------------------------------------------------------------*/ 
local function HasZenoHands( pEntity )
	return pEntity:LookupBone( "Bip01_L_Hand" ) != nil
end

local TranslateTable_TF2 = {}
	TranslateTable_TF2[ "ValveBiped.Bip01_L_Finger0" ] = "bip_thumb_0_L"
	TranslateTable_TF2[ "ValveBiped.Bip01_L_Finger01" ] = "bip_thumb_1_L"
	TranslateTable_TF2[ "ValveBiped.Bip01_L_Finger02" ] = "bip_thumb_2_L"
	TranslateTable_TF2[ "ValveBiped.Bip01_L_Finger1" ] = "bip_index_0_L"
	TranslateTable_TF2[ "ValveBiped.Bip01_L_Finger11" ] = "bip_index_1_L"
	TranslateTable_TF2[ "ValveBiped.Bip01_L_Finger12" ] = "bip_index_2_L"
	TranslateTable_TF2[ "ValveBiped.Bip01_L_Finger2" ] = "bip_middle_0_L"
	TranslateTable_TF2[ "ValveBiped.Bip01_L_Finger21" ] = "bip_middle_1_L"
	TranslateTable_TF2[ "ValveBiped.Bip01_L_Finger22" ] = "bip_middle_2_L"
	TranslateTable_TF2[ "ValveBiped.Bip01_L_Finger3" ] = "bip_ring_0_L"
	TranslateTable_TF2[ "ValveBiped.Bip01_L_Finger31" ] = "bip_ring_1_L"
	TranslateTable_TF2[ "ValveBiped.Bip01_L_Finger32" ] = "bip_ring_2_L"
	TranslateTable_TF2[ "ValveBiped.Bip01_L_Finger4" ] = "bip_pinky_0_L"
	TranslateTable_TF2[ "ValveBiped.Bip01_L_Finger41" ] = "bip_pinky_1_L"
	TranslateTable_TF2[ "ValveBiped.Bip01_L_Finger42" ] = "bip_pinky_2_L"
	TranslateTable_TF2[ "ValveBiped.Bip01_R_Finger0" ] = "bip_thumb_0_R"
	TranslateTable_TF2[ "ValveBiped.Bip01_R_Finger01" ] = "bip_thumb_1_R"
	TranslateTable_TF2[ "ValveBiped.Bip01_R_Finger02" ] = "bip_thumb_2_R"
	TranslateTable_TF2[ "ValveBiped.Bip01_R_Finger1" ] = "bip_index_0_R"
	TranslateTable_TF2[ "ValveBiped.Bip01_R_Finger11" ] = "bip_index_1_R"
	TranslateTable_TF2[ "ValveBiped.Bip01_R_Finger12" ] = "bip_index_2_R"
	TranslateTable_TF2[ "ValveBiped.Bip01_R_Finger2" ] = "bip_middle_0_R"
	TranslateTable_TF2[ "ValveBiped.Bip01_R_Finger21" ] = "bip_middle_1_R"
	TranslateTable_TF2[ "ValveBiped.Bip01_R_Finger22" ] = "bip_middle_2_R"
	TranslateTable_TF2[ "ValveBiped.Bip01_R_Finger3" ] = "bip_ring_0_R"
	TranslateTable_TF2[ "ValveBiped.Bip01_R_Finger31" ] = "bip_ring_1_R"
	TranslateTable_TF2[ "ValveBiped.Bip01_R_Finger32" ] = "bip_ring_2_R"
	TranslateTable_TF2[ "ValveBiped.Bip01_R_Finger4" ] = "bip_pinky_0_R"
	TranslateTable_TF2[ "ValveBiped.Bip01_R_Finger41" ] = "bip_pinky_1_R"
	TranslateTable_TF2[ "ValveBiped.Bip01_R_Finger42" ] = "bip_pinky_2_R"
	
local TranslateTable_Zeno = {}
	TranslateTable_Zeno[ "ValveBiped.Bip01_L_Finger0" ] = "Bip01_L_Finger0"
	TranslateTable_Zeno[ "ValveBiped.Bip01_L_Finger01" ] = "Bip01_L_Finger01"
	TranslateTable_Zeno[ "ValveBiped.Bip01_L_Finger02" ] = "Bip01_L_Finger02"
	TranslateTable_Zeno[ "ValveBiped.Bip01_L_Finger1" ] = "Bip01_L_Finger1"
	TranslateTable_Zeno[ "ValveBiped.Bip01_L_Finger11" ] = "Bip01_L_Finger11"
	TranslateTable_Zeno[ "ValveBiped.Bip01_L_Finger12" ] = "Bip01_L_Finger12"
	TranslateTable_Zeno[ "ValveBiped.Bip01_L_Finger2" ] = "Bip01_L_Finger2"
	TranslateTable_Zeno[ "ValveBiped.Bip01_L_Finger21" ] = "Bip01_L_Finger21"
	TranslateTable_Zeno[ "ValveBiped.Bip01_L_Finger22" ] = "Bip01_L_Finger22"
	TranslateTable_Zeno[ "ValveBiped.Bip01_L_Finger3" ] = "Bip01_L_Finger3"
	TranslateTable_Zeno[ "ValveBiped.Bip01_L_Finger31" ] = "Bip01_L_Finger31"
	TranslateTable_Zeno[ "ValveBiped.Bip01_L_Finger32" ] = "Bip01_L_Finger32"
	TranslateTable_Zeno[ "ValveBiped.Bip01_L_Finger4" ] = "Bip01_L_Finger4"
	TranslateTable_Zeno[ "ValveBiped.Bip01_L_Finger41" ] = "Bip01_L_Finger41"
	TranslateTable_Zeno[ "ValveBiped.Bip01_L_Finger42" ] = "Bip01_L_Finger42"
	TranslateTable_Zeno[ "ValveBiped.Bip01_R_Finger0" ] = "Bip01_R_Finger0"
	TranslateTable_Zeno[ "ValveBiped.Bip01_R_Finger01" ] = "Bip01_R_Finger01"
	TranslateTable_Zeno[ "ValveBiped.Bip01_R_Finger02" ] = "Bip01_R_Finger02"
	TranslateTable_Zeno[ "ValveBiped.Bip01_R_Finger1" ] = "Bip01_R_Finger1"
	TranslateTable_Zeno[ "ValveBiped.Bip01_R_Finger11" ] = "Bip01_R_Finger11"
	TranslateTable_Zeno[ "ValveBiped.Bip01_R_Finger12" ] = "Bip01_R_Finger12"
	TranslateTable_Zeno[ "ValveBiped.Bip01_R_Finger2" ] = "Bip01_R_Finger2"
	TranslateTable_Zeno[ "ValveBiped.Bip01_R_Finger21" ] = "Bip01_R_Finger21"
	TranslateTable_Zeno[ "ValveBiped.Bip01_R_Finger22" ] = "Bip01_R_Finger22"
	TranslateTable_Zeno[ "ValveBiped.Bip01_R_Finger3" ] = "Bip01_R_Finger3"
	TranslateTable_Zeno[ "ValveBiped.Bip01_R_Finger31" ] = "Bip01_R_Finger31"
	TranslateTable_Zeno[ "ValveBiped.Bip01_R_Finger32" ] = "Bip01_R_Finger32"
	TranslateTable_Zeno[ "ValveBiped.Bip01_R_Finger4" ] = "Bip01_R_Finger4"
	TranslateTable_Zeno[ "ValveBiped.Bip01_R_Finger41" ] = "Bip01_R_Finger41"
	TranslateTable_Zeno[ "ValveBiped.Bip01_R_Finger42" ] = "Bip01_R_Finger42"

/*---------------------------------------------------------
	Name: HandEntity
---------------------------------------------------------*/
function TOOL:HandEntity()
	return self:GetWeapon():GetNetworkedEntity( "HandEntity" )
end

/*---------------------------------------------------------
	Name: HandNum
---------------------------------------------------------*/
function TOOL:HandNum()
	return self:GetWeapon():GetNetworkedInt( "HandNum" )
end

/*---------------------------------------------------------
	Name: SetHand
---------------------------------------------------------*/
function TOOL:SetHand( ent, iHand )
	self:GetWeapon():SetNetworkedEntity( "HandEntity", ent )
	self:GetWeapon():SetNetworkedInt( "HandNum", iHand )
end

/*---------------------------------------------------------
	Name: Apply the current tool values to entity's hand
---------------------------------------------------------*/
function TOOL:ApplyValues( pEntity, iHand )

	if (CLIENT) then return end

	for i=0, VarsOnHand-1 do
	
		local Var = self:GetClientInfo( i )
		local VecComp = string.Explode( " ", Var )
		
		local Ang = Angle( tonumber(VecComp[1]), tonumber(VecComp[2]) )
		
		// The thumb's movement is reversed
		if ( i < 3 ) then
			Ang = Angle( tonumber(VecComp[2]), tonumber(VecComp[1]) )		
		end
	
		pEntity:SetNetworkedAngle( "Finger".. i+(iHand*(VarsOnHand)), Ang )
		duplicator.StoreEntityModifier( pEntity, "finger", { [i+(iHand*(VarsOnHand))] = Ang } )
		
	end


end

/*------------------------------------------------------------
	Name: GetHandPositions
	Desc: Hope we don't have any one armed models	
------------------------------------------------------------*/ 
function TOOL:GetHandPositions( pEntity )

	local LeftHand = pEntity:LookupBone( "ValveBiped.Bip01_L_Hand" )
	if (!LeftHand) then LeftHand = pEntity:LookupBone( "bip_hand_L" ) end
	if (!LeftHand) then LeftHand = pEntity:LookupBone( "Bip01_L_Hand" ) end
	
	local RightHand = pEntity:LookupBone( "ValveBiped.Bip01_R_Hand" )
	if (!RightHand) then RightHand = pEntity:LookupBone( "bip_hand_R" ) end
	if (!RightHand) then RightHand = pEntity:LookupBone( "Bip01_R_Hand" ) end
	
	if (!LeftHand || !RightHand) then return false end
	
	local LeftHand = pEntity:GetBoneMatrix( LeftHand )	
	local RightHand = pEntity:GetBoneMatrix( RightHand )
	if (!LeftHand || !RightHand) then return false end

	return LeftHand, RightHand
	
end


/*------------------------------------------------------------
	Name: LeftClick
	Desc: Applies current convar hand to picked hand
------------------------------------------------------------*/ 
function TOOL:LeftClick( trace )

	if ( trace.Entity:IsValid() && trace.Entity:IsPlayer() ) then return false end
	if ( trace.Entity:GetClass() != "prop_ragdoll" ) then return false end
	
	local LeftHand, RightHand = self:GetHandPositions( trace.Entity )
	
	if (!LeftHand) then return false end
	if ( CLIENT ) then return true end
	
	local LeftHand = (LeftHand:GetTranslation() - trace.HitPos):Length()
	local RightHand = (RightHand:GetTranslation() - trace.HitPos):Length()
	
	if ( LeftHand < RightHand ) then
	
		self:ApplyValues( trace.Entity, 0 )
	
	else
	
		self:ApplyValues( trace.Entity, 1 )
	
	end
	
	
	return true

end


/*------------------------------------------------------------
	Name: RightClick
	Desc: Selects picked hand and sucks off convars
------------------------------------------------------------*/ 
function TOOL:RightClick( trace )

	if ( CLIENT ) then return false end
	
	if ( trace.Entity:IsValid() && trace.Entity:IsPlayer() ) then return false end
	if ( trace.Entity:GetClass() != "prop_ragdoll" ) then return false end
	
	local LeftHand, RightHand = self:GetHandPositions( trace.Entity )
	if (!LeftHand) then return false end
	
	local LeftHand = (LeftHand:GetTranslation() - trace.HitPos):Length()
	local RightHand = (RightHand:GetTranslation() - trace.HitPos):Length()
	
	local Hand = 0
	if ( LeftHand < RightHand ) then
	
		self:SetHand( trace.Entity, 0, false )
	
	else
	
		self:SetHand( trace.Entity, 1, false )
		Hand = 1
	
	end
	
	for i=0, VarsOnHand-1 do
	
		local Ang = trace.Entity:GetNetworkedAngle( "Finger".. i + ( Hand * VarsOnHand ) )
		
		if ( i < 3 ) then
			self:GetOwner():ConCommand( Format( "finger_%s %.1f %.1f", i, Ang.Yaw, Ang.Pitch ) )
		else
			self:GetOwner():ConCommand( Format( "finger_%s %.1f %.1f", i, Ang.Pitch, Ang.Yaw ) )
		end		
	
	end
	
	// We don't want to send the finger poses to the client straight away
	// because they will get the old poses that are currently in their convars
	// We need to wait until they convars get updated with the sucked pose
	self.NextUpdate = CurTime() + 0.5
	
	return false
	
end

local OldHand = nil
local OldEntity = nil

/*------------------------------------------------------------
	Name: Think
	Desc: Updates the selected entity with the values from the convars
			Also, on the client it rebuilds the control panel if we have
			selected a new entity or hand
------------------------------------------------------------*/ 
function TOOL:Think()
	
	local selected = self:HandEntity()
	local hand = self:HandNum()
	
	if ( self.NextUpdate && self.NextUpdate > CurTime() ) then return end
	
	if ( CLIENT ) then
	
		if ( OldHand != hand || OldEntity != selected ) then
		
			OldHand = hand
			OldEntity = selected
			
			self:RebuildControlPanel( hand )
			
		end
	
	end

	if ( selected == NULL ) then return end
	if ( selected:IsWorld() ) then return end
	
	self:ApplyValues( selected, hand )

end

if ( SERVER ) then 

	
	/*------------------------------------------------------------
		Name: FingerCopy
		Desc: Copy the fingers from one entity to another for duplicator
	------------------------------------------------------------*/ 
	local function FingerCopy( Player, Entity, Data )
	
		for k, v in pairs( Data ) do
		
			local VarName = "Finger"..k
			Entity:SetNetworkedAngle( VarName, v, true )

		end
	
		duplicator.StoreEntityModifier( Entity, "finger", Data )
		
	end
	
	duplicator.RegisterEntityModifier( "finger", FingerCopy )
	

return end // if (SERVER)

// Notice the return above.
// The rest of this file CLIENT ONLY.

language.Add( "Tool_finger_name", "Finger Poser" )
language.Add( "Tool_finger_desc", "Adjust the fingers of ragdolls" )
language.Add( "Tool_finger_0", "Right click to copy/select. Left click to apply." )

function TOOL.BuildCPanel( CPanel )

	CPanel:AddControl( "Header", { Text = "#Tool_finger_name", Description	= "#Tool_finger_desc" }  )

end

for i=0, VarsOnHand do
	TOOL.ClientConVar[ ""..i ] = "0 0"
end


/*------------------------------------------------------------
	Name: RebuildControlPanel
	Desc: Rebuilds the context menu based on the current selected entity/hand
------------------------------------------------------------*/ 
function TOOL:RebuildControlPanel( hand )

	// We've selected a new entity - rebuild the controls list
	local CPanel = GetControlPanel( "finger" )
	if ( !CPanel ) then return end
	
	CPanel:ClearControls()
	
	self.BuildCPanel( CPanel )
	
	local Ent = self:HandEntity()
	if (!Ent || Ent == NULL) then return end
		
	local CVars = {}
	
	local Default = {}
	for i=0, VarsOnHand do
		table.insert( CVars, "finger_"..i )
		Default[ "finger_"..i ] = "0 0 0"
	end
	
	CPanel:AddControl( "ComboBox", { Label = "#Presets", 
									MenuButton = 1,
									Folder = "finger",
									CVars = CVars,
									Options = { default = Default }
									} )
	
	// Detect mitten hands
	local NumVars = table.Count( Ent.FingerIndex )
	
	CPanel:AddControl( "FingerPoser", { hand = hand, numvars = NumVars } )
	
	
	CPanel:AddControl( "Checkbox", { Label = "#Restrict Axis", Command = "finger_restrict" } )

end

local FacePoser	= surface.GetTextureID( "gui/faceposer_indicator" )

/*------------------------------------------------------------
	Name: DrawHUD
	Desc: Draw a circle around the selected hand
------------------------------------------------------------*/ 
function TOOL:DrawHUD()

	local selected = self:HandEntity()
	local hand = self:HandNum()
	
	if ( selected == NULL ) then return end
	if ( selected:IsWorld() ) then return end
	
	local Bone = nil
	
	local lefthand, righthand = self:GetHandPositions( selected )
	
	local BoneMatrix = lefthand
	if ( hand == 1 ) then BoneMatrix = righthand end
	if (!BoneMatrix) then return end
	
	local vPos = BoneMatrix:GetTranslation()
	
	local scrpos = vPos:ToScreen()
	if (!scrpos.visible) then return end
	
	// Work out the side distance to give a rough headsize box..
	local player_eyes = LocalPlayer():EyeAngles()
	local side = (vPos + player_eyes:Right() * 20):ToScreen()
	local size = math.abs( side.x - scrpos.x )
	
	surface.SetDrawColor( 255, 255, 255, 255 )
	surface.SetTexture( FacePoser )
	surface.DrawTexturedRect( scrpos.x-size, scrpos.y-size, size*2, size*2 )

end

/*------------------------------------------------------------
	Name: GetFingerBone
	Desc: Translate the fingernum, part and hand into an real bone number
------------------------------------------------------------*/ 
local function GetFingerBone( self, fingernum, part, hand )

	//// START HL2 BONE LOOKUP //////////////////////////////////
	local Name = "ValveBiped.Bip01_L_Finger"..fingernum
	if ( hand == 1 ) then Name = "ValveBiped.Bip01_R_Finger"..fingernum end
	if ( part != 0 ) then Name = Name .. part end

	local bone = self:LookupBone( Name )
	if ( bone ) then return bone end
	//// END HL2 BONE LOOKUP //////////////////////////////////
	
	
	//// START TF BONE LOOKUP //////////////////////////////////
	local TranslatedName = TranslateTable_TF2[ Name ]
	if ( TranslatedName ) then 
		local bone = self:LookupBone( TranslatedName )
		if ( bone ) then return bone end
	end
	//// END TF BONE LOOKUP //////////////////////////////////
	
	//// START Zeno BONE LOOKUP //////////////////////////////////
	local TranslatedName = TranslateTable_Zeno[ Name ]
	if ( TranslatedName ) then 
		local bone = self:LookupBone( TranslatedName )
		if ( bone ) then return bone end
	end
	//// END Zeno BONE LOOKUP //////////////////////////////////

end

/*------------------------------------------------------------
	Name: SetupFingers
	Desc: Cache the finger bone numbers for faster access
------------------------------------------------------------*/ 
local function SetupFingers( self )

	if ( self.FingerIndex ) then return end
		
	self.FingerIndex = {}

	local i = 1
	
	for hand = 0, 1 do
		for finger = 0, 4 do
			for part = 0, 2 do
				
				self.FingerIndex[ i ] = GetFingerBone( self, finger, part, hand )
				
				i = i + 1
			
			end
		end
	end

end

/*------------------------------------------------------------
	Name: DoBoneFingers
	Desc: This is what actually adjusts the rotation of each finger
------------------------------------------------------------*/  
function DoBoneFingers( self, numbones, numphysbones )

	local bIsTF2Model = HasTF2Hands( self )

	for k, v in pairs( self.FingerIndex ) do
			
		if ( v ) then
	
			local Rot = self:GetNetworkedAngle( "Finger".. k-1, false )
			if ( Rot ) then
										
				if ( k > VarsOnHand && !bIsTF2Model ) then
					Rot = Rot * 1
					Rot.p = Rot.p * -1
				end
				
				if ( bIsTF2Model ) then
					Rot = Rot * 1
					local old = { Rot.pitch, Rot.yaw, Rot.roll }
					Rot.pitch 	= 0
					Rot.yaw 	= old[1] * -1
					Rot.roll	= old[2] * -1
				end
				
				matBone = self:GetBoneMatrix( v )	
				matBone:Rotate( Rot )		
				self:SetBoneMatrix( v, matBone )
				
			end
			
		end
		
	end

end

/*------------------------------------------------------------
	OnNetworkFingersChanged	
------------------------------------------------------------*/   
local function OnNetworkFingersChanged( entity, name, oldval, newval )

	entity:InvalidateBoneCache()
	return newval

end


/*------------------------------------------------------------
	Name: AddFingersHook
	Desc: Adds the DoBoneFingers to the BuildBonePositions functib
------------------------------------------------------------*/  
local function AddFingersHook( ent )

	if ( !ent || !ent:IsValid() || ent:GetClass() != "prop_ragdoll" ) then return end
	
	SetupFingers( ent )
	
	for i=0, FingerVars do
		ent:SetNetworkedVarProxy( "Finger"..i, OnNetworkFingersChanged )
	end
	
	local CurrentFunction = ent.BuildBonePositions
	
	// This isn't perfect, but it's the best we can do right now.
	
	if ( CurrentFunction ) then
	
		ent.BuildBonePositions = 	function( self, numbones, numphysbones ) 
		
										CurrentFunction( self, numbones, numphysbones )
										DoBoneFingers( self, numbones, numphysbones )
										
									end
	else
	
		ent.BuildBonePositions = DoBoneFingers
	
	end
	
end

hook.Add( "OnEntityCreated", "AddFingersHook", AddFingersHook )