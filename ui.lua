local T = Thievery_Translate

function Thievery_KeybindFrame_OnBind()
    local ppKey = Thievery_Config.ppKey 
    local visual = Thievery_Visual
    if not ppKey then
        ppKey = "E"
    end
    -- ppKey = "SHIFT-SPACE"
    -- ppKey = "SHIFT-E"
    -- ppKey = "SPACE"
    visual.keybind:SetText(ppKey)
    local width, height = visual.keybind:GetSize()

    local sizeX, sizeY = visual.keybindFrameLeft:GetSize()
    visual.keybindFrameLeft:SetSize(sizeX, height + (width*0.05))
    
    sizeX, sizeY = visual.keybindFrameMid:GetSize()
    visual.keybindFrameMid:SetSize((width * 1.1) + 2, height + (width*0.05))
    
    sizeX, sizeY = visual.keybindFrameRight:GetSize()
    visual.keybindFrameRight:SetSize(sizeX, height + (width*0.05))

    sizeX, sizeY = visual.keybindFrameBGLeft:GetSize()
    visual.keybindFrameBGLeft:SetSize(sizeX, height + (width*0.05))
    
    sizeX, sizeY = visual.keybindFrameBGMid:GetSize()
    visual.keybindFrameBGMid:SetSize((width * 1.1) + 2, height + (width*0.05))
    
    sizeX, sizeY = visual.keybindFrameBGRight:GetSize()
    visual.keybindFrameBGRight:SetSize(sizeX, height + (width*0.05))
    -- visual.keybindFrameBG:SetSize((width * 1.25) + 8, height + (width*0.05))
    Thievery_UpdateState(Thievery.pickpocketButton, true)
end

function Thievery_UpdateVisualPosition()
    local visual = Thievery_Visual
    visual:ClearAllPoints()
    local teeburu = Thievery_UI.VisualLocation
    if next(teeburu) ~= nil then
        visual:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", teeburu.left + 12, teeburu.top - 10)
        visual:SetScale(teeburu.scale)
    else
        visual:SetPoint("TOPLEFT", UIParent, "CENTER", 50, 30)
        visual:SetScale(1)
    end
end

local function speedyOnClick(self, isChecked)
    if Thievery_Config.Checkboxes[1].speedyMode == false then
        Thievery_ToggleSpeedy(false)
    end
end

local function lockpickOnClick(self, isChecked)
    if InCombatLockdown() then return end
    Thievery_ActivateLockpicking(Thievery_Config.Checkboxes[2].lockpicking)
    local checkboxes2 = self:GetParent()
    if isChecked == true then 
        checkboxes2.lockpickAnim:Enable()
        checkboxes2.lockpickAnim.text:SetTextColor(1.0, 0.82, 0.0)
        checkboxes2.lockpickSound:Enable()
        checkboxes2.lockpickSound.text:SetTextColor(1.0, 0.82, 0.0)
    elseif isChecked == false then
        checkboxes2.lockpickAnim:Disable()
        checkboxes2.lockpickAnim.text:SetTextColor(0.9, 0.9, 0.9)
        checkboxes2.lockpickSound:Disable()
        checkboxes2.lockpickSound.text:SetTextColor(0.9, 0.9, 0.9)
    end
end
function Thievery_SetupConfigPanel_PreSavedVars(self)
    local configPanel = self.configPanel
    local checkboxes1 = configPanel.checkboxes1
    local keybindFrame = configPanel.keybindFrame
    local moveFrame = configPanel.moveFrame
    local checkboxes2 = configPanel.checkboxes2
    
    local tabs = configPanel.tabs
    local tabNames = {
        [1] = "Pickpocketing",
        [2] = "Lockpicking"
    }
    tabs.isTabOnTop = true
    for i, name in ipairs(tabNames) do
        tabs:AddTab(name)
    end
    local function tabSelectedCallback(tabID)
        local children = {configPanel:GetChildren()}
        for i, v in pairs(children) do
            local id = v:GetID()
            if id and id ~= 0 then
                if id == tabID then
                    v:Show()
                else
                    v:Hide()
                end
            end
        end
        -- if tabID == 1 then
        --     print("this is tab 1")
        -- elseif tabID == 2 then
        --     print("this is tab 2")
        -- elseif tabID == 3 then
        --     print("this is tab 3")
        -- end
    end
    tabs:SetTabSelectedCallback(tabSelectedCallback)
    tabs:SetTab(1)


    moveFrame.title:SetText(T["Change Visual Location"] .. ":")
    moveFrame.tooltipTitle = T["Change Visual Location"]
    moveFrame.tooltipBody = T["After pressing the button, drag the blue highlighted frame anywhere on your screen and click \'Okay\'."
    .. "\n\nClicking the button again, or clicking the reset icon " .. "to the top-right of the highlighted frame will reset the visual to its default position."]
    moveFrame.callFunc = Thievery_UpdateVisualPosition
    moveFrame.moveAndPlaceFrame.placeholderTexture:SetTexture("Interface/AddOns/Thievery/images/placeholder.png")
    moveFrame.moveAndPlaceFrame.resetButton.tooltip = T["Reset"]

    keybindFrame.menuTitle:SetText(T["Thievery Keybind"])
    keybindFrame.onBindFunction = Thievery_KeybindFrame_OnBind
    keybindFrame.disclaimerText = T["The next key you press will be set as the Thievery key"]
    keybindFrame.disclaimerTextModified = T["Awaiting additional key press. Modifier key down: "]
    keybindFrame.disclaimerTextModified = T["Awaiting additional key press. Modifier key down: "]

    checkboxes1.speedyMode.text:SetText(T["Speedy Mode"])
    checkboxes1.speedyMode.text.tooltip = T["Turns on soft targetting for enemies(if off) and auto-loot(if off) upon first pick-pocket, then keeps it on as long as you are stealthed. Zip from pocket to pocket!"]
    checkboxes1.speedyMode:reposition()
    checkboxes1.speedyMode.onClickCallback = speedyOnClick

    checkboxes1.playSound.text:SetText(T["Play Sound Effect"])
    checkboxes1.playSound.text.tooltip = T["When checked, plays a sound effect when the pickpocket key is pressed."]
    checkboxes1.playSound:reposition()

    
    checkboxes1.enableSap.text:SetText(T["Enable Sap"])
    checkboxes1.enableSap.text.tooltip = T["Cast sap before pick pocket, with the same keybind."]
    checkboxes1.enableSap:reposition()

    checkboxes1.debugMode.text:SetText(T["Debug Mode"])
    checkboxes1.debugMode:reposition()

    
    checkboxes2.lockpicking.text:SetText(T["Right-Click Lockpicking"])
    checkboxes2.lockpicking.text.tooltip = T["Right-Click Lockboxes in your inventory to unlock them!"]
    checkboxes2.lockpicking:reposition()
    checkboxes2.lockpicking.onClickCallback = lockpickOnClick
    
    checkboxes2.lockpickAnim.text:SetText(T["Play Animation"])
    checkboxes2.lockpickAnim.text.tooltip = T["Plays a hand-drawn lockpicking animation overlayed on the lockboxes when casting \'Pick Lock\'."]
    checkboxes2.lockpickAnim:reposition()
    
    checkboxes2.lockpickSound.text:SetText(T["Sound Effect"])
    checkboxes2.lockpickSound.text.tooltip = T["Plays a lockpicking sound effect when you successfully unlock a lockbox."]
    checkboxes2.lockpickSound:reposition()
    
end


function Thievery_SetupConfigPanel_PostSavedVars(self)
    local configPanel = self.configPanel
    local checkboxes1 = configPanel.checkboxes1
    local keybindFrame = configPanel.keybindFrame
    local moveFrame = configPanel.moveFrame
    local checkboxes2 = configPanel.checkboxes2
    
    checkboxes1.savedVarTable = Thievery_Config.Checkboxes[1]
    checkboxes1.speedyMode.reference = "speedyMode"
    checkboxes1.playSound.reference = "playSound"
    checkboxes1.enableSap.reference = "enableSap"
    checkboxes1.debugMode.reference = "debugMode"
    checkboxes1:Update()
    checkboxes2.savedVarTable = Thievery_Config.Checkboxes[2]
    checkboxes2.lockpicking.reference = "lockpicking"
    lockpickOnClick(checkboxes2.lockpicking, Thievery_Config.Checkboxes[2].lockpicking)
    checkboxes2.lockpickAnim.reference = "lockpickAnim"
    checkboxes2.lockpickSound.reference = "lockpickSound"
    checkboxes2:Update()
    keybindFrame.savedVarTable = Thievery_Config
    keybindFrame.keybindRef = "ppKey"
    keybindFrame.baseRef = "ppKeyBase"
    Thievery_KeybindFrame_OnBind()
    moveFrame.savedVarTable = Thievery_UI
    moveFrame.savedVarKey = "VisualLocation"
end