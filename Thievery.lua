local T = Thievery_Translate

local isAlliance
local faction = UnitFactionGroup("player")
if faction == "Alliance" then
    isAlliance = true
elseif faction == "Horde" then
    isAlliance = false
end
print("Player is Alliance?", isAlliance)

Thievery_UI = {
    VisualLocation = {},
}

Thievery_Config ={
    ppKey = nil,
    Checkboxes = {},
}


local PPModeActive = false
local sapModeActive = false

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
    if Thievery_Config.Checkboxes.playSound == nil then
        Thievery_Config.Checkboxes.playSound = true
    end
    if Thievery_Config.Checkboxes.enableSap == nil then
        Thievery_Config.Checkboxes.enableSap = false
    end
end

function Thievery_OnLoad(self)
    self:RegisterEvent("PLAYER_ENTERING_WORLD")
    self:RegisterEvent("ADDON_LOADED")
    self:SetScript("OnEvent", Thievery_EventLoader)
    Thievery_SetupConfigPanel(self)
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
    if event == "ADDON_LOADED" and unit == "Thievery" then
        Thievery_SavedVariables()
        Thievery_ConfigPanel.checkboxes.savedVarTable = Thievery_Config.Checkboxes
        Thievery_KeybindFrame.savedVarTable = Thievery_Config
        Thievery_KeybindFrame.savedVarKey = "ppKey"
        Thievery_FitVisualToKeybind()
        Thievery_ConfigPanel.moveFrame.savedVarTable = Thievery_UI
        Thievery_ConfigPanel.moveFrame.savedVarKey = "VisualLocation"
        -- Thievery_MoveFrame.savedVarTable = Thievery_UI.VisualLocation
        Thievery_UpdateVisualPosition()
    elseif event == "PLAYER_ENTERING_WORLD" then

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
    print("Creature Family: ", UnitCreatureFamily("target"))
    print("Creature Type: ", UnitCreatureType("target"))
    print("Classification: ", UnitClassification("target"))
    print(UnitGUID("target"))
    print(getIDFromGUID(UnitGUID("target")))
end


local target = {}
local function setPPMode(self)
    if not PPModeActive then
        local parent = self:GetParent()
        local assignKey = "E"
        if Thievery_Config.ppKey then
            assignKey = Thievery_Config.ppKey
        end
        self:SetAttribute("spell", 921)
        SetOverrideBindingClick(self, true, assignKey, "Thievery_PickpocketButton")
        parent.visual:Show()
        parent.visual.promptText:SetText("Pickpocket")
        parent.visual.npcName:SetText(target.name)
        PPModeActive = true
        sapModeActive = false
    end
end
local function setSapMode(self)
    if not sapModeActive then 
        local parent = self:GetParent()
        local assignKey = "E"
        if Thievery_Config.ppKey then
            assignKey = Thievery_Config.ppKey
        end
        self:SetAttribute("spell", 6770)
        SetOverrideBindingClick(self, true, assignKey, "Thievery_PickpocketButton")
        PPModeActive = true
        parent.visual:Show()
        parent.visual.promptText:SetText("Sap")
        parent.visual.npcName:SetText(target.name)
        sapModeActive = true
        PPModeActive = false
    end
end
function Thievery_Activate(self)
    if InCombatLockdown() then 
        print("Thievery: State change occured during combat. Please contact author.")
        return 
    end
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
    if PPModeActive or sapModeActive then
        local parent = self:GetParent()
        ClearOverrideBindings(self)
        parent.visual:Hide()
        parent.visual.npcName:SetText(nil)
        PPModeActive = false
        sapModeActive = false
    end
end

function Thievery_CheckTargetLocal(target)
    if not target then return false end
    local npcID = target.npcID
    if not npcID then return false end
    if Session_EnemyIDTable[npcID] then
        --print("session match found!")
        return true
    end
end

local stealthed = false
local validTarget = false
function Thievery_UpdateState(self)
    if InCombatLockdown() then return end
    local inRange = C_Spell.IsSpellInRange(921)
    if stealthed and validTarget and inRange then
        target.guid = UnitGUID("target")
        target.npcID = tonumber(getIDFromGUID(target.guid))
        target.name = UnitName("target")
        local _
        _, target.creatureType = UnitCreatureType("target")
        target.classification = UnitClassification("target")
        -- 1)player 2)target ORDER ON PURPOSE, to avoid checking reputations
        target.reaction = UnitReaction("player", "target")
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
--   if not C_Spell.IsSpellInRange(921) then
--             --print("pickpocket out of range")
--             validTarget = false
--             return
--         end

-- /dump WorldLootObjectExists("target")
--CheckInteractDistance("target", 3)
local function checkTargetValidity()
    if not UnitExists("target") then 
            --print("No eligible target")
            return false
    end
    if UnitIsDead("target") or UnitIsCorpse("target") then
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
        if InCombatLockdown() then return end
        if checkTargetValidity() == true then
            validTarget = true
        else
            validTarget = false
            target = {}
        end
        
        if not IsTargetLoose()  then
            -- printTargetInfo()
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