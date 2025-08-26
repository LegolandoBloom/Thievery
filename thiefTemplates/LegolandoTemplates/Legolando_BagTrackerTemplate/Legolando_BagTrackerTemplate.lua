
Thievery_LegolandoBagTrackerMixin = {}

local bagTable = {}

local function resetTable()
	bagTable = {}
	bagTable[0] = {}
	bagTable[1] = {}
	bagTable[2] = {}
	bagTable[3] = {}
	bagTable[4] = {}
	bagTable[5] = {}
	bagTable[6] = {}
end



-- EACH VALID SLOT HAS A TABLE WITH THESE VALUES
-- slot.iconFileID | slot.stackCount | slot.isLocked | slot.quality | slot.IsReadable
-- slot.hyperlink | slot.isFiltered | slot.hasNoValue | slot.itemID | slot.isBound

-- POSSIBLE FILTERS:
-- stackCount: 
--      operator = '=' | '<' | '>' | '<=' | '>=' | '~='
--      number
-- isLocked: false | true
-- quality: 0 (Poor) | 1 (Common) | 2 (Uncommon) | 3 (Rare) | 4 (Epic) | 5 (Legendary) | 6 (Artifact) | 7 (Heirloom) | 8 (Wow Token)
-- IsReadable: false | true
-- hyperlink: {
-- 			    link1, link2, link3, ...         IE: A table with a bunch of item hyperlinks to check
-- 			  }
-- isFiltered: false | true
-- hasNoValue: false | true
-- itemID: {
	-- 			    itemID1, itemID2, itemID3, ...         IE: A table with a bunch of itemIDs to check
	-- 		   }
-- isBound: false | true

-- used to turn tables in filters to singular values to cleanly compare with info later on
local function handleTables(teeburu, info)
	for i, tableInfo in pairs(teeburu) do
		if tableInfo == info then 
			return info
		end
	end
	return nil
end
function Thievery_LegolandoBagTrackerMixin:InvestigateItemSlot(itemButton)
	local slotID, bagID = itemButton:GetSlotAndBagID()
	local info = C_Container.GetContainerItemInfo(bagID, slotID);
	if not bagTable[bagID] then 
		print("Bag ID not initialized in table," , bagID)
		return
	end
	if not info then
		--print("info doesn't exist for slot: ", bagID, slotID)
		return
	end
	if self.filters and next(self.filters) ~= nil then
		local filters = self.filters
		if filters.hyperlink and next(filters.hyperlink) ~= nil then
			filters.hyperlink = handleTables(filters.hyperlink, info.hyperlink)
		end
		if filters.itemID and next(filters.itemID) ~= nil then
			filters.itemID = handleTables(filters.itemID, info.itemID)
		end
		for i, v in pairs(self.filters) do
			print(i, v)
		end
	else
		bagTable[bagID][slotID] = info
		print(bagTable[bagID][slotID].quality)
		-- no filters, add all items
	end
end

function Thievery_LegolandoBagTrackerMixin:UpdateSavedSlots(bagID)
	for i, info in pairs(bagTable[bagID]) do
		print(i, info.quality)
	end
end

function Thievery_LegolandoBagTrackerMixin:InvestigateBag(containerFrame)
	resetTable()
    local bagID = containerFrame:GetID()
    for i, itemButton in containerFrame:EnumerateValidItems() do
		self:InvestigateItemSlot(itemButton)
	end
end

function Thievery_LegolandoBagTrackerMixin:OnLoad()
    EventRegistry:RegisterCallback("ContainerFrame.OpenBag", function(_, containerFrame)
		self:InvestigateBag(containerFrame)
	end)
    EventRegistry:RegisterCallback("ItemButton.UpdateItemContextMatching", function(_, bagID)
		self:UpdateSavedSlots(bagID)
	end)
end

-- local itemID = C_Container.GetContainerItemID(bagID, itemButton:GetID())
-- local info = itemID and next({C_Item.GetItemInfo(itemID)}) and {C_Item.GetItemInfo(itemID)}
-- local classID = info and info[12]
-- local subclassID = info and info[13]
-- if classID and subclassID and itemID == 29569 then 
--     print(itemLink)
--     print("Class: ", C_Item.GetItemClassInfo(classID))
--     print("Class: ", C_Item.GetItemSubClassInfo(classID, subclassID))
-- end