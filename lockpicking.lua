local ANIMATION_SIZE_MULTIPLIER = 1.4

local LP = {}
--____________________________________________________________________________________________ --
--_____________TRACKING PART (with Overlay Textures & OnClick SecureActionButton)_____________ --
--____________________________________________________________________________________________ --

local bagTrackingFrame = CreateFrame("Frame", "BagTrackerExample_BagTracker", UIParent, "Legolando_BagTrackerTemplate_Thievery")
bagTrackingFrame.scanBagsSeparately = false
bagTrackingFrame.reScanEveryOpenBag = false
bagTrackingFrame.clearOnClose = false
bagTrackingFrame.debugLevel = 1
bagTrackingFrame.filters ={
    -- stackCount = {operator = '>', number = 1},
    --isLocked = false,
    -- quality = 4,
	--IsReadable = false,
	-- hyperlink = {link1, link2, link3},
	-- isFiltered = false,
	-- hasNoValue = false,
	itemID = {6948, 3268, 5503, 16885, 63349, 220376, 5759, 5758, 4636, 68729, 4638, 4634, 5760, 29569, 203743, 16884, 190954, 116920, 88567, 4632, 43624, 31952, 121331, 16882, 169475, 4637, 4633, 43622, 186161, 43575, 88165, 180533, 186160, 198657, 188787, 7209, 179311, 194037, 45986, 13918, 180522, 12033, 16883, 180532, 141596, 13875, 6354, 6355, 91331, 85118, 91330, 84897, 106895, 120065, 191296, 91799, 84895, 91329, 91334, 115066, 141608, 204307, 91332, 91333}
	-- isBound = true,
}
bagTrackingFrame:Init()

local currentAnimationAnchor = nil

local trackedItems = {}
--_____________________________________________________________________________________________________________________________
-- Need to have 'containerFrame' in the Payload IN CLASSIC because there is no way to get the right containerFrame from bagID
-- _G["ContainerFrame" .. bagID] --> Does NOT always work 
-- The frames are not tied to their bagIDs, whichever bag you open first is ContainerFrame1.
--_____________________________________________________________________________________________________________________________
function LP.scanDone_Callback(event, bagID, bagContents, containerFrame)
    if not bagID then
        print("not bag ID") return 
    end
    if bagContents == nil then
        print("nil for ", bagID)
    end
    if next(bagContents) == nil then
        print("empty for ", bagID)
    end
    trackedItems[bagID] = bagContents
end

--_____________________________________________________________________________________________________________________________
-- Need to have 'containerFrame' in the Payload IN CLASSIC because there is no way to get the right containerFrame from bagID
-- _G["ContainerFrame" .. bagID] --> Does NOT always work 
-- The frames are not tied to their bagIDs, whichever bag you open first is ContainerFrame1.
--_____________________________________________________________________________________________________________________________
function LP.bagCleared_Callback(event, bagID)
    if not bagID then return end
    trackedItems[bagID] = {}
    if not InCombatLockdown() then 
        LP.clearOverlayButton()
    end
end

function LP.overlay_Events(self, event, unit, ...)
    local arg4, arg5, arg6 = ...
    if event == "UNIT_SPELLCAST_SENT" and arg6 == 1804 then
        currentAnimationAnchor = {self:GetPoint()}
        self:SetScript("OnEvent", nil)
    end
end


local lockpickOverlayButton = CreateFrame("Button", "Thievery_LockpickOverlayButton", UIParent, "SecureActionButtonTemplate")
lockpickOverlayButton:SetFrameStrata("DIALOG")
-- lockpickOverlayButton:SetIgnoreParentScale(true)
lockpickOverlayButton:RegisterForClicks("RightButtonUp")
lockpickOverlayButton:RegisterEvent("UNIT_SPELLCAST_SENT")
lockpickOverlayButton:SetAttribute("type", "macro")
lockpickOverlayButton:HookScript("OnClick", function(self)
    currentAnimationAnchor = {self:GetPoint()}
    self:SetScript("OnEvent", LP.overlay_Events)
    print("clicked")
    -- Thievery_SingleDelayer(0.3, 0, 0.1, self, nil, function()
    --     currentAnimationAnchor = nil
    --     self:SetScript("OnEvent", nil)
    -- end)
end)
lockpickOverlayButton:SetPassThroughButtons("LeftButton", "MiddleButton", "Button4", "Button5")
-- frame:EnableMouseMotion(false)
lockpickOverlayButton:SetPropagateMouseMotion(true)
lockpickOverlayButton.debugTexture = lockpickOverlayButton:CreateTexture(nil, "ARTWORK")
lockpickOverlayButton.debugTexture:SetColorTexture(1, 0, 0, 0.3)
lockpickOverlayButton.debugTexture:Hide()

lockpickOverlayButton.lockpickTexture = lockpickOverlayButton:CreateTexture("Thievery_LockpickOverlayTexture", "OVERLAY")
--________________________________________________________________________________
-- Both lockpickTexture and animationFrame use a 64x64 texture, but animation frame
-- is not parented to lockpickOverlay, so lockpickTexture must ignore parent scale 
-- and use 'Real Size' from GetScaledRect() for easy parity with the animation
-- to change both their scale at the same time, use ANIMATION_SIZE_MULTIPLIER
--________________________________________________________________________________
lockpickOverlayButton.lockpickTexture:SetIgnoreParentScale(true)
lockpickOverlayButton.lockpickTexture:SetPoint("CENTER")
lockpickOverlayButton.lockpickTexture:SetTexture("Interface/AddOns/Thievery/images/lockpick-preanim.png")
lockpickOverlayButton.lockpickTexture:SetAlpha(0.8)
lockpickOverlayButton.currentAnchor = nil


local animationFrame = CreateFrame("Frame", "Thievery_LockpickAnim", UIParent, "Thievery_LockpickAnimTemplate")
animationFrame:SetFrameStrata("HIGH")
animationFrame:SetPoint("CENTER", UIParent, "CENTER")
animationFrame:SetIgnoreParentScale(true) 
animationFrame.anim:SetScript("OnStop", function(self)
    local currentAnchor = lockpickOverlayButton.currentAnchor
    if currentAnchor then
        if currentAnchor[2]:IsMouseOver() then
            lockpickOverlayButton.texture:Show()
        end
    end
end)
animationFrame:Hide()

function LP.relocateOverlayButton(itemButton, bagID, slotID)
    local debugInfo = {}
    debugInfo["Debug Name"] = itemButton:GetDebugName()
    local point = {itemButton:GetPoint()}
    debugInfo["Point"] = {point[1], point[2]:GetDebugName(), point[3], point[4], point[5]}
    local width, height = itemButton:GetSize()
    debugInfo["Size"] = {width, height}
    local _, _, realWidth, realHeight = itemButton:GetScaledRect()
    debugInfo["Real Size"] = {realWidth, realHeight}
    local borderScale = itemButton.IconBorder:GetScale()
    debugInfo["IconBorder Scale:"] = {borderScale}
    Thievery_BetaDump(debugInfo)

    lockpickOverlayButton:ClearAllPoints()
    lockpickOverlayButton:SetPoint("CENTER", itemButton, "CENTER")
    lockpickOverlayButton:SetSize(width*borderScale, height*borderScale)
    Thievery_BetaPrint("Set Overlay size to: ", lockpickOverlayButton:GetSize())
    -- Only show the red overlay texture if debug mode is on
    if Thievery_Config.Checkboxes[1].debugMode == true then
        lockpickOverlayButton.debugTexture:SetAllPoints(lockpickOverlayButton)
        lockpickOverlayButton.debugTexture:Show()
    end

    --________________________________________________________________________________
    -- Both lockpickTexture and animationFrame use a 64x64 texture, but animation frame
    -- is not parented to lockpickOverlay, so lockpickTexture must ignore parent scale 
    -- and use 'Real Size' from GetScaledRect() for easy parity with the animation
    -- to change both their scale at the same time, use ANIMATION_SIZE_MULTIPLIER
    --________________________________________________________________________________
    lockpickOverlayButton.lockpickTexture:SetSize(realWidth*ANIMATION_SIZE_MULTIPLIER, realHeight*ANIMATION_SIZE_MULTIPLIER)
    lockpickOverlayButton:Show()

    local spellName = C_Spell.GetSpellName(1804)
    local line1 = "/cast " .. spellName
    local line2 = "/use " .. " " .. bagID .. " " .. slotID
    lockpickOverlayButton:SetAttribute("macrotext", line1 .. "\n" .. line2)
end

function LP.clearOverlayButton()
    lockpickOverlayButton:ClearAllPoints()
    lockpickOverlayButton:ClearAttribute("macrotext")
    lockpickOverlayButton:Hide()
end

local function checkLockedTooltip()
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

hooksecurefunc("ContainerFrameItemButton_OnEnter", function(itemButton, ...)
    if InCombatLockdown() then return end
    if not itemButton then return end
    local slotID = itemButton:GetID()
    local bagID = itemButton:GetParent():GetID()
    if not trackedItems or not trackedItems[bagID] or not trackedItems[bagID][slotID] then return end
    if not GameTooltip or not GameTooltip:IsShown() or not GameTooltip:IsVisible() then return end
    if checkLockedTooltip() == false then return end
    -- print(GameTooltipTextLeft1:GetText(), GameTooltipTextLeft2:GetText(), GameTooltipTextLeft3:GetText(), GameTooltipTextLeft4:GetText()
    -- if animationFrame.anim:IsPlaying() then return end
    LP.relocateOverlayButton(itemButton, bagID, slotID)
end)
hooksecurefunc("ContainerFrameItemButton_OnLeave", function(itemButton, ...)
    if InCombatLockdown() then return end
    if lockpickOverlayButton:IsShown() then
        LP.clearOverlayButton()
    end
end)


local function lockpicking_Events(self, event, unit, ...)
    local arg4, arg5, arg6 = ...
    if event == "PLAYER_REGEN_DISABLED" then
        LP.clearOverlayButton()
    elseif event == "PLAYER_REGEN_ENABLED" then
        -- do nothing
    elseif event == "UNIT_SPELLCAST_SENT" and unit == "player" and arg6 == 1784 then
        -- start animation if you can
        print("spellcast started")
        if Thievery_Config.Checkboxes[2].lockpickAnim == true and currentAnimationAnchor then
            local itemButton = currentAnimationAnchor[2]
            if not itemButton or not itemButton:IsShown() or not itemButton:IsVisible() then 
                Thievery_BetaPrint("Lockpick animation couldn't be started, item overlay frame doesn't exist or isn't visible")
                return
            end
            local _, _, realWidth, realHeight = itemButton:GetScaledRect()
            animationFrame:ClearAllPoints()
            animationFrame:SetSize(realWidth*ANIMATION_SIZE_MULTIPLIER, realHeight*ANIMATION_SIZE_MULTIPLIER)
            animationFrame.texture:SetSize(realWidth*ANIMATION_SIZE_MULTIPLIER, realHeight*ANIMATION_SIZE_MULTIPLIER)
            animationFrame:SetPoint(currentAnimationAnchor[1], itemButton, currentAnimationAnchor[3], currentAnimationAnchor[4], currentAnimationAnchor[5])
            local _, _, animationRealWidth = animationFrame.texture:GetScaledRect()
            Thievery_BetaPrint("Animation frame texture REAL size: ", animationRealWidth)
            animationFrame:Show()
        end
    elseif (event == "UNIT_SPELLCAST_INTERRUPTED" or event == "UNIT_SPELLCAST_FAILED") and unit == "player" and arg5 == 1784 then
        -- stop animation, clear anchor
        animationFrame:ClearAllPoints()
        animationFrame:Hide()
        currentAnimationAnchor = nil
        Thievery_BetaPrint("Lockpick Interrupted/Failed")
    elseif event == "UNIT_SPELLCAST_STOP" then
        -- print("stopped")
    elseif event == "UNIT_SPELLCAST_SUCCEEDED" and unit == "player" and arg5 == 1784 then
        -- Need to delay a little bit for the tooltip info to be properly updated 
        Thievery_SingleDelayer(2, 0, 0.5, bagTrackingFrame, nil, function()
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
bagTrackingFrame:RegisterEvent("UNIT_SPELLCAST_SENT")
bagTrackingFrame:RegisterEvent("UNIT_SPELLCAST_STOP")
bagTrackingFrame:RegisterEvent("UNIT_SPELLCAST_INTERRUPTED")
bagTrackingFrame:RegisterEvent("UNIT_SPELLCAST_FAILED")
bagTrackingFrame:RegisterEvent("BAG_UPDATE_COOLDOWN")
bagTrackingFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
bagTrackingFrame:RegisterEvent("PLAYER_REGEN_ENABLED")

function Thievery_ActivateLockpicking(enable)
    if enable == true then
        bagTrackingFrame:SetScript("OnEvent", lockpicking_Events)
        bagTrackingFrame.RegisterCallback(bagTrackingFrame, "Lego-BagScanDone-Thievery", LP.scanDone_Callback)
        bagTrackingFrame.RegisterCallback(bagTrackingFrame, "Lego-BagCleared-Thievery", LP.bagCleared_Callback)
        bagTrackingFrame:UpdateAll()
    elseif enable == false then
        LP.clearOverlayButton()
        bagTrackingFrame:SetScript("OnEvent", nil)
        bagTrackingFrame.UnregisterCallback(bagTrackingFrame, "Lego-BagScanDone-Thievery", LP.scanDone_Callback)
        bagTrackingFrame.UnregisterCallback(bagTrackingFrame, "Lego-BagCleared-Thievery", LP.bagCleared_Callback)
    end
end