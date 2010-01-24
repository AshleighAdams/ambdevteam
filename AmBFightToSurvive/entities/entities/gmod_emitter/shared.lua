

ENT.Type 				= "anim"
ENT.Base 				= "base_gmodentity"

ENT.PrintName			= ""
ENT.Author				= ""
ENT.Contact				= ""
ENT.Purpose				= ""
ENT.Instructions		= ""

ENT.Spawnable			= false
ENT.AdminSpawnable		= false


function ENT:SetupDataTables()

	self:DTVar( "Float", 0, "Delay" );
	self:DTVar( "Bool", 0, "Toggle" );
	self:DTVar( "Bool", 1, "On" );

end


/*---------------------------------------------------------
   Effect
---------------------------------------------------------*/
function ENT:SetEffect( name )
	self:SetNetworkedString( "Effect", name )
end
function ENT:GetEffect()
	return self:GetNetworkedString( "Effect" )
end



/*---------------------------------------------------------
   Delay
---------------------------------------------------------*/
function ENT:SetDelay( f )
	self.dt.Delay = f
end
function ENT:GetDelay()
	return self.dt.Delay
end


/*---------------------------------------------------------
   Delay
---------------------------------------------------------*/
function ENT:SetToggle( b )
	self.dt.Toggle = b
end
function ENT:GetToggle()
	return self.dt.Toggle
end


/*---------------------------------------------------------
   On
---------------------------------------------------------*/
function ENT:SetOn( b )
	self.dt.On = b
end
function ENT:GetOn()
	return self.dt.On
end



/*---------------------------------------------------------
   Effect registration
---------------------------------------------------------*/

ENT.Effects				= {}

function ENT:AddEffect( name, func, nicename )

	self.Effects[ name ] = func
	
	if (CLIENT) then
	
		// Maintain a global reference for these effects
		ComboBox_Emitter_Options = ENT.Effects
		language.Add( "emitter_"..name, nicename )
		
	end

end


/*---------------------------------------------------------
   Modular effect adding.. stuff
---------------------------------------------------------*/
local effects = file.FindInLua( "entities/gmod_emitter/fx_*.lua" )
for key, val in pairs( effects ) do

	AddCSLuaFile( val )
	
	if ( CLIENT ) then
		include( val )
	end
	
end
