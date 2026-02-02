local PICKPOCKET_SPELLID = 921

local target = Thievery_Target

Thievery_PPTimerTable = {

}

local TEN_MIN = 600
function Thievery_UpdatePPTimers(targetGUID)
    if next(Thievery_PPTimerTable) == nil then return end
    local targetCountDown 
    local currentTime = GetTime()
    for guid, anoToki in pairs(Thievery_PPTimerTable) do
        if anoToki == nil then Thievery_PPTimerTable[guid] = nil end
        local countDown = (anoToki + TEN_MIN ) - currentTime
        if countDown <= 0 then
            Thievery_BetaPrint("Removing: " .. guid .. " from timer table.")
            Thievery_PPTimerTable[guid] = nil
        else
            if guid == targetGUID then
                targetCountDown = countDown
            end
        end
    end
    return targetCountDown
end


local ppTarget = nil
local awaitingLootFrame = false
local awaitingClose = false
local function timerEvents(self, event, unit, ...)
    local arg4, arg5, arg6 = ...
    unit, arg4, arg5, arg6 = Thievery_ScrubSecret(unit, arg4, arg5, arg6)
    if event == "UNIT_SPELLCAST_SUCCEEDED" and arg5 == PICKPOCKET_SPELLID then
        if target.guid then
            ppTarget = target.guid 
        end
        awaitingLootFrame = true

        Thievery_SingleDelayer(0.5, 0, 0.01, self, nil, function()
            awaitingLootFrame = false
        end)
    elseif event == "LOOT_OPENED" then
        if awaitingLootFrame then
            if ppTarget and ppTarget == target.guid then
                self:SetScript("OnUpdate", nil)
                local autoLoot = unit
                if autoLoot == true then
                    Thievery_PPTimerTable[ppTarget] = GetTime()
                    Thievery_BetaTableToString(Thievery_PPTimerTable)
                    ppTarget = nil
                    awaitingLootFrame = false
                    awaitingClose = false
                else
                    awaitingClose = true
                end
            else
                Thievery_BetaPrint("target changed before loot opened")
                ppTarget = nil
            end
        end
        awaitingLootFrame = false
    elseif event == "LOOT_CLOSED" then
        if awaitingClose then
            if ppTarget and ppTarget == target.guid then
                Thievery_PPTimerTable[ppTarget] = GetTime()
                Thievery_BetaTableToString(Thievery_PPTimerTable)
                Thievery_BetaPrint("START TIMER!")
            else
                Thievery_BetaPrint("target changed before loot frame closed")
            end
        end
        ppTarget = nil
        awaitingLootFrame = false
        awaitingClose = false
        Thievery_BetaPrint("loot frame closing")
        Thievery_UpdateState(Thievery_PickpocketButton, true)
    end
end

local timerFrame = CreateFrame("Frame")
timerFrame:RegisterEvent("LOOT_READY")
timerFrame:RegisterEvent("LOOT_OPENED")
timerFrame:RegisterEvent("LOOT_SLOT_CLEARED")
timerFrame:RegisterEvent("LOOT_CLOSED")
timerFrame:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
timerFrame:SetScript("OnEvent", timerEvents)

--/dump LootFrame.ScrollBox:GetDataProvider():IsEmpty()

