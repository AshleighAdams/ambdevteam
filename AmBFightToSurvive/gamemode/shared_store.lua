--------------------------------------------
------ How to use the Store API,
-- Categories are used to organize items
-- within a store. An item can belong to
-- a category and be shown with it.
-- If a category has child categories, it
-- includes all items found in its
-- children.
--
-- All functions in the store api must be
-- called in a shared section. Items and
-- categories must all have unique id's
-- which can be a number or string, to
-- be identified to the server.
--
-- If OnPurchase is set on an item on the
-- server, it will be called when the item
-- is purchased with the item and player
-- as arguments. The function should see
-- if the player has enough Resps and give
-- the player the item.
--------------------------------------------
require("datastream")

-- A table of categories in the form
-- {CategoryID : {CategoryID, CategoryName, ParentCategory, ListOfChildCategories, ListOfItem}}
local Categories = { }

-- A table of items in the form
-- {ItemID : {ItemID, ItemName, ItemCost}}
local Items = { }

-- ID's of categories with no parent category
local RootCategories = { }

--------------------------------------------
-- The following methods can be applied to
-- categories:
---- GetName()
---- GetParent()
---- GetChildren()
---- GetItems()
--------------------------------------------
local MetaCategory = { }

--------------------------------------------
-- Returns this categories name.
--------------------------------------------
function MetaCategory:GetName()
	return self[2]
end

--------------------------------------------
-- Gets the parent category of this
-- category or nil if there isnt one.
--------------------------------------------
function MetaCategory:GetParent()
	local parent = self[3]
	if parent == nil then
		return nil
	else
		return parent
	end
end

--------------------------------------------
-- Gets the child categories of this
-- category.
--------------------------------------------
function MetaCategory:GetChildren()
	local children = { }
	for k, v in pairs(self[4]) do
		table.insert(children, v)
	end
	return children
end

--------------------------------------------
-- Gets the items in this category. This
-- includes all items in all child
-- categories of this category. This
-- function is computionally expensive.
--------------------------------------------
function MetaCategory:GetItems()
	-- Add items in a category to a list.
	function add_items(category, to)
		-- use items as keys to avoid having the
		-- same item twice
		for k, v in pairs(category[5]) do
			to[v] = true
		end
		
		-- Add items from children
		for k, v in pairs(category[4]) do
			add_items(v, to)
		end
	end
	
	local to = { }
	add_items(self, to)
	
	-- Reverse list
	local res = { }
	for k, v in pairs(to) do
		table.insert(res, k)
	end
	return res
end

--------------------------------------------
-- The following methods can be applied to
-- items:
---- GetName()
---- GetCost()
---- Purchase()
--------------------------------------------
local MetaItem = { }

--------------------------------------------
-- Returns this items name.
--------------------------------------------
function MetaItem:GetName()
	return self[2]
end

--------------------------------------------
-- Gets this items cost.
--------------------------------------------
function MetaItem:GetCost()
	return self[3]
end

--------------------------------------------
-- Buys the item with the current player.
-- Specifiy autobuy if this was bought
-- automatically.
--------------------------------------------
function MetaItem:Purchase(AutoBuy)
	if CLIENT then
		-- Send message to server
		datastream.StreamToServer("Item_Purchase", {self[1], AutoBuy or false})
	end
end
if SERVER then
	local function ReceivePurchase(Player, Handler, ID, Encoded, Decoded)
		local itemid = Decoded[1]
		local autobuy = Decoded[2]
		local item = Items[itemid]
		if item.OnPurchase then
			item.OnPurchase(item, Player, autobuy)
		end
	end
	datastream.Hook("Item_Purchase", ReceivePurchase)
end 

--------------------------------------------
-- Gets a list of all root categories
-- registered.
--------------------------------------------
function GetRootCategories()
	return RootCategories
end

--------------------------------------------
-- Adds and returns a category. Name will
-- be the name of the category and parent
-- is the category to become a child of. If
-- parent is nil or not given, this becomes
-- a root category. If this is called on
-- a client instead of a server, the
-- category becomes local and cannot be
-- seen elsewhere. ID can be specified if
-- the exact id of the category is known.
-- The created category is returned.
--------------------------------------------
function AddCategory(Name, Parent, ID)
	ID = ID or Name

	-- Create
	local cat = {ID, Name, Parent, { }, { }}
	Categories[ID] = cat
	setmetatable(cat, { __index = MetaCategory })
	
	-- Add to parent
	if Parent ~= nil then
		table.insert(Parent[4], cat)
	else
		table.insert(RootCategories, cat)
	end
	
	return cat
end

--------------------------------------------
-- Creates an item with the specified name
-- and cost.
--------------------------------------------
function AddItem(Name, Cost, ID)
	ID = ID or Name

	-- Create
	local item = {ID, Name, Cost}
	Items[ID] = item
	setmetatable(item, { __index = MetaItem })
	
	return item
end

--------------------------------------------
-- Adds the specified item to the specified
-- category.
--------------------------------------------
function AddItemToCategory(Item, Category)
	table.insert(Category[5], Item)
end