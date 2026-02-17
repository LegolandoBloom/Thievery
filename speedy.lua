local PICKPOCKET_SPELLID = 921


function Thievery_ToggleSpeedy(activate)
    if InCombatLockdown() then return end
    if activate == true then
        Thievery_TempCVarHandler:Set("SoftTargetEnemy", "SoftTargetEnemyRange", "SoftTargetEnemyArc", "autoLootRate", "autoLootDefault")
        Thievery_BetaPrint("speedy mode active")
    elseif activate == false then
        Thievery_TempCVarHandler:Release("SoftTargetEnemy", "SoftTargetEnemyRange", "SoftTargetEnemyArc", "autoLootRate", "autoLootDefault")
        Thievery_BetaPrint("speedy mode inactive")
    end
end
function Thievery_SpeedyEvents(self, event, unit, ...)
    local arg4, arg5, arg6 = ...
    unit, arg4, arg5, arg6 = Thievery_ScrubSecret(unit, arg4, arg5, arg6)
    if event == "UNIT_SPELLCAST_SUCCEEDED" and arg5 == PICKPOCKET_SPELLID then
        if Thievery_Config.Checkboxes[1].speedyMode == true and IsStealthed() then
            Thievery_ToggleSpeedy(true)
        end
    elseif event == "UPDATE_STEALTH" then
        if IsStealthed() == false then
            Thievery_ToggleSpeedy(false)
        end
    elseif event == "PLAYER_REGEN_ENABLED" then
        if IsStealthed() == false then
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