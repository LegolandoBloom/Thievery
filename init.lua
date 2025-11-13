-- 'tv' stands for thievery
local addonName, tv = ...

SLASH_THIEVERYCONFIGSHOW1 = "/thief"
SLASH_THIEVERYCONFIGSHOW2 = "/thievery"
SLASH_THIEVERYCONFIGSHOW3 = "/teef"
SlashCmdList["THIEVERYCONFIGSHOW"] = function() 
    Thievery_ConfigPanel:Show()
end

function Thievery_CheckVersion()

end




if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
    tv.gameVersion = 1
elseif WOW_PROJECT_ID == WOW_PROJECT_CATACLYSM_CLASSIC or WOW_PROJECT_ID == 19 then
    tv.gameVersion = 2
elseif WOW_PROJECT_ID == WOW_PROJECT_CLASSIC then
    tv.gameVersion = 3
else
    tv.gameVersion = 0
end


Thievery_UI = {
    VisualLocation = {},
}

Thievery_Config ={
    ppKey = nil,
    Checkboxes = {},
}

Thievery_SavedCVars = {
    SpeedyMode = {},
}

function Thievery_SavedVariables()
    if not Thievery_UI then
        Thievery_UI = {}
    end
    if not Thievery_UI.VisualLocation then
        Thievery_UI.VisualLocation = {}
    end

    if not Thievery_Config then
        Thievery_Config = {}
    end
    if not Thievery_Config.Checkboxes then
        Thievery_Config.Checkboxes = {}
    end
    if not Thievery_Config.Checkboxes[1] then
        Thievery_Config.Checkboxes[1] = {}
    end
    if Thievery_Config.Checkboxes[1].speedyMode == nil then
        Thievery_Config.Checkboxes[1].speedyMode = false
    end
    if Thievery_Config.Checkboxes[1].playSound == nil then
        Thievery_Config.Checkboxes[1].playSound = true
    end
    if Thievery_Config.Checkboxes[1].enableSap == nil then
        Thievery_Config.Checkboxes[1].enableSap = false
    end
    if Thievery_Config.Checkboxes[1].lockpicking == nil then
        Thievery_Config.Checkboxes[1].lockpicking = true
    end
    if Thievery_Config.Checkboxes[1].debugMode == nil then
        Thievery_Config.Checkboxes[1].debugMode = false
    end
    if not Thievery_Config.Checkboxes[2] then
        Thievery_Config.Checkboxes[2] = {}
    end
    if Thievery_Config.Checkboxes[2].lockpicking == nil then
        Thievery_Config.Checkboxes[2].lockpicking = true
    end
    if Thievery_Config.Checkboxes[2].lockpickAnim == nil then
        Thievery_Config.Checkboxes[2].lockpickAnim = true
    end
    if Thievery_Config.Checkboxes[2].lockpickSound == nil then
        Thievery_Config.Checkboxes[2].lockpickSound = true
    end

    if not Thievery_SavedCVars then
        Thievery_SavedCVars = {}
    end
    if not Thievery_SavedCVars.SpeedyMode then
        Thievery_SavedCVars.SpeedyMode = {}
    end
end

-- not a saved variable
Thievery_Target = {}

function Thievery_SingleDelayer(delay, timeElapsed, elapsedThreshhold, delayFrame, cycleFunk, endFunk)
    delayFrame:SetScript("OnUpdate", function(self, elapsed)
        timeElapsed = timeElapsed + elapsed
        if timeElapsed > elapsedThreshhold then
            if cycleFunk then
                if cycleFunk() == true then
                    --print("Breaking delayer")
                    self:SetScript("OnUpdate", nil)
                    return
                end
            end
            delay = delay - timeElapsed
            timeElapsed = 0
        end
        
        if delay <= 0 then
            self:SetScript("OnUpdate", nil)
            endFunk()
            return
        end
    end)
end

function Thievery_BetaPrint(text, ...)
    if Thievery_Config.Checkboxes[1].debugMode == true then
        print(text, ...)
    end
end

function Thievery_BetaDump(dump)
    if Thievery_Config.Checkboxes[1].debugMode == true then
        DevTools_Dump(dump)
    end
end

function Thievery_BetaTableToString(tbl)
    if Thievery_Config.Checkboxes[1].debugMode == true then
        local tableToString = ""
        for i, v in pairs(tbl) do
            local element = "[" .. tostring(i) .. ":" .. tostring(v) .. "]"
            tableToString = tableToString .. "  " .. element
        end
        print(tableToString)
    end
end

function Thievery_OnLoad(self)
    self:RegisterEvent("PLAYER_ENTERING_WORLD")
    self:RegisterEvent("ADDON_LOADED")
    self:SetScript("OnEvent", Thievery_EventLoader)
    Thievery_SetupConfigPanel_PreSavedVars(self)
    local playerClass = UnitClassBase("player")
    if playerClass ~= "ROGUE" then
        return
    end
    self.pickpocketButton:RegisterForClicks("AnyUp", "AnyDown")
    self.pickpocketButton:RegisterEvent("PLAYER_SOFT_INTERACT_CHANGED")
    self.pickpocketButton:RegisterEvent("PLAYER_SOFT_ENEMY_CHANGED")
    self.pickpocketButton:RegisterEvent("PLAYER_TARGET_CHANGED")
    self.pickpocketButton:RegisterEvent("UPDATE_STEALTH")
    self.pickpocketButton:RegisterEvent("PLAYER_REGEN_DISABLED")
    self.pickpocketButton:RegisterEvent("PLAYER_REGEN_ENABLED")
    self.pickpocketButton:SetScript("OnEvent", Thievery_Events)
    local gameVersion = tv.gameVersion
    if gameVersion == 1 then
        self.pickpocketButton:SetAttribute("type", "macro")
        local spellName = C_Spell.GetSpellName(921)
        self.pickpocketButton:SetAttribute("macrotext", "/cast " .. spellName)
    elseif gameVersion == 2 or gameVersion == 3 then
        --____________________________________________________________________________
        --     Pickpocketing with SecureActionButton bugs out in Classic
        --            use SetOverrideBindingSpell directly instead
        --____________________________________________________________________________
        print("Classic")
    end

end

function Thievery_EventLoader(self, event, unit, ...)
    local arg4, arg5 = ...
    if event == "ADDON_LOADED" and unit == "Thievery" then
        Thievery_SavedVariables()
        Thievery_SetupConfigPanel_PostSavedVars(self)
        Thievery_UpdateVisualPosition()
        Thievery_ActivateLockpicking(Thievery_Config.Checkboxes[2].lockpicking)
    elseif event == "PLAYER_ENTERING_WORLD" then
        if unit == false and arg4 == false then return end
        Thievery_ToggleSpeedy(false)
    end
end