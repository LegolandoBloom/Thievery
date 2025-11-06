
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
		-- print("Bag ID not initialized in table," , bagID)
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
			if info[i] == nil then 
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

function Legolando_BagTrackerMixin_Thievery:ClearBag(bagID)
	if bagID > 5 or bagID < 0 then return end
	bagTable[bagID] = {}
	--_____________________________________________________________________________________________________________________________
	-- Need to have 'containerFrame' in the Payload IN CLASSIC because there is no way to get the right containerFrame from bagID
	-- _G["ContainerFrame" .. bagID] --> Does NOT always work 
	-- The frames are not tied to their bagIDs, whichever bag you open first is ContainerFrame1.
	--_____________________________________________________________________________________________________________________________
	self.callbacks:Fire("Lego-BagCleared-Thievery", bagID)
end

function Legolando_BagTrackerMixin_Thievery:InvestigateBag(bagID)
	local correspondingContainerID = IsBagOpen(bagID)
	self:ClearBag(bagID)
	for slotID = 1, C_Container.GetContainerNumSlots(bagID) do
		local id = C_Container.GetContainerItemID(bagID, slotID);
		if id then
			self:InvestigateItemSlot(slotID, bagID)
		end
	end
	--_____________________________________________________________________________________________________________________________
	-- Need to have 'containerFrame' in the Payload IN CLASSIC because there is no way to get the right containerFrame from bagID
	-- _G["ContainerFrame" .. bagID] --> Does NOT always work 
	-- The frames are not tied to their bagIDs, whichever bag you open first is ContainerFrame1.
	--_____________________________________________________________________________________________________________________________
	-- print("Did bag: ", bagID)
	-- for i, v in pairs(bagTable[bagID]) do
	-- 	print(v.itemName)
	-- end
	self.callbacks:Fire("Lego-BagScanDone-Thievery", bagID, bagTable[bagID], self:GetContainerFrame(correspondingContainerID))
end

local bagsToUpdate = {}
local function bagEventHandler(self, ...)
	local bagID = ...
	if bagID > 5 or bagID < 0 then return end
	if bagID then
		bagsToUpdate[bagID] = bagID
	end
	-- print("Will update bags:")
	-- DevTools_Dump(bagsToUpdate)
	self:SetScript("OnUpdate", function()
		for i, v in pairs(bagsToUpdate) do
			-- print("Updating bag ", v)
			self:InvestigateBag(v)
		end
		bagsToUpdate = {}
		self:SetScript("OnUpdate", nil)
	end)
end

function Legolando_BagTrackerMixin_Thievery:UpdateAll()
	for i=1,6 do
		self:InvestigateBag(i - 1)
	end
end

-- Each containerFrame 1-6 has it's own OnUpdate Delayer for ContainerFrame.OpenBag
local containerDelayFrames = {}
for i=1,6,1 do
	containerDelayFrames[i - 1] = CreateFrame("Frame")
end

-- scanPlayerEntering
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
function Legolando_BagTrackerMixin_Thievery:Scan_Hook(bagID, caller)
	if bagID < 0 or bagID > 5 then return end
	if self.scanBagsSeparately == true then
		if self.reScanEveryOpenBag == true then
			containerDelayFrames[bagID]:SetScript("OnUpdate", function(delayerFrame, ...)
				-- print("Scan Every Time, Bag: ", bagID, "caller: ", caller)
				self:InvestigateBag(bagID)
				delayerFrame:SetScript("OnUpdate", nil)
			end)
		else
			if scannedOnce[bagID] then return end
			containerDelayFrames[bagID]:SetScript("OnUpdate", function(delayerFrame, ...)
				-- print("Scan Once, Bag: ", bagID, "caller: ", caller)
				self:InvestigateBag(bagID)
				delayerFrame:SetScript("OnUpdate", nil)
			end)
			scannedOnce[bagID] = true
		end
	else
		if self.reScanEveryOpenBag == true then
			containerDelayFrames[0]:SetScript("OnUpdate", function(delayerFrame, ...)
				local printTable = {}
				for c=1,6,1 do
					printTable[c] = c
					self:InvestigateBag(c - 1)
				end
				-- print("Scan(All) Every, Bags Below: ", "caller: ", caller)
				-- DevTools_Dump(printTable)
				delayerFrame:SetScript("OnUpdate", nil)
			end)
		else
			if scannedOnce[0] then return end
			containerDelayFrames[0]:SetScript("OnUpdate", function(delayerFrame, ...)
				local printTable = {}
				for c=1,6,1 do
					printTable[c] = c
					self:InvestigateBag(c - 1)
				end
				-- print("Scan(All) Once, Bags Below: ", "caller: ", caller)
				-- DevTools_Dump(printTable)
				delayerFrame:SetScript("OnUpdate", nil)
			end)
			scannedOnce[0] = true
		end
	end
end
function Legolando_BagTrackerMixin_Thievery:Clear_Hook(bagID)
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
	-- Need to call InvestigateBag on the next 'OnUpdate', otherwise containerFrame and itemButtons won't have anchors, and return empty when GetPoint() or GetScaledRect() is called.
	-- Each containerFrame 1-6 has it's own OnUpdate Delayer, as created above ↑↑↑
  	hooksecurefunc("ContainerFrame_OnShow", function(containerFrame)
		-- print("ContainerFrame_OnShow", GetTime())
		self:Scan_Hook(containerFrame:GetID(), "ContainerFrame_OnShow")
	end)

	hooksecurefunc("OpenBackpack", function()
		-- print("OpenBackpack  time: ", GetTime())
		self:Scan_Hook(0, "OpenBackpack")
	end)
	hooksecurefunc("ToggleBackpack", function()
		-- print("ToggleBackpack  time: ", GetTime())
		self:Scan_Hook(0, "ToggleBackpack")
	end)
	
	hooksecurefunc("OpenBag", function(id)
	  	-- print("OpenBag id: ", id, GetTime())
		self:Scan_Hook(id, "OpenBag")
	end)
	hooksecurefunc("ToggleBag", function(id)
		-- print("ToggleBag id: ", id, "  time: ",  GetTime())
		self:Scan_Hook(id, "ToggleBag")
	end)

	hooksecurefunc("OpenAllBags", function()
		-- print("OpenAllBags  time: ", GetTime())
		for i=1,6,1 do
			self:Scan_Hook(i, "OpenAllBags")
		end
	end)
	hooksecurefunc("ToggleAllBags", function()
		-- print("ToggleAllBags  time: ", GetTime())
		for i=1,6,1 do
			self:Scan_Hook(i, "ToggleAllBags")
		end
	end)

	hooksecurefunc("ContainerFrame_OnHide", function(containerFrame)
		-- print("ContainerFrame_OnHide", GetTime())
		self:Clear_Hook(containerFrame:GetID())
	end)

  	hooksecurefunc("CloseBackpack", function()
		-- print("CloseBackpack  time: ", GetTime())
		self:Clear_Hook(0)
	end)
  	hooksecurefunc("CloseBag", function(id)
		-- print("CloseBag id: ", id, "  time: ",  GetTime())
		self:Clear_Hook(id)
	end)
  	hooksecurefunc("CloseAllBags", function()
		-- print("CloseAllBags  time: ", GetTime())
		for i=1,6,1 do
			self:Clear_Hook(i)
		end
	end)

	EventRegistry:RegisterFrameEventAndCallback("BAG_UPDATE", bagEventHandler, self)
end
                                                                                         
                                                                                                                   
                                                      
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
--						                 DEBUGGING 
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

--________________________________________________________
--_______ USE THIS TO LIST FILTERED ITEMS NEATLY _________
--          ( keep commented when not in use )
--________________________________________________________
-- SLASH_ThieveryZZZ1 = "/zzz"
-- SlashCmdList["ThieveryZZZ"] = function() 
-- 	print("Filtered items: ")
-- 	for i, v in pairs(bagTable) do
-- 		for a, b in pairs(v) do
-- 			print(b.hyperlink, "in bag ", i, "slot ", a)
-- 		end
-- 	end
-- 	-- print(tableToString(bagTable))
-- end
