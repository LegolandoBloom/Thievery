

local speedyActive = false
function Thievery_ToggleSpeedy(activate)
    if InCombatLockdown() then return end
    if activate == true then
        Thievery_SavedCVars.SpeedyMode.softEnemy = GetCVar("SoftTargetEnemy")
        SetCVar("SoftTargetEnemy", "3")
        Thievery_SavedCVars.SpeedyMode.softEnemyRange = GetCVar("SoftTargetEnemyRange")
        if ppTalent == true then
            SetCVar("SoftTargetEnemyRange", "15")
        else
            SetCVar("SoftTargetEnemyRange", "15")
        end
        Thievery_SavedCVars.SpeedyMode.softEnemyArc = GetCVar("SoftTargetEnemyArc")
        SetCVar("SoftTargetEnemyArc", "2")
        
        Thievery_SavedCVars.SpeedyMode.autoLootRate = GetCVar("autoLootRate")
        SetCVar("autoLootRate", "50")
        Thievery_SavedCVars.SpeedyMode.autoLootDefault = GetCVar("autoLootDefault")
        SetCVar("autoLootDefault", "1")
        speedyActive = true
        Thievery_BetaPrint("speedy mode active")
    elseif activate == false then
        Thievery_BetaTableToString(Thievery_SavedCVars.SpeedyMode)
        if Thievery_SavedCVars.SpeedyMode.softEnemy ~= nil then SetCVar("SoftTargetEnemy", Thievery_SavedCVars.SpeedyMode.softEnemy) end
        Thievery_SavedCVars.SpeedyMode.softEnemy = nil
        if Thievery_SavedCVars.SpeedyMode.softEnemyRange ~= nil then SetCVar("SoftTargetEnemyRange", Thievery_SavedCVars.SpeedyMode.softEnemyRange) end
        Thievery_SavedCVars.SpeedyMode.softEnemyRange = nil
        if Thievery_SavedCVars.SpeedyMode.softEnemyArc ~= nil then SetCVar("SoftTargetEnemyArc", Thievery_SavedCVars.SpeedyMode.softEnemyArc) end
        Thievery_SavedCVars.SpeedyMode.softEnemyArc = nil
        if Thievery_SavedCVars.SpeedyMode.autoLootRate ~= nil then SetCVar("autoLootRate", Thievery_SavedCVars.SpeedyMode.autoLootRate) end
        Thievery_SavedCVars.SpeedyMode.autoLootRate = nil
        if Thievery_SavedCVars.SpeedyMode.autoLootDefault ~= nil then SetCVar("autoLootDefault", Thievery_SavedCVars.SpeedyMode.autoLootDefault) end
        Thievery_SavedCVars.SpeedyMode.autoLootDefault = nil
        speedyActive = false
        Thievery_BetaPrint("speedy mode inactive")
    end
end
function Thievery_SpeedyEvents(self, event, unit, ...)
    local arg4, arg5 = ...
    if event == "UNIT_SPELLCAST_SUCCEEDED" and arg5 == 921 then
        if Thievery_Config.Checkboxes.speedyMode == true and speedyActive == false and IsStealthed() then
            Thievery_ToggleSpeedy(true)
        end
    elseif event == "UPDATE_STEALTH" then
        if speedyActive and IsStealthed() == false then
            Thievery_ToggleSpeedy(false)
        end
    elseif event == "PLAYER_REGEN_ENABLED" then
        if speedyActive and IsStealthed() == false then
            Thievery_ToggleSpeedy(false)
        end
    end
end

local speedyFrame = CreateFrame("Frame")
speedyFrame:RegisterEvent("UPDATE_STEALTH")
speedyFrame:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
speedyFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
speedyFrame:SetScript("OnEvent", Thievery_SpeedyEvents)

--C_Traits.GetSubTreeInfo(C_ClassTalents.GetActiveConfigID(), 51)
--C_ClassTalents.GetHeroTalentSpecsForClassSpec(C_ClassTalents.GetActiveConfigID())

local function resetToDefaults()
    SetCVar("SoftTargetEnemy", "1")
    SetCVar("SoftTargetEnemyRange", "45")
    SetCVar("SoftTargetEnemyArc", "2")
    SetCVar("autoLootRate", "150")
    SetCVar("autoLootDefault", "0")
    print("reset cvars to defaults")
end
SLASH_THIEVERYSPEEDYDEFAULTS1 = "/teefspeedef"
SlashCmdList["THIEVERYSPEEDYDEFAULTS"] = resetToDefaults