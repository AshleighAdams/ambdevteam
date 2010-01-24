
local pnldef_DupeButton = vgui.RegisterFile( "duplicator_gui_button.lua" )

PANEL.VoteName = "none"
PANEL.MaterialName = "exclamation"

/*---------------------------------------------------------
   Name: 
---------------------------------------------------------*/
function PANEL:Init()

	self.NewName = vgui.Create( "DTextEntry", self )
	self.NewName:SetKeyboardInputEnabled( true )
	self.NewName:SetEnabled( true )
	
	self.StoreButton = vgui.Create( "DImageButton", self )
	self.StoreButton:SetMaterial( "gui/silkicons/add" )
	self.StoreButton:SetTooltip( "#Store" )
	self.StoreButton.DoClick = function() self:OnStore() end
	
	self.List = vgui.Create( "PanelList", self )
	self.List:SetSpacing( 1 )
	
	self.DuplicateList = {}
	
end

/*---------------------------------------------------------
   Name: OnStore
---------------------------------------------------------*/
function PANEL:OnStore()
	
	RunConsoleCommand( "tool_duplicator_store", self.NewName:GetValue() )
	
end

/*---------------------------------------------------------
   Name: PerformLayout
---------------------------------------------------------*/
function PANEL:PerformLayout()	

	self:SetTall( 500 )

	self.StoreButton:SizeToContents()
	self.StoreButton:AlignRight( 5 )
	self.StoreButton:AlignBottom()
	
	self.NewName:SetTall( self.StoreButton:GetTall() )
	self.NewName:AlignLeft( 5 );	
	self.NewName:AlignBottom();	
	self.NewName:StretchRightTo( self.StoreButton, 4 );	
	
	self.List:StretchToParent( 0, 0, 0, 0 )
	self.List:StretchBottomTo( self.StoreButton, 4 )

end

/*---------------------------------------------------------
   Name: Clear
---------------------------------------------------------*/
function PANEL:Clear( )

	self.DuplicateList = {}

end

/*---------------------------------------------------------
   Name: Populate
---------------------------------------------------------*/
function PANEL:Add( id, name )

	self.DuplicateList[ id ] = name

end

/*---------------------------------------------------------
   Name: Populate
---------------------------------------------------------*/
function PANEL:Populate()

	self.List:Clear()

	for k, v in pairs( self.DuplicateList ) do
	
		local Button = vgui.CreateFromTable( pnldef_DupeButton, self )
		Button:SetItemText( v )
		Button:SetID( k )
		self.List:AddItem( Button )
	
	end
	
end
