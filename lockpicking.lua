--____________________________________________________________________________________________ --
--_____________TRACKING PART (with Overlay Textures & OnClick SecureActionButton)_____________ --
--____________________________________________________________________________________________ --

local bagTrackingFrame = CreateFrame("Frame", "BagTrackerExample_BagTracker", UIParent, "Legolando_BagTrackerTemplate_Thievery")
	
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

local function pool_clear(framePool, frame)
    frame:SetScript("OnUpdate", nil)
    frame:SetScript("OnEvent", nil)
    frame:ClearAllPoints()
    frame.texture:ClearAllPoints()
    frame:Hide()
end
local function pool_create(frame)
    frame:SetFrameStrata("HIGH")
    frame:RegisterForClicks("RightButtonUp")
    frame:SetAttribute("type", "macro")
    frame:SetPassThroughButtons("LeftButton", "MiddleButton", "Button4", "Button5")
    frame:EnableMouseMotion(false)
    frame.texture = frame:CreateTexture(nil, "ARTWORK")
    frame.texture:SetColorTexture(1, 0, 0, 0.3)
end
-- Make a separate frame pool for each bag slot just in case
Thievery_LockpickOverlays = {}
for i=1,6,1 do
    Thievery_LockpickOverlays[i - 1] = CreateFramePool("Button", Thievery_LockpickOverlays[i - 1], "SecureActionButtonTemplate", pool_clear, false, pool_create)
end


local function handleSlot(itemButton, bagID, slotID)
    if not itemButton:IsShown() or not itemButton:IsVisible() then
        print("item button is not visible, can't create overlay frame")
        return
    end
    local overlayButton = Thievery_LockpickOverlays[bagID]:Acquire()
    overlayButton:ClearAllPoints()
    overlayButton:SetPoint("CENTER", itemButton, "CENTER")
    local width, height = itemButton:GetSize()
    overlayButton:SetSize(width, height)
    overlayButton.texture:SetAllPoints(overlayButton)
    overlayButton:Show()
    local spellName = C_Spell.GetSpellName(1804)
    local line1 = "/cast " .. spellName
    local line2 = "/use " .. " " .. bagID .. " " .. slotID
    overlayButton:SetAttribute("macrotext", line1 .. "\n" .. line2)
end
local function scanDone_Callback(event, bagID, bagContents)
    if InCombatLockdown() then return end
    if not bagID then return end
    local containerFrame = bagTrackingFrame:GetContainerFrame(bagID)
    if not containerFrame or not containerFrame:IsShown() or not containerFrame:IsVisible() then
        -- If a bag isn't visible, don't take any action
        -- print("event fired, yet containerFrame isn't there")
        return
    end
    -- Iterate through all the valid item slots in bags
    for i, itemButton in containerFrame:EnumerateValidItems() do
        if itemButton then
            local buttonID = itemButton:GetID()
            -- If the slot is in the filtered table returned from Legolando_BagTrackerTemplate, call handle function, which will acquire and place the overlays
            if bagContents[buttonID] then
                handleSlot(itemButton, bagID, buttonID)
            end
        end
	end
end
bagTrackingFrame.RegisterCallback(bagTrackingFrame, "Lego-BagScanDone-YourAddon", scanDone_Callback)

-- Clear the overlay secureaction buttons and textures when BagCleared event is fired from template
local function clearOverlays(event, bagID)
    if InCombatLockdown() then return end
    if not bagID then return end
    local containerFrame = bagTrackingFrame:GetContainerFrame(bagID)
    if not containerFrame then
        print("bag clear event fired, yet containerFrame isn't there")
        return
    end
    Thievery_LockpickOverlays[bagID]:ReleaseAll()
end
bagTrackingFrame.RegisterCallback(bagTrackingFrame, "Lego-BagCleared-YourAddon", clearOverlays)

