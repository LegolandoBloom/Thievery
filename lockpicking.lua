local ANIMATION_SIZE_MULTIPLIER = 1.4

--____________________________________________________________________________________________ --
--_____________TRACKING PART (with Overlay Textures & OnClick SecureActionButton)_____________ --
--____________________________________________________________________________________________ --

-- hooksecurefunc("ContainerFrameItemButton_OnEnter", function(itemButton)
--     print(itemButton:GetDebugName())
-- end)

local bagTrackingFrame = CreateFrame("Frame", "BagTrackerExample_BagTracker", UIParent, "Legolando_BagTrackerTemplate_Thievery")
	
bagTrackingFrame.filters ={
    -- stackCount = {operator = '>', number = 1},
    --isLocked = false,
    -- quality = 4,
	--IsReadable = false,
	-- hyperlink = {link1, link2, link3},
	-- isFiltered = false,
	-- hasNoValue = false,
	itemID = {5523, 16885, 63349, 220376, 5759, 5758, 4636, 68729, 4638, 4634, 5760, 29569, 203743, 16884, 190954, 116920, 88567, 4632, 43624, 31952, 121331, 16882, 169475, 4637, 4633, 43622, 186161, 43575, 88165, 180533, 186160, 198657, 188787, 7209, 179311, 194037, 45986, 13918, 180522, 12033, 16883, 180532, 141596, 13875, 6354, 6355, 91331, 85118, 91330, 84897, 106895, 120065, 191296, 91799, 84895, 91329, 91334, 115066, 141608, 204307, 91332, 91333}
	-- isBound = true,
}


local imageFrame = CreateFrame("Frame", nil, UIParent)
imageFrame:SetFrameStrata("HIGH")
imageFrame:SetSize(30, 30)
imageFrame.texture = imageFrame:CreateTexture("ayoawhrf", "OVERLAY")
imageFrame.texture:SetAllPoints()
imageFrame.texture:SetTexture("Interface/AddOns/Thievery/images/lockpick-preanim.png")
imageFrame.texture:SetAlpha(0.8)
imageFrame:SetIgnoreParentScale(true) 
imageFrame.currentAnchor = nil

local function relocateImageFrame(point)
    imageFrame:ClearAllPoints()
    local currentAnchor = point
    if not currentAnchor or not currentAnchor[2] or not currentAnchor[2]:IsShown() or not currentAnchor[2]:IsVisible() then return end
    local _, _, width, height = currentAnchor[2]:GetScaledRect()
    imageFrame:SetSize(width*ANIMATION_SIZE_MULTIPLIER, height*ANIMATION_SIZE_MULTIPLIER)
    imageFrame:SetPoint(currentAnchor[1], currentAnchor[2], currentAnchor[3], currentAnchor[4], currentAnchor[5])
    imageFrame.texture:SetSize(width*ANIMATION_SIZE_MULTIPLIER, height*ANIMATION_SIZE_MULTIPLIER)
    local _, _, realWidth = imageFrame:GetScaledRect()
    Thievery_BetaPrint("Image frame REAL size: ", realWidth)
    local _, _, realWidth = imageFrame.texture:GetScaledRect()
    Thievery_BetaPrint("Image frame texture REAL size: ", realWidth)
    -- imageFrame.texture:SetAllPoints()
    imageFrame:Show()
    imageFrame.currentAnchor = currentAnchor
end

local animationFrame = CreateFrame("Frame", "Thievery_LockpickAnim", UIParent, "Thievery_LockpickAnimTemplate")
animationFrame:SetFrameStrata("HIGH")
animationFrame:SetPoint("CENTER", UIParent, "CENTER")
animationFrame:SetIgnoreParentScale(true) 
animationFrame.anim:SetScript("OnStop", function(self)
    local currentAnchor = imageFrame.currentAnchor
    if currentAnchor then
        if currentAnchor[2]:IsMouseOver() then
            imageFrame:Show()
        end
    end
end)
animationFrame:Hide()

local currentAnimationAnchor = nil
local function pool_object_Events(self, event, unit, ...)
    arg4, arg5, arg6 = ...
    if event == "UNIT_SPELLCAST_SENT" and arg6 == 1804 then
        currentAnimationAnchor = {self:GetPoint()}
        self:SetScript("OnEvent", nil)
    end
end
local function pool_clear(framePool, frame)
    frame:SetScript("OnUpdate", nil)
    frame:SetScript("OnEvent", nil)
    frame:ClearAllPoints()
    frame.texture:ClearAllPoints()
    frame.texture:Hide()
    frame:Hide()
end
local function pool_create(frame)
    frame:SetFrameStrata("HIGH")
    frame:RegisterForClicks("RightButtonUp")
    frame:RegisterEvent("UNIT_SPELLCAST_SENT")
    frame:SetAttribute("type", "macro")
    frame:SetScript("OnEnter", function(self)
        if animationFrame.anim:IsPlaying() then return end
        relocateImageFrame({self:GetPoint()})
    end)
    frame:SetScript("OnLeave", function(self)
        imageFrame:ClearAllPoints()
        imageFrame.currentAnchor = nil
        imageFrame:Hide()
    end)
    frame:HookScript("OnClick", function(self)
        currentAnimationAnchor = {self:GetPoint()}
        self:SetScript("OnEvent", pool_object_Events)
        Thievery_SingleDelayer(0.3, 0, 0.1, self, nil, function()
            currentAnimationAnchor = nil
            self:SetScript("OnEvent", nil)
        end)
    end)
    frame:SetPassThroughButtons("LeftButton", "MiddleButton", "Button4", "Button5")
    -- frame:EnableMouseMotion(false)
    frame:SetPropagateMouseMotion(true)
    frame.texture = frame:CreateTexture(nil, "ARTWORK")
    frame.texture:SetColorTexture(1, 0, 0, 0.3)
    frame.texture:Hide()
end
-- Make a separate frame pool for each bag slot just in case
Thievery_LockpickOverlays = {}
for i=1,6,1 do
    Thievery_LockpickOverlays[i - 1] = CreateFramePool("Button", Thievery_LockpickOverlays[i - 1], "SecureActionButtonTemplate", pool_clear, false, pool_create)
end

function checkLocked(bagID, slotID)
    return true
    -- local locked = false
    -- local lines = C_TooltipInfo.GetBagItem(bagID, slotID).lines
    -- for i, line in pairs(lines) do
    --     -- LOCKED -> from GlobalStrings.lua. Defaults to "Locked" for English clients.
    --     if line.leftText == LOCKED then
    --         locked = true
    --     end
    -- end
    -- return locked
end
local function handleSlot(itemButton, bagID, slotID)
    if InCombatLockdown() then return end
    if not checkLocked(bagID, slotID) then 
        -- lockbox is already unlocked
        return
    end
    if not itemButton:IsShown() or not itemButton:IsVisible() then
        print("item button is not visible, can't create overlay frame")
        return
    end
    
    local debugInfo = {}
    debugInfo["Debug Name"] = itemButton:GetDebugName()
    local point = {itemButton:GetPoint()}
    debugInfo["Point"] = {point[1], point[2]:GetDebugName(), point[3], point[4], point[5]}
    debugInfo["Size"] = itemButton:GetSize()
    local _, _, width, height = itemButton:GetScaledRect()
    debugInfo["Real Size"] = {width, height}
    local borderScale = itemButton.IconBorder:GetScale()
    debugInfo["IconBorder Scale:"] = {borderScale}
    Thievery_BetaDump(debugInfo)

    local overlayButton = Thievery_LockpickOverlays[bagID]:Acquire()
    overlayButton:ClearAllPoints()
    overlayButton:SetPoint("CENTER", itemButton, "CENTER")
    overlayButton:SetSize(width*borderScale, height*borderScale)
    -- Only show the red overlay texture if debug mode is on
    if Thievery_Config.Checkboxes[1].debugMode == true then
        overlayButton.texture:SetAllPoints(overlayButton)
        overlayButton.texture:Show()
    end
    overlayButton:Show()
    local spellName = C_Spell.GetSpellName(1804)
    local line1 = "/cast " .. spellName
    local line2 = "/use " .. " " .. bagID .. " " .. slotID
    overlayButton:SetAttribute("macrotext", line1 .. "\n" .. line2)
end
--_____________________________________________________________________________________________________________________________
-- Need to have 'containerFrame' in the Payload IN CLASSIC because there is no way to get the right containerFrame from bagID
-- _G["ContainerFrame" .. bagID] --> Does NOT always work 
-- The frames are not tied to their bagIDs, whichever bag you open first is ContainerFrame1.
--_____________________________________________________________________________________________________________________________
local function scanDone_Callback(event, bagID, bagContents, containerFrame)
    if InCombatLockdown() then return end
    if not bagID then return end
    if not containerFrame or not containerFrame:IsShown() or not containerFrame:IsVisible() then
        -- If a bag isn't visible, don't take any action
        -- print("event fired, yet containerFrame isn't there")
        -- return
    end
    -- print("callback on isle: ", bagID)
    -- Iterate through all the valid item slots in bags - Can't use EnumerateValidItems on Classic
    local numSlots = C_Container.GetContainerNumSlots(bagID)
	for buttonID = 1, numSlots do
		local id = C_Container.GetContainerItemID(bagID, buttonID);
        -- to check if slot is empty
		if id and bagContents[buttonID] then
            -- FOR SOME REASON IN CLASSIC THE ITEM BUTTONS ARE ORDERED BACKWARDS SO WE NEED TO EXTRACT FROM NUMSLOTS AND +1 - WHY? WHY IS THIS THE CASE? WHY...
            local itemButton = _G[containerFrame:GetDebugName() .. "Item" .. numSlots - buttonID + 1]
            -- to check if the itemButton frame exists and is valid(has a name)
            if itemButton and itemButton:GetDebugName() then
                -- print(itemButton:GetDebugName())
                handleSlot(itemButton, bagID, buttonID)
            end
		end
	end
end

--_____________________________________________________________________________________________________________________________
-- Need to have 'containerFrame' in the Payload IN CLASSIC because there is no way to get the right containerFrame from bagID
-- _G["ContainerFrame" .. bagID] --> Does NOT always work 
-- The frames are not tied to their bagIDs, whichever bag you open first is ContainerFrame1.
--_____________________________________________________________________________________________________________________________
local function clearOverlays(event, bagID, containerFrame)
    if InCombatLockdown() then return end
    if not bagID then return end
    if not containerFrame then
        print("bag clear event fired, yet containerFrame isn't there")
        return
    end
    Thievery_LockpickOverlays[bagID]:ReleaseAll()
end



local function lockpicking_Events(self, event, unit, ...)
    local arg4, arg5 = ...
    if event == "PLAYER_REGEN_DISABLED" then
        for i=1,6,1 do 
            clearOverlays(nil, i-1)
        end
    elseif event == "PLAYER_REGEN_ENABLED" then
        bagTrackingFrame:UpdateAll()
    elseif event == "UNIT_SPELLCAST_START" and unit == "player" and arg5 == 1804 then
        -- start animation if you can
        if Thievery_Config.Checkboxes[2].lockpickAnim == true and currentAnimationAnchor then
            local itemButton = currentAnimationAnchor[2]
            if not itemButton or not itemButton:IsShown() or not itemButton:IsVisible() then 
                Thievery_BetaPrint("Lockpick animation couldn't be started, item overlay frame doesn't exist or isn't visible")
                return
            end
            local _, _, itemButton_Width, itemButtonHeight = itemButton:GetScaledRect()
            animationFrame:ClearAllPoints()
            animationFrame:SetSize(itemButton_Width*ANIMATION_SIZE_MULTIPLIER, itemButtonHeight*ANIMATION_SIZE_MULTIPLIER)
            animationFrame.texture:SetSize(itemButton_Width*ANIMATION_SIZE_MULTIPLIER, itemButtonHeight*ANIMATION_SIZE_MULTIPLIER)
            animationFrame:SetPoint(currentAnimationAnchor[1], itemButton, currentAnimationAnchor[3], currentAnimationAnchor[4], currentAnimationAnchor[5])
            local _, _, realWidth = animationFrame.texture:GetScaledRect()
            Thievery_BetaPrint("Animation frame texture REAL size: ", realWidth)
            animationFrame:Show()
            imageFrame:Hide()
        end
    elseif (event == "UNIT_SPELLCAST_INTERRUPTED" or event == "UNIT_SPELLCAST_FAILED") and unit == "player" and arg5 == 1804 then
        -- stop animation, clear anchor
        animationFrame:ClearAllPoints()
        animationFrame:Hide()
        currentAnimationAnchor = nil
        Thievery_BetaPrint("Lockpick Interrupted/Failed")
    elseif event == "UNIT_SPELLCAST_STOP" then
        -- print("stopped")
    elseif event == "UNIT_SPELLCAST_SUCCEEDED" and unit == "player" and arg5 == 1804 then
        -- Need to delay a little bit for the tooltip info to be properly updated 
        Thievery_SingleDelayer(0.5, 0, 0.1, bagTrackingFrame, nil, function()
            if not InCombatLockdown() then 
                bagTrackingFrame:UpdateAll()
                Thievery_BetaPrint("Lockpick successful!")
                animationFrame:ClearAllPoints()
                animationFrame:Hide()
                currentAnimationAnchor = nil
            end
        end)
        Thievery_BetaPrint("Lockpick cast succeeded")
        if Thievery_Config.Checkboxes[2].lockpickSound == true then
            PlaySoundFile("Interface/Addons/Thievery/sounds/wooden-trunk-latch-1-floraphonic-pixabay.mp3", "SFX")
        end
    elseif event == "BAG_UPDATE_COOLDOWN" then
        -- Triggers right after UNIT_SPELLCAST_SUCCEEDED with pick lock, but still before the tooltip info is updated
    end
end
bagTrackingFrame:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
bagTrackingFrame:RegisterEvent("UNIT_SPELLCAST_START")
bagTrackingFrame:RegisterEvent("UNIT_SPELLCAST_STOP")
bagTrackingFrame:RegisterEvent("UNIT_SPELLCAST_INTERRUPTED")
bagTrackingFrame:RegisterEvent("UNIT_SPELLCAST_FAILED")
bagTrackingFrame:RegisterEvent("BAG_UPDATE_COOLDOWN")
bagTrackingFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
bagTrackingFrame:RegisterEvent("PLAYER_REGEN_ENABLED")

function Thievery_ActivateLockpicking(enable)
    if enable == true then
        bagTrackingFrame:SetScript("OnEvent", lockpicking_Events)
        bagTrackingFrame.RegisterCallback(bagTrackingFrame, "Lego-BagScanDone-Thievery", scanDone_Callback)
        bagTrackingFrame.RegisterCallback(bagTrackingFrame, "Lego-BagCleared-Thievery", clearOverlays)
        bagTrackingFrame:UpdateAll()
    elseif enable == false then
        for i=1,6,1 do 
            clearOverlays(nil, i-1)
        end
        bagTrackingFrame:SetScript("OnEvent", nil)
        bagTrackingFrame.UnregisterCallback(bagTrackingFrame, "Lego-BagScanDone-Thievery", scanDone_Callback)
        bagTrackingFrame.UnregisterCallback(bagTrackingFrame, "Lego-BagCleared-Thievery", clearOverlays)
    end
end