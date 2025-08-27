local bagTrackingFrame = CreateFrame("Frame", "Thiever_BagTracker", UIParent, "Thievery_LegolandoBagTrackerTemplate")

local link1= "what"
local link2= "huh"
local link3= "duh"
	
bagTrackingFrame.filters ={
    stackCount = {operator = '>', number = 1},
    --isLocked = false,
    quality = 4,
	--IsReadable = false,
	-- hyperlink = {link1, link2, link3},
	-- isFiltered = false,
	-- hasNoValue = false,
	-- itemID = {29569, 113575, 112995},
	-- isBound = true,
}


SLASH_THIEVERYBITEM1 = "/bitem"
SlashCmdList["THIEVERYBITEM"] = function()
    local itemButton = GetMouseFoci()[1]
    if not itemButton then return end
    if not itemButton:GetSlotAndBagID() then return end
    local slotID, bagID = itemButton:GetSlotAndBagID()
    DevTools_Dump(C_Container.GetContainerItemInfo(itemButton:GetBagID(), itemButton:GetID()))
    local tooltipData = C_TooltipInfo.GetBagItem(itemButton:GetBagID(), itemButton:GetID())
	DevTools_Dump(tooltipData)
end
