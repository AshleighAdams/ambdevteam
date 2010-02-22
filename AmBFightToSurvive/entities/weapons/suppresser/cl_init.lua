
include('shared.lua')

SWEP.PrintName			= "Suppreser"			
SWEP.Slot				= 4
SWEP.SlotPos			= 3
SWEP.DrawAmmo			= false
SWEP.DrawCrosshair		= false

/*---------------------------------------------------------
	ViewModelDrawn
---------------------------------------------------------*/
function SWEP:ViewModelDrawn()
	
end


function SWEP:DrawHUD()
	local x = ScrW() / 2.0
	local y = ScrH() * 0.8
	local xalign = TEXT_ALIGN_CENTER
	local yalign = TEXT_ALIGN_CENTER
	local font = "Default"
	local diff = 15
	local color = Color(255, 255, 255, 255)
	local power = tostring( self.Power ) or 0
	draw.SimpleText("Power: " .. power, font, x, y + (diff * 0), color, xalign, yalign)
	draw.SimpleText("Hold Mouse 2", font, x, y + (diff * 1), color, xalign, yalign)
	draw.SimpleText("and move mouse up and down", font, x, y + (diff * 2), color, xalign, yalign)
	draw.SimpleText("to control the power.", font, x, y + (diff * 3), color, xalign, yalign)
end
