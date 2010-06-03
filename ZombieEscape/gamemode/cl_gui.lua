concommand.Add( "ze_wepmenu", function()

	local vipslot4
	local vipslot3
	local vipslot2
	local DLabel4
	local vipslot1
	local vipPannel
	local DLabel3
	local grenade
	local flashbang
	local fiveseven
	local deagle
	local glock
	local shotgun
	local mac10
	local para
	local tmp
	local mp5
	local DLabel2
	local secondWepPannel
	local m4
	local ak
	local mainWepPannel
	local SpawnWeps
	
	SpawnWeps = vgui.Create('DFrame')
	SpawnWeps:SetSize(430, 350)
	SpawnWeps:SetPos(0, 20)
	SpawnWeps:SetTitle('Select Spawn Weapons')
	SpawnWeps:SetSizable(true)
	SpawnWeps:SetDeleteOnClose(false)
	SpawnWeps:MakePopup()
	
	mainWepPannel = vgui.Create('DPanel',SpawnWeps)
	mainWepPannel:SetSize(150, 290)
	mainWepPannel:SetPos(10, 70)

	secondWepPannel = vgui.Create('DPanel',SpawnWeps)
	secondWepPannel:SetSize(150, 290)
	secondWepPannel:SetPos(170, 70)
	
	vipPannel = vgui.Create('DPanel',SpawnWeps)
	vipPannel:SetSize(80, 290)
	vipPannel:SetPos(340, 70)
	
	/////
	
	
	
	vipslot4 = vgui.Create('SpawnIcon',vipPannel)
	vipslot4:SetPos(350, 290)
	vipslot4:SetToolTip('VIP 4')
	vipslot4.OnMousePressed = function() Slot(3,4) end

	vipslot3 = vgui.Create('SpawnIcon',vipPannel)
	vipslot3:SetPos(350, 220)
	vipslot3:SetToolTip('VIP 3')
	vipslot3.OnMousePressed = function() Slot(3,3) end

	vipslot2 = vgui.Create('SpawnIcon',vipPannel)
	vipslot2:SetPos(350, 150)
	vipslot2:SetToolTip('VIP 2')
	vipslot2.OnMousePressed = function() Slot(3,2) end

	DLabel4 = vgui.Create('DLabel',SpawnWeps)
	DLabel4:SetPos(360, 50)
	DLabel4:SetText('VIP Slot')
	DLabel4:SizeToContents()

	vipslot1 = vgui.Create('SpawnIcon',vipPannel)
	vipslot1:SetPos(350, 80)
	vipslot1:SetToolTip('VIP 1')
	vipslot1.OnMousePressed = function() Slot(3,1) end



	DLabel3 = vgui.Create('DLabel',SpawnWeps)
	DLabel3:SetPos(190, 50)
	DLabel3:SetText('Secondary Weapon')
	DLabel3:SizeToContents()

	grenade = vgui.Create('SpawnIcon',secondWepPannel)
	grenade:SetPos(180, 220)
	grenade:SetToolTip('HE Grenade')
	grenade.OnMousePressed = function() Slot(2,5) end
	grenade:SetModel('models/weapons/w_eq_fraggrenade.mdl')

	flashbang = vgui.Create('SpawnIcon',secondWepPannel)
	flashbang:SetPos(250, 150)
	flashbang:SetToolTip('Flashbang')
	flashbang.OnMousePressed = function() Slot(2,4) end
	flashbang:SetModel('models/weapons/w_eq_flashbang.mdl')

	fiveseven = vgui.Create('SpawnIcon',secondWepPannel)
	fiveseven:SetPos(180, 150)
	fiveseven:SetToolTip('Five Seven')
	fiveseven.OnMousePressed = function() Slot(2,3) end
	fiveseven:SetModel('models/weapons/w_pist_fiveseven.mdl')

	deagle = vgui.Create('SpawnIcon',secondWepPannel)
	deagle:SetPos(250, 80)
	deagle:SetToolTip('Desert Eagle')
	deagle.OnMousePressed = function() Slot(2,2) end
	deagle:SetModel('models/weapons/w_pist_deagle.mdl')

	glock = vgui.Create('SpawnIcon',secondWepPannel)
	glock:SetPos(180, 80)
	glock:SetToolTip('Glock-18')
	glock.OnMousePressed = function() Slot(2,1) end
	glock:SetModel('models/weapons/w_pist_glock18.mdl')

	shotgun = vgui.Create('SpawnIcon',mainWepPannel)
	shotgun:SetPos(20, 290)
	shotgun:SetToolTip('Shotgun')
	shotgun.OnMousePressed = function()  Slot(1,7) end
	shotgun:SetModel('models/weapons/w_shot_m3super90.mdl')

	mac10 = vgui.Create('SpawnIcon',mainWepPannel)
	mac10:SetPos(90, 220)
	mac10:SetToolTip('Mac-10')
	mac10.OnMousePressed = function() Slot(1,6)  end
	mac10:SetModel('models/weapons/w_smg_mac10.mdl')

	para = vgui.Create('SpawnIcon',mainWepPannel)
	para:SetPos(20, 220)
	para:SetToolTip('M249')
	para.OnMousePressed = function()  Slot(1,5) end
	para:SetModel('models/weapons/w_mach_m249para.mdl')

	tmp = vgui.Create('SpawnIcon',mainWepPannel)
	tmp:SetPos(90, 150)
	tmp:SetToolTip('TMP')
	tmp.OnMousePressed = function()  Slot(1,4) end
	tmp:SetModel('models/weapons/w_smg_mp5.mdl')

	mp5 = vgui.Create('SpawnIcon',mainWepPannel)
	mp5:SetPos(20, 150)
	mp5:SetToolTip('MP5')
	mp5.OnMousePressed = function() Slot(1,3)  end
	mp5:SetModel('models/weapons/w_smg_mp5.mdl')

	DLabel2 = vgui.Create('DLabel',SpawnWeps)
	DLabel2:SetPos(50, 50)
	DLabel2:SetText('Main Weapon')
	DLabel2:SizeToContents()
	
	m4 = vgui.Create('SpawnIcon',mainWepPannel)
	m4:SetPos(90, 80)
	m4:SetToolTip('M4A1')
	m4.OnMousePressed = function()  Slot(1,2) end
	m4:SetModel('models/weapons/w_rif_m4a1.mdl')

	ak = vgui.Create('SpawnIcon',mainWepPannel)
	ak:SetPos(20, 80)
	ak:SetToolTip('AK-47')
	ak.OnMousePressed = function() Slot(1,1) end
	ak:SetModel('models/weapons/w_rif_ak47.mdl')

end)

function Slot(slot,id)
	RunConsoleCommand("ze_setslot",slot,id)
end