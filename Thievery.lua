local T = Thievery_Translate


function Thievery_OnLoad(self)
    self:RegisterEvent("PLAYER_ENTERING_WORLD")
    self:SetScript("OnEvent", Thievery_EventLoader)
    print(self:GetDebugName())
    self:RegisterEvent("PLAYER_SOFT_INTERACT_CHANGED")
    self:RegisterEvent("PLAYER_SOFT_ENEMY_CHANGED")
    self:RegisterEvent("PLAYER_TARGET_CHANGED")
    self:RegisterEvent("UPDATE_STEALTH")
    self:RegisterEvent("PLAYER_REGEN_DISABLED")
    self:RegisterEvent("PLAYER_REGEN_ENABLED")
    self:SetScript("OnEvent", Thievery_Events)
    self.pickpocketButton:SetAttribute("type", "spell")
    self.pickpocketButton:SetAttribute("unit", "target")
    self.pickpocketButton:SetAttribute("spell", 921)
end

function Thievery_EventLoader(self, event, unit, ...)
    if event == "PLAYER_ENTERING_WORLD" then

    end
end

local function printTargetInfo()
    print("Creature Family: ", UnitCreatureFamily("target"))
    print("Creature Type: ", UnitCreatureType("target"))
    print("Classification: ", UnitClassification("target"))
end

local pickPockedActive = false
function Thievery_Activate(self)
    if not pickPocketActive then
        local assignKey = "E"
        SetOverrideBindingClick(self, true, assignKey, "Thievery_PickpocketButton")
        pickPocketActive = true
        self.visual:Show()
        print("now active")
    end
end
function Thievery_Deactivate(self)
    if pickPocketActive then
        ClearOverrideBindings(self)
        pickPocketActive = false
        self.visual:Hide()
    end
end

local stealthed = false
local validTarget = false
function Thievery_UpdateState(self)
    if InCombatLockdown() then return end
    local inRange = C_Spell.IsSpellInRange(921)
    if stealthed and validTarget and inRange then
        Thievery_Activate(self)
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
function Thievery_Events(self, event, unit)
    if event == "PLAYER_SOFT_INTERACT_CHANGED" or event == "PLAYER_SOFT_ENEMY_CHANGED" or event == "PLAYER_TARGET_CHANGED" then
        if InCombatLockdown() then return end
        if checkTargetValidity() == true then
            validTarget = true
        else
            validTarget = false
        end
        
        if not IsTargetLoose()  then
            printTargetInfo()
        end
        Thievery_UpdateState(self)
    elseif event == "UPDATE_STEALTH" then
        if IsStealthed() then
            stealthed = true
            Thievery_UpdateState(self)
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
    elseif event == "PLAYER_REGEN_DISABLED" then
        Thievery_Deactivate(self)
    elseif event == "PLAYER_REGEN_ENABLED" then
        Thievery_UpdateState(self)
    end

end

-- /dump C_Spell.IsSpellUsable(921)
-- /dump SpellCanTargetUnit()

-- /dump SpellCanTargetUnit("target")