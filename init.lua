SLASH_THIEVERYCONFIGSHOW1 = "/thief"
SLASH_THIEVERYCONFIGSHOW2 = "/thievery"
SLASH_THIEVERYCONFIGSHOW3 = "/teef"
SlashCmdList["THIEVERYCONFIGSHOW"] = function() 
    Thievery_ConfigPanel:Show()
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
    if Thievery_Config.Checkboxes.speedyMode == nil then
        Thievery_Config.Checkboxes.speedyMode = false
    end
    if Thievery_Config.Checkboxes.playSound == nil then
        Thievery_Config.Checkboxes.playSound = true
    end
    if Thievery_Config.Checkboxes.enableSap == nil then
        Thievery_Config.Checkboxes.enableSap = false
    end
    if Thievery_Config.Checkboxes.lockpicking == nil then
        Thievery_Config.Checkboxes.lockpicking = true
    end
    if Thievery_Config.Checkboxes.debugMode == nil then
        Thievery_Config.Checkboxes.debugMode = false
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
    if Thievery_Config.Checkboxes.debugMode == true then
        print(text, ...)
    end
end

function Thievery_BetaDump(dump)
    if Thievery_Config.Checkboxes.debugMode == true then
        DevTools_Dump(dump)
    end
end

function Thievery_BetaTableToString(tbl)
    if Thievery_Config.Checkboxes.debugMode == true then
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
    self.pickpocketButton:SetAttribute("type", "spell")
    self.pickpocketButton:SetAttribute("unit", "target")
    self.pickpocketButton:SetAttribute("spell", 921)
end

function Thievery_EventLoader(self, event, unit, ...)
    local arg4, arg5 = ...
    if event == "ADDON_LOADED" and unit == "Thievery" then
        Thievery_SavedVariables()
        Thievery_SetupConfigPanel_PostSavedVars(self)
        Thievery_UpdateVisualPosition()
        Thievery_ActivateLockpicking(Thievery_Config.Checkboxes.lockpicking)
    elseif event == "PLAYER_ENTERING_WORLD" then
        if unit == false and arg4 == false then return end
        Thievery_ToggleSpeedy(false)
    end
end