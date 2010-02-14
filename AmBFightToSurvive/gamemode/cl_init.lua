Teams = Teams or {}
include( 'shared.lua' )
include( 'shared_trace.lua' )
include( 'cl_store.lua' )
include( 'shared_store_items.lua' )
include( 'shared_disable.lua' )
include( 'cl_gui.lua' )
include( 'cl_scoreboard.lua' )
include( 'cl_damageoverlay.lua' )
include( 'cl_recource_systems.lua' )
include( 'cl_prop.lua' )
include( 'cl_map.lua' )

require( "datastream" )

BindLog = BindLog or {}

language.Add( "worldspawn", "Slipt And Fell" )
language.Add( "prop_physics", "Zooming Prop" )
language.Add( "func_door", "Door" )
language.Add( "trigger_hurt", "Mystic Force" )

r = 0

function GM:CalcView(ply,pos,ang,fov)
	local rag = ply:GetRagdollEntity()
	if ValidEntity(rag) then
		local att = rag:GetAttachment(rag:LookupAttachment("eyes"))
		return self.BaseClass:CalcView(ply,att.Pos,att.Ang,fov)
	end
	return self.BaseClass:CalcView(ply,pos,ang,fov)
end

 
function UpdateTeamStats( um )
	local Index = um:ReadLong()
	local Name = um:ReadString()
	local Col = um:ReadVector()
	local Owner = um:ReadEntity()
	local Open = um:ReadLong()
	RealCol = Color(Col.x, Col.y, Col.z, 255)
	Teams[Index] = {}
	Teams[Index].Name = Name
	Teams[Index].Color = RealCol
	Teams[Index].Owner = Owner
	Teams[Index].Open = Open
	team.SetUp( Index, Name, RealCol )
end
usermessage.Hook("teamstats", UpdateTeamStats)

function ShowSpawnMenu()
	local dontspawn_enemydist = 3000
	if OpenMap(true) then
		for k,ref in pairs( ents.FindByClass("refinery") ) do
			if ref.Team == LocalPlayer():Team() then
				r = ref:EntIndex()
				ref.MapPoint:AttachClickHook( function(point)
					RunConsoleCommand("selected_spawn_point", r)
					CloseMap()
					return true
				end)
				
				
				
			end
		end
	else
		local frame = vgui.Create("DFrame")
		frame:SetSize(200, 200)
		frame:Center()
		frame:SetTitle("Pick your spawn point")
		frame:SetDraggable(false)
		frame:ShowCloseButton(true)
		frame:MakePopup()
		
		local spawns = vgui.Create("DListView")
		spawns:SetParent(frame)
		spawns:SetPos(10, 24)
		spawns:SetSize( 200-10-10, 200-10-24 )
		spawns:SetMultiSelect(false)
		spawns:AddColumn("Spawn Name")
		
		spawns:AddLine("Default").OnSelect = function()
			RunConsoleCommand("selected_spawn_point", "def")
			frame:Close()
		end
		
		spawns:AddLine("Tatical Insertion").OnSelect = function()
			RunConsoleCommand("selected_spawn_point", "ti")
			frame:Close()
		end
		
		local dontspawn_enemydist = 3000
		for k,ref in pairs( ents.FindByClass("refinery") ) do
			local spawnok = true
			for i,ply in pairs( ents.FindInSphere( ref:GetPos(), dontspawn_enemydist ) ) do
				if ply:IsPlayer() then
					if ply:Team() != ref.Team && ply:Team()>1 then spawnok = false end
				end
			end
			
			if ref.Team == LocalPlayer():Team() && spawnok then
				spawns:AddLine("Refinery: " .. k).OnSelect = function()
					frame:Close()
					RunConsoleCommand("selected_spawn_point", k)
				end
			end
		end
	end
end
usermessage.Hook( "show_spawn_menu", ShowSpawnMenu )

function ReqTeamInfo( ply )
 
	timer.Simple(5,function(pl) pl:ConCommand("f2s_reqteaminfo") end,ply)
 
end
hook.Add( "PlayerInitialSpawn", "f2s.ReqTeamInfo", ReqTeamInfo )




function SaveKeyBinds(pl,bind,pressed)
	if !table.HasValue( BindLog, bind ) then
		table.insert( BindLog, bind )
	end
end
hook.Add("PlayerBindPress", "f2s.stophax", SaveKeyBinds)

function SendBindLog(um)
	pl=um:ReadEntity()
	local tblToSend = {pl}
	table.Add( tblToSend, BindLog )
	datastream.StreamToServer( "BindLogs", tblToSend )
end
usermessage.Hook("sendbindinfo",SendBindLog)

function ShowBinds(um)
	local bind = um:ReadString()
	Derma_Message(bind)
end
usermessage.Hook("player_keybinds",ShowBinds)