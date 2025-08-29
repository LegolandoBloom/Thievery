
local function tableToString(tbl, recursiveCall)
	local colorTeal = CreateColor(0, 1, 0.76)
	local toString = ""
	if not recursiveCall then
		toString = "\n"
	end
	for i, v in pairs(tbl) do
		if type(v) == "table" then
			if next(v) ~= nil then
				local element = "[" .. colorTeal:WrapTextInColorCode("(Table)") .. tostring(i) .. ":\n   "  .. tableToString(v, true) .. " ]\n"
				toString = toString .. "  " .. element
			end
		else
			local element = "[" .. tostring(i) .. ":" .. tostring(v) .. "]"
			toString = toString .. "  " .. element
		end
	end
	return toString
end



Thievery_LegolandoBagTrackerMixin = {}

local bagTable = {}
bagTable[0] = {}
bagTable[1] = {}
bagTable[2] = {}
bagTable[3] = {}
bagTable[4] = {}
bagTable[5] = {}
bagTable[6] = {}

Thievery_LegolandoBagTrackerMixin.callbacks = Thievery_LegolandoBagTrackerMixin.callbacks or LibStub("CallbackHandler-1.0"):New(Thievery_LegolandoBagTrackerMixin)

function Thievery_LegolandoBagTrackerMixin:GetContainerFrame(bagID)
	if bagID == 0 then
		return ContainerFrame1
	elseif bagID == 1 then
		return ContainerFrame2
	elseif bagID == 2 then
		return ContainerFrame3
	elseif bagID == 3 then
		return ContainerFrame4
	elseif bagID == 4 then
		return ContainerFrame5
	elseif bagID == 5 then
		return ContainerFrame6
	end
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



local function checkStackCount(teeburu, count)
	local operator = teeburu.operator
	local number = teeburu.number
	if operator == '=' then
		if count == number then
			return true
		end
	elseif operator == '<' then
		if count < number then
			return true
		end
	elseif operator == '>' then
		if count > number then
			return true
		end
	elseif operator == '<=' then
		if count <= number then
			return true
		end
	elseif operator == '>=' then
		if count >= number then
			return true
		end
	elseif operator == '~=' then
		if count ~= number then
			return true
		end
	end
	return false
end
local function checkTables(teeburu, info)
	for i, tableInfo in pairs(teeburu) do
		if tableInfo == info then 
			return true
		end
	end
	return false
end
function Thievery_LegolandoBagTrackerMixin:InvestigateItemSlot(itemButton)
	if not itemButton then return end
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
		-- print("Filters: ")
		-- DevTools_Dump(filters)
		local isValid = true
		for i, v in pairs(filters) do
			if not info[i] then 
				print("Item:" , info.hyperlink, " doesn't have any info about the desired filter: ")
				isValid = false
			elseif i == "stackCount" then
				if checkStackCount(v, info.stackCount) == false then
					isValid = false
				end
			elseif i == "itemID" or i == "hyperlink" then
				if checkTables(v, info.itemID) == false then
					isValid = false
				end
			elseif info[i] == v then
				-- print("item", info.hyperlink, "meets criteria:", i)
			else
				isValid = false
			end
		end
		if isValid then
			bagTable[bagID][slotID] = info
		end
	elseif bagID then 
		bagTable[bagID][slotID] = info
		-- no filters, add all items
	end
end

function Thievery_LegolandoBagTrackerMixin:ClearBag(containerFrame)
	if not containerFrame then return end
    local bagID = containerFrame:GetID()
	bagTable[bagID] = {}
	self.callbacks:Fire("Lego-BagCleared", bagID)
end

function Thievery_LegolandoBagTrackerMixin:InvestigateBag(containerFrame)
	if not containerFrame then return end
    local bagID = containerFrame:GetID()
	self:ClearBag(containerFrame)
    for i, itemButton in containerFrame:EnumerateValidItems() do
		self:InvestigateItemSlot(itemButton)
	end
	self.callbacks:Fire("Lego-BagScanDone", bagID, bagTable[bagID])
end

local bagsToUpdate = {}
local function bagEventHandler(self, ...)
	local bagID = ...
	if bagID then
		table.insert(bagsToUpdate, bagID)
		DevTools_Dump(bagsToUpdate)
	end
	self:SetScript("OnUpdate", function()
		for i, v in pairs(bagsToUpdate) do
			print("Updating bag ", v)
			self:InvestigateBag(self:GetContainerFrame(v))
		end
		bagsToUpdate = {}
		self:SetScript("OnUpdate", nil)
	end)
end

function Thievery_LegolandoBagTrackerMixin:OnLoad()
    EventRegistry:RegisterCallback("ContainerFrame.OpenBag", function(_, containerFrame)
		self:InvestigateBag(containerFrame)
	end)
	EventRegistry:RegisterCallback("ContainerFrame.CloseBag", function(_, containerFrame)
		self:ClearBag(containerFrame)
	end)
	EventRegistry:RegisterFrameEventAndCallback("BAG_UPDATE", bagEventHandler, self)
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


SLASH_THIEVERYZZZ1 = "/zzz"
SlashCmdList["THIEVERYZZZ"] = function() 
	print("Filtered items: ")
	for i, v in pairs(bagTable) do
		for a, b in pairs(v) do
			print(b.hyperlink, "in bag ", i, "slot ", a)
		end
	end
	-- print(tableToString(bagTable))
end
