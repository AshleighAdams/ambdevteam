local StoreWidth = 800
local StoreHeight = 600
local StoreKey = KEY_F4

include("shared_store.lua")

local AutoItems = { }

local StoreFrame = nil
local KeyDown = false
--------------------------------------------
-- Opens the store, making it available for
-- the player.
--------------------------------------------
function OpenStore()
	local scrw = ScrW()
	local scrh = ScrH()
	
	-- Main frame used for the store
	local storeframe = vgui.Create("DFrame")
	storeframe:SetSize(StoreWidth, StoreHeight)
	storeframe:SetPos((scrw / 2.0) - (StoreWidth / 2.0), (scrh / 2.0) - (StoreHeight / 2.0))
	storeframe:SetTitle("The Store")
	storeframe:SetDraggable(false)
	storeframe:ShowCloseButton(false)
	local titlesize = 24
	
	-- Purchase on the left
	local purchasebutton = vgui.Create("DButton")
	local buttondown = 500
	purchasebutton:SetParent(storeframe)
	purchasebutton:SetText("Purchase")
	purchasebutton:SetPos(StoreWidth / 3.0 * 2.0, titlesize + buttondown)
	purchasebutton:SetSize(StoreWidth / 3.0, StoreHeight - buttondown - titlesize)
	local checkauto = vgui.Create("DCheckBoxLabel")
	checkauto:SetParent(storeframe)
	checkauto:SetText("Automatically buy on spawn")
	checkauto:SetValue(0)
	checkauto:SetPos(StoreWidth / 3.0 * 2.0, titlesize + buttondown - 20)
	checkauto:SetSize(StoreWidth / 3.0, 20)
	function set_item(Item)
		purchasebutton.DoClick = function()
			Item:Purchase()
		end
		checkauto.OnChange = function() end
		if AutoItems[Item] then
			checkauto:SetValue(1)
		else
			checkauto:SetValue(0)
		end
		checkauto.OnChange = function()
			if checkauto:GetChecked(true) then
				AutoItems[Item] = true
			else
				AutoItems[Item] = nil
			end
		end
	end
	
	-- Available items in the middle
	local itemview = vgui.Create("DListView")
	itemview:SetParent(storeframe)
	itemview:SetPos(StoreWidth / 3.0, titlesize)
	itemview:SetSize(StoreWidth / 3.0, StoreHeight - titlesize)
	itemview:SetMultiSelect(false)
	itemview:AddColumn("Item Name")
	itemview:AddColumn("Resps Cost")
	function set_category(Category) -- Sets currently viewed category
		itemview:Clear()
		local items = Category:GetItems()
		for k, v in pairs(items) do
			itemview:AddLine(v:GetName(), v:GetCost()).OnSelect = function()
				set_item(v)
			end
		end
	end
	
	-- Available categories on the right
	local categoryview = vgui.Create("DTree")
	categoryview:SetParent(storeframe)
	categoryview:SetPos(0, titlesize)
	categoryview:SetSize(StoreWidth / 3.0, StoreHeight - titlesize)
	function node_for_category(Parent, Category) -- Creates a tree node for a category
		local node = Parent:AddNode(Category:GetName())
		for i, c in pairs(Category:GetChildren()) do
			node_for_category(node, c)
		end
		node.DoClick = function()
			set_category(Category)
		end
	end
	for i, c in pairs(GetRootCategories()) do
		node_for_category(categoryview, c)
	end
	
	-- Show
	StoreFrame = storeframe
	storeframe:SetVisible(true)
	storeframe:MakePopup()
end

--------------------------------------------
-- Think hook for the store.
--------------------------------------------
local function StoreThink()
	if input.IsKeyDown(StoreKey) then
		if not KeyDown then
			if StoreFrame then
				if StoreFrame:IsVisible() then
					StoreFrame:SetVisible(false)
				else
					StoreFrame:SetVisible(true)
					StoreFrame:MakePopup()
				end
			else
				OpenStore()
			end
			KeyDown = true
		end
	else
		KeyDown = false
	end
end
hook.Add("Think", "StoreThink", StoreThink)

--------------------------------------------
-- Autobuy stuff
--------------------------------------------
local function StoreAutoBuy()
	for item, buy in pairs(AutoItems) do
		if buy then
			item:Purchase(true)
		end
	end
end
usermessage.Hook("store_autobuy", StoreAutoBuy)