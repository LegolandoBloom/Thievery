
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


Legolando_BagTrackerMixin_Thievery = {}

-- self.debugLevel:
-- 	0 No Debug Prints
-- 	1 Few Debug Prints | Scan_Hook OnUpdate Prints
-- 	2 More Debug Prints ... | + hooksecurefunc prints with time + BAG_UPDATE event prints
--  3 Filter Prints
--  4 is More Debug Prints + Filter Prints

function Legolando_BagTrackerMixin_Thievery:DebugPrint(level, ...)
	local debugLevel = self.debugLevel
	if not debugLevel or debugLevel == 0 then return end
	if debugLevel == 3 then
		if level == 3 then
			print(...)
		end
	elseif level <= debugLevel then
		print(...)
	end
end
function Legolando_BagTrackerMixin_Thievery:DebugDump(level, ...)
	local debugLevel = self.debugLevel
	if not debugLevel or debugLevel == 0 then return end
	if debugLevel == 3 then
		if level == 3 then
			DevTools_Dump(...)
		end
	elseif level <= debugLevel then
		DevTools_Dump(...)
	end
end

local bagTable = {}
bagTable[0] = {}
bagTable[1] = {}
bagTable[2] = {}
bagTable[3] = {}
bagTable[4] = {}
bagTable[5] = {}
bagTable[6] = {}

Legolando_BagTrackerMixin_Thievery.callbacks = Legolando_BagTrackerMixin_Thievery.callbacks or LibStub("CallbackHandler-1.0"):New(Legolando_BagTrackerMixin_Thievery)

function Legolando_BagTrackerMixin_Thievery:GetContainerFrame(containerID)
	if containerID == 1 then
		return ContainerFrame1
	elseif containerID == 2 then
		return ContainerFrame2
	elseif containerID == 3 then
		return ContainerFrame3
	elseif containerID == 4 then
		return ContainerFrame4
	elseif containerID == 5 then
		return ContainerFrame5
	elseif containerID == 6 then
		return ContainerFrame6
	end
	return nil
end
function Legolando_BagTrackerMixin_Thievery:GetBagID(containerFrameName)
	if containerFrameName == "ContainerFrame1" then
		return 0
	elseif containerFrameName == "ContainerFrame2" then
		return 1
	elseif containerFrameName == "ContainerFrame3" then
		return 2
	elseif containerFrameName == "ContainerFrame4" then
		return 3
	elseif containerFrameName == "ContainerFrame5" then
		return 4
	elseif containerFrameName == "ContainerFrame6" then
		return 5
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
function Legolando_BagTrackerMixin_Thievery:InvestigateItemSlot(slotID, bagID)
	if bagID > 5 or bagID < 0 then return end
	local info = C_Container.GetContainerItemInfo(bagID, slotID);
	if not bagTable[bagID] then 
		self:DebugPrint(3, "Bag ID not initialized in table," , bagID)
		return
	end
	if not info then
		self:DebugPrint(3, "info doesn't exist for slot: ", bagID, slotID)
		return
	end
	if self.filters and next(self.filters) ~= nil then
		local filters = self.filters
		-- self:DebugPrint(3, "Filters: ")
		-- self:DebugDump(3, filters)
		local isValid = true
		for i, v in pairs(filters) do
			if info[i] == nil then 
				self:DebugPrint(3, "Item:" , info.hyperlink, " doesn't have any info about the desired filter: ")
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
				self:DebugPrint(3, "item", info.hyperlink, "meets criteria:", i)
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

-- ┌─────────────────────────────────────────────────┐ 
-- │ Never call InvestigateBag() directly, do it on  │ 
-- │ the next update using SetScript "OnUpdate" ! !  │ 
-- └─────────────────────────────────────────────────┘ 
local bagsToUpdate = {}
local function bagEventHandler(self, ...)
	local bagID = ...
	if bagID < 0 or bagID > 5 then return end
	if bagID then
		bagsToUpdate[bagID] = bagID
	end
	self:SetScript("OnUpdate", function()
		for i, v in pairs(bagsToUpdate) do
			self:DebugPrint(2, "Updating bag ", v)
			self:InvestigateBag(v)
		end
		bagsToUpdate = {}
		self:SetScript("OnUpdate", nil)
	end)
end

-- Do not call before PLAYER_ENTERING_WORLD, it will spread taint to bankFrame -> bags
function Legolando_BagTrackerMixin_Thievery:UpdateAll()
	for i=1,6 do
		self:Scan_Hook(i - 1, nil, "UpdateAll")
	end
end

function Legolando_BagTrackerMixin_Thievery:ClearBag(bagID)
	if bagID > 5 or bagID < 0 then return end
	bagTable[bagID] = {}
	self.callbacks:Fire("Lego-BagCleared-Thievery", bagID)
end

function Legolando_BagTrackerMixin_Thievery:InvestigateBag(bagID)
	-- Retail: containerFrame = ContainerFrameUtil_GetShownFrameForID(bagID)
	-- Classic: containerFrame = self:GetContainerFrame(IsBagOpen(bagID))
	local correspondingContainerID = IsBagOpen(bagID)
	self:ClearBag(bagID)
	for slotID = 1, C_Container.GetContainerNumSlots(bagID) do
		local id = C_Container.GetContainerItemID(bagID, slotID);
		if id then
			self:InvestigateItemSlot(slotID, bagID)
		end
	end

	-- print("Did bag: ", bagID)
	-- for i, v in pairs(bagTable[bagID]) do
	-- 	print(v.itemName)
	-- end
	self.callbacks:Fire("Lego-BagScanDone-Thievery", bagID, bagTable[bagID], self:GetContainerFrame(correspondingContainerID))
end

-- Each containerFrame 1-6 has it's own OnUpdate Delayer Scan_Hook
local scanDelayFrames = {}
for i=1,6,1 do
	scanDelayFrames[i - 1] = CreateFrame("Frame")
end
-- scanBagsSeparately
-- reScanEveryOpenBag
-- clearOnClose
local scannedOnce = {
	[0] = false,
	[1] = false,
	[2] = false,
	[3] = false,
	[4] = false,
	[5] = false,
}
-- only do reScanEveryOpenBag == false, (aka scan once per reload)
-- after the player has loaded into the world
local enteredWorld = false
-- ┌─────────────────────────────────────────────────┐ 
-- │ Never call InvestigateBag() directly, do it on  │ 
-- │ the next update using SetScript "OnUpdate" ! !  │ 
-- └─────────────────────────────────────────────────┘                                  
function Legolando_BagTrackerMixin_Thievery:Scan_Hook(bagID, callType, caller)
	if bagID < 0 or bagID > 5 then return end
	if self.scanBagsSeparately == true then
		if self.reScanEveryOpenBag == true then
			-- IF WE ARE:
			-- 1) Scanning Bags Separately  (We can't check if a specific bag is 'open' on toggle when Scanning All Bags Together)
			--  	┌─────────────────────────────────────  
			-- 		│ Also, Scanning All Bags Together is meant to work with Baganator(or other Bag addons),
			-- 	  	  and IsBagOpen() won't work properly with that since Baganator rarely opens the bag frame itself │ 
			-- 																	   	   ───────────────────────────────┘ 
			-- 2) Clearing bagTable[bagID] on 'Close' + Re-scanning every time we open a bag   (Clear on close only works if we are re-scanning every time a bag is opened)
			-- 3) Scan_Hook has been called by a "toggle"
 			-- 4) The bag is currently Closed 
			-- THEN WE CALL CLEAR AND RETURN, SO THAT InvestigateBag() WON'T BE CALLED ON THE NEXT UPDATE
			-- Note: IsBagOpen returns nil instead of false in Classic when bag isn't open
			if self.clearOnClose == true and callType == "toggle" and not IsBagOpen(bagID) then
				self:DebugPrint(1, "Toggle Call - Clear + Early Return ", "caller: ", caller)
				self:ClearBag(bagID)
				return
			end
			scanDelayFrames[bagID]:SetScript("OnUpdate", function(delayerFrame, ...)
				self:DebugPrint(1, "Scan Every Time, Bag: ", bagID, "caller: ", caller)
				self:InvestigateBag(bagID)
				delayerFrame:SetScript("OnUpdate", nil)
			end)
		else
			if not enteredWorld then 
				self:DebugPrint(2, "hasn't entered world yet")
				return 
			end
			if scannedOnce[bagID] then return end
			scanDelayFrames[bagID]:SetScript("OnUpdate", function(delayerFrame, ...)
				self:DebugPrint(1, "Scan Once, Bag: ", bagID, "caller: ", caller)
				self:InvestigateBag(bagID)
				delayerFrame:SetScript("OnUpdate", nil)
			end)
			scannedOnce[bagID] = true
		end
	else
		if self.reScanEveryOpenBag == true then
			scanDelayFrames[0]:SetScript("OnUpdate", function(delayerFrame, ...)
				local printTable = {}
				for c=1,6,1 do
					printTable[c - 1] = c - 1
					self:InvestigateBag(c - 1)
				end
				self:DebugPrint(1, "Scan(All) Every, Bags Below: ", "caller: ", caller)
				self:DebugDump(1, printTable)
				delayerFrame:SetScript("OnUpdate", nil)
			end)
		else
			if not enteredWorld then 
				self:DebugPrint(2, "hasn't entered world yet")
				return 
			end
			if scannedOnce[0] then return end
			scanDelayFrames[0]:SetScript("OnUpdate", function(delayerFrame, ...)
				local printTable = {}
				for c=1,6,1 do
					printTable[c - 1] = c - 1
					self:InvestigateBag(c - 1)
				end
				self:DebugPrint(1, "Scan(All) Once, Bags Below: ", "caller: ", caller)
				self:DebugDump(1, printTable)
				delayerFrame:SetScript("OnUpdate", nil)
			end)
			scannedOnce[0] = true
		end
	end
end
-- ClearBag(bagID) called with this won't always clear bagTable[bagID]  
-- Because InvestigateBag might be called on the next update with Scan_Hook 
-- regardless(through ToggleBag/ToggleBackpack/ToggleAllBags), filling it again.
-- ↑↑↑↑↑       However, check Scan_Hook() Above for a special case     ↑↑↑↑↑
function Legolando_BagTrackerMixin_Thievery:Clear_Call(bagID)
	if bagID < 0 or bagID > 5 then return end
	if not self.reScanEveryOpenBag then return end
	if not self.clearOnClose then return end
	if self.scanBagsSeparately == true then
		self:ClearBag(bagID)
	else
		for c=1,6,1 do
			self:ClearBag(c - 1)
		end
	end
end
function Legolando_BagTrackerMixin_Thievery:Init()
	-- used in Scan_Hook when reScanEveryOpenBag == false (aka scan once per reload)
	-- to make it so that the first and only scan happens after the player enters the world
	EventRegistry:RegisterFrameEventAndCallback("PLAYER_ENTERING_WORLD", function()
		enteredWorld = true
	end, self)
	--________________________________________________________
	--_______ USE THIS TO LIST FILTERED ITEMS NEATLY _________
	--          ( activated when debugLevel > 0 )
	--________________________________________________________
	if self.debugLevel and self.debugLevel > 0 then
		local colorz = {
			[1] = CreateColor(1, 0.41, 0), -- Orange
			[2] = CreateColor(0.9, 0.8, 0.5), -- Color Underlight
			[3] = CreateColor(0.64, 0.3, 0.71), -- Purple
			[4] = CreateColor(1.0, 0.82, 0.0), -- Yellow
			[5] = CreateColor(0.67, 0.41, 0), -- Brown
			[0] = CreateColor(0.85, 0.85, 0.85), -- Grey
		}
		SLASH_BAGTRACKERZZZ1 = "/zzz"
		SlashCmdList["BAGTRACKERZZZ"] = function() 
			print("Filtered items: ")
			local printTable = {}
			for i, v in pairs(bagTable) do
				for a, b in pairs(v) do
					table.insert(printTable, b.hyperlink .. colorz[i]:WrapTextInColorCode(" in bag " .. i) .. " slot " .. a)
					print(b.hyperlink .. colorz[i]:WrapTextInColorCode(" in bag " .. i) .. " slot " .. a)
				end
			end
			-- print(tableToString(printTable))
		end
	end


	-- _____________________________________________________________________________
	--       		  Bag Updater(when player moves/removes items)
	-- _____________________________________________________________________________
	EventRegistry:RegisterFrameEventAndCallback("BAG_UPDATE", bagEventHandler, self)


	-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	--						  Synchronization System for InvestigateBag()
	-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	-- Depending on certain conditions - Addons, Whether you Click on Macro Icons or use Keybinds...
	-- some of the below Callbacks/Hooks wont be triggered, but the ones that do will always trigger
	-- on the SAME UPDATE, but in different order.
	-- We use Scan_Hook to delay the action per bag using separate delayers for each bag. 
	-- This way, despite how many ' BagOpen', 'BagToggle' etc. occur, InvestigateBag()
	-- only gets called once per bag.
	-- Example: 'Open Bag id=4' --> 'ToggleAllBags' is called in the same update   
	--             ▼ ▼ ▼ ▼ ▼ ▼ ▼ ▼ ▼ ▼ ▼ ▼ ▼ ▼ ▼ ▼ ▼ ▼ ▼ ▼ ▼ ▼ ▼ ▼ ▼ ▼ ▼ ▼
	--  Since bag id 4 is in ToggleAllBags, its OnUpdate script will be overwritten,
	--  and the InvestigateBag() for it will only be called once.


	-- 						▼ Commented, Doesn't trigger in Classic ▼
	-- EventRegistry:RegisterCallback("ContainerFrame.OpenBag", function(_, containerFrame)
	-- 	self:DebugPrint(2, "ContainerFrame.OpenBag", containerFrame:GetID(), GetTime())
	-- 	self:Scan_Hook(containerFrame:GetID(), "ContainerFrame.OpenBag")
	-- end)

	hooksecurefunc("ContainerFrame_OnShow", function(containerFrame)
		self:DebugPrint(2, "ContainerFrame_OnShow", containerFrame:GetID(), GetTime())
		self:Scan_Hook(containerFrame:GetID(), "open", "ContainerFrame_OnShow")
	end)
	
	hooksecurefunc("OpenBackpack", function()
		self:DebugPrint(2, "OpenBackpack  time: ", GetTime())
		self:Scan_Hook(0, "open","OpenBackpack")
	end)
	hooksecurefunc("ToggleBackpack", function()
		self:DebugPrint(2, "ToggleBackpack  time: ", GetTime())
		self:Scan_Hook(0, "toggle", "ToggleBackpack") 
	end)
	
	hooksecurefunc("OpenBag", function(id)
	  	self:DebugPrint(2, "OpenBag id: ", id, GetTime())
		self:Scan_Hook(id, "open", "OpenBag")
	end)
	hooksecurefunc("ToggleBag", function(id)
		self:DebugPrint(2, "ToggleBag id: ", id, "  time: ",  GetTime())
		self:Scan_Hook(id, "toggle", "ToggleBag")
	end)

	hooksecurefunc("OpenAllBags", function()
		self:DebugPrint(2, "OpenAllBags  time: ", GetTime())
		for i=1,6,1 do
			self:Scan_Hook(i- 1, "open", "OpenAllBags")
		end
	end)
	hooksecurefunc("ToggleAllBags", function()
		self:DebugPrint(2, "ToggleAllBags  time: ", GetTime())
		for i=1,6,1 do
			self:Scan_Hook(i - 1, "toggle", "ToggleAllBags")
		end
	end)
	-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


	--                      Clear Part 
	-- ClearBag() does not need any delay or sync, since it simply 
	-- just empties bagTable[bagID] and initiates a callback
	
	--                     ▼ Commented, Doesn't trigger in Classic ▼
	-- EventRegistry:RegisterCallback("ContainerFrame.CloseBag", function(_, containerFrame)
	--	self:DebugPrint(2, "ContainerFrame.CloseBag", GetTime())
	--	self:Clear_Call(containerFrame:GetID())
	-- end)

	hooksecurefunc("ContainerFrame_OnHide", function(containerFrame)
		self:DebugPrint(2, "ContainerFrame_OnHide", GetTime())
		self:Clear_Call(containerFrame:GetID())
	end)
  	hooksecurefunc("CloseBackpack", function()
		self:DebugPrint(2, "CloseBackpack  time: ", GetTime())
		self:Clear_Call(0)
	end)
  	hooksecurefunc("CloseBag", function(id)
		self:DebugPrint(2, "CloseBag id: ", id, "  time: ",  GetTime())
		self:Clear_Call(id)
	end)
  	hooksecurefunc("CloseAllBags", function()
		self:DebugPrint(2, "CloseAllBags  time: ", GetTime())
		for i=1,6,1 do
			self:Clear_Call(i - 1)
		end
	end)
end


