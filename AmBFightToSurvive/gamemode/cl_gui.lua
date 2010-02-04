FS = FS or {}
TeamOwner = 0

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


function ShowTeamOptions()

    DermaFrame = vgui.Create( "DFrame" )
        DermaFrame:SetSize( (200+10+10)+(200+10+10), 500 )
        DermaFrame:SetTitle( "Team Options" )
        DermaFrame:SetVisible( true )
        DermaFrame:SetDraggable( false )
        DermaFrame:ShowCloseButton( true )
        DermaFrame:SetDeleteOnClose( true )
        DermaFrame:MakePopup()
        DermaFrame:Center()
    
    local YSpacing = 20
    local Y = 24
    
    TeamNameLabel = vgui.Create("DLabel", DermaFrame)
        TeamNameLabel:SetText("Team name")
        TeamNameLabel:SetPos( 10, Y )
    Y = Y + YSpacing
    
    TeamName = vgui.Create("DTextEntry", DermaFrame)
        TeamName:SetPos( 10,Y )
        TeamName:SetSize( 200,20 )
    Y = Y + YSpacing
    
    TeamPasswordLabel = vgui.Create("DLabel", DermaFrame)
        TeamPasswordLabel:SetText("Password")
        TeamPasswordLabel:SetPos( 10, Y )
    Y = Y + YSpacing
    
    TeamPassword = vgui.Create("DTextEntry", DermaFrame)
        TeamPassword:SetPos( 10,Y )
        TeamPassword:SetSize( 200,20 )
    Y = Y + YSpacing+10
    
    TeamColor = vgui.Create("DColorMixer", DermaFrame)
        TeamColor:SetPos( 20,Y )
        TeamColor:SetSize( 200,125 )
    Y = Y + YSpacing + 125
    
    TeamOpen = vgui.Create("DCheckBoxLabel", DermaFrame)
        TeamOpen:SetPos( 10,Y )
        TeamOpen:SetSize( 200, 20 )
        TeamOpen:SetText("Open Team (no password)")
    Y = Y + YSpacing+10
    
    
    local CreateEdit = "Create"
    self = LocalPlayer()
    for k,Team in pairs( Teams ) do
        if Team.Owner && ValidEntity( Team.Owner ) then
            if Team.Owner == self then
                TeamOwner = k
                CreateEdit = "Edit"
                TeamName:SetText( Team.Name or "" )
                TeamColor:SetColor( Team.Color )
                TeamOpen:SetValue( false )
                break
            end
        end
    end
    
    
    TeamButton = vgui.Create("DButton", DermaFrame)
        TeamButton:SetSize(200, 20)
        TeamButton:SetPos( 10,Y )
        TeamButton:SetText( CreateEdit .. " Team" )
        TeamButton.DoClick = function() 
			Col = TeamColor:GetColor()
			//print( "makeeditteam " .. tostring(TeamOwner) .. " " .. TeamName:GetValue() .. " " .. TeamPassword:GetValue() .. " " .. Col.r .. " " .. Col.g .. " " .. Col.b .. " " .. TeamOpen:GetChecked(true) )
			Teams[TeamOwner] = Teams[TeamOwner] or {}
			Teams[TeamOwner].Password = TeamPassword:GetValue() 
			RunConsoleCommand("makeeditteam", TeamOwner, TeamName:GetValue(), TeamPassword:GetValue(), Col.r, Col.g, Col.b, TeamOpen:GetChecked(true))
			DermaFrame:Close()
        end
    Y = Y + YSpacing+10
    DermaFrame:SetSize( (200+10+10)+(200+10+10), Y )
    
    local TotYSize = Y
    Y = 24 + 10
    X = (200+10+10)
    
	JoinTeamLabel = vgui.Create("DLabel", DermaFrame)
		JoinTeamLabel:SetText("Join Team")
		JoinTeamLabel:SetPos( X+10, Y-10 )
    
	TeamsList = vgui.Create("DListView", DermaFrame)
		TeamsList:SetPos(X+10, Y+10)
        TeamsList:SetSize(200, TotYSize - 20 - 24 - 10 -40)
        TeamsList:SetMultiSelect(false)
        TeamsList:AddColumn("Name") -- Add colu`mn
        TeamsList:AddColumn("Owner")
    
    LeaveButton = vgui.Create("DButton", DermaFrame)
        LeaveButton:SetSize(200, 20)
        LeaveButton:SetPos( X+10, TotYSize - 30 )
        LeaveButton:SetText( "Leave Team" )
        LeaveButton.DoClick = function() RunConsoleCommand("jointeam","1") end
    
    for k,Team in pairs( Teams ) do
        local Name,Owner = Team.Name or "",Team.Owner
        if Owner && ValidEntity( Owner ) then
            TeamsList:AddLine( Name, Owner:Name() ).TeamID = k
        end
    end
    
    TeamsList.DoDoubleClick = function(parent, index, list)
        ID = list.TeamID or 1
        DermaFrame:Close()
        
        if Teams[ID].Open == 1 then RunConsoleCommand("jointeam",ID) return end
                
        PasswordBox = vgui.Create( "DFrame" )
            PasswordBox:SetSize( 200,70 )
            PasswordBox:SetTitle( "Enter the password" )
            PasswordBox:SetVisible( true )
            PasswordBox:SetDraggable( false )
            PasswordBox:ShowCloseButton( true )
            PasswordBox:SetDeleteOnClose(true)
            PasswordBox:MakePopup()
            PasswordBox:Center()
        
        Password = vgui.Create("DTextEntry", PasswordBox)
            Password:SetPos( 10,24+10 )
            Password:SetSize( 200-20,24 )
            Password.OnEnter = function()
                RunConsoleCommand("jointeam",ID, Password:GetValue())
                PasswordBox:Close()
            end
    end

end

function f2sPlayerBindPress(pl,bind,p)
	if bind == "gm_showteam" then ShowTeamOptions() end
end
hook.Add("PlayerBindPress", "f2s.bind",f2sPlayerBindPress)

//concommand.Add("gm_showteam", ShowTeamOptions)
//ShowTeamOptions()
//hook.Add( "ShowTeamOptions", "f2s.ShowTeamOptions", ShowTeamOptions )


