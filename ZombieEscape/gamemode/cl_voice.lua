local PANEL = {}

Derma_Hook( PANEL, 	"Paint", 				"Paint", 	"VoiceNotify" )
Derma_Hook( PANEL, 	"ApplySchemeSettings", 	"Scheme", 	"VoiceNotify" )
Derma_Hook( PANEL, 	"PerformLayout", 		"Layout", 	"VoiceNotify" )
	
function PANEL:Init()

	self.LabelName = vgui.Create( "DLabel", self )
	self.Avatar = vgui.Create( "AvatarImage", self )

end

function PANEL:Setup( ply )

	self.LabelName:SetText( ply:Nick() )
	self.Avatar:SetPlayer( ply )
	
	self.Color = team.GetColor( ply:Team() )
	
	self:InvalidateLayout()

end

derma.DefineControl( "VoiceNotify", "", PANEL, "DPanel" )

local PlayerVoicePanels = {}

function GM:PlayerStartVoice( ply )

	if (!IsValid( g_VoicePanelList ) ) then return end
	
	// There'd be an exta one if voice_loopback is on, so remove it.
	GAMEMODE:PlayerEndVoice( ply )

	local pnl = vgui.Create( "VoiceNotify" )
	pnl:Setup( ply )
	
	g_VoicePanelList:AddItem( pnl )
	
	PlayerVoicePanels[ ply ] = pnl
	
end


local function VoiceClean()

	for k, v in pairs( PlayerVoicePanels ) do
	
		if ( !IsValid( k ) ) then
			GAMEMODE:PlayerEndVoice( k )
		end
	
	end

end

timer.Create( "VoiceClean", 10, 0, VoiceClean )


function GM:PlayerEndVoice( ply )
	
	if ( IsValid( PlayerVoicePanels[ ply ] ) ) then
		g_VoicePanelList:RemoveItem( PlayerVoicePanels[ ply ] )
		PlayerVoicePanels[ ply ]:Remove()
		PlayerVoicePanels[ ply ] = nil
	end
	
end


local function CreateVoiceVGUI()

	g_VoicePanelList = vgui.Create( "DPanelList" )

	g_VoicePanelList:ParentToHUD()
	
	g_VoicePanelList:SetPos( ScrW() - 250, 100 )
	g_VoicePanelList:SetSize( 200, ScrH() - 200 )
	
	g_VoicePanelList:SetDrawBackground( false )
	g_VoicePanelList:SetSpacing( 8 )
	g_VoicePanelList:SetBottomUp( true )

end

hook.Add( "InitPostEntity", "CreateVoiceVGUI", CreateVoiceVGUI )