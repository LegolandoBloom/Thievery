local T = Thievery_Translate

local function clearTable(teeburu)
    for i, v in pairs(teeburu) do
        teeburu[i] = nil
    end
end

local isAlliance
local faction = UnitFactionGroup("player")
if faction == "Alliance" then
    isAlliance = true
elseif faction == "Horde" then
    isAlliance = false
end

local target = Thievery_Target


local UIActive = false
local PPMode = false
local sapMode = false


function Thievery_OnLoad(self)
    self:RegisterEvent("PLAYER_ENTERING_WORLD")
    self:RegisterEvent("ADDON_LOADED")
    self:SetScript("OnEvent", Thievery_EventLoader)
    Thievery_SetupConfigPanel(self)
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
        Thievery_ConfigPanel.checkboxes.savedVarTable = Thievery_Config.Checkboxes
        Thievery_KeybindFrame.savedVarTable = Thievery_Config
        Thievery_KeybindFrame.savedVarKey = "ppKey"
        Thievery_KeybindFrame_OnBind()
        Thievery_ConfigPanel.moveFrame.savedVarTable = Thievery_UI
        Thievery_ConfigPanel.moveFrame.savedVarKey = "VisualLocation"
        -- Thievery_MoveFrame.savedVarTable = Thievery_UI.VisualLocation
        Thievery_UpdateVisualPosition()
        Thievery_BetaPrint("Player is Alliance?", isAlliance)
    elseif event == "PLAYER_ENTERING_WORLD" then
        if unit == false and arg4 == false then return end
        Thievery_ToggleSpeedy(false) 
    end
end

local Session_EnemyIDTable = {

}



local function getIDFromGUID(guid)
    if not guid then return end
    local starto = 0
    local endo = 0
    for i=1,5,1 do
        starto, endo = string.find(guid, "(%d+)", endo + 1)
        if not endo then
            print("Thievery: Faulty GUID, please contact addon author.")
            return
        end
    end
    local npcID = string.sub(guid, starto, endo)
    return npcID
end

local function printTargetInfo()
    Thievery_BetaPrint("Creature Family: ", UnitCreatureFamily("target"))
    Thievery_BetaPrint("Creature Type: ", UnitCreatureType("target"))
    Thievery_BetaPrint("Classification: ", UnitClassification("target"))
    Thievery_BetaPrint(UnitGUID("target"))
    Thievery_BetaPrint(getIDFromGUID(UnitGUID("target")))
end
SLASH_THIEVERYTARGETINFO1 = "/teeftarget"
SlashCmdList["THIEVERYTARGETINFO"] = printTargetInfo

local lastPrint
local function setPPMode(self)
    local remaining = Thievery_UpdatePPTimers(target.guid)
    if remaining then
        remaining = string.format("%.0f", remaining)
        if remaining ~= lastPrint then
            lastPrint = remaining
            Thievery_BetaPrint("Can pickpocket again in: " .. remaining)
        end
    end
    if not PPMode then
        local parent = self:GetParent()
        local assignKey = "E"
        if Thievery_Config.ppKey then
            assignKey = Thievery_Config.ppKey
        end
        self:SetAttribute("spell", 921)
        SetOverrideBindingClick(self, true, assignKey, "Thievery_PickpocketButton")
        PPMode = true
        sapMode = false
        parent.visual:Show()
        parent.visual.npcName:SetText(target.name)
        parent.visual.promptText:SetText(T["Pickpocket"])
        if remaining then
            parent.visual.promptText:SetTextColor(0.8, 0.8, 0.8)
            parent.visual.throughLine:Show()
            Thievery_PPCooldownFrame:SetCooldown(GetTime(), remaining)
        else
            parent.visual.promptText:SetText(T["Pickpocket"])
            parent.visual.promptText:SetTextColor(1, 0, 0)
            parent.visual.throughLine:Hide()
        end
    end

end
local function setSapMode(self)
    if not sapMode then 
        local parent = self:GetParent()
        local assignKey = "E"
        if Thievery_Config.ppKey then
            assignKey = Thievery_Config.ppKey
        end
        self:SetAttribute("spell", 6770)
        SetOverrideBindingClick(self, true, assignKey, "Thievery_PickpocketButton")
        PPMode = true
        parent.visual:Show()
        parent.visual.promptText:SetText(T["Sap"])
        parent.visual.promptText:SetTextColor(1, 0, 0)
        parent.visual.throughLine:Hide()
        parent.visual.npcName:SetText(target.name)
        sapMode = true
        PPMode = false
    end
end
function Thievery_Activate(self)
    if InCombatLockdown() then 
        print("Thievery: State change occured during combat. Please contact author.")
        return 
    end
    UIActive = true
    local sapped = false
    AuraUtil.ForEachAura("target", "HARMFUL", nil, function(name, icon, _, _, _, _, _, _, _, spellID, ...)
        if spellID == 6770 then
            sapped = true
        end
    end)
    if Thievery_Config.Checkboxes.enableSap == true then
        if sapped == false then
            setSapMode(self)
        else
            setPPMode(self)
        end
    else
        setPPMode(self)
    end
end
function Thievery_Deactivate(self)
    if InCombatLockdown() then 
        print("Thievery: State change occured during combat. Please contact author.")
        return 
    end
    if UIActive == true then
        local parent = self:GetParent()
        ClearOverrideBindings(self)
        parent.visual:Hide()
        parent.visual.npcName:SetText(nil)
        UIActive = false
        PPMode = false
        sapMode = false
    end
end

function Thievery_CheckTargetLocal(target)
    if not target then return false end
    local npcID = target.npcID
    if not npcID then return false end
    if Session_EnemyIDTable[npcID] then
        if not PPMode and not sapMode then
            Thievery_BetaPrint("session match found!")
        end
        return true
    end
end

local stealthed = false
local validTarget = false
function Thievery_UpdateState(self, resetMode)
    if InCombatLockdown() then return end
    if resetMode then
        PPMode = false
        sapMode = false
        ClearOverrideBindings(self)
    end
    local inRange = C_Spell.IsSpellInRange(921)
    if stealthed and validTarget and inRange then
        if Thievery_CheckTargetLocal(target) then
            Thievery_Activate(self)
        elseif Thievery_CheckTargetForPP(target, isAlliance) then
            Session_EnemyIDTable[target.npcID] = true
            Thievery_Activate(self)
        else
            Thievery_Deactivate(self)
        end
    else
        Thievery_Deactivate(self)
    end
end

--CheckInteractDistance("target", 3)
local function checkTargetValidity()
    if not UnitExists("target") then 
            --Thievery_BetaPrint("No eligible target")
            return false
    end
    if UnitIsDead("target") or UnitIsCorpse("target") then
        return false
    end
    if UnitIsPlayer("target") then
        return false
    end
    -- 1)player 2)target ORDER ON PURPOSE. To avoid checking reputations
    local reaction = UnitReaction("player", "target")
    if reaction ~= 2 and reaction ~= 4 then
        return false
    end
    return true
end
local function checkAndHandleStealth(self)
    if IsStealthed() then
        stealthed = true
        local erapusuThreshold = 0.3
        local erapusuCounter = 0
        self:SetScript("OnUpdate", function(self, elapsed)
            erapusuCounter = erapusuCounter + elapsed
            if erapusuCounter < erapusuThreshold then
                return
            end
            erapusuCounter = 0
            if InCombatLockdown() then
                self:SetScript("OnUpdate", nil)
            end
            if stealthed == false then
                self:SetScript("OnUpdate", nil)
            end
            Thievery_UpdateState(self)
        end)
    else
        stealthed = false
        Thievery_UpdateState(self)
        self:SetScript("OnUpdate", nil)
    end
end
function Thievery_Events(self, event, unit)
    if event == "PLAYER_SOFT_INTERACT_CHANGED" or event == "PLAYER_SOFT_ENEMY_CHANGED" or event == "PLAYER_TARGET_CHANGED" then
        
        PPMode = false
        sapMode = false
        clearTable(target)
        Thievery_PPCooldownFrame:Clear()
        if InCombatLockdown() then return end
        if checkTargetValidity() == true then
            validTarget = true
            target.guid = UnitGUID("target")
            target.npcID = tonumber(getIDFromGUID(target.guid))
            target.name = UnitName("target")
            local _
            _, target.creatureType = UnitCreatureType("target")
            target.classification = UnitClassification("target")
            -- 1)player 2)target ORDER ON PURPOSE, to avoid checking reputations
            target.reaction = UnitReaction("player", "target")
        else
            validTarget = false
        end
        if not IsTargetLoose() then
            --printTargetInfo()
        end
        checkAndHandleStealth(self)
        Thievery_UpdateState(self)
    elseif event == "UPDATE_STEALTH" then
        checkAndHandleStealth(self)
        Thievery_UpdateState(self)
    elseif event == "PLAYER_REGEN_DISABLED" then
        Thievery_Deactivate(self)
    elseif event == "PLAYER_REGEN_ENABLED" then
        Thievery_UpdateState(self)
    end
end

-- /dump C_Spell.IsSpellUsable(921)
-- /dump SpellCanTargetUnit()

-- /dump SpellCanTargetUnit("target")


