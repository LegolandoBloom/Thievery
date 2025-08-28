local bagTrackingFrame = CreateFrame("Frame", "Thiever_BagTracker", UIParent, "Thievery_LegolandoBagTrackerTemplate")

local link1= "what"
local link2= "huh"
local link3= "duh"
	
bagTrackingFrame.filters ={
    -- stackCount = {operator = '>', number = 1},
    --isLocked = false,
    -- quality = 4,
	--IsReadable = false,
	-- hyperlink = {link1, link2, link3},
	-- isFiltered = false,
	-- hasNoValue = false,
	itemID = {29569, 113575, 112995, 203708},
	-- isBound = true,
}


local lockpickOverlay = CreateFrame("Button", "LockpickOverlay", UIParent, "SecureActionButtonTemplate")
lockpickOverlay:SetPropagateMouseClicks(true)
lockpickOverlay:SetPassThroughButtons("LeftButton", "MiddleButton", "Button4", "Button5")
lockpickOverlay:EnableMouseMotion(false)
lockpickOverlay:SetPoint("CENTER")
lockpickOverlay:SetSize(64, 64)
lockpickOverlay:SetFrameStrata("HIGH")
lockpickOverlay:RegisterForClicks("RightButtonUp")
lockpickOverlay:SetAttribute("type", "macro")
local name = C_Spell.GetSpellName(1804)
local line1 = "/cast " .. name
lockpickOverlay:SetAttribute("spell", name)
lockpickOverlay:HookScript("OnClick", function()
    print("I hath been clicked")
end)

SLASH_THIEVERYBITEM1 = "/bitem"
SlashCmdList["THIEVERYBITEM"] = function()
    local itemButton = GetMouseFoci()[1]
    if not itemButton then return end
    if not itemButton:GetSlotAndBagID() then return end
    local slotID, bagID = itemButton:GetSlotAndBagID()
    DevTools_Dump(C_Container.GetContainerItemInfo(itemButton:GetBagID(), itemButton:GetID()))
    local tooltipData = C_TooltipInfo.GetBagItem(itemButton:GetBagID(), itemButton:GetID())
	DevTools_Dump(tooltipData)

    lockpickOverlay:ClearAllPoints()
    lockpickOverlay:SetPoint("CENTER", itemButton, "CENTER")
    local width, height = itemButton:GetSize()
    lockpickOverlay:SetSize(width, height)
    local line2 = "/use " .. " " .. bagID .. " " .. slotID
    lockpickOverlay:SetAttribute("macrotext", line1 .. "\n" .. line2)
end


Thievery_LockpickOverlays = CreateFramePool("Frame", Thievery_LockpickOverlays, nil, function(framePool, frame)
    frame:ClearAllPoints()
    frame:SetScript("OnUpdate", nil)
    frame:Hide()
end)

local delayFrame = delayFramePool:Acquire()
delayFramePool:Release(self)