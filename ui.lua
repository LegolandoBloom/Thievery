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

local function speedyOnClick()
    if Thievery_Config.Checkboxes.speedyMode == false then
        Thievery_ToggleSpeedy(false)
    end
end

function Thievery_SetupConfigPanel(parent)
    local configPanel = parent.configPanel
    local checkboxes = configPanel.checkboxes
    local keybindFrame = configPanel.keybindFrame
    local moveFrame = configPanel.moveFrame

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

    checkboxes.speedyMode.text:SetText(T["Speedy Mode"])
    checkboxes.speedyMode.onClickFunction = speedyOnClick
    checkboxes.speedyMode.text.tooltip = T["Turns on soft targetting for enemies(if off) and auto-loot(if off) upon first pick-pocket, then keeps it on as long as you are stealthed. Zip from pocket to pocket!"]
    checkboxes.speedyMode:reposition()
    checkboxes.speedyMode.reference = "speedyMode"

    checkboxes.playSound.text:SetText(T["Play Sound Effect"])
    checkboxes.playSound.text.tooltip = T["When checked, plays a sound effect when the pickpocket key is pressed"]
    checkboxes.playSound:reposition()
    checkboxes.playSound.reference = "playSound"
    
    checkboxes.enableSap.text:SetText(T["Enable Sap"])
    checkboxes.enableSap.text.tooltip = T["Cast sap before pick pocket, with the same keybind."]
    checkboxes.enableSap:reposition()
    checkboxes.enableSap.reference = "enableSap"

    checkboxes.debugMode.text:SetText(T["Debug Mode"])
    checkboxes.debugMode:reposition()
    checkboxes.debugMode.reference = "debugMode"

end

