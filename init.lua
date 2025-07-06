
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
    if Thievery_Config.Checkboxes.debugMode == nil then
        Thievery_Config.Checkboxes.debugMode = false
    end
end

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