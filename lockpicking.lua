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
	itemID = {16885, 63349, 220376, 5759, 5758, 4636, 68729, 4638, 4634, 5760, 29569, 203743, 16884, 190954, 116920, 88567, 4632, 43624, 31952, 121331, 16882, 169475, 4637, 4633, 43622, 186161, 43575, 88165, 180533, 186160, 198657, 188787, 7209, 179311, 194037, 45986, 13918, 180522, 12033, 16883, 180532, 141596, 13875, 6354, 6355, 91331, 85118, 91330, 84897, 106895, 120065, 191296, 91799, 84895, 91329, 91334, 115066, 141608, 204307, 91332, 91333}
	-- isBound = true,
}

local imageFrame = CreateFrame("Frame")
imageFrame:SetFrameStrata("HIGH")
imageFrame:SetSize(32,32)
imageFrame.texture = imageFrame:CreateTexture("ayoawhrf", "OVERLAY")
imageFrame.texture:SetAllPoints()
imageFrame.texture:SetSize(32, 32)
imageFrame.texture:SetTexture("Interface/AddOns/Thievery/images/lockpickcursor.png")
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
    frame:SetAttribute("type", "macro")
    frame:SetScript("OnEnter", function(self)
        imageFrame:ClearAllPoints()
        imageFrame:SetPoint("CENTER", self, "CENTER")
        imageFrame:Show()
    end)
    frame:SetScript("OnLeave", function(self)
        imageFrame:ClearAllPoints()
        imageFrame:Hide()
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
    local locked = false
    local lines = C_TooltipInfo.GetBagItem(bagID, slotID).lines
    for i, line in pairs(lines) do
        -- LOCKED -> from GlobalStrings.lua. Defaults to "Locked" for English clients.
        if line.leftText == LOCKED then
            locked = true
        end
    end
    return locked
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
    local overlayButton = Thievery_LockpickOverlays[bagID]:Acquire()
    overlayButton:ClearAllPoints()
    overlayButton:SetPoint("CENTER", itemButton, "CENTER")
    local width, height = itemButton.IconBorder:GetSize()
    local scale = itemButton.IconBorder:GetScale()
    overlayButton:SetSize(width*scale*0.8, height*scale*0.8)
    -- Only show the red overlay texture if debug mode is on
    if Thievery_Config.Checkboxes.debugMode == true then
        overlayButton.texture:SetAllPoints(overlayButton)
        overlayButton.texture:Show()
    end
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




local function lockpicking_Events(self, event, unit, ...)
    local arg4, arg5 = ...
    if event == "PLAYER_REGEN_DISABLED" then
        for i=1,6,1 do 
            clearOverlays(nil, i-1)
        end
    elseif event == "PLAYER_REGEN_ENABLED" then
        bagTrackingFrame:UpdateAll()
    elseif event == "UNIT_SPELLCAST_SUCCEEDED" and unit == "player" and arg5 == 1804 then
        -- Need to delay a little bit for the tooltip info to be properly updated 
        Thievery_SingleDelayer(0.5, 0, 0.1, bagTrackingFrame, nil, function()
            if not InCombatLockdown() then 
                bagTrackingFrame:UpdateAll()
                Thievery_BetaPrint("Lockpick successful!")
            end
        end)
    elseif event == "BAG_UPDATE_COOLDOWN" then
        -- Triggers right after UNIT_SPELLCAST_SUCCEEDED with pick lock, but still before the tooltip info is updated
    end
end
bagTrackingFrame:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
bagTrackingFrame:RegisterEvent("BAG_UPDATE_COOLDOWN")
bagTrackingFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
bagTrackingFrame:RegisterEvent("PLAYER_REGEN_ENABLED")

function Thievery_ActivateLockpicking(enable)
    if enable == true then
        bagTrackingFrame:SetScript("OnEvent", lockpicking_Events)
        bagTrackingFrame.RegisterCallback(bagTrackingFrame, "Lego-BagScanDone-YourAddon", scanDone_Callback)
        bagTrackingFrame.RegisterCallback(bagTrackingFrame, "Lego-BagCleared-YourAddon", clearOverlays)
        bagTrackingFrame:UpdateAll()
    elseif enable == false then
        for i=1,6,1 do 
            clearOverlays(nil, i-1)
        end
        bagTrackingFrame:SetScript("OnEvent", nil)
        bagTrackingFrame.UnregisterCallback(bagTrackingFrame, "Lego-BagScanDone-YourAddon", scanDone_Callback)
        bagTrackingFrame.UnregisterCallback(bagTrackingFrame, "Lego-BagCleared-YourAddon", clearOverlays)
    end
end