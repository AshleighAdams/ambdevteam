
local gmod_drawhelp = CreateClientConVar( "gmod_drawhelp", "1", true, false )
gmod_toolmode = CreateClientConVar( "gmod_toolmode", "rope", true, true )

include('shared.lua')
include('cl_viewscreen.lua')

SWEP.PrintName			= "Tool Gun"			
SWEP.Slot				= 5	
SWEP.SlotPos			= 6	
SWEP.DrawAmmo			= false
SWEP.DrawCrosshair		= true

SWEP.Spawnable			= false
SWEP.AdminSpawnable		= false

SWEP.WepSelectIcon		= surface.GetTextureID( "vgui/gmod_tool" )
SWEP.Gradient			= surface.GetTextureID( "gui/gradient" )
SWEP.InfoIcon			= surface.GetTextureID( "gui/info" )

SWEP.ToolNameHeight		= 0
SWEP.InfoBoxHeight		= 0

surface.CreateFont( "coolvetica", 48, 1000, true, false, "GModToolName" )
surface.CreateFont( "coolvetica", 24, 500, true, false, "GModToolSubtitle" )
surface.CreateFont( "coolvetica", 19, 500, true, false, "GModToolHelp" )


/*---------------------------------------------------------
	Draws the help on the HUD (disabled if gmod_drawhelp is 0)
---------------------------------------------------------*/
function SWEP:DrawHUD()

	if ( !gmod_drawhelp:GetBool() ) then return end
	
	local mode = gmod_toolmode:GetString()
	
	// Don't draw help for a nonexistant tool!
	if ( !self:GetToolObject() ) then return end
	
	self:GetToolObject():DrawHUD()
	
	
	// This could probably all suck less than it already does
	
	
	local x, y = 50, 40
	local w, h = 0, 0
	
	local TextTable = {}
	local QuadTable = {}
	
	QuadTable.texture 	= self.Gradient
	QuadTable.color		= Color( 10, 10, 10, 120 )
	
	QuadTable.x = 0
	QuadTable.y = y-8
	QuadTable.w = 600
	QuadTable.h = self.ToolNameHeight - (y-8)
	draw.TexturedQuad( QuadTable )
	
	TextTable.font = "GModToolName"
	TextTable.color = Color( 240, 240, 240, 255 )
	TextTable.pos = { x, y }
	TextTable.text = "#Tool_"..mode.."_name"
	
	w, h = draw.TextShadow( TextTable, 3 )
	y = y + h
	

	TextTable.font = "GModToolSubtitle"
	TextTable.pos = { x, y }
	TextTable.text = "#Tool_"..mode.."_desc"
	w, h = draw.TextShadow( TextTable, 2 )
	y = y + h + 8
	
	self.ToolNameHeight = y
	
	y = y + 1
	
	QuadTable.x = 0
	QuadTable.y = y
	QuadTable.w = 600
	QuadTable.h = self.InfoBoxHeight
	local alpha =  math.Clamp( 255 + (self:GetToolObject().LastMessage - CurTime())*800, 10, 255 )
	QuadTable.color = Color( alpha, alpha, alpha, 140 )
	draw.TexturedQuad( QuadTable )
		
	y = y + 2
	
	TextTable.font = "GModToolHelp"
	TextTable.pos = { x + self.InfoBoxHeight, y  }
	TextTable.text = "#Tool_"..mode.."_"..self:GetToolObject():GetStage()
	w, h = draw.TextShadow( TextTable, 2 )
	
	surface.SetDrawColor( 255, 255, 255, 255 )
	surface.SetTexture( self.InfoIcon )
	surface.DrawTexturedRect( x+1, y+1, h-3, h-3 )	
	
	self.InfoBoxHeight = h + 4
	
end

function SWEP:SetStage( ... )

	if ( !self:GetToolObject() ) then return end
	return self:GetToolObject():SetStage( ... )
	
end

function SWEP:GetStage( ... )

	if ( !self:GetToolObject() ) then return end
	return self:GetToolObject():GetStage( ... )
	
end

function SWEP:ClearObjects( ... )

	if ( !self:GetToolObject() ) then return end
	self:GetToolObject():ClearObjects( ... )
	
end

function SWEP:StartGhostEntities( ... )

	if ( !self:GetToolObject() ) then return end
	self:GetToolObject():StartGhostEntities( ... )
	
end

function SWEP:PrintWeaponInfo( x, y, alpha )	
end

function SWEP:FreezeMovement()

	local mode = self:GetMode()
	
	if ( !self:GetToolObject() ) then return false end
	
	return self:GetToolObject():FreezeMovement()
	
end
