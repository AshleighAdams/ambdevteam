

ENT.Type = "anim"
ENT.Base = "base_gmodentity"

ENT.PrintName		= ""
ENT.Author			= ""
ENT.Contact			= ""
ENT.Purpose			= ""
ENT.Instructions	= ""

function ENT:SetupDataTables()

	self:DTVar( "Int", 0, "Key" );
	self:DTVar( "Bool", 0, "On" );

end

function ENT:SetKey( key )
	self.dt.Key = key
end
function ENT:GetKey()
	return self.dt.Key
end


function ENT:SetOn( bOn )
	self.dt.On = bOn
end
function ENT:IsOn()
	return self.dt.On
end


function ENT:SetLabel( text )

	text = string.gsub( text, "\\", "" )
	text = string.sub( text, 0, 20 )
	
	if ( text != "" ) then
	
		text = "\""..text.."\""
	
	end
	
	self:SetOverlayText( text )
	
end
function ENT:GetLabel()
	self:GetVar( "Label", "" )
end


function ENT:GetPlayer()
	return self:GetVar( "Founder", NULL )
end
function ENT:GetPlayerIndex()
	return self:GetVar( "FounderIndex", 0 )
end
