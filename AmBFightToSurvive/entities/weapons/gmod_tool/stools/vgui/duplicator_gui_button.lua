/*---------------------------------------------------------
   Name: Init
---------------------------------------------------------*/
function PANEL:Init()
	
	self.SpawnButton = vgui.Create( "DButton", self )
	
	self.DeleteButton = vgui.Create( "DImageButton", self )
	self.DeleteButton:SetMaterial( "gui/silkicons/exclamation" )
	self.DeleteButton:SetTooltip( "Remove" )
	
end

/*---------------------------------------------------------
   Name: SetText
---------------------------------------------------------*/
function PANEL:SetItemText( text )

	self.SpawnButton:SetText( text )

end

/*---------------------------------------------------------
   Name: SetID
---------------------------------------------------------*/
function PANEL:SetID( id )

	self.SpawnButton.DoClick = function() RunConsoleCommand( "tool_duplicator_select", id ) end
	self.DeleteButton.DoClick = function() RunConsoleCommand( "tool_duplicator_remove", id ) end

end

/*---------------------------------------------------------
   Name: PerformLayout
---------------------------------------------------------*/
function PANEL:PerformLayout()	

	self.DeleteButton.y = 3
	self.DeleteButton:SizeToContents()
	self.DeleteButton:AlignRight( 3 )
	
	self:SetTall( self.DeleteButton:GetTall() + 6 )
	
	self.SpawnButton:StretchToParent( 3, 3, 3, 3 )
	self.SpawnButton:StretchRightTo( self.DeleteButton, 3 )
	
end

/*---------------------------------------------------------
   Name: Paint
---------------------------------------------------------*/
function PANEL:Paint()

	draw.RoundedBox( 4, 0, 0, self:GetWide(), self:GetTall(), Color( 0, 0, 0, 150 ) )
	return false

end
