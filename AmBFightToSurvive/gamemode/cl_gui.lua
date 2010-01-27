FS = FS or {}

function FS.ShowSpawnMenu() ---- bad name <<, the spawn class
	local DermaFrame = vgui.Create( "DFrame" )
	DermaFrame:SetPos( 100,100 )
	DermaFrame:SetSize( 320, 180 )
	DermaFrame:SetTitle( "Set Your Class" )
	DermaFrame:SetVisible( true )
	DermaFrame:SetDraggable( true )
	DermaFrame:ShowCloseButton( true )
	DermaFrame:SetDeleteOnClose(false)
	DermaFrame:MakePopup()
	DermaFrame:Center()

	local Weapon1 = vgui.Create( "DComboBox", DermaFrame )
	Weapon1:SetPos( 10, 35 )
	Weapon1:SetSize( 100, 100 )
	Weapon1:SetMultiple( false ) 
	Weapon1:AddItem( "weapon_ar2" )
	Weapon1:AddItem( "weapon_crossbow" )
	Weapon1:AddItem( "weapon_smg1" )
	Weapon1:AddItem( "weapon_rpg" )
	
	local Weapon2 = vgui.Create( "DComboBox", DermaFrame )
	Weapon2:SetPos( 110, 35 )
	Weapon2:SetSize( 100, 100 )
	Weapon2:SetMultiple( false ) 
	Weapon2:AddItem( "weapon_shotgun" ) 
	Weapon2:AddItem( "weapon_357" )
	Weapon2:AddItem( "weapon_pistol" )
	
	local Weapon3 = vgui.Create( "DComboBox", DermaFrame )
	Weapon3:SetPos( 210, 35 )
	Weapon3:SetSize( 100, 100 )
	Weapon3:SetMultiple( false )
	Weapon3:AddItem( "weapon_frag" )
	Weapon3:AddItem( "weapon_slam" )
	Weapon3:AddItem( "weapon_physcannon" )
	
	local SetClass = vgui.Create( "DButton" )
	SetClass:SetParent( DermaFrame )
	SetClass:SetText( "Set Your Class" )
	SetClass:SetPos( 10, 145 )
	SetClass:SetSize( 100, 20 )
	SetClass.DoClick = function ()
		
		local w1,w2,w3 = ""
		w1 = Weapon1:GetSelectedItems()[1]:GetValue()
		w2 = Weapon2:GetSelectedItems()[1]:GetValue()
		w3 = Weapon3:GetSelectedItems()[1]:GetValue()
		local comma = ","
		LocalPlayer():ConCommand("sv_cl_setw " .. w1 .. comma .. w2 .. comma .. w3 )
		DermaFrame:Close()
		print("Weapons Set")
		--w1,w2,w3
	
	end
	

end

concommand.Add("setspawnclass", FS.ShowSpawnMenu)

