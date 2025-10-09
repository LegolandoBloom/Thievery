-- local bagTrackingFrame = CreateFrame("Frame", "Thiever_BagTracker", UIParent, "Thievery_LegolandoBagTrackerTemplate")

-- local link1= "what"
-- local link2= "huh"
-- local link3= "duh"
	
-- bagTrackingFrame.filters ={
--     -- stackCount = {operator = '>', number = 1},
--     --isLocked = false,
--     -- quality = 4,
-- 	--IsReadable = false,
-- 	-- hyperlink = {link1, link2, link3},
-- 	-- isFiltered = false,
-- 	-- hasNoValue = false,
-- 	itemID = {29569, 113575, 112995, 203708},
-- 	-- isBound = true,
-- }


-- local lockpickOverlay = CreateFrame("Button", "LockpickOverlay", UIParent, "SecureActionButtonTemplate")
-- -- lockpickOverlay:SetPropagateMouseClicks(true)
-- lockpickOverlay:SetPassThroughButtons("LeftButton", "MiddleButton", "Button4", "Button5")
-- lockpickOverlay:EnableMouseMotion(false)

-- lockpickOverlay:SetFrameStrata("HIGH")
-- lockpickOverlay:RegisterForClicks("RightButtonUp")
-- lockpickOverlay:SetAttribute("type", "macro")
-- local name = C_Spell.GetSpellName(1804)
-- local line1 = "/cast " .. name
-- lockpickOverlay:SetAttribute("spell", name)
-- lockpickOverlay:HookScript("OnClick", function()
--     print("I hath been clicked")
-- end)

-- SLASH_THIEVERYBITEM1 = "/bitem"
-- SlashCmdList["THIEVERYBITEM"] = function()
--     local itemButton = GetMouseFoci()[1]
--     if not itemButton then return end
--     if not itemButton:GetSlotAndBagID() then return end
--     local slotID, bagID = itemButton:GetSlotAndBagID()
--     DevTools_Dump(C_Container.GetContainerItemInfo(itemButton:GetBagID(), itemButton:GetID()))
--     local tooltipData = C_TooltipInfo.GetBagItem(itemButton:GetBagID(), itemButton:GetID())
-- 	DevTools_Dump(tooltipData)
--     lockpickOverlay:ClearAllPoints()
--     lockpickOverlay:SetPoint("CENTER", itemButton, "CENTER")
--     local width, height = itemButton:GetSize()
--     lockpickOverlay:SetSize(width, height)
--     local line2 = "/use " .. " " .. bagID .. " " .. slotID
--     lockpickOverlay:SetAttribute("macrotext", line1 .. "\n" .. line2)
-- end

-- local function pool_clear(framePool, frame)
--     frame:SetScript("OnUpdate", nil)
--     frame:SetScript("OnEvent", nil)
--     frame:SetScript("OnClick", nil)
--     frame:ClearAllPoints()
--     frame.texture:ClearAllPoints()
--     frame:Hide()
-- end
-- local function pool_create(frame)
--     frame:SetFrameStrata("HIGH")
--     frame:RegisterForClicks("RightButtonUp")
--     frame:SetAttribute("type", "macro")
--     frame:SetPassThroughButtons("LeftButton", "MiddleButton", "Button4", "Button5")
--     frame:EnableMouseMotion(false)
--     frame.texture = frame:CreateTexture(nil, "ARTWORK")
--     frame.texture:SetColorTexture(1, 0, 0)
-- end
-- Thievery_LockpickOverlays = {}
-- for i=1,6,1 do
--     Thievery_LockpickOverlays[i - 1] = CreateFramePool("Button", Thievery_LockpickOverlays[i - 1], "SecureActionButtonTemplate", pool_clear, false, pool_create)
--     print(i - 1)
-- end




-- -- local delayFrame = delayFramePool:Acquire()
-- -- delayFramePool:Release(self)


-- local function handleSlot(itemButton, bagID, slotID)
--     if not itemButton:IsShown() or not itemButton:IsVisible() then
--         print("item button is not visible, can't create overlay frame")
--         return
--     end
--     print(bagID, slotID)
--     local overlayButton = Thievery_LockpickOverlays[bagID]:Acquire()
--     overlayButton:ClearAllPoints()
--     overlayButton:SetPoint("CENTER", itemButton, "CENTER")
--     local width, height = itemButton:GetSize()
--     overlayButton:SetSize(width, height)
--     overlayButton.texture:SetAllPoints(overlayButton)
--     overlayButton:Show()
--     local line2 = "/use " .. " " .. bagID .. " " .. slotID
--     overlayButton:SetAttribute("macrotext", line1 .. "\n" .. line2)
--     overlayButton:SetAttribute("macrotext", line1 .. "\n" .. line2)
--     -- overlayButton:
-- end
-- local function sayHi(event, bagID, bagContents)
--     if InCombatLockdown() then return end
--     if not bagID then return end
--     local containerFrame = bagTrackingFrame:GetContainerFrame(bagID)
--     if not containerFrame or not containerFrame:IsShown() or not containerFrame:IsVisible() then
--         print("event fired, yet containerFrame isn't there")
--         return
--     end
--     -- DevTools_Dump(containerFrame.Items)
--     DevTools_Dump(bagContents)
--     for i, itemButton in containerFrame:EnumerateValidItems() do
--         if itemButton then
--             local buttonID = itemButton:GetID()
--             -- print("item button: ", buttonID, i)
--             if bagContents[buttonID] then
--                 print("yay")
--                 handleSlot(itemButton, bagID, buttonID)
--             end
--         end
-- 	end
-- end
-- bagTrackingFrame.RegisterCallback(bagTrackingFrame, "Lego-BagScanDone", sayHi)

-- local function clearOverlays(event, bagID)
--     if InCombatLockdown() then return end
--     if not bagID then return end
--     local containerFrame = bagTrackingFrame:GetContainerFrame(bagID)
--     if not containerFrame then
--         print("bag clear event fired, yet containerFrame isn't there")
--         return
--     end
--     Thievery_LockpickOverlays[bagID]:ReleaseAll()
-- end
-- bagTrackingFrame.RegisterCallback(bagTrackingFrame, "Lego-BagCleared", clearOverlays)