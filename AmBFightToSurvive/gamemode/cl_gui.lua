FS = FS or {}
TeamOwner = 0

function FS.ShowHelp(um)
	local DermaFrame = vgui.Create( "DFrame" )
    DermaFrame:SetPos( 100,100 )
    local w,h = 640,640
    DermaFrame:SetSize( w,h )
    DermaFrame:SetTitle( "Fight To Survive Help" )
    DermaFrame:SetVisible( true )
    DermaFrame:SetDraggable( true )
    DermaFrame:ShowCloseButton( true )
    DermaFrame:SetDeleteOnClose(false)
    DermaFrame:MakePopup()
    DermaFrame:Center()

    HTML = vgui.Create("HTML", DermaFrame)
    HTML:SetPos(10,10+24)
    HTML:SetSize(w-20,h-20-24)
    HTML:OpenURL( um:ReadString() )
end
usermessage.Hook( "help_info", FS.ShowHelp )
concommand.Add("setspawnclass", function() RunConsoleCommand("openhelp") end)


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
			local open = 0
			if TeamOpen:GetChecked(true) then open = 1 end
			//print( "makeeditteam " .. tostring(TeamOwner) .. " " .. TeamName:GetValue() .. " " .. TeamPassword:GetValue() .. " " .. Col.r .. " " .. Col.g .. " " .. Col.b .. " " .. TeamOpen:GetChecked(true) )
			Teams[TeamOwner] = Teams[TeamOwner] or {}
			Teams[TeamOwner].Password = TeamPassword:GetValue()
			RunConsoleCommand("makeeditteam", TeamOwner, TeamName:GetValue(), TeamPassword:GetValue(), Col.r, Col.g, Col.b, open)
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


